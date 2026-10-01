local Config = require 'shared.config'

-- [source] = { id, name, rank, rankColor, avatarUrl, startTime (Unix ms), status }
local dutyStaff = {}

-- ======== Permissies: ESX group (indien aanwezig) met ACE-fallback ========
-- Zo blijft dit consistent met ox_adminmenu, dat ook eerst ESX-groepen
-- checkt en anders op eigen setgroup/ACE terugvalt.
local ESX = nil

local function tryLoadESX()
    if ESX ~= nil then return ESX end

    local ok, obj = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if ok and obj then
        ESX = obj
        return ESX
    end

    ESX = false
    return nil
end

-- Geeft de groep van de speler terug als lowercase string, of nil.
local function getPlayerGroup(src)
    local esx = tryLoadESX()
    if esx then
        local xPlayer = esx.GetPlayerFromId(src)
        if xPlayer then
            local group = xPlayer.getGroup and xPlayer.getGroup() or nil
            if group then return tostring(group):lower() end
        end
    end
    return nil
end

local function tableContainsCI(list, value)
    if not value then return false end
    value = tostring(value):lower()
    for _, v in ipairs(list) do
        if tostring(v):lower() == value then return true end
    end
    return false
end

-- Mag deze speler /sd, /staffdienst of /staffduty gebruiken?
local function hasStaffPerm(src)
    local group = getPlayerGroup(src)
    if group then
        return tableContainsCI(Config.AllowedGroups, group)
    end

    -- Geen ESX gevonden: val terug op ACE-principals ("group.<naam>").
    for _, allowed in ipairs(Config.AllowedGroups) do
        if IsPlayerAceAllowed(src, 'group.' .. allowed) then
            return true
        end
    end
    return false
end

local function getPlayerRank(src)
    local group = getPlayerGroup(src)
    if group then
        for _, entry in ipairs(Config.RankLabels) do
            if tostring(entry.group):lower() == group then
                return entry.label
            end
        end
        return Config.DefaultRank
    end

    for _, entry in ipairs(Config.RankLabels) do
        if IsPlayerAceAllowed(src, 'group.' .. entry.group) then
            return entry.label
        end
    end
    return Config.DefaultRank
end

local function rgbCss(rgb)
    return string.format('rgb(%d, %d, %d)', rgb[1], rgb[2], rgb[3])
end

-- ======== Discord rollen (rang + avatar in de tag) ========
local function getIdentifierByPrefix(src, prefix)
    local num = GetNumPlayerIdentifiers(src)
    for i = 0, num - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id and id:sub(1, #prefix) == prefix then
            return id:sub(#prefix + 1)
        end
    end
    return nil
end

local function buildAvatarUrl(discordUserId, avatarHash)
    if avatarHash and avatarHash ~= '' then
        local ext = (avatarHash:sub(1, 2) == 'a_') and '.gif' or '.png'
        return 'https://cdn.discordapp.com/avatars/' .. discordUserId .. '/' .. avatarHash .. ext
    end
    return Config.Tag.defaultAvatar
end

-- Zoekt de rol met de hoogste priority uit Config.Ranks die de speler heeft.
local function resolveRankFromRoles(roleIds)
    local bestName, bestColor, bestPriority = nil, nil, -1
    if type(roleIds) == 'table' then
        for _, roleId in ipairs(roleIds) do
            local data = Config.Ranks[tostring(roleId)]
            if data and (data.priority or 0) > bestPriority then
                bestName = data.name
                bestColor = data.color
                bestPriority = data.priority or 0
            end
        end
    end
    return bestName, bestColor
end

-- Vraagt de guild member gegevens van een speler op bij de Discord API.
-- Vereist dat de bot in de guild zit en het Server Members Intent aan staat.
local function fetchDiscordMember(discordUserId, cb)
    if not discordUserId then return cb(nil) end

    PerformHttpRequest(
        ('https://discord.com/api/v10/guilds/%s/members/%s'):format(Config.Discord.guildId, discordUserId),
        function(errCode, resultData)
            if errCode ~= 200 or not resultData then
                return cb(nil)
            end

            local ok, decoded = pcall(json.decode, resultData)
            if not ok or type(decoded) ~= 'table' then
                return cb(nil)
            end

            cb(decoded)
        end,
        'GET', '',
        {
            ['Authorization'] = 'Bot ' .. Config.Discord.botToken,
            ['Content-Type'] = 'application/json',
        }
    )
end

-- Bouwt rank/kleur/avatar voor de tag: met Discord-data indien enabled,
-- anders (of als er geen discord: identifier of API-respons is) een
-- fallback op basis van de ESX-groep + Config.Tag.rankColors.
local function refreshStaffMeta(src, cb)
    local fallbackRank = getPlayerRank(src)
    local fallbackRankColorRgb = (Config.Tag.rankColors and Config.Tag.rankColors[fallbackRank]) or Config.Tag.defaultRankColor
    local fallback = {
        rank      = fallbackRank,
        rankColor = rgbCss(fallbackRankColorRgb),
        avatarUrl = Config.Tag.defaultAvatar,
    }

    if not (Config.Discord and Config.Discord.enabled) then
        return cb(fallback)
    end

    local discordUserId = getIdentifierByPrefix(src, 'discord:')
    if not discordUserId then
        return cb(fallback)
    end

    fetchDiscordMember(discordUserId, function(member)
        if not member then
            return cb(fallback)
        end

        local rankName, rankColor = resolveRankFromRoles(member.roles)
        local user = member.user or {}

        cb({
            rank      = rankName or fallback.rank,
            rankColor = rankColor or fallback.rankColor,
            avatarUrl = user.id and buildAvatarUrl(user.id, user.avatar) or fallback.avatarUrl,
        })
    end)
end

-- ======== Staff-tag instellingen (NUI) ========
-- Elke speler kan zijn eigen tag-weergave aanpassen via /staffsettings.
-- userSettingsStore blijft bewaard op license (overleeft reconnects, niet restarts).
-- tagVisualsStore houdt de laatst bekende instellingen per huidige source bij,
-- zodat andere clients meteen weten hoe ze iemands tag moeten tekenen.
local userSettingsStore = {}
local tagVisualsStore = {}

local function getLicense(src)
    local num = GetNumPlayerIdentifiers(src)
    for i = 0, num - 1 do
        local id = GetPlayerIdentifier(src, i)
        if id and id:sub(1, 8) == 'license:' then
            return id:sub(9)
        end
    end
    return nil
end

if lib and lib.callback then
    lib.callback.register('lm-staffduty:server:getUserSettings', function(source)
        local license = getLicense(source)
        return (license and userSettingsStore[license]) or Config.Tag.defaultSettings
    end)

    lib.callback.register('lm-staffduty:server:getAllTagVisuals', function(source)
        return tagVisualsStore
    end)
end

RegisterNetEvent('lm-staffduty:server:saveSettings', function(settings)
    local src = source
    if type(settings) ~= 'table' then return end

    local license = getLicense(src)
    if license then
        userSettingsStore[license] = settings
    end

    tagVisualsStore[src] = settings
    TriggerClientEvent('lm-staffduty:client:syncTagVisuals', -1, src, settings)
end)

RegisterNetEvent('lm-staffduty:server:openSettings', function()
    local src = source
    if not hasStaffPerm(src) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = locale('no_access'),
            type = 'error',
        })
        return
    end

    refreshStaffMeta(src, function(meta)
        TriggerClientEvent('lm-staffduty:client:openSettingsMenu', src, {
            name      = GetPlayerName(src),
            rank      = meta.rank,
            rankColor = meta.rankColor,
            avatarUrl = meta.avatarUrl,
        })
    end)
end)

local function buildStaffList()
    local list = {}
    local now = os.time() * 1000
    for src, data in pairs(dutyStaff) do
        if GetPlayerName(src) then
            table.insert(list, {
                id          = src,
                name        = data.name,
                rank        = data.rank,
                rankColor   = data.rankColor,
                avatarUrl   = data.avatarUrl,
                dutySeconds = math.floor((now - data.startTime) / 1000),
                status      = data.status,
            })
        else
            dutyStaff[src] = nil
        end
    end
    return list
end

AddEventHandler('playerDropped', function()
    local src = source
    if dutyStaff[src] then
        dutyStaff[src] = nil
    end
    if tagVisualsStore[src] then
        tagVisualsStore[src] = nil
    end
end)

lib.addCommand(Config.Command, {
    help = locale('command_help'),
}, function(source)
    if not hasStaffPerm(source) then
        TriggerClientEvent('ox_lib:notify', source, {
            title = locale('no_access'),
            type = 'error',
        })
        return
    end

    local onDuty = dutyStaff[source] == nil

    if onDuty then
        local fallbackRank = getPlayerRank(source)
        local fallbackRankColorRgb = (Config.Tag.rankColors and Config.Tag.rankColors[fallbackRank]) or Config.Tag.defaultRankColor

        dutyStaff[source] = {
            id        = source,
            name      = GetPlayerName(source),
            rank      = fallbackRank,
            rankColor = rgbCss(fallbackRankColorRgb),
            avatarUrl = Config.Tag.defaultAvatar,
            startTime = os.time() * 1000,
            status    = 'active',
        }
        TriggerClientEvent('illenium-appearance:client:loadJobOutfit', source, {
            outfitData = Config.Outfits[GetEntityModel(GetPlayerPed(source))]
        })

        -- Discord-rang/avatar ophalen kan eventjes duren (HTTP-call), dus we
        -- gaan meteen in dienst met de ESX-fallback en updaten zodra het binnen is.
        refreshStaffMeta(source, function(meta)
            if dutyStaff[source] then
                dutyStaff[source].rank = meta.rank
                dutyStaff[source].rankColor = meta.rankColor
                dutyStaff[source].avatarUrl = meta.avatarUrl
            end
        end)
    else
        dutyStaff[source] = nil
    end

    TriggerClientEvent('lm-staffduty:client:dutyStateChanged', source, onDuty)
end)

-- Zorgt dat als iemands Discord-rol wijzigt terwijl die al in dienst is,
-- de rang/kleur/avatar in de tag na verloop van tijd toch klopt.
CreateThread(function()
    if not (Config.Discord and Config.Discord.enabled) then return end

    while true do
        Wait(Config.Discord.updateInterval or 15000)

        for src in pairs(dutyStaff) do
            refreshStaffMeta(src, function(meta)
                if dutyStaff[src] then
                    dutyStaff[src].rank = meta.rank
                    dutyStaff[src].rankColor = meta.rankColor
                    dutyStaff[src].avatarUrl = meta.avatarUrl
                end
            end)
        end
    end
end)

-- ======== Staff-tag: WIE ziet WIE, bepaald op de server ========
-- De server kent altijd de echte positie van elke connected speler
-- (via GetEntityCoords(GetPlayerPed(src))), ongeacht of die speler
-- client-side "gestreamed"/zichtbaar is bij een ander. Daarom gebeurt de
-- afstandscheck hier, en niet client-side (dat kon een verouderde/foute
-- positie gebruiken als iemand buiten je streaming-bereik ging).
local function vdist(ax, ay, az, bx, by, bz)
    local dx, dy, dz = ax - bx, ay - by, az - bz
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

CreateThread(function()
    while true do
        Wait(Config.Tag.updateInterval or 500)

        if Config.Tag.enabled and next(dutyStaff) ~= nil then
            -- Positie van elke in-dienst zijnde staff maar 1x per tick opvragen.
            local staffCoords = {}
            for src in pairs(dutyStaff) do
                local ped = GetPlayerPed(src)
                if ped ~= 0 then
                    local c = GetEntityCoords(ped)
                    staffCoords[src] = { x = c.x, y = c.y, z = c.z }
                end
            end

            for _, cidStr in ipairs(GetPlayers()) do
                local cid = tonumber(cidStr)
                local myPed = GetPlayerPed(cid)

                if myPed ~= 0 then
                    local myCoords = GetEntityCoords(myPed)
                    local nearby = {}

                    for src, coords in pairs(staffCoords) do
                        local dist = vdist(myCoords.x, myCoords.y, myCoords.z, coords.x, coords.y, coords.z)

                        if Config.Debug then
                            print(('[lm-staffduty] cid=%s <-> staff=%s dist=%.1f'):format(cid, src, dist))
                        end

                        if dist <= (Config.Tag.maxDistance or 25.0) then
                            local data = dutyStaff[src]
                            nearby[#nearby + 1] = {
                                id        = src,
                                name      = data.name,
                                rank      = data.rank,
                                rankColor = data.rankColor,
                                avatarUrl = data.avatarUrl,
                                isSelf    = src == cid,
                                x         = coords.x,
                                y         = coords.y,
                                z         = coords.z,
                                distance  = dist,
                            }
                        end
                    end

                    TriggerClientEvent('lm-staffduty:client:nearbyStaffTags', cid, nearby)
                end
            end
        end
    end
end)

RegisterNetEvent('txsv:checkIfAdmin', function()
    local src = source
    Wait(100)

    if not dutyStaff[src] then
        TriggerClientEvent('txcl:setAdmin', src, false, false, locale('no_access'))
    end
end)

-- ======== Exports ========
-- Gebruikt door andere resources (bv. ox_adminmenu) om te checken of een
-- speler in staff-dienst is voor toegang tot admin tools.
exports('isOnDuty', function(src)
    return dutyStaff[src] ~= nil
end)

exports('GetOnDutyList', function()
    return buildStaffList()
end)
