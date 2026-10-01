vx.addCommand({
        "staffassist",
        "sa"
    }, {
        help = "Staff menu voor beheer",
        name = "Staff assist",
        restricted = Config.group,
    },
    function(source, args, raw)
        if not GroupCheck(source) then
            return
        end

        TriggerClientEvent("vx_staffassist:openmenu", source,
            vx.player.getFromId(source):getGroup())
    end)

vx.addCommand("viewinv", {
    help = "View player inventory",
    params = {
        { name = "playerId", type = "playerId", help = "Player his Id" },
    },
    restricted = Config.group,
}, function(source, args, raw)
    if not GroupCheck(source) then
        return
    end

    local inventory = exports.ox_inventory:forceOpenInventory(source, "player", args.playerId)

    if not inventory then
        vx.notify(source, {
            title = "User does not exist",
            message = "User is invalid, or has not spawned yet.",
            type = "error"
        })
        return
    end

    vx.notify(source, {
        title = "Opening player inventory",
        message = "Looking into " .. GetPlayerName(args.playerId),
        type = "success"
    })
end)


function serverCallbackProxy.doesComserveResourceExist()
    return GetResourceState("vx_comserve") ~= "started"
end

---@return boolean
function GroupCheck(source)
    return (vx.player.getFromId(source):getGroup() == Config.group)
end

---@return SrpPlayer | nil
function serverCallbackProxy.getPlayerFromInput(input, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    if input then
        local isNumber = tonumber(input[1])
        local player

        if isNumber == nil then
            local user = MySQL.query.await("SELECT identifier, firstname, lastname FROM users WHERE identifier=@user", {
                ["@user"] = input[1]
            })

            if user == nil or #user == 0 or user[1] == nil then
                vx.notify(source, {
                    message = "Die speler kan niet worden gevonden",
                    type = "error"
                })
                return nil
            end

            local firstname = user[1].firstname or "Unknown User"
            local lastname = user[1].lastname or ""
            local fullName = (firstname .. " " .. lastname):gsub("%s+$", "")

            return {
                ped = -1,
                identifier = user[1].identifier,
                name = "Offline Player (" .. fullName .. ")",
                isOnline = false
            }
        else
            local esx = ensureESX()
            player = esx and esx.GetPlayerFromId(isNumber) or nil
        end

        if not player then
            vx.notify(source, {
                message = "Die speler kan niet worden gevonden",
                type = "error"
            })
            return nil
        end

        local playerId = player.source or player.playerId or isNumber
        local playerName = (player.getName and player.getName()) or player.name or GetPlayerName(playerId)

        return {
            ped = playerId,
            identifier = player.identifier,
            name = playerName,
            isOnline = playerId ~= 0,
        }
    end
end

---@param user SrpPlayer
function serverCallbackProxy.OpenPlayerInventory(user, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    Discord.LogInventoryInformation(source, user, "Player", "")

    if user.ped == source then
        vx.notify(source, { message = "Waarom wil je je eigen inventory zien via staffassist?" })
        return nil
    end

    exports.ox_inventory:forceOpenInventory(source, "player", user.ped)
end

---@param user SrpPlayer
---@param plate string
function serverCallbackProxy.OpenVehicleInventory(user, plate, type, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    local query = MySQL.query.await("SELECT * FROM owned_vehicles WHERE owner = @owner AND plate = @plate", {
        ["@owner"] = user.identifier,
        ["@plate"] = plate
    })

    if query == nil or #query == 0 or query[1] == nil then
        vx.notify(source, { message = "Vehicle not found" })
        return nil
    end

    local boxType = type == "glove" and "glovebox" or "trunk"
    local metadata = json.decode(query[1].vehicle)
    local vehicle = {
        name = query[1].name and query[1].name or "Ongeregistreerd voertuig",
        type = query[1].type,
        plate = query[1].plate,
        hash = metadata.model,
        hasGlovebox = query[1].glovebox ~= nil,
        hasTrunk = query[1].trunk ~= nil,
    }

    Discord.LogInventoryInformation(source, user, "Vehicle " .. boxType, string.format([[
        **Vehicle name**: %s
        **Vehicle plate**: %s
    ]], vehicle.name, vehicle.plate))

    local netId = utils.spawnGhostVehicleAsync(source, vehicle)

    local inventory = exports.ox_inventory:forceOpenInventory(source, boxType, {
        id = type .. vehicle.plate,
        netid = NetworkGetNetworkIdFromEntity(netId)
    })

    Citizen.Wait(100)
    if not inventory then
        vx.notify(source, {
            message = "Voertuig inhoud kan niet worden geopened, Probeer het later nog een keer",
            type = "error"
        })
    end

    DeleteEntity(netId)
end

---@param user SrpPlayer
---@param property string
function serverCallbackProxy.OpenPropertyInventory(user, property, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    local query = MySQL.query.await("SELECT * FROM owned_properties WHERE id = @id AND owner = @owner", {
        ["@id"] = property,
        ["@owner"] = user.identifier
    })

    if query == nil or #query == 0 then
        return nil
    end

    Discord.LogInventoryInformation(source, user, "Property", string.format([[
**Property Id**: %s
**Property Name**: %s
**Property Price**: %s
**Property Owner**: %s]], query[1].id, query[1].name, query[1].price, query[1].owner))

    local inventory = string.format("vx_property-stash-%s", property)
    exports.ox_inventory:forceOpenInventory(source, "stash", inventory)
end

---@param user SrpPlayer
---@param loods string
function serverCallbackProxy.OpenLoodsInventory(user, loods, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    local query = MySQL.query.await("SELECT * FROM vx_loodsen WHERE id = @id AND owner = @owner", {
        ["@id"] = loods,
        ["@owner"] = user.identifier
    })

    if query == nil or #query == 0 then
        return nil
    end

    Discord.LogInventoryInformation(source, user, "Loodsen", string.format([[
**Loods Id**: %s
**Loods Type**: %s
**Loods Name**: %s
**Loods Owner**: %s]], query[1].id, query[1].type, query[1].property, query[1].owner))

    local inventory = string.format("loods_inventory_%s", loods)
    vx.print.info(inventory)

    exports.ox_inventory:forceOpenInventory(source, "stash", inventory)
end

---@param user SrpPlayer
function serverCallbackProxy.ComservePlayer(user, article, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    local pedId = utils.GetPlayerFromIdentifier(user.identifier)

    vx.print.info(pedId, article)

    if pedId ~= nil then
        exports['vx_comserve'].setCommunityService(source, source, pedId, article.reason, article.count)
    else
        exports['vx_comserve'].setOfflineComserve(source, source, user.identifier, article.reason, article.count)
    end

    vx.notify(source, {
        message = "Gebruiker is op " .. article.count .. " taken gestuurd!",
        type = "success"
    })
end

---@param user SrpPlayer
---@param plate string
function serverCallbackProxy.RemoveVehicleFromGarage(user, plate, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    local query = MySQL.query.await("DELETE FROM owned_vehicles WHERE owner = @owner AND plate = @plate",
        {
            ["@owner"] = user.identifier,
            ["@plate"] = plate,
        })

    Discord.LogCarInformation(source, user, string.format([[
**Vehicle plate**: %s
**Vehicle owner**: %s

_Vehicle was removed from garage_]], plate, user.identifier))

    if query.affectedRows > 0 then
        vx.notify(source, {
            message = "Voertuig verwijderd uit garage",
            type = "success"
        })
    end
end

---@param user SrpPlayer
---@param plate string
function serverCallbackProxy.RenameVehicleInGarage(user, plate, newName, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    local query = MySQL.query.await(
        "UPDATE owned_vehicles SET name = @name WHERE owner = @owner AND plate = @plate",
        {
            ["@name"] = newName,
            ["@owner"] = user.identifier,
            ["@plate"] = plate,
        })

    Discord.LogCarInformation(source, user, string.format([[
**Vehicle plate**: %s
**Vehicle owner**: %s
**Vehicle new name**: %s

_Vehicle name was renamed from garage_]], plate, user.identifier, newName))

    if query.affectedRows > 0 then
        vx.notify(source, {
            message = "Naam van het voertuig is veranderd!",
            type = "success"
        })
    end
end

---@param user SrpPlayer
---@param plate string
function serverCallbackProxy.RenamePlateInGarage(user, plate, newPlate, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    local vehicleData = serverCallbackProxy.GetVehicleFromPlate(plate, source)
    if vehicleData == nil then return end
    local vehicleMetadata = json.decode(vehicleData.vehicle)
    vehicleMetadata.plate = newPlate

    local query = MySQL.query.await(
        "UPDATE owned_vehicles SET vehicle = @vehicle, plate = @newPlate WHERE owner = @owner AND plate = @plate",
        {
            ["@vehicle"] = json.encode(vehicleMetadata),
            ["@newPlate"] = newPlate,
            ["@owner"] = user.identifier,
            ["@plate"] = plate,
        })

    Discord.LogCarInformation(source, user, string.format([[
**Vehicle owner**: %s
**Vehicle old plate**: %s
**Vehicle new plate**: %s

_Vehicle plate was renamed from garage_]], user.identifier, plate, newPlate))

    if query.affectedRows > 0 then
        vx.notify(source, {
            message = "Kenteken van het voertuig is veranderd!",
            type = "success"
        })
    end
end

---@param target SrpPlayer
function serverCallbackProxy.WipePlayerData(target, source) WipePlayerData(target, source) end

---@param target SrpPlayer
function WipePlayerData(target, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return false
    end

    if target.ped <= 0 then
        return
    end

    local txPlayer = database.FindUserInDatabase(target.identifier)

    if txPlayer == nil then
        return
    end

    local identifiers = {
        ["steam"] = utils.getPlayerIdentifierFromTable(txPlayer.ids, true, "steam"),
        ["license"] = utils.getPlayerIdentifierFromTable(txPlayer.ids, true, "license"),
        ["xbl"] = utils.getPlayerIdentifierFromTable(txPlayer.ids, true, "xbl"),
        ["live"] = utils.getPlayerIdentifierFromTable(txPlayer.ids, true, "live"),
        ["discord"] = utils.getPlayerIdentifierFromTable(txPlayer.ids, true, "discord"),
        ["fivem"] = utils.getPlayerIdentifierFromTable(txPlayer.ids, true, "fivem"),
    }

    ---@param keepPrefix any
    ---@param forcedType IdentifierType
    function GetIdentifier(keepPrefix, forcedType)
        local identifierType = forcedType or "license"
        local identifier = identifiers[identifierType]
        if identifier == nil then return nil end
        if not keepPrefix then identifier = identifier:gsub(identifierType .. ":", "") end
        return identifier
    end

    Discord.LogAccountInformation(source, target, "**USER HAS BEEN WIPED FROM THE DATABASE**")

    local blacklistId = Blacklist.AddUser(target.identifier, "Je account word gewiped", source)

    for _, k in pairs(Config.Tables) do
        MySQL.query.await("DELETE FROM " .. k.table .. " WHERE " .. k.key .. " = @user",
            {
                ["@user"] = GetIdentifier(k.keepPrefix, k.type)
            })
    end

    if blacklistId ~= -1 then
        Blacklist.RemoveFromBlacklist(blacklistId)
    end

    return true
end

---@param player SrpPlayer
function serverCallbackProxy.BlacklistPlayer(player, reason, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    local id = Blacklist.AddUser(player.identifier, reason, source)

    if id ~= -1 then
        Discord.LogAccountInformation(source, player, string.format([[
**Blacklist ID**: %s
**Reason**: %s

**USER IS BLACKLISTED**]], id, reason))
    end
end

function serverCallbackProxy.WhitelistPlayer(id, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    local query = Blacklist.RemoveFromBlacklist(id)

    if query then
        vx.notify(source, { message = "Speler is verwijderd van de blacklist", type = "success" })

        Discord.LogAccountInformation(source, {
            name = "Blacklist #" .. tostring(id),
            identifier = tostring(id),
        }, string.format([[
**Blacklist ID**: %s

**USER HIS BLACKLIST WAS REMOVED**]], id))
    else
        vx.notify(source, { message = "Speler niet gevonden op de blacklist", type = "error" })
    end
end

---@param newPlayer string
---@param oldPlayer string
function TransferAccount(newPlayer, oldPlayer, source)
    local user = database.FindUserInDatabase(oldPlayer)

    if user == nil then
        vx.notify(source, {
            message = "Die speler bestaat niet!",
            type = "error"
        })
        return
    end

    local player = utils.GetPlayerFromIdentifier(newPlayer)

    if player ~= nil then
        DropPlayer(player, "Je account word overgezet, even geduld.")
    end

    for _, k in pairs(Config.Tables) do
        if k.type == "license" and k.keepPrefix == false then
            MySQL.query.await("DELETE FROM " .. k.table .. " WHERE " .. k.key .. " = @value", { ["@value"] = newPlayer })
        end
    end

    for _, k in pairs(Config.Tables) do
        if k.type == "license" and k.keepPrefix == false then
            MySQL.query.await("UPDATE " .. k.table .. " SET " .. k.key .. " = @value WHERE " .. k.key .. " = @oldvalue",
                {
                    ["@oldvalue"] = oldPlayer,
                    ["@value"] = newPlayer,
                })
        end
    end
end

---@param target SrpPlayer
---@param oldIdentifier string
function serverCallbackProxy.TransferAccount(target, oldIdentifier, source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    TransferAccount(target.identifier, oldIdentifier, source)
end

function serverCallbackProxy.OpenTrashCan(source)
    if not GroupCheck(source) then
        vx.notify(source, { message = "You are not allowed to execute this trigger" })
        return nil
    end

    local stashId = exports.ox_inventory:CreateTemporaryStash({
        label = 'Prullenbak',
        slots = 500,
        maxWeight = 9999999,
    })

    return stashId
end
