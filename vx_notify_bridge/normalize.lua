NotifyBridge = NotifyBridge or {}

local typeMap = {
    success = 'success',
    error = 'error',
    info = 'inform',
    inform = 'inform',
    warning = 'warning',
    warn = 'warning',
    primary = 'inform',
}

function NotifyBridge.mapType(value)
    if type(value) ~= 'string' then
        return 'inform'
    end

    return typeMap[value:lower()] or 'inform'
end

function NotifyBridge.isType(value)
    return type(value) == 'string' and typeMap[value:lower()] ~= nil
end

--- Zet de verschillende aanroepvormen om naar één melding.
--- notify({ message, type, title, duration })
--- notify(type, message, duration)
--- notify(message, type)
--- notify(type, duration, message, title)
--- notify(title, message, type, duration)
--- notify(message)
function NotifyBridge.normalize(...)
    local first, second, third, fourth = ...

    if type(first) == 'table' then
        local data = first
        local description = data.description or data.message or data.text or data.msg or data.content

        return {
            title = data.title,
            description = description ~= nil and tostring(description) or nil,
            type = NotifyBridge.mapType(data.type or data.notifyType or data.status),
            duration = tonumber(data.duration or data.time or data.length),
        }
    end

    if type(first) == 'string' and type(second) == 'number' and type(third) == 'string' then
        return {
            type = NotifyBridge.mapType(first),
            duration = second,
            description = third,
            title = type(fourth) == 'string' and fourth or nil,
        }
    end

    if NotifyBridge.isType(first) and type(second) == 'string' and (third == nil or type(third) == 'number') then
        return {
            type = NotifyBridge.mapType(first),
            description = second,
            duration = tonumber(third),
            title = type(fourth) == 'string' and fourth or nil,
        }
    end

    if type(first) == 'string' and NotifyBridge.isType(second) and (third == nil or type(third) == 'number') then
        return {
            description = first,
            type = NotifyBridge.mapType(second),
            duration = tonumber(third),
        }
    end

    if type(first) == 'string' and type(second) == 'string' and type(third) == 'string' then
        return {
            title = first,
            description = second,
            type = NotifyBridge.mapType(third),
            duration = tonumber(fourth),
        }
    end

    if type(first) == 'string' then
        return {
            description = first,
            type = 'inform',
            duration = tonumber(second),
        }
    end

    return {
        description = first ~= nil and tostring(first) or '',
        type = 'inform',
    }
end

--- Registreert vx_notify:notify voor andere resources.
--- De export mag nooit een fout doorgeven, anders stopt de aankoop-callback opnieuw.
function NotifyBridge.bind(addEventHandler, deliver)
    addEventHandler('__cfx_export_vx_notify_notify', function(setCB)
        setCB(function(...)
            local ok, err = pcall(deliver, ...)

            if not ok then
                print(('^1[vx_notify_bridge]^7 notify mislukt: %s'):format(tostring(err)))
            end

            return true
        end)
    end)
end
