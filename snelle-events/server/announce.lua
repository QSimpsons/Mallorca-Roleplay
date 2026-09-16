Announce = {}

function Announce.ToAll(message)
    if Config.AnnounceMethod == 'notify' or Config.AnnounceMethod == 'both' then
        TriggerClientEvent('snelle-events:client:notify', -1, message)
    end

    if Config.AnnounceMethod == 'chat' or Config.AnnounceMethod == 'both' then
        TriggerClientEvent('snelle-events:client:chatMessage', -1, message)
    end
end

function Announce.ToPlayer(source, message)
    TriggerClientEvent('snelle-events:client:notify', source, message)

    if Config.AnnounceMethod == 'chat' or Config.AnnounceMethod == 'both' then
        TriggerClientEvent('snelle-events:client:chatMessage', source, message)
    end
end

function Announce.EventCreated(event)
    Announce.ToAll(L('event_announce', ('Nieuw event: %s (%s) - /joinevent'):format(event.name, Utils.GetEventTypeConfig(event.type).label)))
end
