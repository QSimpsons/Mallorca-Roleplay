local protected = {} -- [veh] = true
local lastNotifyVeh = 0
local speedBoostApplied = {} -- [veh] = true

local function dbg(...)
    if Config.Debug then
        print('[eclipse-overheid-voertuigen]', ...)
    end
end

local function notify(msg)
    if GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:notify({ description = msg, type = 'inform' })
        return
    end
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function playerJobName()
    local ok, ESX = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)
    if not ok or not ESX then return nil end
    local data = ESX.GetPlayerData and ESX.GetPlayerData() or nil
    if data and data.job then
        return data.job.name
    end
    return nil
end

local function jobAllowed()
    if not Config.RequireJob then return true end
    local job = playerJobName()
    if not job then return false end
    return Config.Jobs[job] == true
end

local function modelAllowed(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    local model = GetEntityModel(vehicle)
    for spawnName, enabled in pairs(Config.Models) do
        if enabled and joaat(spawnName) == model then
            return true
        end
    end
    local name = string.lower(GetDisplayNameFromVehicleModel(model) or '')
    if name ~= '' and Config.Models[name] then
        return true
    end
    if Config.ProtectEmergencyClass then
        if GetVehicleClass(vehicle) == (Config.EmergencyClass or 18) then
            return true
        end
    end
    return false
end

local function vehicleSpeedKmh(vehicle)
    return GetEntitySpeed(vehicle) * 3.6
end

local function applySpeedSettings(vehicle)
    -- MaxSpeedKmh <= 0 → geen limiet (sneller dan 295 mag).
    local maxKmh = tonumber(Config.MaxSpeedKmh) or 0
    if maxKmh <= 0 then
        -- Hoge cap i.p.v. 0.0 (0 reset naar standaard game-limiet)
        SetVehicleMaxSpeed(vehicle, 500.0) -- m/s ≈ ver boven 295 km/h
        SetEntityMaxSpeed(vehicle, 500.0)
    else
        local ms = maxKmh / 3.6
        SetVehicleMaxSpeed(vehicle, ms)
        SetEntityMaxSpeed(vehicle, ms)
    end

    local mult = tonumber(Config.TopSpeedMultiplier) or 1.0
    if mult < 0.1 then mult = 0.1 end
    if not speedBoostApplied[vehicle] then
        ModifyVehicleTopSpeed(vehicle, mult)
        speedBoostApplied[vehicle] = true
    end
end

local function applyProtection(vehicle)
    if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then return end

    local p = Config.Proofs or {}
    SetEntityProofs(
        vehicle,
        p.bullet == true,
        p.fire == true,
        p.explosion == true,
        p.collision == true,
        p.melee == true,
        p.steam == true,
        true,
        p.drown == true
    )

    SetVehicleCanBeVisiblyDamaged(vehicle, Config.CanBeVisiblyDamaged == true)
    SetVehicleTyresCanBurst(vehicle, Config.TyresCanBurst == true)
    SetDisableVehiclePetrolTankDamage(vehicle, true)
    SetDisableVehiclePetrolTankFires(vehicle, true)
    SetVehicleExplodesOnHighExplosionDamage(vehicle, false)

    if Config.StrongAxles then
        SetVehicleHasStrongAxles(vehicle, true)
    end

    if Config.EngineNeverDegrade then
        SetVehicleEngineCanDegrade(vehicle, false)
    end

    -- Nooit SetVehicleFixed tijdens het rijden: dat laat de auto "stoppen en weer wegrijden".
    local moving = vehicleSpeedKmh(vehicle) > 5.0

    if Config.KeepEngineHealthy then
        if GetVehicleEngineHealth(vehicle) < 950.0 then
            SetVehicleEngineHealth(vehicle, 1000.0)
        end
        if GetVehiclePetrolTankHealth(vehicle) < 950.0 then
            SetVehiclePetrolTankHealth(vehicle, 1000.0)
        end
        -- Houd motor aan bij hoge snelheid
        if moving and not GetIsVehicleEngineRunning(vehicle) then
            SetVehicleEngineOn(vehicle, true, true, false)
        end
    end

    if Config.KeepBodyHealthy and not moving then
        if GetVehicleBodyHealth(vehicle) < 950.0 then
            SetVehicleBodyHealth(vehicle, 1000.0)
            SetVehicleDeformationFixed(vehicle)
        end
        SetVehicleDirtLevel(vehicle, 0.0)
    elseif Config.KeepBodyHealthy then
        -- Tijdens rijden alleen health bijhouden, geen Fixed/Deformation (breekt snelheid)
        if GetVehicleBodyHealth(vehicle) < 200.0 then
            SetVehicleBodyHealth(vehicle, 1000.0)
        end
    end

    if Config.DisableVehicleWeapons then
        DisableVehicleWeapon(true, vehicle, PlayerPedId())
    end

    SetEntityCanBeDamaged(vehicle, false)
    SetVehicleReceivesRampDamage(vehicle, false)

    applySpeedSettings(vehicle)

    protected[vehicle] = true
end

local function shouldProtect(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    if not modelAllowed(vehicle) then return false end
    if Config.RequireJob and not jobAllowed() then
        local ped = PlayerPedId()
        if GetVehiclePedIsIn(ped, false) ~= vehicle then
            return false
        end
        return jobAllowed()
    end
    return true
end

local function collectTargets()
    local list = {}
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh ~= 0 and shouldProtect(veh) then
        list[#list + 1] = veh
    end

    if not Config.OnlyOccupiedByPlayer then
        local coords = GetEntityCoords(ped)
        local pool = GetGamePool('CVehicle')
        local maxDist = Config.NearbyDistance or 60.0
        for i = 1, #pool do
            local v = pool[i]
            if v ~= veh and DoesEntityExist(v) then
                if #(coords - GetEntityCoords(v)) <= maxDist and shouldProtect(v) then
                    list[#list + 1] = v
                end
            end
        end
    end

    return list
end

CreateThread(function()
    while true do
        local wait = Config.RefreshMs or 1000
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)
        local targets = collectTargets()

        for i = 1, #targets do
            local v = targets[i]
            applyProtection(v)

            if Config.Debug and v ~= lastNotifyVeh and veh == v then
                lastNotifyVeh = v
                notify(Config.Text.applied)
                dbg('protected', v)
            end
        end

        -- Tijdens hard rijden: geen auto-handrem / engine-off glitches
        if Config.DisableAutoBrakeAtHighSpeed and veh ~= 0 and shouldProtect(veh) then
            wait = 0
            SetVehicleHandbrake(veh, false)
            if not GetIsVehicleEngineRunning(veh) then
                SetVehicleEngineOn(veh, true, true, false)
            end
            -- Voorkom dat cruise/limiter de auto laat inhouden
            applySpeedSettings(veh)
        end

        for entity in pairs(protected) do
            if not DoesEntityExist(entity) then
                protected[entity] = nil
                speedBoostApplied[entity] = nil
            end
        end

        Wait(wait)
    end
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkPlayerEnteredVehicle' then return end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 and shouldProtect(veh) then
        applyProtection(veh)
        if Config.Debug then
            notify(Config.Text.applied)
        end
    end
end)

exports('ProtectVehicle', function(vehicle)
    if vehicle and DoesEntityExist(vehicle) then
        applyProtection(vehicle)
        return true
    end
    return false
end)

exports('IsProtectedModel', function(model)
    if type(model) == 'string' then
        return Config.Models[string.lower(model)] == true
    end
    if type(model) == 'number' then
        for spawnName, enabled in pairs(Config.Models) do
            if enabled and joaat(spawnName) == model then
                return true
            end
        end
    end
    return false
end)
