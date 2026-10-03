local existingVehiclesCache = {}
local VEHICLE_ENTITY_TYPE = 2

vx.callback.register("vx_garage:getExistingVehicles", function()
    return { ok = true, vehicles = existingVehiclesCache }
end)

vx.callback.register("vx_garage:returnFromImpound", function(playerId, plate)
    local identifier = functions.ownerId(playerId)
    local vehicle = functions.getVehicleByPlate(plate)

    if not identifier or not vehicle or vehicle.owner ~= identifier then
        return false
    end

    local player = vx.player.getFromId(playerId)
    if player then
        player:removeAccountMoney("bank", Config.impoundPrice)
    end

    MySQL.update("UPDATE owned_vehicles SET `pound` = false WHERE `plate` = @plate", {
        ["@plate"] = plate
    })

    return true
end)

vx.callback.register("vx_garage:storedVehicle", function(playerId, plate)
    Citizen.Wait(2000)

    local identifier = functions.ownerId(playerId)
    local vehicle = functions.getVehicleByPlate(plate)

    if not identifier or not vehicle or vehicle.owner ~= identifier then
        return false
    end

    MySQL.update("UPDATE owned_vehicles SET `pound` = false WHERE `plate` = @plate", {
        ["@plate"] = plate
    })

    return true
end)

RegisterNetEvent("entityCreated", function(entity)

    if GetEntityType(entity) ~= VEHICLE_ENTITY_TYPE then
        return
    end

    local plate = GetVehicleNumberPlateText(entity)
    plate = plate:gsub("%s+", "")

    local vehicle = functions.getVehicleByPlate(plate)
    if vehicle then
        table.insert(existingVehiclesCache, {
            plate = plate,
            networkId = entity
        })
        -- vx.print.info("added vehicle to cache", plate)
    else
        -- vx.print.info("unable to find vehicle in database", plate)
    end
end)

RegisterNetEvent("entityRemoved", function(entity)

    if GetEntityType(entity) ~= VEHICLE_ENTITY_TYPE then
        return
    end

    local plate = GetVehicleNumberPlateText(entity)
    if not plate then return end

    local foundInCache = false
    for i, cachedVehicle in pairs(existingVehiclesCache) do
        if cachedVehicle.networkId == entity then
            foundInCache = true
            break
        end
    end

    if not foundInCache then
        return
    end

    MySQL.update("UPDATE owned_vehicles SET `pound` = true WHERE `plate` = @plate", {
        ["@plate"] = plate
    })

    for i, cachedVehicle in pairs(existingVehiclesCache) do
        if cachedVehicle.networkId == entity then
            table.remove(existingVehiclesCache, i)
            break
        end
    end
end)