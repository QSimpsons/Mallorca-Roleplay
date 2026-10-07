local deployed = {}
local lastRequest = {}
local lastScrapeByPlayer = {}
local lastScrapeByVehicle = {}

local function vehicleOf(src, netId)
    local ped = GetPlayerPed(src)
    if ped == 0 then
        return 0
    end

    local okVeh, vehicle = pcall(GetVehiclePedIsIn, ped, false)
    if not okVeh or not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0
    end

    local okNet, current = pcall(NetworkGetNetworkIdFromEntity, vehicle)
    if not okNet or current ~= netId then
        return 0
    end

    return vehicle
end

local function copyImpacts(state)
    local impacts = {}
    if type(state) ~= 'table' or type(state.impacts) ~= 'table' then
        return impacts
    end

    for i = 1, math.min(#state.impacts, Config.MaxImpacts) do
        local item = state.impacts[i]
        local clean = Impact.sanitize(item)
        if clean then
            impacts[#impacts + 1] = {
                side = clean.side,
                along = clean.along,
                spread = clean.spread,
                severity = clean.severity,
                adjustHealth = type(item) == 'table' and item.adjustHealth and true or false
            }
        end
    end

    return impacts
end

local function networkId(vehicle, fallback)
    if type(fallback) == 'number' and fallback > 0 then
        return fallback
    end
    local ok, netId = pcall(NetworkGetNetworkIdFromEntity, vehicle)
    if ok and type(netId) == 'number' and netId > 0 then
        return netId
    end
    return nil
end

local function rememberImpact(vehicle, netId, impact, adjustHealth, fallbackSrc)
    if not Config.SideDamage or vehicle == 0 or not DoesEntityExist(vehicle) then
        return false
    end

    local sanitized = Impact.sanitize(impact)
    if not sanitized then
        return false
    end

    local current = {}
    pcall(function()
        current = Entity(vehicle).state.eclipseImpact
    end)
    local impacts = copyImpacts(current)
    if #impacts >= Config.MaxImpacts then
        return false
    end

    local resolvedEarly = networkId(vehicle, netId)
    local stamped = resolvedEarly or vehicle
    local seenAt = lastScrapeByVehicle[stamped]
    if seenAt and GetGameTimer() - seenAt < Config.ScrapeCooldownMs then
        return false
    end

    impacts[#impacts + 1] = {
        side = sanitized.side,
        along = sanitized.along,
        spread = sanitized.spread,
        severity = sanitized.severity,
        adjustHealth = adjustHealth and true or false
    }

    local saved = pcall(function()
        Entity(vehicle).state:set('eclipseImpact', { impacts = impacts }, true)
    end)
    if not saved then
        return false
    end
    lastScrapeByVehicle[stamped] = GetGameTimer()
    if not adjustHealth then
        return true
    end

    local resolved = networkId(vehicle, netId)
    if not resolved then
        return true
    end

    local owner = fallbackSrc
    local okOwner, ownerId = pcall(NetworkGetEntityOwner, vehicle)
    if okOwner and type(ownerId) == 'number' and ownerId > 0 then
        owner = ownerId
    end
    if type(owner) == 'number' and owner > 0 then
        TriggerClientEvent('Eclipse-airbags:healthGo', owner, resolved, sanitized.severity, sanitized.side)
    end

    return true
end

local function clearImpact(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end
    pcall(function()
        Entity(vehicle).state:set('eclipseImpact', { impacts = {} }, true)
    end)
    local resolved = networkId(vehicle, nil)
    if resolved then
        lastScrapeByVehicle[resolved] = nil
    end
end

local function struckVehicle(srcVehicle, netId)
    if type(netId) ~= 'number' or netId <= 0 then
        return 0
    end

    local other = NetworkGetEntityFromNetworkId(netId)
    if other == 0 or not DoesEntityExist(other) or other == srcVehicle then
        return 0
    end

    local okClass, class = pcall(GetVehicleClass, other)
    if okClass and class == 21 then
        return 0
    end

    local okDistance, distance = pcall(function()
        return #(GetEntityCoords(srcVehicle) - GetEntityCoords(other))
    end)
    if not okDistance or not distance or distance > Config.StrikeDistance then
        return 0
    end

    return other
end

local function driverVehicle(src, netId)
    local vehicle = vehicleOf(src, netId)
    if vehicle == 0 then
        return 0
    end

    local driver = GetPlayerPed(src)
    local okSeat, seatPed = pcall(GetPedInVehicleSeat, vehicle, -1)
    if not okSeat or seatPed ~= driver then
        return 0
    end

    local okClass, class = pcall(GetVehicleClass, vehicle)
    if okClass and Config.BlockedClasses[class] then
        return 0
    end

    return vehicle
end

RegisterNetEvent('Eclipse-airbags:request', function(netId, impact, otherNetId, otherImpact)
    local src = source
    if type(netId) ~= 'number' then
        return
    end

    local now = os.time()
    if lastRequest[src] and now - lastRequest[src] < 2 then
        TriggerClientEvent('Eclipse-airbags:denied', src)
        return
    end
    lastRequest[src] = now

    local vehicle = driverVehicle(src, netId)
    if vehicle == 0 then
        TriggerClientEvent('Eclipse-airbags:denied', src)
        return
    end

    local state = deployed[netId]
    if state and now - state < Config.MinRedeploySeconds then
        TriggerClientEvent('Eclipse-airbags:denied', src)
        return
    end

    deployed[netId] = now

    pcall(function()
        Entity(vehicle).state:set('eclipseAirbags', true, true)
    end)

    rememberImpact(vehicle, netId, impact, false, src)
    local other = struckVehicle(vehicle, otherNetId)
    if other ~= 0 then
        rememberImpact(other, otherNetId, otherImpact, true, src)
    end

    TriggerClientEvent('Eclipse-airbags:accepted', src)
    TriggerClientEvent('Eclipse-airbags:deploy', -1, netId)
end)

RegisterNetEvent('Eclipse-airbags:scrape', function(netId, impact, otherNetId, otherImpact)
    local src = source
    if not Config.SideDamage or type(netId) ~= 'number' then
        return
    end

    local now = GetGameTimer()
    if lastScrapeByPlayer[src] and now - lastScrapeByPlayer[src] < Config.ScrapeCooldownMs then
        return
    end

    local vehicle = driverVehicle(src, netId)
    if vehicle == 0 then
        return
    end

    lastScrapeByPlayer[src] = now
    rememberImpact(vehicle, netId, impact, true, src)

    local other = struckVehicle(vehicle, otherNetId)
    if other ~= 0 then
        rememberImpact(other, otherNetId, otherImpact, true, src)
    end
end)

local function playerNear(src, vehicle)
    local ped = GetPlayerPed(src)
    if ped == 0 or vehicle == 0 or not DoesEntityExist(vehicle) then
        return false
    end

    local okDistance, distance = pcall(function()
        return #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
    end)
    return okDistance and distance and distance <= 40.0
end

RegisterNetEvent('Eclipse-airbags:checkRepair', function(netId)
    local src = source
    if type(netId) ~= 'number' or not deployed[netId] then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not playerNear(src, vehicle) then
        return
    end

    deployed[netId] = nil
    pcall(function()
        Entity(vehicle).state:set('eclipseAirbags', false, true)
    end)
    clearImpact(vehicle)
    TriggerClientEvent('Eclipse-airbags:repaired', -1, netId)
end)

RegisterNetEvent('Eclipse-airbags:clearImpact', function(netId)
    local src = source
    if type(netId) ~= 'number' then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if not playerNear(src, vehicle) then
        return
    end

    clearImpact(vehicle)
end)

AddEventHandler('playerDropped', function()
    lastRequest[source] = nil
    lastScrapeByPlayer[source] = nil
end)

CreateThread(function()
    while true do
        Wait(60000)
        for netId in pairs(deployed) do
            local vehicle = NetworkGetEntityFromNetworkId(netId)
            if vehicle == 0 or not DoesEntityExist(vehicle) then
                deployed[netId] = nil
            end
        end
        for netId in pairs(lastScrapeByVehicle) do
            local vehicle = NetworkGetEntityFromNetworkId(netId)
            if vehicle == 0 or not DoesEntityExist(vehicle) then
                lastScrapeByVehicle[netId] = nil
            end
        end
    end
end)
