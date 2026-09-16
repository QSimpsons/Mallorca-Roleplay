Permissions = {}

local Framework = nil
local FrameworkName = 'standalone'

local function detectFramework()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end

    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end

    if GetResourceState('qb-core') == 'started' then
        return 'qbcore'
    end

    return 'standalone'
end

CreateThread(function()
    FrameworkName = detectFramework()

    if FrameworkName == 'esx' then
        Framework = exports['es_extended']:getSharedObject()
    elseif FrameworkName == 'qbcore' then
        Framework = exports['qb-core']:GetCoreObject()
    end
end)

function Permissions.GetFramework()
    return FrameworkName, Framework
end

function Permissions.HasAce(source, ace)
    return IsPlayerAceAllowed(source, ace)
end

function Permissions.CanManage(source)
    if Permissions.HasAce(source, Config.Permissions.aceManage) then
        return true
    end

    if Permissions.HasAce(source, Config.Permissions.aceHost) then
        return true
    end

    local fw, obj = Permissions.GetFramework()

    if fw == 'esx' and obj then
        local xPlayer = obj.GetPlayerFromId(source)
        if xPlayer then
            local group = xPlayer.getGroup()
            return Utils.TableContains(Config.Permissions.esxGroups, group)
        end
    end

    if fw == 'qbcore' and obj then
        for _, perm in ipairs(Config.Permissions.qbPermissions) do
            if obj.Functions.HasPermission(source, perm) then
                return true
            end
        end
    end

    return Config.AllowPublicHosting
end

function Permissions.GetPlayerName(source)
    return GetPlayerName(source) or ('Speler %s'):format(source)
end

function Permissions.GiveReward(source, amount, account)
    if not Config.Rewards.enabled or amount <= 0 then return end

    local fw, obj = Permissions.GetFramework()

    if fw == 'esx' and obj then
        local xPlayer = obj.GetPlayerFromId(source)
        if xPlayer then
            if account == 'bank' then
                xPlayer.addAccountMoney('bank', amount)
            else
                xPlayer.addMoney(amount)
            end
        end
    elseif fw == 'qbcore' and obj then
        local player = obj.Functions.GetPlayer(source)
        if player then
            if account == 'bank' then
                player.Functions.AddMoney('bank', amount)
            else
                player.Functions.AddMoney('cash', amount)
            end
        end
    end
end

function Permissions.SendWebhook(title, description, color)
    if Config.DiscordWebhook == '' then return end

    PerformHttpRequest(Config.DiscordWebhook, function() end, 'POST', json.encode({
        embeds = {{
            title = title,
            description = description,
            color = color or 3447003,
            footer = { text = 'Snelle Events' },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
    }), { ['Content-Type'] = 'application/json' })
end
