-- Simuleert ESX + oxmysql en draait server/main.lua.
-- lua5.4 tests/test_flow.lua

local here = arg[0]:match('^(.*)/') or '.'
local root = here .. '/..'

local failures = 0
local function eq(actual, expected, name)
    if actual ~= expected then
        failures = failures + 1
        io.stderr:write(('FAIL %s: got %q expected %q\n'):format(name, tostring(actual), tostring(expected)))
    end
end

local players = {}
local notes = {}
local rows = {}
local handlers = {}
local commands = {}
local exportReg = {}
local function xPlayer(id, identifier, group)
    local accounts = { money = 500, bank = 0 }
    local player = {
        source = id,
        identifier = identifier,
        group = group or 'user',
        name = 'Speler ' .. tostring(id),
        _accounts = accounts
    }
    -- ESX roept deze met een punt aan (self zit in de closure).
    player.getGroup = function() return player.group end
    player.getName = function() return player.name end
    player.getAccount = function(name)
        if accounts[name] == nil then return nil end
        return { name = name, money = accounts[name] }
    end
    player.addAccountMoney = function(name, amount)
        accounts[name] = accounts[name] + amount
    end
    player.setAccountMoney = function(name, amount)
        accounts[name] = amount
    end
    return player
end

ESX = {
    GetPlayerFromId = function(id) return players[id] end
}

exports = setmetatable({}, {
    __call = function(_, name, fn)
        exportReg[name] = fn
    end,
    __index = function(_, key)
        if key == 'es_extended' then
            return { getSharedObject = function() return ESX end }
        end
    end
})

function AddEventHandler(name, fn)
    handlers[name] = fn
end

function RegisterCommand(name, fn)
    commands[name] = fn
end

function CreateThread(fn)
    fn()
end

function TriggerClientEvent(name, src, message)
    notes[#notes + 1] = { name = name, src = src, message = message }
end

function IsPlayerAceAllowed()
    return false
end

local function affectedInsert(key, amount, account, reason)
    if rows[key] then return 0 end
    rows[key] = { amount = amount, account = account, reason = reason }
    return 1
end

MySQL = {
    query = { await = function() return true end },
    scalar = {
        await = function(sql, params)
            if sql:find('snelle_startcoins', 1, true) then
                local row = rows[params[1]]
                return row and params[1] or nil
            end
            if sql:find('TIMESTAMPDIFF', 1, true) then
                return players._age and players._age[params[1]] or nil
            end
            error('onbekende query: ' .. sql)
        end
    },
    update = {
        await = function(sql, params)
            if sql:find('INSERT IGNORE', 1, true) then
                return affectedInsert(params[1], params[2], params[3], params[4])
            end
            if sql:find('DELETE FROM', 1, true) then
                local existed = rows[params[1]] ~= nil
                rows[params[1]] = nil
                return existed and 1 or 0
            end
            error('onbekende update: ' .. sql)
        end
    }
}

players._age = {}

dofile(root .. '/config.lua')
dofile(root .. '/server/grant.lua')
dofile(root .. '/server/main.lua')

eq(type(handlers['esx:playerLoaded']), 'function', 'playerLoaded hooked')
eq(type(commands.geefstartcoins), 'function', 'command registered')
eq(type(exportReg.GiveStartCoins), 'function', 'export registered')

local function money(id)
    return players[id]._accounts.money
end

local function noteCount()
    return #notes
end

-- Nieuw character krijgt 10000 bovenop startgeld.
players[1] = xPlayer(1, 'char1:license:aaa')
handlers['esx:playerLoaded'](1, players[1], true)
eq(money(1), 10500, 'new player cash')
eq(rows['char1:license:aaa'].amount, 10000, 'row stored')
eq(notes[#notes].message, 'Welkom! Je hebt 10.000 coins ontvangen.', 'welcome text')

-- Zelfde character nog een keer, ook als isNew per ongeluk true blijft: geen tweede keer.
local beforeNotes = noteCount()
handlers['esx:playerLoaded'](1, players[1], true)
eq(money(1), 10500, 'no double pay')
eq(noteCount(), beforeNotes, 'no second welcome')

-- Bestaande speler krijgt niks.
players[2] = xPlayer(2, 'char1:license:bbb')
players._age['char1:license:bbb'] = 86400
handlers['esx:playerLoaded'](2, players[2], false)
eq(money(2), 500, 'old player unchanged')
eq(rows['char1:license:bbb'], nil, 'old player no row')

-- Character van een paar seconden geleden, isNew ontbreekt: wel coins.
players[3] = xPlayer(3, 'char1:license:ccc')
players._age['char1:license:ccc'] = 20
handlers['esx:playerLoaded'](3, players[3], nil)
eq(money(3), 10500, 'recent fallback')

-- Tweede character van dezelfde license krijgt zelf ook 10000.
players[4] = xPlayer(4, 'char2:license:aaa')
handlers['esx:playerLoaded'](4, players[4], true)
eq(money(4), 10500, 'second character')
eq(rows['char2:license:aaa'] ~= nil, true, 'second character row')

-- Account bestaat niet: geen coins, claim wordt teruggedraaid.
Config.Account = 'coins'
players[5] = xPlayer(5, 'char1:license:ddd')
handlers['esx:playerLoaded'](5, players[5], true)
eq(money(5), 500, 'missing account no cash')
eq(rows['char1:license:ddd'], nil, 'claim rolled back')
Config.Account = 'money'

-- Na een mislukte poging alsnog geven.
handlers['esx:playerLoaded'](5, players[5], true)
eq(money(5), 10500, 'retry after rollback')

-- Speler zonder rechten.
players[6] = xPlayer(6, 'char1:license:eee', 'user')
commands.geefstartcoins(6, { '2' })
eq(notes[#notes].message, Config.Messages.noPermission, 'user blocked')
eq(money(2), 500, 'user could not pay old player')

-- Staff geeft de startcoins alsnog aan een oude speler, één keer.
players[7] = xPlayer(7, 'char1:license:fff', 'admin')
commands.geefstartcoins(7, { '2' })
eq(money(2), 10500, 'admin grant once')
commands.geefstartcoins(7, { '2' })
eq(money(2), 10500, 'admin second time blocked')
eq(notes[#notes].message, Config.Messages.already, 'already message')

-- force telt er nog 10000 bij.
commands.geefstartcoins(7, { '2', 'force' })
eq(money(2), 20500, 'admin force')

-- Export.
players[8] = xPlayer(8, 'char1:license:ggg')
local okExport = exportReg.GiveStartCoins(8, false)
eq(okExport, true, 'export ok')
eq(money(8), 10500, 'export paid')

if failures > 0 then
    io.stderr:write(('%d flow test(s) failed\n'):format(failures))
    os.exit(1)
end

print('snelle-startcoins flow tests: ok')
