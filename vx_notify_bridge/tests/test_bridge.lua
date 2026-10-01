local root = arg[0]:match('^(.*)/') or '.'
local passed = 0

local function eq(actual, expected, label)
    if actual ~= expected then
        error(('%s: verwacht %q, kreeg %q'):format(label, tostring(expected), tostring(actual)), 2)
    end
end

dofile(root .. '/../normalize.lua')

local function check(label, payload, field, expected)
    eq(payload[field], expected, label .. '.' .. field)
    passed = passed + 1
end

local tableCall = NotifyBridge.normalize({
    title = 'Cardealer',
    message = 'Je hebt een voertuig gekocht',
    type = 'success',
    duration = 4000,
})
check('tabel', tableCall, 'title', 'Cardealer')
check('tabel', tableCall, 'description', 'Je hebt een voertuig gekocht')
check('tabel', tableCall, 'type', 'success')
check('tabel', tableCall, 'duration', 4000)

local infoCall = NotifyBridge.normalize({ text = 'Klaar', type = 'info' })
check('info', infoCall, 'description', 'Klaar')
check('info', infoCall, 'type', 'inform')

local typeMessage = NotifyBridge.normalize('error', 'Te weinig geld', 2500)
check('type-bericht', typeMessage, 'type', 'error')
check('type-bericht', typeMessage, 'description', 'Te weinig geld')
check('type-bericht', typeMessage, 'duration', 2500)

local messageType = NotifyBridge.normalize('Betaald', 'success')
check('bericht-type', messageType, 'description', 'Betaald')
check('bericht-type', messageType, 'type', 'success')

local esxStyle = NotifyBridge.normalize('warning', 3000, 'Let op', 'Dealer')
check('esx', esxStyle, 'type', 'warning')
check('esx', esxStyle, 'duration', 3000)
check('esx', esxStyle, 'description', 'Let op')
check('esx', esxStyle, 'title', 'Dealer')

local titled = NotifyBridge.normalize('Cardealer', 'Staat in de garage', 'success', 1500)
check('titel', titled, 'title', 'Cardealer')
check('titel', titled, 'description', 'Staat in de garage')
check('titel', titled, 'type', 'success')
check('titel', titled, 'duration', 1500)

local plain = NotifyBridge.normalize('Alleen tekst')
check('tekst', plain, 'description', 'Alleen tekst')
check('tekst', plain, 'type', 'inform')

local handlers = {}

local function addEventHandler(name, fn)
    handlers[name] = fn
end

local delivered
local exploded = false

NotifyBridge.bind(addEventHandler, function(...)
    delivered = NotifyBridge.normalize(...)
    if exploded then
        error('display kapot')
    end
end)

local exportFn
handlers['__cfx_export_vx_notify_notify'](function(fn)
    exportFn = fn
end)

if type(exportFn) ~= 'function' then
    error('export notify is niet geregistreerd')
end
passed = passed + 1

local returned = exportFn({ message = 'Garage', type = 'success' })
eq(returned, true, 'export geeft true terug')
passed = passed + 1
eq(delivered.description, 'Garage', 'export levert de melding')
passed = passed + 1
eq(delivered.type, 'success', 'export levert het type')
passed = passed + 1

exploded = true
local stillOk = exportFn('mislukt', 'error')
eq(stillOk, true, 'een fout in de melding stopt de aankoop niet')
passed = passed + 1

local clientHandlers = {}
local clientEvents = {}
local nativeText
local oxPayload
local resourceState = {
    vx_notify = 'missing',
    ox_lib = 'missing',
    es_extended = 'missing',
}

function AddEventHandler(name, fn)
    clientHandlers[name] = fn
end

function RegisterNetEvent(name, fn)
    clientEvents[name] = fn
end

function GetResourceState(name)
    return resourceState[name] or 'missing'
end

function BeginTextCommandThefeedPost() end

function AddTextComponentSubstringPlayerName(text)
    nativeText = text
end

function EndTextCommandThefeedPostTicker() end

function TriggerEvent() end

exports = setmetatable({}, {
    __index = function(_, resource)
        return setmetatable({}, {
            __index = function(_, name)
                if resource == 'ox_lib' and name == 'notify' then
                    return function(_, data)
                        oxPayload = data
                    end
                end

                error('No such export ' .. tostring(name) .. ' in resource ' .. tostring(resource))
            end,
        })
    end,
})

dofile(root .. '/../client.lua')

local clientExport
clientHandlers['__cfx_export_vx_notify_notify'](function(fn)
    clientExport = fn
end)

clientExport('success', 'Voertuig staat in je garage')
eq(nativeText, 'Voertuig staat in je garage', 'zonder ox_lib komt de melding in de feed')
passed = passed + 1

resourceState.ox_lib = 'started'
nativeText = nil
clientExport({ title = 'Cardealer', message = 'Gekocht', type = 'error' })
eq(oxPayload.description, 'Gekocht', 'ox_lib krijgt de tekst')
passed = passed + 1
eq(oxPayload.type, 'error', 'ox_lib krijgt het type')
passed = passed + 1
eq(oxPayload.title, 'Cardealer', 'ox_lib krijgt de titel')
passed = passed + 1
eq(nativeText, nil, 'ox_lib vervangt de GTA-feed')
passed = passed + 1

local forwarded
resourceState.vx_notify = 'started'
local oldIndex = getmetatable(exports).__index
getmetatable(exports).__index = function(_, resource)
    return setmetatable({}, {
        __index = function(_, name)
            if resource == 'vx_notify' and name == 'Notify' then
                return function(_, data)
                    forwarded = data
                end
            end

            error('No such export ' .. tostring(name) .. ' in resource ' .. tostring(resource))
        end,
    })
end

clientExport({ message = 'Bestaande notify', type = 'success' })
eq(forwarded.message, 'Bestaande notify', 'bestaande Notify-export wordt gebruikt')
passed = passed + 1
getmetatable(exports).__index = oldIndex

local serverHandlers = {}
local sent

function AddEventHandler(name, fn)
    serverHandlers[name] = fn
end

function TriggerClientEvent(name, target, payload)
    sent = { name = name, target = target, payload = payload }
end

source = nil
dofile(root .. '/../server.lua')

local serverExport
serverHandlers['__cfx_export_vx_notify_notify'](function(fn)
    serverExport = fn
end)

serverExport(4, 'success', 'Betaald')
eq(sent.target, 4, 'server stuurt naar het speler-id')
passed = passed + 1
eq(sent.payload.description, 'Betaald', 'server stuurt de tekst door')
passed = passed + 1
eq(sent.payload.type, 'success', 'server stuurt het type door')
passed = passed + 1

source = 9
sent = nil
serverExport({ message = 'Voor jezelf', type = 'inform' })
eq(sent.target, 9, 'zonder speler-id gaat de melding naar source')
passed = passed + 1
eq(sent.payload.description, 'Voor jezelf', 'source-melding houdt de tekst')
passed = passed + 1

print(('ok %d checks'):format(passed))
