local lastSpawnAt = 0

local function _(key, ...)
    local str = (Locales[Config.Locale] and Locales[Config.Locale][key]) or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

local function setFuel(vehicle, amount)
    amount = amount or 100.0
    if Config.FuelResource and GetResourceState(Config.FuelResource) == 'started' then
        pcall(function()
            exports[Config.FuelResource]:setFuel(vehicle, amount)
        end)
    end
    SetVehicleFuelLevel(vehicle, amount + 0.0)
end

local function giveKeys(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local props = ESX.Game.GetVehicleProperties(vehicle)
    local res = Config.KeyResource
    if res and GetResourceState(res) == 'started' then
        pcall(function()
            exports[res]:giveCarKeys(plate, props, vehicle)
        end)
        return
    end
    TriggerEvent('vehiclekeys:client:SetOwner', plate)
end

local function findFreeSpawn(spawnPoints)
    for i = 1, #spawnPoints do
        local sp = spawnPoints[i]
        if ESX.Game.IsSpawnPointClear(vector3(sp.x, sp.y, sp.z), 3.0) then
            return sp
        end
    end
    return nil
end

local function applyExtras(vehicle)
    local extras = Config.VehicleExtras and Config.VehicleExtras.extras
    if extras then
        for id, enabled in pairs(extras) do
            if DoesExtraExist(vehicle, tonumber(id)) then
                SetVehicleExtra(vehicle, tonumber(id), enabled and 0 or 1)
            end
        end
    end
    if Config.VehicleExtras and Config.VehicleExtras.livery then
        SetVehicleLivery(vehicle, Config.VehicleExtras.livery)
    end
end

local function spawnVehicle(model, spawnPoints)
    if GetGameTimer() - lastSpawnAt < 2500 then return end
    lastSpawnAt = GetGameTimer()

    local sp = findFreeSpawn(spawnPoints)
    if not sp then
        Notify(_('garage_blocked'), 'error')
        return
    end

    ESX.Game.SpawnVehicle(model, vector3(sp.x, sp.y, sp.z), sp.w or sp.heading or 0.0, function(vehicle)
        SetVehicleNumberPlateText(vehicle, ('POL%03d'):format(math.random(0, 999)))
        SetVehicleEngineOn(vehicle, true, true, false)
        applyExtras(vehicle)
        setFuel(vehicle, 100.0)
        giveKeys(vehicle)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        Notify(_('garage_spawned', model), 'success')
    end)
end

function OpenGarage(location, vehicleType)
    if not IsOnDuty() then
        Notify(_('not_on_duty'), 'error')
        return
    end

    vehicleType = vehicleType or 'cars'
    local categories = Config.Vehicles[vehicleType] or {}
    local grade = GetGrade()
    local options = {}

    for i = 1, #categories do
        local cat = categories[i]
        if grade >= (cat.minGrade or 0) then
            local vehicleOptions = {}
            for j = 1, #cat.vehicles do
                local v = cat.vehicles[j]
                vehicleOptions[#vehicleOptions + 1] = {
                    title = v.label,
                    description = v.model,
                    onSelect = function()
                        spawnVehicle(v.model, location.spawnPoints or {})
                    end,
                }
            end

            local menuId = ('politie_garage_%s_%s'):format(vehicleType, i)
            lib.registerContext({
                id = menuId,
                title = cat.category,
                menu = 'politie_garage_root',
                options = vehicleOptions,
            })

            options[#options + 1] = {
                title = cat.category,
                description = ('Vanaf rang %s'):format(cat.minGrade or 0),
                menu = menuId,
            }
        end
    end

    if #options == 0 then
        Notify(_('no_permission'), 'error')
        return
    end

    lib.registerContext({
        id = 'politie_garage_root',
        title = location.label or 'Garage',
        options = options,
    })
    lib.showContext('politie_garage_root')
end

function StoreCurrentVehicle()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then return end
    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then return end
    ESX.Game.DeleteVehicle(vehicle)
    Notify(_('garage_stored'), 'success')
end
