local protected = {}
local speedBoostApplied = {}
local lastNotifyVeh = 0
local lastFullRepairAt = 0

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
    if Config.ProtectEmergencyClass and GetVehicleClass(vehicle) == (Config.EmergencyClass or 18) then
        return true
    end
    return false
end

local function vehicleSpeedKmh(vehicle)
    return GetEntitySpeed(vehicle) * 3.6
end

local function shouldProtect(vehicle)
    if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then
        return false
    end

    local ped = PlayerPedId()
    local inThis = GetVehiclePedIsIn(ped, false) == vehicle

    -- Police/ambulance in eender welk voertuig → altijd 0 damage
    if Config.ProtectAllJobVehicles and inThis and jobAllowed() then
        return true
    end

    if not modelAllowed(vehicle) then
        return false
    end

    if Config.RequireJob then
        if inThis then
            return jobAllowed()
        end
        -- Nearby matching models only when jij zelf on-duty bent
        return jobAllowed()
    end

    return true
end

local function applySpeedSettings(vehicle)
    local maxKmh = tonumber(Config.MaxSpeedKmh) or 0
    if maxKmh <= 0 then
        SetVehicleMaxSpeed(vehicle, 500.0)
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

local function restoreDoorsAndExtras(vehicle)
    for door = 0, 7 do
        if GetIsDoorValid(vehicle, door) then
            if IsVehicleDoorDamaged(vehicle, door) then
                -- Kan deuk/deur-state resetten zonder volledige Fixed
                SetVehicleDoorControl(vehicle, door, 0, 0.0)
                SetVehicleDoorShut(vehicle, door, true)
            end
            SetVehicleDoorOpen(vehicle, door, false, true)
            SetVehicleDoorShut(vehicle, door, true)
        end
    end
end

local function lockZeroDamage(vehicle)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehiclePetrolTankHealth(vehicle, 1000.0)
    SetEntityHealth(vehicle, GetEntityMaxHealth(vehicle))

    for i = 0, 7 do
        if IsVehicleTyreBurst(vehicle, i, false) or IsVehicleTyreBurst(vehicle, i, true) then
            SetVehicleTyreFixed(vehicle, i)
        end
    end

    for i = 0, 7 do
        if not IsVehicleWindowIntact(vehicle, i) then
            FixVehicleWindow(vehicle, i)
        end
    end

    if not GetIsVehicleEngineRunning(vehicle) and GetPedInVehicleSeat(vehicle, -1) ~= 0 then
        SetVehicleEngineOn(vehicle, true, true, false)
    end
end

local function fullVisualRepair(vehicle)
    -- Alleen stilstaand gebruiken — SetVehicleFixed reset snelheid/momentum.
    local velocity = GetEntityVelocity(vehicle)
    local heading = GetEntityHeading(vehicle)
    local coords = GetEntityCoords(vehicle)

    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleDirtLevel(vehicle, 0.0)
    lockZeroDamage(vehicle)
    restoreDoorsAndExtras(vehicle)

    SetEntityCoordsNoOffset(vehicle, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(vehicle, heading)
    SetEntityVelocity(vehicle, velocity.x, velocity.y, velocity.z)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, true, true, false)
end

local function needsVisualRepair(vehicle)
    if GetVehicleBodyHealth(vehicle) < 999.0 then return true end
    if GetVehicleEngineHealth(vehicle) < 999.0 then return true end
    for door = 0, 7 do
        if GetIsDoorValid(vehicle, door) and IsVehicleDoorDamaged(vehicle, door) then
            return true
        end
    end
    for i = 0, 7 do
        if not IsVehicleWindowIntact(vehicle, i) then return true end
        if IsVehicleTyreBurst(vehicle, i, false) or IsVehicleTyreBurst(vehicle, i, true) then
            return true
        end
    end
    return false
end

local function applyProtection(vehicle)
    if not DoesEntityExist(vehicle) or not IsEntityAVehicle(vehicle) then return end

    local zero = Config.ZeroDamage ~= false
    local p = Config.Proofs or {}

    SetEntityProofs(
        vehicle,
        zero or p.bullet == true,
        zero or p.fire == true,
        zero or p.explosion == true,
        zero or p.collision == true,
        zero or p.melee == true,
        zero or p.steam == true,
        true,
        zero or p.drown == true
    )

    SetEntityInvincible(vehicle, true)
    SetEntityCanBeDamaged(vehicle, false)
    SetVehicleCanBeVisiblyDamaged(vehicle, false)
    SetVehicleCanBreak(vehicle, false)
    SetVehicleTyresCanBurst(vehicle, false)
    SetVehicleWheelsCanBreak(vehicle, false)
    SetDisableVehiclePetrolTankDamage(vehicle, true)
    SetDisableVehiclePetrolTankFires(vehicle, true)
    SetVehicleExplodesOnHighExplosionDamage(vehicle, false)
    SetVehicleReceivesRampDamage(vehicle, false)
    SetVehicleHasStrongAxles(vehicle, true)
    SetVehicleEngineCanDegrade(vehicle, false)
    pcall(function()
        SetDisableVehicleEngineFires(vehicle, true)
    end)

    lockZeroDamage(vehicle)
    applySpeedSettings(vehicle)

    local speed = vehicleSpeedKmh(vehicle)
    local repairLimit = tonumber(Config.RepairBelowKmh) or 3.0

    if Config.FullRepairWhenStopped and speed <= repairLimit and needsVisualRepair(vehicle) then
        local now = GetGameTimer()
        if now - lastFullRepairAt > 1500 then
            lastFullRepairAt = now
            fullVisualRepair(vehicle)
            dbg('fullVisualRepair', vehicle)
        end
    elseif speed <= repairLimit then
        SetVehicleDeformationFixed(vehicle)
        SetVehicleDirtLevel(vehicle, 0.0)
    end

    if Config.DisableVehicleWeapons then
        DisableVehicleWeapon(true, vehicle, PlayerPedId())
    end

    protected[vehicle] = true
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
            if v ~= veh and DoesEntityExist(v) and #(coords - GetEntityCoords(v)) <= maxDist then
                if shouldProtect(v) then
                    list[#list + 1] = v
                end
            end
        end
    end

    return list
end

CreateThread(function()
    while true do
        local wait = Config.RefreshMs or 500
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped, false)

        for _, v in ipairs(collectTargets()) do
            applyProtection(v)
            if Config.Debug and v ~= lastNotifyVeh and veh == v then
                lastNotifyVeh = v
                notify(Config.Text.applied)
            end
        end

        if veh ~= 0 and shouldProtect(veh) then
            wait = 0
            SetEntityInvincible(veh, true)
            SetEntityCanBeDamaged(veh, false)
            SetVehicleCanBeVisiblyDamaged(veh, false)
            SetVehicleCanBreak(veh, false)
            lockZeroDamage(veh)

            if Config.DisableAutoBrakeAtHighSpeed then
                SetVehicleHandbrake(veh, false)
                if not GetIsVehicleEngineRunning(veh) then
                    SetVehicleEngineOn(veh, true, true, false)
                end
                applySpeedSettings(veh)
            end

            -- Stilstaand met zichtbare schade → meteen netjes maken
            if Config.FullRepairWhenStopped and vehicleSpeedKmh(veh) <= (Config.RepairBelowKmh or 3.0) then
                if needsVisualRepair(veh) and (GetGameTimer() - lastFullRepairAt) > 1500 then
                    lastFullRepairAt = GetGameTimer()
                    fullVisualRepair(veh)
                end
            end
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

AddEventHandler('gameEventTriggered', function(name)
    if name ~= 'CEventNetworkPlayerEnteredVehicle' then return end
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh ~= 0 and shouldProtect(veh) then
        applyProtection(veh)
        if vehicleSpeedKmh(veh) <= (Config.RepairBelowKmh or 3.0) then
            fullVisualRepair(veh)
        end
        if Config.Debug then
            notify(Config.Text.applied)
        end
    end
end)

RegisterCommand('repairovh', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 then return end
    if not shouldProtect(veh) and not jobAllowed() then
        return
    end
    if vehicleSpeedKmh(veh) > (Config.RepairBelowKmh or 3.0) then
        notify('Stop eerst helemaal stil om te repareren.')
        return
    end
    fullVisualRepair(veh)
    applyProtection(veh)
    notify(Config.Text.repaired or 'Voertuigschade hersteld.')
end, false)

exports('ProtectVehicle', function(vehicle)
    if vehicle and DoesEntityExist(vehicle) then
        applyProtection(vehicle)
        if vehicleSpeedKmh(vehicle) <= (Config.RepairBelowKmh or 3.0) then
            fullVisualRepair(vehicle)
        end
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
