local events = {}
local clientEvents = {}
local commands = {}
local savedFile = nil
local now = 100000
local allowAce = true

function GetGameTimer()
    return now
end

function IsPlayerAceAllowed()
    return allowAce
end

function GetPlayerIdentifiers()
    return { 'license:test' }
end

function GetPlayerName()
    return 'Tester'
end

function GetCurrentResourceName()
    return 'eclipse-time'
end

function LoadResourceFile()
    return nil
end

function SaveResourceFile(_, _, data)
    savedFile = data
    return true
end

function TriggerClientEvent(name, target, ...)
    clientEvents[#clientEvents + 1] = { name = name, target = target, args = { ... } }
end

function RegisterNetEvent(name, handler)
    events[name] = handler
end

function RegisterCommand(name, handler)
    commands[name] = handler
end

function AddEventHandler()
end

function CreateThread()
end

json = {
    encode = function()
        return '{"ok":true}'
    end,
    decode = function()
        error('geen json in deze test')
    end
}

local exported = {}
function exports(name, handler)
    exported[name] = handler
end

dofile('eclipse-time/config.lua')
dofile('eclipse-time/server/main.lua')

local function assertEq(actual, expected, label)
    if actual ~= expected then
        error(label .. ': verwacht ' .. tostring(expected) .. ', kreeg ' .. tostring(actual))
    end
end

local state = exported.GetState()
assertEq(state.hour, 14, 'startuur')
assertEq(state.minute, 0, 'startminuut')
assertEq(state.weather, 'EXTRASUNNY', 'startweer')
assertEq(state.freeze, true, 'start freeze')

local function payload(overrides)
    local data = {
        hour = 8,
        minute = 30,
        weather = 'RAIN',
        freeze = false,
        blackout = true,
        dynamic = false,
        instantTime = true,
        h24 = true,
        instantWeather = false,
        tsunami = true
    }
    for key, value in pairs(overrides or {}) do
        data[key] = value
    end
    return data
end

source = 7
allowAce = false
events['eclipse-time:apply'](payload(), false)
assertEq(exported.GetState().weather, 'EXTRASUNNY', 'zonder rechten blijft het weer')
assertEq(clientEvents[#clientEvents].name, 'eclipse-time:notify', 'weigering meldt')

allowAce = true
clientEvents = {}
now = now + 400
events['eclipse-time:apply'](payload({ weather = 'METEOR' }), false)
assertEq(exported.GetState().weather, 'EXTRASUNNY', 'ongeldig weer wordt geweigerd')
assertEq(clientEvents[#clientEvents].args[1], Config.Locale.invalid, 'ongeldige melding')

now = now + 400
events['eclipse-time:apply'](payload({ hour = 24 }), false)
assertEq(exported.GetState().hour, 14, 'uur 24 wordt geweigerd')
assertEq(clientEvents[#clientEvents].args[1], Config.Locale.invalid, 'uur buiten bereik')

now = now + 400
events['eclipse-time:apply'](payload({ freeze = 'ja' }), false)
assertEq(exported.GetState().freeze, true, 'geen boolean wordt geweigerd')

clientEvents = {}
now = now + 400
events['eclipse-time:apply'](payload(), false)
state = exported.GetState()
assertEq(state.hour, 8, 'uur toegepast')
assertEq(state.minute, 30, 'minuut toegepast')
assertEq(state.weather, 'RAIN', 'weer toegepast')
assertEq(state.freeze, false, 'freeze uit')
assertEq(state.blackout, true, 'blackout aan')
assertEq(state.tsunami, true, 'tsunami aan')
assertEq(state.instantWeather, false, 'geleidelijke weerwisseling')
assertEq(clientEvents[1].name, 'eclipse-time:state', 'staat naar clients')
assertEq(clientEvents[1].target, -1, 'broadcast')
assertEq(clientEvents[1].args[2].smoothTime, false, 'directe tijd springt')
assertEq(clientEvents[1].args[2].applyWeather, true, 'weer wordt gezet')

now = now + 50
local before = #clientEvents
events['eclipse-time:apply'](payload({ hour = 9 }), false)
assertEq(#clientEvents, before, 'te snelle tweede wijziging wordt genegeerd')
assertEq(exported.GetState().hour, 8, 'uur blijft na rate limit')

now = now + 400
events['eclipse-time:apply'](payload({
    hour = 1,
    minute = 0,
    weather = 'CLOUDS',
    instantTime = false,
    freeze = false
}), true)
state = exported.GetState()
assertEq(state.hour, 1, 'opslaan past het uur toe')
assertEq(state.weather, 'CLOUDS', 'opslaan past het weer toe')
assertEq(savedFile, '{"ok":true}', 'bestand geschreven')
local foundSmooth = false
for i = 1, #clientEvents do
    if clientEvents[i].name == 'eclipse-time:state' and clientEvents[i].args[2].smoothTime == true then
        foundSmooth = true
    end
end
assertEq(foundSmooth, true, 'uitgestelde tijdswissel')

now = now + 400
clientEvents = {}
events['eclipse-time:requestOpen']()
assertEq(clientEvents[1].name, 'eclipse-time:open', 'menu opent')
assertEq(clientEvents[1].args[1].hour, 1, 'menu toont de servertijd')

now = now + 100
local openCount = #clientEvents
events['eclipse-time:requestOpen']()
assertEq(#clientEvents, openCount, 'dubbele open wordt gedempt')

commands.time(0)
assertEq(#clientEvents, openCount, 'console opent geen menu')

print('server.test.lua ok')
