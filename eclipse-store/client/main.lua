local open = false
local pendingCatalog = false

local function dbg(...)
    if Config.Debug then
        print('[eclipse-store]', ...)
    end
end

local function notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

local function setFocus(state)
    SetNuiFocus(state, state)
    SetNuiFocusKeepInput(false)
end

local function closeStore()
    if not open then
        return
    end
    open = false
    setFocus(false)
    SendNUIMessage({ action = 'close' })
end

local function openStore()
    if open then
        return
    end

    open = true
    pendingCatalog = true
    setFocus(true)
    SendNUIMessage({
        action = 'open',
        loading = true,
        ui = {
            storeName = Config.StoreName,
            serverName = Config.ServerName,
            discordUrl = Config.DiscordUrl,
            discordMembers = Config.DiscordMembers,
            banner = Config.Banner,
            newBadgeCategory = Config.NewBadgeCategory,
            storeUrl = Config.StoreUrl,
        },
    })
    TriggerServerEvent('eclipse-store:server:getCatalog')
end

RegisterNetEvent('eclipse-store:client:catalog', function(payload)
    pendingCatalog = false
    if not open then
        return
    end

    SendNUIMessage({
        action = 'catalog',
        payload = payload,
    })
end)

RegisterNetEvent('eclipse-store:client:basketResult', function(result)
    if not open then
        if result and result.message then
            notify(result.message)
        elseif result and result.error then
            notify(result.error)
        end
        return
    end

    SendNUIMessage({
        action = 'basket',
        result = result,
    })

    if result and result.openUrl and result.openUrl ~= '' then
        SendNUIMessage({ action = 'openUrl', url = result.openUrl })
    end
end)

RegisterNetEvent('eclipse-store:client:openUrl', function(url)
    if type(url) ~= 'string' or url == '' then
        return
    end
    SendNUIMessage({ action = 'openUrl', url = url })
end)

RegisterNUICallback('close', function(_, cb)
    closeStore()
    cb({ ok = true })
end)

RegisterNUICallback('refresh', function(_, cb)
    TriggerServerEvent('eclipse-store:server:getCatalog')
    cb({ ok = true })
end)

RegisterNUICallback('getBasket', function(_, cb)
    TriggerServerEvent('eclipse-store:server:getBasket')
    cb({ ok = true })
end)

RegisterNUICallback('addToBasket', function(data, cb)
    local ident = data and (data.ident or data.package_id or data.id)
    if not ident then
        cb({ ok = false })
        return
    end
    TriggerServerEvent('eclipse-store:server:addToBasket', ident)
    cb({ ok = true })
end)

RegisterNUICallback('removeFromBasket', function(data, cb)
    local ident = data and (data.ident or data.package_id or data.id)
    if not ident then
        cb({ ok = false })
        return
    end
    TriggerServerEvent('eclipse-store:server:removeFromBasket', ident)
    cb({ ok = true })
end)

RegisterNUICallback('checkout', function(_, cb)
    TriggerServerEvent('eclipse-store:server:checkout')
    cb({ ok = true })
end)

RegisterNUICallback('openExternal', function(data, cb)
    local url = data and data.url
    if type(url) == 'string' and url ~= '' then
        -- CEF helper used by FiveM NUI
        dbg('openExternal', url)
    end
    cb({ ok = true })
end)

RegisterCommand(Config.Command or 'store', function()
    if open then
        closeStore()
    else
        openStore()
    end
end, false)

if Config.OpenKey and Config.OpenKey ~= '' then
    RegisterKeyMapping(Config.Command or 'store', 'Open Eclipse Store', 'keyboard', Config.OpenKey)
end

-- Export for other resources
exports('OpenStore', openStore)
exports('CloseStore', closeStore)

AddEventHandler('onResourceStop', function(res)
    if res == GetCurrentResourceName() and open then
        setFocus(false)
    end
end)

CreateThread(function()
    while true do
        if open then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 257, true)
            if IsDisabledControlJustPressed(0, 322) then -- ESC
                closeStore()
            end
            Wait(0)
        else
            Wait(400)
        end
    end
end)