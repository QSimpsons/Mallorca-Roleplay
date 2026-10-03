-- esrp_lib is the Vertex library under a new resource name.
-- init.lua publishes that API as both vx and esrp_lib.
vx = vx or esrp_lib
esrp_lib = esrp_lib or vx

if vx == nil then
	error("[ocean_garage] esrp_lib is niet geladen. Zet ensure esrp_lib voor ensure ocean_garage.")
end
