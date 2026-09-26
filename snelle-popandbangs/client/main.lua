local popsEnabled = true
local busy = false
local lastUse = 0
local requests = {}
local requestId = 0

local function notify(message, kind)
    kind = kind or 'inform'

    if GetNotifyType() == 'ox_lib' and lib and lib.notify then
        lib.notify({
            description = message,
            type = kind
        })
        return
    end

    if GetResourceState('es_extended') == 'started' then
        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and ESX and ESX.ShowNotification then
            ESX.ShowNotification(message)
            return
        end
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

local function notifyResult(result)
    if not result or not result.key then
        notify(L('timeout'), 'error')
        return
    end

    local key = result.key
    local kind = 'error'

    if key == 'installed' or key == 'removed' then
        kind = 'success'
        notify(L(key, result.stage or ''), kind)
        return
    end

    if key == 'upgraded' then
        notify(L(key, result.from or 0, result.stage or 0), 'success')
        return
    end

    if key == 'already' or key == 'need_higher' then
        notify(L(key, result.stage or 0), 'error')
        return
    end

    if key == 'admin_set' then
        notify(L(key, result.stage or 0, result.plate or ''), 'success')
        return
    end

    if key == 'admin_clear' then
        notify(L(key, result.plate or ''), 'success')
        return
    end

    notify(L(key), kind)
end

RegisterNetEvent('snelle-popandbangs:client:notify', function(result)
    notifyResult(result)
end)

RegisterNetEvent('snelle-popandbangs:client:response', function(id, result)
    local pending = requests[id]
    if not pending then
        return
    end

    requests[id] = nil
    pending:resolve(result or { ok = false, key = 'timeout' })
end)

local function serverCall(eventName, payload, timeout)
    requestId = requestId + 1
    local id = requestId
    local pending = promise.new()
    requests[id] = pending

    TriggerServerEvent(eventName, id, payload)

    SetTimeout(timeout or 8000, function()
        if requests[id] then
            requests[id] = nil
            pending:resolve({ ok = false, key = 'timeout' })
        end
    end)

    return Citizen.Await(pending)
end

local function closestVehicle(radius)
    local coords = GetEntityCoords(PlayerPedId())
    local best, bestDist

    for _, vehicle in ipairs(GetGamePool('CVehicle')) do
        local dist = #(coords - GetEntityCoords(vehicle))
        if dist <= radius and (not bestDist or dist < bestDist) then
            best = vehicle
            bestDist = dist
        end
    end

    return best, bestDist
end

local function hasItem(name)
    if GetInventoryType() ~= 'ox_inventory' then
        return false
    end

    local ok, count = pcall(function()
        return exports.ox_inventory:Search('count', name)
    end)

    return ok and (count or 0) > 0
end

local function runProgress(label, duration)
    local ped = PlayerPedId()

    if GetProgressType() == 'ox_lib' and lib and lib.progressCircle then
        return lib.progressCircle({
            duration = duration,
            label = label,
            position = 'bottom',
            useWhileDead = false,
            canCancel = true,
            disable = {
                move = true,
                car = true,
                combat = true
            },
            anim = {
                dict = 'mini@repair',
                clip = 'fixing_a_ped'
            }
        }) == true
    end

    RequestAnimDict('mini@repair')
    local loadedUntil = GetGameTimer() + 2000
    while not HasAnimDictLoaded('mini@repair') and GetGameTimer() < loadedUntil do
        Wait(10)
    end

    TaskPlayAnim(ped, 'mini@repair', 'fixing_a_ped', 8.0, -8.0, duration, 1, 0.0, false, false, false)
    local started = GetGameTimer()

    while GetGameTimer() - started < duration do
        DisableControlAction(0, 30, true)
        DisableControlAction(0, 31, true)
        DisableControlAction(0, 21, true)
        DisableControlAction(0, 24, true)
        DisableControlAction(0, 25, true)

        if IsControlJustPressed(0, 73) or IsControlJustPressed(0, 177) then
            ClearPedTasks(ped)
            return false
        end

        Wait(0)
    end

    ClearPedTasks(ped)
    return true
end

local function prepareVehicle(vehicle)
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then
        notify(L('exit_vehicle'), 'error')
        return false
    end

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        notify(L('no_vehicle'), 'error')
        return false
    end

    if IsBlockedClass(GetVehicleClass(vehicle)) then
        notify(L('bad_class'), 'error')
        return false
    end

    if #(GetEntityCoords(ped) - GetEntityCoords(vehicle)) > (Config.InstallDistance or 3.5) + 0.8 then
        notify(L('too_far'), 'error')
        return false
    end

    if GetEntitySpeed(vehicle) > (Config.MaxInstallSpeed or 1.5) then
        notify(L('vehicle_moving'), 'error')
        return false
    end

    local netId = VehToNet(vehicle)
    if not netId or netId == 0 then
        notify(L('invalid'), 'error')
        return false
    end

    TaskTurnPedToFaceEntity(ped, vehicle, 600)
    Wait(350)
    return netId
end

local function startInstall(stage, vehicle)
    local now = GetGameTimer()
    -- ox_inventory kan het item én de ESX-usable tegelijk sturen. De tweede negeren we stil.
    if (now - lastUse) < 1200 then
        return
    end

    if busy then
        notify(L('busy'), 'error')
        return
    end

    local cfg = Config.Stages[stage]
    if not cfg then
        return
    end

    vehicle = vehicle or select(1, closestVehicle(Config.InstallDistance or 3.5))
    lastUse = now
    busy = true

    local netId = prepareVehicle(vehicle)
    if not netId then
        busy = false
        return
    end

    local finished = runProgress(L('installing', stage), cfg.installTime or 8000)
    if not finished then
        busy = false
        notify(L('cancelled'), 'error')
        return
    end

    if not DoesEntityExist(vehicle) or #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle)) > (Config.ServerDistance or 6.0) then
        busy = false
        notify(L('too_far'), 'error')
        return
    end

    local result = serverCall('snelle-popandbangs:server:install', {
        netId = netId,
        stage = stage
    })

    busy = false
    notifyResult(result)
end

local function startRemove(vehicle)
    local now = GetGameTimer()
    if (now - lastUse) < 1200 then
        return
    end

    if busy then
        notify(L('busy'), 'error')
        return
    end

    vehicle = vehicle or select(1, closestVehicle(Config.InstallDistance or 3.5))
    lastUse = now
    busy = true

    local netId = prepareVehicle(vehicle)
    if not netId then
        busy = false
        return
    end

    local finished = runProgress(L('removing'), 6000)
    if not finished then
        busy = false
        notify(L('cancelled'), 'error')
        return
    end

    local result = serverCall('snelle-popandbangs:server:remove', {
        netId = netId
    })

    busy = false
    notifyResult(result)
end

exports('useInstallItem', function(a)
    local name = a
    if type(a) == 'table' then
        name = a.name
    end

    local stage = StageFromItem(name)
    if not stage then
        return
    end

    startInstall(stage)
end)

exports('useRemoveItem', function()
    startRemove()
end)

RegisterNetEvent('snelle-popandbangs:client:use', function(itemName)
    local stage = StageFromItem(itemName)
    if stage then
        startInstall(stage)
    end
end)

RegisterNetEvent('snelle-popandbangs:client:useRemove', function()
    startRemove()
end)

local function ownedStages()
    local list = {}
    for stage = 1, 6 do
        local cfg = Config.Stages[stage]
        if cfg and hasItem(cfg.item) then
            list[#list + 1] = stage
        end
    end
    return list
end

local function openInstallMenu(vehicle)
    local owned = ownedStages()
    if #owned == 0 then
        notify(L('no_item'), 'error')
        return
    end

    if #owned == 1 or not (HasOxLib() and lib and lib.registerContext) then
        startInstall(owned[#owned], vehicle)
        return
    end

    local options = {}
    for i = 1, #owned do
        local stage = owned[i]
        options[#options + 1] = {
            title = L('stage_title', stage),
            description = L('stage_' .. stage),
            onSelect = function()
                startInstall(stage, vehicle)
            end
        }
    end

    lib.registerContext({
        id = 'snelle_popbang_install',
        title = L('target_install'),
        options = options
    })
    lib.showContext('snelle_popbang_install')
end

CreateThread(function()
    if GetTargetType() ~= 'ox_target' then
        return
    end

    exports.ox_target:addGlobalVehicle({
        {
            name = 'snelle_popbang_install',
            label = L('target_install'),
            icon = 'fa-solid fa-fire',
            distance = Config.InstallDistance or 3.5,
            canInteract = function()
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    return false
                end
                return #ownedStages() > 0
            end,
            onSelect = function(data)
                openInstallMenu(data.entity)
            end
        },
        {
            name = 'snelle_popbang_remove',
            label = L('target_remove'),
            icon = 'fa-solid fa-wrench',
            distance = Config.InstallDistance or 3.5,
            canInteract = function()
                if IsPedInAnyVehicle(PlayerPedId(), false) then
                    return false
                end
                return hasItem(Config.RemoverItem)
            end,
            onSelect = function(data)
                startRemove(data.entity)
            end
        }
    })
end)

RegisterCommand(Config.ToggleCommand or 'popbang', function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) or GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), -1) ~= ped then
        return
    end

    popsEnabled = not popsEnabled
    if popsEnabled then
        notify(L('toggled_on'), 'success')
    else
        notify(L('toggled_off'), 'inform')
    end
end, false)

CreateThread(function()
    local cmd = Config.ToggleCommand or 'popbang'
    TriggerEvent('chat:addSuggestion', '/' .. cmd, L('toggle_help'))
end)

RegisterNetEvent('snelle-popandbangs:client:synced', function(stage)
    if not Config.NotifyOnEnter or type(stage) ~= 'number' or stage <= 0 then
        return
    end

    local cmd = Config.ToggleCommand or 'popbang'
    if popsEnabled then
        notify(L('active', stage, cmd), 'inform')
    else
        notify(L('active_muted', stage, cmd), 'inform')
    end
end)

CreateThread(function()
    local lastVehicle = 0

    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and vehicle ~= lastVehicle and GetPedInVehicleSeat(vehicle, -1) == ped then
            lastVehicle = vehicle
            local netId = VehToNet(vehicle)
            if netId and netId ~= 0 then
                TriggerServerEvent('snelle-popandbangs:server:sync', netId)
            end
        elseif vehicle == 0 then
            lastVehicle = 0
        end

        Wait(500)
    end
end)

local function playBackfireAt(pos, scale)
    if type(StartParticleFxNonLoopedAtCoord) ~= 'function' or not pos then
        return
    end

    UseParticleFxAssetNextCall('core')
    StartParticleFxNonLoopedAtCoord(
        'veh_backfire',
        pos.x, pos.y, pos.z,
        0.0, 0.0, 0.0,
        scale or 0.6,
        false, false, false
    )
end

local function exhaustBurst(vehicle, cfg)
    if not HasNamedPtfxAssetLoaded('core') then
        RequestNamedPtfxAsset('core')
        return
    end

    local played = 0
    local soundPos
    local limit = cfg.exhausts or 1
    local showFlame = math.random(100) <= (cfg.flameChance or 100)
    local scale = cfg.flameScale or 0.6

    for i = 1, #Config.ExhaustBones do
        local bone = GetEntityBoneIndexByName(vehicle, Config.ExhaustBones[i])
        if bone ~= -1 then
            local pos = GetWorldPositionOfEntityBone(vehicle, bone)
            if not soundPos then
                soundPos = pos
            end

            if showFlame then
                playBackfireAt(pos, scale)
            end

            played = played + 1
            if played >= limit then
                break
            end
        end
    end

    if not soundPos then
        soundPos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -2.1, 0.25)
        if showFlame then
            playBackfireAt(soundPos, scale)
        end
    end

    if Config.SoundMode == 'explosion' and soundPos then
        pcall(AddExplosion, soundPos.x, soundPos.y, soundPos.z, Config.ExplosionType or 61, 0.0, true, true, 0.0, true)
    end
end

local function playPop(vehicle, stage)
    local cfg = Config.Stages[stage]
    if not cfg or not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    CreateThread(function()
        local count = math.random(cfg.burst.min or 1, cfg.burst.max or 1)
        for i = 1, count do
            if not DoesEntityExist(vehicle) then
                return
            end

            exhaustBurst(vehicle, cfg)

            if i < count then
                Wait(math.random(cfg.burstGap.min or 70, cfg.burstGap.max or 120))
            end
        end
    end)
end

RegisterNetEvent('snelle-popandbangs:client:pop', function(netId, stage)
    if type(netId) ~= 'number' or type(stage) ~= 'number' then
        return
    end

    local vehicle = NetToVeh(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(vehicle)) > (Config.SyncDistance or 70.0) + 15.0 then
        return
    end

    playPop(vehicle, stage)
end)

CreateThread(function()
    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do
        Wait(50)
    end

    local lastPopAt = 0
    local lastGear = 0
    local wasAccelerating = false
    local trackedVehicle = 0

    while true do
        local sleep = 700
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= trackedVehicle then
            trackedVehicle = vehicle
            lastGear = 0
            wasAccelerating = false
        end

        if popsEnabled and vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped and GetIsVehicleEngineRunning(vehicle) and not IsBlockedClass(GetVehicleClass(vehicle)) then
            local stage = Entity(vehicle).state.popbangStage or 0
            local cfg = Config.Stages[stage]

            if cfg and GetVehicleEngineHealth(vehicle) > 0.0 then
                sleep = Config.CheckInterval or 110
                local now = GetGameTimer()
                local rpm = GetVehicleCurrentRpm(vehicle)
                local gear = GetVehicleCurrentGear(vehicle)
                local accelerating = IsControlPressed(0, 71)
                local speed = GetEntitySpeed(vehicle) * 3.6

                if (now - lastPopAt) >= cfg.cooldown then
                    local moving = speed >= (Config.MinSpeed or 18.0)
                    local revving = cfg.allowStationary and accelerating and rpm >= (cfg.antilagRpm or 0.8)
                    local want = false

                    if (moving or revving) and rpm >= cfg.minRpm and rpm <= (cfg.maxRpm or 1.05) then
                        if not accelerating and wasAccelerating then
                            want = true
                        elseif moving and gear ~= lastGear and lastGear > 0 and stage >= 2 then
                            want = true
                        elseif cfg.antilag and accelerating and rpm >= (cfg.antilagRpm or 0.8) and math.random(100) <= (cfg.antilagChance or 0) then
                            want = true
                        elseif moving and not accelerating and math.random(100) <= (cfg.chance or 0) then
                            want = true
                        end
                    end

                    if want then
                        lastPopAt = now
                        playPop(vehicle, stage)
                        local netId = VehToNet(vehicle)
                        if netId and netId ~= 0 then
                            TriggerServerEvent('snelle-popandbangs:server:pop', netId)
                        end
                    end
                end

                if gear > 0 then
                    lastGear = gear
                end
                wasAccelerating = accelerating
            else
                wasAccelerating = false
            end
        else
            wasAccelerating = false
            lastGear = 0
        end

        Wait(sleep)
    end
end)
