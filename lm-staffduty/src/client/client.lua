local Config = require 'shared.config'
local settingsOpen = false
local isOnDuty = false

-- Eigen tag-instellingen (grootte, transparantie, avatar aan/uit, ...)
local myTagSettings = Config.Tag.defaultSettings

-- [serverId] = laatst bekende tag-instellingen van andere staff (voor hun tag bij ons)
local remoteVisuals = {}

-- Haalt de opgeslagen tag-instellingen van de speler op bij de server.
local function loadMyTagSettings()
    if not (lib and lib.callback) then return end
    lib.callback('lm-staffduty:server:getUserSettings', false, function(settings)
        myTagSettings = settings or Config.Tag.defaultSettings
    end)
end

CreateThread(function()
    loadMyTagSettings()

    if lib and lib.callback then
        lib.callback('lm-staffduty:server:getAllTagVisuals', false, function(all)
            if type(all) == 'table' then
                remoteVisuals = all
            end
        end)
    end
end)

RegisterNetEvent('lm-staffduty:client:syncTagVisuals', function(sid, settings)
    if type(sid) ~= 'number' or type(settings) ~= 'table' then return end
    remoteVisuals[sid] = settings
end)

-- ======== Staff-tag boven het hoofd ========
-- De server stuurt periodiek (Config.Tag.updateInterval, standaard 500ms) een
-- LIJST die AL gefilterd is op afstand, met de echte wereld-coördinaten van
-- iedereen die dichtbij is. Die coördinaten cachen we hier alleen.
--
-- De omzetting naar scherm-positie (GetScreenCoordFromWorldCoord) gebeurt in
-- een aparte loop die ELKE FRAME draait: dat moet, want anders "springt" de
-- tag maar 2x per seconde naar een nieuwe plek op je scherm zodra je camera
-- beweegt, wat precies het schokkerige/knipperende gevoel gaf.
local nearbyStaff = {}

RegisterNetEvent('lm-staffduty:client:nearbyStaffTags', function(nearby)
    nearbyStaff = (type(nearby) == 'table') and nearby or {}
end)

CreateThread(function()
    while true do
        local sleep = 500

        if Config.Tag and Config.Tag.enabled and #nearbyStaff > 0 then
            sleep = 0
            local tags = {}
            local myPed = cache.ped

            for _, entry in ipairs(nearbyStaff) do
                local isSelf = entry.isSelf
                local targetPed = isSelf and myPed or GetPlayerPed(GetPlayerFromServerId(entry.id))

                local headX, headY, headZ

                if targetPed and targetPed ~= 0 and DoesEntityExist(targetPed) then
                    -- Live positie, elke frame opnieuw: geen vertraging, volgt
                    -- rennen/animaties exact zoals het spel ze op dit moment tekent.
                    local c = GetEntityCoords(targetPed)
                    headX, headY, headZ = c.x, c.y, c.z + 0.9
                else
                    -- Fallback: alleen als de ped hier lokaal (nog) niet bestaat
                    -- (bv. net binnen je scope), gebruik de laatst bekende
                    -- server-positie zodat de tag niet ineens verdwijnt.
                    headX, headY, headZ = entry.x, entry.y, entry.z + 0.9
                end

                local onScreen, sx, sy = GetScreenCoordFromWorldCoord(headX, headY, headZ)

                if onScreen then
                    tags[#tags + 1] = {
                        serverId      = entry.id,
                        screenX       = sx * 100,
                        screenY       = sy * 100,
                        distance      = entry.distance,
                        name          = entry.name,
                        rank          = entry.rank,
                        rankColor     = entry.rankColor,
                        avatarUrl     = entry.avatarUrl,
                        isSelf        = isSelf,
                        ownerSettings = remoteVisuals[entry.id],
                    }
                end
            end

            SendNUIMessage({
                action       = 'updatePedTags',
                tags         = tags,
                userSettings = myTagSettings,
            })
        else
            SendNUIMessage({ action = 'clearAllTags' })
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('lm-staffduty:client:dutyStateChanged', function(value)
    isOnDuty = value
    lib.callback('illenium-appearance:server:getAppearance', false, function(skin)
        if value then
            Wait(1000)
            ExecuteCommand('txAdmin-reauth')
            loadMyTagSettings()
        else
            TriggerEvent('skinchanger:loadSkin', skin)
            TriggerEvent('txcl:setAdmin', false, false, locale('no_access'))

            if settingsOpen then
                settingsOpen = false
                SetNuiFocus(false, false)
                SendNUIMessage({ action = 'closeSettings' })
            end
        end

        lib.notify({
            title = value and locale('duty_on') or locale('duty_off'),
            type  = 'info',
        })
    end, GetEntityModel(cache.ped))
end)

-- ======== Instellingen-menu (/staffsettings) ========
RegisterCommand(Config.SettingsCommand, function()
    TriggerServerEvent('lm-staffduty:server:openSettings')
end, false)

RegisterNetEvent('lm-staffduty:client:openSettingsMenu', function(userInfo)
    if settingsOpen then return end
    settingsOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action       = 'openSettings',
        userSettings = myTagSettings,
        userInfo     = userInfo,
        uiColor      = Config.Tag.uiColor,
    })
end)

RegisterNUICallback('closeSettings', function(_, cb)
    settingsOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeSettings' })
    cb('ok')
end)

RegisterNUICallback('saveSettings', function(data, cb)
    if type(data) == 'table' then
        myTagSettings = data
        TriggerServerEvent('lm-staffduty:server:saveSettings', data)
    end

    settingsOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeSettings' })
    cb('ok')
end)

RegisterNUICallback('uiReady', function(_, cb)
    cb('ok')
end)

CreateThread(function()
    while true do
        if isOnDuty then
            local ped = PlayerPedId()

            RemoveAllPedWeapons(ped, true)

            DisablePlayerFiring(PlayerId(), true)
            SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        end

        Wait(250)
    end
end)
