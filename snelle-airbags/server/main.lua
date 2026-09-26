local deployed = {}
local lastRequest = {}

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

RegisterNetEvent('snelle-airbags:request', function(netId)
    local src = source
    if type(netId) ~= 'number' then
        return
    end

    local now = os.time()
    if lastRequest[src] and now - lastRequest[src] < 2 then
        TriggerClientEvent('snelle-airbags:denied', src)
        return
    end
    lastRequest[src] = now

    local vehicle = vehicleOf(src, netId)
    local driver = GetPlayerPed(src)
    local okSeat, seatPed = pcall(GetPedInVehicleSeat, vehicle, -1)
    if vehicle == 0 or not okSeat or seatPed ~= driver then
        TriggerClientEvent('snelle-airbags:denied', src)
        return
    end

    local okClass, class = pcall(GetVehicleClass, vehicle)
    if okClass and Config.BlockedClasses[class] then
        TriggerClientEvent('snelle-airbags:denied', src)
        return
    end

    local state = deployed[netId]
    if state and now - state < Config.MinRedeploySeconds then
        TriggerClientEvent('snelle-airbags:denied', src)
        return
    end

    deployed[netId] = now
    TriggerClientEvent('snelle-airbags:accepted', src)
    TriggerClientEvent('snelle-airbags:deploy', -1, netId)
end)

RegisterNetEvent('snelle-airbags:checkRepair', function(netId)
    local src = source
    if type(netId) ~= 'number' or not deployed[netId] then
        return
    end

    if os.time() - deployed[netId] < Config.MinRedeploySeconds then
        return
    end

    if vehicleOf(src, netId) == 0 then
        return
    end

    deployed[netId] = nil
    TriggerClientEvent('snelle-airbags:repaired', -1, netId)
end)

AddEventHandler('playerDropped', function()
    lastRequest[source] = nil
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
    end
end)
