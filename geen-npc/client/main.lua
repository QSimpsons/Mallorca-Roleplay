local scenarioTypes = {
    'WORLD_VEHICLE_ATTRACTOR',
    'WORLD_VEHICLE_AMBULANCE',
    'WORLD_VEHICLE_BICYCLE_BMX',
    'WORLD_VEHICLE_BICYCLE_BMX_BALLAS',
    'WORLD_VEHICLE_BICYCLE_BMX_FAMILY',
    'WORLD_VEHICLE_BICYCLE_BMX_HARMONY',
    'WORLD_VEHICLE_BICYCLE_BMX_VAGOS',
    'WORLD_VEHICLE_BICYCLE_MOUNTAIN',
    'WORLD_VEHICLE_BICYCLE_ROAD',
    'WORLD_VEHICLE_BIKE_OFF_ROAD_RACE',
    'WORLD_VEHICLE_BIKER',
    'WORLD_VEHICLE_BOAT_IDLE',
    'WORLD_VEHICLE_BOAT_IDLE_ALAMO',
    'WORLD_VEHICLE_BOAT_IDLE_MARQUIS',
    'WORLD_VEHICLE_BROKEN_DOWN',
    'WORLD_VEHICLE_BUSINESSMEN',
    'WORLD_VEHICLE_HELI_LIFEGUARD',
    'WORLD_VEHICLE_CLUCKIN_BELL_TRAILER',
    'WORLD_VEHICLE_CONSTRUCTION_SOLO',
    'WORLD_VEHICLE_CONSTRUCTION_PASSENGERS',
    'WORLD_VEHICLE_DRIVE_PASSENGERS',
    'WORLD_VEHICLE_DRIVE_PASSENGERS_LIMITED',
    'WORLD_VEHICLE_DRIVE_SOLO',
    'WORLD_VEHICLE_FIRE_TRUCK',
    'WORLD_VEHICLE_EMPTY',
    'WORLD_VEHICLE_MARIACHI',
    'WORLD_VEHICLE_MECHANIC',
    'WORLD_VEHICLE_MILITARY_PLANES_BIG',
    'WORLD_VEHICLE_MILITARY_PLANES_SMALL',
    'WORLD_VEHICLE_PARK_PARALLEL',
    'WORLD_VEHICLE_PARK_PERPENDICULAR_NOSE_IN',
    'WORLD_VEHICLE_PASSENGER_EXIT',
    'WORLD_VEHICLE_POLICE_BIKE',
    'WORLD_VEHICLE_POLICE_CAR',
    'WORLD_VEHICLE_POLICE',
    'WORLD_VEHICLE_POLICE_NEXT_TO_CAR',
    'WORLD_VEHICLE_QUARRY',
    'WORLD_VEHICLE_SALTON',
    'WORLD_VEHICLE_SALTON_DIRT_BIKE',
    'WORLD_VEHICLE_SECURITY_CAR',
    'WORLD_VEHICLE_STREETRACE',
    'WORLD_VEHICLE_TOURBUS',
    'WORLD_VEHICLE_TOURIST',
    'WORLD_VEHICLE_TANDL',
    'WORLD_VEHICLE_TRACTOR',
    'WORLD_VEHICLE_TRACTOR_BEACH',
    'WORLD_VEHICLE_TRUCK_LOGS',
    'WORLD_VEHICLE_TRUCKS_TRAILERS',
    'WORLD_VEHICLE_DISTANT_EMPTY_GROUND',
}

-- 1 t/m 5 zijn ambient spawns van de game. 6+ is permanent of mission (scripts, spelers).
local function isAmbientPopulation(entity)
    local popType = GetEntityPopulationType(entity)
    return popType > 0 and popType <= 5
end

local function vehicleHasPlayer(vehicle)
    local seats = GetVehicleMaxNumberOfPassengers(vehicle)
    for seat = -1, seats - 1 do
        local ped = GetPedInVehicleSeat(vehicle, seat)
        if ped ~= 0 and IsPedAPlayer(ped) then
            return true
        end
    end
    return false
end

local function deleteAmbient(entity)
    if not DoesEntityExist(entity) then
        return
    end
    SetEntityAsMissionEntity(entity, true, true)
    DeleteEntity(entity)
end

local function clearAmbient()
    if Config.DisablePeds then
        for _, ped in ipairs(GetGamePool('CPed')) do
            if not IsPedAPlayer(ped) and isAmbientPopulation(ped) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                if vehicle == 0 or not vehicleHasPlayer(vehicle) then
                    deleteAmbient(ped)
                end
            end
        end
    end

    if Config.DisableTraffic or Config.DisableParkedVehicles then
        for _, vehicle in ipairs(GetGamePool('CVehicle')) do
            if isAmbientPopulation(vehicle) and not vehicleHasPlayer(vehicle) then
                deleteAmbient(vehicle)
            end
        end
    end
end

CreateThread(function()
    while true do
        if Config.DisablePeds then
            SetPedDensityMultiplierThisFrame(0.0)
            SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0)
        end

        if Config.DisableTraffic then
            SetVehicleDensityMultiplierThisFrame(0.0)
            SetRandomVehicleDensityMultiplierThisFrame(0.0)
            SetAmbientVehicleRangeMultiplierThisFrame(0.0)
        end

        if Config.DisableParkedVehicles then
            SetParkedVehicleDensityMultiplierThisFrame(0.0)
        end

        if Config.DisableWantedLevel then
            local playerId = PlayerId()
            if GetPlayerWantedLevel(playerId) ~= 0 then
                SetPlayerWantedLevel(playerId, 0, false)
                SetPlayerWantedLevelNow(playerId, false)
            end
            SetMaxWantedLevel(0)
        end

        Wait(0)
    end
end)

CreateThread(function()
    while true do
        if Config.DisablePeds then
            SetPedPopulationBudget(0)
        end

        if Config.DisableTraffic or Config.DisableParkedVehicles then
            SetVehiclePopulationBudget(0)
        end

        if Config.DisableDispatch then
            for service = 1, 15 do
                EnableDispatchService(service, false)
            end

            SetCreateRandomCops(false)
            SetCreateRandomCopsNotOnScenarios(false)
            SetCreateRandomCopsOnScenarios(false)
            SetDispatchCopsForPlayer(PlayerId(), false)
            SetGarbageTrucks(false)
            SetRandomBoats(false)
            SetRandomTrains(false)
            DistantCopCarSirens(false)

            for i = 1, #scenarioTypes do
                SetScenarioTypeEnabled(scenarioTypes[i], false)
            end
        end

        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        if Config.ClearExisting then
            clearAmbient()
        end
        Wait(Config.ClearInterval)
    end
end)
