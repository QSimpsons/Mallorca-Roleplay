local ESX = nil

local Push = {
    busy = false,
    mode = nil,
    forceStop = false,
    requestStop = false,
    helpText = nil,
    textUiOpen = false,
    sessionVehicle = nil
}

local session = {}

local function loadESX()
    if ESX then
        return
    end

    if exports and exports['es_extended'] then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and obj then
            ESX = obj
            return
        end
    end

    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)
end

CreateThread(function()
    while not ESX do
        loadESX()
        Wait(100)
    end
end)

local function reasonText(reason)
    local key = 'reason_' .. tostring(reason or 'unknown')
    local text = L(key)
    if text == key then
        return L('reason_unknown')
    end
    return text
end

function Push.Notify(message, nType)
    nType = nType or 'inform'
    local method = GetNotifyType()

    if method == 'ox_lib' and HasOxLib() then
        lib.notify({
            title = L('notify_title'),
            description = message,
            type = nType
        })
        return
    end

    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(message)
        return
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

function Push.NotifyReason(reason)
    Push.Notify(reasonText(reason), 'error')
end

function Push.ShowTextUI(text)
    if Push.helpText == text and Push.textUiOpen then
        return
    end

    if Push.textUiOpen then
        Push.HideTextUI()
    end

    Push.helpText = text
    Push.textUiOpen = true

    if GetTextUIType() == 'ox_lib' and HasOxLib() and lib.showTextUI then
        lib.showTextUI(text)
    end
end

function Push.HideTextUI()
    if not Push.textUiOpen and not Push.helpText then
        return
    end

    Push.textUiOpen = false
    Push.helpText = nil

    if HasOxLib() and lib.hideTextUI then
        lib.hideTextUI()
    end
end

CreateThread(function()
    while true do
        local sleep = 500
        local usingOx = GetTextUIType() == 'ox_lib' and HasOxLib() and lib.showTextUI
        if Push.helpText and not usingOx then
            sleep = 0
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName(Push.helpText)
            EndTextCommandDisplayHelp(0, false, false, -1)
        end
        Wait(sleep)
    end
end)

local function waitForServer(netId, mode)
    while not ESX do
        Wait(50)
    end

    local pending = true
    local allowed, why = false, 'timeout'

    ESX.TriggerServerCallback('snelle-voertuigduwen:canStart', function(ok, reason)
        pending = false
        allowed = ok and true or false
        why = reason
    end, netId, mode)

    local deadline = GetGameTimer() + 4000
    while pending and GetGameTimer() < deadline do
        Wait(0)
    end

    if pending then
        return false, 'timeout'
    end

    return allowed, why
end

local function requestControl(entity)
    if not DoesEntityExist(entity) then
        return false
    end

    if not NetworkGetEntityIsNetworked(entity) then
        return true
    end

    local deadline = GetGameTimer() + 1500
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < deadline do
        NetworkRequestControlOfEntity(entity)
        Wait(0)
    end

    return NetworkHasControlOfEntity(entity)
end

local function loadAnim(dict)
    if HasAnimDictLoaded(dict) then
        return true
    end

    RequestAnimDict(dict)
    local deadline = GetGameTimer() + 3000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < deadline do
        Wait(0)
    end

    return HasAnimDictLoaded(dict)
end

local function animForPed(ped)
    local name = Config.Anim.name
    if not IsPedMale(ped) and Config.Anim.nameFemale then
        name = Config.Anim.nameFemale
    end
    return Config.Anim.dict, name
end

local function playPushAnim(ped)
    local dict, name = animForPed(ped)
    if not loadAnim(dict) then
        return false
    end

    if not IsEntityPlayingAnim(ped, dict, name, 3) then
        TaskPlayAnim(ped, dict, name, 8.0, -8.0, -1, Config.Anim.flag or 1, 0.0, false, false, false)
    end

    return true
end

local function vehicleOccupied(vehicle)
    local seats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
    local lastSeat = math.max(-1, seats - 2)
    for seat = -1, lastSeat do
        local ped = GetPedInVehicleSeat(vehicle, seat)
        if ped ~= 0 and DoesEntityExist(ped) then
            if IsPedAPlayer(ped) or not Config.AllowNpcPassengers then
                return true
            end
        end
    end
    return false
end

function Push.Evaluate(vehicle)
    local ped = PlayerPedId()

    if Push.busy then
        return false, 'busy'
    end

    if IsEntityDead(ped) or IsPedDeadOrDying(ped, true) then
        return false, 'dead'
    end

    if IsPedRagdoll(ped) or IsPedFalling(ped) then
        return false, 'ragdoll'
    end

    if IsPedInAnyVehicle(ped, false) then
        return false, 'in_vehicle'
    end

    if IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) then
        return false, 'swimming'
    end

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then
        return false, 'no_vehicle'
    end

    local dist = #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
    if dist > Config.InteractDistance then
        return false, 'too_far'
    end

    if Config.BlockedClasses[GetVehicleClass(vehicle)] or IsModelBlacklisted(GetEntityModel(vehicle)) then
        return false, 'blocked'
    end

    if IsEntityAttached(vehicle) then
        return false, 'attached'
    end

    if GetEntitySpeed(vehicle) > Config.MaxVehicleSpeed then
        return false, 'moving'
    end

    if GetEntityHeightAboveGround(vehicle) > Config.MaxHeightAboveGround then
        return false, 'in_air'
    end

    if Config.BlockLocked then
        local lock = GetVehicleDoorLockStatus(vehicle)
        if lock and lock > 1 then
            return false, 'locked'
        end
    end

    if Config.RequireEngineOff and GetIsVehicleEngineRunning(vehicle) then
        return false, 'engine_on'
    end

    if Config.RequireBroken and GetVehicleEngineHealth(vehicle) > Config.BrokenEngineHealth then
        return false, 'not_broken'
    end

    if vehicleOccupied(vehicle) then
        return false, 'occupied'
    end

    return true
end

function Push.ClosestVehicle()
    local coords = GetEntityCoords(PlayerPedId())
    local best, bestDist = nil, Config.InteractDistance
    local pool = GetGamePool('CVehicle')

    for i = 1, #pool do
        local veh = pool[i]
        if DoesEntityExist(veh) then
            local dist = #(coords - GetEntityCoords(veh))
            if dist < bestDist then
                best = veh
                bestDist = dist
            end
        end
    end

    return best
end

local function networkIdOf(vehicle)
    if NetworkGetEntityIsNetworked(vehicle) then
        return NetworkGetNetworkIdFromEntity(vehicle)
    end
    return 0
end

local function lockMigration(vehicle, netId)
    if netId and netId ~= 0 then
        SetNetworkIdCanMigrate(netId, false)
        session.migrated = true
    end
end

local function prepareVehicle(vehicle)
    SetVehicleEngineOn(vehicle, false, true, true)
    SetVehicleUndriveable(vehicle, false)
    SetVehicleHandbrake(vehicle, false)
    SetVehicleForwardSpeed(vehicle, 0.0)

    if Config.HazardLights then
        SetVehicleIndicatorLights(vehicle, 0, true)
        SetVehicleIndicatorLights(vehicle, 1, true)
        session.hazards = true
    end
end

local function clearHazards(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then
        return
    end

    SetVehicleIndicatorLights(vehicle, 0, false)
    SetVehicleIndicatorLights(vehicle, 1, false)
end

local function cleanup(leaveHazards)
    local ped = PlayerPedId()
    local vehicle = session.vehicle

    if vehicle and DoesEntityExist(vehicle) then
        FreezeEntityPosition(vehicle, false)
        SetEntityVelocity(vehicle, 0.0, 0.0, 0.0)
        SetVehicleForwardSpeed(vehicle, 0.0)
        SetVehicleHandbrake(vehicle, true)
        SetVehicleEngineOn(vehicle, false, true, true)

        if session.hazards and leaveHazards then
            SetVehicleIndicatorLights(vehicle, 0, true)
            SetVehicleIndicatorLights(vehicle, 1, true)
        elseif session.hazards then
            clearHazards(vehicle)
        end

        if session.migrated and session.netId and session.netId ~= 0 then
            SetNetworkIdCanMigrate(session.netId, true)
        end
    end

    if IsEntityAttached(ped) then
        DetachEntity(ped, true, false)
    end

    ClearPedTasks(ped)
    SetPedCanRagdoll(ped, true)
    Push.HideTextUI()

    session = {}
    Push.busy = false
    Push.mode = nil
    Push.forceStop = false
    Push.requestStop = false
    Push.sessionVehicle = nil
end

local function pushSnapshot(result)
    local vehicle = session.vehicle
    if (not vehicle or vehicle == 0 or not DoesEntityExist(vehicle)) and session.reportVehicle and DoesEntityExist(session.reportVehicle) then
        vehicle = session.reportVehicle
    end

    local snap = {
        netId = session.netId or 0,
        result = result or 'done',
        plate = nil,
        model = nil,
        x = nil,
        y = nil,
        z = nil
    }

    if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
        local coords = GetEntityCoords(vehicle)
        snap.plate = GetVehicleNumberPlateText(vehicle)
        snap.model = GetEntityModel(vehicle)
        snap.x = coords.x
        snap.y = coords.y
        snap.z = coords.z
    end

    return snap
end

local function finish(message, nType, leaveHazards, result)
    local hadSession = session.netId ~= nil
    local snap = pushSnapshot(result)
    cleanup(leaveHazards)
    if hadSession then
        TriggerServerEvent('snelle-voertuigduwen:server:finish', snap)
    end
    if message then
        Push.Notify(message, nType or 'inform')
    end
end

local function disablePushControls(includeMove)
    local controls = { 21, 22, 23, 24, 25, 44, 73, 75, 140, 141, 142, 143, 257, 263, 264 }
    if includeMove then
        controls[#controls + 1] = 30
        controls[#controls + 1] = 31
        controls[#controls + 1] = 32
        controls[#controls + 1] = 33
        controls[#controls + 1] = 34
        controls[#controls + 1] = 35
    end

    for i = 1, #controls do
        DisableControlAction(0, controls[i], true)
    end
end

local function cancelPressed()
    return Push.forceStop
        or Push.requestStop
        or IsDisabledControlJustPressed(0, 73)
        or IsControlJustPressed(0, 73)
end

-- Windows VK-codes. Die volgen het teken op de toets, dus Z/Q op AZERTY
-- en W/A op QWERTY, los van de GTA-looptoetsen.
local VK_Z, VK_Q, VK_S, VK_D = 0x5A, 0x51, 0x53, 0x44
local VK_W, VK_A = 0x57, 0x41

local function rawKeyDown(vk)
    if type(IsRawKeyDown) ~= 'function' then
        return false
    end

    local ok, down = pcall(IsRawKeyDown, vk)
    return ok and down == true
end

local function controlDown(control)
    return IsDisabledControlPressed(0, control) or IsControlPressed(0, control)
end

local function readPushInput()
    local layout = Config.Keyboard or 'both'
    local forward = controlDown(32)
    local back = controlDown(33)
    local left = controlDown(34)
    local right = controlDown(35)

    if layout ~= 'qwerty' then
        forward = forward or rawKeyDown(VK_Z)
        left = left or rawKeyDown(VK_Q)
    end

    if layout ~= 'azerty' then
        forward = forward or rawKeyDown(VK_W)
        left = left or rawKeyDown(VK_A)
    end

    back = back or rawKeyDown(VK_S)
    right = right or rawKeyDown(VK_D)

    return forward, back, left, right
end

local function manualHelpText()
    local layout = Config.Keyboard or 'both'
    if layout == 'azerty' then
        return L('help_manual_azerty')
    end
    if layout == 'qwerty' then
        return L('help_manual_qwerty')
    end
    return L('help_manual')
end

local function drawProgress(label, pct)
    if pct < 0 then pct = 0 end
    if pct > 1 then pct = 1 end

    SetTextFont(4)
    SetTextScale(0.0, 0.36)
    SetTextColour(255, 255, 255, 230)
    SetTextCentre(true)
    SetTextDropshadow(1, 0, 0, 0, 200)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandDisplayText(0.5, 0.855)

    local width = 0.16
    local y = 0.90
    DrawRect(0.5, y, width, 0.012, 12, 16, 22, 180)
    local fill = width * pct
    if fill > 0.001 then
        DrawRect(0.5 - (width * 0.5) + (fill * 0.5), y, fill, 0.008, 72, 168, 255, 230)
    end
end

local function angleDelta(fromHeading, toHeading)
    return ((toHeading - fromHeading + 180.0) % 360.0) - 180.0
end

local function lerpAngle(fromHeading, toHeading, t)
    return (fromHeading + angleDelta(fromHeading, toHeading) * t) % 360.0
end

local function flatUnit(vec)
    local x, y = vec.x, vec.y
    local len = math.sqrt((x * x) + (y * y))
    if len < 0.001 then
        return nil
    end
    return vector3(x / len, y / len, 0.0)
end

local function headingOf(dir)
    return GetHeadingFromVector_2d(dir.x, dir.y)
end

local function closestRoad(coords)
    local nodeTypes = { 1, 0 }

    for i = 1, #nodeTypes do
        local ok, found, node, heading = pcall(GetClosestVehicleNodeWithHeading, coords.x, coords.y, coords.z, nodeTypes[i], 3.0, 0)
        local usable = ok and (found == true or found == 1) and type(node) == 'vector3' and type(heading) == 'number'
        if usable then
            if #(coords - node) <= Config.Shoulder.maxNodeDistance then
                local rad = math.rad(heading)
                local right = vector3(math.cos(rad), math.sin(rad), 0.0)
                return node, right, heading
            end
        end
    end

    return nil
end

local function groundLift(pos)
    local found, ground = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 2.0, false)
    if found then
        return pos.z - ground
    end
    return 0.6
end

local function placeOnGround(pos, lift, fallbackZ)
    RequestCollisionAtCoord(pos.x, pos.y, pos.z)
    local found, ground = GetGroundZFor_3dCoord(pos.x, pos.y, (fallbackZ or pos.z) + 3.0, false)
    if found then
        return vector3(pos.x, pos.y, ground + lift)
    end
    return vector3(pos.x, pos.y, fallbackZ or pos.z)
end

local function pointInWater(pos)
    local found, height = GetWaterHeight(pos.x, pos.y, pos.z + 1.0)
    if not found then
        return false
    end
    return height > (pos.z - 0.35)
end

local function clipPath(fromPos, toPos, ignore)
    local flat = vector3(toPos.x - fromPos.x, toPos.y - fromPos.y, 0.0)
    local length = #flat
    if length < 0.05 then
        return nil
    end

    local dir = flat / length
    local origin = vector3(fromPos.x, fromPos.y, fromPos.z + 0.55)
    local start = origin + (dir * 1.4)
    local dest = vector3(toPos.x, toPos.y, toPos.z + 0.55)
    local handle = StartExpensiveSynchronousShapeTestLosProbe(
        start.x, start.y, start.z,
        dest.x, dest.y, dest.z,
        1, ignore or 0, 4
    )
    local retval, hit, endCoords, _, entityHit = GetShapeTestResult(handle)
    if retval ~= 2 or hit ~= 1 or not endCoords then
        return toPos
    end

    if ignore and ignore ~= 0 and entityHit == ignore then
        return toPos
    end

    local hitDist = #(vector3(endCoords.x, endCoords.y, 0.0) - vector3(start.x, start.y, 0.0))
    local allowed = 1.4 + hitDist - 0.9
    if allowed < Config.Shoulder.minSlide then
        return nil
    end

    if allowed >= length then
        return toPos
    end

    return vector3(fromPos.x, fromPos.y, fromPos.z) + (dir * allowed)
end

-- Bestemming naast de weg. nil, reason als het niet hoeft of niet kan.
local function shoulderDestination(vehicle)
    local startPos = GetEntityCoords(vehicle)
    local node, right, roadHeading = closestRoad(startPos)
    local moveDir
    local distance
    local targetHeading

    if node and right then
        local delta = startPos - node
        local side = (delta.x * right.x) + (delta.y * right.y)
        local direction = 1.0
        local prefer = Config.Shoulder.prefer or 'auto'

        if prefer == 'left' then
            direction = -1.0
        elseif prefer == 'right' then
            direction = 1.0
        elseif side < -1.25 then
            direction = -1.0
        end

        local targetSide = direction * Config.Shoulder.offset
        local need = targetSide - side
        local minSlide = Config.Shoulder.minSlide

        -- Alleen verder de berm in. Nooit terug de rijbaan op als de auto er al voorbij staat.
        if (direction > 0 and need <= minSlide) or (direction < 0 and need >= -minSlide) then
            return nil, 'already'
        end

        if math.abs(need) > Config.Shoulder.maxSlide then
            need = Config.Shoulder.maxSlide * (need >= 0 and 1 or -1)
        end

        moveDir = need >= 0 and right or (right * -1.0)
        distance = math.abs(need)

        if Config.Shoulder.alignToRoad then
            local flipped = (roadHeading + 180.0) % 360.0
            local current = GetEntityHeading(vehicle)
            if math.abs(angleDelta(current, flipped)) < math.abs(angleDelta(current, roadHeading)) then
                targetHeading = flipped
            else
                targetHeading = roadHeading % 360.0
            end
        end
    else
        local heading = math.rad(GetEntityHeading(vehicle))
        moveDir = vector3(math.cos(heading), math.sin(heading), 0.0)
        distance = Config.Shoulder.fallbackDistance
    end

    moveDir = flatUnit(moveDir)
    if not moveDir then
        return nil, 'blocked'
    end

    local dest = startPos + (moveDir * distance)
    if pointInWater(dest) then
        return nil, 'blocked_path'
    end

    local clipped = clipPath(startPos, dest, vehicle)
    if not clipped then
        return nil, 'blocked_path'
    end

    local finalDist = #(vector3(clipped.x, clipped.y, startPos.z) - vector3(startPos.x, startPos.y, startPos.z))
    if finalDist < Config.Shoulder.minSlide then
        return nil, 'already'
    end

    return {
        start = startPos,
        dest = clipped,
        distance = finalDist,
        moveDir = flatUnit(clipped - startPos) or moveDir,
        targetHeading = targetHeading,
        lift = groundLift(startPos)
    }
end

local function attachForAside(ped, vehicle, moveDir)
    local minDim, maxDim = GetModelDimensions(GetEntityModel(vehicle))
    local origin = GetEntityCoords(vehicle)
    local rightPoint = GetOffsetFromEntityInWorldCoords(vehicle, 1.0, 0.0, 0.0)
    local vehRight = flatUnit(rightPoint - origin) or vector3(1.0, 0.0, 0.0)
    local dot = (vehRight.x * moveDir.x) + (vehRight.y * moveDir.y)
    local x = dot >= 0 and (minDim.x - 0.35) or (maxDim.x + 0.35)
    local z = minDim.z + 1.0
    local rotZ = angleDelta(GetEntityHeading(vehicle), headingOf(moveDir))

    AttachEntityToEntity(
        ped, vehicle, 0,
        x, 0.0, z,
        0.0, 0.0, rotZ,
        false, false, false, true, 0, true
    )
end

local function runAside(vehicle, netId)
    session.netId = netId
    session.reportVehicle = vehicle

    local plan, reason = shoulderDestination(vehicle)
    if not plan then
        finish(reasonText(reason or 'blocked_path'), 'error', false, reason or 'failed')
        return
    end

    local ped = PlayerPedId()
    session.vehicle = vehicle
    session.mode = 'aside'
    Push.mode = 'aside'
    Push.sessionVehicle = vehicle

    lockMigration(vehicle, netId)
    prepareVehicle(vehicle)
    SetPedCanRagdoll(ped, false)
    SetEntityNoCollisionEntity(ped, vehicle, true)
    FreezeEntityPosition(vehicle, true)
    session.frozen = true

    loadAnim(Config.Anim.dict)
    SetCurrentPedWeapon(ped, joaat('WEAPON_UNARMED'), true)
    ClearPedTasksImmediately(ped)
    attachForAside(ped, vehicle, plan.moveDir)

    local speed = Config.Shoulder.speed or 1.15
    if speed < 0.25 then
        speed = 0.25
    end

    local duration = math.max(900, math.floor((plan.distance / speed) * 1000))
    local started = GetGameTimer()
    local startHeading = GetEntityHeading(vehicle)
    local cancelled = false
    Push.ShowTextUI(L('help_aside'))

    while true do
        if not DoesEntityExist(vehicle) or IsEntityDead(ped) then
            cancelled = true
            break
        end

        disablePushControls(true)
        if cancelPressed() then
            cancelled = true
            break
        end

        local elapsed = GetGameTimer() - started
        local t = elapsed / duration
        if t > 1.0 then
            t = 1.0
        end
        local eased = t * t * (3.0 - (2.0 * t))
        local pos = plan.start + (plan.moveDir * (plan.distance * eased))
        pos = placeOnGround(pos, plan.lift, plan.start.z)

        SetEntityCoordsNoOffset(vehicle, pos.x, pos.y, pos.z, false, false, false)
        SetEntityVelocity(vehicle, 0.0, 0.0, 0.0)
        if plan.targetHeading then
            SetEntityHeading(vehicle, lerpAngle(startHeading, plan.targetHeading, eased))
        end

        if not IsEntityAttachedToEntity(ped, vehicle) then
            attachForAside(ped, vehicle, plan.moveDir)
        end

        playPushAnim(ped)
        drawProgress(L('progress_aside'), t)

        if t >= 1.0 then
            break
        end

        Wait(0)
    end

    if DoesEntityExist(vehicle) then
        FreezeEntityPosition(vehicle, false)
        session.frozen = false
        RequestCollisionAtCoord(GetEntityCoords(vehicle))
        Wait(0)
        SetVehicleOnGroundProperly(vehicle)
    end

    if cancelled then
        finish(L('cancelled'), 'inform', false, 'cancelled')
        return
    end

    finish(L('done_aside'), 'success', true, 'done')
end

local function attachToRear(ped, vehicle)
    local minDim = GetModelDimensions(GetEntityModel(vehicle))
    AttachEntityToEntity(
        ped, vehicle, 0,
        0.0, minDim.y - 0.35, minDim.z + 1.02,
        0.0, 0.0, 0.0,
        false, false, false, true, 0, true
    )
end

local function runManual(vehicle, netId)
    local ped = PlayerPedId()
    session.vehicle = vehicle
    session.netId = netId
    session.mode = 'manual'
    Push.mode = 'manual'
    Push.sessionVehicle = vehicle

    lockMigration(vehicle, netId)
    prepareVehicle(vehicle)
    SetPedCanRagdoll(ped, false)
    SetCurrentPedWeapon(ped, joaat('WEAPON_UNARMED'), true)
    ClearPedTasksImmediately(ped)
    attachToRear(ped, vehicle)
    playPushAnim(ped)
    Push.ShowTextUI(manualHelpText())
    Push.Notify(L('started_manual'), 'inform')

    local lostSince = nil

    while true do
        disablePushControls(true)

        if Push.forceStop or Push.requestStop or not DoesEntityExist(vehicle) or IsEntityDead(ped) or cancelPressed() then
            break
        end

        if NetworkGetEntityIsNetworked(vehicle) and not NetworkHasControlOfEntity(vehicle) then
            NetworkRequestControlOfEntity(vehicle)
            lostSince = lostSince or GetGameTimer()
            if GetGameTimer() - lostSince > 800 then
                finish(reasonText('no_control'), 'error', false, 'failed')
                return
            end
        else
            lostSince = nil
        end

        if not IsEntityAttachedToEntity(ped, vehicle) then
            attachToRear(ped, vehicle)
        end

        playPushAnim(ped)

        local frame = GetFrameTime()
        local turn = (Config.Manual.turnRate or 70.0) * frame
        local heading = GetEntityHeading(vehicle)
        local forward, back, left, right = readPushInput()

        if left then
            heading = heading + turn
        elseif right then
            heading = heading - turn
        end

        if left or right then
            SetEntityHeading(vehicle, heading % 360.0)
        end

        if left then
            SetVehicleSteeringAngle(vehicle, 28.0)
        elseif right then
            SetVehicleSteeringAngle(vehicle, -28.0)
        else
            SetVehicleSteeringAngle(vehicle, 0.0)
        end

        if forward then
            SetVehicleHandbrake(vehicle, false)
            SetVehicleForwardSpeed(vehicle, Config.Manual.speed or 1.05)
            SetVehicleBrakeLights(vehicle, false)
        elseif back then
            SetVehicleHandbrake(vehicle, false)
            SetVehicleForwardSpeed(vehicle, -math.abs(Config.Manual.reverseSpeed or 0.55))
            SetVehicleBrakeLights(vehicle, false)
        else
            SetVehicleForwardSpeed(vehicle, 0.0)
            SetVehicleBrakeLights(vehicle, true)
            SetVehicleHandbrake(vehicle, true)
        end

        Wait(0)
    end

    if DoesEntityExist(vehicle) then
        SetVehicleForwardSpeed(vehicle, 0.0)
        SetVehicleHandbrake(vehicle, true)
        SetVehicleSteeringAngle(vehicle, 0.0)
        local minDim = GetModelDimensions(GetEntityModel(vehicle))
        local rear = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, minDim.y - 0.85, 0.0)
        DetachEntity(ped, true, false)
        local placed = placeOnGround(rear, 1.0, GetEntityCoords(vehicle).z)
        SetEntityCoordsNoOffset(ped, placed.x, placed.y, placed.z, false, false, false)
        SetEntityHeading(ped, GetEntityHeading(vehicle))
    end

    local manualResult = 'done'
    if Push.forceStop or IsEntityDead(ped) then
        manualResult = 'cancelled'
    end
    finish(L('cancelled'), 'inform', false, manualResult)
end

function Push.Begin(mode, vehicle)
    if IsPauseMenuActive() then
        return false
    end

    if Push.busy then
        if mode == 'manual' and Push.mode == 'manual' then
            Push.requestStop = true
        end
        return false
    end

    if mode == 'manual' and Config.Manual and Config.Manual.enabled == false then
        Push.NotifyReason('blocked')
        return false
    end

    vehicle = vehicle or Push.ClosestVehicle()
    local ok, reason = Push.Evaluate(vehicle)
    if not ok then
        Push.NotifyReason(reason)
        return false
    end

    Push.busy = true
    Push.forceStop = false
    Push.requestStop = false

    local netId = networkIdOf(vehicle)
    local allowed, why = waitForServer(netId, mode)
    if not allowed then
        Push.busy = false
        Push.NotifyReason(why)
        return false
    end

    if not DoesEntityExist(vehicle) or not requestControl(vehicle) then
        Push.busy = false
        TriggerServerEvent('snelle-voertuigduwen:server:finish', netId)
        Push.NotifyReason('no_control')
        return false
    end

    local runner = mode == 'aside' and runAside or runManual
    local okRun, err = xpcall(function()
        runner(vehicle, netId)
    end, debug.traceback)

    if not okRun then
        print(('[snelle-voertuigduwen] %s'):format(err))
        if Push.busy then
            finish(reasonText('unknown'), 'error', false, 'failed')
        end
        return false
    end

    return true
end

function Push.Stop()
    if not Push.busy then
        return false
    end

    Push.requestStop = true
    return true
end

exports('PushAside', function(vehicle)
    return Push.Begin('aside', vehicle)
end)

exports('StartPush', function(vehicle)
    return Push.Begin('manual', vehicle)
end)

exports('StopPush', function()
    return Push.Stop()
end)

local function promptFor(vehicle)
    if not vehicle then
        return nil
    end

    local ok = Push.Evaluate(vehicle)
    if not ok then
        return nil
    end

    local manual = not (Config.Manual and Config.Manual.enabled == false)
    if manual then
        return ('[%s] %s    [%s] %s'):format(Config.Keys.push or 'G', L('target_push'), Config.Keys.aside or 'H', L('target_aside'))
    end

    return ('[%s] %s'):format(Config.Keys.aside or 'H', L('target_aside'))
end

CreateThread(function()
    while true do
        local sleep = 500
        if not Push.busy then
            local vehicle = Push.ClosestVehicle()
            local prompt = promptFor(vehicle)
            if prompt then
                sleep = 200
                Push.ShowTextUI(prompt)
            else
                Push.HideTextUI()
            end
        end
        Wait(sleep)
    end
end)

local function bindKey(commandName, key, description, handler)
    RegisterCommand('+' .. commandName, function()
        handler()
    end, false)

    RegisterCommand('-' .. commandName, function() end, false)
    RegisterKeyMapping('+' .. commandName, description, 'keyboard', key)
end

CreateThread(function()
    while not ESX do
        Wait(100)
    end

    bindKey('snelle_voertuig_duw', Config.Keys.push or 'G', L('target_push'), function()
        if Push.busy and Push.mode == 'manual' then
            Push.requestStop = true
            return
        end
        if Push.busy then
            return
        end
        Push.Begin('manual', Push.ClosestVehicle())
    end)

    bindKey('snelle_voertuig_kant', Config.Keys.aside or 'H', L('target_aside'), function()
        if Push.busy and Push.mode == 'aside' then
            Push.requestStop = true
            return
        end
        if Push.busy then
            return
        end
        Push.Begin('aside', Push.ClosestVehicle())
    end)

    RegisterCommand(Config.Commands.push or 'duw', function()
        if Push.busy and Push.mode == 'manual' then
            Push.requestStop = true
            return
        end
        Push.Begin('manual', Push.ClosestVehicle())
    end, false)

    RegisterCommand(Config.Commands.aside or 'aandekant', function()
        if Push.busy then
            Push.requestStop = true
            return
        end
        Push.Begin('aside', Push.ClosestVehicle())
    end, false)

    TriggerEvent('chat:addSuggestion', '/' .. (Config.Commands.push or 'duw'), L('help_command_push'))
    TriggerEvent('chat:addSuggestion', '/' .. (Config.Commands.aside or 'aandekant'), L('help_command_aside'))
end)

local function targetEntity(data)
    if type(data) == 'number' then
        return data
    end
    if type(data) == 'table' then
        return data.entity or data[1]
    end
    return nil
end

CreateThread(function()
    local waited = 0
    while GetTargetType() == 'none' and waited < 6000 do
        Wait(250)
        waited = waited + 250
    end

    local targetType = GetTargetType()
    local distance = Config.InteractDistance

    local function canInteract(entity)
        if Push.busy or IsPedInAnyVehicle(PlayerPedId(), false) then
            return false
        end
        local ok = Push.Evaluate(entity)
        return ok == true
    end

    if targetType == 'ox_target' and HasOxTarget() then
        local options = {
            {
                name = 'snelle_voertuig_kant',
                icon = 'fa-solid fa-arrows-left-right',
                label = L('target_aside'),
                distance = distance,
                canInteract = function(entity)
                    return canInteract(entity)
                end,
                onSelect = function(data)
                    Push.Begin('aside', targetEntity(data))
                end
            }
        }

        if not (Config.Manual and Config.Manual.enabled == false) then
            options[#options + 1] = {
                name = 'snelle_voertuig_duw',
                icon = 'fa-solid fa-hand',
                label = L('target_push'),
                distance = distance,
                canInteract = function(entity)
                    return canInteract(entity)
                end,
                onSelect = function(data)
                    Push.Begin('manual', targetEntity(data))
                end
            }
        end

        exports.ox_target:addGlobalVehicle(options)
        return
    end

    if targetType == 'qtarget' and HasQTarget() then
        local resource = ResourceStarted('qtarget') and 'qtarget' or 'bt-target'
        local options = {
            {
                icon = 'fas fa-arrows-alt-h',
                label = L('target_aside'),
                canInteract = function(entity)
                    return canInteract(entity)
                end,
                action = function(entity)
                    Push.Begin('aside', targetEntity(entity))
                end
            }
        }

        if not (Config.Manual and Config.Manual.enabled == false) then
            options[#options + 1] = {
                icon = 'fas fa-hand-paper',
                label = L('target_push'),
                canInteract = function(entity)
                    return canInteract(entity)
                end,
                action = function(entity)
                    Push.Begin('manual', targetEntity(entity))
                end
            }
        end

        pcall(function()
            exports[resource]:Vehicle({
                options = options,
                distance = distance
            })
        end)
    end
end)

RegisterNetEvent('snelle-voertuigduwen:client:forceStop', function()
    Push.forceStop = true
end)

AddStateBagChangeHandler('snelle_pushing', nil, function(bagName, _, value)
    if value ~= nil then
        return
    end

    local ent = GetEntityFromStateBagName(bagName)
    if not ent or ent == 0 or not DoesEntityExist(ent) then
        return
    end

    if Push.sessionVehicle and ent == Push.sessionVehicle then
        return
    end

    FreezeEntityPosition(ent, false)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    if Push.busy or session.vehicle then
        cleanup(false)
    else
        Push.HideTextUI()
    end
end)
