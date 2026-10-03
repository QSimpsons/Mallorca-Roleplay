--[[
    Mallorca Speedometer - client
    Alleen voertuig-HUD. Geen externe downloads, geen obfuscation.
]]

local visible = false
local leftOn = false
local rightOn = false
local hazardOn = false
local currentPlate = nil
local fuelReady = true
local lastSaveAt = 0
local lastFuelSaved = nil

local function statusColor(value, greenAt, yellowAt)
    if value >= greenAt then
        return 'green'
    end
    if value >= yellowAt then
        return 'yellow'
    end
    return 'red'
end

local function normalizePlate(plate)
    if type(plate) ~= 'string' then
        return ''
    end
    return (plate:gsub('^%s+', ''):gsub('%s+$', ''):upper())
end

local function getDriverVehicle()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        return 0
    end
    local vehicle = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        return 0
    end
    return vehicle
end

local function getFuel(vehicle)
    -- Optioneel: vast fuel-script uit config
    local resource = Config.Fuel and Config.Fuel.Resource or ''
    if resource ~= '' and GetResourceState(resource) == 'started' then
        local exportName = Config.Fuel.Export or 'GetFuel'
        local ok, value = pcall(function()
            return exports[resource][exportName](vehicle)
        end)
        if ok and type(value) == 'number' then
            return math.max(0.0, math.min(100.0, value))
        end
    end

    local level = GetVehicleFuelLevel(vehicle)
    if type(level) ~= 'number' then
        return 100.0
    end
    return math.max(0.0, math.min(100.0, level))
end

local function setFuel(vehicle, amount)
    amount = math.max(0.0, math.min(100.0, amount))
    SetVehicleFuelLevel(vehicle, amount)
end

local function saveFuel(vehicle, force)
    if not Config.Fuel or not Config.Fuel.UseDatabase then
        return
    end
    if not vehicle or vehicle == 0 then
        return
    end

    local plate = normalizePlate(GetVehicleNumberPlateText(vehicle))
    if plate == '' then
        return
    end

    local fuel = getFuel(vehicle)
    local now = GetGameTimer()
    local interval = Config.Fuel.SaveMs or 15000

    if not force then
        if (now - lastSaveAt) < interval then
            return
        end
        if lastFuelSaved and math.abs(lastFuelSaved - fuel) < 0.5 then
            return
        end
    end

    lastSaveAt = now
    lastFuelSaved = fuel
    TriggerServerEvent('mallorca-speedometer:server:saveFuel', plate, fuel)
end

local function requestFuel(vehicle)
    if not Config.Fuel or not Config.Fuel.UseDatabase then
        fuelReady = true
        return
    end

    local plate = normalizePlate(GetVehicleNumberPlateText(vehicle))
    if plate == '' then
        fuelReady = true
        return
    end

    currentPlate = plate
    fuelReady = false
    TriggerServerEvent('mallorca-speedometer:server:getFuel', plate)

    Citizen.SetTimeout(1500, function()
        if currentPlate == plate and not fuelReady then
            fuelReady = true
        end
    end)
end

RegisterNetEvent('mallorca-speedometer:client:setFuel', function(plate, fuel)
    plate = normalizePlate(plate)
    if currentPlate ~= plate then
        return
    end

    local vehicle = getDriverVehicle()
    if vehicle ~= 0 then
        setFuel(vehicle, tonumber(fuel) or 100.0)
    end
    fuelReady = true
end)

local function applyIndicators(vehicle)
    if vehicle == 0 then
        return
    end
    if hazardOn then
        SetVehicleIndicatorLights(vehicle, 0, true)
        SetVehicleIndicatorLights(vehicle, 1, true)
    else
        SetVehicleIndicatorLights(vehicle, 0, leftOn)
        SetVehicleIndicatorLights(vehicle, 1, rightOn)
    end
end

local function hideHud()
    if not visible then
        return
    end
    visible = false
    SendNUIMessage({ action = 'hide' })
end

local function showHud(data)
    visible = true
    SendNUIMessage({ action = 'update', data = data })
end

local function isHandbrakeOn(vehicle)
    if GetVehicleHandbrake(vehicle) then
        return true
    end
    return IsControlPressed(0, 76)
end

local function areLightsOn(vehicle)
    local _, lightsOn, highbeams = GetVehicleLightsState(vehicle)
    return lightsOn == 1 or highbeams == 1
end

local function consumeFuel(vehicle, dt)
    if not Config.Fuel or Config.Fuel.Consume == false then
        return
    end
    if not GetIsVehicleEngineRunning(vehicle) then
        return
    end

    local speed = GetEntitySpeed(vehicle) * 3.6
    local use = (Config.Fuel.IdleDrain or 0.01) * dt
    if speed > 1.0 then
        use = use + ((Config.Fuel.DriveDrain or 0.035) + speed * (Config.Fuel.SpeedDrain or 0.00025)) * dt
    end

    local fuel = getFuel(vehicle)
    local nextFuel = math.max(0.0, fuel - use)
    if nextFuel ~= fuel then
        setFuel(vehicle, nextFuel)
    end
    if nextFuel <= 0.0 then
        SetVehicleEngineOn(vehicle, false, true, true)
    end
end

CreateThread(function()
    local wasInVehicle = false
    local lastVehicle = 0
    local lastTick = GetGameTimer()

    while true do
        local vehicle = getDriverVehicle()
        local now = GetGameTimer()
        local dt = math.max(0.0, (now - lastTick) / 1000.0)
        lastTick = now

        if vehicle == 0 then
            if wasInVehicle and lastVehicle ~= 0 then
                saveFuel(lastVehicle, true)
            end
            wasInVehicle = false
            lastVehicle = 0
            currentPlate = nil
            fuelReady = true
            leftOn = false
            rightOn = false
            hazardOn = false
            hideHud()
            Wait(400)
        elseif Config.HideInPauseMenu and IsPauseMenuActive() then
            hideHud()
            Wait(200)
        else
            if (not wasInVehicle) or lastVehicle ~= vehicle then
                requestFuel(vehicle)
            end
            wasInVehicle = true
            lastVehicle = vehicle

            if fuelReady then
                consumeFuel(vehicle, dt)
                saveFuel(vehicle, false)
            end

            local speed = GetEntitySpeed(vehicle) * (Config.UseKmh and 3.6 or 2.236936)
            local engineHealth = GetVehicleEngineHealth(vehicle)
            local bodyHealth = GetVehicleBodyHealth(vehicle)
            local fuel = getFuel(vehicle)

            showHud({
                speed = math.floor(speed + 0.5),
                maxSpeed = Config.MaxSpeed or 280,
                unit = Config.UseKmh and 'km/h' or 'mph',
                engine = statusColor(engineHealth, Config.Engine.green, Config.Engine.yellow),
                damage = statusColor(bodyHealth, Config.Body.green, Config.Body.yellow),
                fuel = math.floor(fuel + 0.5),
                fuelState = statusColor(fuel, Config.Fuel.green or 40, Config.Fuel.yellow or 15),
                left = hazardOn or leftOn,
                right = hazardOn or rightOn,
                hazard = hazardOn,
                handbrake = isHandbrakeOn(vehicle),
                lights = areLightsOn(vehicle)
            })

            Wait(Config.TickMs or 50)
        end
    end
end)

if Config.EnableIndicatorKeys then
    RegisterCommand('ms_left_indicator', function()
        local vehicle = getDriverVehicle()
        if vehicle == 0 then return end
        hazardOn = false
        leftOn = not leftOn
        if leftOn then rightOn = false end
        applyIndicators(vehicle)
    end, false)

    RegisterCommand('ms_right_indicator', function()
        local vehicle = getDriverVehicle()
        if vehicle == 0 then return end
        hazardOn = false
        rightOn = not rightOn
        if rightOn then leftOn = false end
        applyIndicators(vehicle)
    end, false)

    RegisterCommand('ms_hazard', function()
        local vehicle = getDriverVehicle()
        if vehicle == 0 then return end
        hazardOn = not hazardOn
        if hazardOn then
            leftOn = false
            rightOn = false
        end
        applyIndicators(vehicle)
    end, false)

    RegisterKeyMapping('ms_left_indicator', 'Knipperlicht links', 'keyboard', Config.Keys.left)
    RegisterKeyMapping('ms_right_indicator', 'Knipperlicht rechts', 'keyboard', Config.Keys.right)
    RegisterKeyMapping('ms_hazard', 'Noodknippers', 'keyboard', Config.Keys.hazard)
end
