local forwardNames = { 'Notify', 'sendNotify', 'SendNotify', 'Show', 'show' }

local function descriptionOf(payload)
    local description = payload.description

    if type(description) ~= 'string' or description == '' then
        description = payload.title
    end

    if type(description) ~= 'string' or description == '' then
        return 'Melding'
    end

    return description
end

local function tryExisting(...)
    if GetResourceState('vx_notify') ~= 'started' then
        return false
    end

    local packed = table.pack(...)

    for i = 1, #forwardNames do
        local name = forwardNames[i]
        local ok = pcall(function()
            exports['vx_notify'][name](nil, table.unpack(packed, 1, packed.n))
        end)

        if ok then
            return true
        end
    end

    return false
end

local function showOx(payload)
    if GetResourceState('ox_lib') ~= 'started' then
        return false
    end

    local data = {
        title = payload.title,
        description = descriptionOf(payload),
        type = payload.type or 'inform',
        duration = payload.duration,
    }

    if data.title == data.description then
        data.title = nil
    end

    local ok = pcall(function()
        exports.ox_lib:notify(data)
    end)

    return ok
end

local esx

local function getESX()
    if esx then
        return esx
    end

    if GetResourceState('es_extended') ~= 'started' then
        return nil
    end

    local ok, obj = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if ok and type(obj) == 'table' then
        esx = obj
    end

    return esx
end

local function showEsx(payload)
    if GetResourceState('es_extended') ~= 'started' then
        return false
    end

    local text = descriptionOf(payload)
    local obj = getESX()

    if obj and type(obj.ShowNotification) == 'function' then
        local ok = pcall(function()
            obj.ShowNotification(text)
        end)

        if ok then
            return true
        end
    end

    TriggerEvent('esx:showNotification', text)
    return true
end

local function showNative(payload)
    local text = descriptionOf(payload)

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandThefeedPostTicker(false, false)
end

local function show(payload)
    if showOx(payload) then
        return
    end

    if showEsx(payload) then
        return
    end

    showNative(payload)
end

local function deliver(...)
    if tryExisting(...) then
        return
    end

    show(NotifyBridge.normalize(...))
end

NotifyBridge.bind(AddEventHandler, deliver)

RegisterNetEvent('vx_notify_bridge:notify', function(payload)
    if type(payload) ~= 'table' then
        payload = NotifyBridge.normalize(payload)
    end

    local ok, err = pcall(show, payload)

    if not ok then
        print(('^1[vx_notify_bridge]^7 notify mislukt: %s'):format(tostring(err)))
    end
end)

print('^2[vx_notify_bridge]^7 Export vx_notify:notify is beschikbaar.')
