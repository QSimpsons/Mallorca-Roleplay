Impact = {}

function Impact.clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

-- dx > 0: de rechterkant ving de klap op. dy > 0: de voorkant.
-- along loopt van -1 (achter) naar 1 (voor) bij een zijkant.
function Impact.classify(dx, dy)
    local ax = math.abs(dx or 0.0)
    local ay = math.abs(dy or 0.0)
    if ax < 0.0001 and ay < 0.0001 then
        return nil
    end

    if ax >= ay then
        local along = 0.0
        if ax > 0.0 then
            along = Impact.clamp(dy / ax, -1.0, 1.0)
        end
        local spread = 0.4
        if ay >= ax * 0.45 then
            spread = 0.95
        end
        return {
            side = dx >= 0 and 'right' or 'left',
            along = along,
            spread = spread
        }
    end

    return {
        side = dy >= 0 and 'front' or 'rear',
        along = Impact.clamp(dx / math.max(ay, 0.0001), -1.0, 1.0) * 0.35,
        spread = 0.45
    }
end

function Impact.severityFromDrop(drop, scrapeDrop, heavyDrop)
    if heavyDrop <= scrapeDrop then
        heavyDrop = scrapeDrop + 1.0
    end
    local amount = (drop - scrapeDrop) / (heavyDrop - scrapeDrop)
    return Impact.clamp(amount, 0.2, 1.0)
end

function Impact.sanitize(raw)
    if type(raw) ~= 'table' then
        return nil
    end

    local side = raw.side
    if side ~= 'left' and side ~= 'right' and side ~= 'front' and side ~= 'rear' then
        return nil
    end

    return {
        side = side,
        along = Impact.clamp(tonumber(raw.along) or 0.0, -1.0, 1.0),
        spread = Impact.clamp(tonumber(raw.spread) or 0.4, 0.15, 1.0),
        severity = Impact.clamp(tonumber(raw.severity) or 0.2, 0.0, 1.0)
    }
end

function Impact.tyresFor(impact, severity, blowoutAt)
    if type(impact) ~= 'table' then
        return {}
    end
    if impact.side ~= 'left' and impact.side ~= 'right' then
        return {}
    end
    if severity < blowoutAt then
        return {}
    end
    if impact.along >= 0.2 then
        return { 'front' }
    end
    if impact.along <= -0.2 then
        return { 'rear' }
    end
    if severity >= 0.85 then
        return { 'front', 'rear' }
    end
    return { 'front' }
end

local TYRE_INDEX = {
    left = { front = 0, rear = 4 },
    right = { front = 1, rear = 5 }
}

function Impact.tyreIndexes(side, names)
    local indexes = {}
    local map = TYRE_INDEX[side]
    if not map or type(names) ~= 'table' then
        return indexes
    end

    for i = 1, #names do
        local index = map[names[i]]
        if index then
            indexes[#indexes + 1] = index
        end
    end

    return indexes
end

function Impact.panels(impact)
    local panels = {}
    if type(impact) ~= 'table' then
        return panels
    end

    local function add(door, window)
        panels[#panels + 1] = { door = door, window = window }
    end

    local function addSide(frontDoor, frontWindow, rearDoor, rearWindow)
        local wantFront = impact.spread >= 0.75 or impact.along >= -0.05
        local wantRear = impact.spread >= 0.75 or impact.along <= 0.05
        if impact.spread < 0.75 then
            if impact.along >= 0.2 then
                wantFront = true
                wantRear = false
            elseif impact.along <= -0.2 then
                wantFront = false
                wantRear = true
            end
        end
        if wantFront then
            add(frontDoor, frontWindow)
        end
        if wantRear then
            add(rearDoor, rearWindow)
        end
    end

    if impact.side == 'left' then
        addSide(0, 0, 2, 2)
    elseif impact.side == 'right' then
        addSide(1, 1, 3, 3)
    elseif impact.side == 'front' then
        add(4, 6)
    else
        add(5, 7)
    end

    return panels
end

function Impact.dentOffsets(impact, minDim, maxDim)
    local points = {}
    if type(impact) ~= 'table' or type(minDim) ~= 'table' or type(maxDim) ~= 'table' then
        return points
    end

    local length = maxDim.y - minDim.y
    local width = maxDim.x - minDim.x
    if length < 0.05 or width < 0.05 then
        return points
    end

    local midX = (minDim.x + maxDim.x) * 0.5
    local midY = (minDim.y + maxDim.y) * 0.5
    local z = minDim.z + ((maxDim.z - minDim.z) * 0.46)

    local function add(x, y, zOffset)
        points[#points + 1] = {
            x = x,
            y = y,
            z = z + (zOffset or 0.0)
        }
    end

    if impact.side == 'left' or impact.side == 'right' then
        local x = impact.side == 'right' and (maxDim.x - (width * 0.03)) or (minDim.x + (width * 0.03))
        local center = midY + (impact.along * length * 0.28)
        center = Impact.clamp(center, minDim.y + (length * 0.12), maxDim.y - (length * 0.12))
        local reach = length * 0.2 * impact.spread
        add(x, center, 0.04)
        if impact.spread >= 0.55 then
            add(x, Impact.clamp(center + reach, minDim.y + (length * 0.08), maxDim.y - (length * 0.08)), -0.02)
            add(x, Impact.clamp(center - reach, minDim.y + (length * 0.08), maxDim.y - (length * 0.08)), 0.0)
        end
        return points
    end

    local y = impact.side == 'front' and (maxDim.y - (length * 0.03)) or (minDim.y + (length * 0.03))
    local center = midX + (impact.along * width * 0.22)
    add(center, y, 0.05)
    add(center + (width * 0.18), y, 0.0)
    add(center - (width * 0.18), y, 0.0)
    return points
end

function Impact.bodyAfter(current, severity, lossAtFull, minimum)
    if type(current) ~= 'number' then
        return minimum
    end

    local nextHealth = current - (lossAtFull * severity)
    if nextHealth < minimum then
        nextHealth = minimum
    end
    if nextHealth > current then
        nextHealth = current
    end
    return nextHealth
end

function Impact.repaired(floorBody, body, rise, healthy)
    if type(floorBody) ~= 'number' or type(body) ~= 'number' then
        return false
    end
    return body >= healthy and body >= (floorBody + rise)
end
