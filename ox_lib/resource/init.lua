local debug_getinfo = debug.getinfo

function noop() end

local loadError

local function hasLoaded()
    if loadError then
        return loadError
    end

    return true
end

-- Dependents call this from @ox_lib/init.lua. Register it before any startup
-- step that can error, or that file aborts and leaves lib/cache unset.
exports('hasLoaded', hasLoaded)

lib = setmetatable({
    name = 'ox_lib',
    context = IsDuplicityVersion() and 'server' or 'client',
    hasLoaded = hasLoaded,
}, {
    __newindex = function(self, key, fn)
        rawset(self, key, fn)

        local info = debug_getinfo(2, 'S')
        local src = info and info.short_src or ''

        if src:find('ox_lib/resource', 1, true) or src:find('ox_lib\\resource', 1, true) then
            exports(key, fn)
        end
    end,

    __index = function(self, key)
        local dir = ('imports/%s'):format(key)
        local chunk = LoadResourceFile(self.name, ('%s/%s.lua'):format(dir, self.context))
        local shared = LoadResourceFile(self.name, ('%s/shared.lua'):format(dir))

        if shared then
            chunk = (chunk and ('%s\n%s'):format(shared, chunk)) or shared
        end

        if chunk then
            local fn, err = load(chunk, ('@@ox_lib/%s/%s.lua'):format(key, self.context))

            if not fn or err then
                return error(('\n^1Error importing module (%s): %s^0'):format(dir, err), 3)
            end

            rawset(self, key, fn() or noop)

            return self[key]
        end
    end
})

cache = {
    resource = lib.name,
    game = GetGameName(),
}

-- Install before the UI check. error() stops this file, and FiveM's built-in
-- require cannot load resource.settings or define the locale global.
require = lib.require

if not LoadResourceFile(lib.name, 'web/build/index.html') then
    loadError =
    '^1Unable to load UI. Build ox_lib or download the latest release.\n	^3https://github.com/overextended/ox_lib/releases/latest/download/ox_lib.zip^0'
    error(loadError)
end
