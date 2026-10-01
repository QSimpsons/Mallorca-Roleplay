NotifyBridge.bind(AddEventHandler, function(...)
    local count = select('#', ...)
    local first = ...
    local target
    local payload

    if count >= 2 and type(first) == 'number' and first >= 1 and first <= 2048 and first % 1 == 0 then
        target = first
        payload = NotifyBridge.normalize(select(2, ...))
    elseif type(source) == 'number' and source > 0 then
        target = source
        payload = NotifyBridge.normalize(...)
    else
        return
    end

    TriggerClientEvent('vx_notify_bridge:notify', target, payload)
end)

print('^2[vx_notify_bridge]^7 Server-export vx_notify:notify is beschikbaar.')
