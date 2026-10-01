local ESX = exports['es_extended']:getSharedObject()

local Handcuffed = {}

local function _(key, ...)
    local str = (Locales[Config.Locale] and Locales[Config.Locale][key]) or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

local function notify(src, msg, nType)
    TriggerClientEvent('eclipse-politie:client:notify', src, msg, nType or 'inform')
end

local function getPolicePlayer(src)
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not xPlayer.job then return nil end
    if xPlayer.job.name ~= Config.JobName then return nil end
    return xPlayer
end

local function hasGrade(xPlayer, action)
    local needed = Config.MinGrade[action] or 0
    return (xPlayer.job.grade or 0) >= needed
end

local function isNear(src, target, maxDist)
    maxDist = maxDist or 5.0
    local a = GetPlayerPed(src)
    local b = GetPlayerPed(target)
    if a == 0 or b == 0 then return false end
    return #(GetEntityCoords(a) - GetEntityCoords(b)) <= maxDist
end

-- Society registratie
AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    TriggerEvent('esx_society:registerSociety', Config.JobName, 'Politie', Config.Society, Config.Society, Config.Society, { type = 'public' })
    pcall(function()
        TriggerEvent('esx_phone:registerNumber', Config.JobName, 'Politie', true, true)
    end)
end)

------------------------------------------------------------------------
-- Duty
------------------------------------------------------------------------
RegisterNetEvent('eclipse-politie:server:toggleDuty', function()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer or not xPlayer.job then return end

    local name = xPlayer.job.name
    local grade = xPlayer.job.grade or 0

    if name == Config.JobName then
        xPlayer.setJob(Config.OffJobName, grade)
        notify(src, _('duty_off'), 'inform')
    elseif name == Config.OffJobName then
        xPlayer.setJob(Config.JobName, grade)
        notify(src, _('duty_on'), 'success')
    else
        notify(src, _('not_police'), 'error')
    end
end)

------------------------------------------------------------------------
-- Armory
------------------------------------------------------------------------
RegisterNetEvent('eclipse-politie:server:giveWeapon', function(weaponName)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer then
        notify(src, _('not_on_duty'), 'error')
        return
    end
    if type(weaponName) ~= 'string' then return end

    local allowed
    for i = 1, #Config.Armory.weapons do
        local w = Config.Armory.weapons[i]
        if w.name == weaponName and (xPlayer.job.grade or 0) >= w.grade then
            allowed = w
            break
        end
    end
    if not allowed then
        notify(src, _('no_permission'), 'error')
        return
    end

    xPlayer.addWeapon(weaponName, 100)
    notify(src, _('armory_taken', allowed.label), 'success')
end)

RegisterNetEvent('eclipse-politie:server:giveItem', function(itemName, count)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer then
        notify(src, _('not_on_duty'), 'error')
        return
    end
    if type(itemName) ~= 'string' then return end
    count = tonumber(count) or 1

    local allowed
    for i = 1, #Config.Armory.items do
        local it = Config.Armory.items[i]
        if it.name == itemName and (xPlayer.job.grade or 0) >= it.grade then
            allowed = it
            break
        end
    end
    if not allowed then
        notify(src, _('no_permission'), 'error')
        return
    end

    xPlayer.addInventoryItem(itemName, math.min(count, allowed.count or 1))
    notify(src, _('armory_taken', allowed.label), 'success')
end)

RegisterNetEvent('eclipse-politie:server:storeWeapons', function()
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer then return end

    for i = 1, #Config.Armory.weapons do
        local w = Config.Armory.weapons[i]
        if xPlayer.hasWeapon(w.name) then
            xPlayer.removeWeapon(w.name)
        end
    end
    notify(src, _('armory_stored'), 'success')
end)

------------------------------------------------------------------------
-- Player actions
------------------------------------------------------------------------
RegisterNetEvent('eclipse-politie:server:handcuff', function(target)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer or not hasGrade(xPlayer, 'cuff') then
        notify(src, _('no_permission'), 'error')
        return
    end
    target = tonumber(target)
    if not target or not isNear(src, target, 3.5) then
        notify(src, _('player_too_far'), 'error')
        return
    end

    if Config.RequireHandcuffItem and Config.HandcuffItem and Config.HandcuffItem ~= '' then
        local item = xPlayer.getInventoryItem(Config.HandcuffItem)
        if not item or (item.count or 0) < 1 then
            notify(src, 'Je hebt geen handboeien.', 'error')
            return
        end
    end

    Handcuffed[target] = not Handcuffed[target]
    TriggerClientEvent('eclipse-politie:client:setHandcuff', target, Handcuffed[target])
    if Handcuffed[target] then
        notify(src, _('cuffed'), 'success')
    else
        notify(src, _('uncuffed'), 'inform')
    end
end)

RegisterNetEvent('eclipse-politie:server:drag', function(target)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer or not hasGrade(xPlayer, 'escort') then return end
    target = tonumber(target)
    if not target or not isNear(src, target, 3.5) then
        notify(src, _('player_too_far'), 'error')
        return
    end
    if not Handcuffed[target] then
        notify(src, 'Verdachte is niet geboeid.', 'error')
        return
    end
    TriggerClientEvent('eclipse-politie:client:drag', target, src)
    notify(src, _('escorting'), 'inform')
end)

RegisterNetEvent('eclipse-politie:server:putInVehicle', function(target)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer or not hasGrade(xPlayer, 'vehicle') then return end
    target = tonumber(target)
    if not target or not isNear(src, target, 5.0) then return end
    TriggerClientEvent('eclipse-politie:client:putInVehicle', target)
    notify(src, _('in_vehicle'), 'success')
end)

RegisterNetEvent('eclipse-politie:server:outVehicle', function(target)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer or not hasGrade(xPlayer, 'vehicle') then return end
    target = tonumber(target)
    if not target or not isNear(src, target, 5.0) then return end
    TriggerClientEvent('eclipse-politie:client:outVehicle', target)
    notify(src, _('out_vehicle'), 'success')
end)

RegisterNetEvent('eclipse-politie:server:search', function(target)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer or not hasGrade(xPlayer, 'search') then return end
    target = tonumber(target)
    if not target or not isNear(src, target, 3.5) then
        notify(src, _('player_too_far'), 'error')
        return
    end

    local tPlayer = ESX.GetPlayerFromId(target)
    if not tPlayer then return end

    local inventory = {}
    local items = tPlayer.getInventory and tPlayer.getInventory() or tPlayer.inventory or {}
    if type(items) == 'table' then
        for _, item in pairs(items) do
            local count = item.count or item.amount or 0
            if count > 0 then
                inventory[#inventory + 1] = {
                    name = item.name,
                    label = item.label or item.name,
                    count = count,
                }
            end
        end
    end

    -- Wapens
    local loadout = tPlayer.getLoadout and tPlayer.getLoadout() or {}
    for i = 1, #loadout do
        inventory[#inventory + 1] = {
            name = loadout[i].name,
            label = loadout[i].label or loadout[i].name,
            count = 1,
        }
    end

    TriggerClientEvent('eclipse-politie:client:showSearch', src, tPlayer.getName(), inventory)
    notify(src, _('search_done'), 'success')
end)

RegisterNetEvent('eclipse-politie:server:checkId', function(target)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer or not hasGrade(xPlayer, 'id') then return end
    target = tonumber(target)
    if not target or not isNear(src, target, 3.5) then
        notify(src, _('player_too_far'), 'error')
        return
    end

    local tPlayer = ESX.GetPlayerFromId(target)
    if not tPlayer then return end

    local data = {
        name = tPlayer.getName(),
        job = ('%s - %s'):format(tPlayer.job.label or tPlayer.job.name, tPlayer.job.grade_label or tPlayer.job.grade),
        dob = tPlayer.get and (tPlayer.get('dateofbirth') or tPlayer.get('dateOfBirth')) or '-',
        sex = tPlayer.get and tPlayer.get('sex') or '-',
        height = tPlayer.get and tPlayer.get('height') or '-',
    }

    -- ESX identity velden
    if tPlayer.variables then
        data.dob = tPlayer.variables.dateofbirth or data.dob
        data.sex = tPlayer.variables.sex or data.sex
        data.height = tPlayer.variables.height or data.height
    end

    TriggerClientEvent('eclipse-politie:client:showId', src, data)
    notify(src, _('id_shown', data.name), 'inform')
end)

RegisterNetEvent('eclipse-politie:server:fine', function(target, amount, reason)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer or not hasGrade(xPlayer, 'fine') then
        notify(src, _('no_permission'), 'error')
        return
    end

    target = tonumber(target)
    amount = math.floor(tonumber(amount) or 0)
    reason = tostring(reason or 'Boete')

    if not target or not isNear(src, target, 5.0) then
        notify(src, _('player_too_far'), 'error')
        return
    end
    if amount < 1 or amount > (Config.MaxFine or 25000) then
        notify(src, _('invalid_amount'), 'error')
        return
    end

    local tPlayer = ESX.GetPlayerFromId(target)
    if not tPlayer then return end

    tPlayer.removeAccountMoney('bank', amount)

    if Config.BillingSociety and GetResourceState('esx_addonaccount') == 'started' then
        TriggerEvent('esx_addonaccount:getSharedAccount', Config.Society, function(account)
            if account then
                account.addMoney(amount)
            end
        end)
    end

    MySQL.insert(
        'INSERT INTO eclipse_politie_fines (identifier, player_name, officer, officer_name, amount, reason) VALUES (?, ?, ?, ?, ?, ?)',
        { tPlayer.identifier, tPlayer.getName(), xPlayer.identifier, xPlayer.getName(), amount, reason }
    )

    -- Optioneel esx_billing log
    if GetResourceState('esx_billing') == 'started' then
        pcall(function()
            MySQL.insert('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (?, ?, ?, ?, ?, ?)', {
                tPlayer.identifier,
                xPlayer.identifier,
                'society',
                Config.Society,
                reason,
                amount,
            })
        end)
    end

    notify(src, _('billed', amount), 'success')
    notify(target, _('billed_received', amount), 'error')
end)

RegisterNetEvent('eclipse-politie:server:checkPlate', function(plate)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer then return end
    plate = tostring(plate or ''):gsub('%s+', '')

    MySQL.single('SELECT owner, vehicle FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate }, function(row)
        if not row then
            notify(src, ('Kenteken %s: niet geregistreerd / NPCs'):format(plate), 'inform')
            return
        end
        MySQL.single('SELECT firstname, lastname FROM users WHERE identifier = ? LIMIT 1', { row.owner }, function(user)
            local ownerName = user and (('%s %s'):format(user.firstname or '', user.lastname or '')) or row.owner
            notify(src, ('Kenteken %s · Eigenaar: %s'):format(plate, ownerName), 'inform')
        end)
    end)
end)

RegisterNetEvent('eclipse-politie:server:impound', function(props)
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer or not hasGrade(xPlayer, 'impound') then return end
    if type(props) ~= 'table' or not props.plate then return end

    local plate = tostring(props.plate):gsub('%s+', '')
    local encoded = json.encode(props)

    MySQL.single('SELECT owner FROM owned_vehicles WHERE plate = ? LIMIT 1', { plate }, function(row)
        MySQL.insert(
            'INSERT INTO eclipse_politie_impound (plate, owner, props, reason, officer, officer_name) VALUES (?, ?, ?, ?, ?, ?)',
            { plate, row and row.owner or nil, encoded, 'Inbeslagname politie', xPlayer.identifier, xPlayer.getName() }
        )
    end)

    -- pound-kolom bestaat niet overal; falen mag stil
    pcall(function()
        MySQL.update('UPDATE owned_vehicles SET stored = 0, pound = 1 WHERE plate = ?', { plate })
    end)
    pcall(function()
        MySQL.update('UPDATE owned_vehicles SET stored = 0 WHERE plate = ?', { plate })
    end)

    notify(src, _('impounded'), 'success')
end)

RegisterNetEvent('eclipse-politie:server:getSocietyMoney', function()
    local src = source
    local xPlayer = getPolicePlayer(src)
    if not xPlayer or not hasGrade(xPlayer, 'boss') then
        notify(src, _('no_permission'), 'error')
        return
    end
    TriggerEvent('esx_addonaccount:getSharedAccount', Config.Society, function(account)
        local money = account and account.money or 0
        notify(src, ('Maatschappijsaldo: €%s'):format(money), 'inform')
    end)
end)

AddEventHandler('playerDropped', function()
    local src = source
    Handcuffed[src] = nil
end)
