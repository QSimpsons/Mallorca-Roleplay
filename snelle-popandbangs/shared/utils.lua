function Debug(...)
    if not Config or not Config.Debug then
        return
    end

    print(('[snelle-popandbangs] %s'):format(table.concat({ ... }, ' ')))
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

function GetTargetType()
    local configured = Config.Target or 'auto'
    if configured ~= 'auto' then
        return configured
    end

    if HasOxTarget() then
        return 'ox_target'
    end

    return 'none'
end

function NormalizePlate(plate)
    if type(plate) ~= 'string' then
        return nil
    end

    plate = plate:gsub('^%s+', ''):gsub('%s+$', ''):upper():gsub('%s+', '')
    if plate == '' then
        return nil
    end

    return plate
end

function StageFromItem(itemName)
    if type(itemName) ~= 'string' or not Config.Stages then
        return nil
    end

    for stage = 1, 6 do
        local cfg = Config.Stages[stage]
        if cfg and cfg.item == itemName then
            return stage
        end
    end

    return nil
end

function IsBlockedClass(class)
    return Config.BlockedClasses and Config.BlockedClasses[class] == true
end
