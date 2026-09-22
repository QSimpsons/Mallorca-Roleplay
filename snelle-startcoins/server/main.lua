local ESX = exports['es_extended']:getSharedObject()

local granted = {}
local busy = {}

local function log(msg)
    print(('[snelle-startcoins] %s'):format(msg))
end

local function storageKey(identifier)
    return Grant.storageKey(identifier, Config.OncePerCharacter)
end

local function notify(src, message)
    if not src or src <= 0 or not message or message == '' then
        return
    end
    TriggerClientEvent('snelle-startcoins:notify', src, message)
end

local function isAdmin(src)
    if src == 0 then
        return true
    end
    if IsPlayerAceAllowed(src, 'command.geefstartcoins') then
        return true
    end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return false
    end
    local group = xPlayer.getGroup()
    for i = 1, #Config.AdminGroups do
        if group == Config.AdminGroups[i] then
            return true
        end
    end
    return false
end

local function pay(xPlayer)
    local account = Config.Account
    local amount = math.floor(tonumber(Config.Amount) or 0)
    if amount <= 0 then
        return false, 'amount'
    end
    if not xPlayer.getAccount(account) then
        return false, 'account'
    end

    if Config.Mode == 'set' then
        xPlayer.setAccountMoney(account, amount, 'Startcoins')
    else
        xPlayer.addAccountMoney(account, amount, 'Startcoins')
    end
    return true
end

local function alreadyInDatabase(key)
    local row = MySQL.scalar.await(
        'SELECT `identifier` FROM `snelle_startcoins` WHERE `identifier` = ? LIMIT 1',
        { key }
    )
    return row ~= nil
end

local function createdAgo(identifier)
    if not Config.UseCreatedAtFallback then
        return nil
    end
    local ok, ago = pcall(function()
        return MySQL.scalar.await(
            'SELECT TIMESTAMPDIFF(SECOND, `created_at`, NOW()) FROM `users` WHERE `identifier` = ? LIMIT 1',
            { identifier }
        )
    end)
    if not ok then
        return nil
    end
    return tonumber(ago)
end

local function claimKey(key, amount, account, reason)
    return MySQL.update.await(
        'INSERT IGNORE INTO `snelle_startcoins` (`identifier`, `amount`, `account`, `reason`) VALUES (?, ?, ?, ?)',
        { key, amount, account, reason }
    )
end

local function releaseKey(key)
    MySQL.update.await('DELETE FROM `snelle_startcoins` WHERE `identifier` = ?', { key })
end

local function giveStartCoins(src, xPlayer, isNew, force, staffSrc)
    if not xPlayer then
        return false, 'no_player'
    end

    local identifier = xPlayer.identifier
    local key = storageKey(identifier)
    if not key then
        return false, 'identifier'
    end

    if busy[key] then
        return false, 'busy'
    end
    busy[key] = true

    local okRun, result, reason = xpcall(function()
        local claimed = granted[key] == true
        if not claimed then
            claimed = alreadyInDatabase(key) == true
            if claimed then
                granted[key] = true
            end
        end

        local ago = nil
        if not force and isNew ~= true then
            ago = createdAgo(identifier)
        end

        local allow, why = Grant.shouldGrant({
            alreadyGranted = claimed and not force,
            isNew = force and true or isNew,
            createdAgoSeconds = ago,
            fallbackEnabled = Config.UseCreatedAtFallback == true,
            windowSeconds = Config.NewPlayerWindowSeconds
        })

        if not allow then
            return false, why
        end

        local inserted = false
        if not claimed then
            local affected = claimKey(key, Config.Amount, Config.Account, why)
            if not affected or affected < 1 then
                granted[key] = true
                return false, 'already'
            end
            inserted = true
        end

        local paid, payReason = pay(xPlayer)
        if not paid then
            if inserted then
                local rolled, rollErr = pcall(releaseKey, key)
                if not rolled then
                    log(('Terugdraaien van claim %s mislukte: %s'):format(key, rollErr))
                end
            end
            log(('Uitkering mislukt voor %s (%s). Account "%s" bestaat niet of het bedrag is ongeldig.'):format(
                key, payReason or '?', Config.Account
            ))
            return false, payReason or 'pay'
        end

        granted[key] = true

        local pretty = Grant.formatAmount(Config.Amount)
        if staffSrc then
            notify(src, Config.Messages.adminReceived:format(pretty, Config.CoinLabel))
            local name = xPlayer.getName() or key
            local staffMsg = Config.Messages.adminGranted:format(pretty, Config.CoinLabel, name)
            if staffSrc == 0 then
                log(staffMsg)
            else
                notify(staffSrc, staffMsg)
            end
        else
            notify(src, Config.Messages.received:format(pretty, Config.CoinLabel))
            log(('%s krijgt %s %s (%s).'):format(key, pretty, Config.CoinLabel, why))
        end

        return true, why
    end, debug.traceback)

    busy[key] = nil

    if not okRun then
        log(('Fout bij %s: %s'):format(key, result))
        return false, 'error'
    end

    return result, reason
end

local function onPlayerLoaded(a, b, c)
    local src, xPlayer, isNew = Grant.normalizeLoaded(a, b, c)
    if not src then
        return
    end
    if type(xPlayer) ~= 'table' or not xPlayer.identifier then
        xPlayer = ESX.GetPlayerFromId(src)
    end
    if not xPlayer then
        return
    end

    CreateThread(function()
        local ok, err = pcall(giveStartCoins, src, xPlayer, isNew, false, nil)
        if not ok then
            log(('Fout bij speler %s: %s'):format(src, err))
        end
    end)
end

AddEventHandler('esx:playerLoaded', onPlayerLoaded)

RegisterCommand('geefstartcoins', function(src, args)
    if not isAdmin(src) then
        notify(src, Config.Messages.noPermission)
        return
    end

    local target = tonumber(args[1] or '')
    if not target then
        if src == 0 then
            log(Config.Messages.usage)
        else
            notify(src, Config.Messages.usage)
        end
        return
    end

    local xPlayer = ESX.GetPlayerFromId(target)
    if not xPlayer then
        if src == 0 then
            log(Config.Messages.noPlayer)
        else
            notify(src, Config.Messages.noPlayer)
        end
        return
    end

    local force = args[2] == 'force'
    CreateThread(function()
        local ok, reason = giveStartCoins(target, xPlayer, true, force, src)
        if ok then
            return
        end
        local msg = Config.Messages.failed
        if reason == 'already' then
            msg = Config.Messages.already
        elseif reason == 'no_player' then
            msg = Config.Messages.noPlayer
        end
        if src == 0 then
            log(msg)
        else
            notify(src, msg)
        end
    end)
end, false)

CreateThread(function()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `snelle_startcoins` (
            `identifier` VARCHAR(80) NOT NULL,
            `amount` INT NOT NULL,
            `account` VARCHAR(32) NOT NULL,
            `reason` VARCHAR(32) NOT NULL,
            `granted_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
    log(('Actief. Nieuwe spelers krijgen %s %s op account "%s".'):format(
        Grant.formatAmount(Config.Amount),
        Config.CoinLabel,
        Config.Account
    ))
end)

exports('GiveStartCoins', function(playerId, force)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        return false, 'no_player'
    end
    return giveStartCoins(playerId, xPlayer, true, force == true, nil)
end)
