functions = {}

function functions.ownerId(src)
    if ESX and ESX.GetPlayerFromId then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer and xPlayer.identifier and xPlayer.identifier ~= '' then
            return xPlayer.identifier
        end
    end
    -- vx.player.getIdentifier returns a license id. owned_vehicles.owner is the ESX character id.
    if vx and vx.player and vx.player.getFromId then
        local ok, player = pcall(vx.player.getFromId, src)
        local frameworkPlayer = ok and player and player.fp
        if frameworkPlayer and frameworkPlayer.identifier and frameworkPlayer.identifier ~= '' then
            return frameworkPlayer.identifier
        end
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
