function Debug(...)
    if not Config or not Config.Debug then
        return
    end

    print(('[snelle-voertuigduwen] %s'):format(table.concat({ ... }, ' ')))
end

function ResourceStarted(name)
    return GetResourceState(name) == 'started'
end

function HasOxLib()
    return ResourceStarted('ox_lib') and lib ~= nil
end

function HasOxTarget()
    return ResourceStarted('ox_target')
end

function HasQTarget()
    return ResourceStarted('qtarget') or ResourceStarted('bt-target')
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

function IsModelBlacklisted(model)
    local list = Config.BlacklistedModels
    if type(list) ~= 'table' or not model then
        return false
    end

    for i = 1, #list do
        local entry = list[i]
        local hash = type(entry) == 'number' and entry or joaat(entry)
        if hash == model then
            return true
        end
    end

    return false
end

function JobsRestricted()
    return type(Config.AllowedJobs) == 'table' and next(Config.AllowedJobs) ~= nil
end
