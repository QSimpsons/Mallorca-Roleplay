functions = {}

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

function functions.ownerIds(src)
    local ids = {}
    local seen = {}

    local function add(id)
        if type(id) ~= 'string' or id == '' or seen[id] then
            return
        end

        seen[id] = true
        ids[#ids + 1] = id

        local rest = id:match('^%w+:(.+)$')
        if rest and #rest >= 15 then
            add(rest)
        end
    end

    if ESX and ESX.GetPlayerFromId then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            add(xPlayer.identifier)
            if xPlayer.getIdentifier then
                local ok, identifier = pcall(function()
                    return xPlayer.getIdentifier()
                end)
                if ok then
                    add(identifier)
                end
            end
        end
    end

    if esrp_lib and esrp_lib.player and esrp_lib.player.getIdentifier then
        add(esrp_lib.player.getIdentifier(src, true))
    end

    if GetNumPlayerIdentifiers and GetPlayerIdentifier then
        local count = GetNumPlayerIdentifiers(src) or 0
        for i = 0, count - 1 do
            add(GetPlayerIdentifier(src, i))
        end
    end

    return ids
end

function functions.ownerId(src)
    local ids = functions.ownerIds(src)
    return ids[1]
end

local function queryOwned(plate, owners)
    local normalized = functions.normalizePlate(plate)
    local compact = normalized:gsub('%s+', '')
    if normalized == '' then
        return nil, 'leeg kenteken'
    end

    local params = { normalized, compact }
    local ownerClause = ''

    if owners then
        if #owners == 0 then
            return nil, 'geen identifier'
        end

        local placeholders = {}
        for i = 1, #owners do
            placeholders[i] = '?'
            params[#params + 1] = owners[i]
        end
        ownerClause = (' AND TRIM(`owner`) IN (%s)'):format(table.concat(placeholders, ','))
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
        return nil, result
    end

    return result[1]
end

function functions.getVehicleByPlate(plate)
    local vehicle, err = queryOwned(plate, nil)
    if err and not vehicle and err ~= 'leeg kenteken' then
        print(('^1[eclipse-garage]^7 Kenteken opzoeken mislukt (%s): %s'):format(functions.normalizePlate(plate), tostring(err)))
    end
    return vehicle
end

function functions.findOwnedVehicle(src, plate)
    local vehicle, err = queryOwned(plate, functions.ownerIds(src))
    if err and not vehicle and err ~= 'leeg kenteken' and err ~= 'geen identifier' then
        print(('^1[eclipse-garage]^7 Kenteken opzoeken mislukt (%s): %s'):format(functions.normalizePlate(plate), tostring(err)))
    end
    return vehicle
end
