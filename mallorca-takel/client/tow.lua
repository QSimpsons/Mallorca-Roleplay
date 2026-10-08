Tow = Tow or {}

local attachedVehicle = 0
local attachedTow = 0
local attachedCfg = nil
local busy = false

local function modelHash(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return 0
    end
    return GetEntityModel(vehicle)
end

function Tow.GetProfile(vehicle)
    local hash = modelHash(vehicle)
    if hash == 0 then
        return nil
    end
    return Config.TowVehicles[hash]
end

function Tow.IsTowVehicle(vehicle)
    return Tow.GetProfile(vehicle) ~= nil
end

function Tow.GetAttached()
    if attachedVehicle ~= 0 and DoesEntityExist(attachedVehicle) and DoesEntityExist(attachedTow) then
        return attachedVehicle, attachedTow
    end
    attachedVehicle = 0
    attachedTow = 0
    attachedCfg = nil
    return 0, 0
end

function Tow.IsBusy()
    return busy
end

function Tow.EnsureControl(entity)
    if entity == 0 or not DoesEntityExist(entity) then
        return false
    end
    if NetworkHasControlOfEntity(entity) then
        return true
    end
    local timeout = GetGameTimer() + 2500
    NetworkRequestControlOfEntity(entity)
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
        NetworkRequestControlOfEntity(entity)
        Wait(0)
    end
    return NetworkHasControlOfEntity(entity)
end

function Tow.IsClassAllowed(vehicle)
    if Config.AllowAllVehicles then
        return true
    end
    return Config.AllowedClasses[GetVehicleClass(vehicle)] == true
end

function Tow.EmptyVehicle(vehicle)
    local occupied = false
    local maxPassengers = GetVehicleMaxNumberOfPassengers(vehicle)
    for seat = -1, maxPassengers do
        local ped = GetPedInVehicleSeat(vehicle, seat)
        if ped ~= 0 then
            occupied = true
            TaskLeaveVehicle(ped, vehicle, 16)
        end
    end
    if occupied then
        Wait(900)
        if GetPedInVehicleSeat(vehicle, -1) ~= 0 then
            return false
        end
    end
    return true
end

local function closestFromPoint(point, maxDist, ignore)
    local vehicles = GetGamePool('CVehicle')
    local closest, dist = 0, maxDist
    for i = 1, #vehicles do
        local veh = vehicles[i]
        if veh ~= ignore and DoesEntityExist(veh) then
            local d = #(GetEntityCoords(veh) - point)
            if d < dist then
                closest = veh
                dist = d
            end
        end
    end
    return closest, dist
end

function Tow.FindTruck(ped, maxDist)
    local veh = GetVehiclePedIsIn(ped, false)
    if veh ~= 0 and Tow.IsTowVehicle(veh) then
        return veh
    end
    maxDist = maxDist or 8.0
    local coords = GetEntityCoords(ped)
    local vehicles = GetGamePool('CVehicle')
    local closest, dist = 0, maxDist
    for i = 1, #vehicles do
        local v = vehicles[i]
        if Tow.IsTowVehicle(v) then
            local d = #(GetEntityCoords(v) - coords)
            if d < dist then
                closest = v
                dist = d
            end
        end
    end
    return closest
end

function Tow.FindTarget(tow)
    if tow == 0 or not DoesEntityExist(tow) then
        return 0
    end
    local behind = GetOffsetFromEntityInWorldCoords(tow, 0.0, -7.4, 0.0)
    local target = closestFromPoint(behind, Config.TowSearchDistance or 12.0, tow)
    if target == 0 then
        target = closestFromPoint(GetEntityCoords(tow), Config.TowSearchDistance or 12.0, tow)
    end
    if target == 0 or Tow.IsTowVehicle(target) then
        return 0
    end
    return target
end

function Tow.Describe(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return nil
    end
    local plate = GetVehicleNumberPlateText(vehicle) or ''
    plate = plate:gsub('^%s+', ''):gsub('%s+$', '')
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)) or 'VOERTUIG'
    local body = math.floor((GetVehicleBodyHealth(vehicle) / 10.0) + 0.5)
    local engine = math.floor((GetVehicleEngineHealth(vehicle) / 10.0) + 0.5)
    return {
        plate = plate,
        model = model,
        body = body,
        engine = engine,
        netId = NetworkGetNetworkIdFromEntity(vehicle)
    }
end

local function boneIndex(tow, cfg)
    local names = { cfg.bone or 'bodyshell', 'bodyshell', 'chassis', 'chassis_dummy' }
    for i = 1, #names do
        local idx = GetEntityBoneIndexByName(tow, names[i])
        if idx ~= -1 then
            return idx
        end
    end
    return 0
end

local function prepare(entity)
    SetEntityAsMissionEntity(entity, true, true)
    SetVehicleHasBeenOwnedByPlayer(entity, true)
    if NetworkGetEntityIsNetworked and not NetworkGetEntityIsNetworked(entity) then
        if NetworkRegisterEntityAsNetworked then
            NetworkRegisterEntityAsNetworked(entity)
        end
    end
    local netId = NetworkGetNetworkIdFromEntity(entity)
    if netId and netId ~= 0 then
        SetNetworkIdExistsOnAllMachines(netId, true)
        SetNetworkIdCanMigrate(netId, false)
    end
end

local function pinToBed(tow, target, cfg, slide)
    local bone = boneIndex(tow, cfg)
    local off = cfg.offset or vector3(0.0, -2.0, 1.0)
    local rot = cfg.rotation or vector3(0.0, 0.0, 0.0)

    SetEntityCollision(target, false, false)
    SetVehicleEngineOn(target, false, true, true)
    SetVehicleUndriveable(target, true)
    SetEntityNoCollisionEntity(target, tow, true)
    SetEntityNoCollisionEntity(tow, target, true)

    if slide then
        local startY = off.y - (cfg.slide or 6.0)
        local steps = 16
        for i = 0, steps do
            local t = i / steps
            local y = startY + ((off.y - startY) * t)
            local z = off.z + ((1.0 - t) * 0.28)
            AttachEntityToEntity(
                target, tow, bone,
                off.x, y, z,
                rot.x, rot.y, rot.z,
                false, false, false, false, 2, true
            )
            Wait(40)
        end
    end

    AttachEntityToEntity(
        target, tow, bone,
        off.x, off.y, off.z,
        rot.x, rot.y, rot.z,
        false, false, false, false, 2, true
    )

    return IsEntityAttachedToEntity(target, tow)
end

local function remember(tow, target, cfg)
    attachedVehicle = target
    attachedTow = tow
    attachedCfg = cfg
    local towNet = NetworkGetNetworkIdFromEntity(tow)
    local tgtNet = NetworkGetNetworkIdFromEntity(target)
    if Entity(tow).state then
        Entity(tow).state:set('mallorcaBed', tgtNet, true)
    end
    TriggerServerEvent('mallorca-takel:server:syncAttach', towNet, tgtNet, {
        x = cfg.offset.x, y = cfg.offset.y, z = cfg.offset.z,
        rx = cfg.rotation.x, ry = cfg.rotation.y, rz = cfg.rotation.z
    })
end

local function forget(tow)
    if tow ~= 0 and DoesEntityExist(tow) and Entity(tow).state then
        Entity(tow).state:set('mallorcaBed', nil, true)
    end
    TriggerServerEvent('mallorca-takel:server:syncDetach')
    attachedVehicle = 0
    attachedTow = 0
    attachedCfg = nil
end

function Tow.Attach(specificTarget)
    if busy then
        return false, 'busy'
    end
    local current = Tow.GetAttached()
    if current ~= 0 then
        return false, 'already_towing'
    end

    local ped = PlayerPedId()
    local tow = Tow.FindTruck(ped, specificTarget and 18.0 or 10.0)
    if tow == 0 then
        return false, 'no_truck'
    end

    local cfg = Tow.GetProfile(tow)
    if not cfg then
        return false, 'no_truck'
    end

    local target = specificTarget
    if not target or target == 0 or not DoesEntityExist(target) then
        target = Tow.FindTarget(tow)
    end
    if target == 0 or target == tow or Tow.IsTowVehicle(target) then
        return false, 'no_target'
    end
    if #(GetEntityCoords(tow) - GetEntityCoords(target)) > 18.0 then
        return false, 'too_far_truck'
    end
    if not Tow.IsClassAllowed(target) then
        return false, 'class_blocked'
    end
    if not Tow.EmptyVehicle(target) then
        return false, 'occupied'
    end

    busy = true
    Tow.EnsureControl(tow)
    Tow.EnsureControl(target)
    prepare(tow)
    prepare(target)

    local ok = pinToBed(tow, target, cfg, true)
    busy = false
    if not ok then
        SetEntityCollision(target, true, true)
        SetVehicleUndriveable(target, false)
        return false, 'no_target'
    end

    remember(tow, target, cfg)
    return true, 'attached', target, tow
end

function Tow.Detach()
    if busy then
        return false, 'busy'
    end
    local target, tow = Tow.GetAttached()
    if target == 0 then
        return false, 'not_towing'
    end

    local cfg = attachedCfg or Tow.GetProfile(tow) or {}
    Tow.EnsureControl(target)
    Tow.EnsureControl(tow)

    DetachEntity(target, false, false)
    SetEntityCollision(target, true, true)
    SetVehicleUndriveable(target, false)
    FreezeEntityPosition(target, false)

    local netId = NetworkGetNetworkIdFromEntity(target)
    if netId and netId ~= 0 then
        SetNetworkIdCanMigrate(netId, true)
    end

    if tow ~= 0 and DoesEntityExist(tow) then
        local dropY = cfg.dropY or -10.0
        local drop = GetOffsetFromEntityInWorldCoords(tow, 0.0, dropY, 0.35)
        SetEntityCoords(target, drop.x, drop.y, drop.z, false, false, false, false)
        SetVehicleOnGroundProperly(target)
    end

    forget(tow)
    return true, 'detached', target
end

function Tow.ClearLocal()
    attachedVehicle = 0
    attachedTow = 0
    attachedCfg = nil
    busy = false
end

RegisterNetEvent('mallorca-takel:client:applyAttach', function(towNet, tgtNet, pos)
    towNet = tonumber(towNet)
    tgtNet = tonumber(tgtNet)
    if not towNet or not tgtNet then
        return
    end
    local tow = NetworkGetEntityFromNetworkId(towNet)
    local target = NetworkGetEntityFromNetworkId(tgtNet)
    if tow == 0 or target == 0 or not DoesEntityExist(tow) or not DoesEntityExist(target) then
        return
    end
    if NetworkHasControlOfEntity(target) then
        return
    end
    local cfg = Tow.GetProfile(tow) or {}
    local bone = boneIndex(tow, cfg)
    local off = cfg.offset or vector3(pos and pos.x or 0.0, pos and pos.y or -2.0, pos and pos.z or 1.0)
    local rot = cfg.rotation or vector3(0.0, 0.0, 0.0)
    AttachEntityToEntity(
        target, tow, bone,
        off.x, off.y, off.z,
        rot.x, rot.y, rot.z,
        false, false, false, false, 2, true
    )
    SetEntityCollision(target, false, false)
end)

RegisterNetEvent('mallorca-takel:client:applyDetach', function(tgtNet)
    tgtNet = tonumber(tgtNet)
    if not tgtNet then
        return
    end
    local target = NetworkGetEntityFromNetworkId(tgtNet)
    if target ~= 0 and DoesEntityExist(target) and not NetworkHasControlOfEntity(target) then
        DetachEntity(target, false, false)
        SetEntityCollision(target, true, true)
    end
end)

CreateThread(function()
    while true do
        Wait(500)
        if attachedVehicle ~= 0 then
            if not DoesEntityExist(attachedVehicle) or not DoesEntityExist(attachedTow) then
                Tow.ClearLocal()
            elseif not busy and not IsEntityAttachedToEntity(attachedVehicle, attachedTow) and attachedCfg then
                Tow.EnsureControl(attachedVehicle)
                pinToBed(attachedTow, attachedVehicle, attachedCfg, false)
            end
        end
    end
end)
