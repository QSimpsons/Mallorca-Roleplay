Damage = {}

local running = {}
local again = {}
local againShake = {}
local appliedCount = {}
local burstWheels = {}
local bodyFloor = {}
local clearSent = {}
local soonToken = {}

local function keyOf(vehicle)
    if NetworkGetEntityIsNetworked(vehicle) then
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        if netId and netId ~= 0 then
            return 'n' .. netId
        end
    end
    return 'e' .. tostring(vehicle)
end

local function netIdOf(vehicle)
    if not NetworkGetEntityIsNetworked(vehicle) then
        return nil
    end
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then
        return nil
    end
    return netId
end

local function distanceBetween(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    local dz = (a.z or 0.0) - (b.z or 0.0)
    return math.sqrt((dx * dx) + (dy * dy) + (dz * dz))
end

function Damage.readImpacts(vehicle)
    local list = {}
    if not DoesEntityExist(vehicle) then
        return list
    end

    local ok, state = pcall(function()
        return Entity(vehicle).state.eclipseImpact
    end)
    if not ok or type(state) ~= 'table' or type(state.impacts) ~= 'table' then
        return list
    end

    for i = 1, #state.impacts do
        local item = Impact.sanitize(state.impacts[i])
        if item then
            list[#list + 1] = item
        end
    end

    return list
end

function Damage.wrecked(vehicle)
    local ok, state = pcall(function()
        return Entity(vehicle).state.eclipseAirbags
    end)
    return ok and state == true
end

function Damage.noteBody(netId, body)
    if type(netId) ~= 'number' or type(body) ~= 'number' then
        return
    end

    local floor = bodyFloor[netId]
    if not floor then
        bodyFloor[netId] = {
            body = body,
            readyAt = GetGameTimer() + Config.RepairGraceMs
        }
        return
    end

    if body < floor.body then
        floor.body = body
    end
end

function Damage.restore(vehicle)
    local key = keyOf(vehicle)
    if DoesEntityExist(vehicle) then
        SetVehicleDeformationFixed(vehicle)
        local wheels = burstWheels[key]
        if wheels then
            for index in pairs(wheels) do
                SetVehicleTyreFixed(vehicle, index)
            end
        end
    end

    burstWheels[key] = nil
    appliedCount[key] = 0
    local netId = netIdOf(vehicle)
    if netId then
        bodyFloor[netId] = nil
        clearSent[netId] = nil
    end
end

local function boneLocal(vehicle, boneName)
    local index = GetEntityBoneIndexByName(vehicle, boneName)
    if not index or index == -1 then
        return nil
    end

    local world = GetWorldPositionOfEntityBone(vehicle, index)
    if not world then
        return nil
    end

    local forward, right, up, pos = GetEntityMatrix(vehicle)
    local dx = world.x - pos.x
    local dy = world.y - pos.y
    local dz = world.z - pos.z
    return (dx * right.x) + (dy * right.y) + (dz * right.z),
        (dx * forward.x) + (dy * forward.y) + (dz * forward.z),
        (dx * up.x) + (dy * up.y) + (dz * up.z)
end

local function panelPoints(vehicle, impact, dimsMin, dimsMax)
    local resolved = {}
    local targets = Impact.bodyTargets(impact)
    for i = 1, #targets do
        local target = targets[i]
        local x, y, z = boneLocal(vehicle, target.bone)
        if x then
            local push = target.outward or 0.0
            if impact.side == 'left' then
                push = -math.abs(push)
            elseif impact.side == 'right' then
                push = math.abs(push)
            else
                push = 0.0
            end
            resolved[#resolved + 1] = {
                x = x + (target.x or 0.0) + push,
                y = y + (target.y or 0.0),
                z = z + (target.z or 0.0),
                weight = target.weight or 1.0
            }
        end
    end

    if #resolved >= 2 then
        return resolved
    end

    return Impact.dentOffsets(impact, dimsMin, dimsMax)
end

function Damage.applyVisuals(vehicle, impacts, shake, reset)
    if not DoesEntityExist(vehicle) or #impacts == 0 then
        return
    end

    if reset then
        SetVehicleDeformationFixed(vehicle)
        Wait(0)
        if not DoesEntityExist(vehicle) then
            return
        end
    end

    local minDim, maxDim = GetModelDimensions(GetEntityModel(vehicle))
    local dimsMin = { x = minDim.x, y = minDim.y, z = minDim.z }
    local dimsMax = { x = maxDim.x, y = maxDim.y, z = maxDim.z }
    SetVehicleCanBeVisiblyDamaged(vehicle, true)
    SetVehicleTyresCanBurst(vehicle, true)

    local key = keyOf(vehicle)
    local wheels = burstWheels[key] or {}
    burstWheels[key] = wheels

    for i = 1, #impacts do
        local impact = impacts[i]
        local points = panelPoints(vehicle, impact, dimsMin, dimsMax)
        local damage = Config.DentDamageMin + ((Config.DentDamageMax - Config.DentDamageMin) * impact.severity)
        local radius = Config.DentRadiusMin + ((Config.DentRadiusMax - Config.DentRadiusMin) * impact.severity)

        for p = 1, #points do
            local point = points[p]
            local weight = point.weight or 1.0
            SetVehicleDamage(vehicle, point.x, point.y, point.z, damage * weight, radius, true)
        end

        local names = Impact.tyresFor(impact, impact.severity, Config.BlowoutSeverity)
        local indexes = Impact.tyreIndexes(impact.side, names)
        local onRim = impact.severity >= Config.WheelOffSeverity
        for t = 1, #indexes do
            SetVehicleTyreBurst(vehicle, indexes[t], onRim, 1000.0)
            wheels[indexes[t]] = true
        end

        local panels = Impact.panels(impact)
        if impact.severity >= Config.GlassSeverity then
            for n = 1, #panels do
                SmashVehicleWindow(vehicle, panels[n].window)
                if panels[n].window == 6 then
                    PopOutVehicleWindscreen(vehicle)
                end
            end
        end

        if impact.severity >= Config.PanelOpenSeverity then
            if impact.side == 'front' then
                SetVehicleDoorOpen(vehicle, 4, false, true)
            elseif impact.side == 'rear' then
                SetVehicleDoorOpen(vehicle, 5, false, true)
            end
        end
    end

    local newest = impacts[#impacts]
    if shake and newest and newest.severity < 0.85 then
        local ped = PlayerPedId()
        if GetVehiclePedIsIn(ped, false) == vehicle then
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.16 + (newest.severity * 0.2))
        end
    end
end

function Damage.pump(vehicle, shake)
    if not DoesEntityExist(vehicle) then
        return
    end

    local key = keyOf(vehicle)
    if shake then
        againShake[key] = true
    end
    if running[key] then
        again[key] = true
        return
    end

    running[key] = true
    CreateThread(function()
        repeat
            local doShake = againShake[key] == true
            again[key] = false
            againShake[key] = false
            Wait(0)
            if not DoesEntityExist(vehicle) then
                break
            end

            local impacts = Damage.readImpacts(vehicle)
            if #impacts == 0 then
                if (appliedCount[key] or 0) > 0 then
                    Damage.restore(vehicle)
                end
                appliedCount[key] = 0
            else
                Damage.applyVisuals(vehicle, impacts, doShake, true)
                appliedCount[key] = #impacts
            end
        until not again[key]
        running[key] = nil
    end)
end

function Damage.pumpSoon(vehicle)
    Damage.pump(vehicle, true)
    if not DoesEntityExist(vehicle) then
        return
    end

    local key = keyOf(vehicle)
    local token = (soonToken[key] or 0) + 1
    soonToken[key] = token
    CreateThread(function()
        Wait(450)
        if soonToken[key] ~= token or not DoesEntityExist(vehicle) then
            return
        end
        Damage.pump(vehicle, false)
        Wait(700)
        if soonToken[key] ~= token or not DoesEntityExist(vehicle) then
            return
        end
        Damage.pump(vehicle, false)
    end)
end

function Damage.needsPump(vehicle)
    local key = keyOf(vehicle)
    return #Damage.readImpacts(vehicle) ~= (appliedCount[key] or 0)
end

function Damage.applyDirect(vehicle, impact)
    local sanitized = Impact.sanitize(impact)
    if not sanitized or not DoesEntityExist(vehicle) then
        return
    end

    local body = GetVehicleBodyHealth(vehicle)
    SetVehicleBodyHealth(vehicle, Impact.bodyAfter(body, sanitized.severity, Config.ScrapeBodyLoss, Config.MinBodyAfterScrape))
    if sanitized.side == 'front' then
        local engine = GetVehicleEngineHealth(vehicle)
        SetVehicleEngineHealth(vehicle, Impact.bodyAfter(engine, sanitized.severity, Config.ScrapeEngineLoss, Config.MinEngineAfterScrape))
    end

    CreateThread(function()
        Damage.applyVisuals(vehicle, { sanitized }, true, false)
    end)
end

function Damage.observe(vehicle)
    local netId = netIdOf(vehicle)
    if not netId or not DoesEntityExist(vehicle) then
        return
    end

    local impacts = Damage.readImpacts(vehicle)
    if #impacts == 0 then
        bodyFloor[netId] = nil
        return
    end

    Damage.noteBody(netId, GetVehicleBodyHealth(vehicle))
    local floor = bodyFloor[netId]
    if not floor or GetGameTimer() < floor.readyAt then
        return
    end

    local body = GetVehicleBodyHealth(vehicle)
    if not Impact.repaired(floor.body, body, Config.RepairRise, Config.RepairHealth) then
        return
    end

    local sent = clearSent[netId]
    if sent and GetGameTimer() - sent < 3000 then
        return
    end

    clearSent[netId] = GetGameTimer()
    TriggerServerEvent('Eclipse-airbags:clearImpact', netId)
end

local function rayHit(vehicle, x1, y1, z, x2, y2)
    local from = GetOffsetFromEntityInWorldCoords(vehicle, x1, y1, z)
    local to = GetOffsetFromEntityInWorldCoords(vehicle, x2, y2, z)
    local handle = StartExpensiveSynchronousShapeTestLosProbe(
        from.x, from.y, from.z,
        to.x, to.y, to.z,
        19, vehicle, 7
    )
    local _, hit, endCoords, _, entity = GetShapeTestResult(handle)
    if hit ~= true and hit ~= 1 then
        return nil
    end
    if not endCoords then
        return nil
    end

    local dist = distanceBetween(endCoords, from)
    if dist < 0.2 or dist > 2.6 then
        return nil
    end

    return {
        point = endCoords,
        entity = entity or 0,
        dist = dist
    }
end

local function contactAxes(vehicle, worldPoint)
    local forward, right, _, pos = GetEntityMatrix(vehicle)
    local dx = worldPoint.x - pos.x
    local dy = worldPoint.y - pos.y
    local dz = worldPoint.z - pos.z
    local x = (dx * right.x) + (dy * right.y) + (dz * right.z)
    local y = (dx * forward.x) + (dy * forward.y) + (dz * forward.z)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(vehicle))
    local halfW = math.max((maxDim.x - minDim.x) * 0.5, 0.001)
    local halfL = math.max((maxDim.y - minDim.y) * 0.5, 0.001)
    local midX = (minDim.x + maxDim.x) * 0.5
    local midY = (minDim.y + maxDim.y) * 0.5
    return (x - midX) / halfW, (y - midY) / halfL
end

local function probe(vehicle)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(vehicle))
    local length = maxDim.y - minDim.y
    local z = minDim.z + ((maxDim.z - minDim.z) * 0.48)
    local yFront = minDim.y + (length * 0.72)
    local yRear = minDim.y + (length * 0.28)
    local specs = {
        { side = 'left', along = 0.55, y = yFront, x1 = 0.0, x2 = minDim.x - 0.8 },
        { side = 'left', along = -0.55, y = yRear, x1 = 0.0, x2 = minDim.x - 0.8 },
        { side = 'right', along = 0.55, y = yFront, x1 = 0.0, x2 = maxDim.x + 0.8 },
        { side = 'right', along = -0.55, y = yRear, x1 = 0.0, x2 = maxDim.x + 0.8 },
        { side = 'front', along = 0.0, y1 = maxDim.y - 0.2, y2 = maxDim.y + 0.9, x1 = 0.0, x2 = 0.0 },
        { side = 'rear', along = 0.0, y1 = minDim.y + 0.2, y2 = minDim.y - 0.9, x1 = 0.0, x2 = 0.0 }
    }

    local grouped = {}
    for i = 1, #specs do
        local spec = specs[i]
        local y1 = spec.y or spec.y1
        local y2 = spec.y or spec.y2
        local hit = rayHit(vehicle, spec.x1, y1, z, spec.x2, y2)
        if hit then
            local group = grouped[spec.side]
            if not group then
                grouped[spec.side] = {
                    dist = hit.dist,
                    along = spec.along,
                    count = 1,
                    entity = hit.entity,
                    point = hit.point
                }
            else
                group.count = group.count + 1
                group.along = group.along + spec.along
                if hit.dist < group.dist then
                    group.dist = hit.dist
                    group.entity = hit.entity
                    group.point = hit.point
                end
            end
        end
    end

    local bestSide = nil
    local bestDist = nil
    for side, group in pairs(grouped) do
        if not bestDist or group.dist < bestDist then
            bestDist = group.dist
            bestSide = side
        end
    end
    if not bestSide then
        return nil
    end

    local group = grouped[bestSide]
    return {
        side = bestSide,
        along = Impact.clamp(group.along / group.count, -1.0, 1.0),
        spread = group.count >= 2 and 0.95 or 0.42
    }, group.entity, group.point
end

function Damage.inspect(vehicle, dx, dy)
    local impact, entity, point = probe(vehicle)
    if not impact then
        impact = Impact.classify(dx, dy)
    end
    if not impact then
        return nil, 0, nil
    end

    local other = 0
    local otherImpact = nil
    if entity and entity ~= 0 and DoesEntityExist(entity) and GetEntityType(entity) == 2 and point then
        other = entity
        local nx, ny = contactAxes(entity, point)
        otherImpact = Impact.classify(nx, ny)
    end

    return impact, other, otherImpact
end

function Damage.capture(vehicle, dx, dy, drop, heavy)
    if not Config.SideDamage or not DoesEntityExist(vehicle) then
        return nil, nil, nil
    end

    local impact, other, otherImpact = Damage.inspect(vehicle, dx, dy)
    if not impact and heavy then
        impact = { side = 'front', along = 0.0, spread = 0.5 }
    end
    if not impact then
        return nil, nil, nil
    end

    local severity = Impact.severityFromDrop(drop, Config.ScrapeDrop, Config.HeavyDrop)
    if heavy then
        severity = math.max(severity, 0.9)
    end
    impact.severity = severity

    local otherNetId = nil
    local packedOther = nil
    if other ~= 0 and otherImpact then
        otherImpact.severity = severity
        if NetworkGetEntityIsNetworked(other) then
            local netId = NetworkGetNetworkIdFromEntity(other)
            if netId and netId ~= 0 then
                otherNetId = netId
                packedOther = Impact.sanitize(otherImpact)
            end
        else
            Damage.applyDirect(other, otherImpact)
        end
    end

    return Impact.sanitize(impact), otherNetId, packedOther
end

AddStateBagChangeHandler('eclipseImpact', nil, function(bagName)
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 or not DoesEntityExist(entity) then
        return
    end
    Damage.pumpSoon(entity)
end)

RegisterNetEvent('Eclipse-airbags:healthGo', function(netId, severity, side)
    if type(netId) ~= 'number' or type(severity) ~= 'number' or type(side) ~= 'string' then
        return
    end

    severity = Impact.clamp(severity, 0.0, 1.0)
    CreateThread(function()
        local vehicle = NetworkGetEntityFromNetworkId(netId)
        if vehicle == 0 or not DoesEntityExist(vehicle) then
            return
        end

        local timeout = GetGameTimer() + 600
        while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do
            NetworkRequestControlOfEntity(vehicle)
            Wait(0)
        end
        if not DoesEntityExist(vehicle) then
            return
        end

        local body = GetVehicleBodyHealth(vehicle)
        SetVehicleBodyHealth(vehicle, Impact.bodyAfter(body, severity, Config.ScrapeBodyLoss, Config.MinBodyAfterScrape))
        if side == 'front' then
            local engine = GetVehicleEngineHealth(vehicle)
            SetVehicleEngineHealth(vehicle, Impact.bodyAfter(engine, severity, Config.ScrapeEngineLoss, Config.MinEngineAfterScrape))
        end

        Damage.noteBody(netId, GetVehicleBodyHealth(vehicle))
        Damage.pump(vehicle, false)
    end)
end)
