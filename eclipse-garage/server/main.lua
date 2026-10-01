local ESX = nil
local ready = false
local schema = {
    stored = false,
    parking = false,
    pound = false,
    job = false
}
local busy = {}
local pending = {}
local spawned = {}
local lastAction = {}
local lastCall = {}

local function debugPrint(...)
    if Config.Debug then
        print('^3[eclipse-garage]^7', ...)
    end
end

local function loadESX()
    if ESX then
        return
    end
    if exports and exports['es_extended'] then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and obj then
            ESX = obj
            return
        end
    end
    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)
end

local function dbReady()
    return GetResourceState('oxmysql') == 'started'
end

local function dbFetch(query, params, cb)
    params = params or {}
    if not dbReady() then
        cb(nil)
        return
    end
    exports.oxmysql:query(query, params, function(result)
        cb(result)
    end)
end

local function dbInsert(query, params, cb)
    params = params or {}
    if not dbReady() then
        if cb then cb(nil) end
        return
    end
    exports.oxmysql:insert(query, params, function(id)
        if cb then cb(id) end
    end)
end

local function dbExecute(query, params, cb)
    params = params or {}
    if not dbReady() then
        if cb then cb(nil) end
        return
    end
    exports.oxmysql:update(query, params, function(affected)
        if cb then cb(affected) end
    end)
end

local function getPlayer(src)
    loadESX()
    if not ESX then
        return nil
    end
    return ESX.GetPlayerFromId(src)
end

local function notify(src, msg)
    TriggerClientEvent('eclipse-garage:client:notify', src, msg)
end

local function playerName(xPlayer, src)
    if xPlayer and xPlayer.getName then
        local ok, name = pcall(function()
            return xPlayer.getName()
        end)
        if ok and name and name ~= '' then
            return name
        end
    end
    return GetPlayerName(src) or 'Onbekend'
end

local function vecDist(a, b)
    if not a or not b then
        return 9999.0
    end
    local dx = (a.x or 0.0) - (b.x or 0.0)
    local dy = (a.y or 0.0) - (b.y or 0.0)
    local dz = (a.z or 0.0) - (b.z or 0.0)
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function playerCoords(src)
    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then
        return nil, ped
    end
    return GetEntityCoords(ped), ped
end

local function nearLocation(src, location, maxDist)
    if not location then
        return false
    end
    local coords = playerCoords(src)
    if not coords then
        return false
    end
    return vecDist(coords, location.coords) <= (maxDist or Config.ServerDistance)
end

local function nearSpawn(location, coords, maxDist)
    if not location or not coords or not location.spawns then
        return false
    end
    maxDist = maxDist or 20.0
    for i = 1, #location.spawns do
        if vecDist(coords, location.spawns[i]) <= maxDist then
            return true
        end
    end
    return false
end

local function validCoords(coords)
    if type(coords) ~= 'table' then
        return false
    end
    local x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
    if not x or not y or not z then
        return false
    end
    if x ~= x or y ~= y or z ~= z then
        return false
    end
    return true
end

local function isStored(value)
    return value == true or value == 1 or value == '1'
end

local function decodeProps(value)
    if type(value) == 'table' then
        return value
    end
    if type(value) ~= 'string' or value == '' then
        return {}
    end
    local ok, decoded = pcall(json.decode, value)
    if ok and type(decoded) == 'table' then
        return decoded
    end
    return {}
end

local function encodeProps(props)
    local ok, encoded = pcall(json.encode, props or {})
    if ok and type(encoded) == 'string' then
        return encoded
    end
    return nil
end

local function modelKey(model)
    if model == nil then
        return nil
    end
    if type(model) == 'number' then
        return model
    end
    local n = tonumber(model)
    if n then
        return n
    end
    if joaat then
        return joaat(tostring(model))
    end
    return nil
end

local function plateOfEntity(ent)
    if not ent or ent == 0 then
        return nil
    end
    local ok, plate = pcall(GetVehicleNumberPlateText, ent)
    if ok and type(plate) == 'string' and plate ~= '' then
        return plate
    end
    return nil
end

local function pedVehicle(ped)
    if not ped or ped == 0 then
        return 0
    end
    local ok, veh = pcall(GetVehiclePedIsIn, ped, false)
    if ok and type(veh) == 'number' then
        return veh
    end
    return 0
end

local function netEntity(netId)
    netId = tonumber(netId) or 0
    if netId == 0 then
        return 0
    end
    local ok, ent = pcall(NetworkGetEntityFromNetworkId, netId)
    if ok and type(ent) == 'number' then
        return ent
    end
    return 0
end

local function actionAllowed(src)
    local now = os.clock()
    if lastAction[src] and (now - lastAction[src]) < 0.8 then
        return false
    end
    lastAction[src] = now
    return true
end

local function charge(xPlayer, amount, reason)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then
        return true, 'free', 0
    end
    local cash = 0
    if xPlayer.getMoney then
        cash = xPlayer.getMoney() or 0
    end
    if cash >= amount then
        xPlayer.removeMoney(amount, reason)
        return true, 'money', amount
    end
    local bank = xPlayer.getAccount and xPlayer.getAccount('bank')
    if bank and (bank.money or 0) >= amount then
        xPlayer.removeAccountMoney('bank', amount, reason)
        return true, 'bank', amount
    end
    return false, nil, amount
end

local function refund(src, amount, account, reason)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 or account == 'free' or account == nil then
        return
    end
    local xPlayer = getPlayer(src)
    if not xPlayer then
        return
    end
    if account == 'bank' and xPlayer.addAccountMoney then
        xPlayer.addAccountMoney('bank', amount, reason)
        return
    end
    if xPlayer.addMoney then
        xPlayer.addMoney(amount, reason)
    end
end

local function addSociety(amount)
    amount = math.floor(tonumber(amount) or 0)
    local account = Config.ImpoundSociety
    if not account or account == '' or amount <= 0 then
        return
    end
    if GetResourceState('esx_addonaccount') == 'started' then
        TriggerEvent('esx_addonaccount:getSharedAccount', account, function(shared)
            if shared and shared.addMoney then
                shared.addMoney(amount)
            end
        end)
        return
    end
    dbExecute(
        'UPDATE addon_account_data SET money = money + ? WHERE account_name = ?',
        { amount, account }
    )
end

local function logAction(ident, name, action, plate, location, amount)
    dbExecute(
        [[INSERT INTO eclipse_garage_log (identifier, player_name, action, plate, location, amount)
          VALUES (?, ?, ?, ?, ?, ?)]],
        { ident or '', name or '', action or '', plate or '', location or '', math.floor(tonumber(amount) or 0) }
    )
end

local function moneySnapshot(xPlayer)
    local cash, bank = 0, 0
    if xPlayer.getMoney then
        cash = xPlayer.getMoney() or 0
    end
    local account = xPlayer.getAccount and xPlayer.getAccount('bank')
    if account then
        bank = account.money or 0
    end
    return cash, bank
end

local function jobAllowed(xPlayer)
    if not xPlayer or not xPlayer.job or not xPlayer.job.name then
        return false
    end
    local name = string.lower(tostring(xPlayer.job.name))
    return Config.ImpoundJobs and Config.ImpoundJobs[name] == true
end

local function staffAllowed(src, xPlayer)
    if Config.ImpoundAce and Config.ImpoundAce ~= '' then
        local ok, allowed = pcall(IsPlayerAceAllowed, src, Config.ImpoundAce)
        if ok and allowed then
            return true
        end
    end
    return jobAllowed(xPlayer)
end

local function columnSql()
    local cols = { 'owner', 'plate', 'vehicle', 'type' }
    if schema.stored then
        cols[#cols + 1] = 'stored'
    end
    if schema.parking then
        cols[#cols + 1] = 'parking'
    end
    if schema.pound then
        cols[#cols + 1] = 'pound'
    end
    if schema.job then
        cols[#cols + 1] = 'job'
    end
    return table.concat(cols, ', ')
end

local function plateWhere()
    return "UPPER(REPLACE(plate, ' ', '')) = ?"
end

local function ensureSchema(done)
    local function columnExists(name, cb)
        dbFetch(('SELECT `%s` FROM owned_vehicles LIMIT 1'):format(name), {}, function(rows)
            cb(rows ~= nil)
        end)
    end

    dbFetch([[CREATE TABLE IF NOT EXISTS `mallorca_impound` (
        `id` INT NOT NULL AUTO_INCREMENT,
        `plate` VARCHAR(12) NOT NULL,
        `owner` VARCHAR(64) DEFAULT NULL,
        `props` LONGTEXT NOT NULL,
        `reason` VARCHAR(128) NOT NULL DEFAULT 'In beslag genomen',
        `officer` VARCHAR(64) DEFAULT NULL,
        `officer_name` VARCHAR(80) DEFAULT NULL,
        `price` INT NOT NULL DEFAULT 1500,
        `model` VARCHAR(64) DEFAULT NULL,
        `impounded_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (`id`),
        KEY `plate` (`plate`),
        KEY `owner` (`owner`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]], {}, function()
        dbFetch([[CREATE TABLE IF NOT EXISTS `eclipse_garage_log` (
            `id` INT NOT NULL AUTO_INCREMENT,
            `identifier` VARCHAR(80) NOT NULL,
            `player_name` VARCHAR(64) DEFAULT NULL,
            `action` VARCHAR(24) NOT NULL,
            `plate` VARCHAR(16) DEFAULT NULL,
            `location` VARCHAR(64) DEFAULT NULL,
            `amount` INT NOT NULL DEFAULT 0,
            `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]], {}, function()
            local function addColumn(name, ddl, nextStep)
                columnExists(name, function(exists)
                    if exists then
                        schema[name] = true
                        nextStep()
                        return
                    end
                    dbFetch(ddl, {}, function()
                        columnExists(name, function(now)
                            schema[name] = now
                            if not now then
                                print(('^1[eclipse-garage]^7 Kolom owned_vehicles.%s ontbreekt.'):format(name))
                            end
                            nextStep()
                        end)
                    end)
                end)
            end

            addColumn('stored', 'ALTER TABLE owned_vehicles ADD COLUMN `stored` TINYINT(1) NOT NULL DEFAULT 1', function()
                addColumn('parking', 'ALTER TABLE owned_vehicles ADD COLUMN `parking` VARCHAR(60) DEFAULT NULL', function()
                    addColumn('pound', 'ALTER TABLE owned_vehicles ADD COLUMN `pound` VARCHAR(60) DEFAULT NULL', function()
                        columnExists('job', function(exists)
                            schema.job = exists
                            done()
                        end)
                    end)
                end)
            end)
        end)
    end)
end

local function playerIdents(src, xPlayer)
    local list = {}
    if xPlayer and type(xPlayer.identifier) == 'string' then
        list[#list + 1] = xPlayer.identifier
    end
    local count = 0
    if GetNumPlayerIdentifiers then
        count = GetNumPlayerIdentifiers(src) or 0
    end
    for i = 0, count - 1 do
        local ident = GetPlayerIdentifier(src, i)
        list[#list + 1] = ident
        if type(ident) == 'string' then
            local bare = EclipseOwner.bare(ident)
            if bare ~= '' and bare ~= ident:lower() then
                list[#list + 1] = bare
            end
        end
    end
    if xPlayer and type(xPlayer.identifier) == 'string' then
        local bare = EclipseOwner.bare(xPlayer.identifier)
        if bare ~= '' then
            list[#list + 1] = bare
        end
    end
    return EclipseOwner.unique(list)
end

local function fetchOwned(ident, cb)
    dbFetch('SELECT ' .. columnSql() .. ' FROM owned_vehicles WHERE owner = ?', { ident }, function(rows)
        cb(rows)
    end)
end

local function fetchOwnedMany(idents, cb)
    if not idents or #idents == 0 then
        cb({})
        return
    end
    local marks = {}
    for i = 1, #idents do
        marks[i] = '?'
    end
    dbFetch(
        'SELECT ' .. columnSql() .. ' FROM owned_vehicles WHERE owner IN (' .. table.concat(marks, ', ') .. ')',
        idents,
        function(rows)
            cb(rows)
        end
    )
end

local function fetchOwnedPlate(ident, plateKey, cb)
    dbFetch(
        'SELECT ' .. columnSql() .. ' FROM owned_vehicles WHERE owner = ? AND ' .. plateWhere(),
        { ident, plateKey },
        function(rows)
            if rows == nil then
                cb(false)
                return
            end
            cb(rows[1])
        end
    )
end

local function fetchPlate(plateKey, cb)
    dbFetch(
        'SELECT ' .. columnSql() .. ' FROM owned_vehicles WHERE ' .. plateWhere() .. ' LIMIT 1',
        { plateKey },
        function(rows)
            if rows == nil then
                cb(nil, true)
                return
            end
            cb(rows[1], false)
        end
    )
end

local function fetchImpounds(ident, cb)
    dbFetch(
        [[SELECT i.* FROM mallorca_impound i
          INNER JOIN owned_vehicles o
            ON UPPER(REPLACE(o.plate, ' ', '')) = UPPER(REPLACE(i.plate, ' ', ''))
          WHERE o.owner = ?
          ORDER BY i.id DESC]],
        { ident },
        function(rows)
            cb(rows)
        end
    )
end

local function indexImpounds(rows)
    local map = {}
    for i = 1, #(rows or {}) do
        local row = rows[i]
        local key = Config.NormalizePlate(row.plate)
        local prev = map[key]
        if key ~= '' and (not prev or (tonumber(row.id) or 0) > (tonumber(prev.id) or 0)) then
            map[key] = row
        end
    end
    return map
end

local function vehicleState(row, impound)
    if impound then
        return 'impound'
    end
    if schema.pound and type(row.pound) == 'string' and row.pound ~= '' then
        return 'impound'
    end
    if not schema.stored or isStored(row.stored) then
        return 'garage'
    end
    return 'out'
end

local function entryFromRow(row, impound, mode, location)
    local props = decodeProps(row.vehicle)
    if impound and impound.props then
        local impoundProps = decodeProps(impound.props)
        if next(impoundProps) ~= nil then
            props = impoundProps
        end
    end
    local state = vehicleState(row, impound)
    local price = 0
    local reason = nil
    if state == 'impound' then
        price = 0
        reason = (impound and impound.reason) or 'In de impound'
    elseif state == 'out' then
        price = 0
        reason = 'Staat buiten of is vermist'
    elseif mode == 'call' then
        price = tonumber(Config.Call.price) or Config.Prices.call or 0
    end

    local here = true
    if mode == 'garage' and state == 'garage' and not Config.ShareGarages then
        local parking = row.parking
        here = parking == nil or parking == '' or parking == (location and location.id)
        if not here then
            reason = 'Staat in een andere garage'
        end
    end

    return {
        plate = row.plate,
        plateKey = Config.NormalizePlate(row.plate),
        type = row.type or 'car',
        state = state,
        price = price,
        reason = reason,
        here = here,
        model = props.model,
        engine = props.engineHealth,
        body = props.bodyHealth,
        fuel = props.fuelLevel,
        parking = row.parking
    }
end

local function includeEntry(entry, mode, location)
    if mode == 'call' then
        return Config.CallAllowed(entry.type)
    end
    if not location or not Config.SameType(location.type, entry.type) then
        return false
    end
    if mode == 'impound' then
        return entry.state == 'impound' or (entry.state == 'out' and Config.RecoverOutVehicles)
    end
    return true
end

local function sendList(src, payload, cbToken)
    local xPlayer = getPlayer(src)
    if not xPlayer then
        return
    end
    local mode = payload and payload.mode or 'garage'
    local location = nil
    if mode == 'garage' then
        location = Config.FindGarage(payload.locationId)
        if not location or not nearLocation(src, location, Config.ServerDistance + 6.0) then
            notify(src, Config.Text.notHere)
            TriggerClientEvent('eclipse-garage:client:close', src)
            return
        end
    elseif mode == 'impound' then
        location = Config.FindImpound(payload.locationId)
        if not location or not nearLocation(src, location, Config.ServerDistance + 6.0) then
            notify(src, Config.Text.notImpound)
            TriggerClientEvent('eclipse-garage:client:close', src)
            return
        end
    elseif mode == 'call' then
        if not Config.Call.enabled then
            notify(src, Config.Text.callOff)
            TriggerClientEvent('eclipse-garage:client:close', src)
            return
        end
    else
        return
    end

    local ident = xPlayer.identifier
    local idents = playerIdents(src, xPlayer)
    fetchOwnedMany(idents, function(rows)
        if rows == nil then
            notify(src, Config.Text.dbDown)
            TriggerClientEvent('eclipse-garage:client:close', src)
            return
        end
        fetchImpounds(ident, function(impoundRows)
            if impoundRows == nil then
                notify(src, Config.Text.dbDown)
                TriggerClientEvent('eclipse-garage:client:close', src)
                return
            end
            local map = indexImpounds(impoundRows)
            local list = {}
            for i = 1, #rows do
                local row = rows[i]
                if Config.IncludeJobVehicles or Config.IsPersonalVehicle(row.job) then
                    local key = Config.NormalizePlate(row.plate)
                    local entry = entryFromRow(row, map[key], mode, location)
                    if includeEntry(entry, mode, location) then
                        list[#list + 1] = entry
                    end
                end
            end
            local cash, bank = moneySnapshot(xPlayer)
            local subtitle = 'Kies een voertuig om op te roepen'
            if mode == 'impound' then
                subtitle = 'Haal een voertuig gratis uit de impound'
            elseif mode == 'call' then
                subtitle = 'Het voertuig wordt bij je in de buurt gezet'
            end
            TriggerClientEvent('eclipse-garage:client:open', src, {
                token = cbToken,
                mode = mode,
                title = location and location.label or 'Voertuig oproepen',
                subtitle = subtitle,
                vehicles = list,
                cash = cash,
                bank = bank
            })
        end)
    end)
end

local function clearPending(token)
    local ticket = pending[token]
    pending[token] = nil
    if ticket then
        busy[ticket.plateKey] = nil
    end
    return ticket
end

local function revertTicket(token, tell)
    local ticket = clearPending(token)
    if not ticket then
        return
    end
    local sets = {}
    local params = {}
    if schema.stored then
        sets[#sets + 1] = 'stored = ?'
        params[#params + 1] = ticket.restoreStored
    end
    if schema.parking then
        sets[#sets + 1] = 'parking = ?'
        params[#params + 1] = ticket.restoreParking
    end
    if schema.pound then
        if ticket.restorePound and ticket.restorePound ~= '' then
            sets[#sets + 1] = 'pound = ?'
            params[#params + 1] = ticket.restorePound
        else
            sets[#sets + 1] = 'pound = NULL'
        end
    end
    if #sets > 0 then
        params[#params + 1] = ticket.plateKey
        dbExecute(
            'UPDATE owned_vehicles SET ' .. table.concat(sets, ', ') .. ' WHERE UPPER(REPLACE(plate, \' \', \'\')) = ?',
            params
        )
    end
    local impound = ticket.impound
    if impound then
        dbExecute(
            [[INSERT INTO mallorca_impound (plate, owner, props, reason, officer, officer_name, price, model)
              VALUES (?, ?, ?, ?, ?, ?, ?, ?)]],
            {
                impound.plate,
                impound.owner,
                impound.props or '{}',
                impound.reason or 'In beslag genomen',
                impound.officer,
                impound.officer_name,
                tonumber(impound.price) or Config.Prices.impound,
                impound.model
            }
        )
    end
    refund(ticket.src, ticket.amount, ticket.account, 'eclipse-garage-refund')
    if tell then
        notify(ticket.src, tell)
    end
end

local function markOut(plateKey, cb)
    local sets = {}
    local params = {}
    if schema.stored then
        sets[#sets + 1] = 'stored = 0'
    end
    if schema.parking then
        sets[#sets + 1] = 'parking = NULL'
    end
    if schema.pound then
        sets[#sets + 1] = 'pound = NULL'
    end
    if #sets == 0 then
        cb(true)
        return
    end
    params[1] = plateKey
    dbExecute(
        'UPDATE owned_vehicles SET ' .. table.concat(sets, ', ') .. ' WHERE UPPER(REPLACE(plate, \' \', \'\')) = ?',
        params,
        function(affected)
            cb(affected ~= nil)
        end
    )
end

local function deleteImpound(plateKey, cb)
    dbExecute(
        [[DELETE FROM mallorca_impound WHERE UPPER(REPLACE(plate, ' ', '')) = ?]],
        { plateKey },
        function()
            if cb then cb() end
        end
    )
end

RegisterNetEvent('eclipse-garage:server:list', function(payload)
    local src = source
    if not ready then
        notify(src, Config.Text.dbDown)
        TriggerClientEvent('eclipse-garage:client:close', src)
        return
    end
    payload = payload or {}
    sendList(src, payload, payload.token)
end)

RegisterNetEvent('eclipse-garage:server:spawn', function(payload)
    local src = source
    if not ready then
        notify(src, Config.Text.dbDown)
        TriggerClientEvent('eclipse-garage:client:idle', src)
        return
    end
    if not actionAllowed(src) then
        notify(src, Config.Text.tooFast)
        TriggerClientEvent('eclipse-garage:client:idle', src)
        return
    end

    payload = payload or {}
    local mode = payload.mode
    local plateKey = Config.NormalizePlate(payload.plate)
    local coords = payload.coords
    if plateKey == '' or not validCoords(coords) then
        TriggerClientEvent('eclipse-garage:client:idle', src)
        return
    end

    local xPlayer = getPlayer(src)
    if not xPlayer then
        return
    end

    local location = nil
    if mode == 'call' then
        if not Config.Call.enabled then
            notify(src, Config.Text.callOff)
            TriggerClientEvent('eclipse-garage:client:idle', src)
            return
        end
        local pcoords, ped = playerCoords(src)
        if not pcoords then
            return
        end
        if vecDist(pcoords, coords) > (Config.Call.maxDistance or 35.0) then
            notify(src, Config.Text.notHere)
            TriggerClientEvent('eclipse-garage:client:idle', src)
            return
        end
        local current = pedVehicle(ped)
        if current ~= 0 then
            notify(src, Config.Text.inVehicleCall)
            TriggerClientEvent('eclipse-garage:client:idle', src)
            return
        end
        local waited = os.time() - (lastCall[src] or 0)
        if waited < (Config.Call.cooldown or 20) then
            notify(src, Config.Text.cooldown)
            TriggerClientEvent('eclipse-garage:client:idle', src)
            return
        end
    elseif mode == 'garage' then
        location = Config.FindGarage(payload.locationId)
        if not location or not nearLocation(src, location) or not nearSpawn(location, coords) then
            notify(src, Config.Text.notHere)
            TriggerClientEvent('eclipse-garage:client:idle', src)
            return
        end
    elseif mode == 'impound' then
        location = Config.FindImpound(payload.locationId)
        if not location or not nearLocation(src, location) or not nearSpawn(location, coords) then
            notify(src, Config.Text.notImpound)
            TriggerClientEvent('eclipse-garage:client:idle', src)
            return
        end
    else
        TriggerClientEvent('eclipse-garage:client:idle', src)
        return
    end

    if busy[plateKey] then
        notify(src, Config.Text.busy)
        TriggerClientEvent('eclipse-garage:client:idle', src)
        return
    end
    busy[plateKey] = src

    local function unlock()
        if busy[plateKey] == src then
            busy[plateKey] = nil
        end
    end

    local function deny(msg)
        unlock()
        notify(src, msg)
        TriggerClientEvent('eclipse-garage:client:idle', src)
    end

    fetchPlate(plateKey, function(row, failed)
        if failed then
            deny(Config.Text.dbDown)
            return
        end
        if not row or not EclipseOwner.same(row.owner, playerIdents(src, xPlayer)) then
            deny(Config.Text.notOwner)
            return
        end
        if location and not Config.SameType(location.type, row.type) then
            deny(Config.Text.wrongType)
            return
        end
        if mode == 'call' and not Config.CallAllowed(row.type) then
            deny(Config.Text.wrongType)
            return
        end

        fetchImpounds(xPlayer.identifier, function(impoundRows)
            if impoundRows == nil then
                deny(Config.Text.dbDown)
                return
            end
            xPlayer = getPlayer(src)
            if not xPlayer then
                unlock()
                return
            end
            local impound = indexImpounds(impoundRows)[plateKey]
            local state = vehicleState(row, impound)
            local price = 0
            local action = 'spawn'

            if mode == 'garage' or mode == 'call' then
                if state == 'impound' then
                    deny(Config.Text.impounded)
                    return
                end
                if state ~= 'garage' then
                    deny(Config.Text.alreadyOut)
                    return
                end
                if mode == 'garage' and not Config.ShareGarages then
                    local parking = row.parking
                    if parking and parking ~= '' and parking ~= location.id then
                        deny(Config.Text.otherGarage)
                        return
                    end
                end
                if mode == 'call' then
                    price = tonumber(Config.Call.price) or Config.Prices.call or 0
                    action = 'call'
                end
            elseif mode == 'impound' then
                if state == 'impound' then
                    price = 0
                    action = 'impound'
                elseif state == 'out' and Config.RecoverOutVehicles then
                    price = 0
                    action = 'recover'
                else
                    deny(Config.Text.notStored)
                    return
                end
            end

            local paid, account, amount = charge(xPlayer, price, 'eclipse-garage-' .. action)
            if not paid then
                deny(Config.Text.noMoney)
                return
            end

            markOut(plateKey, function(ok)
                if not ok then
                    refund(src, amount, account, 'eclipse-garage-refund')
                    deny(Config.Text.dbDown)
                    return
                end

                local function finish()
                    local token = ('%s:%s:%s'):format(plateKey, src, math.random(100000, 999999))
                    local props = decodeProps(row.vehicle)
                    if impound and impound.props then
                        local latest = decodeProps(impound.props)
                        if next(latest) ~= nil then
                            props = latest
                        end
                    end
                    props.plate = row.plate
                    pending[token] = {
                        src = src,
                        plateKey = plateKey,
                        plate = row.plate,
                        amount = amount,
                        account = account,
                        restoreStored = schema.stored and (isStored(row.stored) and 1 or 0) or 1,
                        restoreParking = row.parking,
                        restorePound = row.pound,
                        impound = impound,
                        society = (action == 'impound' or action == 'recover') and amount or 0,
                        action = action,
                        ident = xPlayer.identifier,
                        name = playerName(xPlayer, src),
                        location = payload.locationId
                    }
                    if mode == 'call' then
                        lastCall[src] = os.time()
                    end
                    TriggerClientEvent('eclipse-garage:client:spawn', src, {
                        token = token,
                        plate = row.plate,
                        props = props,
                        coords = {
                            x = tonumber(coords.x),
                            y = tonumber(coords.y),
                            z = tonumber(coords.z),
                            w = tonumber(coords.w) or 0.0
                        },
                        mode = mode
                    })
                    SetTimeout(25000, function()
                        if pending[token] then
                            revertTicket(token, Config.Text.modelFail)
                            TriggerClientEvent('eclipse-garage:client:idle', src)
                        end
                    end)
                end

                if impound or (schema.pound and type(row.pound) == 'string' and row.pound ~= '') then
                    deleteImpound(plateKey, finish)
                else
                    finish()
                end
            end)
        end)
    end)
end)

RegisterNetEvent('eclipse-garage:server:spawned', function(token, netId)
    local src = source
    local ticket = pending[token]
    if not ticket or ticket.src ~= src then
        return
    end
    clearPending(token)
    spawned[ticket.plateKey] = {
        src = src,
        netId = tonumber(netId) or 0
    }
    if (ticket.society or 0) > 0 then
        addSociety(ticket.society)
    end
    logAction(ticket.ident, ticket.name, ticket.action, ticket.plate, ticket.location, ticket.amount)
end)

RegisterNetEvent('eclipse-garage:server:spawnFailed', function(token)
    local src = source
    local ticket = pending[token]
    if not ticket or ticket.src ~= src then
        return
    end
    revertTicket(token, Config.Text.modelFail)
end)

local function saveStored(plateKey, propsJson, parking, cb)
    local sets = { 'vehicle = ?' }
    local params = { propsJson }
    if schema.stored then
        sets[#sets + 1] = 'stored = 1'
    end
    if schema.parking then
        sets[#sets + 1] = 'parking = ?'
        params[#params + 1] = parking
    end
    if schema.pound then
        sets[#sets + 1] = 'pound = NULL'
    end
    params[#params + 1] = plateKey
    dbExecute(
        'UPDATE owned_vehicles SET ' .. table.concat(sets, ', ') .. ' WHERE UPPER(REPLACE(plate, \' \', \'\')) = ?',
        params,
        function(affected)
            cb(affected ~= nil)
        end
    )
end

RegisterNetEvent('eclipse-garage:server:store', function(payload)
    local src = source
    if not ready then
        notify(src, Config.Text.dbDown)
        return
    end
    if not actionAllowed(src) then
        notify(src, Config.Text.tooFast)
        return
    end
    payload = payload or {}
    local plateKey = Config.NormalizePlate(payload.plate)
    local location = Config.FindGarage(payload.locationId)
    if plateKey == '' or not location or not nearLocation(src, location, Config.StoreDistance + 4.0) then
        notify(src, Config.Text.notHere)
        return
    end

    local xPlayer = getPlayer(src)
    if not xPlayer then
        notify(src, Config.Text.dbDown)
        return
    end

    local _, ped = playerCoords(src)
    local veh = 0
    if ped and ped ~= 0 then
        veh = pedVehicle(ped)
    end
    if veh == 0 then
        veh = netEntity(payload.netId)
    end
    if veh ~= 0 then
        local actual = plateOfEntity(veh)
        if actual and Config.NormalizePlate(actual) ~= plateKey then
            notify(src, Config.Text.plateMismatch)
            return
        end
        local seatOk, driver = pcall(GetPedInVehicleSeat, veh, -1)
        if seatOk and driver and driver ~= 0 and ped and ped ~= 0 and driver ~= ped then
            notify(src, Config.Text.notDriver)
            return
        end
    end

    if busy[plateKey] then
        notify(src, Config.Text.busy)
        return
    end
    busy[plateKey] = src

    local idents = playerIdents(src, xPlayer)
    local displayPlate = tostring(payload.plate or ''):upper():gsub('^%s+', ''):gsub('%s+$', '')
    if #displayPlate > 12 then
        displayPlate = displayPlate:sub(1, 12)
    end

    local function release()
        if busy[plateKey] == src then
            busy[plateKey] = nil
        end
    end

    local function parked(plate, message)
        release()
        spawned[plateKey] = nil
        logAction(xPlayer.identifier, playerName(xPlayer, src), 'store', plate, location.id, 0)
        TriggerClientEvent('eclipse-garage:client:stored', src, {
            plate = plate,
            netId = tonumber(payload.netId) or 0,
            message = message
        })
    end

    local function claim(props)
        if not props.model then
            release()
            notify(src, Config.Text.modelFail)
            return
        end
        props.plate = displayPlate
        local encoded = encodeProps(props)
        if not encoded then
            release()
            notify(src, Config.Text.dbDown)
            return
        end
        local cols = { '`owner`', '`plate`', '`vehicle`', '`type`' }
        local marks = { '?', '?', '?', '?' }
        local params = { xPlayer.identifier, displayPlate, encoded, 'car' }
        if schema.stored then
            cols[#cols + 1] = '`stored`'
            marks[#marks + 1] = '?'
            params[#params + 1] = 1
        end
        if schema.parking then
            cols[#cols + 1] = '`parking`'
            marks[#marks + 1] = '?'
            params[#params + 1] = location.id
        end
        if schema.job then
            cols[#cols + 1] = '`job`'
            marks[#marks + 1] = '?'
            params[#params + 1] = ''
        end
        dbInsert(
            'INSERT INTO owned_vehicles (' .. table.concat(cols, ', ') .. ') VALUES (' .. table.concat(marks, ', ') .. ')',
            params,
            function(insertId)
                if insertId == nil then
                    release()
                    notify(src, Config.Text.dbDown)
                    return
                end
                parked(displayPlate, Config.Text.storedNew)
            end
        )
    end

    fetchPlate(plateKey, function(row, failed)
        if failed then
            release()
            notify(src, Config.Text.dbDown)
            return
        end

        local incoming = decodeProps(payload.props)
        if not row then
            claim(incoming)
            return
        end
        if not EclipseOwner.same(row.owner, idents) then
            release()
            notify(src, Config.Text.notOwner)
            return
        end
        if not Config.SameType(location.type, row.type) then
            release()
            notify(src, Config.Text.wrongType)
            return
        end
        if schema.pound and type(row.pound) == 'string' and row.pound ~= '' then
            release()
            notify(src, Config.Text.impounded)
            return
        end

        dbFetch(
            [[SELECT id FROM mallorca_impound WHERE UPPER(REPLACE(plate, ' ', '')) = ? LIMIT 1]],
            { plateKey },
            function(impoundRows)
                if impoundRows == nil then
                    release()
                    notify(src, Config.Text.dbDown)
                    return
                end
                if impoundRows[1] then
                    release()
                    notify(src, Config.Text.impounded)
                    return
                end

                local current = decodeProps(row.vehicle)
                local currentModel = modelKey(current.model)
                local incomingModel = modelKey(incoming.model)
                if currentModel and incomingModel and currentModel ~= incomingModel then
                    release()
                    notify(src, Config.Text.plateMismatch)
                    return
                end
                if next(incoming) == nil then
                    incoming = current
                end
                incoming.plate = row.plate
                if not incoming.model then
                    incoming.model = current.model
                end
                local encoded = encodeProps(incoming)
                if not encoded then
                    release()
                    notify(src, Config.Text.dbDown)
                    return
                end

                saveStored(plateKey, encoded, location.id, function(ok)
                    if not ok then
                        release()
                        notify(src, Config.Text.dbDown)
                        return
                    end
                    parked(row.plate)
                end)
            end
        )
    end)
end)

local function impoundOwned(src, xPlayer, row, props, reason, onDone)
    local plateKey = Config.NormalizePlate(row.plate)
    local encoded = encodeProps(props)
    if not encoded then
        encoded = row.vehicle or '{}'
    end
    local officer = xPlayer.identifier
    local officerName = playerName(xPlayer, src)
    local price = 0
    local model = tostring(props.model or '')

    dbInsert(
        [[INSERT INTO mallorca_impound (plate, owner, props, reason, officer, officer_name, price, model)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?)]],
        { row.plate, row.owner or xPlayer.identifier, encoded, reason, officer, officerName, price, model },
        function(insertId)
            if not insertId then
                busy[plateKey] = nil
                notify(src, Config.Text.dbDown)
                if onDone then onDone(false) end
                return
            end
            dbExecute(
                [[DELETE FROM mallorca_impound
                  WHERE UPPER(REPLACE(plate, ' ', '')) = ? AND id <> ?]],
                { plateKey, insertId }
            )
            local sets = {}
                    local params = {}
                    if schema.stored then
                        sets[#sets + 1] = 'stored = 1'
                    end
                    if schema.parking then
                        sets[#sets + 1] = 'parking = NULL'
                    end
                    if schema.pound then
                        sets[#sets + 1] = 'pound = ?'
                        params[#params + 1] = 'impound'
                    end
                    local function afterUpdate()
                        spawned[plateKey] = nil
                        busy[plateKey] = nil
                        logAction(officer, officerName, 'staff_impound', row.plate, reason, price)
                        notify(src, Config.Text.staffDone)
                        local players = GetPlayers()
                        for i = 1, #players do
                            local id = tonumber(players[i])
                            local target = id and getPlayer(id)
                            if target and target.identifier == row.owner and id ~= src then
                                notify(id, Config.Text.ownerImpounded:format(row.plate))
                            end
                        end
                        if onDone then onDone(true) end
                    end
                    if #sets == 0 then
                        afterUpdate()
                        return
                    end
                    params[#params + 1] = plateKey
                    dbExecute(
                        'UPDATE owned_vehicles SET ' .. table.concat(sets, ', ') .. ' WHERE UPPER(REPLACE(plate, \' \', \'\')) = ?',
                        params,
                        afterUpdate
                    )
        end
    )
end

RegisterNetEvent('eclipse-garage:server:staffImpound', function(payload)
    local src = source
    if not ready then
        notify(src, Config.Text.dbDown)
        return
    end
    local xPlayer = getPlayer(src)
    if not xPlayer or not staffAllowed(src, xPlayer) then
        notify(src, Config.Text.staffDenied)
        return
    end
    payload = payload or {}
    local plateKey = Config.NormalizePlate(payload.plate)
    if plateKey == '' then
        notify(src, Config.Text.noVehicle)
        return
    end

    local _, ped = playerCoords(src)
    local netId = tonumber(payload.netId) or 0
    local veh = netEntity(netId)
    if not ped or veh == 0 then
        notify(src, Config.Text.noVehicle)
        return
    end
    local dist = vecDist(GetEntityCoords(ped), GetEntityCoords(veh))
    if dist > 12.0 then
        notify(src, Config.Text.noVehicle)
        return
    end
    local actual = plateOfEntity(veh)
    if actual and Config.NormalizePlate(actual) ~= plateKey then
        notify(src, Config.Text.plateMismatch)
        return
    end

    local reason = tostring(payload.reason or 'In beslag genomen'):sub(1, 120)
    if reason == '' then
        reason = 'In beslag genomen'
    end

    if busy[plateKey] then
        notify(src, Config.Text.busy)
        return
    end
    busy[plateKey] = src

    fetchPlate(plateKey, function(row, failed)
        if failed then
            busy[plateKey] = nil
            notify(src, Config.Text.dbDown)
            return
        end
        if not row then
            busy[plateKey] = nil
            notify(src, Config.Text.staffNpc)
            TriggerClientEvent('eclipse-garage:client:stored', src, {
                plate = payload.plate,
                netId = netId,
                quiet = true
            })
            return
        end
        local props = decodeProps(payload.props)
        if next(props) == nil then
            props = decodeProps(row.vehicle)
        end
        props.plate = row.plate
        impoundOwned(src, xPlayer, row, props, reason, function(ok)
            if not ok then
                return
            end
            TriggerClientEvent('eclipse-garage:client:stored', src, {
                plate = row.plate,
                netId = netId,
                quiet = true
            })
        end)
    end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    lastAction[src] = nil
    lastCall[src] = nil
    for token, ticket in pairs(pending) do
        if ticket.src == src then
            revertTicket(token, nil)
        end
    end
    for plateKey, lockSrc in pairs(busy) do
        if lockSrc == src then
            busy[plateKey] = nil
        end
    end
end)

CreateThread(function()
    loadESX()
    local tries = 0
    while not dbReady() and tries < 30 do
        tries = tries + 1
        Wait(500)
    end
    if not dbReady() then
        print('^1[eclipse-garage]^7 oxmysql niet gevonden. Zet ensure oxmysql vóór eclipse-garage.')
        return
    end
    while not ESX and tries < 40 do
        loadESX()
        tries = tries + 1
        Wait(250)
    end
    ensureSchema(function()
        ready = true
        print('^2[eclipse-garage]^7 Garage en impound gestart.')
    end)
end)
