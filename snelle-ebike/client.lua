local bikeEntity = nil
local bikeNetId = nil
local bikeBlip = nil
local battery = Config.Battery.startPercent or 100
local lastAction = 0
local framework = 'standalone'
local ESX, QBCore

local function notify(message, kind)
    kind = kind or 'info'
    if framework == 'esx' and ESX and ESX.ShowNotification then
        ESX.ShowNotification(message)
        return
    end
    if framework == 'qb' and QBCore and QBCore.Functions and QBCore.Functions.Notify then
        local qbType = kind == 'error' and 'error' or (kind == 'success' and 'success' or 'primary')
        QBCore.Functions.Notify(message, qbType)
        return
    end
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

local function detectFramework()
    local mode = Config.Framework
    if mode == 'esx' or (mode == 'auto' and GetResourceState('es_extended') == 'started') then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and obj then
            ESX = obj
            framework = 'esx'
            return
        end
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
            framework = 'esx'
        end)
        return
    end
    if mode == 'qb' or (mode == 'auto' and (GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started')) then
        local ok, obj = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and obj then
            QBCore = obj
            framework = 'qb'
            return
        end
    end
    framework = 'standalone'
end

local function onCooldown()
    local now = GetGameTimer()
    if now - lastAction < (Config.Cooldown or 0) * 1000 then
        notify(Config.Messages.cooldown, 'error')
        return true
    end
    lastAction = now
    return false
end

local function clearBlip()
    if bikeBlip and DoesBlipExist(bikeBlip) then
        RemoveBlip(bikeBlip)
    end
    bikeBlip = nil
end

local function attachBlip(entity)
    clearBlip()
    if not Config.ShowBlip or not entity or not DoesEntityExist(entity) then
        return
    end
    bikeBlip = AddBlipForEntity(entity)
    SetBlipSprite(bikeBlip, Config.Blip.sprite or 226)
    SetBlipColour(bikeBlip, Config.Blip.color or 47)
    SetBlipScale(bikeBlip, Config.Blip.scale or 0.7)
    SetBlipAsShortRange(bikeBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Blip.label or 'E-bike')
    EndTextCommandSetBlipName(bikeBlip)
end

local function forgetBike()
    clearBlip()
    bikeEntity = nil
    bikeNetId = nil
end

local function resolveBike()
    if bikeEntity and DoesEntityExist(bikeEntity) then
        return bikeEntity
    end
    if bikeNetId then
        local ent = NetworkGetEntityFromNetworkId(bikeNetId)
        if ent and ent ~= 0 and DoesEntityExist(ent) then
            bikeEntity = ent
            return ent
        end
    end
    forgetBike()
    return nil
end

local function loadModel(model)
    local hash = joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        return nil
    end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        Wait(50)
        if GetGameTimer() > timeout then
            return nil
        end
    end
    return hash
end

local function resolveModel()
    local primary = Config.Model
    local hash = loadModel(primary)
    if hash then
        return hash, primary, false
    end

    local fallback = Config.FallbackModel or 'inductor'
    if fallback ~= primary then
        hash = loadModel(fallback)
        if hash then
            return hash, fallback, true
        end
    end

    return nil, primary, false
end

local function applyFatbikeLook(vehicle)
    local look = Config.Appearance
    if not look or not look.enabled or not vehicle or not DoesEntityExist(vehicle) then
        return
    end

    SetVehicleModKit(vehicle, 0)

    local primary = look.primary or {}
    local secondary = look.secondary or {}
    if primary.r and secondary.r then
        -- Basisindex zwart/oranje, daarna exacte RGB
        SetVehicleColours(vehicle, 0, 38)
        SetVehicleCustomPrimaryColour(vehicle, primary.r or 0, primary.g or 0, primary.b or 0)
        SetVehicleCustomSecondaryColour(vehicle, secondary.r or 0, secondary.g or 0, secondary.b or 0)
    end

    SetVehicleExtraColours(vehicle, look.pearlescent or 0, look.wheelColor or 0)

    if look.wheelWidth and SetVehicleWheelWidth then
        SetVehicleWheelWidth(vehicle, look.wheelWidth + 0.0)
    end
    if look.wheelSize and SetVehicleWheelSize then
        SetVehicleWheelSize(vehicle, look.wheelSize + 0.0)
    end

    SetVehicleDirtLevel(vehicle, 0.0)
end

local function drawBatteryHud()
    if not Config.Battery.enabled then
        return
    end
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 or veh ~= resolveBike() then
        return
    end

    local pct = math.max(0, math.min(100, math.floor(battery + 0.5)))
    local r, g, b = 80, 200, 120
    if pct <= 20 then
        r, g, b = 220, 70, 70
    elseif pct <= 40 then
        r, g, b = 230, 180, 60
    end

    SetTextFont(4)
    SetTextScale(0.35, 0.35)
    SetTextColour(r, g, b, 220)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(('Fatbike  %d%%'):format(pct))
    EndTextCommandDisplayText(0.5, 0.92)
end

local function deleteBikeEntity(entity)
    if not entity or not DoesEntityExist(entity) then
        return
    end
    SetEntityAsMissionEntity(entity, true, true)
    DeleteVehicle(entity)
    if DoesEntityExist(entity) then
        DeleteEntity(entity)
    end
end

local function storeBike()
    if onCooldown() then
        return
    end

    local ped = PlayerPedId()
    if IsEntityDead(ped) then
        notify(Config.Messages.dead, 'error')
        return
    end

    local entity = resolveBike()
    if not entity then
        notify(Config.Messages.noBike, 'error')
        return
    end

    local pedCoords = GetEntityCoords(ped)
    local bikeCoords = GetEntityCoords(entity)
    local dist = #(pedCoords - bikeCoords)
    local inBike = GetVehiclePedIsIn(ped, false) == entity

    if not inBike and dist > (Config.StoreDistance or 3.0) then
        notify(Config.Messages.tooFar, 'error')
        return
    end

    if inBike then
        TaskLeaveVehicle(ped, entity, 16)
        local leaveTimeout = GetGameTimer() + 2000
        while GetVehiclePedIsIn(ped, false) == entity and GetGameTimer() < leaveTimeout do
            Wait(50)
        end
    end

    deleteBikeEntity(entity)
    forgetBike()
    battery = Config.Battery.startPercent or 100
    TriggerServerEvent('snelle-ebike:server:stored')
    notify(Config.Messages.stored, 'success')
end

local function spawnBike()
    if onCooldown() then
        return
    end

    local ped = PlayerPedId()
    if IsEntityDead(ped) then
        notify(Config.Messages.dead, 'error')
        return
    end

    if GetVehiclePedIsIn(ped, false) ~= 0 then
        notify(Config.Messages.inVehicle, 'error')
        return
    end

    if resolveBike() then
        notify(Config.Messages.alreadyOut, 'error')
        return
    end

    local hash, modelName, usedFallback = resolveModel()
    if not hash then
        notify(Config.Messages.modelMissing, 'error')
        TriggerServerEvent('snelle-ebike:server:spawnFailed')
        return
    end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local forward = GetEntityForwardVector(ped)
    local x = coords.x + forward.x * 1.2
    local y = coords.y + forward.y * 1.2
    local z = coords.z

    local vehicle = CreateVehicle(hash, x, y, z, heading, true, false)
    if not vehicle or vehicle == 0 then
        SetModelAsNoLongerNeeded(hash)
        notify(Config.Messages.modelMissing, 'error')
        TriggerServerEvent('snelle-ebike:server:spawnFailed')
        return
    end

    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNumberPlateText(vehicle, string.sub(Config.Plate or 'FATBIKE', 1, 8))
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetEntityAsMissionEntity(vehicle, true, true)
    applyFatbikeLook(vehicle)
    SetModelAsNoLongerNeeded(hash)

    bikeEntity = vehicle
    bikeNetId = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdCanMigrate(bikeNetId, true)
    SetNetworkIdExistsOnAllMachines(bikeNetId, true)
    attachBlip(vehicle)
    battery = Config.Battery.startPercent or 100

    if Config.WarpIntoBike then
        TaskWarpPedIntoVehicle(ped, vehicle, -1)
    end

    -- Kleuren/banden soms opnieuw zetten na warp (netwerk sync)
    CreateThread(function()
        Wait(150)
        if DoesEntityExist(vehicle) then
            applyFatbikeLook(vehicle)
        end
    end)

    TriggerServerEvent('snelle-ebike:server:spawned', bikeNetId)
    if usedFallback then
        notify(Config.Messages.usingFallback, 'info')
    end
    notify(Config.Messages.spawned, 'success')
end

local function toggleBike()
    if resolveBike() then
        storeBike()
    else
        if Config.UseItem then
            TriggerServerEvent('snelle-ebike:server:trySpawn')
        else
            spawnBike()
        end
    end
end

RegisterNetEvent('snelle-ebike:client:spawnAllowed', function()
    spawnBike()
end)

RegisterNetEvent('snelle-ebike:client:notify', function(message, kind)
    notify(message, kind)
end)

RegisterCommand(Config.Command, function()
    toggleBike()
end, false)

TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Zet je fatbike uit of berg hem op')

if Config.StoreKey and Config.StoreKey ~= '' then
    RegisterKeyMapping(Config.Command, 'Fatbike spawn / opbergen', 'keyboard', Config.StoreKey)
end

-- ESX usable item fallback (sommige servers triggeren client-side)
RegisterNetEvent('snelle-ebike:client:useItem', function()
    toggleBike()
end)

CreateThread(function()
    detectFramework()
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local entity = resolveBike()
        if entity then
            sleep = 200
            if Config.Battery.enabled then
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
                if veh == entity then
                    sleep = 0
                    local speed = GetEntitySpeed(entity)
                    if speed > 1.0 then
                        local drain = (Config.Battery.drainPerMinute or 0) / 60.0 * 0.2
                        battery = math.max(0, battery - drain)
                    end
                    drawBatteryHud()
                    -- Houd fatbike-banden breed na sync
                    if Config.Appearance and Config.Appearance.enabled and Config.Appearance.wheelWidth then
                        if type(SetVehicleWheelWidth) == 'function' then
                            SetVehicleWheelWidth(entity, Config.Appearance.wheelWidth + 0.0)
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end
    local entity = resolveBike()
    if entity then
        deleteBikeEntity(entity)
    end
    forgetBike()
end)

exports('getBike', resolveBike)
exports('spawnBike', function()
    if Config.UseItem then
        TriggerServerEvent('snelle-ebike:server:trySpawn')
    else
        spawnBike()
    end
end)
exports('storeBike', storeBike)
