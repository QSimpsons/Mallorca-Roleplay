local dynamicDoeken = {}
local dataFile = 'data/doeken.json'

local function filePath()
    return GetResourcePath(GetCurrentResourceName()) .. '/' .. dataFile
end

local function loadSaved()
    dynamicDoeken = {}

    if not Config.OpslaanDynamisch then
        return
    end

    local raw = LoadResourceFile(GetCurrentResourceName(), dataFile)
    if not raw or raw == '' then
        return
    end

    local ok, data = pcall(json.decode, raw)
    if ok and type(data) == 'table' then
        dynamicDoeken = data
    end
end

local function saveSaved()
    if not Config.OpslaanDynamisch then
        return
    end

    SaveResourceFile(GetCurrentResourceName(), dataFile, json.encode(dynamicDoeken), -1)
end

local function hasAce(src)
    return IsPlayerAceAllowed(src, Config.AcePermission)
end

local function hasEsxGroup(src)
    if not Config.EsxGroups or #Config.EsxGroups == 0 then
        return false
    end

    local esx = nil
    if GetResourceState('es_extended') == 'started' then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok then
            esx = obj
        end
    end

    if not esx then
        return false
    end

    local xPlayer = esx.GetPlayerFromId(src)
    if not xPlayer then
        return false
    end

    local group = nil
    if xPlayer.getGroup then
        group = xPlayer.getGroup()
    elseif xPlayer.group then
        group = xPlayer.group
    end

    if not group then
        return false
    end

    for i = 1, #Config.EsxGroups do
        if Config.EsxGroups[i] == group then
            return true
        end
    end

    return false
end

local function canManage(src)
    if src == 0 then
        return true
    end
    return hasAce(src) or hasEsxGroup(src)
end

local function notify(src, msg)
    TriggerClientEvent('fotodoek:notify', src, msg)
end

local function newId()
    return ('d%d'):format(math.floor(os.time() * 1000) + math.random(10, 99))
end

RegisterNetEvent('fotodoek:requestSync', function()
    local src = source
    TriggerClientEvent('fotodoek:sync', src, dynamicDoeken)
end)

RegisterNetEvent('fotodoek:place', function(payload)
    local src = source
    if not canManage(src) then
        notify(src, 'Je hebt geen toestemming om een doek te plaatsen.')
        return
    end

    if type(payload) ~= 'table' then
        return
    end

    local entry = {
        id = newId(),
        label = tostring(payload.label or 'Fotodoek'):sub(1, 48),
        x = tonumber(payload.x) or 0.0,
        y = tonumber(payload.y) or 0.0,
        z = tonumber(payload.z) or 0.0,
        heading = tonumber(payload.heading) or 0.0,
        breedte = tonumber(payload.breedte) or Config.Breedte,
        hoogte = tonumber(payload.hoogte) or Config.Hoogte
    }

    dynamicDoeken[#dynamicDoeken + 1] = entry
    saveSaved()

    TriggerClientEvent('fotodoek:add', -1, entry)
    notify(src, ('Fotodoek geplaatst (%s).'):format(entry.label))
    print(('[fotodoek] %s plaatste doek %s @ %.2f %.2f %.2f'):format(
        GetPlayerName(src) or src, entry.id, entry.x, entry.y, entry.z
    ))
end)

RegisterNetEvent('fotodoek:delete', function(id)
    local src = source
    if not canManage(src) then
        notify(src, 'Je hebt geen toestemming om een doek te verwijderen.')
        return
    end

    id = tostring(id or '')
    local removed = false

    for i = #dynamicDoeken, 1, -1 do
        if dynamicDoeken[i].id == id then
            table.remove(dynamicDoeken, i)
            removed = true
            break
        end
    end

    if not removed then
        notify(src, 'Doek niet gevonden.')
        return
    end

    saveSaved()
    TriggerClientEvent('fotodoek:remove', -1, id)
    notify(src, 'Fotodoek verwijderd.')
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    loadSaved()
    print(('[fotodoek] Geladen: %s dynamische doek(en).'):format(#dynamicDoeken))
end)

-- Export voor andere resources (bijv. event-script)
exports('PlaceDoek', function(coords, heading, label)
    local entry = {
        id = newId(),
        label = label or 'Fotodoek',
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = heading or 0.0,
        breedte = Config.Breedte,
        hoogte = Config.Hoogte
    }
    dynamicDoeken[#dynamicDoeken + 1] = entry
    saveSaved()
    TriggerClientEvent('fotodoek:add', -1, entry)
    return entry.id
end)

exports('RemoveDoek', function(id)
    id = tostring(id)
    for i = #dynamicDoeken, 1, -1 do
        if dynamicDoeken[i].id == id then
            table.remove(dynamicDoeken, i)
            saveSaved()
            TriggerClientEvent('fotodoek:remove', -1, id)
            return true
        end
    end
    return false
end)
