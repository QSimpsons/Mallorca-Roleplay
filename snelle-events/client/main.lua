savedPosition = nil
currentEvent = nil
local activeBlips = {}
local isFrozen = false
local eventVehicle = nil
local ClientFramework = nil
local ClientFrameworkName = 'standalone'

CreateThread(function()
    while Config.Framework == 'esx' and not ClientFramework do
        if GetResourceState('es_extended') == 'started' then
            ClientFramework = exports['es_extended']:getSharedObject()
            ClientFrameworkName = 'esx'
            break
        end
        Wait(500)
    end
end)

local function resolveNotifyType()
    if Config.Notify ~= 'auto' then return Config.Notify end
    if GetResourceState('ox_lib') == 'started' then return 'ox' end
    if ClientFrameworkName == 'esx' then return 'esx' end
    if ClientFrameworkName == 'qbcore' then return 'qb' end
    return 'native'
end

function NotifyClient(message)
    local notifyType = resolveNotifyType()

    if notifyType == 'ox' and GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:notify({ description = message, type = 'inform' })
        return
    end

    if notifyType == 'esx' and ClientFramework then
        ClientFramework.ShowNotification(message)
        return
    end

    if notifyType == 'qb' and ClientFramework then
        ClientFramework.Functions.Notify(message, 'primary', 5000)
        return
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

RegisterNetEvent('snelle-events:client:chatMessage', function(message)
    local prefix = Config.ChatPrefix or '[EVENT]'
    local color = Config.ChatColor or { 56, 189, 248 }

    TriggerEvent('chat:addMessage', {
        color = color,
        multiline = false,
        args = { prefix, message }
    })
end)

local function savePosition()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    savedPosition = {
        coords = { x = coords.x, y = coords.y, z = coords.z },
        heading = GetEntityHeading(ped)
    }
end

local function returnToPosition()
    if not Config.ReturnToPosition or not savedPosition then return end

    local ped = PlayerPedId()
    local c = savedPosition.coords

    DoScreenFadeOut(500)
    Wait(600)

    SetEntityCoordsNoOffset(ped, c.x, c.y, c.z, false, false, false)
    SetEntityHeading(ped, savedPosition.heading)

    Wait(200)
    DoScreenFadeIn(500)

    savedPosition = nil
    NotifyClient(L('returned_to_position'))
end

local function clearBlips()
    for _, blip in pairs(activeBlips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    activeBlips = {}
end

local function updateBlips(events)
    clearBlips()
    if not Config.Blips.enabled then return end

    for _, event in ipairs(events) do
        if event.status ~= 'ended' and event.coords then
            local blip = AddBlipForCoord(event.coords.x, event.coords.y, event.coords.z)
            SetBlipSprite(blip, Config.Blips.sprite)
            SetBlipColour(blip, Config.Blips.color)
            SetBlipScale(blip, Config.Blips.scale)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(L('blip_label', event.name))
            EndTextCommandSetBlipName(blip)
            activeBlips[event.id] = blip
        end
    end
end

local function teleportToEvent(event)
    local ped = PlayerPedId()
    local coords, heading = Utils.CoordsToVector(event.coords)

    DoScreenFadeOut(400)
    Wait(500)

    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(ped, heading)

    Wait(200)
    DoScreenFadeIn(400)

    NotifyClient(L('teleported'))
end

local function setFrozen(state)
    isFrozen = state
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, state)

    if state then
        NotifyClient(L('frozen'))
    else
        NotifyClient(L('unfrozen'))
    end
end

local function cleanupVehicle()
    if not Config.DeleteEventVehicleOnLeave then return end
    if eventVehicle and DoesEntityExist(eventVehicle) then
        DeleteEntity(eventVehicle)
    end
    eventVehicle = nil
end

local function spawnEventVehicle(modelName)
    cleanupVehicle()

    local model = joaat(modelName)
    RequestModel(model)

    local timeout = 0
    while not HasModelLoaded(model) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if not HasModelLoaded(model) then return end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    eventVehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false)
    SetPedIntoVehicle(ped, eventVehicle, -1)
    SetVehicleOnGroundProperly(eventVehicle)
    SetModelAsNoLongerNeeded(model)

    NotifyClient(L('vehicle_spawned'))
end

local function giveEventLoadout(event)
    if not event.settings.allowWeapons or not event.settings.loadout then return end

    local ped = PlayerPedId()
    RemoveAllPedWeapons(ped, true)

    for _, weapon in ipairs(event.settings.loadout) do
        GiveWeaponToPed(ped, joaat(weapon), event.settings.ammo or 120, false, false)
    end

    NotifyClient(L('weapons_given'))
end

local function resetEventState(skipReturn)
    if isFrozen then
        setFrozen(false)
    end

    cleanupVehicle()

    local ped = PlayerPedId()
    SetEntityInvincible(ped, false)
    SetPlayerInvincible(PlayerId(), false)

    currentEvent = nil

    if not skipReturn then
        returnToPosition()
    else
        savedPosition = nil
    end
end

RegisterNetEvent('snelle-events:client:notify', function(message)
    NotifyClient(message)
end)

RegisterNetEvent('snelle-events:client:globalAnnounce', function(message)
    NotifyClient(message)
end)

local function stripWeaponsForEvent(event)
    if not Config.StripWeaponsOnJoin then return end
    if event.settings.allowWeapons or event.type == 'pvp' then return end

    local ped = PlayerPedId()
    RemoveAllPedWeapons(ped, true)
end

RegisterNetEvent('snelle-events:client:syncEvents', function(events)
    updateBlips(events)
    SendNUIMessage({ action = 'syncEvents', events = events })
end)

RegisterNetEvent('snelle-events:client:openJoinMenu', function(events)
    SendNUIMessage({ action = 'openJoin', events = events })
    SetNuiFocus(true, true)
end)

RegisterNetEvent('snelle-events:client:joinedEvent', function(event, isHost)
    if not savedPosition then
        savePosition()
        TriggerServerEvent('snelle-events:server:savePlayerData', savedPosition)
    end

    currentEvent = event
    stripWeaponsForEvent(event)
    teleportToEvent(event)

    if event.settings.freezeOnStart and event.status == 'waiting' then
        setFrozen(true)
    end

    SendNUIMessage({
        action = 'showEventHud',
        event = event,
        isHost = isHost
    })
end)

RegisterNetEvent('snelle-events:client:leftEvent', function(event, skipReturn)
    SendNUIMessage({ action = 'hideEventHud' })
    resetEventState(skipReturn)
end)

RegisterNetEvent('snelle-events:client:countdown', function(seconds, event)
    currentEvent = event

    CreateThread(function()
        for i = seconds, 1, -1 do
            NotifyClient(L('countdown', i))
            SendNUIMessage({ action = 'countdown', seconds = i })
            Wait(1000)
        end
    end)
end)

RegisterNetEvent('snelle-events:client:eventStarted', function(event)
    currentEvent = event

    if isFrozen then
        setFrozen(false)
    end

    if event.type == 'race' or event.type == 'derby' then
        if event.settings.vehicle then
            spawnEventVehicle(event.settings.vehicle)
        end
    end

    if event.type == 'pvp' or event.settings.allowWeapons then
        giveEventLoadout(event)
    end

    SendNUIMessage({ action = 'eventStarted', event = event })
end)

RegisterNetEvent('snelle-events:client:eventStopped', function(event)
    SendNUIMessage({ action = 'hideEventHud' })
    resetEventState(false)
end)

RegisterNetEvent('snelle-events:client:becameHost', function(event)
    currentEvent = event
    SendNUIMessage({ action = 'becameHost', event = event })
end)

RegisterNetEvent('snelle-events:client:playerJoined', function(eventId, playerName, count)
    if currentEvent and currentEvent.id == eventId then
        currentEvent.playerCount = count
        SendNUIMessage({ action = 'updatePlayerCount', count = count })
    end
end)

RegisterNetEvent('snelle-events:client:playerLeft', function(eventId, playerName, count)
    if currentEvent and currentEvent.id == eventId then
        currentEvent.playerCount = count
        SendNUIMessage({ action = 'updatePlayerCount', count = count })
    end
end)

-- Sync events bij spawn
CreateThread(function()
    Wait(2000)
    TriggerServerEvent('snelle-events:server:requestEvents')
end)

-- F6 keybind voor staff panel
RegisterCommand('+snelleEventsPanel', function()
    TriggerServerEvent('snelle-events:server:requestOpenPanel')
end, false)

RegisterCommand('-snelleEventsPanel', function() end, false)
RegisterKeyMapping('+snelleEventsPanel', 'Open Event Panel', 'keyboard', Config.Keys.openPanel)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    clearBlips()
    cleanupVehicle()
    SetNuiFocus(false, false)

    if isFrozen then
        FreezeEntityPosition(PlayerPedId(), false)
    end
end)
