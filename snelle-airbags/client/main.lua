local pending = false
local lockedUntil = 0
local awaitingRepair = false

local function notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

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
    if not IsModelInCdimage(model) then
        return false
    end

    RequestModel(model)
    local timeout = GetGameTimer() + 3000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(0)
    end

    return true
end

local function launchBag(vehicle, offset, model)
    local pos = GetOffsetFromEntityInWorldCoords(vehicle, offset.x, offset.y, offset.z)
    local bag = CreateObject(model, pos.x, pos.y, pos.z, false, false, false)
    if bag == 0 or not DoesEntityExist(bag) then
        return nil
    end

    SetEntityAsMissionEntity(bag, true, true)
    SetEntityCollision(bag, true, true)
    SetEntityDynamic(bag, true)
    SetEntityNoCollisionEntity(bag, vehicle, false)

    local forward = GetEntityForwardVector(vehicle)
    local velocity = GetEntityVelocity(vehicle)
    local spread = Config.Spread

    SetEntityVelocity(
        bag,
        velocity.x + forward.x * Config.LaunchForward + (math.random() - 0.5) * spread,
        velocity.y + forward.y * Config.LaunchForward + (math.random() - 0.5) * spread,
        velocity.z + Config.LaunchUp + math.random() * 2.0
    )
    ApplyForceToEntity(
        bag, 1,
        (math.random() - 0.5) * 4.0,
        (math.random() - 0.5) * 4.0,
        math.random() * 2.0,
        (math.random() - 0.5) * 2.0,
        (math.random() - 0.5) * 2.0,
        (math.random() - 0.5) * 2.0,
        0, false, true, true, false, true
    )

    return bag
end

local function playBurst(vehicle)
    if not HasNamedPtfxAssetLoaded('core') then
        RequestNamedPtfxAsset('core')
        local timeout = GetGameTimer() + 1500
        while not HasNamedPtfxAssetLoaded('core') and GetGameTimer() < timeout do
            Wait(0)
        end
    end

    if not HasNamedPtfxAssetLoaded('core') then
        return
    end

    UseParticleFxAssetNextCall('core')
    StartParticleFxNonLoopedOnEntity(
        'ent_sht_steam',
        vehicle,
        0.0, 0.85, 0.55,
        0.0, 0.0, 0.0,
        1.35,
        false, false, false
    )
end

local function deployLocal(vehicle)
    if Config.PopWindscreen then
        PopOutVehicleWindscreen(vehicle)
        SmashVehicleWindow(vehicle, 6)
    end

    playBurst(vehicle)
    PlaySoundFromEntity(-1, 'Whoosh_1s_L_to_R', vehicle, 'MP_LOBBY_SOUNDS', false, 0)

    local ped = PlayerPedId()
    if GetVehiclePedIsIn(ped, false) == vehicle then
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', Config.CameraShake)
        notify(Config.Notify)

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
    end

    local model = joaat(Config.Prop)
    if not loadModel(model) then
        return
    end

    local bags = {}
    for i = 1, #Config.Airbags do
        local bag = launchBag(vehicle, Config.Airbags[i], model)
        if bag then
            bags[#bags + 1] = bag
        end
    end

    SetModelAsNoLongerNeeded(model)

    if #bags == 0 then
        return
    end

    SetTimeout(Config.DespawnMs, function()
        for i = 1, #bags do
            if DoesEntityExist(bags[i]) then
                DeleteEntity(bags[i])
            end
        end
    end)
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

RegisterNetEvent('snelle-airbags:repaired', function()
    awaitingRepair = false
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
