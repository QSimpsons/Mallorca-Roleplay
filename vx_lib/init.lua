-- Runs inside the resource that includes @vx_lib/init.lua (for example esrp_cardealer).
-- esrp_lib/init.lua publishes the Vertex API as the globals vx and esrp_lib.

if vx ~= nil then
    esrp_lib = esrp_lib or vx
    return
end

local chunk = LoadResourceFile("esrp_lib", "init.lua")
if not chunk then
    error("[vx_lib] esrp_lib/init.lua ontbreekt. Zet ensure esrp_lib voor deze resource.")
end

local fn, err = load(chunk, "@esrp_lib/init.lua", "t", _ENV)
if not fn then
    error(("[vx_lib] esrp_lib init.lua: %s"):format(err))
end

fn()

vx = vx or esrp_lib
esrp_lib = esrp_lib or vx

if vx == nil then
    error("[vx_lib] esrp_lib heeft vx niet gezet.")
end
