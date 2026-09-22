ESX = exports["es_extended"]:getSharedObject()


local function HasCoinPermission(source)
    if source == 0 then
        return true -- console
    end

    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return false    
    end


--AANZETTEN INDIEN JE MEERDERE GROEPEN WIL TOEVOEGEN!!
    -- local allowedGroups ={
    --     admin = true,
    --     owner = true
    -- }
    -- return xPlayer.getGroup() == true

 --ENKEL REGEL 24 UIT ZETTEN INDIEN JE MEE GROEPEN TOEGANG WIL GEVEN   
    return xPlayer.getGroup() =="owner"

end

function sendToDiscord(title, description)
    print(('[vex-tebexwrapper] %s | %s'):format(title or 'log', description or ''))
end

lib.callback.register('vex-tebexwrapper:request:config', function(source)
    return Config
end)

lib.callback.register('vex-tebexwrapper:request:coins', function(source)
    return getPlayerCoins(source)
end)

lib.callback.register('vex-tebexwrapper:request:name', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return 'Gebruiker'
    end
    return xPlayer.getName()
end)

local usedDiscountCodes = {}

lib.callback.register('vex-tebexwrapper:process:cart', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end

    local playerCoins = tonumber(getPlayerCoins(source)) or 0
    local totalPrice = data.total

    if playerCoins < totalPrice then
        sendToDiscord("🚨 Cheat Gedetecteerd",
            ("**Speler:** %s (%s)\n**Reden:** Probeerde te kopen zonder genoeg coins.\n**Coins:** %s | **Prijs:** %s")
            :format(GetPlayerName(source), xPlayer.identifier, playerCoins, totalPrice),
            15158332
        )
        if Config.Cheat.kick then
            DropPlayer(source, Config.Cheat.kickmessage)
        end
        return
    end

    local gekochteItems = {}

    for _, item in ipairs(data.items) do
        if item.type == 'pack' and item.items then
            for i = 1, item.quantity do
                for _, packItem in ipairs(item.items) do
                    local success = GiveProduct(source, packItem.type, packItem.id, packItem.amount)
                    table.insert(gekochteItems, ("%s x%s"):format(packItem.name, packItem.amount))
                end
            end
        else
            local success = GiveProduct(source, item.type, item.id, item.amount * item.quantity)
            table.insert(gekochteItems, ("%s x%s"):format(item.name, item.amount * item.quantity))
        end
    end

    if data.discount and data.discount.code then
        if not usedDiscountCodes[xPlayer.identifier] then
            usedDiscountCodes[xPlayer.identifier] = {}
        end
        table.insert(usedDiscountCodes[xPlayer.identifier], data.discount.code)
    end

    updatePlayerCoins(source, totalPrice, 'remove')
    Notify(source, 'Aankoop Gelukt', 'Je aankoop is succesvol verwerkt!', 'fa-solid fa-receipt')
    exports['mallorca_announcements']:sendDisplayDonation('NIEUWE DONATIE!', 'Ondersteuning voor de server', GetPlayerName(xPlayer.source), 'Heeft zojuist '..totalPrice..'x coins aan spullen gekocht!', true)

    sendToDiscord("🛒 Aankoop",
        ("**Speler:** %s (%s)\n**Betaald:** %s Coins\n**Gekocht:**\n- %s")
        :format(xPlayer.getName(), xPlayer.identifier, totalPrice, table.concat(gekochteItems, "\n- ")),
        3066993
    )
end)

local function getRandomReward(rewards)
    local totalProbability = 0
    for _, reward in pairs(rewards) do
        totalProbability = totalProbability + reward.probability
    end
    local random = math.random() * totalProbability
    local currentProbability = 0
    for _, reward in pairs(rewards) do
        currentProbability = currentProbability + reward.probability
        if random <= currentProbability then
            return reward
        end
    end
    return rewards[1]
end

lib.callback.register('vex-tebexwrapper:open:crate', function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then
        return {success = false, message = "Speler niet gevonden"}
    end

    local crateId = data.crateId
    local price = data.price
    local playerCoins = tonumber(getPlayerCoins(source)) or 0

    if playerCoins < price then
        sendToDiscord("🚨 Cheat Gedetecteerd",
            ("**Speler:** %s (%s)\n**Reden:** Probeerde een crate te openen zonder genoeg coins.\n**Coins:** %s | **Prijs:** %s")
            :format(GetPlayerName(source), xPlayer.identifier, playerCoins, price),
            15158332
        )
        return {success = false, message = "Niet genoeg coins"}
    end

    local crateData = nil
    for _, category in pairs(Config.StoreData.categories) do
        if category.products then
            for _, product in pairs(category.products) do
                if product.id == crateId and product.type == "crate" then
                    crateData = product
                    break
                end
            end
        end
        if crateData then break end
    end

    if not crateData or not crateData.rewards then
        return {success = false, message = "Crate niet gevonden"}
    end

    updatePlayerCoins(source, price, 'remove')

    local reward = getRandomReward(crateData.rewards)
    GiveProduct(source, reward.type, reward.id, reward.amount)

    sendToDiscord("🎁 Crate Geopend",
        ("**Speler:** %s (%s)\n**Crate:** %s\n**Beloning:** %s x%s")
        :format(xPlayer.getName(), xPlayer.identifier, crateData.name or crateId, reward.name or reward.id, reward.amount),
        15844367
    )

    return {success = true, reward = reward, allRewards = crateData.rewards}
end)

function GeneratePlate()
    local charset = {}
    for i = 48, 57 do table.insert(charset, string.char(i)) end
    for i = 65, 90 do table.insert(charset, string.char(i)) end
    local function randomPlate()
        local plate = ""
        for i = 1, 4 do
            plate = plate .. charset[math.random(1, #charset)]
        end
        return 'MLRP' .. plate
    end
    local plate
    local result
    repeat
        plate = randomPlate()
        result = MySQL.Sync.fetchScalar("SELECT plate FROM owned_vehicles WHERE plate = @plate LIMIT 1", {['@plate'] = plate})
    until not result
    return plate
end

giveVehicle = function(player, model, type)
    local xPlayer = ESX.GetPlayerFromId(player)
    if not xPlayer then return end
    local plate = GeneratePlate()
    local vehicleProps = { model = GetHashKey(model), plate = plate }
    MySQL.Sync.execute(
        "INSERT INTO owned_vehicles (owner, plate, vehicle, stored, type) VALUES (@owner, @plate, @vehicle, @stored, @type);",
        {['@owner'] = xPlayer.identifier, ['@plate'] = plate, ['@vehicle'] = json.encode(vehicleProps), ['@stored'] = 0, ['@type'] = type}
    )
    sendToDiscord("🚗 Voertuig Gegeven",
        ("**Speler:** %s (%s)\n**Model:** %s\n**Kenteken:** %s")
        :format(xPlayer.getName(), xPlayer.identifier, model, plate),
        15158332
    )
end

getPlayerCoins = function(player)
    local xPlayer = ESX.GetPlayerFromId(player)
    if not xPlayer then
        Citizen.Wait(1000)
        xPlayer = ESX.GetPlayerFromId(player)
        if not xPlayer then return 0 end
    end
    local result = MySQL.query.await('SELECT coins FROM users WHERE identifier = ?', {xPlayer.getIdentifier()})
    if not result[1] or result[1].coins == nil then
        return 0
    end
    return tonumber(result[1].coins) or 0
end

updatePlayerCoins = function(player, amount, action)
    local xPlayer = ESX.GetPlayerFromId(player)
    if not xPlayer and type(player) == "string" then
        xPlayer = ESX.GetPlayerFromIdentifier(player)
    end
    if not xPlayer then return end
    local sign = (action == 'remove') and -1 or 1
    local change = sign * tonumber(amount)
    MySQL.Async.execute('UPDATE users SET coins = coins + ? WHERE identifier = ?', {change, xPlayer.getIdentifier()})
    local newCoins = getPlayerCoins(xPlayer.source)
    lib.callback.await('vex-tebexwrapper:client:update:coins', player, newCoins)
    sendToDiscord("💰 Coins Bijgewerkt",
        ("**Speler:** %s (%s)\n**Actie:** %s\n**Aantal:** %s\n**Nieuw Saldo:** %s")
        :format(xPlayer.getName(), xPlayer.identifier, action, amount, newCoins),
        (action == 'add') and 3066993 or 15158332
    )
end

updatePlayerCoinsOffline = function(player, amount, action)
    local sign = (action == 'remove') and -1 or 1
    local change = sign * tonumber(amount)
    MySQL.Async.execute('UPDATE users SET coins = COALESCE(coins, 0) + ? WHERE identifier = ?', {change, player})
    sendToDiscord("💰 Coins Bijgewerkt (Offline)",
        ("**Identifier:** %s\n**Actie:** %s\n**Aantal:** %s")
        :format(player, action, amount),
        (action == 'add') and 3066993 or 15158332
    )
end

RegisterCommand('vexwrapper:sendProduct', function(source, args, rawCommand)
    if source > 0 then return end
    local data = {
        cfxID  = tostring(args[1]) or '0',
        amount = tonumber(args[2]) or 0,
        price  = tonumber(args[3]) or 0.00,
    }
    vexWrapperSendPayment(data)
end, false)

vexWrapperSendPayment = function(data)
    if not data.cfxID then return end
    local license = getLicenseFromCFX(data.cfxID)
    if not license then
        updatePlayerCoinsOffline(data.cfxID, tonumber(data.amount), 'add')
        return
    end
    local xPlayer = ESX.GetPlayerFromIdentifier(license)
    if xPlayer then
        updatePlayerCoins(xPlayer.source, data.amount, 'add')
        Notify(xPlayer.source, 'Coins Ontvangen', 'Je hebt '..data.amount..'x coins ontvangen!', 'fa-solid fa-coins')
        exports['mallorca_announcements']:sendDisplayDonation('NIEUWE DONATIE!', 'Ondersteuning voor de server', GetPlayerName(xPlayer.source), 'Heeft zojuist '..data.amount..'x coins gekocht!', true)
        sendToDiscord("💰 Coins Ontvangen",
            ("**Speler:** %s (%s)\n**cfxID:** %s\n**Aantal:** %s Coins")
            :format(xPlayer.getName(), license, data.cfxID, data.amount),
            3447003
        )
    else
        updatePlayerCoinsOffline(license, tonumber(data.amount), 'add')
        sendToDiscord("💰 Coins Toegevoegd (Offline)",
            ("**Identifier:** %s\n**cfxID:** %s\n**Aantal:** %s Coins")
            :format(license, data.cfxID, data.amount),
            3447003
        )
    end
end

getLicenseFromCFX = function(cfxID)
    for _, playerId in ipairs(GetPlayers()) do
        for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
            if string.sub(identifier, 1, 6) == "fivem:" then
                local idNum = string.sub(identifier, 7)
                if idNum == tostring(cfxID) then
                    for _, id2 in ipairs(GetPlayerIdentifiers(playerId)) do
                        if string.sub(id2, 1, 7) == "license" then
                            return string.sub(id2, 9)
                        end
                    end
                end
            end
        end
    end
    return nil
end

exports('giveOnlinePlayerCoins', function(player, amount)
    updatePlayerCoins(player, amount, 'add')
end)

exports('giveOfflinePlayerCoins', function(player, amount)
    updatePlayerCoinsOffline(player, amount, 'add')
end)

exports('removeOnlinePlayerCoins', function(player, amount)
    updatePlayerCoins(player, amount, 'remove')
end)

exports('removeOfflinePlayerCoins', function(player, amount)
    updatePlayerCoinsOffline(player, amount, 'remove')
end)


RegisterCommand("givecoins", function(source, args)

    if not HasCoinPermission(source) then
        TriggerClientEvent("ox_lib:notify", source, {
            title = "Geen toegang",
            description = "Je mag dit commando niet gebruiken.",
            type = "error"
        })
        return
    end

    local target = tonumber(args[1])
    local amount = tonumber(args[2])

    if not target or not amount then
        TriggerClientEvent("ox_lib:notify", source, {
            title = "Gebruik",
            description = "/givecoins <id> <aantal>",
            type = "error"
        })
        return
    end

    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end

    updatePlayerCoins(target, amount, "add")

    TriggerClientEvent("ox_lib:notify", source, {
        title = "Succes",
        description = ("Je gaf %s %d coins."):format(GetPlayerName(target), amount),
        type = "success"
    })

end, false)

RegisterCommand("removecoins", function(source, args)

    if not HasCoinPermission(source) then
        TriggerClientEvent("ox_lib:notify", source, {
            title = "Geen toegang",
            description = "Je mag dit commando niet gebruiken.",
            type = "error"
        })
        return
    end

    local target = tonumber(args[1])
    local amount = tonumber(args[2])

    if not target or not amount then
        TriggerClientEvent("ox_lib:notify", source, {
            title = "Gebruik",
            description = "/removecoins <id> <aantal>",
            type = "error"
        })
        return
    end

    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then return end

    updatePlayerCoins(target, amount, "remove")

    TriggerClientEvent("ox_lib:notify", source, {
        title = "Succes",
        description = ("Je haalde %d coins weg bij %s."):format(amount, GetPlayerName(target)),
        type = "success"
    })

end, false)

updatePlayerCoins = function(player, amount, action)
    local xPlayer = ESX.GetPlayerFromId(player)

    if not xPlayer and type(player) == "string" then
        xPlayer = ESX.GetPlayerFromIdentifier(player)
    end

    if not xPlayer then return end

    amount = math.abs(tonumber(amount) or 0)

    local currentCoins = getPlayerCoins(xPlayer.source)

    if action == "remove" then
        if currentCoins < amount then
            sendToDiscord(
                "🚨 Negatieve Coins Geblokkeerd",
                ("**Speler:** %s (%s)\n**Coins:** %s\n**Probeerde te verwijderen:** %s")
                :format(xPlayer.getName(), xPlayer.identifier, currentCoins, amount),
                15158332
            )
            return false
        end
    end

    local sign = (action == "remove") and -1 or 1
    local change = sign * amount

    MySQL.Async.execute(
        'UPDATE users SET coins = COALESCE(coins, 0) + ? WHERE identifier = ?',
        {change, xPlayer.getIdentifier()}
    )

    local newCoins = math.max(0, currentCoins + change)

    lib.callback.await(
        'vex-tebexwrapper:client:update:coins',
        player,
        newCoins
    )

    sendToDiscord(
        "💰 Coins Bijgewerkt",
        ("**Speler:** %s (%s)\n**Actie:** %s\n**Aantal:** %s\n**Nieuw Saldo:** %s")
        :format(xPlayer.getName(), xPlayer.identifier, action, amount, newCoins),
        (action == "add") and 3066993 or 15158332
    )

    return true
end
