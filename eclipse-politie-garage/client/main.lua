local ESX = exports['es_extended']:getSharedObject()

local isOpen = false
local lastSpawnAt = 0
local nearbyGarage = nil
local blips = {}

local function notify(msg, nType)
    if GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:notify({ description = msg, type = nType or 'inform' })
        return
    end
    ESX.ShowNotification(msg)
end

local function getJob()
    local data = ESX.GetPlayerData()
    return data and data.job or nil
end

local function canUseGarage(garage)
    local job = getJob()
    if not job then return false end

    if job.name == Config.JobName then
        local grade = job.grade or 0
        if grade < (Config.MinGrade or 1) then return false end
        if garage and grade < (garage.minGrade or 1) then return false end
        return true
    end

    if Config.AllowOffDuty and job.name == Config.OffJobName then
        return true
    end

    return false
end

local function playerGrade()
    local job = getJob()
    if not job or job.name ~= Config.JobName then return 0 end
    return job.grade or 0
end

local function urlDecode(str)
    str = str:gsub('+', ' ')
    return (str:gsub('%%(%x%x)', function(hex)
        return string.char(tonumber(hex, 16))
    end))
end

-- imagetourls.com/nl/v?u=... → directe CDN-url (viewer-pagina's werken niet in <img>)
local function normalizeImageUrl(url)
    if type(url) ~= 'string' or url == '' then return url end

    local wrapped = url:match('[?&]u=([^&]+)')
    if wrapped then
        local decoded = urlDecode(wrapped)
        if decoded:match('^https?://') then
            return decoded
        end
    end

    return url
end

local function localVehicleImage(model)
    if not model or model == '' then return nil end
    local res = GetCurrentResourceName()
    local exts = { '.png', '.webp', '.jpg', '.jpeg' }
    for i = 1, #exts do
        local file = ('html/img/vehicles/%s%s'):format(model, exts[i])
        if LoadResourceFile(res, file) then
            return ('img/vehicles/%s%s'):format(model, exts[i])
        end
    end
    return nil
end

local function vehicleImage(vehicle)
    local img = vehicle.image
    if type(img) == 'string' and img ~= '' then
        img = normalizeImageUrl(img)
        -- Relatief pad: img/vehicles/naam.png
        if not img:match('^https?://') and not img:match('^nui://') and not img:match('^data:') then
            img = img:gsub('^/+', '')
            if img:sub(1, 5) == 'html/' then
                img = img:sub(6)
            end
            return img
        end
        return img
    end

    local localImg = localVehicleImage(vehicle.model) or localVehicleImage(vehicle.id)
    if localImg then
        return localImg
    end

    return (Config.ImageBase or 'https://docs.fivem.net/vehicles/%s.webp'):format(vehicle.model)
end

local function categoryAllowed(allowedCats, category)
    if not allowedCats then return true end
    for c = 1, #allowedCats do
        if allowedCats[c] == category then
            return true
        end
    end
    return false
end

local function vehiclesForGarage(garage)
    local grade = playerGrade()
    local allowedCats = garage and garage.categories or nil
    local list = {}

    for i = 1, #Config.Vehicles do
        local v = Config.Vehicles[i]
        if grade >= (v.minGrade or 0) and categoryAllowed(allowedCats, v.category) then
            list[#list + 1] = v
        end
    end

    return list
end

local function categoriesForGarage(garage, vehicles)
    local used = {}
    for i = 1, #vehicles do
        used[vehicles[i].category] = true
    end

    local cats = {}
    for i = 1, #Config.Categories do
        local cat = Config.Categories[i]
        if cat.special == 'favorites' then
            cats[#cats + 1] = { id = cat.id, label = cat.label, icon = cat.icon, special = cat.special }
        elseif used[cat.id] then
            if not garage.categories then
                cats[#cats + 1] = { id = cat.id, label = cat.label, icon = cat.icon }
            else
                for c = 1, #garage.categories do
                    if garage.categories[c] == cat.id then
                        cats[#cats + 1] = { id = cat.id, label = cat.label, icon = cat.icon }
                        break
                    end
                end
            end
        end
    end
    return cats
end

local function payloadVehicles(vehicles)
    local out = {}
    for i = 1, #vehicles do
        local v = vehicles[i]
        out[#out + 1] = {
            id = v.id,
            label = v.label,
            model = v.model,
            category = v.category,
            minGrade = v.minGrade or 0,
            badge = v.badge,
            image = vehicleImage(v),
            stats = v.stats or { speed = 50, accel = 50, brake = 50, handling = 50 },
        }
    end
    return out
end

local function closeUi()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function openUi(garage)
    if isOpen then return end
    if not canUseGarage(garage) then
        notify(Config.Text.noJob, 'error')
        return
    end

    local vehicles = vehiclesForGarage(garage)
    if #vehicles == 0 then
        notify(Config.Text.noGrade, 'error')
        return
    end

    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        data = {
            title = 'Politiegarage',
            location = 'Made By Goudesnelle',
            garageId = garage.id,
            grade = playerGrade(),
            categories = categoriesForGarage(garage, vehicles),
            vehicles = payloadVehicles(vehicles),
            texts = {
                search = 'Zoek op naam of model…',
                spawn = 'PAK VOERTUIG',
                empty = 'Geen voertuigen in deze categorie.',
                favoritesEmpty = 'Nog geen favorieten. Klik op ★ bij een voertuig.',
                speed = 'Snelheid',
                accel = 'Acceleratie',
                brake = 'Remmen',
                handling = 'Handling',
            }
        }
    })
end

local function setFuel(vehicle, amount)
    amount = amount or (Config.Fuel.default or 100.0)
    local res = Config.Fuel.resource
    if res and GetResourceState(res) == 'started' then
        pcall(function()
            if res == 'ox_fuel' then
                Entity(vehicle).state.fuel = amount
            else
                exports[res]:SetFuel(vehicle, amount)
            end
        end)
        pcall(function()
            exports[res]:setFuel(vehicle, amount)
        end)
    end
    SetVehicleFuelLevel(vehicle, amount + 0.0)
end

local function giveKeys(vehicle)
    if Config.Keys.system == 'none' then return end
    local plate = GetVehicleNumberPlateText(vehicle)

    if Config.Keys.resource and GetResourceState(Config.Keys.resource) == 'started' then
        pcall(function()
            exports[Config.Keys.resource]:giveCarKeys(plate)
        end)
        return
    end

    if Config.Keys.system == 'auto' then
        local candidates = {
            'jg-givekey', 'jg-carkeys', 'wasabi_carlock', 'qs-vehiclekeys',
            'mk_vehiclekeys', 'vehicles_keys', 'cd_garage'
        }
        for i = 1, #candidates do
            local res = candidates[i]
            if GetResourceState(res) == 'started' then
                local ok = pcall(function()
                    if res == 'qs-vehiclekeys' then
                        exports[res]:GiveKeys(plate)
                    elseif res == 'wasabi_carlock' then
                        exports[res]:GiveKey(plate)
                    else
                        exports[res]:giveCarKeys(plate)
                    end
                end)
                if ok then return end
            end
        end
    end

    TriggerEvent(Config.Keys.event or 'vehiclekeys:client:SetOwner', plate)
end

local function applyExtras(vehicle)
    local extras = Config.VehicleExtras and Config.VehicleExtras.extras
    if extras then
        for id, enabled in pairs(extras) do
            local extraId = tonumber(id)
            if extraId and DoesExtraExist(vehicle, extraId) then
                SetVehicleExtra(vehicle, extraId, enabled and 0 or 1)
            end
        end
    end
    if Config.VehicleExtras and Config.VehicleExtras.livery then
        SetVehicleLivery(vehicle, Config.VehicleExtras.livery)
    end
end

local function findGarageById(id)
    for i = 1, #Config.Garages do
        if Config.Garages[i].id == id then
            return Config.Garages[i]
        end
    end
    return nil
end

local function findVehicleById(id)
    for i = 1, #Config.Vehicles do
        if Config.Vehicles[i].id == id then
            return Config.Vehicles[i]
        end
    end
    return nil
end

local function makePlate()
    local digits = Config.Plate.digits or 3
    local max = (10 ^ digits) - 1
    local n = math.random(0, max)
    return ('%s%0' .. digits .. 'd'):format(Config.Plate.prefix or 'POL', n)
end

-- Spawn alleen binnen OneSync-range van de speler, anders vlak voor de speler.
local function resolveSpawn(garage)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped)
    local pedHeading = GetEntityHeading(ped)
    local maxDist = Config.MaxSpawnDistance or 80.0
    local spawnPoints = (garage and garage.spawnPoints) or {}

    for i = 1, #spawnPoints do
        local sp = spawnPoints[i]
        local pos = vector3(sp.x, sp.y, sp.z)
        if #(pedCoords - pos) <= maxDist and ESX.Game.IsSpawnPointClear(pos, 3.0) then
            return pos, sp.w or sp.heading or 0.0
        end
    end

    -- Fallback: voor de speler (voorkomt ESX "Out of onesync range")
    local forward = GetEntityForwardVector(ped)
    local tryOffsets = { 4.0, 6.0, 8.0, 3.0, 10.0 }
    for i = 1, #tryOffsets do
        local dist = tryOffsets[i]
        local pos = pedCoords + (forward * dist)
        local found, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pedCoords.z + 2.0, false)
        if found then
            pos = vector3(pos.x, pos.y, groundZ + 0.2)
        end
        if ESX.Game.IsSpawnPointClear(pos, 2.5) then
            return pos, pedHeading
        end
    end

    local pos = pedCoords + (forward * 4.0)
    return vector3(pos.x, pos.y, pedCoords.z), pedHeading
end

local function finishSpawnedVehicle(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        notify(Config.Text.modelFail, 'error')
        return false
    end

    SetVehicleNumberPlateText(vehicle, makePlate())
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleDirtLevel(vehicle, 0.0)
    SetVehicleOnGroundProperly(vehicle)
    applyExtras(vehicle)
    setFuel(vehicle, Config.Fuel.default)
    giveKeys(vehicle)

    if Config.WarpIntoVehicle then
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    end

    notify(Config.Text.spawned, 'success')
    return true
end

local function spawnVehicleNative(model, coords, heading, cb)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        cb(nil)
        return
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 8000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then
            cb(nil)
            return
        end
        Wait(10)
    end

    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading or 0.0, true, false)
    if vehicle and vehicle ~= 0 then
        SetEntityAsMissionEntity(vehicle, true, true)
        SetModelAsNoLongerNeeded(hash)
        NetworkRegisterEntityAsNetworked(vehicle)
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        SetNetworkIdCanMigrate(netId, true)
        SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    end
    cb(vehicle)
end

local function spawnVehicle(vehicleCfg, garage)
    if GetGameTimer() - lastSpawnAt < (Config.SpawnCooldown or 2500) then
        notify(Config.Text.cooldown, 'error')
        return
    end

    if playerGrade() < (vehicleCfg.minGrade or 0) then
        notify(Config.Text.noPerm, 'error')
        return
    end

    local coords, heading = resolveSpawn(garage)
    if not coords then
        notify(Config.Text.blocked, 'error')
        return
    end

    -- UI dicht vóór spawn (focus/camera kan ESX-afstand checks verstoren)
    closeUi()
    lastSpawnAt = GetGameTimer()
    local model = vehicleCfg.model

    local pedCoords = GetEntityCoords(PlayerPedId())
    if #(pedCoords - coords) > (Config.MaxSpawnDistance or 80.0) then
        -- Extra veiligheidsnet: altijd dichtbij spawnen
        coords, heading = resolveSpawn(nil)
    end

    local function onSpawned(vehicle)
        if not finishSpawnedVehicle(vehicle) then return end
    end

    -- ESX spawn kan crashen/erroren buiten OneSync-range; vang af en gebruik native.
    local ok = pcall(function()
        ESX.Game.SpawnVehicle(model, coords, heading or 0.0, function(vehicle)
            if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
                onSpawned(vehicle)
            else
                spawnVehicleNative(model, coords, heading, onSpawned)
            end
        end)
    end)

    if not ok then
        spawnVehicleNative(model, coords, heading, onSpawned)
    end
end

local function storeCurrentVehicle(garage)
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        notify(Config.Text.noVehicle, 'error')
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        notify(Config.Text.notDriver, 'error')
        return
    end

    if garage and garage.deleteCoords then
        local dist = #(GetEntityCoords(ped) - garage.deleteCoords)
        if dist > (Config.StoreDistance or 8.0) then
            return
        end
    end

    ESX.Game.DeleteVehicle(vehicle)
    notify(Config.Text.stored, 'success')
end

RegisterNUICallback('close', function(_, cb)
    closeUi()
    cb({ ok = true })
end)

RegisterNUICallback('spawn', function(data, cb)
    local garage = findGarageById(data and data.garageId)
    local vehicle = findVehicleById(data and data.vehicleId)
    if not garage or not vehicle then
        cb({ ok = false })
        return
    end
    if not canUseGarage(garage) then
        notify(Config.Text.noJob, 'error')
        cb({ ok = false })
        return
    end
    spawnVehicle(vehicle, garage)
    cb({ ok = true })
end)

RegisterCommand(Config.Commands.open, function()
    local garage = nearbyGarage or Config.Garages[1]
    if garage then openUi(garage) end
end, false)

RegisterCommand(Config.Commands.store, function()
    storeCurrentVehicle(nearbyGarage or Config.Garages[1])
end, false)

RegisterNUICallback('ready', function(_, cb)
    cb({ ok = true })
end)

CreateThread(function()
    for i = 1, #Config.Garages do
        local g = Config.Garages[i]
        if Config.Blip.enabled and g.blip ~= false then
            local blip = AddBlipForCoord(g.coords.x, g.coords.y, g.coords.z)
            SetBlipSprite(blip, Config.Blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.Blip.scale)
            SetBlipColour(blip, Config.Blip.colour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Config.Blip.label)
            EndTextCommandSetBlipName(blip)
            blips[#blips + 1] = blip
        end
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        nearbyGarage = nil

        for i = 1, #Config.Garages do
            local g = Config.Garages[i]
            local dist = #(coords - g.coords)
            if dist < Config.MarkerDistance then
                sleep = 0
                DrawMarker(
                    Config.Marker.type,
                    g.coords.x, g.coords.y, g.coords.z,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    Config.Marker.scale, Config.Marker.scale, Config.Marker.scale,
                    Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.a,
                    false, true, 2, false, nil, nil, false
                )

                if dist < Config.InteractDistance then
                    nearbyGarage = g
                    if not isOpen then
                        ESX.ShowHelpNotification(Config.Text.open)
                        if IsControlJustReleased(0, 38) then -- E
                            openUi(g)
                        end
                    end
                end
            end

            if g.deleteCoords then
                local dDist = #(coords - g.deleteCoords)
                if dDist < Config.MarkerDistance then
                    sleep = 0
                    if IsPedInAnyVehicle(ped, false) and dDist < Config.StoreDistance then
                        nearbyGarage = g
                        ESX.ShowHelpNotification(Config.Text.store)
                        if IsControlJustReleased(0, 38) then
                            storeCurrentVehicle(g)
                        end
                    end
                end
            end
        end

        if isOpen and IsControlJustReleased(0, 322) then -- ESC
            closeUi()
        end

        Wait(sleep)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    closeUi()
    for i = 1, #blips do
        RemoveBlip(blips[i])
    end
end)

-- Voor integratie vanuit andere resources:
exports('OpenPoliceGarage', function(garageId)
    local garage = findGarageById(garageId) or Config.Garages[1]
    if garage then openUi(garage) end
end)

exports('ClosePoliceGarage', closeUi)
