local ESX = nil
local pendingWash = {}

local function loadESX()
    if ESX then
        return true
    end

    if exports and exports['es_extended'] then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and obj then
            ESX = obj
            return true
        end
    end

    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)

    return ESX ~= nil
end

CreateThread(function()
    while not loadESX() do
        Wait(100)
    end

    Debug('ESX geladen, inventory =', GetInventoryType())
end)

local function getPlayer(src)
    if not ESX then
        return nil
    end
    return ESX.GetPlayerFromId(src)
end

local function getItemCount(src, name)
    if GetInventoryType() == 'ox_inventory' then
        return exports.ox_inventory:GetItemCount(src, name) or 0
    end

    local xPlayer = getPlayer(src)
    if not xPlayer then
        return 0
    end

    local item = xPlayer.getInventoryItem(name)
    if not item then
        return 0
    end

    return item.count or item.amount or 0
end

local function canCarry(src, name, count)
    count = count or 1

    if GetInventoryType() == 'ox_inventory' then
        return exports.ox_inventory:CanCarryItem(src, name, count)
    end

    local xPlayer = getPlayer(src)
    if not xPlayer then
        return false
    end

    if xPlayer.canCarryItem then
        return xPlayer.canCarryItem(name, count)
    end

    return true
end

local function addItem(src, name, count)
    count = count or 1

    if GetInventoryType() == 'ox_inventory' then
        return exports.ox_inventory:AddItem(src, name, count)
    end

    local xPlayer = getPlayer(src)
    if not xPlayer then
        return false
    end

    xPlayer.addInventoryItem(name, count)
    return true
end

local function removeItem(src, name, count)
    count = count or 1
    if getItemCount(src, name) < count then
        return false
    end

    if GetInventoryType() == 'ox_inventory' then
        return exports.ox_inventory:RemoveItem(src, name, count)
    end

    local xPlayer = getPlayer(src)
    if not xPlayer then
        return false
    end

    xPlayer.removeInventoryItem(name, count)
    return true
end

local function missingItems(src, requirements)
    local missing = {}

    for i = 1, #requirements do
        local req = requirements[i]
        local have = getItemCount(src, req.name)
        if have < (req.count or 1) then
            missing[#missing + 1] = ('%s x%s'):format(ItemLabel(req.name), req.count or 1)
        end
    end

    if #missing == 0 then
        return nil
    end

    return table.concat(missing, ', ')
end

local function getMoney(xPlayer)
    if not xPlayer then
        return 0
    end

    local account = Config.PayAccount or 'money'
    if xPlayer.getAccount then
        local data = xPlayer.getAccount(account)
        if data and data.money then
            return data.money
        end
    end

    if account == 'bank' then
        return 0
    end

    if xPlayer.getMoney then
        return xPlayer.getMoney()
    end

    return 0
end

local function removeMoney(xPlayer, amount)
    local account = Config.PayAccount or 'money'
    if xPlayer.removeAccountMoney then
        xPlayer.removeAccountMoney(account, amount)
        return
    end

    if xPlayer.removeMoney then
        xPlayer.removeMoney(amount)
    end
end

local function findShopItem(name)
    for i = 1, #(Config.Shop.items or {}) do
        local item = Config.Shop.items[i]
        if item.name == name then
            return item
        end
    end
    return nil
end

local function vehicleFromNetId(src, netId)
    if type(netId) ~= 'number' then
        return nil
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        return nil
    end

    if GetEntityType(vehicle) ~= 2 then
        return nil
    end

    local ped = GetPlayerPed(src)
    if ped == 0 then
        return nil
    end

    local dist = #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
    if dist > (Config.Wash.maxDistance + 3.0) then
        return nil
    end

    return vehicle
end

local function consumeWashItems(src, washType)
    local data = GetWashType(washType)
    if not data then
        return false, 'invalid_wash'
    end

    local missing = missingItems(src, data.items)
    if missing then
        return false, 'missing_items', missing
    end

    for i = 1, #data.items do
        local req = data.items[i]
        if req.give and not canCarry(src, req.give, req.count or 1) then
            return false, 'cannot_carry'
        end
    end

    for i = 1, #data.items do
        local req = data.items[i]
        if req.consume then
            if not removeItem(src, req.name, req.count or 1) then
                return false, 'missing_items', ItemLabel(req.name)
            end
            if req.give then
                if not addItem(src, req.give, req.count or 1) then
                    addItem(src, req.name, req.count or 1)
                    return false, 'cannot_carry'
                end
            end
        end
    end

    return true
end

CreateThread(function()
    while not ESX do
        Wait(100)
    end

    local usable = {
        Config.Items.emptyBucket,
        Config.Items.waterBucket,
        Config.Items.sponge,
        Config.Items.soap,
        Config.Items.cloth,
        Config.Items.wax,
        Config.Items.tireCleaner,
        Config.Items.kit
    }

    for i = 1, #usable do
        local itemName = usable[i]
        if itemName then
            ESX.RegisterUsableItem(itemName, function(source)
                TriggerClientEvent('snelle-handcarwash:client:usedItem', source, itemName)
            end)
        end
    end
end)

ESXCallback = function(name, fn)
    CreateThread(function()
        while not ESX do
            Wait(50)
        end
        ESX.RegisterServerCallback(name, fn)
    end)
end

ESXCallback('snelle-handcarwash:startWash', function(source, cb, netId, washType)
    local data = GetWashType(washType)
    if not data then
        cb({ ok = false, reason = 'invalid_wash' })
        return
    end

    if pendingWash[source] then
        if os.time() - (pendingWash[source].started or 0) < 90 then
            cb({ ok = false, reason = 'busy' })
            return
        end
        pendingWash[source] = nil
    end

    local vehicle = vehicleFromNetId(source, netId)
    if not vehicle then
        cb({ ok = false, reason = 'no_vehicle' })
        return
    end

    local missing = missingItems(source, data.items)
    if missing then
        cb({ ok = false, reason = 'missing_items', extra = missing })
        return
    end

    pendingWash[source] = {
        washType = washType,
        netId = netId,
        started = os.time()
    }

    cb({ ok = true })
end)

ESXCallback('snelle-handcarwash:finishWash', function(source, cb, netId, washType)
    local pending = pendingWash[source]
    pendingWash[source] = nil

    if not pending or pending.washType ~= washType then
        cb({ ok = false, reason = 'cancelled' })
        return
    end

    local vehicle = vehicleFromNetId(source, netId)
    if not vehicle then
        cb({ ok = false, reason = 'no_vehicle' })
        return
    end

    local ok, reason, extra = consumeWashItems(source, washType)
    if not ok then
        cb({ ok = false, reason = reason, extra = extra })
        return
    end

    local data = GetWashType(washType)
    local waxedUntil = nil
    if data.waxed and Config.Wash.waxDurationMinutes > 0 then
        waxedUntil = os.time() + (Config.Wash.waxDurationMinutes * 60)
    end

    local payload = {
        dirtLevel = data.dirtLevel,
        cleanTires = data.cleanTires and true or false,
        waxed = data.waxed and true or false,
        waxedUntil = waxedUntil
    }

    local okState, errState = pcall(function()
        Entity(vehicle).state:set('snelleHandwash', payload, true)
    end)
    if not okState then
        Debug('statebag failed', tostring(errState))
    end
    TriggerClientEvent('snelle-handcarwash:client:applyClean', -1, netId, payload)

    cb({ ok = true, dirtLevel = payload.dirtLevel, cleanTires = payload.cleanTires, waxed = payload.waxed })
end)

RegisterNetEvent('snelle-handcarwash:cancelWash', function()
    pendingWash[source] = nil
end)

local function isNearShop(src)
    local ped = GetPlayerPed(src)
    if ped == 0 then
        return false
    end

    local coords = GetEntityCoords(ped)
    local maxDist = (Config.Shop.interactDistance or 2.2) + 4.0

    for i = 1, #Config.Shops do
        if #(coords - Config.Shops[i].coords) <= maxDist then
            return true
        end
    end

    return false
end

local function isNearWater(src)
    local ped = GetPlayerPed(src)
    if ped == 0 then
        return false
    end

    if Config.Water.allowNaturalWater and IsEntityInWater(ped) then
        return true
    end

    local coords = GetEntityCoords(ped)
    local tapDist = (Config.Water.interactDistance or 2.0) + 2.5
    local shopDist = tapDist + 8.0

    for i = 1, #Config.Shops do
        if #(coords - Config.Shops[i].coords) <= shopDist then
            return true
        end
    end

    for i = 1, #Config.Water.taps do
        if #(coords - Config.Water.taps[i]) <= tapDist then
            return true
        end
    end

    return false
end

ESXCallback('snelle-handcarwash:canFillBucket', function(source, cb)
    if not isNearWater(source) then
        cb({ ok = false, reason = 'not_near_water' })
        return
    end
    if getItemCount(source, Config.Items.emptyBucket) < 1 then
        cb({ ok = false, reason = 'need_empty_bucket' })
        return
    end

    if getItemCount(source, Config.Items.waterBucket) > 0 then
        cb({ ok = false, reason = 'already_has_water' })
        return
    end

    cb({ ok = true })
end)

ESXCallback('snelle-handcarwash:fillBucket', function(source, cb)
    if not isNearWater(source) then
        cb({ ok = false, reason = 'not_near_water' })
        return
    end
    if getItemCount(source, Config.Items.emptyBucket) < 1 then
        cb({ ok = false, reason = 'need_empty_bucket' })
        return
    end

    if not removeItem(source, Config.Items.emptyBucket, 1) then
        cb({ ok = false, reason = 'need_empty_bucket' })
        return
    end

    if not addItem(source, Config.Items.waterBucket, 1) then
        addItem(source, Config.Items.emptyBucket, 1)
        cb({ ok = false, reason = 'cannot_carry' })
        return
    end

    cb({ ok = true })
end)

ESXCallback('snelle-handcarwash:buyItem', function(source, cb, itemName)
    if not isNearShop(source) then
        cb({ ok = false, reason = 'not_near_shop' })
        return
    end
    local shopItem = findShopItem(itemName)
    if not shopItem then
        cb({ ok = false, reason = 'invalid_wash' })
        return
    end

    local xPlayer = getPlayer(source)
    if not xPlayer then
        cb({ ok = false, reason = 'busy' })
        return
    end

    local amount = shopItem.amount or 1
    local price = shopItem.price or 0

    if getMoney(xPlayer) < price then
        cb({ ok = false, reason = 'not_enough_money', extra = price })
        return
    end

    if not canCarry(source, shopItem.name, amount) then
        cb({ ok = false, reason = 'cannot_carry' })
        return
    end

    removeMoney(xPlayer, price)
    addItem(source, shopItem.name, amount)
    cb({ ok = true, price = price, amount = amount })
end)

AddEventHandler('playerDropped', function()
    pendingWash[source] = nil
end)

-- ox_inventory export fallback (items.lua client.export)
exports('useHandwashItem', function(event, item, inventory, slot, data)
    local src = inventory and inventory.id or source
    if type(src) ~= 'number' then
        return
    end
    TriggerClientEvent('snelle-handcarwash:client:usedItem', src, item and item.name or Config.Items.sponge)
end)
