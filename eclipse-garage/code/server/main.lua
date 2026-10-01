local function updateStoredStatus(plate, stored)
    MySQL.update("UPDATE owned_vehicles SET `stored` = @stored WHERE `plate` = @plate", {
        ["@stored"] = stored,
        ["@plate"] = plate
    })
end

esrp_lib.callback.register("vx_garage:getOwnedVehicles", function(source, vehicleType)
    local identifier = esrp_lib.player.getIdentifier(source)
    local vehicles = MySQL.query.await([[
        SELECT *,
               IFNULL(`favorite`, 0) as favorite
        FROM owned_vehicles
        WHERE `owner` = @owner AND `type` = @type
    ]], {
        ["@owner"] = identifier,
        ["@type"] = vehicleType
    })
    if not vehicles then vehicles = {} end
    return vehicles
end)

esrp_lib.callback.register("vx_garage:vehicleSpawned", function(source, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    local plate = GetVehicleNumberPlateText(entity)
    local ent = Entity(entity)
    ent.state:set("plate", plate)
    updateStoredStatus(plate, false)
end)

esrp_lib.callback.register("vx_garage:storeVehicle", function(source, garage, vehicleData, plate)
    local identifier = esrp_lib.player.getIdentifier(source)
    local cleanedPlate = plate:gsub("^%s+", "")

    local vehicles = MySQL.query.await("SELECT * FROM owned_vehicles WHERE `owner` = @owner AND `plate` = @plate", {
        ["@owner"] = identifier,
        ["@plate"] = cleanedPlate
    })

    if not vehicles then
        return false
    end

    local vehicle = vehicles[1]
    if not vehicle then
        return false
    end

    MySQL.update([[ 
        UPDATE owned_vehicles
        SET `vehicle` = @vehicle,
            `pound` = false
        WHERE `plate` = @plate
    ]], {
        ["@vehicle"] = json.encode(vehicleData),
        ["@plate"] = plate
    })

    return true
end)

esrp_lib.callback.register("vx_garage:setVehicleName", function(source, plate, name)
    local identifier = esrp_lib.player.getIdentifier(source)
    local vehicles = MySQL.query.await("SELECT * FROM owned_vehicles WHERE `owner` = @owner AND `plate` = @plate", {
        ["@owner"] = identifier,
        ["@plate"] = plate
    })

    if not vehicles then return false end
    local vehicle = vehicles[1]
    if not vehicle then return false end

    MySQL.update("UPDATE owned_vehicles SET `name` = @name WHERE `plate` = @plate", {
        ["@name"] = name,
        ["@plate"] = plate
    })

    return true
end)

esrp_lib.callback.register("vx_garage:setFavorite", function(source, plate, favorite)
    local identifier = esrp_lib.player.getIdentifier(source)
    local vehicles = MySQL.query.await("SELECT * FROM owned_vehicles WHERE `owner` = @owner AND `plate` = @plate", {
        ["@owner"] = identifier,
        ["@plate"] = plate
    })

    if not vehicles or not vehicles[1] then
        return false
    end

    MySQL.update("UPDATE owned_vehicles SET `favorite` = @favorite WHERE `plate` = @plate", {
        ["@favorite"] = favorite,
        ["@plate"] = plate
    })

    return true
end)

MySQL.ready(function()
    MySQL.update.await("UPDATE owned_vehicles SET `stored` = true WHERE `stored` = false")
end)
