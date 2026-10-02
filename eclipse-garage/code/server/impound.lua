local existingVehiclesCache = {}
local VEHICLE_ENTITY_TYPE = 2

esrp_lib.callback.register("vx_garage:getExistingVehicles", function()
    return { ok = true, vehicles = existingVehiclesCache }
end)

esrp_lib.callback.register("vx_garage:returnFromImpound", function(playerId, plate)
    local vehicle = functions.findOwnedVehicle(playerId, plate)
    if not vehicle then
        return false
    end

    local player = esrp_lib.player.getFromId(playerId)
    if player then
        player:removeAccountMoney("bank", Config.impoundPrice)
    end

    MySQL.update.await("UPDATE owned_vehicles SET `pound` = 0 WHERE `plate` = ? AND `owner` = ?", {
        vehicle.plate,
        vehicle.owner
    })

    return true
end)

esrp_lib.callback.register("vx_garage:storedVehicle", function(playerId, plate)
    Citizen.Wait(2000)

    local vehicle = functions.findOwnedVehicle(playerId, plate)
    if not vehicle then
        return false
    end

    MySQL.update.await("UPDATE owned_vehicles SET `pound` = 0 WHERE `plate` = ? AND `owner` = ?", {
        vehicle.plate,
        vehicle.owner
    })

    return true
end)

RegisterNetEvent("entityCreated", function(entity)

    if GetEntityType(entity) ~= VEHICLE_ENTITY_TYPE then
        return
    end

    local plate = GetVehicleNumberPlateText(entity)
    local vehicle = functions.getVehicleByPlate(plate)
    if vehicle then
        table.insert(existingVehiclesCache, {
            plate = vehicle.plate,
            networkId = entity
        })
        -- esrp_lib.print.info("added vehicle to cache", plate)
    else
        -- esrp_lib.print.info("unable to find vehicle in database", plate)
    end
end)

RegisterNetEvent("entityRemoved", function(entity)

    if GetEntityType(entity) ~= VEHICLE_ENTITY_TYPE then
        return
    end

    local cached
    for i, cachedVehicle in pairs(existingVehiclesCache) do
        if cachedVehicle.networkId == entity then
            cached = cachedVehicle
            table.remove(existingVehiclesCache, i)
            break
        end
    end

    if not cached then
        return
    end

    MySQL.update("UPDATE owned_vehicles SET `pound` = 1 WHERE `plate` = ?", {
        cached.plate
    })
end)