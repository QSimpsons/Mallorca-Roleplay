local existingVehiclesCache = {}
local VEHICLE_ENTITY_TYPE = 2

local function removeFromCache(entity)
    for i = #existingVehiclesCache, 1, -1 do
        if existingVehiclesCache[i].networkId == entity then
            table.remove(existingVehiclesCache, i)
        end
    end
end

vx.callback.register("vx_garage:getExistingVehicles", function()
    return { ok = true, vehicles = existingVehiclesCache }
end)

vx.callback.register("vx_garage:returnFromImpound", function(playerId, plate)
    local vehicle = functions.findOwnedVehicle(playerId, plate)
    if not vehicle or not functions.isImpounded(vehicle) then
        return false
    end

    local price = tonumber(Config.impoundPrice) or 0
    if price > 0 then
        local xPlayer = ESX and ESX.GetPlayerFromId(playerId)
        if not xPlayer or not xPlayer.getAccount or not xPlayer.removeAccountMoney then
            return false
        end

        local account = xPlayer.getAccount('bank')
        if not account or (account.money or 0) < price then
            return false
        end

        xPlayer.removeAccountMoney('bank', price, 'Impound')
    end

    MySQL.update.await([[
        UPDATE owned_vehicles
        SET `pound` = NULL, `stored` = 1, `parking` = NULL
        WHERE `plate` = ? AND `owner` = ?
    ]], {
        vehicle.plate,
        vehicle.owner
    })

    return true
end)

vx.callback.register("vx_garage:storedVehicle", function(playerId, plate)
    local vehicle = functions.findOwnedVehicle(playerId, plate)
    if not vehicle or not functions.isStoring(vehicle.plate) then
        return false
    end

    functions.clearStoring(vehicle.plate)
    return true
end)

RegisterNetEvent("entityCreated", function(entity)
    if GetEntityType(entity) ~= VEHICLE_ENTITY_TYPE then
        return
    end

    local plate = GetVehicleNumberPlateText(entity)
    if not plate then
        return
    end

    local vehicle = functions.getVehicleByPlate(plate)
    if not vehicle then
        return
    end

    existingVehiclesCache[#existingVehiclesCache + 1] = {
        plate = vehicle.plate,
        owner = vehicle.owner,
        networkId = entity
    }
end)

RegisterNetEvent("entityRemoved", function(entity)
    if GetEntityType(entity) ~= VEHICLE_ENTITY_TYPE then
        return
    end

    local cached
    for i = 1, #existingVehiclesCache do
        if existingVehiclesCache[i].networkId == entity then
            cached = existingVehiclesCache[i]
            break
        end
    end

    if not cached then
        return
    end

    removeFromCache(entity)

    if functions.isStoring(cached.plate) or not cached.owner then
        return
    end

    -- ESX 1.15.2: a removed world vehicle goes to the impound lot, stored and not parked.
    MySQL.update.await([[
        UPDATE owned_vehicles
        SET `stored` = 1, `parking` = NULL, `pound` = 'Impound'
        WHERE `plate` = ? AND `owner` = ?
          AND (`pound` IS NULL OR `pound` IN ('', '0', 'false', 'FALSE'))
    ]], {
        cached.plate,
        cached.owner
    })
end)
