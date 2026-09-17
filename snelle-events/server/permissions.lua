Permissions = {}

local Framework = nil
local FrameworkName = Config.Framework or 'esx'

local function loadESX()
    if Framework then return Framework end

    if GetResourceState('es_extended') ~= 'started' then
        return nil
    end

    Framework = exports['es_extended']:getSharedObject()
    FrameworkName = 'esx'
    return Framework
end

local function detectFramework()
    if Config.Framework == 'esx' then
        return loadESX() and 'esx' or 'standalone'
    end

    if Config.Framework == 'qbcore' and GetResourceState('qb-core') == 'started' then
        Framework = exports['qb-core']:GetCoreObject()
        FrameworkName = 'qbcore'
        return 'qbcore'
    end

    if Config.Framework == 'auto' then
        if GetResourceState('es_extended') == 'started' then
            loadESX()
            return 'esx'
        end

        if GetResourceState('qb-core') == 'started' then
            Framework = exports['qb-core']:GetCoreObject()
            FrameworkName = 'qbcore'
            return 'qbcore'
        end
    end

    FrameworkName = 'standalone'
    return 'standalone'
end

CreateThread(function()
    while not Framework and Config.Framework == 'esx' do
        loadESX()
        if Framework then break end
        Wait(500)
    end

    if Config.Framework ~= 'esx' then
        detectFramework()
    end
end)

function Permissions.GetFramework()
    if Config.Framework == 'esx' and not Framework then
        loadESX()
    end

    return FrameworkName, Framework
end

function Permissions.GetESXPlayer(source)
    local esx = loadESX()
    if not esx then return nil end
    return esx.GetPlayerFromId(source)
end

function Permissions.HasAce(source, ace)
    return IsPlayerAceAllowed(source, ace)
end

function Permissions.IsInEsxGroups(source, groups)
    local xPlayer = Permissions.GetESXPlayer(source)
    if not xPlayer then return false end

    local group = xPlayer.getGroup()
    return Utils.TableContains(groups, group)
end

function Permissions.CanManage(source)
    if Permissions.HasAce(source, Config.Permissions.aceManage) then
        return true
    end

    if Permissions.HasAce(source, Config.Permissions.aceHost) then
        return true
    end

    local fw = Permissions.GetFramework()

    if fw == 'esx' then
        if Permissions.IsInEsxGroups(source, Config.Permissions.esxGroups) then
            return true
        end

        if Permissions.IsInEsxGroups(source, Config.Permissions.esxHostGroups or {}) then
            return true
        end
    end

    if fw == 'qbcore' and Framework then
        for _, perm in ipairs(Config.Permissions.qbPermissions or {}) do
            if Framework.Functions.HasPermission(source, perm) then
                return true
            end
        end
    end

    return Config.AllowPublicHosting
end

function Permissions.GetPlayerName(source)
    local xPlayer = Permissions.GetESXPlayer(source)
    if xPlayer and xPlayer.getName then
        return xPlayer.getName()
    end

    return GetPlayerName(source) or ('Speler %s'):format(source)
end

function Permissions.GiveReward(source, amount, account)
    if not Config.Rewards.enabled or amount <= 0 then return end

    local xPlayer = Permissions.GetESXPlayer(source)
    if not xPlayer then return end

    if account == 'bank' then
        xPlayer.addAccountMoney('bank', amount)
    else
        xPlayer.addMoney(amount)
    end
end

function Permissions.SendWebhook(title, description, color)
    if Config.DiscordWebhook == '' then return end

    PerformHttpRequest(Config.DiscordWebhook, function() end, 'POST', json.encode({
        embeds = {{
            title = title,
            description = description,
            color = color or 3447003,
            footer = { text = 'Snelle Events · ESX' },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
    }), { ['Content-Type'] = 'application/json' })
end
