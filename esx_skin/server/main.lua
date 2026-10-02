local function decodeSkin(value)
    if type(value) == "table" then
        return value
    end

    if type(value) ~= "string" or value == "" then
        return nil
    end

    local ok, decoded = pcall(json.decode, value)
    if not ok or type(decoded) ~= "table" then
        return nil
    end

    return decoded
end

local function sanitizeSkinValue(value)
    if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
        return nil
    end

    if value < -100000 or value > 100000 then
        return nil
    end

    return math.floor(value + 0.5)
end

local function persistSkin(identifier, skin, done)
    MySQL.query("SELECT skin FROM users WHERE identifier = @identifier", {
        ["@identifier"] = identifier,
    }, function(users)
        local current = decodeSkin(users and users[1] and users[1].skin) or {}

        for key, value in pairs(skin) do
            local sanitized = type(key) == "string" and #key <= 64 and sanitizeSkinValue(value) or nil
            if sanitized ~= nil then
                current[key] = sanitized
            end
        end

        MySQL.update("UPDATE users SET skin = @skin WHERE identifier = @identifier", {
            ["@skin"] = json.encode(current),
            ["@identifier"] = identifier,
        }, function()
            if done then
                done(current)
            end
        end)
    end)
end

local function savePlayerSkin(playerSource, skin, done)
    if type(skin) ~= "table" then
        if done then
            done(false)
        end
        return
    end

    local xPlayer = ESX.Player(playerSource)
    if not xPlayer then
        if done then
            done(false)
        end
        return
    end

    if skin.bags_1 ~= nil and not ESX.GetConfig().CustomInventory then
        local defaultMaxWeight = ESX.GetConfig().MaxWeight
        local backpackModifier = Config.BackpackWeight[skin.bags_1]

        if backpackModifier then
            xPlayer.setMaxWeight(defaultMaxWeight + backpackModifier)
        else
            xPlayer.setMaxWeight(defaultMaxWeight)
        end
    end

    pcall(function()
        if xPlayer.set then
            xPlayer.set("skin", skin)
        end
    end)

    persistSkin(xPlayer.getIdentifier(), skin, function()
        if done then
            done(true)
        end
    end)
end

RegisterNetEvent("esx_skin:save", function(skin)
    savePlayerSkin(source, skin)
end)

xLib.callback.registerCompat("esx_skin:saveSkin", function(source, cb, skin)
    savePlayerSkin(source, skin, function(saved)
        cb(saved == true)
    end)
end)

RegisterNetEvent("esx_skin:setWeight", function(skin)
    local xPlayer = ESX.Player(source)

    if not ESX.GetConfig().CustomInventory then
        local defaultMaxWeight = ESX.GetConfig().MaxWeight
        local backpackModifier = Config.BackpackWeight[skin.bags_1]

        if backpackModifier then
            xPlayer.setMaxWeight(defaultMaxWeight + backpackModifier)
        else
            xPlayer.setMaxWeight(defaultMaxWeight)
        end
    end
end)

xLib.callback.registerCompat("esx_skin:getPlayerSkin", function(source, cb)
    local xPlayer = ESX.Player(source)

    MySQL.query("SELECT skin FROM users WHERE identifier = @identifier", {
        ["@identifier"] = xPlayer.getIdentifier(),
    }, function(users)
        local user, skin = users[1], nil

        local jobSkin = {
            skin_male = xPlayer.getJob().skin_male,
            skin_female = xPlayer.getJob().skin_female,
        }

        skin = decodeSkin(user.skin)

        cb(skin, jobSkin)
    end)
end)

ESX.RegisterCommand("skin", "admin", function(xPlayer, args)
    if not args.playerId then
        args.playerId = xPlayer
    end
    args.playerId.triggerEvent("esx_skin:openSaveableMenu")
end, false, { help = TranslateCap("skin"), arguments = { { name = "playerId", help = TranslateCap("skin"), type = "player" }} })
