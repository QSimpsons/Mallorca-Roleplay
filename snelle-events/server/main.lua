local function notify(source, key, ...)
    TriggerClientEvent('snelle-events:client:notify', source, L(key, ...))
end

local function openPanel(source)
    if not Permissions.CanManage(source) then
        notify(source, 'no_permission')
        return
    end

    TriggerClientEvent('snelle-events:client:openPanel', source, {
        canManage = true,
        events = Events.GetPublicList(),
        eventTypes = Config.EventTypes,
        presets = Config.PresetLocations,
        playerCoords = Utils.SerializeCoords(GetEntityCoords(GetPlayerPed(source)), GetEntityHeading(GetPlayerPed(source)))
    })
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Events.Cleanup()
    print('[snelle-events] ESX event systeem actief (uitgebreid)')
end)

RegisterNetEvent('snelle-events:server:requestOpenPanel', function()
    openPanel(source)
end)

RegisterNetEvent('snelle-events:server:createEvent', function(data)
    local source = source
    if not Permissions.CanManage(source) then
        notify(source, 'no_permission')
        return
    end

    local ok, result = Events.Create(source, data)
    if not ok then
        notify(source, result)
        return
    end

    notify(source, 'event_created', result.name)
    TriggerClientEvent('snelle-events:client:panelData', source, {
        events = Events.GetPublicList(),
        currentEvent = Events.GetDetailed(result.id)
    })
end)

RegisterNetEvent('snelle-events:server:joinEvent', function(eventId, password)
    local source = source
    local ok, result, a, b = Events.Join(source, eventId, false, password)

    if not ok then
        if result == 'event_full' or result == 'not_enough_players' then
            notify(source, result, b, a)
        else
            notify(source, result)
        end
        return
    end

    notify(source, 'joined_event', result.name)
end)

RegisterNetEvent('snelle-events:server:leaveEvent', function()
    local source = source
    local ok, result = Events.Leave(source)
    if not ok then
        notify(source, result)
        return
    end
    notify(source, 'left_event', result.name)
end)

RegisterNetEvent('snelle-events:server:startEvent', function(eventId)
    local source = source
    local ok, result, a, b = Events.Start(source, eventId)
    if not ok then
        if result == 'not_enough_players' then
            notify(source, result, a, b)
        else
            notify(source, result)
        end
        return
    end
    notify(source, 'event_started', result.name)
end)

RegisterNetEvent('snelle-events:server:stopEvent', function(eventId)
    local source = source
    local ok, result = Events.Stop(source, eventId)
    if not ok then
        notify(source, result)
        return
    end
    notify(source, 'event_stopped', result.name)
end)

RegisterNetEvent('snelle-events:server:kickPlayer', function(eventId, targetSource)
    local source = source
    local ok, err = Events.Kick(source, eventId, tonumber(targetSource))
    if not ok then notify(source, err) end
end)

RegisterNetEvent('snelle-events:server:promoteHost', function(eventId, targetSource)
    local source = source
    local ok, err = Events.PromoteHost(source, eventId, tonumber(targetSource))
    if not ok then notify(source, err) else notify(source, 'host_promoted') end
end)

RegisterNetEvent('snelle-events:server:invitePlayer', function(eventId, targetSource)
    local source = source
    local ok, err = Events.Invite(source, eventId, tonumber(targetSource))
    if not ok then notify(source, err) else notify(source, 'invite_sent') end
end)

RegisterNetEvent('snelle-events:server:acceptInvite', function()
    local source = source
    local ok, result = Events.AcceptInvite(source)
    if not ok then
        notify(source, result)
        return
    end
    notify(source, 'joined_event', result.name)
end)

RegisterNetEvent('snelle-events:server:teleportAll', function(eventId)
    local source = source
    local ok, err = Events.TeleportAll(source, eventId)
    if not ok then notify(source, err) else notify(source, 'teleported_all') end
end)

RegisterNetEvent('snelle-events:server:announceEvent', function(eventId, message)
    local source = source
    local ok, err = Events.Announce(source, eventId, message)
    if not ok then notify(source, err or 'event_not_found') end
end)

RegisterNetEvent('snelle-events:server:setWinner', function(eventId, winnerSource)
    local source = source
    local ok, err = Events.SetWinner(source, eventId, tonumber(winnerSource))
    if not ok then notify(source, err) end
end)

RegisterNetEvent('snelle-events:server:playerKilled', function(killerServerId)
    local source = source
    Events.RegisterKill(tonumber(killerServerId) or 0, source)
end)

RegisterNetEvent('snelle-events:server:eliminateSelf', function(reason)
    local source = source
    local event = Events.GetPlayerEvent(source)
    if event then
        Events.Eliminate(source, event.id, reason)
    end
end)

RegisterNetEvent('snelle-events:server:raceFinish', function()
    Events.RaceFinish(source)
end)

RegisterNetEvent('snelle-events:server:savePlayerData', function(data)
    Events.SavePlayerData(source, data)
end)

RegisterNetEvent('snelle-events:server:requestEvents', function()
    TriggerClientEvent('snelle-events:client:syncEvents', source, Events.GetPublicList())
end)

RegisterNetEvent('snelle-events:server:requestEventDetail', function(eventId)
    local detail = Events.GetDetailed(eventId)
    if detail then
        TriggerClientEvent('snelle-events:client:panelData', source, {
            events = Events.GetPublicList(),
            currentEvent = detail
        })
    end
end)

RegisterNetEvent('snelle-events:server:getOnlinePlayers', function()
    local source = source
    if not Permissions.CanManage(source) then return end

    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        local id = tonumber(playerId)
        players[#players + 1] = {
            id = id,
            name = Permissions.GetPlayerName(id),
            inEvent = Events.IsPlayerInEvent(id)
        }
    end

    TriggerClientEvent('snelle-events:client:onlinePlayers', source, players)
end)

-- Commando's
RegisterCommand(Config.Commands.manage, function(source)
    if source == 0 then return end
    openPanel(source)
end, false)

RegisterCommand(Config.Commands.join, function(source, args)
    if source == 0 then return end

    if args[1] then
        local password = args[2]
        local ok, result, a, b = Events.Join(source, args[1], false, password)
        if not ok then
            if result == 'event_full' then
                notify(source, result, b, a)
            else
                notify(source, result)
            end
            return
        end
        notify(source, 'joined_event', result.name)
        return
    end

    local list = Events.GetPublicList()
    if #list == 0 then
        notify(source, 'no_events_available')
        return
    end

    TriggerClientEvent('snelle-events:client:openJoinMenu', source, list)
end, false)

RegisterCommand(Config.Commands.leave, function(source)
    if source == 0 then return end
    local ok, result = Events.Leave(source)
    if not ok then
        notify(source, result)
        return
    end
    notify(source, 'left_event', result.name)
end, false)

RegisterCommand(Config.Commands.info, function(source)
    if source == 0 then return end
    local event = Events.GetPlayerEvent(source)
    if not event then
        notify(source, 'not_in_event')
        return
    end
    notify(source, 'event_info', event.name, Utils.GetEventTypeConfig(event.type).label, #event.players, event.maxPlayers, Utils.StatusLabel(event.status))
end, false)

RegisterCommand(Config.Commands.invite, function(source, args)
    if source == 0 then return end
    local event = Events.GetPlayerEvent(source)
    if not event then
        notify(source, 'not_in_event')
        return
    end

    local target = tonumber(args[1])
    if not target then
        notify(source, 'invite_usage')
        return
    end

    local ok, err = Events.Invite(source, event.id, target)
    if not ok then notify(source, err) else notify(source, 'invite_sent') end
end, false)

RegisterCommand(Config.Commands.spectate, function(source)
    if source == 0 then return end
    local event = Events.GetPlayerEvent(source)
    if not event then
        notify(source, 'not_in_event')
        return
    end
    TriggerClientEvent('snelle-events:client:toggleSpectate', source, Events.GetDetailed(event.id))
end, false)

exports('CreateEvent', function(source, data)
    return Events.Create(source, data)
end)

exports('GetActiveEvents', function()
    return Events.GetPublicList()
end)

exports('IsPlayerInEvent', function(source)
    return Events.IsPlayerInEvent(source)
end)

exports('GetPlayerEvent', function(source)
    return Events.GetPlayerEvent(source)
end)

exports('SetWinner', function(source, eventId, winnerSource)
    return Events.SetWinner(source, eventId, winnerSource)
end)
