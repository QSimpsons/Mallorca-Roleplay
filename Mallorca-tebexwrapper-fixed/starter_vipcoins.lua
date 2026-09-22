-- Eenmalig 10.000 VIP coins (users.coins) als iemand voor het eerst ingame komt.
-- Bestaande spelers worden bij de eerste start gemarkeerd en krijgen niks.

StarterVip = StarterVip or {}

local BACKFILL_KEY = '__backfill__'

function StarterVip.personKey(identifier)
    if type(identifier) ~= 'string' or identifier == '' then
        return nil
    end
    return (identifier:gsub('^char%d+:', ''))
end

function StarterVip.formatAmount(amount)
    local n = math.floor(tonumber(amount) or 0)
    if n < 0 then n = 0 end
    local formatted = tostring(n):reverse():gsub('(%d%d%d)', '%1.'):reverse()
    if formatted:sub(1, 1) == '.' then
        formatted = formatted:sub(2)
    end
    return formatted
end

-- claimed = deze persoon staat al in Mallorca_starter_vipcoins (uitkering of bestaande speler)
function StarterVip.shouldGrant(claimed)
    if claimed then
        return false, 'already'
    end
    return true, 'first_join'
end

if type(MySQL) ~= 'table' or type(AddEventHandler) ~= 'function' then
    return
end

local ready = false
local busy = {}

local function log(msg)
    print(('[Mallorca-tebexwrapper] %s'):format(msg))
end

local function playerIdentifier(xPlayer)
    if not xPlayer then
        return nil
    end
    if xPlayer.getIdentifier then
        return xPlayer.getIdentifier()
    end
    return xPlayer.identifier
end

local function ensureCoinsColumn()
    local count = MySQL.scalar.await([[
        SELECT COUNT(*) FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = 'users' AND column_name = 'coins'
    ]])
    if tonumber(count) == 0 then
        MySQL.query.await('ALTER TABLE `users` ADD COLUMN `coins` INT NOT NULL DEFAULT 0')
        log('Kolom users.coins aangemaakt.')
    end
end

local function ensureClaimTable()
    MySQL.query.await([[
        CREATE TABLE IF NOT EXISTS `Mallorca_starter_vipcoins` (
            `identifier` VARCHAR(128) NOT NULL,
            `amount` INT NOT NULL,
            `granted_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`identifier`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    ]])
end

local function backfillDone()
    local row = MySQL.scalar.await(
        'SELECT `identifier` FROM `Mallorca_starter_vipcoins` WHERE `identifier` = ? LIMIT 1',
        { BACKFILL_KEY }
    )
    return row ~= nil
end

local function backfillExistingPlayers()
    local rows = MySQL.query.await('SELECT `identifier` FROM `users`') or {}
    local seen = {}
    local batch = {}
    local marked = 0

    local function flush()
        if #batch == 0 then
            return
        end
        local placeholders = {}
        local params = {}
        for i = 1, #batch do
            placeholders[i] = '(?, 0)'
            params[#params + 1] = batch[i]
        end
        MySQL.update.await(
            'INSERT IGNORE INTO `Mallorca_starter_vipcoins` (`identifier`, `amount`) VALUES ' .. table.concat(placeholders, ','),
            params
        )
        marked = marked + #batch
        batch = {}
    end

    for i = 1, #rows do
        local key = StarterVip.personKey(rows[i].identifier)
        if key and key ~= BACKFILL_KEY and not seen[key] then
            seen[key] = true
            batch[#batch + 1] = key
            if #batch >= 200 then
                flush()
            end
        end
    end
    flush()

    MySQL.update.await(
        'INSERT IGNORE INTO `Mallorca_starter_vipcoins` (`identifier`, `amount`) VALUES (?, 0)',
        { BACKFILL_KEY }
    )
    log(('Bestaande spelers krijgen geen startcoins (%s personen overgeslagen).'):format(marked))
end

local function tryGrant(src, xPlayer)
    if not ready or not src or not xPlayer then
        return false, 'not_ready'
    end

    local raw = playerIdentifier(xPlayer)
    local key = StarterVip.personKey(raw)
    if not key or key == BACKFILL_KEY then
        return false, 'identifier'
    end
    if busy[key] then
        return false, 'busy'
    end
    busy[key] = true

    local okRun, result, reason = xpcall(function()
        local amount = math.floor(tonumber(Config.StarterVipCoins) or 0)
        if amount <= 0 then
            return false, 'disabled'
        end

        local existing = MySQL.scalar.await(
            'SELECT `identifier` FROM `Mallorca_starter_vipcoins` WHERE `identifier` = ? LIMIT 1',
            { key }
        )
        local allow, why = StarterVip.shouldGrant(existing ~= nil)
        if not allow then
            return false, why
        end

        local claimed = MySQL.update.await(
            'INSERT IGNORE INTO `Mallorca_starter_vipcoins` (`identifier`, `amount`) VALUES (?, ?)',
            { key, amount }
        )
        if not claimed or claimed < 1 then
            return false, 'already'
        end

        local updated = MySQL.update.await(
            'UPDATE `users` SET `coins` = COALESCE(`coins`, 0) + ? WHERE `identifier` = ?',
            { amount, raw }
        )
        if not updated or updated < 1 then
            MySQL.update.await('DELETE FROM `Mallorca_starter_vipcoins` WHERE `identifier` = ?', { key })
            log(('Geen users-rij voor %s, startcoins niet gezet.'):format(raw))
            return false, 'no_user'
        end

        local pretty = StarterVip.formatAmount(amount)
        local balance = amount
        local okBalance, current = pcall(getPlayerCoins, src)
        if okBalance and tonumber(current) then
            balance = tonumber(current)
        end
        TriggerClientEvent('Mallorca-tebexwrapper:starter:coins', src, balance)
        TriggerClientEvent('vex-tebexwrapper:starter:coins', src, balance)
        Notify(src, 'VIP Coins', ('Welkom! Je hebt %s VIP coins ontvangen.'):format(pretty), 'fa-solid fa-coins')
        if sendToDiscord then
            sendToDiscord(
                'VIP startcoins',
                ('**Speler:** %s (%s)\n**Eenmalig:** %s VIP coins'):format(GetPlayerName(src) or key, raw, pretty),
                3066993
            )
        end
        log(('%s krijgt %s VIP coins (eerste join).'):format(key, pretty))
        return true, 'first_join'
    end, debug.traceback)

    busy[key] = nil

    if not okRun then
        log(('Startcoins fout voor %s: %s'):format(key, result))
        return false, 'error'
    end
    return result, reason
end

local function onPlayerLoaded(playerId, xPlayer)
    local src = playerId
    if type(src) ~= 'number' then
        return
    end
    if type(xPlayer) ~= 'table' or not playerIdentifier(xPlayer) then
        xPlayer = ESX.GetPlayerFromId(src)
    end
    if not xPlayer then
        return
    end
    CreateThread(function()
        while not ready do
            Wait(50)
        end
        tryGrant(src, xPlayer)
    end)
end

AddEventHandler('esx:playerLoaded', onPlayerLoaded)

CreateThread(function()
    local ok, err = xpcall(function()
        ensureCoinsColumn()
        ensureClaimTable()
        if not backfillDone() then
            backfillExistingPlayers()
        end
        ready = true
        log(('Startcoins actief: %s VIP coins, alleen bij de eerste join.'):format(
            StarterVip.formatAmount(Config.StarterVipCoins or 0)
        ))
        for _, id in ipairs(GetPlayers()) do
            local src = tonumber(id)
            local xPlayer = src and ESX.GetPlayerFromId(src) or nil
            if xPlayer then
                tryGrant(src, xPlayer)
            end
        end
    end, debug.traceback)
    if not ok then
        log(('Startcoins niet gestart: %s'):format(err))
    end
end)
