functions = {}

function functions.ownerId(src)
    if ESX and ESX.GetPlayerFromId then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.identifier and xPlayer.identifier ~= '' then
            return xPlayer.identifier
        end
    end
    if esrp_lib and esrp_lib.player and esrp_lib.player.getIdentifier then
        return esrp_lib.player.getIdentifier(src, true)
    end
    return nil
end

function functions.getVehicleByPlate(plate)
    local ok, result = pcall(function()
        return MySQL.query.await("SELECT * FROM owned_vehicles WHERE `plate` = ? LIMIT 1", { plate })
    end)
    if not ok or type(result) ~= 'table' then
        return nil
    end
    return result[1]
end
