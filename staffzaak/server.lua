local duty = {}
local lastToggle = {}
local allowedGroups = {}
local allowedJobs = {}

for i = 1, #(Config.AllowedGroups or {}) do
    local name = Config.AllowedGroups[i]
    if type(name) == 'string' then
        allowedGroups[name:lower()] = true
    end
end

for i = 1, #(Config.AllowedJobs or {}) do
    local name = Config.AllowedJobs[i]
    if type(name) == 'string' then
        allowedJobs[name:lower()] = true
    end
end

local function sanitize(text)
    text = tostring(text or 'onbekend')
    text = text:gsub('[%c@`*_~<>|%%]', '')
    text = text:gsub('%s+', ' ')
    text = text:gsub('^%s+', ''):gsub('%s+$', '')
    if text == '' then
        text = 'onbekend'
    end
    return text:sub(1, 48)
end

local function message(key, fallback)
    local messages = Config.Messages
    local value = messages and messages[key]
    if type(value) == 'string' and value ~= '' then
        return value
    end
    return fallback
end

local function formatMessage(template, ...)
    local ok, formatted = pcall(string.format, template, ...)
    if ok then
        return formatted
    end
    return template
end

local function notify(target, messageText, kind)
    if not target or target <= 0 or type(messageText) ~= 'string' then return end
    TriggerClientEvent('staffzaak:notify', target, messageText, kind or 'info')
end

local function publish()
    local map = {}
    for src, on in pairs(duty) do
        if on then
            map[tostring(src)] = true
        end
    end
    GlobalState.staffzaakOnDuty = map
end

local function identifierByPrefix(source, prefix)
    local identifiers = GetPlayerIdentifiers(source)
    for i = 1, #identifiers do
        local identifier = identifiers[i]
        if identifier:sub(1, #prefix) == prefix then
            return identifier
        end
    end
    return 'onbekend'
end

local function hasAce(source)
    local aces = Config.AllowedAces or {}
    for i = 1, #aces do
        local ace = aces[i]
        if type(ace) == 'string' and ace ~= '' and IsPlayerAceAllowed(source, ace) then
            return true
        end
    end
    return false
end

-- QBCore en Qbox zetten staff vaak op een ace zoals admin, group.admin of qbcore.admin.
local function hasGroupAce(source)
    local groups = Config.AllowedGroups or {}
    for i = 1, #groups do
        local group = groups[i]
        if type(group) == 'string' and group ~= '' then
            if IsPlayerAceAllowed(source, group)
                or IsPlayerAceAllowed(source, 'group.' .. group)
                or IsPlayerAceAllowed(source, 'qbcore.' .. group) then
                return true
            end
        end
    end
    return false
end

local function hasLicense(source)
    local allowed = ServerConfig and ServerConfig.AllowedLicenses
    if type(allowed) ~= 'table' or #allowed == 0 then
        return false
    end

    local mine = {}
    local identifiers = GetPlayerIdentifiers(source)
    for i = 1, #identifiers do
        mine[identifiers[i]] = true
    end

    for i = 1, #allowed do
        local license = allowed[i]
        if type(license) == 'string' and mine[license] then
            return true
        end
    end

    return false
end

local function groupAllowed(group)
    return type(group) == 'string' and allowedGroups[group:lower()] == true
end

local function jobAllowed(job)
    return type(job) == 'string' and allowedJobs[job:lower()] == true
end

local function hasEsxPermission(source)
    if GetResourceState('es_extended') ~= 'started' then
        return false
    end

    local ok, esx = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)
    if not ok or not esx or not esx.GetPlayerFromId then
        return false
    end

    local xPlayer = esx.GetPlayerFromId(source)
    if not xPlayer then
        return false
    end

    local group = xPlayer.group
    if xPlayer.getGroup then
        local success, value = pcall(function()
            return xPlayer.getGroup()
        end)
        if success and value then
            group = value
        end
    end

    if groupAllowed(group) then
        return true
    end

    local job = xPlayer.job and xPlayer.job.name
    return jobAllowed(job)
end

local function hasQbPermission(source, resource)
    if GetResourceState(resource) ~= 'started' then
        return false
    end

    local ok, core = pcall(function()
        return exports[resource]:GetCoreObject()
    end)
    if not ok or type(core) ~= 'table' or not core.Functions then
        return false
    end

    if core.Functions.HasPermission then
        for i = 1, #(Config.AllowedGroups or {}) do
            local group = Config.AllowedGroups[i]
            local success, allowed = pcall(function()
                return core.Functions.HasPermission(source, group)
            end)
            if success and allowed then
                return true
            end
        end
    end

    if not core.Functions.GetPlayer then
        return false
    end

    local success, player = pcall(function()
        return core.Functions.GetPlayer(source)
    end)
    if not success or not player or not player.PlayerData then
        return false
    end

    local data = player.PlayerData
    if groupAllowed(data.group) or groupAllowed(data.permission) then
        return true
    end

    local job = data.job and data.job.name
    return jobAllowed(job)
end

local function isAllowed(source)
    if Config.RequirePermission == false then
        return true
    end
    if hasAce(source) or hasGroupAce(source) or hasLicense(source) then
        return true
    end
    if hasEsxPermission(source) then
        return true
    end
    if hasQbPermission(source, 'qb-core') or hasQbPermission(source, 'qbx_core') then
        return true
    end
    return false
end

local function notifyOnDuty(message, except)
    for src, on in pairs(duty) do
        if on and src ~= except then
            notify(src, message, 'info')
        end
    end
end

local function announce(name, onDuty, except)
    local mode = 'staff'
    if type(Config.AnnounceTo) == 'string' then
        mode = Config.AnnounceTo:lower():gsub('%s+', '')
    end
    if mode == 'none' or mode == 'niemand' then return end

    local template = onDuty and message('staffJoined', '%s is in staffdienst gegaan.') or message('staffLeft', '%s is uit staffdienst gegaan.')
    local messageText = formatMessage(template, name)

    if mode == 'everyone' or mode == 'all' or mode == 'iedereen' then
        local players = GetPlayers()
        for i = 1, #players do
            local target = tonumber(players[i])
            if target and target ~= except then
                notify(target, messageText, 'info')
            end
        end
        return
    end

    notifyOnDuty(messageText, except)
end

local function writeLog(source, name, onDuty, reason)
    local action = onDuty and 'in' or 'uit'
    local extra = reason and (' (' .. reason .. ')') or ''
    print(('[staffzaak] %s (ID %s) is %s staffdienst gegaan%s.'):format(name, source, action, extra))

    local webhook = ServerConfig and ServerConfig.Webhook
    if type(webhook) ~= 'string' or not webhook:find('^https://') then
        return
    end

    local description = ('**%s** (ID %s) is %s staffdienst gegaan%s.'):format(name, source, action, extra)
    local payload = json.encode({
        username = 'Staffdienst',
        embeds = {
            {
                title = onDuty and 'In staffdienst' or 'Uit staffdienst',
                color = onDuty and 5763719 or 15548997,
                description = description,
                fields = {
                    { name = 'License', value = identifierByPrefix(source, 'license:'), inline = false },
                    { name = 'Discord', value = identifierByPrefix(source, 'discord:'), inline = false },
                },
                footer = { text = 'staffzaak' },
                timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            },
        },
    })

    PerformHttpRequest(webhook, function(status)
        if status ~= 200 and status ~= 204 then
            print(('[staffzaak] Discord-log mislukt (status %s).'):format(tostring(status)))
        end
    end, 'POST', payload, { ['Content-Type'] = 'application/json' })
end

local function setDuty(source, shouldBeOn)
    if source == 0 then
        print('[staffzaak] Dit commando werkt alleen in-game.')
        return false
    end

    if not GetPlayerName(source) then
        return false
    end

    if not isAllowed(source) then
        notify(source, message('noPermission', 'Je hebt geen toestemming om in staffdienst te gaan.'), 'error')
        return false
    end

    shouldBeOn = shouldBeOn == true
    local isOn = duty[source] == true
    if isOn == shouldBeOn then
        notify(source, shouldBeOn and message('alreadyOn', 'Je bent al in staffdienst.') or message('alreadyOff', 'Je bent niet in staffdienst.'), 'info')
        return isOn
    end

    local now = os.time()
    local previous = lastToggle[source]
    local cooldown = tonumber(Config.Cooldown) or 0
    if previous and cooldown > 0 and (now - previous) < cooldown then
        notify(source, message('cooldown', 'Wacht even voordat je staffdienst opnieuw wisselt.'), 'error')
        return isOn
    end

    local name = sanitize(GetPlayerName(source))
    lastToggle[source] = now
    announce(name, shouldBeOn, source)

    if shouldBeOn then
        duty[source] = true
    else
        duty[source] = nil
    end

    publish()
    notify(source, shouldBeOn and message('onDuty', 'Je bent nu in staffdienst.') or message('offDuty', 'Je bent uit staffdienst gegaan.'), shouldBeOn and 'success' or 'info')
    writeLog(source, name, shouldBeOn)
    return shouldBeOn
end

local function toggleDuty(source)
    setDuty(source, duty[source] ~= true)
end

RegisterCommand(Config.Command, function(source)
    toggleDuty(source)
end, false)

AddEventHandler('playerDropped', function()
    local src = source
    if duty[src] then
        local name = sanitize(GetPlayerName(src))
        duty[src] = nil
        publish()
        announce(name, false, src)
        local ok, err = pcall(writeLog, src, name, false, 'disconnect')
        if not ok then
            print(('[staffzaak] Log bij disconnect mislukt: %s'):format(tostring(err)))
        end
    end
    lastToggle[src] = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    duty = {}
    lastToggle = {}
    publish()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    GlobalState.staffzaakOnDuty = {}
end)

exports('isOnDuty', function(playerId)
    return duty[playerId] == true
end)

exports('getOnDuty', function()
    local list = {}
    for src, on in pairs(duty) do
        if on then
            list[#list + 1] = src
        end
    end
    return list
end)

