local function notify(source, key, ...)
    TriggerClientEvent('snelle-events:client:notify', source, L(key, ...))
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    Events.Cleanup()
    print('[snelle-events] Resource gestart - event systeem actief')
end)

-- Permissie check
RegisterNetEvent('snelle-events:server:requestOpenPanel', function()
    local source = source
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
        currentEvent = result
    })
end)

RegisterNetEvent('snelle-events:server:joinEvent', function(eventId)
    local source = source
    local ok, result, a, b = Events.Join(source, eventId)

    if not ok then
        if result == 'event_full' then
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
    local ok, result = Events.Start(source, eventId)

    if not ok then
        notify(source, result)
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
    local ok, err = Events.Kick(source, eventId, targetSource)

    if not ok then
        notify(source, err)
    end
end)

RegisterNetEvent('snelle-events:server:announceEvent', function(eventId, message)
    local source = source
    local ok, err = Events.Announce(source, eventId, message)

    if not ok then
        notify(source, err or 'event_not_found')
    end
end)

RegisterNetEvent('snelle-events:server:setWinner', function(eventId, winnerSource)
    local source = source
    local ok, err = Events.SetWinner(source, eventId, winnerSource)

    if not ok then
        notify(source, err)
    end
end)

RegisterNetEvent('snelle-events:server:savePlayerData', function(data)
    Events.SavePlayerData(source, data)
end)

RegisterNetEvent('snelle-events:server:requestEvents', function()
    TriggerClientEvent('snelle-events:client:syncEvents', source, Events.GetPublicList())
end)

-- Commando's
RegisterCommand(Config.Commands.manage, function(source)
    if source == 0 then return end

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
end, false)

RegisterCommand(Config.Commands.join, function(source, args)
    if source == 0 then return end

    if args[1] then
        local ok, result, a, b = Events.Join(source, args[1])
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

-- Exports
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
