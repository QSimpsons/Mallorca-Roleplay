savedPosition = nil
currentEvent = nil
syncedEvents = {}
outOfBoundsTimer = 0
raceFinished = false
local activeBlips = {}
local isFrozen = false
local eventVehicle = nil
local ClientFramework = nil
local ClientFrameworkName = 'standalone'
local isSpectating = false
local spectateIndex = 1

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

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

RegisterNetEvent('snelle-events:client:chatMessage', function(message)
    TriggerEvent('chat:addMessage', {
        color = Config.ChatColor or { 56, 189, 248 },
        multiline = false,
        args = { Config.ChatPrefix or '[EVENT]', message }
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

local function shouldReturnOnLeave()
    if Config.Teleport and Config.Teleport.returnOnLeave ~= nil then
        return Config.Teleport.returnOnLeave
    end
    return Config.ReturnToPosition
end

local function returnToPosition()
    if not shouldReturnOnLeave() or not savedPosition then return end

    local c = savedPosition.coords
    TeleportToCoords({ x = c.x, y = c.y, z = c.z, heading = savedPosition.heading }, {
        force = true,
        noSpread = true,
        silent = true
    })
    savedPosition = nil
    NotifyClient(L('returned_to_position'))
end

local function clearBlips()
    for _, blip in pairs(activeBlips) do
        if DoesBlipExist(blip) then RemoveBlip(blip) end
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

            if event.finishCoords and event.type == 'race' then
                local finish = AddBlipForCoord(event.finishCoords.x, event.finishCoords.y, event.finishCoords.z)
                SetBlipSprite(finish, 38)
                SetBlipColour(finish, 2)
                SetBlipScale(finish, 0.85)
                BeginTextCommandSetBlipName('STRING')
                AddTextComponentString('Finish: ' .. event.name)
                EndTextCommandSetBlipName(finish)
                activeBlips[event.id .. '_finish'] = finish
            end
        end
    end
end

function TeleportToCoords(coords, options)
    options = options or {}

    local ped = PlayerPedId()
    local x, y, z = coords.x + 0.0, coords.y + 0.0, coords.z + 0.0
    local heading = coords.heading or 0.0

    if Config.Teleport and Config.Teleport.spreadPlayers and not options.noSpread then
        local radius = Config.Teleport.spreadRadius or 3.0
        local angle = math.random() * math.pi * 2
        local dist = math.random() * radius
        x = x + math.cos(angle) * dist
        y = y + math.sin(angle) * dist
    end

    local useFade = not (Config.Teleport and Config.Teleport.useScreenFade == false)
    if useFade then
        DoScreenFadeOut(400)
        Wait(500)
    end

    RequestCollisionAtCoord(x, y, z)
    SetEntityCoordsNoOffset(ped, x, y, z, false, false, false)
    SetEntityHeading(ped, heading)

    local timeout = 0
    while not HasCollisionLoadedAroundEntity(ped) and timeout < 50 do
        Wait(50)
        timeout = timeout + 1
    end

    if useFade then
        Wait(100)
        DoScreenFadeIn(400)
    end

    if not options.silent then
        NotifyClient(L('teleported'))
    end
end

local function setFrozen(state)
    isFrozen = state
    FreezeEntityPosition(PlayerPedId(), state)
    NotifyClient(state and L('frozen') or L('unfrozen'))
end

local function cleanupVehicle()
    if not Config.DeleteEventVehicleOnLeave then
        eventVehicle = nil
        return
    end
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
    if not event.settings or not event.settings.allowWeapons or not event.settings.loadout then return end
    local ped = PlayerPedId()
    RemoveAllPedWeapons(ped, true)
    for _, weapon in ipairs(event.settings.loadout) do
        GiveWeaponToPed(ped, joaat(weapon), event.settings.ammo or 120, false, false)
    end
    NotifyClient(L('weapons_given'))
end

local function stripWeaponsForEvent(event)
    if not Config.StripWeaponsOnJoin then return end
    if event.settings and (event.settings.allowWeapons or event.type == 'pvp' or event.type == 'deathmatch') then return end
    RemoveAllPedWeapons(PlayerPedId(), true)
end

local function stopSpectate()
    if not isSpectating then return end
    isSpectating = false
    local ped = PlayerPedId()
    NetworkSetInSpectatorMode(false, ped)
    SetEntityVisible(ped, true, false)
    SetEntityCollision(ped, true, true)
    NotifyClient(L('spectate_off'))
end

local function resetEventState(skipReturn)
    stopSpectate()
    if isFrozen then setFrozen(false) end
    cleanupVehicle()
    local ped = PlayerPedId()
    SetEntityInvincible(ped, false)
    SetPlayerInvincible(PlayerId(), false)
    NetworkSetFriendlyFireOption(true)
    currentEvent = nil
    raceFinished = false
    outOfBoundsTimer = 0
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

RegisterNetEvent('snelle-events:client:syncEvents', function(events)
    syncedEvents = events or {}
    updateBlips(syncedEvents)
    SendNUIMessage({ action = 'syncEvents', events = syncedEvents })
end)

RegisterNetEvent('snelle-events:client:openJoinMenu', function(events)
    SendNUIMessage({ action = 'openJoin', events = events })
    SetEventNuiFocus(true)
end)

RegisterNetEvent('snelle-events:client:teleportToEvent', function(coords)
    TeleportToCoords(coords)
end)

RegisterNetEvent('snelle-events:client:joinedEvent', function(event, isHost)
    if not savedPosition then
        savePosition()
        TriggerServerEvent('snelle-events:server:savePlayerData', savedPosition)
    end

    currentEvent = event
    raceFinished = false
    stripWeaponsForEvent(event)

    -- Spawn / teleport naar eventlocatie (config: Config.Teleport.onJoin / onCreate)
    local shouldTeleport = true
    if isHost and Config.Teleport and Config.Teleport.onCreate == false then
        shouldTeleport = false
    elseif not isHost and Config.Teleport and Config.Teleport.onJoin == false then
        shouldTeleport = false
    end

    if shouldTeleport and event.coords then
        TeleportToCoords(event.coords, { noSpread = isHost == true })
    end

    if event.settings and event.settings.freezeOnStart and event.status == 'waiting' then
        setFrozen(true)
    end

    SendNUIMessage({ action = 'showEventHud', event = event, isHost = isHost })
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
    raceFinished = false

    if isFrozen then setFrozen(false) end

    if event.type == 'race' or event.type == 'derby' then
        if event.settings and event.settings.vehicle then
            spawnEventVehicle(event.settings.vehicle)
        end
    end

    if event.type == 'pvp' or event.type == 'deathmatch' or event.type == 'hunt' or (event.settings and event.settings.allowWeapons) then
        giveEventLoadout(event)
    end

    if event.type == 'parachute' then
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local height = (event.settings and event.settings.dropHeight) or 800.0
        SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z + height, false, false, false)
        GiveWeaponToPed(ped, joaat('GADGET_PARACHUTE'), 1, false, true)
        NotifyClient(L('parachute_ready'))
    end

    if event.roles then
        local myId = GetPlayerServerId(PlayerId())
        local role = nil
        for _, p in ipairs(event.players or {}) do
            if p.id == myId then role = p.role break end
        end
        if role == 'target' then NotifyClient(L('role_target'))
        elseif role == 'hunter' then NotifyClient(L('role_hunter'))
        elseif role == 'hider' then NotifyClient(L('role_hider'))
        elseif role == 'seeker' then NotifyClient(L('role_seeker')) end
    end

    SendNUIMessage({ action = 'eventStarted', event = event })
end)

RegisterNetEvent('snelle-events:client:eventStopped', function()
    SendNUIMessage({ action = 'hideEventHud' })
    resetEventState(false)
end)

RegisterNetEvent('snelle-events:client:eventUpdate', function(event)
    currentEvent = event
    SendNUIMessage({ action = 'eventUpdate', event = event })
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

RegisterNetEvent('snelle-events:client:invite', function(data)
    SendNUIMessage({ action = 'showInvite', data = data })
    SetEventNuiFocus(true)
end)

RegisterNetEvent('snelle-events:client:eliminated', function(event)
    currentEvent = event
    local ped = PlayerPedId()
    SetEntityInvincible(ped, true)
    NotifyClient(L('eliminated', ''))
    SendNUIMessage({ action = 'eliminated', event = event })
end)

RegisterNetEvent('snelle-events:client:toggleSpectate', function(event)
    if not event then return end
    currentEvent = event

    if isSpectating then
        stopSpectate()
        return
    end

    local targets = {}
    local myId = GetPlayerServerId(PlayerId())
    for _, p in ipairs(event.players or {}) do
        if p.id ~= myId and not p.eliminated then
            targets[#targets + 1] = p.id
        end
    end

    if #targets == 0 then return end

    isSpectating = true
    spectateIndex = 1
    local targetPed = GetPlayerPed(GetPlayerFromServerId(targets[spectateIndex]))
    if targetPed and targetPed ~= 0 then
        local ped = PlayerPedId()
        SetEntityVisible(ped, false, false)
        SetEntityCollision(ped, false, false)
        NetworkSetInSpectatorMode(true, targetPed)
        NotifyClient(L('spectate_on'))
    end
end)

CreateThread(function()
    Wait(2000)
    TriggerServerEvent('snelle-events:server:requestEvents')
end)

RegisterCommand('+snelleEventsPanel', function()
    TriggerServerEvent('snelle-events:server:requestOpenPanel')
end, false)
RegisterCommand('-snelleEventsPanel', function() end, false)
RegisterKeyMapping('+snelleEventsPanel', 'Open Event Panel', 'keyboard', Config.Keys.openPanel)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    clearBlips()
    cleanupVehicle()
    stopSpectate()
    SetNuiFocus(false, false)
    if isFrozen then FreezeEntityPosition(PlayerPedId(), false) end
end)
