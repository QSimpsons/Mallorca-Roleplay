local cooldowns = {}
local pending = {}

local function isAllowedJob(xPlayer)
    if not xPlayer or not xPlayer.job then
        return false
    end

    for _, job in ipairs(Config.AllowedJobs) do
        if xPlayer.job.name == job then
            return true
        end
    end

    return false
end

local function reviveWithAmbulance(src)
    if GetResourceState('tk_ambulancejob') ~= 'started' then
        return false
    end

    local revived = pcall(function()
        exports.tk_ambulancejob:revive(src, true)
    end)

    if revived then
        return true
    end

    return pcall(function()
        exports.tk_ambulancejob:setDeathState(src, 0)
    end)
end

lib.callback.register('prp-newlife:args', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not isAllowedJob(xPlayer) then
        return { allowed = false, reason = 'Geen toegang tot dit command!' }
    end

    local lastUsed = cooldowns[source] or 0
    local now = os.time()
    local cooldownTime = Config.cooldown

    if (now - lastUsed) < cooldownTime then
        local remaining = cooldownTime - (now - lastUsed)
        return { allowed = false, reason = 'Wacht nog ' .. remaining .. ' seconden.' }
    end

    cooldowns[source] = now
    return { allowed = true }
end)

RegisterNetEvent('prp-newlife:spawn', function(locationKey)
    local src = source
    local data = Config.NewLifeSpawns[locationKey]

    if not data then
        DropPlayer(src, "resource exploited")
        return
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not isAllowedJob(xPlayer) then
        return
    end

    pending[src] = {
        key = locationKey,
        readyAt = os.time() + math.floor(Config.TeleportDelay * 60)
    }

    TriggerClientEvent('prp-newlife:client:teleport', src, data.coords)
end)

RegisterNetEvent('prp-newlife:complete', function()
    local src = source
    local session = pending[src]

    if not session then
        return
    end

    if os.time() + 1 < session.readyAt then
        return
    end

    local data = Config.NewLifeSpawns[session.key]
    pending[src] = nil

    if not data then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not isAllowedJob(xPlayer) then
        return
    end

    reviveWithAmbulance(src)
    TriggerClientEvent('prp-newlife:client:arrive', src, data.coords)
end)

AddEventHandler('playerDropped', function()
    local src = source
    cooldowns[src] = nil
    pending[src] = nil
end)
