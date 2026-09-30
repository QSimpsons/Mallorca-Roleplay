---@type table Target module; the table returned at end of file. One API over the supported
---target resources (ox_target, qb-target, qtarget).
local target = {}

---@type string[] Supported target resources, in detection-priority order.
local SUPPORTED = { 'ox_target', 'qb-target', 'qtarget' }

---Modern ox_target exports. Any one of these means the client script got far enough to register
---the camelCase API. Resource state alone is not enough: ox_target stays "started" when
---client/main.lua returns early (ox_lib older than that build requires) and registers nothing.
local OX_MARKERS = { 'addModel', 'addBoxZone', 'addSphereZone', 'addGlobalPed', 'addGlobalPlayer', 'addEntity' }

---@type string|nil Active backend resource, or nil while none has usable exports.
local active

---@type 'ox'|'legacy'|nil Call style for `active`.
local api

---@type fun()[] Callbacks waiting for a backend to appear; drained once one does.
local pending = {}

---@type { name: string, args: table }[] Registrations made before a backend was usable.
local queued = {}

---@type table<string, boolean> Methods that have already reported a missing backend.
local warned = {}

---@type table<string, boolean> Methods that have already reported a missing export.
local failed = {}

local reported = false
local watching = false
local flushing = false
local booting = true

---@param resource string|nil
---@return boolean
local function started(resource)
    return type(resource) == 'string' and GetResourceState(resource) == 'started'
end

---Indexing a missing export throws "No such export ...". That is not a failed call.
---@param resource string
---@param exportName string
---@return boolean
local function hasExport(resource, exportName)
    if not started(resource) then return false end
    local ok, fn = pcall(function()
        return exports[resource][exportName]
    end)
    return ok and fn ~= nil
end

---Calls an export. The proxy ignores its first argument, matching a colon call.
---A missing export returns false instead of killing the client script.
---@param resource string
---@param exportName string
---@return boolean ok
---@return any result
local function tryExport(resource, exportName, ...)
    if not started(resource) then
        return false, 'missing'
    end
    local packed = table.pack(...)
    local ok, result = pcall(function()
        return exports[resource][exportName](exports[resource], table.unpack(packed, 1, packed.n))
    end)
    if ok then
        return true, result
    end
    if type(result) == 'string' and result:find('No such export', 1, true) then
        return false, 'missing'
    end
    error(result)
end

---@param resource string
---@return boolean
local function hasModern(resource)
    for i = 1, #OX_MARKERS do
        if hasExport(resource, OX_MARKERS[i]) then
            return true
        end
    end
    return false
end

---Returns the first supported target whose exports can actually be called.
---@return string|nil resource
---@return 'ox'|'legacy'|nil kind
local function resolve()
    if started('ox_target') and hasModern('ox_target') then
        return 'ox_target', 'ox'
    end
    if started('ox_target') and hasExport('ox_target', 'AddTargetModel') then
        return 'ox_target', 'legacy'
    end
    if started('qb-target') and (hasExport('qb-target', 'AddTargetModel') or hasExport('qb-target', 'AddBoxZone')) then
        return 'qb-target', 'legacy'
    end
    if started('qtarget') and (hasExport('qtarget', 'AddTargetModel') or hasExport('qtarget', 'AddBoxZone') or hasExport('qtarget', 'Player')) then
        return 'qtarget', 'legacy'
    end
    return nil, nil
end

---@param method string
local function warnWaiting(method)
    if warned[method] then return end
    warned[method] = true
    if started('ox_target') or started('qb-target') or started('qtarget') then
        print(('^3[sd-phone]^0 target.%s queued: a target resource is started but its exports are not available yet.')
            :format(method))
    else
        print(('^3[sd-phone]^0 target.%s queued: no target resource is running yet (ox_target, qb-target or qtarget).')
            :format(method))
    end
end

---@param method string
local function warnFailed(method)
    if failed[method] then return end
    failed[method] = true
    print(('^3[sd-phone]^0 target.%s skipped: %s has no matching export.')
        :format(method, active or 'target'))
end

local function reportUnavailable()
    if active or reported then return end
    reported = true
    if started('ox_target') then
        print('^1[sd-phone]^0 ox_target is running but never registered addModel or AddTargetModel. Its client script stopped before creating exports, so target options cannot be registered. This usually means ox_lib is older than the version ox_target requires (current ox_target needs ox_lib 3.30.0 or newer). Update ox_lib, restart ox_target, then restart sd-phone.')
    elseif started('qb-target') or started('qtarget') then
        print('^1[sd-phone]^0 a target resource is running but it did not register its target exports. Target options were not registered.')
    else
        print('^3[sd-phone]^0 no target resource is running (ox_target, qb-target or qtarget). Payphone booths and any other target interactions stay off until one starts.')
    end
end

---Legacy export names for one ox-style method. qtarget's compat layer uses Player/Ped/Vehicle/Object
---where qb-target uses AddGlobalPlayer/AddGlobalPed/AddGlobalVehicle/AddGlobalObject.
---@param names string[]
---@return boolean ok
---@return any result
local function callLegacy(names, ...)
    local resources = {}
    if active then resources[#resources + 1] = active end
    if active == 'ox_target' then resources[#resources + 1] = 'qtarget' end

    for i = 1, #resources do
        local resource = resources[i]
        if started(resource) then
            for j = 1, #names do
                local ok, result = tryExport(resource, names[j], ...)
                if ok then
                    return true, result
                end
            end
        end
    end
    return false
end

local function flushQueue()
    local calls = queued
    queued = {}
    flushing = true
    for i = 1, #calls do
        local call = calls[i]
        local fn = target[call.name]
        if fn then
            fn(table.unpack(call.args, 1, call.args.n))
        end
    end
    flushing = false
end

---@param resource string
---@param kind 'ox'|'legacy'
local function activate(resource, kind)
    active = resource
    api = kind
    target.system = resource
    reported = false
    if not booting or #pending > 0 or #queued > 0 then
        print(('^2[sd-phone]^0 target resource %s started; registering interactions now.'):format(resource))
    end

    local ready = pending
    pending = {}
    for i = 1, #ready do
        ready[i]()
    end
    flushQueue()
end

---@return boolean
local function refresh()
    if active then return true end
    local resource, kind = resolve()
    if not resource then return false end
    activate(resource, kind)
    return true
end

local function watch()
    if watching or active then return end
    watching = true
    CreateThread(function()
        for _ = 1, 40 do
            if active then
                watching = false
                return
            end
            Wait(500)
            if refresh() then
                watching = false
                return
            end
        end
        watching = false
        if not active then
            reportUnavailable()
        end
    end)
end

---Runs `cb` as soon as a backend is available: right now when one is already usable, otherwise
---the moment a supported resource registers its exports. Registration that would otherwise run at
---load time belongs here, because a server is free to start sd-phone before its target resource.
---@param cb fun()
function target.onReady(cb)
    if type(cb) ~= 'function' then return end
    if active then return cb() end
    pending[#pending + 1] = cb
end

AddEventHandler('onClientResourceStart', function(resource)
    local relevant = resource == 'ox_lib'
    if not relevant then
        for i = 1, #SUPPORTED do
            if resource == SUPPORTED[i] then
                relevant = true
                break
            end
        end
    end
    if not relevant then return end
    reported = false
    if refresh() then return end
    watch()
end)

AddEventHandler('onClientResourceStop', function(resource)
    if resource ~= active then return end
    active = nil
    api = nil
    target.system = nil
end)

---Wraps an ox_target onSelect so qb-target/qtarget can call it. Those backends invoke
---action(entity, optionData) with the raw entity handle first, while ox_target passes one table
---{ entity, coords, ... }. Handing onSelect over unwrapped meant every consumer that indexed its
---argument crashed under qb-target with "attempt to index a number value".
---@param onSelect fun(data: table)|nil ox_target-shaped handler
---@return fun(entity: number|nil, data: table|nil)|nil action in the qb-target/qtarget shape
local function adaptAction(onSelect)
    if type(onSelect) ~= 'function' then return nil end
    return function(entity, data)
        local handle = type(entity) == 'number' and entity ~= 0 and entity or nil
        onSelect({
            entity = handle,
            coords = handle and DoesEntityExist(handle) and GetEntityCoords(handle) or nil,
            name   = type(data) == 'table' and data.name or nil,
        })
    end
end

---Translate ox_target option entries to the qb-target/qtarget shape.
---@param options table[] ox_target-shaped option entries
---@param forceLegacy? boolean convert even while the modern ox API is selected
---@return table[] options in the active backend's shape
local function convertOptions(options, forceLegacy)
    if api == 'ox' and not forceLegacy then return options end
    if type(options) ~= 'table' then return {} end

    local out = {}
    for i = 1, #options do
        local o = options[i]
        out[#out + 1] = {
            type        = o.type or 'client',
            event       = o.event,
            icon        = o.icon,
            label       = o.label,
            action      = adaptAction(o.onSelect),
            canInteract = o.canInteract,
            distance    = o.distance,
            groups      = o.groups,
            items       = o.items,
        }
    end
    return out
end

---Register a box-shaped interaction zone at fixed world coordinates. On qb-target/qtarget a
---random name is minted when none is given, size defaults to 2x2x2, and minZ/maxZ derive from centre + height.
---@param data table ox_target box-zone data.
function target.addBoxZone(data)
    if api == 'ox' then
        local ok, result = tryExport(active, 'addBoxZone', data)
        if ok then return result end
    end

    local name    = data.name or ('box_zone_' .. math.random(100000, 999999))
    local size    = data.size or vec3(2, 2, 2)
    local heading = data.rotation or 0
    local ok, result = callLegacy({ 'AddBoxZone' }, name, data.coords, size.x, size.y, {
        name      = name,
        heading   = heading,
        debugPoly = data.debug or false,
        minZ      = data.coords.z - (size.z / 2),
        maxZ      = data.coords.z + (size.z / 2),
    }, {
        options  = convertOptions(data.options, true),
        distance = data.distance or 2.5,
    })
    if ok then return result == nil and true or result end
    warnFailed('addBoxZone')
    return false
end

---Register a sphere-shaped interaction zone at fixed world coordinates. The qb-target/qtarget
---equivalent is a Z-aware circle zone; a random name is minted when none is given.
---@param data table ox_target sphere-zone data.
function target.addSphereZone(data)
    if api == 'ox' then
        local ok, result = tryExport(active, 'addSphereZone', data)
        if ok then return result end
    end

    local name = data.name or ('sphere_zone_' .. math.random(100000, 999999))
    local ok, result = callLegacy({ 'AddCircleZone' }, name, data.coords, data.radius or 1.0, {
        name      = name,
        useZ      = true,
        debugPoly = data.debug or false,
    }, {
        options  = convertOptions(data.options, true),
        distance = data.distance or 2.5,
    })
    if ok then return result == nil and true or result end
    warnFailed('addSphereZone')
    return false
end

---Register a polygon-shaped interaction zone defined by an array of points. On qb-target/qtarget
---minZ/maxZ derive from the centre coords + thickness when coords are provided.
---@param data table ox_target poly-zone data.
function target.addPolyZone(data)
    if api == 'ox' then
        local ok, result = tryExport(active, 'addPolyZone', data)
        if ok then return result end
    end

    local name = data.name or ('poly_zone_' .. math.random(100000, 999999))
    local ok, result = callLegacy({ 'AddPolyZone' }, name, data.points, {
        name      = name,
        debugPoly = data.debug or false,
        minZ      = data.coords and data.coords.z - (data.thickness or 2) / 2,
        maxZ      = data.coords and data.coords.z + (data.thickness or 2) / 2,
    }, {
        options  = convertOptions(data.options, true),
        distance = data.distance or 2.5,
    })
    if ok then return result == nil and true or result end
    warnFailed('addPolyZone')
    return false
end

---Attach target options to a networked entity addressed by its net id; the local entity handle
---is resolved for the qb-target/qtarget call.
---@param netId number
---@param options table[]
function target.addEntity(netId, options)
    if api == 'ox' then
        local ok, result = tryExport(active, 'addEntity', netId, options)
        if ok then return result end
    end
    local entity = NetworkGetEntityFromNetworkId(netId)
    local ok = callLegacy({ 'AddTargetEntity' }, entity, {
        options  = convertOptions(options, true),
        distance = options.distance or 2.5,
    })
    if ok then return true end
    warnFailed('addEntity')
    return false
end

---Attach target options to a client-local entity (not networked).
---@param entity number Local entity (not networked).
---@param options table[]
function target.addLocalEntity(entity, options)
    if api == 'ox' then
        local ok, result = tryExport(active, 'addLocalEntity', entity, options)
        if ok then return result end
    end
    local ok = callLegacy({ 'AddTargetEntity' }, entity, {
        options  = convertOptions(options, true),
        distance = options.distance or 2.5,
    })
    if ok then return true end
    warnFailed('addLocalEntity')
    return false
end

---Attach target options to every entity matching one or more model hashes. A single model is
---wrapped into a list for the qb-target/qtarget call.
---@param models string|number|(string|number)[]
---@param options table[]
function target.addModel(models, options)
    if api == 'ox' then
        local ok, result = tryExport(active, 'addModel', models, options)
        if ok then return result end
    end
    local ok = callLegacy({ 'AddTargetModel' }, type(models) == 'table' and models or { models }, {
        options  = convertOptions(options, true),
        distance = type(options) == 'table' and options.distance or 2.5,
    })
    if ok then return true end
    warnFailed('addModel')
    return false
end

---Attach target options to every ped in the world.
---@param options table[]
function target.addGlobalPed(options)
    if api == 'ox' then
        local ok, result = tryExport(active, 'addGlobalPed', options)
        if ok then return result end
    end
    local ok = callLegacy({ 'AddGlobalPed', 'Ped' }, {
        options  = convertOptions(options, true),
        distance = type(options) == 'table' and options.distance or 2.5,
    })
    if ok then return true end
    warnFailed('addGlobalPed')
    return false
end

---Attach target options to every vehicle in the world.
---@param options table[]
function target.addGlobalVehicle(options)
    if api == 'ox' then
        local ok, result = tryExport(active, 'addGlobalVehicle', options)
        if ok then return result end
    end
    local ok = callLegacy({ 'AddGlobalVehicle', 'Vehicle' }, {
        options  = convertOptions(options, true),
        distance = type(options) == 'table' and options.distance or 2.5,
    })
    if ok then return true end
    warnFailed('addGlobalVehicle')
    return false
end

---Attach target options to every world object.
---@param options table[]
function target.addGlobalObject(options)
    if api == 'ox' then
        local ok, result = tryExport(active, 'addGlobalObject', options)
        if ok then return result end
    end
    local ok = callLegacy({ 'AddGlobalObject', 'Object' }, {
        options  = convertOptions(options, true),
        distance = type(options) == 'table' and options.distance or 2.5,
    })
    if ok then return true end
    warnFailed('addGlobalObject')
    return false
end

local warnedPlayerFallback = false

---Older ox_target builds have addGlobalPed and no addGlobalPlayer. Players are peds, so keep the
---option off NPCs by wrapping canInteract.
---@param options table
---@return table
local function playerPedOptions(options)
    local function wrap(option)
        if type(option) ~= 'table' then return option end
        local copy = {}
        for key, value in pairs(option) do
            copy[key] = value
        end
        local original = option.canInteract
        copy.canInteract = function(entity, ...)
            if entity and entity ~= 0 and not IsPedAPlayer(entity) then
                return false
            end
            if original then
                return original(entity, ...)
            end
            return true
        end
        return copy
    end

    if type(options) ~= 'table' then
        return options
    end

    if options[1] then
        local list = {}
        for i = 1, #options do
            list[i] = wrap(options[i])
        end
        return list
    end

    return wrap(options)
end

---Attach target options to every other player.
---@param options table[]
function target.addGlobalPlayer(options)
    if api == 'ox' then
        local ok, result = tryExport(active, 'addGlobalPlayer', options)
        if ok then return result end
        if hasExport(active, 'addGlobalPed') then
            if not warnedPlayerFallback then
                warnedPlayerFallback = true
                print('^3[sd-phone]^0 ox_target has no addGlobalPlayer export; registering player options with addGlobalPed.')
            end
            ok, result = tryExport(active, 'addGlobalPed', playerPedOptions(options))
            if ok then return result end
        end
    end

    local distance = type(options) == 'table' and options.distance or 2.5
    local ok = callLegacy({ 'AddGlobalPlayer', 'Player' }, {
        options  = convertOptions(options, true),
        distance = distance,
    })
    if ok then return true end

    ok = callLegacy({ 'AddGlobalPed', 'Ped' }, {
        options  = convertOptions(playerPedOptions(options), true),
        distance = distance,
    })
    if ok then return true end

    warnFailed('addGlobalPlayer')
    return false
end

---Remove a previously-registered zone by id.
---@param id any Zone id returned from the matching `add...Zone` call.
function target.removeZone(id)
    if api == 'ox' then
        local ok, result = tryExport(active, 'removeZone', id)
        if ok then return result end
    end
    local ok = callLegacy({ 'RemoveZone' }, id)
    if ok then return true end
    warnFailed('removeZone')
    return false
end

---Remove a target option from a networked entity (resolved from its net id for the
---qb-target/qtarget call).
---@param netId number
---@param label? string Specific option label to remove. Removes all when omitted.
function target.removeEntity(netId, label)
    if api == 'ox' then
        local ok, result = tryExport(active, 'removeEntity', netId, label)
        if ok then return result end
    end
    local ok = callLegacy({ 'RemoveTargetEntity' }, NetworkGetEntityFromNetworkId(netId), label)
    if ok then return true end
    warnFailed('removeEntity')
    return false
end

---Remove a target option from a client-local entity.
---@param entity number
---@param label? string Specific option label to remove. Removes all when omitted.
function target.removeLocalEntity(entity, label)
    if api == 'ox' then
        local ok, result = tryExport(active, 'removeLocalEntity', entity, label)
        if ok then return result end
    end
    local ok = callLegacy({ 'RemoveTargetEntity' }, entity, label)
    if ok then return true end
    warnFailed('removeLocalEntity')
    return false
end

---Remove a target option attached via `addModel`. A single model is wrapped into a list for the
---qb-target/qtarget call.
---@param models string|number|(string|number)[]
---@param label? string Specific option label to remove. Removes all when omitted.
function target.removeModel(models, label)
    if api == 'ox' then
        local ok, result = tryExport(active, 'removeModel', models, label)
        if ok then return result end
    end
    local ok = callLegacy({ 'RemoveTargetModel' }, type(models) == 'table' and models or { models }, label)
    if ok then return true end
    warnFailed('removeModel')
    return false
end

---Remove a global ped target option.
---@param label? string Specific option label to remove. Removes all when omitted.
function target.removeGlobalPed(label)
    if api == 'ox' then
        local ok, result = tryExport(active, 'removeGlobalPed', label)
        if ok then return result end
    end
    local ok = callLegacy({ 'RemoveGlobalPed', 'RemovePed' }, label)
    if ok then return true end
    warnFailed('removeGlobalPed')
    return false
end

---Remove a global vehicle target option.
---@param label? string Specific option label to remove. Removes all when omitted.
function target.removeGlobalVehicle(label)
    if api == 'ox' then
        local ok, result = tryExport(active, 'removeGlobalVehicle', label)
        if ok then return result end
    end
    local ok = callLegacy({ 'RemoveGlobalVehicle', 'RemoveVehicle' }, label)
    if ok then return true end
    warnFailed('removeGlobalVehicle')
    return false
end

---Remove a global object target option.
---@param label? string Specific option label to remove. Removes all when omitted.
function target.removeGlobalObject(label)
    if api == 'ox' then
        local ok, result = tryExport(active, 'removeGlobalObject', label)
        if ok then return result end
    end
    local ok = callLegacy({ 'RemoveGlobalObject', 'RemoveObject' }, label)
    if ok then return true end
    warnFailed('removeGlobalObject')
    return false
end

---Remove a global player target option.
---@param label? string Specific option label to remove. Removes all when omitted.
function target.removeGlobalPlayer(label)
    if api == 'ox' then
        local ok, result = tryExport(active, 'removeGlobalPlayer', label)
        if ok then return result end
        if hasExport(active, 'removeGlobalPed') then
            ok, result = tryExport(active, 'removeGlobalPed', label)
            if ok then return result end
        end
    end
    local ok = callLegacy({ 'RemoveGlobalPlayer', 'RemovePlayer' }, label)
    if ok then return true end
    ok = callLegacy({ 'RemoveGlobalPed', 'RemovePed' }, label)
    if ok then return true end
    warnFailed('removeGlobalPlayer')
    return false
end

-- Every method above reaches for exports, so each one is wrapped in a single guard. A call made
-- before any backend has registered exports is queued and replayed when one does, instead of
-- throwing or being dropped. onReady is the exception: waiting is what it is for.
for name, fn in pairs(target) do
    if type(fn) == 'function' and name ~= 'onReady' then
        target[name] = function(...)
            if not active then
                if not flushing and #queued < 100 then
                    queued[#queued + 1] = { name = name, args = table.pack(...) }
                end
                warnWaiting(name)
                return false
            end
            return fn(...)
        end
    end
end

if not refresh() then
    booting = false
    watch()
else
    booting = false
end

return target
