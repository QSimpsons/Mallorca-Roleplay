local ESX = nil
local active = {}
local activeByNet = {}
local lastUse = {}

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

local function jobAllowed(xPlayer)
    if not JobsRestricted() then
        return true
    end

    local job = xPlayer.job and xPlayer.job.name
    if not job then
        return false
    end

    for i = 1, #Config.AllowedJobs do
        if Config.AllowedJobs[i] == job then
            return true
        end
    end

    return false
end

local function clearSession(src, forceClient)
    local session = active[src]
    if not session then
        return
    end

    active[src] = nil
    if session.netId and session.netId ~= 0 and activeByNet[session.netId] == src then
        activeByNet[session.netId] = nil
    end

    if session.ent and session.ent ~= 0 and DoesEntityExist(session.ent) then
        local ok = pcall(function()
            Entity(session.ent).state:set('snelle_pushing', nil, true)
        end)
        if not ok then
            Debug('state clear mislukt voor', src)
        end
    end

    if forceClient then
        TriggerClientEvent('snelle-voertuigduwen:client:forceStop', src)
    end
end

local function pedBlocksPush(ped)
    if not ped or ped == 0 then
        return false
    end

    local isPlayer = false
    pcall(function()
        isPlayer = IsPedAPlayer(ped)
    end)

    if isPlayer then
        return true
    end

    return not Config.AllowNpcPassengers
end

local function vehicleBlocked(ent)
    local okClass, class = pcall(GetVehicleClass, ent)
    if okClass and Config.BlockedClasses[class] then
        return 'blocked'
    end

    local okModel, model = pcall(GetEntityModel, ent)
    if okModel and IsModelBlacklisted(model) then
        return 'blocked'
    end

    local okSpeed, speed = pcall(GetEntitySpeed, ent)
    if okSpeed and speed and speed > (Config.MaxVehicleSpeed + 0.8) then
        return 'moving'
    end

    for seat = -1, 15 do
        local okPed, ped = pcall(GetPedInVehicleSeat, ent, seat)
        if okPed and pedBlocksPush(ped) then
            return 'occupied'
        end
    end

    return nil
end

CreateThread(function()
    while not ESX do
        loadESX()
        Wait(100)
    end

    ESX.RegisterServerCallback('snelle-voertuigduwen:canStart', function(source, cb, netId, mode)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then
            cb(false, 'unknown')
            return
        end

        if active[src] then
            cb(false, 'busy')
            return
        end

        if not jobAllowed(xPlayer) then
            cb(false, 'job')
            return
        end

        if Config.RequireOnDuty and xPlayer.job and xPlayer.job.onDuty == false then
            cb(false, 'off_duty')
            return
        end

        mode = mode == 'aside' and 'aside' or 'manual'
        if mode == 'manual' and Config.Manual and Config.Manual.enabled == false then
            cb(false, 'blocked')
            return
        end

        local cooldown = (Config.Cooldown and Config.Cooldown[mode]) or 2
        local now = os.time()
        local stamp = lastUse[src]
        if stamp and stamp[mode] and (now - stamp[mode]) < cooldown then
            cb(false, 'cooldown')
            return
        end

        netId = tonumber(netId) or 0
        if netId ~= 0 and activeByNet[netId] and activeByNet[netId] ~= src then
            cb(false, 'in_use')
            return
        end

        local ent = 0
        if netId ~= 0 then
            ent = NetworkGetEntityFromNetworkId(netId)
            if not ent or ent == 0 or not DoesEntityExist(ent) then
                cb(false, 'no_vehicle')
                return
            end

            if GetEntityType(ent) ~= 2 then
                cb(false, 'no_vehicle')
                return
            end

            local ped = GetPlayerPed(src)
            if ped and ped ~= 0 then
                local dist = #(GetEntityCoords(ped) - GetEntityCoords(ent))
                if dist > (Config.InteractDistance + 2.5) then
                    cb(false, 'too_far')
                    return
                end
            end

            local blocked = vehicleBlocked(ent)
            if blocked then
                cb(false, blocked)
                return
            end

            local stateOwner = nil
            pcall(function()
                stateOwner = Entity(ent).state.snelle_pushing
            end)
            if stateOwner and stateOwner ~= src and activeByNet[netId] then
                cb(false, 'in_use')
                return
            end
        end

        lastUse[src] = lastUse[src] or {}
        lastUse[src][mode] = now
        active[src] = {
            netId = netId,
            ent = ent,
            mode = mode,
            started = now
        }
        if netId ~= 0 then
            activeByNet[netId] = src
            if ent ~= 0 then
                pcall(function()
                    Entity(ent).state:set('snelle_pushing', src, true)
                end)
            end
        end

        cb(true)
    end)
end)

RegisterNetEvent('snelle-voertuigduwen:server:finish', function(netId)
    local src = source
    local session = active[src]
    if not session then
        return
    end

    netId = tonumber(netId) or 0
    if session.netId ~= netId then
        return
    end

    clearSession(src, false)
end)

AddEventHandler('playerDropped', function()
    local src = source
    lastUse[src] = nil
    clearSession(src, false)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    for src in pairs(active) do
        clearSession(src, true)
    end
end)

CreateThread(function()
    while true do
        Wait(5000)
        local now = os.time()
        for src, session in pairs(active) do
            local limit = session.mode == 'manual' and 600 or 30
            if now - session.started > limit then
                Debug('sessie verlopen', src, session.mode)
                clearSession(src, true)
            end
        end
    end
end)
