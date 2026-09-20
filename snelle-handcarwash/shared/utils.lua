function Debug(...)
    if not Config or not Config.Debug then
        return
    end

    print(('[snelle-handcarwash] %s'):format(table.concat({ ... }, ' ')))
end

function ResourceStarted(name)
    return GetResourceState(name) == 'started'
end

function HasOxLib()
    return ResourceStarted('ox_lib') and lib ~= nil
end

function HasOxInventory()
    return ResourceStarted('ox_inventory')
end

function HasOxTarget()
    return ResourceStarted('ox_target')
end

function HasQTarget()
    return ResourceStarted('qtarget') or ResourceStarted('bt-target')
end

function GetInventoryType()
    local configured = Config.Inventory or 'auto'
    if configured ~= 'auto' then
        return configured
    end

    if HasOxInventory() then
        return 'ox_inventory'
    end

    return 'esx'
end

function GetTargetType()
    local configured = Config.Target or 'auto'
    if configured ~= 'auto' then
        return configured
    end

    if HasOxTarget() then
        return 'ox_target'
    end

    if HasQTarget() then
        return 'qtarget'
    end

    return 'none'
end

function GetNotifyType()
    local configured = Config.Notify or 'auto'
    if configured ~= 'auto' then
        return configured
    end

    if HasOxLib() then
        return 'ox_lib'
    end

    return 'esx'
end

function GetProgressType()
    local configured = Config.Progress or 'auto'
    if configured ~= 'auto' then
        return configured
    end

    if HasOxLib() then
        return 'ox_lib'
    end

    return 'native'
end

function GetTextUIType()
    local configured = Config.TextUI or 'auto'
    if configured ~= 'auto' then
        return configured
    end

    if HasOxLib() then
        return 'ox_lib'
    end

    return 'esx'
end

function GetWashType(name)
    return Config.WashTypes and Config.WashTypes[name] or nil
end

function ItemLabel(name)
    local key = 'item_' .. name
    local label = L(key)
    if label == key then
        return name
    end
    return label
end
