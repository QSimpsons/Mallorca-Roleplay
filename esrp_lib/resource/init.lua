local currentResourceName = GetCurrentResourceName()
local context = IsDuplicityVersion() and "server" or "client"

if not LoadResourceFile(currentResourceName, "web/dist/index.html") then
   print(("^3[esrp_lib]^7 UI ontbreekt in resource '%s'. De Lua-API blijft beschikbaar."):format(currentResourceName))
end

---@type VxCache
---@diagnostic disable-next-line: missing-fields
local cache = {
   resource = currentResourceName
}

local function proxyExports(self, key, value)
   rawset(self, key, value)

   local info = debug.getinfo(2, 'S')
   if not info or not info.short_src:find("@" .. currentResourceName .. "/resource") then
      return
   end

   if type(value) == "function" then
      exports(key, value)
      return
   end

   if type(value) == "table" then
      setmetatable(value, {
         __newindex = function(t, k, v)
            proxyExports(t, key .. k, v)
         end
      })
   end
end

vx = setmetatable({
   context = context,
   cache = cache,
   serverConfig = ServerConfig,
   sharedConfig = SharedConfig
}, {
   __index = vx_loadModule,
   __newindex = proxyExports,
})

vx.frameworkResource = vx_autoDetect.getFramework()
vx.targetResource = vx_autoDetect.getTarget()
vx.inventoryResource = vx_autoDetect.getInventory()
vx.notifyResource = vx_autoDetect.getNotify()
vx.textuiResource = vx_autoDetect.getTextUi()

function vx.getFramework() return vx.frameworkResource end

function vx.getTarget() return vx.targetResource end

function vx.getServerConfig() return ServerConfig end

function vx.getSharedConfig() return SharedConfig end

function vx.getInventory() return vx_autoDetect.getInventory() end

_ENV.esrp_lib = vx

vx_autoDetect.loadFramework()

if GetResourceState("ox_lib") ~= "missing" then
   local oxInit = LoadResourceFile("ox_lib", "init.lua")
   local loadOx, err = oxInit and load(oxInit, "@ox_lib/init.lua")
   if not loadOx or err then
      vx.print.error(("Failed to load ox_lib (%s)"):format(err))
   else
      local ok, loadErr = pcall(loadOx)
      if not ok then
         vx.print.error(("Failed to load ox_lib (%s)"):format(loadErr))
      elseif context == "server" then
         vx.print.info("Successfully loaded ox_lib")
      end
   end
end
