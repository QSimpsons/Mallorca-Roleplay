-- SafeProgress: jg-progressbar heeft vaak geen `Progress` export.
-- Crash was: No such export Progress in resource jg-progressbar
-- Fallback: ox_lib lib.progressBar (al een dependency van jg-anwb).

local OX_LIB_STYLES = {
    ox_lib = 'bar',
    ['ox-bar'] = 'bar',
    ['ox-circle'] = 'circle',
    oxlib = 'bar',
}

local QB_PROGRESS_RESOURCES = {
    'progressbar',
    'qb-progressbar',
}

local warnedMissingExport = false

local function ResourceStarted(name)
    return type(name) == 'string' and name ~= '' and GetResourceState(name) == 'started'
end

local function FinishOnce(cb)
    local done = false
    return function(cancelled)
        if done then
            return
        end
        done = true
        if type(cb) == 'function' then
            cb(cancelled and true or false)
        end
    end
end

local function BuildOxPayload(data)
    local disable
    if type(data.controlDisables) == 'table' then
        disable = {
            move = data.controlDisables.disableMovement,
            car = data.controlDisables.disableCarMovement,
            mouse = data.controlDisables.disableMouse,
            combat = data.controlDisables.disableCombat,
        }
    end

    local anim
    if type(data.animation) == 'table' then
        if data.animation.animDict and data.animation.anim then
            anim = {
                dict = data.animation.animDict,
                clip = data.animation.anim,
                flag = data.animation.flags,
            }
        elseif data.animation.scenario then
            anim = {
                scenario = data.animation.scenario,
            }
        end
    end

    return {
        duration = tonumber(data.duration) or 1000,
        label = data.label or '',
        useWhileDead = data.useWhileDead == true,
        canCancel = data.canCancel ~= false,
        disable = disable,
        anim = anim,
    }
end

local function RunOxProgress(data, style)
    local payload = BuildOxPayload(data)
    if style == 'circle' and lib and lib.progressCircle then
        return lib.progressCircle(payload)
    end
    if lib and lib.progressBar then
        return lib.progressBar(payload)
    end
    if lib and lib.progressCircle then
        return lib.progressCircle(payload)
    end

    local ok, result = pcall(function()
        if style == 'circle' then
            return exports.ox_lib:progressCircle(payload)
        end
        return exports.ox_lib:progressBar(payload)
    end)
    if ok and type(result) == 'boolean' then
        return result
    end
    return nil
end

local function TryCallbackExport(resource, data, finish)
    if not ResourceStarted(resource) then
        return false
    end

    local methods = { 'Progress', 'progress' }
    for i = 1, #methods do
        local method = methods[i]
        local ok = pcall(function()
            exports[resource][method](data, finish)
        end)
        if ok then
            return true
        end
    end
    return false
end

SafeProgress = function(data, cb)
    data = type(data) == 'table' and data or {}
    local finish = FinishOnce(cb)
    local configured = Config and Config.Progress
    local oxStyle = type(configured) == 'string' and OX_LIB_STYLES[configured] or nil

    if not oxStyle then
        local tried = {}
        local candidates = { configured }
        for i = 1, #QB_PROGRESS_RESOURCES do
            candidates[#candidates + 1] = QB_PROGRESS_RESOURCES[i]
        end
        for i = 1, #candidates do
            local resource = candidates[i]
            if resource and not tried[resource] then
                tried[resource] = true
                if TryCallbackExport(resource, data, finish) then
                    return true
                end
            end
        end

        if configured and ResourceStarted(configured) and not warnedMissingExport then
            warnedMissingExport = true
            print(('^3[jg-anwb] Geen Progress export in %s, ox_lib progressBar wordt gebruikt.^7'):format(configured))
        end
    end

    CreateThread(function()
        local success = RunOxProgress(data, oxStyle)
        if success == nil then
            Wait(tonumber(data.duration) or 0)
            finish(false)
            return
        end
        finish(not success)
    end)
    return true
end

print('^2[jg-anwb] progress.lua: SafeProgress (ox_lib fallback)^7')
