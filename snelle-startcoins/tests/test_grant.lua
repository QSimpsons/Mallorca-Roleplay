-- Draait buiten FiveM: lua5.4 tests/test_grant.lua
local here = arg[0]:match('^(.*)/') or '.'
dofile(here .. '/../server/grant.lua')

local failures = 0

local function eq(actual, expected, name)
    if actual ~= expected then
        failures = failures + 1
        io.stderr:write(('FAIL %s: got %q expected %q\n'):format(name, tostring(actual), tostring(expected)))
    end
end

eq(Grant.formatAmount(10000), '10.000', 'format 10000')
eq(Grant.formatAmount(1000), '1.000', 'format 1000')
eq(Grant.formatAmount(999), '999', 'format 999')
eq(Grant.formatAmount(1000000), '1.000.000', 'format million')
eq(Grant.formatAmount('10000'), '10.000', 'format string')

eq(Grant.storageKey('char1:license:abc', true), 'char1:license:abc', 'per character')
eq(Grant.storageKey('char2:license:abc', false), 'license:abc', 'per license')
eq(Grant.storageKey('license:abc', false), 'license:abc', 'license stays')
eq(Grant.storageKey('', true), nil, 'empty identifier')

local function grant(opts)
    local ok, reason = Grant.shouldGrant(opts)
    return ok, reason
end

local base = {
    alreadyGranted = false,
    isNew = true,
    createdAgoSeconds = nil,
    fallbackEnabled = true,
    windowSeconds = 180
}

do
    local ok, reason = grant(base)
    eq(ok, true, 'new gets coins')
    eq(reason, 'new_character', 'new reason')
end

do
    local ok, reason = grant({
        alreadyGranted = true,
        isNew = true,
        fallbackEnabled = true,
        windowSeconds = 180
    })
    eq(ok, false, 'already blocked')
    eq(reason, 'already', 'already reason')
end

do
    local ok, reason = grant({
        alreadyGranted = false,
        isNew = false,
        createdAgoSeconds = 99999,
        fallbackEnabled = true,
        windowSeconds = 180
    })
    eq(ok, false, 'old player blocked')
    eq(reason, 'existing', 'existing reason')
end

do
    local ok, reason = grant({
        alreadyGranted = false,
        isNew = false,
        createdAgoSeconds = 30,
        fallbackEnabled = true,
        windowSeconds = 180
    })
    eq(ok, true, 'fresh character fallback')
    eq(reason, 'recent_character', 'recent reason')
end

do
    local ok, reason = grant({
        alreadyGranted = false,
        isNew = nil,
        createdAgoSeconds = nil,
        fallbackEnabled = true,
        windowSeconds = 180
    })
    eq(ok, false, 'unknown without timestamp')
    eq(reason, 'unknown', 'unknown reason')
end

do
    local ok = grant({
        alreadyGranted = false,
        isNew = false,
        createdAgoSeconds = 10,
        fallbackEnabled = false,
        windowSeconds = 180
    })
    eq(ok, false, 'fallback off ignores created_at')
end

do
    local src, xPlayer, isNew = Grant.normalizeLoaded(4, { identifier = 'char1:license:abc' }, true)
    eq(src, 4, 'normalize src')
    eq(xPlayer.identifier, 'char1:license:abc', 'normalize player')
    eq(isNew, true, 'normalize isNew')
end

do
    local src, _, isNew = Grant.normalizeLoaded(7, false, nil)
    eq(src, 7, 'normalize id only src')
    eq(isNew, false, 'normalize id only isNew')
end

if failures > 0 then
    io.stderr:write(('%d test(s) failed\n'):format(failures))
    os.exit(1)
end

print('snelle-startcoins grant tests: ok')
