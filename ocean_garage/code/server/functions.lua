functions = {}

local storingPlates = {}

-- ESX 1.15.2 stores cars, boats and aircraft. This garage calls aircraft "airplane".
local typeAliases = {
    car = { 'car', 'automobile' },
    boat = { 'boat' },
    airplane = { 'airplane', 'aircraft', 'plane', 'heli', 'helicopter' },
}

function functions.normalizePlate(plate)
    if type(plate) ~= 'string' then
        return ''
    end

    plate = plate:gsub('%z', '')
    return (plate:gsub('^%s*(.-)%s*$', '%1')):upper()
end

function functions.compactPlate(plate)
    return functions.normalizePlate(plate):gsub('%s+', '')
end

function functions.vehicleTypes(vehicleType)
    local aliases = typeAliases[vehicleType]
    if aliases then
        return aliases
    end

    if type(vehicleType) == 'string' and vehicleType ~= '' then
        return { vehicleType }
    end

    return { 'car' }
end

function functions.ownerId(src)
    if ESX and ESX.GetPlayerFromId then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            local identifier = xPlayer.getIdentifier and xPlayer.getIdentifier() or xPlayer.identifier
            if type(identifier) == 'string' and identifier ~= '' then
                return identifier
            end
        end
    end

    if vx and vx.player and vx.player.getFromId then
        local ok, player = pcall(vx.player.getFromId, src)
        local frameworkPlayer = ok and player and player.fp
        local identifier = frameworkPlayer and (frameworkPlayer.getIdentifier and frameworkPlayer.getIdentifier() or frameworkPlayer.identifier)
        if type(identifier) == 'string' and identifier ~= '' then
            return identifier
        end
    end

    return nil
end

--- ESX 1.15.2 `pound` is a VARCHAR impound name. Older copies of this garage wrote 0/1 into it.
function functions.isImpounded(vehicle)
    if type(vehicle) ~= 'table' then
        return false
    end

    local pound = vehicle.pound
    if pound == nil or pound == false then
        return false
    end

    if pound == true or pound == 1 then
        return true
    end

    if type(pound) == 'number' then
        return pound ~= 0
    end

    if type(pound) ~= 'string' then
        return false
    end

    local value = pound:gsub('^%s*(.-)%s*$', '%1'):lower()
    if value == '' or value == '0' or value == 'false' or value == 'null' then
        return false
    end

    return true
end

function functions.isStored(vehicle)
    local stored = vehicle and vehicle.stored
    return stored == true or stored == 1 or stored == '1'
end

function functions.markStoring(plate)
    local key = functions.compactPlate(plate)
    if key ~= '' then
        storingPlates[key] = true
    end
end

function functions.clearStoring(plate)
    storingPlates[functions.compactPlate(plate)] = nil
end

function functions.isStoring(plate)
    return storingPlates[functions.compactPlate(plate)] == true
end

local function queryOwned(plate, owner)
    local normalized = functions.normalizePlate(plate)
    local compact = functions.compactPlate(plate)
    if normalized == '' then
        return nil
    end

    local params = { normalized, compact }
    local ownerClause = ''
    if type(owner) == 'string' and owner ~= '' then
        ownerClause = ' AND `owner` = ?'
        params[#params + 1] = owner
    end

    local ok, result = pcall(function()
        return MySQL.query.await(([[
            SELECT * FROM owned_vehicles
            WHERE (
                UPPER(TRIM(`plate`)) = ?
                OR REPLACE(UPPER(TRIM(`plate`)), ' ', '') = ?
            )%s
            LIMIT 1
        ]]):format(ownerClause), params)
    end)

    if not ok or type(result) ~= 'table' then
        print(('^1[ocean_garage]^7 Kenteken opzoeken mislukt (%s): %s'):format(normalized, tostring(result)))
        return nil
    end

    return result[1]
end

function functions.getVehicleByPlate(plate)
    return queryOwned(plate, nil)
end

function functions.findOwnedVehicle(src, plate)
    return queryOwned(plate, functions.ownerId(src))
end
