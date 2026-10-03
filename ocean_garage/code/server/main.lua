local function parkingName(garage)
    if type(garage) == 'table' and type(garage.name) == 'string' and garage.name ~= '' then
        return garage.name
    end

    return 'Garage'
end

vx.callback.register("vx_garage:getOwnedVehicles", function(source, vehicleType)
    local identifier = functions.ownerId(source)
    if not identifier then
        return { ok = true, vehicles = {} }
    end

    local types = functions.vehicleTypes(vehicleType)
    local placeholders = {}
    local params = { identifier }
    for i = 1, #types do
        placeholders[i] = '?'
        params[#params + 1] = types[i]
    end

    local ok, vehicles = pcall(function()
        return MySQL.query.await(([[
            SELECT * FROM owned_vehicles
            WHERE `owner` = ? AND `type` IN (%s)
        ]]):format(table.concat(placeholders, ',')), params)
    end)

    if not ok or type(vehicles) ~= 'table' then
        print(('^1[ocean_garage]^7 Voertuigen laden mislukt: %s'):format(tostring(vehicles)))
        return { ok = true, vehicles = {} }
    end

    for i = 1, #vehicles do
        if vehicles[i].favorite == nil then
            vehicles[i].favorite = 0
        end

        -- The UI still reads pound as 1/0. ESX 1.15.2 stores an impound name in that column.
        vehicles[i].pound = functions.isImpounded(vehicles[i]) and 1 or 0
        vehicles[i].stored = functions.isStored(vehicles[i]) and 1 or 0
    end

    return { ok = true, vehicles = vehicles }
end)

vx.callback.register("vx_garage:vehicleSpawned", function(source, netId, plate)
    local vehicle = functions.findOwnedVehicle(source, plate)
    local entity = NetworkGetEntityFromNetworkId(netId)

    if not vehicle or functions.isImpounded(vehicle) or not functions.isStored(vehicle) then
        if entity and entity ~= 0 then
            DeleteEntity(entity)
        end
        return false
    end

    if (not entity or entity == 0) and type(netId) == 'number' then
        for _ = 1, 20 do
            Wait(50)
            entity = NetworkGetEntityFromNetworkId(netId)
            if entity and entity ~= 0 then
                break
            end
        end
    end

    if entity and entity ~= 0 then
        local ent = Entity(entity)
        ent.state:set("plate", vehicle.plate, false)
        ent.state:set("owner", vehicle.owner, false)
    end

    MySQL.update.await([[
        UPDATE owned_vehicles
        SET `stored` = 0, `parking` = NULL
        WHERE `plate` = ? AND `owner` = ?
    ]], { vehicle.plate, vehicle.owner })

    return true
end)

vx.callback.register("vx_garage:storeVehicle", function(source, garage, vehicleData, plate)
    local vehicle = functions.findOwnedVehicle(source, plate)
    if not vehicle and type(vehicleData) == 'table' then
        vehicle = functions.findOwnedVehicle(source, vehicleData.plate)
    end

    if not vehicle or type(vehicleData) ~= 'table' or functions.isImpounded(vehicle) then
        print(('^3[ocean_garage]^7 Opslaan geweigerd voor %s, plaat "%s"'):format(
            tostring(functions.ownerId(source)),
            functions.normalizePlate(plate)
        ))
        return false
    end

    vehicleData.plate = vehicle.plate
    functions.markStoring(vehicle.plate)

    MySQL.update.await([[
        UPDATE owned_vehicles
        SET `vehicle` = ?,
            `stored` = 1,
            `pound` = NULL,
            `parking` = ?
        WHERE `plate` = ? AND `owner` = ?
    ]], {
        json.encode(vehicleData),
        parkingName(garage),
        vehicle.plate,
        vehicle.owner
    })

    local storedPlate = vehicle.plate
    SetTimeout(5000, function()
        functions.clearStoring(storedPlate)
    end)

    return true
end)

vx.callback.register("vx_garage:setVehicleName", function(source, plate, name)
    local vehicle = functions.findOwnedVehicle(source, plate)
    if not vehicle then
        return false
    end

    if type(name) ~= 'string' then
        return false
    end

    name = name:sub(1, 64)

    MySQL.update.await("UPDATE owned_vehicles SET `name` = ? WHERE `plate` = ? AND `owner` = ?", {
        name,
        vehicle.plate,
        vehicle.owner
    })

    return true
end)

vx.callback.register("vx_garage:setFavorite", function(source, plate, favorite)
    local vehicle = functions.findOwnedVehicle(source, plate)
    if not vehicle then
        return false
    end

    local flag = (favorite == true or favorite == 1 or favorite == '1') and 1 or 0

    MySQL.update.await("UPDATE owned_vehicles SET `favorite` = ? WHERE `plate` = ? AND `owner` = ?", {
        flag,
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

    pcall(function()
        -- Old garage builds stored a boolean in ESX's VARCHAR pound column.
        MySQL.update.await([[
            UPDATE owned_vehicles
            SET `pound` = NULL
            WHERE `pound` IN ('0', 'false', 'FALSE')
        ]])
        MySQL.update.await([[
            UPDATE owned_vehicles
            SET `pound` = 'Impound', `stored` = 1, `parking` = NULL
            WHERE `pound` IN ('1', 'true', 'TRUE')
        ]])
        MySQL.update.await("UPDATE owned_vehicles SET `stored` = 1 WHERE `stored` = 0")
    end)
end)
