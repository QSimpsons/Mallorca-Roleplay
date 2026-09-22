local here = arg[0]:match('^(.*)/') or '.'
dofile(here .. '/../starter_vipcoins.lua')

local failures = 0
local function eq(actual, expected, name)
    if actual ~= expected then
        failures = failures + 1
        io.stderr:write(('FAIL %s: got %q expected %q\n'):format(name, tostring(actual), tostring(expected)))
    end
end

eq(StarterVip.personKey('char1:license:abc'), 'license:abc', 'strip char1')
eq(StarterVip.personKey('char12:license:abc'), 'license:abc', 'strip char12')
eq(StarterVip.personKey('license:abc'), 'license:abc', 'plain license')
eq(StarterVip.personKey(''), nil, 'empty')
eq(StarterVip.formatAmount(10000), '10.000', 'format')

local ok, reason = StarterVip.shouldGrant(false)
eq(ok, true, 'first join grants')
eq(reason, 'first_join', 'first join reason')

ok, reason = StarterVip.shouldGrant(true)
eq(ok, false, 'second time blocked')
eq(reason, 'already', 'already reason')

-- Zelfde persoon, tweede character: dezelfde sleutel, dus al geclaimd.
local first = StarterVip.personKey('char1:license:aaa')
local second = StarterVip.personKey('char2:license:aaa')
eq(first, second, 'characters share one grant')

if failures > 0 then
    io.stderr:write(('%d test(s) failed\n'):format(failures))
    os.exit(1)
end
print('starter vipcoins tests: ok')
