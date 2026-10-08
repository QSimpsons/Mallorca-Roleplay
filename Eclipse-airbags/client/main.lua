local pending = false
local lockedUntil = 0
local awaitingRepair = false
local deployedBags = {}
local healthFloor = {}
local repairSent = {}
local totaled = {}
local wrecked = {}
local noFireUntil = {}
local blockPetrolFireUntil = 0

local function isBlocked(vehicle)
    if Config.BlockedClasses[GetVehicleClass(vehicle)] then
        return true
    end

    local model = GetEntityModel(vehicle)
    for i = 1, #Config.BlacklistedModels do
        if model == joaat(Config.BlacklistedModels[i]) then
            return true
        end
    end

    return false
end

local function loadModel(model)
    if HasModelLoaded(model) then
        return true
    end

    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(0)
    end

    return true
end

local function unit(v)
    local length = math.sqrt((v.x * v.x) + (v.y * v.y) + (v.z * v.z))
    if length < 0.0001 then
        return v
    end

    return vector3(v.x / length, v.y / length, v.z / length)
end

local function setScale(entity, scale)
    local forward, right, up, pos = GetEntityMatrix(entity)
    forward = unit(forward)
    right = unit(right)
    up = unit(up)

    SetEntityMatrix(
        entity,
        forward.x * scale, forward.y * scale, forward.z * scale,
        right.x * scale, right.y * scale, right.z * scale,
        up.x * scale, up.y * scale, up.z * scale,
        pos.x, pos.y, pos.z
    )
end

local function easeOut(t)
    local left = 1.0 - t
    return 1.0 - (left * left * left)
end

local function attachBag(bag, vehicle, bone, spec, t)
    local x = spec.from.x + ((spec.to.x - spec.from.x) * t)
    local y = spec.from.y + ((spec.to.y - spec.from.y) * t)
    local z = spec.from.z + ((spec.to.z - spec.from.z) * t)

    AttachEntityToEntity(
        bag, vehicle, bone,
        x, y, z,
        spec.rot.x, spec.rot.y, spec.rot.z,
        true, true, false, false, 2, true
    )
end

local function deleteObject(obj)
    if not DoesEntityExist(obj) then
        return
    end

    SetEntityAsMissionEntity(obj, true, true)
    local timeout = GetGameTimer() + 600
    while not NetworkHasControlOfEntity(obj) and GetGameTimer() < timeout do
        NetworkRequestControlOfEntity(obj)
        Wait(0)
    end

    if DoesEntityExist(obj) then
        DeleteEntity(obj)
    end
end

local function removeAirbagsFromVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    local model = joaat(Config.AirbagModel)
    local objects = GetGamePool('CObject')

    for i = 1, #objects do
        local obj = objects[i]
        if DoesEntityExist(obj) and GetEntityModel(obj) == model then
            local attached = GetEntityAttachedTo(obj) == vehicle or IsEntityAttachedToEntity(obj, vehicle)
            if attached then
                deleteObject(obj)
            end
        end
    end
end

local function deleteBags(netId)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle ~= 0 then
        removeAirbagsFromVehicle(vehicle)
    end

    local bags = deployedBags[netId]
    if bags then
        for i = 1, #bags do
            deleteObject(bags[i])
        end
    end

    deployedBags[netId] = nil
    healthFloor[netId] = nil
    repairSent[netId] = nil
    totaled[netId] = nil
    wrecked[netId] = nil

    if vehicle ~= 0 and DoesEntityExist(vehicle) then
        SetVehicleUndriveable(vehicle, false)
        SetVehicleHandbrake(vehicle, false)
        SetEntityMaxSpeed(vehicle, 0.0)
    end
end

local function rememberFloor(netId, body, engine)
    local floor = healthFloor[netId]
    if not floor then
        healthFloor[netId] = {
            body = body,
            engine = engine,
            readyAt = GetGameTimer() + Config.RepairGraceMs
        }
        return
    end

    if body < floor.body then
        floor.body = body
    end
    if engine < floor.engine then
        floor.engine = engine
    end
end

local function looksRepaired(netId, body, engine)
    local floor = healthFloor[netId]
    if not floor or GetGameTimer() < floor.readyAt then
        return false
    end

    local bodyRose = body >= floor.body + Config.RepairRise
    local engineRose = engine >= floor.engine + Config.RepairRise
    if bodyRose or engineRose then
        return true
    end

    if body >= Config.RepairHealth and engine >= Config.RepairHealth then
        return floor.body < Config.RepairHealth or floor.engine < Config.RepairHealth
    end

    return false
end

local function inflate(vehicle, entries)
    local started = GetGameTimer()

    while DoesEntityExist(vehicle) do
        local t = (GetGameTimer() - started) / Config.InflateMs
        if t > 1.0 then
            t = 1.0
        end

        local eased = easeOut(t)
        local scale = Config.StartScale + ((1.0 - Config.StartScale) * eased)

        for i = 1, #entries do
            local entry = entries[i]
            if DoesEntityExist(entry.bag) then
                attachBag(entry.bag, vehicle, entry.bone, entry.spec, eased)
                setScale(entry.bag, scale)
            end
        end

        if t >= 1.0 then
            break
        end

        Wait(0)
    end
end

local function spawnAirbag(vehicle, spec, model)
    local bone = GetEntityBoneIndexByName(vehicle, spec.bone)
    if bone == -1 then
        return nil
    end

    local pos = GetEntityCoords(vehicle)
    local bag = CreateObject(model, pos.x, pos.y, pos.z, true, true, false)
    if bag == 0 or not DoesEntityExist(bag) then
        return nil
    end

    SetEntityAsMissionEntity(bag, true, true)
    SetEntityCollision(bag, false, false)
    FreezeEntityPosition(bag, true)
    attachBag(bag, vehicle, bone, spec, 0.0)
    setScale(bag, Config.StartScale)

    return { bag = bag, bone = bone, spec = spec }
end

local function writeOff(vehicle)
    if not Config.TotalLoss or vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    local body = GetVehicleBodyHealth(vehicle)
    local engine = GetVehicleEngineHealth(vehicle)
    if body > Config.CrashBodyHealth then
        SetVehicleBodyHealth(vehicle, Config.CrashBodyHealth)
    end
    if engine > Config.CrashEngineHealth then
        SetVehicleEngineHealth(vehicle, Config.CrashEngineHealth)
    end

    SetVehiclePetrolTankHealth(vehicle, 1000.0)
    SetDisableVehiclePetrolTankFires(vehicle, true)
    SetDisableVehiclePetrolTankDamage(vehicle, true)
    StopEntityFire(vehicle)
    SetVehicleUndriveable(vehicle, true)
    SetVehicleEngineOn(vehicle, false, true, true)
    SetEntityMaxSpeed(vehicle, 0.1)
    SetVehicleForwardSpeed(vehicle, 0.0)
    SetVehicleHandbrake(vehicle, true)
    SetVehicleDoorOpen(vehicle, 4, false, true)

    for window = 0, 7 do
        SmashVehicleWindow(vehicle, window)
    end

    for _, wheel in ipairs({ 0, 1, 4, 5 }) do
        SetVehicleTyreBurst(vehicle, wheel, true, 1000.0)
    end

    SetVehicleExplodesOnHighExplosionDamage(vehicle, false)
    SetVehicleDamage(vehicle, 0.0, 1.4, 0.2, 180.0, 40.0, true)
    SetVehicleDamage(vehicle, 0.4, 1.0, 0.15, 120.0, 30.0, true)
    SetVehicleDamage(vehicle, -0.4, 1.0, 0.15, 120.0, 30.0, true)

    if GetVehicleEngineHealth(vehicle) < Config.CrashEngineHealth then
        SetVehicleEngineHealth(vehicle, Config.CrashEngineHealth)
    end
    StopEntityFire(vehicle)
    local coords = GetEntityCoords(vehicle)
    StopFireInRange(coords.x, coords.y, coords.z, 8.0)
end

local function quench(vehicle)
    SetDisableVehiclePetrolTankFires(vehicle, true)
    SetDisableVehiclePetrolTankDamage(vehicle, true)
    if IsEntityOnFire(vehicle) then
        StopEntityFire(vehicle)
    end

    local coords = GetEntityCoords(vehicle)
    StopFireInRange(coords.x, coords.y, coords.z, 6.5)
end

local function spillAt(vehicle, x, y)
    local pos = GetOffsetFromEntityInWorldCoords(vehicle, x, y, 0.2)
    local found, ground = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 2.0, false)
    local z = found and (ground + 0.03) or pos.z
    return pos.x, pos.y, z
end

local function leaveFluids(vehicle)
    local fluids = Config.Fluids
    local pools = {
        { kind = 'petrol', x = 0.15, y = -1.45 },
        { kind = 'petrol', x = -0.35, y = -1.9 },
        { kind = 'oil', x = -0.1, y = 1.25 },
        { kind = 'oil', x = 0.35, y = 1.55 },
        { kind = 'coolant', x = 0.7, y = 0.85 },
        { kind = 'coolant', x = 0.95, y = 0.35 }
    }

    for i = 1, #pools do
        local pool = pools[i]
        local x, y, z = spillAt(vehicle, pool.x, pool.y)

        if pool.kind == 'petrol' then
            AddPetrolDecal(x, y, z, 2.0, fluids.petrol.width, fluids.petrol.transparency)
            AddDecal(9003, x, y, z, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0, fluids.petrol.width, fluids.petrol.width, 0.15, 0.12, 0.05, 0.9, fluids.coolant.seconds, false, false, false)
        elseif pool.kind == 'oil' then
            local placed = pcall(AddOilDecal, x, y, z, 1.5, fluids.oil.width, fluids.oil.transparency)
            if not placed then
                AddDecal(9002, x, y, z, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0, fluids.oil.width, fluids.oil.width, 0.02, 0.02, 0.02, 1.0, fluids.coolant.seconds, false, false, false)
            end
        else
            local coolant = fluids.coolant
            AddDecal(9000, x, y, z, 0.0, 0.0, -1.0, 0.0, 1.0, 0.0, coolant.width, coolant.width, coolant.r, coolant.g, coolant.b, coolant.opacity, coolant.seconds, false, false, false)
        end
    end

    blockPetrolFireUntil = GetGameTimer() + Config.NoFireMs
end

local function deployLocal(vehicle)
    local model = joaat(Config.AirbagModel)
    if not loadModel(model) then
        return
    end

    local ped = PlayerPedId()
    if GetPedInVehicleSeat(vehicle, -1) == ped then
        awaitingRepair = true
    end

    local specs = { Config.Driver, Config.Passenger }
    local entries = {}
    for i = 1, #specs do
        local entry = spawnAirbag(vehicle, specs[i], model)
        if entry then
            entries[#entries + 1] = entry
        end
    end

    if #entries == 0 then
        SetModelAsNoLongerNeeded(model)
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    deployedBags[netId] = {}
    for i = 1, #entries do
        deployedBags[netId][i] = entries[i].bag
    end

    writeOff(vehicle)
    wrecked[netId] = true
    totaled[netId] = true
    noFireUntil[netId] = GetGameTimer() + Config.NoFireMs
    rememberFloor(netId, GetVehicleBodyHealth(vehicle), GetVehicleEngineHealth(vehicle))

    pcall(function()
        Entity(vehicle).state:set('eclipseAirbags', true, true)
    end)

    inflate(vehicle, entries)
    SetModelAsNoLongerNeeded(model)
end

RegisterNetEvent('Eclipse-airbags:deploy', function(netId)
    if type(netId) ~= 'number' then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(vehicle)
    if #(GetEntityCoords(ped) - coords) > Config.SyncDistance then
        return
    end

    if Config.PopWindscreen then
        PopOutVehicleWindscreen(vehicle)
        for window = 0, 7 do
            SmashVehicleWindow(vehicle, window)
        end
    end

    PlaySoundFromEntity(-1, 'Whoosh_1s_L_to_R', vehicle, 'MP_LOBBY_SOUNDS', false, 0)

    if GetVehiclePedIsIn(ped, false) == vehicle then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', Config.CameraShake)
    end

    quench(vehicle)
    leaveFluids(vehicle)
    totaled[netId] = true
    noFireUntil[netId] = GetGameTimer() + Config.NoFireMs
    SetVehicleUndriveable(vehicle, true)
    SetVehicleEngineOn(vehicle, false, true, true)
    SetEntityMaxSpeed(vehicle, 0.1)

    if not wrecked[netId] and (NetworkGetEntityOwner(vehicle) == PlayerId() or GetPedInVehicleSeat(vehicle, -1) == ped) then
        writeOff(vehicle)
        wrecked[netId] = true
    end

    if NetworkGetEntityOwner(vehicle) ~= PlayerId() then
        return
    end

    deployLocal(vehicle)
end)

RegisterNetEvent('Eclipse-airbags:denied', function()
    pending = false
end)

local function requestDeploy(vehicle)
    local now = GetGameTimer()
    if pending or now < lockedUntil then
        return
    end

    if not NetworkGetEntityIsNetworked(vehicle) then
        return
    end

    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if not netId or netId == 0 then
        return
    end

    pending = true
    lockedUntil = now + 4000
    writeOff(vehicle)
    quench(vehicle)
    wrecked[netId] = true
    totaled[netId] = true
    noFireUntil[netId] = GetGameTimer() + Config.NoFireMs
    rememberFloor(netId, GetVehicleBodyHealth(vehicle), GetVehicleEngineHealth(vehicle))
    TriggerServerEvent('Eclipse-airbags:request', netId)

    SetTimeout(3000, function()
        pending = false
    end)
end

RegisterNetEvent('Eclipse-airbags:accepted', function()
    pending = false
end)

CreateThread(function()
    local history = {}
    local collidedAt = 0
    local lastPush = 0

    while true do
        local sleep = 500
        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(vehicle, -1) == ped and not isBlocked(vehicle) then
                local speed = GetEntitySpeed(vehicle) * 3.6

                if speed > 15.0 then
                    sleep = 0
                    local now = GetGameTimer()

                    if HasEntityCollidedWithAnything(vehicle) then
                        collidedAt = now
                    end

                    if now - lastPush >= 40 then
                        lastPush = now
                        history[#history + 1] = { t = now, speed = speed }

                        local oldest = history[1]
                        while oldest and now - oldest.t > Config.SampleMs do
                            table.remove(history, 1)
                            oldest = history[1]
                        end

                        if oldest and oldest.t ~= now and now - collidedAt <= Config.SampleMs + 80 then
                            local drop = oldest.speed - speed
                            if drop >= Config.SpeedDrop and oldest.speed >= Config.MinSpeed then
                                requestDeploy(vehicle)
                                collidedAt = 0
                                history = {}
                            end
                        end
                    end
                else
                    history = {}
                    collidedAt = 0
                    sleep = 200
                end
            else
                history = {}
                collidedAt = 0
            end
        else
            history = {}
            collidedAt = 0
            pending = false
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('Eclipse-airbags:repaired', function(netId)
    awaitingRepair = false
    if type(netId) == 'number' then
        deleteBags(netId)
        return
    end

    for id in pairs(deployedBags) do
        deleteBags(id)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for netId in pairs(deployedBags) do
        deleteBags(netId)
    end
end)

CreateThread(function()
    while true do
        Wait(750)

        local coords = GetEntityCoords(PlayerPedId())
        local vehicles = GetGamePool('CVehicle')

        for i = 1, #vehicles do
            local vehicle = vehicles[i]
            if DoesEntityExist(vehicle) and #(GetEntityCoords(vehicle) - coords) < 40.0 and NetworkGetEntityIsNetworked(vehicle) then
                local netId = NetworkGetNetworkIdFromEntity(vehicle)
                local marked = deployedBags[netId] ~= nil
                if not marked then
                    local ok, state = pcall(function()
                        return Entity(vehicle).state.eclipseAirbags
                    end)
                    marked = ok and state == true
                end

                local sentAt = repairSent[netId]
                if marked and netId and netId ~= 0 and (not sentAt or GetGameTimer() - sentAt > 3000) then
                    local body = GetVehicleBodyHealth(vehicle)
                    local engine = GetVehicleEngineHealth(vehicle)
                    rememberFloor(netId, body, engine)
                    if looksRepaired(netId, body, engine) then
                        repairSent[netId] = GetGameTimer()
                        TriggerServerEvent('Eclipse-airbags:checkRepair', netId)
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    loadModel(joaat(Config.AirbagModel))
end)

CreateThread(function()
    while true do
        if GetGameTimer() < blockPetrolFireUntil then
            SetDisablePetrolDecalsIgnitingThisFrame()
            Wait(0)
        else
            Wait(400)
        end
    end
end)

CreateThread(function()
    while true do
        local waitMs = 1000
        local now = GetGameTimer()

        for netId in pairs(totaled) do
            waitMs = 400
            local vehicle = NetworkGetEntityFromNetworkId(netId)
            if vehicle ~= 0 and DoesEntityExist(vehicle) then
                SetVehicleUndriveable(vehicle, true)
                SetVehicleHandbrake(vehicle, true)
                SetEntityMaxSpeed(vehicle, 0.1)
                SetVehicleEngineOn(vehicle, false, true, true)
            end
        end

        for netId, untilAt in pairs(noFireUntil) do
            if now > untilAt then
                noFireUntil[netId] = nil
            else
                waitMs = 0
                local vehicle = NetworkGetEntityFromNetworkId(netId)
                if vehicle ~= 0 and DoesEntityExist(vehicle) then
                    quench(vehicle)
                    if GetVehicleEngineHealth(vehicle) < Config.CrashEngineHealth then
                        SetVehicleEngineHealth(vehicle, Config.CrashEngineHealth)
                        if healthFloor[netId] then
                            healthFloor[netId].engine = Config.CrashEngineHealth
                        end
                    end
                end
            end
        end

        Wait(waitMs)
    end
end)
