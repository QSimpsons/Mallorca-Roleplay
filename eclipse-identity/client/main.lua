local ESX = nil
local open = false
local saving = false

local function debugPrint(message)
    if Config.Debug then
        print(('[eclipse-identity] %s'):format(message))
    end
end

local function ensureESX()
    if ESX then
        return ESX
    end

    if GetResourceState('es_extended') ~= 'started' then
        return nil
    end

    local ok, obj = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if ok and obj then
        ESX = obj
        return ESX
    end

    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)

    return ESX
end

local function notify(message)
    local esx = ensureESX()
    if esx and esx.ShowNotification then
        esx.ShowNotification(message)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, false)
    end
end

local function hasIdentity()
    local esx = ensureESX()
    if not esx or not esx.GetPlayerData then
        return false
    end

    local data = esx.GetPlayerData()
    return data and type(data.firstName) == 'string' and data.firstName ~= ''
end

local function payload()
    return {
        action = 'open',
        serverName = Config.ServerName,
        discord = Config.Discord,
        rules = Config.Rules,
        dateFormat = Config.DateFormat,
        minHeight = Config.MinHeight,
        maxHeight = Config.MaxHeight,
        minAge = Config.MinAge,
        maxAge = Config.MaxAge,
        minName = Config.MinNameLength,
        maxName = Config.MaxNameLength
    }
end

function OpenMenu()
    if open then
        return
    end

    open = true
    SetNuiFocus(true, true)
    SendNUIMessage(payload())
end

function CloseMenu()
    if not open then
        return
    end

    open = false
    saving = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function finishRegistration()
    SetTimeout(1500, function()
        CloseMenu()

        local esx = ensureESX()
        local multichar = false
        if esx and esx.GetConfig then
            local ok, cfg = pcall(function()
                return esx.GetConfig()
            end)
            multichar = ok and cfg and cfg.Multichar or false
        end

        if not multichar then
            TriggerEvent('esx_skin:playerRegistered')
        end
    end)
end

local function saveWithEsxIdentity(data, cb)
    local esx = ensureESX()
    if not esx or not esx.TriggerServerCallback then
        cb({ ok = false, error = 'ESX is niet gestart.' })
        return
    end

    esx.TriggerServerCallback('esx_identity:registerIdentity', function(success)
        if success == true then
            cb({ ok = true })
            finishRegistration()
            return
        end

        if type(success) == 'string' and success ~= '' then
            cb({ ok = false, error = success })
            return
        end

        cb({
            ok = false,
            error = 'Deze gegevens zijn niet geaccepteerd. Controleer naam, leeftijd en lengte.'
        })
    end, data)
end

local function saveWithEclipse(data, cb)
    local esx = ensureESX()
    if not esx or not esx.TriggerServerCallback then
        cb({ ok = false, error = 'ESX is niet gestart.' })
        return
    end

    esx.TriggerServerCallback('eclipse-identity:register', function(response)
        if response and response.ok then
            cb({ ok = true })
            finishRegistration()
            return
        end

        cb({
            ok = false,
            error = (response and response.error) or 'Opslaan is mislukt.'
        })
    end, data)
end

RegisterNUICallback('register', function(data, cb)
    if saving then
        cb({ ok = false, error = 'Even geduld.' })
        return
    end

    local valid, result = Identity.Validate(data, Config)
    if not valid then
        cb({ ok = false, error = result })
        return
    end

    saving = true

    local function done(response)
        saving = false
        cb(response)
    end

    if Config.UseEsxIdentity and GetResourceState('esx_identity') == 'started' then
        debugPrint('opslaan via esx_identity')
        saveWithEsxIdentity(result, done)
        return
    end

    debugPrint('opslaan via eclipse-identity')
    saveWithEclipse(result, done)
end)

RegisterNetEvent('esx_identity:showRegisterIdentity', function()
    TriggerEvent('esx_skin:resetFirstSpawn')
    OpenMenu()
end)

RegisterNetEvent('eclipse-identity:open', function()
    OpenMenu()
end)

if Config.Command and Config.Command ~= '' then
    RegisterCommand(Config.Command, function()
        if hasIdentity() and not IsPlayerAceAllowed(PlayerId(), 'eclipse.identity') then
            notify('Je bent al ingeschreven.')
            return
        end

        OpenMenu()
    end, false)
end

CreateThread(function()
    while true do
        if open then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 200, true)
            DisableControlAction(0, 322, true)
            Wait(0)
        else
            Wait(400)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and open then
        SetNuiFocus(false, false)
    end
end)

exports('Open', OpenMenu)
exports('Close', CloseMenu)
