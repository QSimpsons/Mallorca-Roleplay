local State = Config.CopyState(Config.Defaults)
local menuOpen = false
local smoothToken = 0
local transitioning = false
local weatherToken = 0
local weatherSettling = false

local tsunamiFrom = 0.0
local tsunamiTo = 0.0
local tsunamiBegan = 0

local function cancelSmooth()
    smoothToken = smoothToken + 1
    transitioning = false
end

local function smoothTo(targetHour, targetMinute)
    smoothToken = smoothToken + 1
    local token = smoothToken
    local start = State.hour * 60 + State.minute
    local target = targetHour * 60 + targetMinute
    local diff = (target - start) % 1440

    if diff == 0 then
        State.hour = targetHour
        State.minute = targetMinute
        transitioning = false
        return
    end

    transitioning = true
    CreateThread(function()
        local stepWait = math.max(1, math.floor((Config.SmoothTimeChangeSeconds * 1000) / diff))
        for i = 1, diff do
            if token ~= smoothToken then
                return
            end
            local current = (start + i) % 1440
            State.hour = math.floor(current / 60)
            State.minute = current % 60
            Wait(stepWait)
        end
        if token == smoothToken then
            transitioning = false
        end
    end)
end

local function applyWeather(weather, instant)
    if not Config.WeatherById(weather) then
        return
    end

    weatherToken = weatherToken + 1
    local token = weatherToken

    ClearOverrideWeather()
    ClearWeatherTypePersist()

    if instant then
        weatherSettling = false
        SetWeatherTypePersist(weather)
        SetWeatherTypeNow(weather)
        SetWeatherTypeNowPersist(weather)
        return
    end

    weatherSettling = true
    SetWeatherTypeOvertimePersist(weather, Config.WeatherTransitionSeconds + 0.0)
    SetTimeout(math.floor(Config.WeatherTransitionSeconds * 1000), function()
        if token ~= weatherToken then
            return
        end
        weatherSettling = false
        SetWeatherTypeNowPersist(weather)
    end)
end

local function tsunamiStrength()
    local ramp = Config.TsunamiRampMs
    if not ramp or ramp < 1 then
        ramp = 1
    end
    local progress = math.min(1.0, (GetGameTimer() - tsunamiBegan) / ramp)
    return tsunamiFrom + (tsunamiTo - tsunamiFrom) * progress
end

local function setTsunami(active)
    tsunamiFrom = tsunamiStrength()
    tsunamiTo = active and (Config.TsunamiStrength or 1.0) or 0.0
    tsunamiBegan = GetGameTimer()
end

local function applyState(newState, opts)
    opts = opts or {}
    local targetHour = newState.hour
    local targetMinute = newState.minute
    local weatherChanged = newState.weather ~= State.weather or newState.instantWeather ~= State.instantWeather

    if opts.smoothTime then
        newState.hour = State.hour
        newState.minute = State.minute
        State = newState
        smoothTo(targetHour, targetMinute)
    else
        cancelSmooth()
        State = newState
    end

    if opts.initial or opts.applyWeather or weatherChanged then
        applyWeather(State.weather, opts.initial == true or State.instantWeather == true)
    end

    setTsunami(State.tsunami == true)
end

local function notify(message)
    if type(message) ~= 'string' or message == '' then
        return
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

local function closeMenu()
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNetEvent('snelle-time:state', function(newState, opts)
    if type(newState) ~= 'table' or type(newState.hour) ~= 'number' or type(newState.minute) ~= 'number' then
        return
    end
    applyState(newState, opts)
end)

RegisterNetEvent('snelle-time:tick', function(hour, minute, frozen)
    if type(hour) ~= 'number' or type(minute) ~= 'number' then
        return
    end

    State.freeze = frozen == true
    if transitioning then
        return
    end

    State.hour = math.floor(hour) % 24
    State.minute = math.max(0, math.min(59, math.floor(minute)))
end)

RegisterNetEvent('snelle-time:open', function(serverState, weathers, locale)
    menuOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        state = serverState,
        weathers = weathers,
        locale = locale
    })
end)

RegisterNetEvent('snelle-time:notify', function(message)
    notify(message)
end)

RegisterNetEvent('snelle-time:result', function(message)
    SendNUIMessage({
        action = 'toast',
        message = message
    })
end)

RegisterNUICallback('close', function(_, cb)
    closeMenu()
    cb({ ok = true })
end)

RegisterNUICallback('change', function(data, cb)
    TriggerServerEvent('snelle-time:apply', data, false)
    cb({ ok = true })
end)

RegisterNUICallback('save', function(data, cb)
    TriggerServerEvent('snelle-time:apply', data, true)
    cb({ ok = true })
end)

RegisterCommand(Config.Command, function()
    TriggerServerEvent('snelle-time:requestOpen')
end, false)

CreateThread(function()
    PauseClock(true)
    while true do
        NetworkOverrideClockTime(State.hour, State.minute, 0)
        SetArtificialLightsState(State.blackout == true)
        SetArtificialLightsStateAffectsVehicles(false)
        if menuOpen then
            DisableControlAction(0, 199, true)
            DisableControlAction(0, 200, true)
        end
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        local info = Config.WeatherById(State.weather)
        if State.weather and not weatherSettling then
            SetWeatherTypePersist(State.weather)
            if State.instantWeather then
                SetWeatherTypeNowPersist(State.weather)
            end
        end

        SetRainLevel((info and info.rain) or 0.0)
        SetWindSpeed((info and info.wind) or 0.0)
        local snow = info and info.snow or false
        SetForceVehicleTrails(snow)
        SetForcePedFootstepsTracks(snow)
        Wait(1000)
    end
end)

CreateThread(function()
    local applied = -1.0
    while true do
        local strength = tsunamiStrength()
        if math.abs(strength - applied) > 0.002 then
            WaterOverrideSetStrength(strength + 0.0)
            applied = strength
            Wait(0)
        else
            Wait(500)
        end
    end
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    CreateThread(function()
        Wait(1500)
        TriggerServerEvent('snelle-time:requestSync')
        pcall(function()
            TriggerEvent('chat:addSuggestion', '/' .. Config.Command, Config.Locale.suggestion)
        end)
    end)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    menuOpen = false
    SetNuiFocus(false, false)
    WaterOverrideSetStrength(0.0)
end)

exports('GetState', function()
    return Config.CopyState(State)
end)
