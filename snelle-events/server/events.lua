Events = {}

Events.Active = {}
Events.PlayerIndex = {}
Events.Invites = {} -- [targetSource] = { eventId, from, expires }

local function countActiveEvents()
    local count = 0
    for _, event in pairs(Events.Active) do
        if event.status ~= 'ended' then
            count = count + 1
        end
    end
    return count
end

local function getPlayerEventId(source)
    return Events.PlayerIndex[source]
end

local function setPlayerEvent(source, eventId)
    Events.PlayerIndex[source] = eventId
end

local function clearPlayerEvent(source)
    Events.PlayerIndex[source] = nil
end

local function buildRoster(event)
    local roster = {}
    for _, playerId in ipairs(event.players) do
        local score = event.scores[playerId] or { kills = 0, deaths = 0, eliminated = false }
        roster[#roster + 1] = {
            id = playerId,
            name = Permissions.GetPlayerName(playerId),
            isHost = playerId == event.hostId,
            kills = score.kills or 0,
            deaths = score.deaths or 0,
            eliminated = score.eliminated == true,
            role = event.roles[playerId]
        }
    end
    return roster
end

local function buildPublicEvent(event)
    return {
        id = event.id,
        name = event.name,
        type = event.type,
        typeLabel = Utils.GetEventTypeConfig(event.type).label,
        host = event.hostName,
        hostId = event.hostId,
        maxPlayers = event.maxPlayers,
        minPlayers = event.minPlayers,
        playerCount = #event.players,
        status = event.status,
        statusLabel = Utils.StatusLabel(event.status),
        coords = event.coords,
        finishCoords = event.finishCoords,
        countdown = event.countdown,
        description = event.description,
        zoneRadius = event.settings.zoneRadius,
        enforceZone = event.settings.enforceZone,
        hasPassword = event.password ~= nil and event.password ~= '',
        duration = event.settings.duration,
        scoreToWin = event.settings.scoreToWin,
        players = buildRoster(event)
    }
end

local function syncEventToPlayers(event)
    local public = buildPublicEvent(event)
    for _, playerId in ipairs(event.players) do
        TriggerClientEvent('snelle-events:client:eventUpdate', playerId, public)
    end
    TriggerClientEvent('snelle-events:client:syncEvents', -1, Events.GetPublicList())
end

local function countAlive(event)
    local alive = 0
    for _, playerId in ipairs(event.players) do
        local score = event.scores[playerId]
        if not score or not score.eliminated then
            alive = alive + 1
        end
    end
    return alive
end

local function getAlivePlayers(event)
    local list = {}
    for _, playerId in ipairs(event.players) do
        local score = event.scores[playerId]
        if not score or not score.eliminated then
            list[#list + 1] = playerId
        end
    end
    return list
end

function Events.GetPublicList()
    local list = {}
    for _, event in pairs(Events.Active) do
        if event.status ~= 'ended' then
            list[#list + 1] = buildPublicEvent(event)
        end
    end
    table.sort(list, function(a, b) return a.name < b.name end)
    return list
end

function Events.GetById(eventId)
    return Events.Active[eventId]
end

function Events.GetPlayerEvent(source)
    local eventId = getPlayerEventId(source)
    if not eventId then return nil end
    return Events.Active[eventId]
end

function Events.IsPlayerInEvent(source)
    return getPlayerEventId(source) ~= nil
end

function Events.GetDetailed(eventId)
    local event = Events.GetById(eventId)
    if not event then return nil end
    return buildPublicEvent(event)
end

function Events.Create(source, data)
    if countActiveEvents() >= Config.MaxActiveEvents then
        return false, 'max_events_reached'
    end

    local eventType = data.type or 'custom'
    if not Config.EventTypes[eventType] then
        return false, 'invalid_event_type'
    end

    local typeConfig = Utils.GetEventTypeConfig(eventType)
    local eventId = Utils.GenerateId()
    local ped = GetPlayerPed(source)
    local coords = data.coords or Utils.SerializeCoords(GetEntityCoords(ped), GetEntityHeading(ped))

    local finishCoords = data.finishCoords
    if not finishCoords and typeConfig.finishOffset then
        finishCoords = {
            x = coords.x + (typeConfig.finishOffset.x or 0.0),
            y = coords.y + (typeConfig.finishOffset.y or 0.0),
            z = coords.z + (typeConfig.finishOffset.z or 0.0),
            heading = coords.heading or 0.0
        }
    end

    local password = Utils.Trim(data.password or '')
    if password == '' then password = nil end

    local event = {
        id = eventId,
        name = Utils.SanitizeEventName(data.name),
        type = eventType,
        description = Utils.Trim(data.description or typeConfig.description or ''),
        hostId = source,
        hostName = Permissions.GetPlayerName(source),
        maxPlayers = tonumber(data.maxPlayers) or typeConfig.defaultMaxPlayers,
        minPlayers = tonumber(data.minPlayers) or typeConfig.defaultMinPlayers or Config.DefaultMinPlayers,
        coords = coords,
        finishCoords = finishCoords,
        status = 'waiting',
        countdown = tonumber(data.countdown) or Config.DefaultCountdown,
        password = password,
        players = {},
        playerData = {},
        scores = {},
        roles = {},
        createdAt = os.time(),
        startedAt = nil,
        settings = {
            allowWeapons = data.allowWeapons ~= nil and data.allowWeapons or typeConfig.allowWeapons,
            pvpEnabled = data.pvpEnabled ~= nil and data.pvpEnabled or typeConfig.pvpEnabled,
            freezeOnStart = data.freezeOnStart ~= nil and data.freezeOnStart or typeConfig.freezeOnStart,
            vehicle = data.vehicle or typeConfig.vehicle,
            loadout = data.loadout or typeConfig.loadout,
            ammo = data.ammo or typeConfig.ammo,
            zoneRadius = tonumber(data.zoneRadius) or typeConfig.zoneRadius or Config.DefaultZoneRadius,
            enforceZone = data.enforceZone ~= nil and data.enforceZone or typeConfig.enforceZone,
            duration = tonumber(data.duration) or typeConfig.duration,
            scoreToWin = tonumber(data.scoreToWin) or typeConfig.scoreToWin,
            dropHeight = typeConfig.dropHeight,
            autoWinner = typeConfig.autoWinner == true,
            finishDistance = typeConfig.finishDistance or 8.0
        }
    }

    Buckets.Assign(event)
    Events.Active[eventId] = event
    Events.Join(source, eventId, true)

    TriggerClientEvent('snelle-events:client:syncEvents', -1, Events.GetPublicList())
    Announce.EventCreated(event)
    Permissions.SendWebhook(L('webhook_created'), ('**%s** (%s)\nHost: %s\nSpelers: 0/%s'):format(event.name, event.type, event.hostName, event.maxPlayers), 3066993)

    return true, event
end

function Events.Join(source, eventId, isHost, password)
    local event = Events.GetById(eventId)
    if not event or event.status == 'ended' then
        return false, 'event_not_found'
    end

    if event.status == 'active' or event.status == 'countdown' then
        if not isHost then
            return false, 'event_already_started'
        end
    end

    if Events.IsPlayerInEvent(source) and getPlayerEventId(source) ~= eventId then
        return false, 'already_in_event'
    end

    if #event.players >= event.maxPlayers then
        return false, 'event_full', event.maxPlayers, #event.players
    end

    if event.password and not isHost then
        if Utils.Trim(password or '') ~= event.password then
            return false, 'wrong_password'
        end
    end

    if not Config.AllowDeadPlayers then
        local ped = GetPlayerPed(source)
        if ped ~= 0 and GetEntityHealth(ped) <= 0 then
            return false, 'cannot_join_dead'
        end
    end

    for _, playerId in ipairs(event.players) do
        if playerId == source then
            return true, event
        end
    end

    event.players[#event.players + 1] = source
    event.scores[source] = { kills = 0, deaths = 0, eliminated = false }
    setPlayerEvent(source, eventId)
    Buckets.SetPlayer(source, event.bucket)

    Events.Invites[source] = nil

    TriggerClientEvent('snelle-events:client:joinedEvent', source, buildPublicEvent(event), isHost == true)
    TriggerClientEvent('snelle-events:client:playerJoined', -1, eventId, Permissions.GetPlayerName(source), #event.players)
    syncEventToPlayers(event)

    if not isHost then
        Permissions.SendWebhook(L('webhook_joined'), ('**%s** toegetreden tot **%s**'):format(Permissions.GetPlayerName(source), event.name), 5763719)
    end

    return true, event
end

function Events.Leave(source, skipReturn, eliminated)
    local eventId = getPlayerEventId(source)
    if not eventId then
        return false, 'not_in_event'
    end

    local event = Events.GetById(eventId)
    if not event then
        clearPlayerEvent(source)
        Buckets.ResetPlayer(source)
        return false, 'event_not_found'
    end

    for i, playerId in ipairs(event.players) do
        if playerId == source then
            table.remove(event.players, i)
            break
        end
    end

    clearPlayerEvent(source)
    event.playerData[source] = nil
    Buckets.ResetPlayer(source)

    TriggerClientEvent('snelle-events:client:leftEvent', source, buildPublicEvent(event), skipReturn == true)
    TriggerClientEvent('snelle-events:client:playerLeft', -1, eventId, Permissions.GetPlayerName(source), #event.players)

    if not eliminated then
        Permissions.SendWebhook(L('webhook_left'), ('**%s** verlaten **%s**'):format(Permissions.GetPlayerName(source), event.name), 15158332)
    end

    if event.hostId == source and #event.players > 0 then
        event.hostId = event.players[1]
        event.hostName = Permissions.GetPlayerName(event.hostId)
        TriggerClientEvent('snelle-events:client:notify', event.hostId, L('you_are_host'))
        TriggerClientEvent('snelle-events:client:becameHost', event.hostId, buildPublicEvent(event))
    end

    syncEventToPlayers(event)

    if event.status == 'active' and event.settings.autoWinner then
        Events.CheckAutoWinner(eventId)
    end

    if #event.players == 0 and event.status ~= 'ended' then
        Events.Stop(event.hostId or source, eventId, true)
    end

    return true, event
end

function Events.Kick(hostSource, eventId, targetSource)
    local event = Events.GetById(eventId)
    if not event then return false, 'event_not_found' end
    if event.hostId ~= hostSource and not Permissions.CanManage(hostSource) then
        return false, 'host_only'
    end
    if not Utils.TableContains(event.players, targetSource) then
        return false, 'player_not_in_event'
    end

    TriggerClientEvent('snelle-events:client:notify', targetSource, L('kicked_from_event'))
    Events.Leave(targetSource)
    return true
end

function Events.PromoteHost(source, eventId, targetSource)
    local event = Events.GetById(eventId)
    if not event then return false, 'event_not_found' end
    if event.hostId ~= source and not Permissions.CanManage(source) then
        return false, 'host_only'
    end
    if not Utils.TableContains(event.players, targetSource) then
        return false, 'player_not_in_event'
    end

    event.hostId = targetSource
    event.hostName = Permissions.GetPlayerName(targetSource)
    TriggerClientEvent('snelle-events:client:notify', targetSource, L('you_are_host'))
    TriggerClientEvent('snelle-events:client:becameHost', targetSource, buildPublicEvent(event))
    syncEventToPlayers(event)
    return true
end

function Events.Invite(source, eventId, targetSource)
    local event = Events.GetById(eventId)
    if not event then return false, 'event_not_found' end
    if event.hostId ~= source and not Permissions.CanManage(source) then
        return false, 'host_only'
    end
    if Events.IsPlayerInEvent(targetSource) then
        return false, 'already_in_event'
    end

    Events.Invites[targetSource] = {
        eventId = eventId,
        from = source,
        fromName = Permissions.GetPlayerName(source),
        eventName = event.name,
        expires = os.time() + (Config.InviteExpireSeconds or 60)
    }

    TriggerClientEvent('snelle-events:client:invite', targetSource, {
        eventId = eventId,
        eventName = event.name,
        fromName = Permissions.GetPlayerName(source),
        expires = Config.InviteExpireSeconds or 60
    })

    return true
end

function Events.AcceptInvite(source)
    local invite = Events.Invites[source]
    if not invite then return false, 'no_invite' end
    if os.time() > invite.expires then
        Events.Invites[source] = nil
        return false, 'invite_expired'
    end

    return Events.Join(source, invite.eventId, false, nil)
end

function Events.TeleportAll(source, eventId)
    local event = Events.GetById(eventId)
    if not event then return false, 'event_not_found' end
    if event.hostId ~= source and not Permissions.CanManage(source) then
        return false, 'host_only'
    end

    for _, playerId in ipairs(event.players) do
        TriggerClientEvent('snelle-events:client:teleportToEvent', playerId, event.coords)
    end

    return true
end

function Events.Start(source, eventId)
    local event = Events.GetById(eventId)
    if not event then return false, 'event_not_found' end
    if event.hostId ~= source and not Permissions.CanManage(source) then
        return false, 'host_only'
    end
    if event.status ~= 'waiting' then return false, 'event_not_found' end

    if #event.players < event.minPlayers then
        return false, 'not_enough_players', event.minPlayers, #event.players
    end

    -- Assign hunt / hide roles
    if event.type == 'hunt' or event.type == 'hideandseek' then
        local shuffled = Utils.CopyTable(event.players)
        for i = #shuffled, 2, -1 do
            local j = math.random(i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end

        local target = shuffled[1]
        event.roles[target] = event.type == 'hunt' and 'target' or 'hider'

        for i = 2, #shuffled do
            event.roles[shuffled[i]] = event.type == 'hunt' and 'hunter' or 'seeker'
        end
    end

    event.status = 'countdown'

    for _, playerId in ipairs(event.players) do
        TriggerClientEvent('snelle-events:client:countdown', playerId, event.countdown, buildPublicEvent(event))
    end

    syncEventToPlayers(event)

    SetTimeout(event.countdown * 1000, function()
        if not Events.Active[eventId] or Events.Active[eventId].status ~= 'countdown' then return end

        event.status = 'active'
        event.startedAt = os.time()

        for _, playerId in ipairs(event.players) do
            TriggerClientEvent('snelle-events:client:eventStarted', playerId, buildPublicEvent(event))
        end

        syncEventToPlayers(event)
        Announce.ToAll(L('event_started', event.name))
        Permissions.SendWebhook(L('webhook_started'), ('**%s** gestart\nSpelers: %s'):format(event.name, #event.players), 5763719)

        if event.settings.duration and event.settings.duration > 0 then
            SetTimeout(event.settings.duration * 1000, function()
                if Events.Active[eventId] and Events.Active[eventId].status == 'active' then
                    Events.EndByTime(eventId)
                end
            end)
        end
    end)

    return true, event
end

function Events.Stop(source, eventId, autoStop)
    local event = Events.GetById(eventId)
    if not event then return false, 'event_not_found' end
    if not autoStop and event.hostId ~= source and not Permissions.CanManage(source) then
        return false, 'host_only'
    end

    event.status = 'ended'
    local playersCopy = Utils.CopyTable(event.players)

    for _, playerId in ipairs(playersCopy) do
        Buckets.ResetPlayer(playerId)
        TriggerClientEvent('snelle-events:client:eventStopped', playerId, buildPublicEvent(event))
        clearPlayerEvent(playerId)
    end

    event.players = {}
    event.playerData = {}
    event.scores = {}
    event.roles = {}

    TriggerClientEvent('snelle-events:client:syncEvents', -1, Events.GetPublicList())
    Announce.ToAll(L('event_stopped', event.name))
    Permissions.SendWebhook(L('webhook_stopped'), ('**%s** gestopt'):format(event.name), 15158332)

    SetTimeout(60000, function()
        Events.Active[eventId] = nil
    end)

    return true, event
end

function Events.Announce(source, eventId, message)
    local event = Events.GetById(eventId)
    if not event then return false, 'event_not_found' end
    if event.hostId ~= source and not Permissions.CanManage(source) then
        return false, 'host_only'
    end

    message = Utils.Trim(message or '')
    if message == '' then return false end

    for _, playerId in ipairs(event.players) do
        TriggerClientEvent('snelle-events:client:notify', playerId, L('event_announce', message))
    end

    Announce.ToAll(L('event_announce', ('[%s] %s'):format(event.name, message)))
    return true
end

local function payPlaceRewards(event, orderedWinners)
    if not Config.Rewards.enabled then return end

    local places = {
        Config.Rewards.winner,
        Config.Rewards.secondPlace,
        Config.Rewards.thirdPlace
    }

    for i, playerId in ipairs(orderedWinners) do
        local reward = places[i]
        if reward and reward.money and reward.money > 0 then
            Permissions.GiveReward(playerId, reward.money, reward.account)
            if i == 1 then
                TriggerClientEvent('snelle-events:client:notify', playerId, L('reward_winner', reward.money))
            else
                TriggerClientEvent('snelle-events:client:notify', playerId, L('reward_place', i, reward.money))
            end
        end
    end

    for _, playerId in ipairs(event.players) do
        if not Utils.TableContains(orderedWinners, playerId) then
            Permissions.GiveReward(playerId, Config.Rewards.participant.money, Config.Rewards.participant.account)
            TriggerClientEvent('snelle-events:client:notify', playerId, L('reward_participant', Config.Rewards.participant.money))
        end
    end
end

function Events.SetWinner(source, eventId, winnerSource)
    local event = Events.GetById(eventId)
    if not event then return false, 'event_not_found' end
    if event.hostId ~= source and not Permissions.CanManage(source) then
        return false, 'host_only'
    end
    if not Utils.TableContains(event.players, winnerSource) then
        return false, 'player_not_in_event'
    end

    local winnerName = Permissions.GetPlayerName(winnerSource)
    payPlaceRewards(event, { winnerSource })
    Announce.ToAll(L('winner_announced', winnerName))

    Events.Stop(source, eventId, true)
    return true
end

function Events.Eliminate(source, eventId, reason)
    local event = Events.GetById(eventId)
    if not event or event.status ~= 'active' then return false end
    if not Utils.TableContains(event.players, source) then return false end

    event.scores[source] = event.scores[source] or { kills = 0, deaths = 0, eliminated = false }
    if event.scores[source].eliminated then return false end

    event.scores[source].eliminated = true
    event.scores[source].deaths = (event.scores[source].deaths or 0) + 1

    TriggerClientEvent('snelle-events:client:notify', source, L('eliminated', reason or ''))
    TriggerClientEvent('snelle-events:client:eliminated', source, buildPublicEvent(event))
    syncEventToPlayers(event)

    Events.CheckAutoWinner(eventId)
    return true
end

function Events.RegisterKill(killerSource, victimSource)
    local event = Events.GetPlayerEvent(victimSource)
    if not event or event.status ~= 'active' then return end
    if not event.settings.pvpEnabled then return end

    event.scores[victimSource] = event.scores[victimSource] or { kills = 0, deaths = 0, eliminated = false }
    event.scores[victimSource].deaths = (event.scores[victimSource].deaths or 0) + 1

    if killerSource and killerSource > 0 and Utils.TableContains(event.players, killerSource) then
        event.scores[killerSource] = event.scores[killerSource] or { kills = 0, deaths = 0, eliminated = false }
        event.scores[killerSource].kills = (event.scores[killerSource].kills or 0) + 1

        if event.type == 'deathmatch' and event.settings.scoreToWin then
            if event.scores[killerSource].kills >= event.settings.scoreToWin then
                Events.SetWinner(event.hostId, event.id, killerSource)
                return
            end
        end

        if event.type == 'hunt' and event.roles[victimSource] == 'target' then
            Events.SetWinner(event.hostId, event.id, killerSource)
            return
        end
    end

    if event.type == 'pvp' or event.type == 'derby' or event.type == 'hunt' or event.type == 'hideandseek' then
        event.scores[victimSource].eliminated = true
        TriggerClientEvent('snelle-events:client:eliminated', victimSource, buildPublicEvent(event))
        Events.CheckAutoWinner(event.id)
    end

    syncEventToPlayers(event)
end

function Events.RaceFinish(source)
    local event = Events.GetPlayerEvent(source)
    if not event or event.type ~= 'race' or event.status ~= 'active' then return end
    if event.scores[source] and event.scores[source].eliminated then return end

    Events.SetWinner(event.hostId, event.id, source)
end

function Events.CheckAutoWinner(eventId)
    local event = Events.GetById(eventId)
    if not event or event.status ~= 'active' or not event.settings.autoWinner then return end

    local alive = getAlivePlayers(event)

    if event.type == 'hideandseek' then
        local hidersAlive = 0
        for _, playerId in ipairs(alive) do
            if event.roles[playerId] == 'hider' then
                hidersAlive = hidersAlive + 1
            end
        end
        if hidersAlive == 0 then
            -- Seekers win: pick top seeker by kills or first seeker
            for _, playerId in ipairs(event.players) do
                if event.roles[playerId] == 'seeker' then
                    Events.SetWinner(event.hostId, event.id, playerId)
                    return
                end
            end
        end
        return
    end

    if #alive == 1 then
        Events.SetWinner(event.hostId, event.id, alive[1])
    elseif #alive == 0 then
        Events.Stop(event.hostId, eventId, true)
    end
end

function Events.EndByTime(eventId)
    local event = Events.GetById(eventId)
    if not event or event.status ~= 'active' then return end

    if event.type == 'deathmatch' then
        local best, bestKills = nil, -1
        for _, playerId in ipairs(event.players) do
            local kills = (event.scores[playerId] and event.scores[playerId].kills) or 0
            if kills > bestKills then
                bestKills = kills
                best = playerId
            end
        end
        if best then
            Events.SetWinner(event.hostId, event.id, best)
            return
        end
    end

    if event.type == 'hunt' then
        for _, playerId in ipairs(event.players) do
            if event.roles[playerId] == 'target' and not (event.scores[playerId] and event.scores[playerId].eliminated) then
                Events.SetWinner(event.hostId, event.id, playerId)
                return
            end
        end
    end

    if event.type == 'hideandseek' then
        for _, playerId in ipairs(event.players) do
            if event.roles[playerId] == 'hider' and not (event.scores[playerId] and event.scores[playerId].eliminated) then
                Events.SetWinner(event.hostId, event.id, playerId)
                return
            end
        end
    end

    Events.Stop(event.hostId, eventId, true)
end

function Events.SavePlayerData(source, data)
    local eventId = getPlayerEventId(source)
    if not eventId then return end
    local event = Events.GetById(eventId)
    if not event then return end
    event.playerData[source] = data
end

function Events.Cleanup()
    if not Config.CleanupOnRestart then return end
    Events.Active = {}
    Events.PlayerIndex = {}
    Events.Invites = {}
end

AddEventHandler('playerDropped', function()
    local source = source
    Events.Invites[source] = nil
    if Events.IsPlayerInEvent(source) then
        Events.Leave(source, true)
    end
end)
