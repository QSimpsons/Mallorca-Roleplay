local ESX = nil
local ui = {
    open = false,
    mode = nil,
    locationId = nil,
    token = 0
}
local taking = false

local function loadESX()
    if ESX then
        return
    end
    if exports and exports['es_extended'] then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and obj then
            ESX = obj
            return
        end
    end
    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)
end

local function notify(msg)
    if not msg or msg == '' then
        return
    end
    if GetResourceState('ox_lib') == 'started' then
        local ok = pcall(function()
            exports.ox_lib:notify({ description = msg, type = 'inform' })
        end)
        if ok then
            return
        end
    end
    loadESX()
    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(msg)
        return
    end
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function help(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

local function vehicleLabel(model)
    if model == nil then
        return 'Voertuig'
    end
    local hash = model
    if type(hash) == 'string' then
        hash = tonumber(hash) or joaat(hash)
    end
    local display = GetDisplayNameFromVehicleModel(hash)
    if not display or display == '' or display == 'CARNOTFOUND' then
        return 'Voertuig'
    end
    local label = GetLabelText(display)
    if not label or label == '' or label == 'NULL' then
        return display
    end
    return label
end

local function readFuel(vehicle)
    local fuel = GetVehicleFuelLevel(vehicle)
    if GetResourceState('ox_fuel') == 'started' then
        local stateFuel = Entity(vehicle).state.fuel
        if type(stateFuel) == 'number' then
            fuel = stateFuel
        end
    end
    return fuel
end

local function setFuel(vehicle, level)
    level = tonumber(level) or (Config.Fuel and Config.Fuel.default) or 100.0
    if level < 0.0 then
        level = 0.0
    end
    if level > 100.0 then
        level = 100.0
    end
    SetVehicleFuelLevel(vehicle, level + 0.0)
    if GetResourceState('ox_fuel') == 'started' then
        Entity(vehicle).state:set('fuel', level, true)
    end
    if GetResourceState('LegacyFuel') == 'started' then
        pcall(function()
            exports.LegacyFuel:SetFuel(vehicle, level)
        end)
    end
    if GetResourceState('cdn-fuel') == 'started' then
        pcall(function()
            exports['cdn-fuel']:SetFuel(vehicle, level)
        end)
    end
    if GetResourceState('ps-fuel') == 'started' then
        pcall(function()
            exports['ps-fuel']:SetFuel(vehicle, level)
        end)
    end
end

local function giveKeys(vehicle, plate)
    local system = Config.Keys and Config.Keys.system or 'none'
    if system == 'none' or not plate or plate == '' then
        return
    end
    if system == 'auto' then
        if GetResourceState('qs-vehiclekeys') == 'started' then
            system = 'qs'
        elseif GetResourceState('wasabi_carlock') == 'started' then
            system = 'wasabi'
        elseif GetResourceState('mk_vehiclekeys') == 'started' then
            system = 'mk'
        elseif GetResourceState('vehicles_keys') == 'started' then
            system = 'jaksam'
        elseif GetResourceState('cd_garage') == 'started' then
            system = 'cd'
        else
            return
        end
    end
    pcall(function()
        if system == 'qs' then
            exports['qs-vehiclekeys']:GiveKeys(plate, nil, true)
        elseif system == 'wasabi' then
            exports.wasabi_carlock:GiveKey(plate)
        elseif system == 'mk' then
            exports['mk_vehiclekeys']:AddKey(vehicle)
        elseif system == 'jaksam' then
            TriggerServerEvent('vehicles_keys:selfGiveVehicleKeys', plate)
        elseif system == 'cd' then
            TriggerEvent('cd_garage:AddKeys', plate)
        end
    end)
end

local function getProps(vehicle)
    local props = {}
    loadESX()
    if ESX and ESX.Game and ESX.Game.GetVehicleProperties then
        local ok, result = pcall(ESX.Game.GetVehicleProperties, vehicle)
        if ok and type(result) == 'table' then
            props = result
        end
    end
    props.plate = GetVehicleNumberPlateText(vehicle)
    props.model = props.model or GetEntityModel(vehicle)
    props.fuelLevel = readFuel(vehicle)
    props.engineHealth = GetVehicleEngineHealth(vehicle)
    props.bodyHealth = GetVehicleBodyHealth(vehicle)
    return props
end

local function applyProps(vehicle, props)
    loadESX()
    if ESX and ESX.Game and ESX.Game.SetVehicleProperties then
        pcall(ESX.Game.SetVehicleProperties, vehicle, props)
    end
    if props.engineHealth then
        SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
    end
    if props.bodyHealth then
        SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
    end
end

local function loadModel(model)
    if type(model) == 'string' then
        model = tonumber(model) or joaat(model)
    end
    model = tonumber(model)
    if not model or not IsModelInCdimage(model) or not IsModelAVehicle(model) then
        return nil
    end
    RequestModel(model)
    local timeout = GetGameTimer() + 8000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then
            return nil
        end
        Wait(10)
    end
    return model
end

local function findVeh(netId, plate)
    netId = tonumber(netId) or 0
    if netId ~= 0 then
        local ent = NetworkGetEntityFromNetworkId(netId)
        if ent and ent ~= 0 and DoesEntityExist(ent) then
            return ent
        end
    end
    local key = Config.NormalizePlate(plate)
    if key == '' then
        return 0
    end
    local pool = GetGamePool('CVehicle')
    for i = 1, #pool do
        if Config.NormalizePlate(GetVehicleNumberPlateText(pool[i])) == key then
            return pool[i]
        end
    end
    return 0
end

local function spawnVehicle(data)
    local props = data.props or {}
    local model = loadModel(props.model)
    if not model then
        return nil
    end
    local c = data.coords or {}
    RequestCollisionAtCoord(c.x, c.y, c.z)
    local veh = CreateVehicle(model, c.x, c.y, c.z, c.w or 0.0, true, true)
    if not veh or veh == 0 then
        SetModelAsNoLongerNeeded(model)
        return nil
    end
    SetEntityAsMissionEntity(veh, true, true)
    local timeout = GetGameTimer() + 1500
    while not HasCollisionLoadedAroundEntity(veh) and GetGameTimer() < timeout do
        Wait(0)
    end
    local class = GetVehicleClass(veh)
    if class ~= 14 and class ~= 15 and class ~= 16 then
        SetVehicleOnGroundProperly(veh)
    end
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    applyProps(veh, props)
    local plate = data.plate or props.plate or ''
    if plate ~= '' then
        SetVehicleNumberPlateText(veh, plate)
    end
    setFuel(veh, props.fuelLevel or (Config.Fuel and Config.Fuel.default) or 100.0)
    SetVehicleEngineOn(veh, true, true, false)
    SetVehicleDoorsLocked(veh, 1)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, 'OFF')
    local netId = NetworkGetNetworkIdFromEntity(veh)
    if netId and netId ~= 0 then
        SetNetworkIdCanMigrate(netId, true)
    end
    if Config.WarpIntoVehicle then
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    end
    SetModelAsNoLongerNeeded(model)
    CreateThread(function()
        Wait(400)
        if DoesEntityExist(veh) then
            giveKeys(veh, plate)
        end
    end)
    return veh
end

local function firstClearSpawn(location)
    if not location or not location.spawns then
        return nil
    end
    for i = 1, #location.spawns do
        local spot = location.spawns[i]
        if not IsAnyVehicleNearPoint(spot.x, spot.y, spot.z, 2.7) then
            return { x = spot.x, y = spot.y, z = spot.z, w = spot.w or 0.0 }
        end
    end
    return nil
end

local function findCallCoords()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local found, node, nodeHeading = GetClosestVehicleNodeWithHeading(pos.x, pos.y, pos.z, 1, 3.0, 0)
    if found and type(node) == 'vector3' and #(pos - node) <= (Config.Call.maxDistance or 35.0) then
        if not IsAnyVehicleNearPoint(node.x, node.y, node.z, 2.5) then
            return { x = node.x, y = node.y, z = node.z, w = nodeHeading or heading }
        end
    end
    local fwd = GetEntityForwardVector(ped)
    return {
        x = pos.x + fwd.x * 5.0,
        y = pos.y + fwd.y * 5.0,
        z = pos.z,
        w = heading
    }
end

local function findLocation(id)
    return Config.FindGarage(id) or Config.FindImpound(id)
end

local function closeUi()
    ui.open = false
    ui.token = ui.token + 1
    taking = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function requestOpen(mode, location)
    if ui.open then
        return
    end
    ui.token = ui.token + 1
    ui.open = true
    ui.mode = mode
    ui.locationId = location and location.id or nil
    taking = false
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'loading',
        mode = mode,
        title = location and location.label or 'Voertuig oproepen',
        subtitle = 'Voertuigen laden...'
    })
    TriggerServerEvent('snelle-garage:server:list', {
        mode = mode,
        locationId = ui.locationId,
        token = ui.token
    })
end

local storing = false

local function pressedInteract()
    return IsControlJustReleased(0, 38) or IsDisabledControlJustReleased(0, 38)
end

local function storeVehicle(location)
    if storing then
        return
    end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= ped then
        notify(Config.Text.notDriver)
        return
    end
    local props = getProps(veh)
    if not props.plate or props.plate == '' then
        notify(Config.Text.plateMismatch)
        return
    end
    storing = true
    notify(Config.Text.storing)
    TriggerServerEvent('snelle-garage:server:store', {
        plate = props.plate,
        props = props,
        locationId = location.id,
        netId = NetworkGetNetworkIdFromEntity(veh)
    })
    SetTimeout(1200, function()
        storing = false
    end)
end

local function staffImpound(entity, reason)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        notify(Config.Text.noVehicle)
        return
    end
    local props = getProps(entity)
    TriggerServerEvent('snelle-garage:server:staffImpound', {
        plate = props.plate,
        props = props,
        reason = reason or 'In beslag genomen',
        netId = NetworkGetNetworkIdFromEntity(entity),
        model = props.model
    })
end

local function isStaffJob()
    local data = ESX and ESX.PlayerData
    local job = data and data.job and data.job.name
    if not job then
        return false
    end
    return Config.ImpoundJobs and Config.ImpoundJobs[string.lower(job)] == true
end

RegisterNetEvent('snelle-garage:client:notify', function(msg)
    notify(msg)
end)

RegisterNetEvent('snelle-garage:client:close', function()
    closeUi()
end)

RegisterNetEvent('snelle-garage:client:idle', function()
    taking = false
    SendNUIMessage({ action = 'idle' })
end)

RegisterNetEvent('snelle-garage:client:open', function(data)
    if not data or data.token ~= ui.token or not ui.open then
        return
    end
    local vehicles = data.vehicles or {}
    for i = 1, #vehicles do
        vehicles[i].label = vehicleLabel(vehicles[i].model)
    end
    SendNUIMessage({
        action = 'open',
        mode = data.mode,
        title = data.title,
        subtitle = data.subtitle,
        vehicles = vehicles,
        cash = data.cash,
        bank = data.bank
    })
end)

RegisterNetEvent('snelle-garage:client:spawn', function(data)
    taking = false
    closeUi()
    if type(data) ~= 'table' or type(data.token) ~= 'string' then
        return
    end
    CreateThread(function()
        local veh = spawnVehicle(data)
        if not veh then
            TriggerServerEvent('snelle-garage:server:spawnFailed', data.token)
            notify(Config.Text.modelFail)
            return
        end
        TriggerServerEvent('snelle-garage:server:spawned', data.token, NetworkGetNetworkIdFromEntity(veh))
        if data.mode == 'call' then
            notify(Config.Text.called)
        elseif data.mode == 'impound' then
            notify(Config.Text.recovered)
        else
            notify(Config.Text.spawned)
        end
        PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    end)
end)

RegisterNetEvent('snelle-garage:client:stored', function(data)
    data = data or {}
    storing = false
    local veh = 0
    local ped = PlayerPedId()
    local current = GetVehiclePedIsIn(ped, false)
    if current ~= 0 and Config.NormalizePlate(GetVehicleNumberPlateText(current)) == Config.NormalizePlate(data.plate) then
        veh = current
    else
        veh = findVeh(data.netId, data.plate)
    end
    if veh ~= 0 then
        local ped = PlayerPedId()
        if GetVehiclePedIsIn(ped, false) == veh then
            local side = GetOffsetFromEntityInWorldCoords(veh, 1.8, 0.0, 0.0)
            SetEntityCoords(ped, side.x, side.y, side.z, false, false, false, false)
        end
        SetEntityAsMissionEntity(veh, true, true)
        DeleteVehicle(veh)
        if DoesEntityExist(veh) then
            DeleteEntity(veh)
        end
    end
    if not data.quiet then
        notify(data.message or Config.Text.parked)
    end
end)

RegisterNUICallback('close', function(_, cb)
    cb({ ok = true })
    closeUi()
end)

RegisterNUICallback('refresh', function(_, cb)
    cb({ ok = true })
    if not ui.open then
        return
    end
    local location = ui.locationId and findLocation(ui.locationId) or nil
    ui.token = ui.token + 1
    taking = false
    SendNUIMessage({
        action = 'loading',
        mode = ui.mode,
        title = location and location.label or 'Voertuig oproepen',
        subtitle = 'Voertuigen laden...'
    })
    TriggerServerEvent('snelle-garage:server:list', {
        mode = ui.mode,
        locationId = ui.locationId,
        token = ui.token
    })
end)

RegisterNUICallback('take', function(data, cb)
    cb({ ok = true })
    if taking or not ui.open then
        return
    end
    local plate = data and data.plate
    if type(plate) ~= 'string' or plate == '' then
        return
    end
    taking = true
    local coords
    if ui.mode == 'call' then
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            taking = false
            notify(Config.Text.inVehicleCall)
            SendNUIMessage({ action = 'idle' })
            return
        end
        coords = findCallCoords()
    else
        coords = firstClearSpawn(findLocation(ui.locationId))
        if not coords then
            taking = false
            notify(Config.Text.spawnBlocked)
            SendNUIMessage({ action = 'idle' })
            return
        end
    end
    TriggerServerEvent('snelle-garage:server:spawn', {
        plate = plate,
        mode = ui.mode,
        locationId = ui.locationId,
        coords = coords
    })
end)

local function drawMarker(loc, kind)
    local marker = Config.Markers[kind] or Config.Markers.car
    DrawMarker(
        marker.type or 36,
        loc.coords.x, loc.coords.y, loc.coords.z + 0.2,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0.85, 0.85, 0.85,
        marker.r or 255, marker.g or 138, marker.b or 26, 170,
        false, true, 2, false, nil, nil, false
    )
end

local function createBlips()
    local function add(loc, kind)
        if loc.blip == false then
            return
        end
        local defaults = Config.Blips[kind] or Config.Blips.car
        local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
        SetBlipSprite(blip, defaults.sprite or 357)
        SetBlipColour(blip, defaults.color or 17)
        SetBlipScale(blip, defaults.scale or 0.75)
        SetBlipAsShortRange(blip, Config.BlipShortRange == true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(loc.label)
        EndTextCommandSetBlipName(blip)
    end
    for i = 1, #Config.Garages do
        add(Config.Garages[i], Config.Garages[i].type)
    end
    for i = 1, #Config.Impounds do
        add(Config.Impounds[i], 'impound')
    end
end

local function nearestOf(list, maxDist)
    local coords = GetEntityCoords(PlayerPedId())
    local best, bestDist
    for i = 1, #list do
        local dist = #(coords - list[i].coords)
        if dist <= maxDist and (not bestDist or dist < bestDist) then
            best = list[i]
            bestDist = dist
        end
    end
    return best
end

local function openCall()
    if not Config.Call.enabled then
        notify(Config.Text.callOff)
        return
    end
    if IsPedInAnyVehicle(PlayerPedId(), false) then
        notify(Config.Text.inVehicleCall)
        return
    end
    requestOpen('call', nil)
end

RegisterCommand(Config.Commands.garage or 'garage', function()
    local ped = PlayerPedId()
    local garage = nearestOf(Config.Garages, Config.CommandDistance or 22.0)
    if not garage then
        notify(Config.Text.notHere)
        return
    end
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
        storeVehicle(garage)
        return
    end
    requestOpen('garage', garage)
end, false)

local function openImpoundCommand()
    local impound = nearestOf(Config.Impounds, Config.CommandDistance or 22.0)
    if not impound then
        notify(Config.Text.notImpound)
        return
    end
    requestOpen('impound', impound)
end

RegisterCommand(Config.Commands.impound or 'impound', openImpoundCommand, false)
RegisterCommand('inbeslag', openImpoundCommand, false)
RegisterCommand(Config.Commands.call or 'oproep', openCall, false)

if Config.Call.enabled then
    RegisterKeyMapping(Config.Commands.call or 'oproep', 'Voertuig oproepen', 'keyboard', Config.Call.key or 'F7')
end

RegisterCommand(Config.Commands.staffImpound or 'inbeslagnemen', function(_, args)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        local pool = GetGamePool('CVehicle')
        local bestDist
        for i = 1, #pool do
            local dist = #(coords - GetEntityCoords(pool[i]))
            if dist < 6.0 and (not bestDist or dist < bestDist) then
                veh = pool[i]
                bestDist = dist
            end
        end
    end
    local reason = table.concat(args or {}, ' ')
    if reason == '' then
        reason = 'In beslag genomen'
    end
    staffImpound(veh, reason)
end, false)

CreateThread(function()
    while not ESX do
        loadESX()
        Wait(200)
    end
    if ESX.GetPlayerData then
        ESX.PlayerData = ESX.GetPlayerData()
    end
    createBlips()
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    loadESX()
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob', function(job)
    loadESX()
    ESX.PlayerData = ESX.PlayerData or {}
    ESX.PlayerData.job = job
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local closest, closestDist, closestKind

        local function consider(list, kind)
            for i = 1, #list do
                local loc = list[i]
                local dist = #(coords - loc.coords)
                if dist < (Config.MarkerDistance or 28.0) then
                    sleep = 0
                    drawMarker(loc, kind == 'impound' and 'impound' or loc.type)
                end
                if not closestDist or dist < closestDist then
                    closest = loc
                    closestDist = dist
                    closestKind = kind
                end
            end
        end

        consider(Config.Garages, 'garage')
        consider(Config.Impounds, 'impound')

        if closest and closestDist and not ui.open and not IsPauseMenuActive() then
            local veh = GetVehiclePedIsIn(ped, false)
            local driving = veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped
            local limit = Config.InteractDistance or 2.5
            if closestKind == 'garage' and driving then
                limit = Config.StoreDistance or 8.0
            end
            if closestDist <= limit then
                sleep = 0
                if closestKind == 'garage' and driving then
                    help(Config.Text.store)
                    if pressedInteract() then
                        storeVehicle(closest)
                    end
                elseif veh == 0 then
                    help(closestKind == 'impound' and Config.Text.openImpound or Config.Text.openGarage)
                    if pressedInteract() then
                        requestOpen(closestKind == 'impound' and 'impound' or 'garage', closest)
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

local targetReady = false

local function setupTarget()
    if targetReady or GetResourceState('ox_target') ~= 'started' then
        return
    end
    targetReady = true
    local ok = pcall(function()
        for i = 1, #Config.Garages do
            local garage = Config.Garages[i]
            exports.ox_target:addSphereZone({
                coords = garage.coords,
                radius = 2.2,
                debug = false,
                options = {
                    {
                        name = 'snelle_garage_' .. garage.id,
                        icon = 'fa-solid fa-warehouse',
                        label = 'Garage openen',
                        distance = 2.5,
                        onSelect = function()
                            local ped = PlayerPedId()
                            local veh = GetVehiclePedIsIn(ped, false)
                            if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
                                storeVehicle(garage)
                                return
                            end
                            requestOpen('garage', garage)
                        end
                    }
                }
            })
        end
        for i = 1, #Config.Impounds do
            local impound = Config.Impounds[i]
            exports.ox_target:addSphereZone({
                coords = impound.coords,
                radius = 2.2,
                debug = false,
                options = {
                    {
                        name = 'snelle_impound_' .. impound.id,
                        icon = 'fa-solid fa-truck-ramp-box',
                        label = 'Impound openen',
                        distance = 2.5,
                        canInteract = function()
                            return not IsPedInAnyVehicle(PlayerPedId(), false)
                        end,
                        onSelect = function()
                            requestOpen('impound', impound)
                        end
                    }
                }
            })
        end
        exports.ox_target:addGlobalVehicle({
            {
                name = 'snelle_staff_impound',
                icon = 'fa-solid fa-warehouse',
                label = 'In beslag nemen',
                distance = 3.0,
                canInteract = function(entity)
                    return isStaffJob() and entity and entity ~= 0
                end,
                onSelect = function(data)
                    staffImpound(data.entity, 'In beslag genomen')
                end
            }
        })
    end)
    if not ok then
        targetReady = false
    end
end

AddEventHandler('onClientResourceStart', function(name)
    if name == 'ox_target' or name == GetCurrentResourceName() then
        setupTarget()
    end
end)

CreateThread(function()
    Wait(1500)
    setupTarget()
end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then
        SetNuiFocus(false, false)
    end
end)
