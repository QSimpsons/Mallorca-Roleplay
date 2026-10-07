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

    local deployedVehicle = NetworkGetEntityFromNetworkId(netId)
    if deployedVehicle ~= 0 and DoesEntityExist(deployedVehicle) then
        pcall(function()
            Entity(deployedVehicle).state:set('snelleAirbags', true, true)
        end)
    end

    TriggerClientEvent('snelle-airbags:accepted', src)
    TriggerClientEvent('snelle-airbags:deploy', -1, netId)
end)

RegisterNetEvent('snelle-airbags:checkRepair', function(netId)
    local src = source
    if type(netId) ~= 'number' or not deployed[netId] then
        return
    end

    local ped = GetPlayerPed(src)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if ped == 0 or vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    local okDistance, distance = pcall(function()
        return #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
    end)
    if not okDistance or not distance or distance > 40.0 then
        return
    end

    deployed[netId] = nil
    pcall(function()
        Entity(vehicle).state:set('snelleAirbags', false, true)
    end)
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
