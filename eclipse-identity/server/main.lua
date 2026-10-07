local ESX = nil
local registered = false
local lastAttempt = {}

local function ensureESX()
    if ESX then
        return ESX
    end

    if GetResourceState('es_extended') ~= 'started' then
        return nil
    end

    local ok, obj = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if ok and obj then
        ESX = obj
        return ESX
    end

    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)

    return ESX
end

local function saveToDatabase(identifier, data)
    local params = {
        data.firstname,
        data.lastname,
        data.dateofbirth,
        data.sex,
        data.height,
        identifier
    }

    if GetResourceState('oxmysql') == 'started' then
        exports.oxmysql:update(
            'UPDATE users SET firstname = ?, lastname = ?, dateofbirth = ?, sex = ?, height = ? WHERE identifier = ?',
            params
        )
        return true
    end

    if MySQL and MySQL.Async and MySQL.Async.execute then
        MySQL.Async.execute(
            'UPDATE users SET firstname = @firstname, lastname = @lastname, dateofbirth = @dateofbirth, sex = @sex, height = @height WHERE identifier = @identifier',
            {
                ['@firstname'] = data.firstname,
                ['@lastname'] = data.lastname,
                ['@dateofbirth'] = data.dateofbirth,
                ['@sex'] = data.sex,
                ['@height'] = data.height,
                ['@identifier'] = identifier
            }
        )
        return true
    end

    return false
end

local function saveIdentity(src, data)
    local esx = ensureESX()
    if not esx then
        return false, 'ESX is niet gestart.'
    end

    local xPlayer = esx.GetPlayerFromId(src)
    if not xPlayer then
        return false, 'Geen personage gevonden. Laat esx_identity aanstaan als je multichar gebruikt.'
    end

    local fullName = ('%s %s'):format(data.firstname, data.lastname)
    if xPlayer.setName then
        xPlayer.setName(fullName)
    end

    xPlayer.set('firstName', data.firstname)
    xPlayer.set('lastName', data.lastname)
    xPlayer.set('dateofbirth', data.dateofbirth)
    xPlayer.set('sex', data.sex)
    xPlayer.set('height', data.height)

    saveToDatabase(xPlayer.identifier, data)
    return true
end

local function registerCallback()
    local esx = ensureESX()
    if not esx or not esx.RegisterServerCallback or registered then
        return registered
    end

    local function onRegister(source, cb, data)
        local now = os.clock()
        if lastAttempt[source] and (now - lastAttempt[source]) < 1.5 then
            cb({ ok = false, error = 'Even geduld.' })
            return
        end
        lastAttempt[source] = now

        local valid, result = Identity.Validate(data, Config)
        if not valid then
            cb({ ok = false, error = result })
            return
        end

        local saved, saveError = saveIdentity(source, result)
        if not saved then
            cb({ ok = false, error = saveError or 'Opslaan is mislukt.' })
            return
        end

        cb({ ok = true })
    end

    local ok, err = pcall(function()
        esx.RegisterServerCallback('eclipse-identity:register', onRegister)
    end)

    if not ok then
        print(('[eclipse-identity] callback niet geregistreerd: %s'):format(err))
        return false
    end

    registered = true
    return true
end

CreateThread(function()
    while not registerCallback() do
        Wait(500)
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == 'es_extended' then
        ESX = nil
        registered = false
        registerCallback()
    end
end)

AddEventHandler('playerDropped', function()
    lastAttempt[source] = nil
end)
