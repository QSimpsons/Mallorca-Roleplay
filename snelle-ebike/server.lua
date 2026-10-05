local framework = 'standalone'
local ESX, QBCore
local playerBikes = {}
local cooldowns = {}

local function detectFramework()
    local mode = Config.Framework
    if mode == 'esx' or (mode == 'auto' and GetResourceState('es_extended') == 'started') then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and obj then
            ESX = obj
            framework = 'esx'
            return
        end
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
            framework = 'esx'
        end)
        return
    end
    if mode == 'qb' or (mode == 'auto' and (GetResourceState('qb-core') == 'started' or GetResourceState('qbx_core') == 'started')) then
        local ok, obj = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and obj then
            QBCore = obj
            framework = 'qb'
            return
        end
    end
    framework = 'standalone'
end

local function notify(src, message, kind)
    TriggerClientEvent('snelle-ebike:client:notify', src, message, kind or 'info')
end

local function onCooldown(src)
    local now = os.time()
    local last = cooldowns[src] or 0
    if now - last < (Config.Cooldown or 0) then
        notify(src, Config.Messages.cooldown, 'error')
        return true
    end
    cooldowns[src] = now
    return false
end

local function getIdentifier(src)
    for _, id in ipairs(GetPlayerIdentifiers(src)) do
        if id:sub(1, 8) == 'license:' then
            return id
        end
    end
    return ('src:%s'):format(src)
end

local function hasItem(src)
    if not Config.UseItem then
        return true
    end

    local item = Config.ItemName or 'ebike'

    if framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then
            return false
        end
        local inv = xPlayer.getInventoryItem(item)
        return inv and inv.count and inv.count > 0
    end

    if framework == 'qb' and QBCore then
        local player = QBCore.Functions.GetPlayer(src)
        if not player then
            return false
        end
        local inv = player.Functions.GetItemByName(item)
        return inv and inv.amount and inv.amount > 0
    end

    -- Standalone met UseItem: geen echte inventory, altijd toestaan
    return true
end

local function removeItem(src)
    if not Config.UseItem or not Config.ConsumeItem then
        return true
    end

    local item = Config.ItemName or 'ebike'

    if framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then
            return false
        end
        local inv = xPlayer.getInventoryItem(item)
        if not inv or not inv.count or inv.count < 1 then
            return false
        end
        xPlayer.removeInventoryItem(item, 1)
        return true
    end

    if framework == 'qb' and QBCore then
        local player = QBCore.Functions.GetPlayer(src)
        if not player then
            return false
        end
        local inv = player.Functions.GetItemByName(item)
        if not inv or not inv.amount or inv.amount < 1 then
            return false
        end
        player.Functions.RemoveItem(item, 1)
        if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item] then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove')
        end
        return true
    end

    return true
end

local function giveItem(src)
    if not Config.UseItem or not Config.ConsumeItem then
        return
    end

    local item = Config.ItemName or 'ebike'

    if framework == 'esx' and ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addInventoryItem(item, 1)
        end
        return
    end

    if framework == 'qb' and QBCore then
        local player = QBCore.Functions.GetPlayer(src)
        if player then
            player.Functions.AddItem(item, 1)
            if QBCore.Shared and QBCore.Shared.Items and QBCore.Shared.Items[item] then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add')
            end
        end
    end
end

local function registerUsableItems()
    if not Config.UseItem then
        return
    end

    local item = Config.ItemName or 'ebike'

    if framework == 'esx' and ESX and ESX.RegisterUsableItem then
        ESX.RegisterUsableItem(item, function(source)
            TriggerClientEvent('snelle-ebike:client:useItem', source)
        end)
    end

    if framework == 'qb' and QBCore and QBCore.Functions and QBCore.Functions.CreateUseableItem then
        QBCore.Functions.CreateUseableItem(item, function(source)
            TriggerClientEvent('snelle-ebike:client:useItem', source)
        end)
    end
end

RegisterNetEvent('snelle-ebike:server:trySpawn', function()
    local src = source
    if onCooldown(src) then
        return
    end
    if playerBikes[src] then
        notify(src, Config.Messages.alreadyOut, 'error')
        return
    end
    if not hasItem(src) then
        notify(src, Config.Messages.noItem, 'error')
        return
    end
    if not removeItem(src) then
        notify(src, Config.Messages.noItem, 'error')
        return
    end
    TriggerClientEvent('snelle-ebike:client:spawnAllowed', src)
end)

RegisterNetEvent('snelle-ebike:server:spawned', function(netId)
    local src = source
    if type(netId) ~= 'number' then
        return
    end
    playerBikes[src] = {
        netId = netId,
        identifier = getIdentifier(src),
    }
end)

RegisterNetEvent('snelle-ebike:server:spawnFailed', function()
    local src = source
    -- Item teruggeven als spawn mislukte nadat het item al was afgenomen.
    if not playerBikes[src] then
        giveItem(src)
    end
end)

RegisterNetEvent('snelle-ebike:server:stored', function()
    local src = source
    if playerBikes[src] then
        playerBikes[src] = nil
        giveItem(src)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    playerBikes[src] = nil
    cooldowns[src] = nil
end)

CreateThread(function()
    detectFramework()
    Wait(1000)
    detectFramework()
    registerUsableItems()
end)

exports('hasBikeOut', function(src)
    return playerBikes[src] ~= nil
end)
