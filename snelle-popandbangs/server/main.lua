local ESX
local installed = {}
local saveBlocked = false
local recentAction = {}
local lastPop = {}

local function loadESX()
    if ESX then
        return true
    end

    local ok, obj = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if ok and obj then
        ESX = obj
        return true
    end

    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)

    return ESX ~= nil
end

local function getPlayer(src)
    if not ESX then
        return nil
    end
    return ESX.GetPlayerFromId(src)
end

local function getItemCount(src, name)
    if GetInventoryType() == 'ox_inventory' then
        local ok, count = pcall(function()
            return exports.ox_inventory:GetItemCount(src, name)
        end)
        if ok then
            return count or 0
        end
        return 0
    end

    local xPlayer = getPlayer(src)
    if not xPlayer then
        return 0
    end

    local item = xPlayer.getInventoryItem(name)
    if not item then
        return 0
    end

    return item.count or item.amount or 0
end

local function removeItem(src, name, count)
    count = count or 1
    if getItemCount(src, name) < count then
        return false
    end

    if GetInventoryType() == 'ox_inventory' then
        local ok, removed = pcall(function()
            return exports.ox_inventory:RemoveItem(src, name, count)
        end)
        return ok and removed ~= false
    end

    local xPlayer = getPlayer(src)
    if not xPlayer then
        return false
    end

    xPlayer.removeInventoryItem(name, count)
    return true
end

local function hasJob(src)
    if not Config.RequireJob then
        return true
    end

    local xPlayer = getPlayer(src)
    local job = xPlayer and xPlayer.job and xPlayer.job.name
    if not job then
        return false
    end

    for i = 1, #(Config.Jobs or {}) do
        if Config.Jobs[i] == job then
            return true
        end
    end

    return false
end

local function loadInstalled()
    local raw = LoadResourceFile(GetCurrentResourceName(), Config.DataFile or 'data/installed.json')
    if not raw or raw == '' then
        installed = {}
        return
    end

    local ok, decoded = pcall(json.decode, raw)
    if ok and type(decoded) == 'table' then
        installed = decoded
        return
    end

    saveBlocked = true
    installed = {}
    print('[snelle-popandbangs] data/installed.json is ongeldig. Er wordt niets opgeslagen tot je dat bestand herstelt.')
end

local function saveInstalled()
    if saveBlocked then
        print('[snelle-popandbangs] Opslaan overgeslagen: installed.json was ongeldig bij het starten.')
        return
    end

    local payload = next(installed) and json.encode(installed) or '{}'
    SaveResourceFile(GetCurrentResourceName(), Config.DataFile or 'data/installed.json', payload, #payload)
end

local function stageOfPlate(plate)
    local value = tonumber(installed[plate])
    if not value then
        return 0
    end

    value = math.floor(value)
    if value < 1 or value > 6 or not Config.Stages[value] then
        return 0
    end

    return value
end

local function vehicleFromNet(netId)
    if type(netId) ~= 'number' then
        return nil
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return nil
    end

    if GetEntityType(vehicle) ~= 2 then
        return nil
    end

    return vehicle
end

local function isDriver(vehicle, ped)
    if type(GetPedInVehicleSeat) == 'function' then
        local ok, driver = pcall(GetPedInVehicleSeat, vehicle, -1)
        if ok then
            return driver == ped
        end
    end

    return GetVehiclePedIsIn(ped, false) == vehicle
end

local function playerNearVehicle(src, vehicle)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then
        return false
    end

    return #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) <= (Config.ServerDistance or 6.0)
end

local function typeBlocked(vehicle)
    if type(GetVehicleType) ~= 'function' then
        return false
    end

    local ok, kind = pcall(GetVehicleType, vehicle)
    if not ok or type(kind) ~= 'string' then
        return false
    end

    return Config.BlockedTypes and Config.BlockedTypes[kind] == true
end

local function tooSoon(src)
    local now = GetGameTimer()
    if recentAction[src] and (now - recentAction[src]) < 1500 then
        return true
    end
    return false
end

local function markAction(src)
    recentAction[src] = GetGameTimer()
end

local function applyState(vehicle, stage)
    Entity(vehicle).state:set('popbangStage', stage or 0, true)
end

local function plateOf(vehicle)
    return NormalizePlate(GetVehicleNumberPlateText(vehicle))
end

local function reply(src, id, result)
    TriggerClientEvent('snelle-popandbangs:client:response', src, id, result)
end

RegisterNetEvent('snelle-popandbangs:server:install', function(id, payload)
    local src = source
    if type(id) ~= 'number' or type(payload) ~= 'table' then
        return
    end

    local stage = tonumber(payload.stage)
    if not stage then
        reply(src, id, { ok = false, key = 'invalid' })
        return
    end

    stage = math.floor(stage)
    local cfg = Config.Stages[stage]
    if not cfg then
        reply(src, id, { ok = false, key = 'invalid' })
        return
    end

    if tooSoon(src) then
        reply(src, id, { ok = false, key = 'busy' })
        return
    end

    if not hasJob(src) then
        reply(src, id, { ok = false, key = 'no_job' })
        return
    end

    local vehicle = vehicleFromNet(payload.netId)
    if not vehicle then
        reply(src, id, { ok = false, key = 'no_vehicle' })
        return
    end

    if not playerNearVehicle(src, vehicle) then
        reply(src, id, { ok = false, key = 'too_far' })
        return
    end

    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 and GetVehiclePedIsIn(ped, false) == vehicle then
        reply(src, id, { ok = false, key = 'exit_vehicle' })
        return
    end

    if GetEntitySpeed(vehicle) > (Config.MaxInstallSpeed or 1.5) + 0.4 then
        reply(src, id, { ok = false, key = 'vehicle_moving' })
        return
    end

    if typeBlocked(vehicle) then
        reply(src, id, { ok = false, key = 'bad_class' })
        return
    end

    local plate = plateOf(vehicle)
    if not plate then
        reply(src, id, { ok = false, key = 'invalid' })
        return
    end

    local current = stageOfPlate(plate)
    if current == stage then
        reply(src, id, { ok = false, key = 'already', stage = current })
        return
    end

    if current > stage then
        reply(src, id, { ok = false, key = 'need_higher', stage = current })
        return
    end

    if not removeItem(src, cfg.item, 1) then
        reply(src, id, { ok = false, key = 'no_item' })
        return
    end

    installed[plate] = stage
    saveInstalled()
    applyState(vehicle, stage)
    markAction(src)

    print(('[snelle-popandbangs] %s heeft stage %s gezet op %s'):format(src, stage, plate))

    if current > 0 then
        reply(src, id, { ok = true, key = 'upgraded', from = current, stage = stage })
        return
    end

    reply(src, id, { ok = true, key = 'installed', stage = stage })
end)

RegisterNetEvent('snelle-popandbangs:server:remove', function(id, payload)
    local src = source
    if type(id) ~= 'number' or type(payload) ~= 'table' then
        return
    end

    if tooSoon(src) then
        reply(src, id, { ok = false, key = 'busy' })
        return
    end

    if not hasJob(src) then
        reply(src, id, { ok = false, key = 'no_job' })
        return
    end

    local vehicle = vehicleFromNet(payload.netId)
    if not vehicle then
        reply(src, id, { ok = false, key = 'no_vehicle' })
        return
    end

    if not playerNearVehicle(src, vehicle) then
        reply(src, id, { ok = false, key = 'too_far' })
        return
    end

    local plate = plateOf(vehicle)
    if not plate or stageOfPlate(plate) <= 0 then
        reply(src, id, { ok = false, key = 'nothing_installed' })
        return
    end

    if not removeItem(src, Config.RemoverItem, 1) then
        reply(src, id, { ok = false, key = 'no_remover' })
        return
    end

    installed[plate] = nil
    saveInstalled()
    applyState(vehicle, 0)
    markAction(src)

    print(('[snelle-popandbangs] %s heeft pop & bangs van %s gehaald'):format(src, plate))
    reply(src, id, { ok = true, key = 'removed' })
end)

RegisterNetEvent('snelle-popandbangs:server:sync', function(netId)
    local src = source
    local vehicle = vehicleFromNet(netId)
    if not vehicle then
        return
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 or GetVehiclePedIsIn(ped, false) ~= vehicle then
        return
    end

    local plate = plateOf(vehicle)
    local stage = plate and stageOfPlate(plate) or 0
    if stage > 0 then
        applyState(vehicle, stage)
    end

    TriggerClientEvent('snelle-popandbangs:client:synced', src, stage)
end)

RegisterNetEvent('snelle-popandbangs:server:pop', function(netId)
    local src = source
    local vehicle = vehicleFromNet(netId)
    if not vehicle then
        return
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 or not isDriver(vehicle, ped) then
        return
    end

    local plate = plateOf(vehicle)
    local stage = plate and stageOfPlate(plate) or 0
    local cfg = Config.Stages[stage]
    if not cfg then
        return
    end

    local now = GetGameTimer()
    local minGap = math.floor((cfg.cooldown or 400) * 0.7)
    if lastPop[src] and (now - lastPop[src]) < minGap then
        return
    end
    lastPop[src] = now

    if (Entity(vehicle).state.popbangStage or 0) ~= stage then
        applyState(vehicle, stage)
    end

    local origin = GetEntityCoords(vehicle)
    local maxDist = Config.SyncDistance or 70.0

    for _, id in ipairs(GetPlayers()) do
        local target = tonumber(id)
        if target and target ~= src then
            local targetPed = GetPlayerPed(target)
            if targetPed and targetPed ~= 0 and #(GetEntityCoords(targetPed) - origin) <= maxDist then
                TriggerClientEvent('snelle-popandbangs:client:pop', target, netId, stage)
            end
        end
    end
end)

local function vehicleOfAdmin(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then
        return nil
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if not vehicle or vehicle == 0 or not isDriver(vehicle, ped) then
        return nil
    end

    return vehicle
end

RegisterCommand('popbangset', function(src, args)
    if src == 0 then
        print('[snelle-popandbangs] /popbangset gebruik je in-game, in de bestuurdersstoel.')
        return
    end

    local stage = tonumber(args[1] or '')
    if not stage or not Config.Stages[math.floor(stage)] then
        TriggerClientEvent('snelle-popandbangs:client:notify', src, { key = 'admin_range' })
        return
    end

    stage = math.floor(stage)
    local vehicle = vehicleOfAdmin(src)
    if not vehicle then
        TriggerClientEvent('snelle-popandbangs:client:notify', src, { key = 'admin_usage' })
        return
    end

    local plate = plateOf(vehicle)
    if not plate then
        TriggerClientEvent('snelle-popandbangs:client:notify', src, { key = 'invalid' })
        return
    end

    installed[plate] = stage
    saveInstalled()
    applyState(vehicle, stage)
    TriggerClientEvent('snelle-popandbangs:client:notify', src, {
        key = 'admin_set',
        stage = stage,
        plate = plate
    })
end, true)

RegisterCommand('popbangclear', function(src)
    if src == 0 then
        print('[snelle-popandbangs] /popbangclear gebruik je in-game, in de bestuurdersstoel.')
        return
    end

    local vehicle = vehicleOfAdmin(src)
    if not vehicle then
        TriggerClientEvent('snelle-popandbangs:client:notify', src, { key = 'admin_usage' })
        return
    end

    local plate = plateOf(vehicle)
    if not plate then
        TriggerClientEvent('snelle-popandbangs:client:notify', src, { key = 'invalid' })
        return
    end

    installed[plate] = nil
    saveInstalled()
    applyState(vehicle, 0)
    TriggerClientEvent('snelle-popandbangs:client:notify', src, {
        key = 'admin_clear',
        plate = plate
    })
end, true)

exports('GetStage', function(plate)
    plate = NormalizePlate(plate)
    if not plate then
        return 0
    end
    return stageOfPlate(plate)
end)

local function registerUsables()
    if not ESX then
        return
    end

    local usable = {}
    for stage = 1, 6 do
        local cfg = Config.Stages[stage]
        if cfg and cfg.item then
            usable[#usable + 1] = cfg.item
        end
    end
    usable[#usable + 1] = Config.RemoverItem

    for i = 1, #usable do
        local itemName = usable[i]
        ESX.RegisterUsableItem(itemName, function(playerId)
            if itemName == Config.RemoverItem then
                TriggerClientEvent('snelle-popandbangs:client:useRemove', playerId)
                return
            end
            TriggerClientEvent('snelle-popandbangs:client:use', playerId, itemName)
        end)
    end
end

AddEventHandler('playerDropped', function()
    recentAction[source] = nil
    lastPop[source] = nil
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= 'ox_inventory' and resource ~= 'es_extended' then
        return
    end

    CreateThread(function()
        Wait(500)
        loadESX()
        registerUsables()
    end)
end)

CreateThread(function()
    loadInstalled()

    while not loadESX() do
        Wait(100)
    end

    local deadline = GetGameTimer() + 15000
    while GetResourceState('ox_inventory') == 'starting' and GetGameTimer() < deadline do
        Wait(200)
    end

    registerUsables()

    print(('[snelle-popandbangs] geladen, inventory = %s, %s kentekens met pop & bangs'):format(
        GetInventoryType(),
        (function()
            local n = 0
            for _ in pairs(installed) do
                n = n + 1
            end
            return n
        end)()
    ))
end)

CreateThread(function()
    Wait(2000)
    if type(GetAllVehicles) ~= 'function' then
        return
    end

    for _, vehicle in ipairs(GetAllVehicles()) do
        if DoesEntityExist(vehicle) then
            local plate = plateOf(vehicle)
            local stage = plate and stageOfPlate(plate) or 0
            if stage > 0 then
                applyState(vehicle, stage)
            end
        end
    end
end)
