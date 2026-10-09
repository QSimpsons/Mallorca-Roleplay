local parked = {}
local pendingRetrieve = {}

local function identifier(src)
    local ids = GetPlayerIdentifiers(src)
    for i = 1, #ids do
        if ids[i]:sub(1, 8) == 'license:' then
            return ids[i]
        end
    end
    return ids[1]
end

local function plateKey(plate)
    return (tostring(plate or ''):gsub('%s+', ''):upper())
end

local function spotExists(id)
    for i = 1, #Config.Parking.spots do
        if Config.Parking.spots[i].id == id then
            return true
        end
    end
    return false
end

local function copyColor(value)
    if type(value) ~= 'table' then
        return nil
    end
    local r, g, b = tonumber(value[1]), tonumber(value[2]), tonumber(value[3])
    if not r or not g or not b then
        return nil
    end
    return { math.floor(r), math.floor(g), math.floor(b) }
end

local function sanitizeProps(props)
    if type(props) ~= 'table' then
        return nil
    end

    local model = tonumber(props.model)
    local plate = type(props.plate) == 'string' and props.plate:sub(1, 12) or ''
    if not model or model <= 0 or plateKey(plate) == '' then
        return nil
    end

    local clean = {
        model = math.floor(model),
        plate = plate,
        plateIndex = tonumber(props.plateIndex) or 0,
        bodyHealth = tonumber(props.bodyHealth) or 1000.0,
        engineHealth = tonumber(props.engineHealth) or 1000.0,
        fuelLevel = tonumber(props.fuelLevel) or 65.0,
        dirtLevel = tonumber(props.dirtLevel) or 0.0,
        color1 = tonumber(props.color1) or 0,
        color2 = tonumber(props.color2) or 0,
        pearlescentColor = tonumber(props.pearlescentColor) or 0,
        wheelColor = tonumber(props.wheelColor) or 0,
        wheels = tonumber(props.wheels) or 0,
        windowTint = tonumber(props.windowTint) or 0,
        livery = tonumber(props.livery) or -1,
        turbo = props.turbo == true,
        xenon = props.xenon == true,
        neonEnabled = {},
        extras = {},
        mods = {},
    }

    if type(props.neonEnabled) == 'table' then
        for i = 1, 4 do
            clean.neonEnabled[i] = props.neonEnabled[i] == true
        end
    end

    clean.neonColor = copyColor(props.neonColor)
    clean.tyreSmokeColor = copyColor(props.tyreSmokeColor)
    clean.customPrimary = copyColor(props.customPrimary)
    clean.customSecondary = copyColor(props.customSecondary)

    if type(props.extras) == 'table' then
        for id, enabled in pairs(props.extras) do
            local extraId = tonumber(id)
            if extraId and extraId >= 0 and extraId <= 16 then
                clean.extras[tostring(math.floor(extraId))] = enabled == true
            end
        end
    end

    if type(props.mods) == 'table' then
        for modType, modIndex in pairs(props.mods) do
            local slot = tonumber(modType)
            local index = tonumber(modIndex)
            if slot and index and slot >= 0 and slot <= 49 and index >= -1 and index <= 100 then
                clean.mods[tostring(math.floor(slot))] = math.floor(index)
            end
        end
    end

    return clean
end

local function save()
    local list = {}
    for id, entry in pairs(parked) do
        list[#list + 1] = {
            id = id,
            owner = entry.owner,
            props = entry.props,
        }
    end

    local ok = SaveResourceFile(GetCurrentResourceName(), 'data/parked.json', json.encode(list), -1)
    if not ok then
        print('[snelle-blokkenpark] Kon data/parked.json niet opslaan.')
    end
end

local function remember(id, owner, props)
    if not id or type(owner) ~= 'string' or owner == '' then
        return
    end
    local clean = sanitizeProps(props)
    if clean then
        parked[id] = { owner = owner, props = clean }
    end
end

local function load()
    local raw = LoadResourceFile(GetCurrentResourceName(), 'data/parked.json')
    if not raw or raw == '' then
        parked = {}
        return
    end

    local ok, data = pcall(json.decode, raw)
    if not ok or type(data) ~= 'table' then
        print('[snelle-blokkenpark] parked.json is onleesbaar, begin leeg.')
        parked = {}
        return
    end

    parked = {}
    if data[1] then
        for i = 1, #data do
            local entry = data[i]
            if type(entry) == 'table' then
                remember(tonumber(entry.id), entry.owner, entry.props)
            end
        end
        return
    end

    for key, entry in pairs(data) do
        if type(entry) == 'table' then
            remember(tonumber(entry.id) or tonumber(key), entry.owner, entry.props)
        end
    end
end

local function countOwned(owner)
    local total = 0
    for _, entry in pairs(parked) do
        if entry.owner == owner then
            total = total + 1
        end
    end
    return total
end

local function clearPlate(plate, exceptId)
    local key = plateKey(plate)
    for id, entry in pairs(parked) do
        if id ~= exceptId and plateKey(entry.props.plate) == key then
            parked[id] = nil
        end
    end
end

local function payloadFor(src)
    local owner = identifier(src)
    local list = {}
    for id, entry in pairs(parked) do
        list[#list + 1] = {
            id = id,
            mine = entry.owner == owner,
            props = entry.props,
        }
    end
    table.sort(list, function(a, b)
        return a.id < b.id
    end)
    return list
end

local function sync(target)
    if target then
        TriggerClientEvent('snelle-blokkenpark:sync', target, payloadFor(target))
        return
    end

    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        TriggerClientEvent('snelle-blokkenpark:sync', src, payloadFor(src))
    end
end

local function reply(src, id, result)
    TriggerClientEvent('snelle-blokkenpark:rpcResult', src, id, result)
end

RegisterNetEvent('snelle-blokkenpark:requestSync', function()
    sync(source)
end)

RegisterNetEvent('snelle-blokkenpark:park', function(requestId, payload)
    local src = source
    payload = payload or {}
    local spotId = tonumber(payload.spotId)
    local owner = identifier(src)
    local props = sanitizeProps(payload.props)

    if not owner or not spotId or not spotExists(spotId) or not props then
        reply(src, requestId, { ok = false, message = props and Config.Messages.occupied or Config.Messages.invalid })
        return
    end

    local existing = parked[spotId]
    if existing and existing.owner ~= owner then
        reply(src, requestId, { ok = false, message = Config.Messages.occupied })
        return
    end

    local moving = false
    local key = plateKey(props.plate)
    for _, entry in pairs(parked) do
        if entry.owner == owner and plateKey(entry.props.plate) == key then
            moving = true
            break
        end
    end

    local alreadyMine = existing and existing.owner == owner
    if not alreadyMine and not moving and countOwned(owner) >= Config.MaxPerPlayer then
        reply(src, requestId, { ok = false, message = Config.Messages.limit })
        return
    end

    local used = 0
    for _ in pairs(parked) do
        used = used + 1
    end
    if not alreadyMine and not moving and used >= #Config.Parking.spots then
        reply(src, requestId, { ok = false, message = Config.Messages.full })
        return
    end

    clearPlate(props.plate, spotId)
    parked[spotId] = { owner = owner, props = props }
    save()
    sync()
    reply(src, requestId, { ok = true, message = Config.Messages.parked })
end)

RegisterNetEvent('snelle-blokkenpark:retrieve', function(requestId, payload)
    local src = source
    local spotId = tonumber(payload and payload.spotId)
    local entry = spotId and parked[spotId] or nil
    local owner = identifier(src)

    if not entry then
        reply(src, requestId, { ok = false, message = Config.Messages.occupied })
        return
    end
    if entry.owner ~= owner then
        reply(src, requestId, { ok = false, message = Config.Messages.notYours })
        return
    end

    local props = entry.props
    parked[spotId] = nil
    pendingRetrieve[src] = {
        spotId = spotId,
        props = props,
        owner = owner,
        expires = os.time() + 30,
    }
    save()
    sync()
    reply(src, requestId, { ok = true, message = Config.Messages.retrieved, props = props })
end)

RegisterNetEvent('snelle-blokkenpark:restore', function(requestId)
    local src = source
    local pending = pendingRetrieve[src]
    pendingRetrieve[src] = nil

    if not pending or pending.expires < os.time() or parked[pending.spotId] then
        reply(src, requestId, { ok = false, message = Config.Messages.spawnFailed })
        return
    end

    parked[pending.spotId] = { owner = pending.owner, props = pending.props }
    save()
    sync()
    reply(src, requestId, { ok = true })
end)

RegisterNetEvent('snelle-blokkenpark:commitRetrieve', function()
    pendingRetrieve[source] = nil
end)

AddEventHandler('playerDropped', function()
    local src = source
    local pending = pendingRetrieve[src]
    pendingRetrieve[src] = nil
    if not pending or parked[pending.spotId] then
        return
    end
    parked[pending.spotId] = { owner = pending.owner, props = pending.props }
    save()
end)

RegisterCommand('blokkenpark', function(src, args)
    if src == 0 then
        print('[snelle-blokkenpark] Alleen een speler kan dit commando gebruiken.')
        return
    end
    TriggerClientEvent('snelle-blokkenpark:tp', src, args[1] == 'parking' and 'interior' or 'park')
end, true)

RegisterCommand('blokkenpos', function(src)
    if src == 0 then
        return
    end
    TriggerClientEvent('snelle-blokkenpark:printpos', src)
end, true)

load()
local restored = 0
for _ in pairs(parked) do
    restored = restored + 1
end
print(('[snelle-blokkenpark] Geladen. %d geparkeerde voertuigen bewaard.'):format(restored))
