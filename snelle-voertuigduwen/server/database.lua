Database = {}

local function hasOxMysql()
    return GetResourceState('oxmysql') == 'started'
end

local function hasMysqlAsync()
    return GetResourceState('mysql-async') == 'started'
end

function Database.IsEnabled()
    return Config.Database and Config.Database.enabled == true and (hasOxMysql() or hasMysqlAsync())
end

local function execute(query, params, cb)
    if not Database.IsEnabled() then
        if cb then cb(nil) end
        return
    end

    if hasOxMysql() then
        local ok = pcall(function()
            exports.oxmysql:execute(query, params or {}, cb)
        end)
        if ok then
            return
        end
    end

    if hasMysqlAsync() and MySQL and MySQL.Async then
        pcall(function()
            MySQL.Async.execute(query, params or {}, cb)
        end)
    end
end

local function insert(query, params, cb)
    if not Database.IsEnabled() then
        if cb then cb(nil) end
        return
    end

    if hasOxMysql() then
        local ok = pcall(function()
            exports.oxmysql:insert(query, params or {}, cb)
        end)
        if ok then
            return
        end
    end

    if hasMysqlAsync() and MySQL and MySQL.Async then
        pcall(function()
            MySQL.Async.insert(query, params or {}, cb)
        end)
    end
end

local function cleanText(value, maxLen)
    if type(value) ~= 'string' then
        return nil
    end

    value = value:gsub('^%s+', ''):gsub('%s+$', '')
    value = value:gsub('[%c]', '')
    if value == '' then
        return nil
    end

    return value:sub(1, maxLen or 32)
end

local function cleanNumber(value)
    local n = tonumber(value)
    if not n or n ~= n or n == math.huge or n == -math.huge then
        return nil
    end
    return n
end

function Database.LogPush(identifier, playerName, info)
    if not Database.IsEnabled() or not identifier or type(info) ~= 'table' then
        return
    end

    local mode = info.mode == 'aside' and 'aside' or 'manual'
    local result = cleanText(info.result, 32) or 'done'
    local plate = cleanText(info.plate, 12)
    local model = info.model and tostring(info.model):sub(1, 32) or nil
    local name = cleanText(playerName, 64)

    insert([[
        INSERT INTO snelle_voertuig_duwen
            (identifier, player_name, mode, result, plate, model, pos_x, pos_y, pos_z)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        identifier,
        name,
        mode,
        result,
        plate,
        model,
        cleanNumber(info.x),
        cleanNumber(info.y),
        cleanNumber(info.z)
    })

    if result ~= 'done' then
        return
    end

    execute([[
        INSERT INTO snelle_voertuig_duwen_stats
            (identifier, player_name, pushes, aside_count, manual_count)
        VALUES (?, ?, 1, ?, ?)
        ON DUPLICATE KEY UPDATE
            player_name = VALUES(player_name),
            pushes = pushes + 1,
            aside_count = aside_count + VALUES(aside_count),
            manual_count = manual_count + VALUES(manual_count)
    ]], {
        identifier,
        name,
        mode == 'aside' and 1 or 0,
        mode == 'manual' and 1 or 0
    })
end

CreateThread(function()
    if not (Config.Database and Config.Database.enabled) then
        print('[snelle-voertuigduwen] Database logging uit')
        return
    end

    local tries = 0
    while tries < 30 do
        if hasOxMysql() or hasMysqlAsync() then
            print(('[snelle-voertuigduwen] Database logging actief (%s)'):format(hasOxMysql() and 'oxmysql' or 'mysql-async'))
            return
        end
        tries = tries + 1
        Wait(1000)
    end

    print('[snelle-voertuigduwen] Database staat aan, maar oxmysql of mysql-async is niet gestart. Importeer sql/install.sql en start oxmysql vóór deze resource.')
end)
