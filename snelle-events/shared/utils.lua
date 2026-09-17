Utils = {}

function Utils.Trim(value)
    if type(value) ~= 'string' then return value end
    return value:match('^%s*(.-)%s*$')
end

function Utils.TableContains(tbl, value)
    for _, v in ipairs(tbl) do
        if v == value then return true end
    end
    return false
end

function Utils.CopyTable(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == 'table' then
            copy[k] = Utils.CopyTable(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function Utils.GenerateId()
    return ('evt_%s_%s'):format(os.time(), math.random(1000, 9999))
end

function Utils.GetDistance(a, b)
    return #(vector3(a.x, a.y, a.z) - vector3(b.x, b.y, b.z))
end

function Utils.StatusLabel(status)
    local map = {
        waiting = L('status_waiting'),
        countdown = L('status_countdown'),
        active = L('status_active'),
        ended = L('status_ended')
    }
    return map[status] or status
end

function Utils.SanitizeEventName(name)
    name = Utils.Trim(name or '')
    if name == '' then return 'Event' end
    return name:sub(1, 64)
end

function Utils.GetEventTypeConfig(eventType)
    return Config.EventTypes[eventType] or Config.EventTypes.custom
end

function Utils.SerializeCoords(coords, heading)
    return {
        x = coords.x + 0.0,
        y = coords.y + 0.0,
        z = coords.z + 0.0,
        heading = heading or 0.0
    }
end

function Utils.CoordsToVector(data)
    return vector3(data.x, data.y, data.z), data.heading or 0.0
end
