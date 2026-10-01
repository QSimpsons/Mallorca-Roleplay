if Config.Framework ~= 'esx' then return end

ESX = exports["es_extended"]:getSharedObject()

RegisterCallback = ESX.RegisterServerCallback
CreateUsableItem = ESX.RegisterUsableItem

function ShowNotification(src, text, notifyType)
    TriggerClientEvent('esx:showNotification', src, text)
end

function GetPlayerFromId(playerId)
    return ESX.GetPlayerFromId(playerId)
end

function GetPlayerFromIdentifier(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

function GetSource(xPlayer)
    xPlayer = type(xPlayer) == 'number' and ESX.GetPlayerFromId(xPlayer) or xPlayer
    return xPlayer.source
end

function GetIdentifier(xPlayer)
    xPlayer = type(xPlayer) == 'number' and ESX.GetPlayerFromId(xPlayer) or xPlayer
    return xPlayer.identifier
end

function GetPlayerObjects()
    return ESX.GetPlayers()
end

function IsAdmin(playerId)
    local xPlayer = GetPlayerFromId(playerId)
    return Config.AdminGroups[xPlayer.getGroup()]
end

function GetCharName(identifier)
    local xTarget = GetPlayerFromIdentifier(identifier)
    if xTarget then return xTarget.getName() end

	local result = MySQL.Sync.fetchAll('SELECT firstname, lastname FROM users where identifier = ?', {identifier})
    local name = ('%s %s'):format(result?[1]?.firstname, result?[1]?.lastname)

    return name
end

function GetJob(xPlayer)
    return xPlayer.job
end

local function resolvePlayer(xPlayer)
    if type(xPlayer) == 'number' then
        return ESX.GetPlayerFromId(xPlayer)
    end

    if type(xPlayer) ~= 'table' or xPlayer.GetPlayers or xPlayer.GetPlayerFromId then
        return nil
    end

    return xPlayer
end

function GetJobName(xPlayer)
    xPlayer = resolvePlayer(xPlayer)
    if not xPlayer then return end

    local job = xPlayer.job or (type(xPlayer.getJob) == 'function' and xPlayer.getJob())
    if type(job) == 'table' then
        return job.name
    end
end

function GetGradeId(xPlayer)
    xPlayer = resolvePlayer(xPlayer)
    if not xPlayer then return end

    local job = xPlayer.job or (type(xPlayer.getJob) == 'function' and xPlayer.getJob())
    if type(job) == 'table' then
        return job.grade
    end
end

function GetGradeLabel(xPlayer)
    xPlayer = resolvePlayer(xPlayer)
    if not xPlayer then return end

    local job = xPlayer.job or (type(xPlayer.getJob) == 'function' and xPlayer.getJob())
    if type(job) == 'table' then
        return job.grade_label
    end
end

local function bindPlayer(xPlayer)
    if type(xPlayer) ~= 'table' or xPlayer.GetJobName then return xPlayer end

    -- Escrowed files call xPlayer:GetJobName(). A missing method is exactly
    -- "attempt to call a nil value (field 'GetJobName')".
    xPlayer.GetJobName = function()
        return GetJobName(xPlayer)
    end

    xPlayer.GetGradeId = function()
        return GetGradeId(xPlayer)
    end

    xPlayer.GetGradeLabel = function()
        return GetGradeLabel(xPlayer)
    end

    return xPlayer
end

local function bindPlayerList(players)
    if type(players) ~= 'table' then return players end

    for key, value in pairs(players) do
        if type(value) == 'table' and (value.job or value.getJob or value.source or value.identifier) then
            players[key] = bindPlayer(value)
        end
    end

    return players
end

if not ESX._tkPoliceJobBound then
    ESX._tkPoliceJobBound = true

    local originalGetPlayerFromId = ESX.GetPlayerFromId
    local originalGetPlayerFromIdentifier = ESX.GetPlayerFromIdentifier
    local originalGetExtendedPlayers = ESX.GetExtendedPlayers

    if originalGetPlayerFromId then
        ESX.GetPlayerFromId = function(playerId)
            return bindPlayer(originalGetPlayerFromId(playerId))
        end
    end

    if originalGetPlayerFromIdentifier then
        ESX.GetPlayerFromIdentifier = function(identifier)
            return bindPlayer(originalGetPlayerFromIdentifier(identifier))
        end
    end

    if originalGetExtendedPlayers then
        ESX.GetExtendedPlayers = function(...)
            local players, count = originalGetExtendedPlayers(...)
            return bindPlayerList(players), count
        end
    end

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= GetCurrentResourceName() then return end

        ESX._tkPoliceJobBound = nil
        if originalGetPlayerFromId then ESX.GetPlayerFromId = originalGetPlayerFromId end
        if originalGetPlayerFromIdentifier then ESX.GetPlayerFromIdentifier = originalGetPlayerFromIdentifier end
        if originalGetExtendedPlayers then ESX.GetExtendedPlayers = originalGetExtendedPlayers end
        ESX.GetJobName = nil
    end)
end

ESX.GetJobName = function(player)
    if player == nil or player == ESX then
        return
    end

    return GetJobName(player)
end

bindPlayerList(ESX.Players)

AddEventHandler('esx:playerLoaded', function(_, xPlayer)
    bindPlayer(xPlayer)
    bindPlayerList(ESX.Players)
end)

function IsOnDuty(playerId)
    return true
end

function SetJob(xPlayer, job, grade)
    xPlayer.setJob(job, grade)
end

function GetAccountMoney(xPlayer, account)
    return xPlayer.getAccount(account).money
end

function AddAccountMoney(xPlayer, account, amount)
    xPlayer.addAccountMoney(account, amount)
end

function RemoveAccountMoney(xPlayer, account, amount)
    xPlayer.removeAccountMoney(account, amount)
end

local function IsWeapon(item)
    return item and string.upper(string.sub(item, 0, 7)) == 'WEAPON_'
end

function GetItemAmount(xPlayer, item)
    if Config.Inventory == 'default' and IsWeapon(item) then
        local has = xPlayer.getWeapon(item)
        return has and 1 or 0
    end

    local xItem = xPlayer.getInventoryItem(item)
    return xItem?.count or xItem?.amount or 0
end

function CanCarryItem(xPlayer, item, amount)
    if Config.Inventory == 'ox' then
        return exports.ox_inventory:CanCarryItem(GetSource(xPlayer), item, amount)
    end

    if Config.Inventory == 'default' and IsWeapon(item) then
        local weapon = xPlayer.getWeapon(item)
        return not weapon
    end

    return xPlayer.canCarryItem(item, amount)
end

function AddItem(xPlayer, item, amount, metadata)
    if not CanCarryItem(xPlayer, item, amount) then return end

    if Config.Inventory == 'ox' then
        exports.ox_inventory:AddItem(GetSource(xPlayer), item, amount, metadata)
        return true
    end

    if Config.Inventory == 'qs' then
        exports['qs-inventory']:AddItem(GetSource(xPlayer), item, amount, nil, metadata)
        return true
    end

    if Config.Inventory == 'default' and IsWeapon(item) then
        xPlayer.addWeapon(item, amount)
        return true
    end

    xPlayer.addInventoryItem(item, amount)
    return true
end

function RemoveItem(xPlayer, item, amount)
    if Config.Inventory == 'default' and IsWeapon(item) then
        xPlayer.removeWeapon(item, amount)
        return
    end

    xPlayer.removeInventoryItem(item, amount)
end

function GetItemLabel(item)
    if Config.Inventory == 'ox' then
        return exports.ox_inventory:Items(item)?.label or item
    end

    if Config.Inventory == 'default' and IsWeapon(item) then
        return ESX.GetWeaponLabel(item) or item
    end

    return ESX.GetItemLabel(item) or item
end

RegisterCallback('tk_policejob:getItemLabel', function(src, cb, item)
	cb(GetItemLabel(item))
end)

CreateThread(function()
    repeat Wait(100) until ESX

    frameworkLoaded = true
end)