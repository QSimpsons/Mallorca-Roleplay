local pending = false
local lockedUntil = 0
local awaitingRepair = false
local deployedBags = {}

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

local function deleteBags(netId)
    local bags = deployedBags[netId]
    if not bags then
        return
    end

    for i = 1, #bags do
        if DoesEntityExist(bags[i]) then
            DeleteEntity(bags[i])
        end
    end

    deployedBags[netId] = nil
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

local function deployLocal(vehicle)
    local model = joaat(Config.AirbagModel)
    if not loadModel(model) then
        return
    end

    local ped = PlayerPedId()
    if Config.StallEngine and GetPedInVehicleSeat(vehicle, -1) == ped then
        awaitingRepair = true
        SetVehicleEngineOn(vehicle, false, true, true)
        SetVehicleUndriveable(vehicle, true)
        local stalled = vehicle
        SetTimeout(Config.StallMs, function()
            if DoesEntityExist(stalled) then
                SetVehicleUndriveable(stalled, false)
            end
        end)
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

    inflate(vehicle, entries)
    SetModelAsNoLongerNeeded(model)
end

RegisterNetEvent('snelle-airbags:deploy', function(netId)
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
        SmashVehicleWindow(vehicle, 6)
    end

    PlaySoundFromEntity(-1, 'Whoosh_1s_L_to_R', vehicle, 'MP_LOBBY_SOUNDS', false, 0)

    if GetVehiclePedIsIn(ped, false) == vehicle then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', Config.CameraShake)
    end

    if NetworkGetEntityOwner(vehicle) ~= PlayerId() then
        return
    end

    deployLocal(vehicle)
end)

RegisterNetEvent('snelle-airbags:denied', function()
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
    TriggerServerEvent('snelle-airbags:request', netId)

    SetTimeout(3000, function()
        pending = false
    end)
end

RegisterNetEvent('snelle-airbags:accepted', function()
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

RegisterNetEvent('snelle-airbags:repaired', function(netId)
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
        Wait(2000)

        if awaitingRepair then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                if GetPedInVehicleSeat(vehicle, -1) == ped and NetworkGetEntityIsNetworked(vehicle) then
                    local body = GetVehicleBodyHealth(vehicle)
                    local engine = GetVehicleEngineHealth(vehicle)
                    if body >= Config.RepairHealth and engine >= Config.RepairHealth then
                        local netId = NetworkGetNetworkIdFromEntity(vehicle)
                        if netId and netId ~= 0 then
                            TriggerServerEvent('snelle-airbags:checkRepair', netId)
                        end
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    loadModel(joaat(Config.AirbagModel))
end)
