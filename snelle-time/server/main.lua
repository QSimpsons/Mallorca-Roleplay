local state = Config.CopyState(Config.Defaults)
local timeToken = 0
local holdUntil = 0
local lastApply = {}
local lastOpen = {}

local function publicState()
    return Config.CopyState(state)
end

local function isAllowed(src)
    if src == 0 then
        return true
    end

    if not Config.RequirePermission then
        return true
    end

    if IsPlayerAceAllowed(src, Config.AcePermission) then
        return true
    end

    local wanted = {}
    local list = Config.AllowedIdentifiers or {}
    for i = 1, #list do
        wanted[list[i]] = true
    end

    local identifiers = GetPlayerIdentifiers(src)
    for i = 1, #identifiers do
        if wanted[identifiers[i]] then
            return true
        end
    end

    return false
end

local function flag(value, fallback, loose)
    if value == true or value == false then
        return value
    end
    if loose then
        return fallback
    end
    return nil
end

local function sanitize(data, loose)
    if type(data) ~= 'table' then
        return nil
    end

    local hour = tonumber(data.hour)
    local minute = tonumber(data.minute)
    if not hour or not minute or hour ~= hour or minute ~= minute then
        return nil
    end

    hour = math.floor(hour)
    minute = math.floor(minute)
    if hour < 0 or hour > 23 or minute < 0 or minute > 59 then
        return nil
    end

    if type(data.weather) ~= 'string' or not Config.WeatherById(data.weather) then
        return nil
    end

    local freeze = flag(data.freeze, Config.Defaults.freeze, loose)
    local blackout = flag(data.blackout, Config.Defaults.blackout, loose)
    local dynamic = flag(data.dynamic, Config.Defaults.dynamic, loose)
    local instantTime = flag(data.instantTime, Config.Defaults.instantTime, loose)
    local h24 = flag(data.h24, Config.Defaults.h24, loose)
    local instantWeather = flag(data.instantWeather, Config.Defaults.instantWeather, loose)
    local tsunami = flag(data.tsunami, Config.Defaults.tsunami, loose)

    if freeze == nil or blackout == nil or dynamic == nil or instantTime == nil
        or h24 == nil or instantWeather == nil or tsunami == nil then
        return nil
    end

    return {
        hour = hour,
        minute = minute,
        weather = data.weather,
        freeze = freeze,
        blackout = blackout,
        dynamic = dynamic,
        instantTime = instantTime,
        h24 = h24,
        instantWeather = instantWeather,
        tsunami = tsunami
    }
end

local function broadcast(target, opts)
    TriggerClientEvent('snelle-time:state', target or -1, publicState(), opts or {})
end

local function persist()
    local encoded = json.encode(publicState())
    if not encoded then
        return false
    end

    return SaveResourceFile(GetCurrentResourceName(), 'data/settings.json', encoded, -1) and true or false
end

local function loadSaved()
    local raw = LoadResourceFile(GetCurrentResourceName(), 'data/settings.json')
    if not raw or raw == '' then
        return
    end

    local ok, decoded = pcall(json.decode, raw)
    if not ok then
        print('[snelle-time] data/settings.json is ongeldig, standaardwaarden worden gebruikt.')
        return
    end

    local clean = sanitize(decoded, true)
    if not clean then
        print('[snelle-time] Opgeslagen instellingen zijn onvolledig, standaardwaarden worden gebruikt.')
        return
    end

    state = clean
end

local function gameMinuteMs()
    local ms = math.floor(tonumber(Config.MillisecondsPerGameMinute) or 2000)
    if ms < 100 then
        ms = 100
    end
    return ms
end

local function rateOk(src, kind)
    local key = tostring(src) .. ':' .. kind
    local now = GetGameTimer()
    local previous = lastApply[key]
    if previous and (now - previous) < 300 then
        return false
    end
    lastApply[key] = now
    return true
end

local function pickDynamicWeather()
    local pool = Config.DynamicWeatherTypes or {}
    if #pool == 0 then
        return state.weather
    end

    local choice = pool[math.random(#pool)]
    if choice == state.weather and #pool > 1 then
        local index = math.random(#pool - 1)
        for i = 1, #pool do
            if pool[i] ~= state.weather then
                index = index - 1
                if index == 0 then
                    return pool[i]
                end
            end
        end
    end

    return choice
end

loadSaved()
math.randomseed(os.time())

CreateThread(function()
    while true do
        local token = timeToken
        local waitMs = state.freeze and 1000 or gameMinuteMs()
        Wait(waitMs)

        if token == timeToken and not state.freeze and GetGameTimer() >= holdUntil then
            state.minute = state.minute + 1
            if state.minute >= 60 then
                state.minute = 0
                state.hour = (state.hour + 1) % 24
            end
            TriggerClientEvent('snelle-time:tick', -1, state.hour, state.minute, false)
        end
    end
end)

CreateThread(function()
    local interval = math.floor((Config.DynamicWeatherMinutes or 15) * 60000)
    if interval < 60000 then
        interval = 60000
    end

    while true do
        Wait(interval)
        if state.dynamic then
            local nextWeather = pickDynamicWeather()
            if nextWeather ~= state.weather and Config.WeatherById(nextWeather) then
                state.weather = nextWeather
                broadcast(-1, {
                    smoothTime = false,
                    applyWeather = true
                })
            end
        end
    end
end)

RegisterNetEvent('snelle-time:requestSync', function()
    broadcast(source, {
        initial = true,
        smoothTime = false,
        applyWeather = true
    })
end)

local function openFor(src)
    if src == 0 then
        return
    end

    local now = GetGameTimer()
    if lastOpen[src] and (now - lastOpen[src]) < 500 then
        return
    end
    lastOpen[src] = now

    if not isAllowed(src) then
        TriggerClientEvent('snelle-time:notify', src, Config.Locale.denied)
        return
    end

    TriggerClientEvent('snelle-time:open', src, publicState(), Config.Weathers, Config.Locale)
end

RegisterNetEvent('snelle-time:requestOpen', function()
    openFor(source)
end)

RegisterNetEvent('snelle-time:apply', function(data, shouldSave)
    local src = source
    if not isAllowed(src) then
        TriggerClientEvent('snelle-time:notify', src, Config.Locale.denied)
        return
    end

    if not rateOk(src, shouldSave == true and 'save' or 'change') then
        return
    end

    local clean = sanitize(data, false)
    if not clean then
        TriggerClientEvent('snelle-time:notify', src, Config.Locale.invalid)
        return
    end

    local timeChanged = clean.hour ~= state.hour or clean.minute ~= state.minute or clean.freeze ~= state.freeze
    local weatherChanged = clean.weather ~= state.weather or clean.instantWeather ~= state.instantWeather
    state = clean

    if timeChanged then
        timeToken = timeToken + 1
        if not state.instantTime and not state.freeze then
            local smoothMs = math.floor((tonumber(Config.SmoothTimeChangeSeconds) or 15) * 1000)
            holdUntil = GetGameTimer() + math.max(0, smoothMs)
        else
            holdUntil = 0
        end
    end

    local saved = true
    if shouldSave == true then
        saved = persist()
    end

    broadcast(-1, {
        smoothTime = timeChanged and not state.instantTime and not state.freeze,
        applyWeather = weatherChanged
    })

    local name = GetPlayerName(src) or 'onbekend'
    print(('[snelle-time] %s (%s) zette %02d:%02d, weer %s%s'):format(
        name,
        src,
        state.hour,
        state.minute,
        state.weather,
        shouldSave == true and ' (opgeslagen)' or ''
    ))

    if shouldSave == true and not saved then
        TriggerClientEvent('snelle-time:notify', src, Config.Locale.saveFailed)
        TriggerClientEvent('snelle-time:result', src, Config.Locale.saveFailed)
        return
    end

    local message = shouldSave == true and Config.Locale.saved or Config.Locale.applied
    TriggerClientEvent('snelle-time:notify', src, message)
    TriggerClientEvent('snelle-time:result', src, message)
end)

AddEventHandler('playerDropped', function()
    local prefix = tostring(source) .. ':'
    local stale = {}
    for key in pairs(lastApply) do
        if type(key) == 'string' and key:sub(1, #prefix) == prefix then
            stale[#stale + 1] = key
        end
    end
    for i = 1, #stale do
        lastApply[stale[i]] = nil
    end
    lastOpen[source] = nil
end)

RegisterCommand(Config.Command, function(src)
    if src == 0 then
        print(('[snelle-time] Nu %02d:%02d, weer %s, freeze %s'):format(
            state.hour,
            state.minute,
            state.weather,
            state.freeze and 'aan' or 'uit'
        ))
        return
    end

    openFor(src)
end, false)

exports('GetState', function()
    return publicState()
end)

print(('[snelle-time] Gestart op %02d:%02d met weer %s. Commando /%s'):format(
    state.hour,
    state.minute,
    state.weather,
    Config.Command
))
