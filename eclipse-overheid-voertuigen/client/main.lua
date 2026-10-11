local protected = {} -- [veh] = true
local lastNotifyVeh = 0

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
    local name = string.lower(GetDisplayNameFromVehicleModel(model) or '')
    -- GetDisplayNameFromVehicleModel geeft vaak de game-naam; voor addons beter joaat-check via Config keys
    for spawnName, enabled in pairs(Config.Models) do
        if enabled and joaat(spawnName) == model then
            return true
        end
    end
    -- fallback display name match
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
        true, -- bulletproof tires-related flag in some builds; keep true with proofs
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

    if Config.KeepEngineHealthy then
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
    end

    if Config.KeepBodyHealthy then
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehicleFixed(vehicle)
        SetVehicleDirtLevel(vehicle, 0.0)
    end

    if Config.DisableVehicleWeapons then
        DisableVehicleWeapon(true, vehicle, PlayerPedId())
    end

    -- Extra: geen deuken zichtbaar houden
    SetEntityCanBeDamaged(vehicle, false)
    SetVehicleReceivesRampDamage(vehicle, false)

    protected[vehicle] = true
end

local function shouldProtect(vehicle)
    if not DoesEntityExist(vehicle) then return false end
    if not modelAllowed(vehicle) then return false end
    if Config.RequireJob and not jobAllowed() then
        -- Als RequireJob: alleen beschermen wanneer JIJ de juiste job hebt én in/bij het voertuig zit.
        -- Andere spelers hun PD-auto's blijven dan normaal tenzij zij het script ook draaien (client-side).
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
        local targets = collectTargets()

        for i = 1, #targets do
            local v = targets[i]
            applyProtection(v)

            if Config.Debug and v ~= lastNotifyVeh and GetVehiclePedIsIn(PlayerPedId(), false) == v then
                lastNotifyVeh = v
                notify(Config.Text.applied)
                dbg('protected', v)
            end
        end

        -- opruimen van oude refs
        for veh in pairs(protected) do
            if not DoesEntityExist(veh) then
                protected[veh] = nil
            end
        end

        Wait(wait)
    end
end)

-- Direct toepassen bij instappen
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

-- Export voor andere resources (na spawn)
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
