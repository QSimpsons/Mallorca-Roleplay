Events = {}

Events.Active = {}
Events.PlayerIndex = {}

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

local function buildPublicEvent(event)
    return {
        id = event.id,
        name = event.name,
        type = event.type,
        typeLabel = Utils.GetEventTypeConfig(event.type).label,
        host = event.hostName,
        hostId = event.hostId,
        maxPlayers = event.maxPlayers,
        playerCount = #event.players,
        status = event.status,
        statusLabel = Utils.StatusLabel(event.status),
        coords = event.coords,
        countdown = event.countdown,
        description = event.description
    }
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

    local event = {
        id = eventId,
        name = Utils.SanitizeEventName(data.name),
        type = eventType,
        description = Utils.Trim(data.description or typeConfig.description or ''),
        hostId = source,
        hostName = Permissions.GetPlayerName(source),
        maxPlayers = tonumber(data.maxPlayers) or typeConfig.defaultMaxPlayers,
        coords = data.coords or Utils.SerializeCoords(GetEntityCoords(GetPlayerPed(source)), GetEntityHeading(GetPlayerPed(source))),
        status = 'waiting',
        countdown = tonumber(data.countdown) or Config.DefaultCountdown,
        players = {},
        playerData = {},
        createdAt = os.time(),
        settings = {
            allowWeapons = data.allowWeapons ~= nil and data.allowWeapons or typeConfig.allowWeapons,
            pvpEnabled = data.pvpEnabled ~= nil and data.pvpEnabled or typeConfig.pvpEnabled,
            freezeOnStart = data.freezeOnStart ~= nil and data.freezeOnStart or typeConfig.freezeOnStart,
            vehicle = data.vehicle or typeConfig.vehicle,
            loadout = data.loadout or typeConfig.loadout,
            ammo = data.ammo or typeConfig.ammo
        }
    }

    Events.Active[eventId] = event
    Events.Join(source, eventId, true)

    TriggerClientEvent('snelle-events:client:syncEvents', -1, Events.GetPublicList())
    Permissions.SendWebhook(L('webhook_created'), ('**%s** (%s)\nHost: %s\nSpelers: 0/%s'):format(event.name, event.type, event.hostName, event.maxPlayers), 3066993)

    return true, event
end

function Events.Join(source, eventId, isHost)
    local event = Events.GetById(eventId)
    if not event or event.status == 'ended' then
        return false, 'event_not_found'
    end

    if Events.IsPlayerInEvent(source) and getPlayerEventId(source) ~= eventId then
        return false, 'already_in_event'
    end

    if #event.players >= event.maxPlayers then
        return false, 'event_full', event.maxPlayers, #event.players
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
    setPlayerEvent(source, eventId)

    TriggerClientEvent('snelle-events:client:joinedEvent', source, event, isHost == true)
    TriggerClientEvent('snelle-events:client:playerJoined', -1, eventId, Permissions.GetPlayerName(source), #event.players)
    TriggerClientEvent('snelle-events:client:syncEvents', -1, Events.GetPublicList())

    if not isHost then
        Permissions.SendWebhook(L('webhook_joined'), ('**%s** toegetreden tot **%s**'):format(Permissions.GetPlayerName(source), event.name), 5763719)
    end

    return true, event
end

function Events.Leave(source, skipReturn)
    local eventId = getPlayerEventId(source)
    if not eventId then
        return false, 'not_in_event'
    end

    local event = Events.GetById(eventId)
    if not event then
        clearPlayerEvent(source)
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

    TriggerClientEvent('snelle-events:client:leftEvent', source, event, skipReturn == true)
    TriggerClientEvent('snelle-events:client:playerLeft', -1, eventId, Permissions.GetPlayerName(source), #event.players)
    TriggerClientEvent('snelle-events:client:syncEvents', -1, Events.GetPublicList())

    Permissions.SendWebhook(L('webhook_left'), ('**%s** verlaten **%s**'):format(Permissions.GetPlayerName(source), event.name), 15158332)

    if event.hostId == source and #event.players > 0 then
        event.hostId = event.players[1]
        event.hostName = Permissions.GetPlayerName(event.hostId)
        TriggerClientEvent('snelle-events:client:notify', event.hostId, L('you_are_host'))
        TriggerClientEvent('snelle-events:client:becameHost', event.hostId, event)
    end

    if #event.players == 0 and event.status ~= 'ended' then
        Events.Stop(event.hostId, eventId, true)
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

function Events.Start(source, eventId)
    local event = Events.GetById(eventId)
    if not event then return false, 'event_not_found' end
    if event.hostId ~= source and not Permissions.CanManage(source) then
        return false, 'host_only'
    end
    if event.status ~= 'waiting' then return false, 'event_not_found' end

    event.status = 'countdown'

    for _, playerId in ipairs(event.players) do
        TriggerClientEvent('snelle-events:client:countdown', playerId, event.countdown, event)
    end

    TriggerClientEvent('snelle-events:client:syncEvents', -1, Events.GetPublicList())

    SetTimeout(event.countdown * 1000, function()
        if not Events.Active[eventId] or Events.Active[eventId].status ~= 'countdown' then return end

        event.status = 'active'

        for _, playerId in ipairs(event.players) do
            TriggerClientEvent('snelle-events:client:eventStarted', playerId, event)
        end

        TriggerClientEvent('snelle-events:client:syncEvents', -1, Events.GetPublicList())
        TriggerClientEvent('snelle-events:client:globalAnnounce', -1, L('event_started', event.name))
        Permissions.SendWebhook(L('webhook_started'), ('**%s** gestart\nSpelers: %s'):format(event.name, #event.players), 5763719)
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
        TriggerClientEvent('snelle-events:client:eventStopped', playerId, event)
        clearPlayerEvent(playerId)
    end

    event.players = {}
    event.playerData = {}

    TriggerClientEvent('snelle-events:client:syncEvents', -1, Events.GetPublicList())
    TriggerClientEvent('snelle-events:client:globalAnnounce', -1, L('event_stopped', event.name))
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

    TriggerClientEvent('snelle-events:client:globalAnnounce', -1, L('event_announce', ('[%s] %s'):format(event.name, message)))
    return true
end

function Events.SetWinner(source, eventId, winnerSource)
    local event = Events.GetById(eventId)
    if not event then return false, 'event_not_found' end
    if event.hostId ~= source and not Permissions.CanManage(source) then
        return false, 'host_only'
    end

    local winnerName = Permissions.GetPlayerName(winnerSource)

    if Config.Rewards.enabled then
        Permissions.GiveReward(winnerSource, Config.Rewards.winner.money, Config.Rewards.winner.account)
        TriggerClientEvent('snelle-events:client:notify', winnerSource, L('reward_winner', Config.Rewards.winner.money))

        for _, playerId in ipairs(event.players) do
            if playerId ~= winnerSource then
                Permissions.GiveReward(playerId, Config.Rewards.participant.money, Config.Rewards.participant.account)
                TriggerClientEvent('snelle-events:client:notify', playerId, L('reward_participant', Config.Rewards.participant.money))
            end
        end
    end

    TriggerClientEvent('snelle-events:client:globalAnnounce', -1, L('winner_announced', winnerName))
    return true
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
end

AddEventHandler('playerDropped', function()
    local source = source
    if Events.IsPlayerInEvent(source) then
        Events.Leave(source, true)
    end
end)
