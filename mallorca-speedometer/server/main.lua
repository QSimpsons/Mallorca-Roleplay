--[[
    Mallorca Speedometer - server
    Alleen brandstof laden/opslaan in owned_vehicles.fuel
]]

local function normalizePlate(plate)
    if type(plate) ~= 'string' then
        return ''
    end
    return (plate:gsub('^%s+', ''):gsub('%s+$', ''):upper())
end

local function clampFuel(value)
    local n = tonumber(value) or 100.0
    if n < 0.0 then return 0.0 end
    if n > 100.0 then return 100.0 end
    return n
end

local function readFuelFromDb(plate, cb)
    if GetResourceState('oxmysql') == 'started' then
        exports.oxmysql:scalar(
            'SELECT fuel FROM owned_vehicles WHERE UPPER(TRIM(plate)) = ? LIMIT 1',
            { plate },
            cb
        )
        return true
    end
    return false
end

local function writeFuelToDb(plate, fuel)
    if GetResourceState('oxmysql') == 'started' then
        exports.oxmysql:execute(
            'UPDATE owned_vehicles SET fuel = ? WHERE UPPER(TRIM(plate)) = ?',
            { fuel, plate }
        )
        return true
    end
    return false
end

RegisterNetEvent('mallorca-speedometer:server:getFuel', function(plate)
    local src = source
    plate = normalizePlate(plate)

    if not Config.Fuel or not Config.Fuel.UseDatabase or plate == '' then
        TriggerClientEvent('mallorca-speedometer:client:setFuel', src, plate, 100.0)
        return
    end

    local ok = readFuelFromDb(plate, function(result)
        local fuel = 100.0
        if result ~= nil then
            fuel = clampFuel(result)
        end
        TriggerClientEvent('mallorca-speedometer:client:setFuel', src, plate, fuel)
    end)

    if not ok then
        TriggerClientEvent('mallorca-speedometer:client:setFuel', src, plate, 100.0)
    end
end)

RegisterNetEvent('mallorca-speedometer:server:saveFuel', function(plate, fuel)
    if not Config.Fuel or not Config.Fuel.UseDatabase then
        return
    end

    plate = normalizePlate(plate)
    fuel = clampFuel(fuel)
    if plate == '' then
        return
    end

    writeFuelToDb(plate, fuel)
end)
