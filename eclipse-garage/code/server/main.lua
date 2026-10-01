local function updateStoredStatus(plate, stored)
    MySQL.update("UPDATE owned_vehicles SET `stored` = @stored WHERE `plate` = @plate", {
        ["@stored"] = stored,
        ["@plate"] = plate
    })
end

esrp_lib.callback.register("vx_garage:getOwnedVehicles", function(source, vehicleType)
    local identifier = functions.ownerId(source)
    if not identifier then
        return {}
    end
    local ok, vehicles = pcall(function()
        return MySQL.query.await([[
            SELECT * FROM owned_vehicles
            WHERE `owner` = ? AND `type` = ?
        ]], { identifier, vehicleType or 'car' })
    end)
    if not ok or type(vehicles) ~= 'table' then
        return {}
    end
    for i = 1, #vehicles do
        if vehicles[i].favorite == nil then
            vehicles[i].favorite = 0
        end
    end
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
    local identifier = functions.ownerId(source)
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
    local identifier = functions.ownerId(source)
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
    local identifier = functions.ownerId(source)
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
    local function ensureColumn(name, ddl)
        local exists = pcall(function()
            MySQL.query.await(('SELECT `%s` FROM owned_vehicles LIMIT 1'):format(name))
        end)
        if not exists then
            pcall(function()
                MySQL.query.await(ddl)
            end)
        end
    end

    ensureColumn('favorite', 'ALTER TABLE owned_vehicles ADD COLUMN `favorite` TINYINT(1) NOT NULL DEFAULT 0')
    ensureColumn('name', 'ALTER TABLE owned_vehicles ADD COLUMN `name` VARCHAR(64) DEFAULT NULL')
    ensureColumn('pound', 'ALTER TABLE owned_vehicles ADD COLUMN `pound` TINYINT(1) NOT NULL DEFAULT 0')
    pcall(function()
        MySQL.update.await("UPDATE owned_vehicles SET `stored` = true WHERE `stored` = false")
    end)
end)
