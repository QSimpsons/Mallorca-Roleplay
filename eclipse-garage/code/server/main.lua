local function updateStoredStatus(plate, stored)
    local vehicle = functions.getVehicleByPlate(plate)
    if not vehicle then
        return
    end

    MySQL.update.await("UPDATE owned_vehicles SET `stored` = ? WHERE `plate` = ? AND `owner` = ?", {
        stored and 1 or 0,
        vehicle.plate,
        vehicle.owner
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
        print(('^1[eclipse-garage]^7 Voertuigen laden mislukt: %s'):format(tostring(vehicles)))
        return { ok = true, vehicles = {} }
    end
    for i = 1, #vehicles do
        if vehicles[i].favorite == nil then
            vehicles[i].favorite = 0
        end
    end
    return { ok = true, vehicles = vehicles }
end)

esrp_lib.callback.register("vx_garage:vehicleSpawned", function(source, netId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    local plate = GetVehicleNumberPlateText(entity)
    local ent = Entity(entity)
    ent.state:set("plate", plate)
    updateStoredStatus(plate, false)
end)

esrp_lib.callback.register("vx_garage:storeVehicle", function(source, garage, vehicleData, plate)
    local vehicle = functions.findOwnedVehicle(source, plate)
    if not vehicle and type(vehicleData) == 'table' then
        vehicle = functions.findOwnedVehicle(source, vehicleData.plate)
    end

    if not vehicle or type(vehicleData) ~= 'table' then
        print(('^3[eclipse-garage]^7 Opslaan geweigerd voor %s, plaat "%s"'):format(
            tostring(functions.ownerId(source)),
            functions.normalizePlate(plate)
        ))
        return false
    end

    vehicleData.plate = vehicle.plate

    MySQL.update.await([[
        UPDATE owned_vehicles
        SET `vehicle` = ?,
            `pound` = 0
        WHERE `plate` = ? AND `owner` = ?
    ]], {
        json.encode(vehicleData),
        vehicle.plate,
        vehicle.owner
    })

    return true
end)

esrp_lib.callback.register("vx_garage:setVehicleName", function(source, plate, name)
    local vehicle = functions.findOwnedVehicle(source, plate)
    if not vehicle then
        return false
    end

    MySQL.update.await("UPDATE owned_vehicles SET `name` = ? WHERE `plate` = ? AND `owner` = ?", {
        name,
        vehicle.plate,
        vehicle.owner
    })

    return true
end)

esrp_lib.callback.register("vx_garage:setFavorite", function(source, plate, favorite)
    local vehicle = functions.findOwnedVehicle(source, plate)
    if not vehicle then
        return false
    end

    MySQL.update.await("UPDATE owned_vehicles SET `favorite` = ? WHERE `plate` = ? AND `owner` = ?", {
        favorite,
        vehicle.plate,
        vehicle.owner
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
