-- Standalone test for SafeProgress fallback (no FiveM runtime required).
-- Run: lua5.4 jg-anwb/tests/test_progress_fallback.lua

local ROOT = arg[0]:match('(.+)/[^/]+$') or '.'
local PROGRESS_LUA = ROOT .. '/../client/progress.lua'
local real_print = print

local failures = 0
local function assert_eq(actual, expected, message)
    if actual ~= expected then
        failures = failures + 1
        io.stderr:write(('FAIL: %s (got %s, expected %s)\n'):format(
            message, tostring(actual), tostring(expected)
        ))
    end
end

local function assert_true(value, message)
    assert_eq(not not value, true, message)
end

local function reset_env(opts)
    opts = opts or {}
    package.loaded['progress_under_test'] = nil

    _G.Config = { Progress = opts.progressResource or 'jg-progressbar' }
    _G.oxCalls = {}
    _G.exportCalls = {}
    _G.prints = {}
    _G.SafeProgress = nil

    _G.GetResourceState = function(name)
        if opts.states and opts.states[name] then
            return opts.states[name]
        end
        if name == 'jg-progressbar' then
            return opts.jgState or 'started'
        end
        if name == 'ox_lib' then
            return 'started'
        end
        if name == 'progressbar' or name == 'qb-progressbar' then
            return opts.qbState or 'missing'
        end
        return 'missing'
    end

    _G.CreateThread = function(fn)
        fn()
    end

    _G.Wait = function(_) end

    _G.print = function(msg)
        _G.prints[#_G.prints + 1] = tostring(msg)
    end

    local oxResult = opts.oxResult
    if oxResult == nil then
        oxResult = true
    end

    _G.lib = {
        progressBar = function(payload)
            _G.oxCalls[#_G.oxCalls + 1] = { kind = 'bar', payload = payload }
            return oxResult
        end,
        progressCircle = function(payload)
            _G.oxCalls[#_G.oxCalls + 1] = { kind = 'circle', payload = payload }
            return oxResult
        end,
    }

    local progressExport = opts.progressExport
    local exportIndex = function(resource)
        return setmetatable({}, {
            __index = function(_, method)
                if resource == 'jg-progressbar' and progressExport then
                    return function(data, cb)
                        _G.exportCalls[#_G.exportCalls + 1] = {
                            resource = resource,
                            method = method,
                            data = data,
                        }
                        progressExport(data, cb)
                    end
                end
                if resource == 'progressbar' and opts.qbProgress then
                    return function(data, cb)
                        _G.exportCalls[#_G.exportCalls + 1] = {
                            resource = resource,
                            method = method,
                            data = data,
                        }
                        opts.qbProgress(data, cb)
                    end
                end
                error(('No such export %s in resource %s'):format(tostring(method), tostring(resource)), 2)
            end,
        })
    end

    _G.exports = setmetatable({}, {
        __index = function(_, resource)
            return exportIndex(resource)
        end,
    })

    local chunk, err = loadfile(PROGRESS_LUA)
    if not chunk then
        error('Could not load progress.lua: ' .. tostring(err))
    end
    chunk()
end

-- 1. Exact production crash: jg-progressbar started, no Progress export.
do
    reset_env()
    local cancelled
    SafeProgress({
        duration = 10000,
        label = 'Voertuig aan het schoonmaken',
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
    }, function(wasCancelled)
        cancelled = wasCancelled
    end)

    assert_eq(#_G.exportCalls, 0, 'missing Progress export should not record a successful export call')
    assert_eq(#_G.oxCalls, 1, 'should fall back to ox_lib progressBar')
    assert_eq(_G.oxCalls[1].kind, 'bar', 'default ox fallback is progressBar')
    assert_eq(_G.oxCalls[1].payload.label, 'Voertuig aan het schoonmaken', 'label is forwarded to ox_lib')
    assert_eq(_G.oxCalls[1].payload.disable.move, true, 'disableMovement maps to disable.move')
    assert_eq(_G.oxCalls[1].payload.disable.car, true, 'disableCarMovement maps to disable.car')
    assert_eq(_G.oxCalls[1].payload.disable.combat, true, 'disableCombat maps to disable.combat')
    assert_eq(cancelled, false, 'successful ox_lib progress should call cb(false)')
    assert_true(#_G.prints >= 2, 'should print load banner plus missing-export warning')
end

-- 2. Existing Progress export must be used and ox_lib skipped.
do
    reset_env({
        progressExport = function(data, cb)
            cb(false)
        end,
    })
    local cancelled
    SafeProgress({ duration = 2000, label = 'Repareren' }, function(wasCancelled)
        cancelled = wasCancelled
    end)
    assert_eq(#_G.exportCalls, 1, 'Progress export should be used when it exists')
    assert_eq(_G.exportCalls[1].method, 'Progress', 'should call Progress (QB API)')
    assert_eq(#_G.oxCalls, 0, 'should not fall back to ox_lib when Progress exists')
    assert_eq(cancelled, false, 'export success should call cb(false)')
end

-- 3. Cancelled ox_lib progress.
do
    reset_env({ oxResult = false })
    local cancelled
    SafeProgress({ duration = 1000, label = 'VIN' }, function(wasCancelled)
        cancelled = wasCancelled
    end)
    assert_eq(cancelled, true, 'ox_lib false (cancelled) should call cb(true)')
end

-- 4. Config.Progress = ox-circle should skip jg-progressbar entirely.
do
    reset_env({ progressResource = 'ox-circle' })
    SafeProgress({ duration = 500, label = 'Circle' }, function() end)
    assert_eq(#_G.exportCalls, 0, 'ox-circle should not touch jg-progressbar')
    assert_eq(_G.oxCalls[1].kind, 'circle', 'ox-circle uses progressCircle')
end

-- 5. qb-progressbar fallback when jg-progressbar has no export.
do
    reset_env({
        qbState = 'started',
        qbProgress = function(_, cb)
            cb(false)
        end,
    })
    local cancelled
    SafeProgress({ duration = 1000, label = 'QB' }, function(wasCancelled)
        cancelled = wasCancelled
    end)
    assert_eq(#_G.exportCalls, 1, 'should use progressbar/qb-progressbar if present')
    assert_eq(_G.exportCalls[1].resource, 'progressbar', 'progressbar is tried after Config.Progress')
    assert_eq(#_G.oxCalls, 0, 'ox_lib unused when qb-style export works')
    assert_eq(cancelled, false, 'qb-style success should call cb(false)')
end

-- 6. Animation mapping for VIN check.
do
    reset_env()
    SafeProgress({
        duration = 60000,
        label = 'VIN',
        animation = {
            animDict = 'mp_intro_seq@',
            anim = 'mp_mech_fix',
            flags = 0,
        },
    }, function() end)
    assert_eq(_G.oxCalls[1].payload.anim.dict, 'mp_intro_seq@', 'animDict maps to anim.dict')
    assert_eq(_G.oxCalls[1].payload.anim.clip, 'mp_mech_fix', 'anim maps to anim.clip')
    assert_eq(_G.oxCalls[1].payload.anim.flag, 0, 'flags maps to anim.flag')
end

-- 7. Direct exports['jg-progressbar']:Progress must be catchable (production error).
do
    reset_env()
    local ok, err = pcall(function()
        exports['jg-progressbar']:Progress({ duration = 1 }, function() end)
    end)
    assert_eq(ok, false, 'raw Progress call should still error without SafeProgress')
    assert_true(tostring(err):find('No such export Progress', 1, true) ~= nil, 'raw error text matches production crash')
end

-- 8. Drop-in client.lua must be v8 and must not call Config.Progress:Progress.
do
    local path = ROOT .. '/../client/client.lua'
    local fh = assert(io.open(path, 'r'))
    local src = fh:read('*a')
    fh:close()
    assert_true(src:find("client.lua v8 geladen %(PROGRESS%-FIX%)", 1) ~= nil, 'client.lua must print v8 PROGRESS-FIX')
    assert_eq(src:find("print('^2[jg-anwb] client.lua v6 geladen^7')", 1, true) ~= nil, false, 'client.lua must not still print v6 geladen')
    assert_eq(src:find("exports[''..Config.Progress..'']:Progress", 1, true) ~= nil, false, 'raw Config.Progress Progress export must be gone')
    local count = 0
    for _ in src:gmatch('SafeProgress%({') do
        count = count + 1
    end
    assert_eq(count, 3, 'repair/vin/wash must call SafeProgress')
end

if failures > 0 then
    io.stderr:write(('test_progress_fallback.lua: %d failure(s)\n'):format(failures))
    os.exit(1)
end

real_print('test_progress_fallback.lua: all checks passed')
