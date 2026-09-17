Database = {}

local ready = false

local function hasOxMysql()
    return GetResourceState('oxmysql') == 'started'
end

local function hasMysqlAsync()
    return GetResourceState('mysql-async') == 'started'
end

function Database.IsEnabled()
    return Config.Database and Config.Database.enabled == true and (hasOxMysql() or hasMysqlAsync())
end

function Database.GetIdentifier(source)
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:find('license:') then
            return id
        end
    end
    return GetPlayerIdentifier(source, 0)
end

local function execute(query, params, cb)
    if hasOxMysql() then
        exports.oxmysql:execute(query, params or {}, cb)
        return
    end

    if hasMysqlAsync() then
        MySQL.Async.execute(query, params or {}, cb)
    end
end

local function insert(query, params, cb)
    if hasOxMysql() then
        exports.oxmysql:insert(query, params or {}, cb)
        return
    end

    if hasMysqlAsync() then
        MySQL.Async.insert(query, params or {}, cb)
    end
end

function Database.SaveEvent(event, winnerSource)
    if not Database.IsEnabled() or not event then return end

    local winnerIdentifier = nil
    local winnerName = nil
    if winnerSource then
        winnerIdentifier = Database.GetIdentifier(winnerSource)
        winnerName = Permissions.GetPlayerName(winnerSource)
    end

    local hostIdentifier = event.hostId and Database.GetIdentifier(event.hostId) or nil

    insert([[
        INSERT INTO snelle_events
            (event_id, name, type, host_identifier, host_name, status, max_players, player_count,
             coords_x, coords_y, coords_z, winner_identifier, winner_name, started_at, ended_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, FROM_UNIXTIME(?), NOW())
    ]], {
        event.id,
        event.name,
        event.type,
        hostIdentifier,
        event.hostName,
        event.status or 'ended',
        event.maxPlayers,
        #(event.players or {}),
        event.coords and event.coords.x or nil,
        event.coords and event.coords.y or nil,
        event.coords and event.coords.z or nil,
        winnerIdentifier,
        winnerName,
        event.startedAt or os.time()
    }, function(insertId)
        if not insertId then return end

        for _, playerId in ipairs(event.players or {}) do
            local score = event.scores and event.scores[playerId] or {}
            local identifier = Database.GetIdentifier(playerId)
            local isWinner = winnerSource == playerId
            local reward = 0

            if isWinner and Config.Rewards and Config.Rewards.winner then
                reward = Config.Rewards.winner.money or 0
            elseif Config.Rewards and Config.Rewards.participant then
                reward = Config.Rewards.participant.money or 0
            end

            execute([[
                INSERT INTO snelle_event_players
                    (event_db_id, event_id, identifier, player_name, kills, deaths, eliminated, is_winner, role, reward_money)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ]], {
                insertId,
                event.id,
                identifier,
                Permissions.GetPlayerName(playerId),
                score.kills or 0,
                score.deaths or 0,
                score.eliminated and 1 or 0,
                isWinner and 1 or 0,
                event.roles and event.roles[playerId] or nil,
                reward
            })

            execute([[
                INSERT INTO snelle_event_stats (identifier, player_name, events_joined, events_won, total_kills, total_deaths, total_reward)
                VALUES (?, ?, 1, ?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    player_name = VALUES(player_name),
                    events_joined = events_joined + 1,
                    events_won = events_won + VALUES(events_won),
                    total_kills = total_kills + VALUES(total_kills),
                    total_deaths = total_deaths + VALUES(total_deaths),
                    total_reward = total_reward + VALUES(total_reward)
            ]], {
                identifier,
                Permissions.GetPlayerName(playerId),
                isWinner and 1 or 0,
                score.kills or 0,
                score.deaths or 0,
                reward
            })
        end
    end)
end

CreateThread(function()
    if not (Config.Database and Config.Database.enabled) then
        print('[snelle-events] Database logging uitgeschakeld')
        return
    end

    local tries = 0
    while tries < 30 do
        if hasOxMysql() or hasMysqlAsync() then
            ready = true
            print('[snelle-events] Database logging actief (' .. (hasOxMysql() and 'oxmysql' or 'mysql-async') .. ')')
            return
        end
        tries = tries + 1
        Wait(1000)
    end

    print('[snelle-events] WAARSCHUWING: Database enabled maar oxmysql/mysql-async niet gevonden')
end)
