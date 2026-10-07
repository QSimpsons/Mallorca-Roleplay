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

local SIDE_PARTS = {
    left = {
        frontDoor = 'door_dside_f',
        rearDoor = 'door_dside_r',
        frontWheel = 'wheel_lf',
        rearWheel = 'wheel_lr',
        headlight = 'headlight_l',
        taillight = 'taillight_l'
    },
    right = {
        frontDoor = 'door_pside_f',
        rearDoor = 'door_pside_r',
        frontWheel = 'wheel_rf',
        rearWheel = 'wheel_rr',
        headlight = 'headlight_r',
        taillight = 'taillight_r'
    }
}

local function addTarget(list, bone, x, y, z, weight, outward)
    list[#list + 1] = {
        bone = bone,
        x = x or 0.0,
        y = y or 0.0,
        z = z or 0.0,
        weight = weight or 1.0,
        outward = outward or 0.0
    }
end

-- Punten op het echte plaatwerk: deur, spatbord, bumper en lamp.
-- outward duwt de deuk naar de buitenkant van dat paneel.
function Impact.bodyTargets(impact)
    local list = {}
    if type(impact) ~= 'table' then
        return list
    end

    if impact.side == 'left' or impact.side == 'right' then
        local parts = SIDE_PARTS[impact.side]
        local corner = impact.side == 'left' and -0.5 or 0.5
        if impact.spread >= 0.75 then
            addTarget(list, parts.frontDoor, 0.0, -0.06, 0.02, 1.0, 0.22)
            addTarget(list, parts.frontDoor, 0.0, -0.36, -0.06, 0.9, 0.22)
            addTarget(list, parts.frontDoor, 0.0, -0.32, -0.28, 0.62, 0.16)
            addTarget(list, parts.rearDoor, 0.0, -0.08, 0.0, 0.92, 0.22)
            addTarget(list, parts.rearDoor, 0.0, -0.3, -0.24, 0.6, 0.16)
            addTarget(list, parts.frontWheel, 0.0, 0.02, 0.34, 0.55, 0.14)
            addTarget(list, parts.rearWheel, 0.0, 0.0, 0.32, 0.45, 0.14)
            return list
        end

        if impact.along >= 0.45 then
            addTarget(list, parts.frontWheel, 0.0, 0.06, 0.36, 1.0, 0.18)
            addTarget(list, parts.headlight, 0.0, 0.06, 0.0, 0.85, 0.04)
            addTarget(list, 'bumper_f', corner, 0.1, -0.06, 0.9, 0.0)
            return list
        end

        if impact.along >= -0.05 then
            addTarget(list, parts.frontDoor, 0.0, -0.12, 0.02, 1.0, 0.24)
            addTarget(list, parts.frontDoor, 0.0, -0.4, -0.08, 0.95, 0.24)
            addTarget(list, parts.frontDoor, 0.0, -0.28, -0.3, 0.72, 0.18)
            return list
        end

        if impact.along >= -0.55 then
            addTarget(list, parts.rearDoor, 0.0, -0.1, 0.0, 1.0, 0.24)
            addTarget(list, parts.rearDoor, 0.0, -0.32, -0.22, 0.78, 0.18)
            return list
        end

        addTarget(list, parts.rearWheel, 0.0, 0.0, 0.34, 1.0, 0.16)
        addTarget(list, parts.taillight, 0.0, -0.04, 0.0, 0.8, 0.04)
        addTarget(list, 'bumper_r', corner, -0.08, 0.02, 0.85, 0.0)
        return list
    end

    if impact.side == 'front' then
        local along = impact.along or 0.0
        addTarget(list, 'bumper_f', 0.0, 0.12, -0.05, 1.0, 0.0)
        addTarget(list, 'bumper_f', -0.55, 0.08, -0.04, Impact.clamp(0.7 - along, 0.35, 1.0), 0.0)
        addTarget(list, 'bumper_f', 0.55, 0.08, -0.04, Impact.clamp(0.7 + along, 0.35, 1.0), 0.0)
        addTarget(list, 'bonnet', 0.0, 0.4, 0.02, 0.7, 0.0)
        addTarget(list, 'headlight_l', 0.0, 0.06, 0.0, Impact.clamp(0.75 - along, 0.3, 1.0), 0.0)
        addTarget(list, 'headlight_r', 0.0, 0.06, 0.0, Impact.clamp(0.75 + along, 0.3, 1.0), 0.0)
        return list
    end

    local along = impact.along or 0.0
    addTarget(list, 'bumper_r', 0.0, -0.1, 0.02, 1.0, 0.0)
    addTarget(list, 'bumper_r', -0.5, -0.06, 0.0, Impact.clamp(0.7 - along, 0.35, 1.0), 0.0)
    addTarget(list, 'bumper_r', 0.5, -0.06, 0.0, Impact.clamp(0.7 + along, 0.35, 1.0), 0.0)
    addTarget(list, 'boot', 0.0, -0.28, 0.04, 0.68, 0.0)
    addTarget(list, 'taillight_l', 0.0, -0.04, 0.0, Impact.clamp(0.75 - along, 0.3, 1.0), 0.0)
    addTarget(list, 'taillight_r', 0.0, -0.04, 0.0, Impact.clamp(0.75 + along, 0.3, 1.0), 0.0)
    return list
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
    local height = maxDim.z - minDim.z
    local doorZ = minDim.z + (height * 0.42)
    local sillZ = minDim.z + (height * 0.22)
    local bumperZ = minDim.z + (height * 0.2)

    local function add(x, y, z, weight)
        points[#points + 1] = {
            x = x,
            y = y,
            z = z,
            weight = weight or 1.0
        }
    end

    local function yAt(t)
        return minDim.y + (length * Impact.clamp(t, 0.06, 0.94))
    end

    if impact.side == 'left' or impact.side == 'right' then
        local x = impact.side == 'right' and (maxDim.x + 0.02) or (minDim.x - 0.02)
        local centerT = Impact.clamp((impact.along + 1.0) * 0.5, 0.12, 0.88)
        if impact.spread >= 0.75 then
            for step = 0, 5 do
                local t = 0.16 + (step * 0.13)
                local falloff = 1.0 - math.abs(t - centerT)
                if falloff < 0.45 then
                    falloff = 0.45
                end
                add(x, yAt(t), doorZ, 0.5 + (0.5 * falloff))
                add(x, yAt(t), sillZ, 0.35 + (0.35 * falloff))
            end
            return points
        end

        local reach = 0.08 + (0.06 * impact.spread)
        add(x, yAt(centerT), doorZ, 1.0)
        add(x, yAt(centerT - reach), doorZ - (height * 0.08), 0.85)
        add(x, yAt(centerT + reach), sillZ, 0.7)
        add(x, yAt(centerT), sillZ, 0.6)
        return points
    end

    local y = impact.side == 'front' and (maxDim.y + 0.02) or (minDim.y - 0.02)
    local center = midX + (impact.along * width * 0.2)
    local hoodZ = minDim.z + (height * 0.48)
    add(center, y, bumperZ, 1.0)
    add(center - (width * 0.22), y, bumperZ, 0.85)
    add(center + (width * 0.22), y, bumperZ, 0.85)
    add(center, impact.side == 'front' and (y - (length * 0.08)) or (y + (length * 0.08)), hoodZ, 0.65)
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
