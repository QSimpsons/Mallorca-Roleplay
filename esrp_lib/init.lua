local resourceName = GetCurrentResourceName()
local context = IsDuplicityVersion() and "server" or "client"

if type(noop) ~= "function" then
   function noop() end
end

local moduleLoaderFile = LoadResourceFile("esrp_lib", "loader.lua")
if not moduleLoaderFile then
   error("[esrp_lib] loader.lua ontbreekt. De resource-map moet esrp_lib heten.")
end

local loadModuleLoader, err = load(moduleLoaderFile, "@esrp_lib/loader.lua")
if not loadModuleLoader then
   error(("[esrp_lib] loader.lua kon niet geladen worden: %s"):format(err))
end

loadModuleLoader()

local function call(self, index, ...)
   local module = rawget(self, index)

   if not module then
      self[index] = noop
      module = vx_loadModule(self, index)

      if not module then
         local function makeProxy(path)
            return setmetatable({}, {
               __index = function(_, key)
                  return makeProxy(path .. key)
               end,

               __call = function(_, ...)
                  return exports["esrp_lib"][path](nil, ...)
               end
            })
         end

         local proxy = makeProxy(index)

         if not ... then
            self[index] = proxy
         end

         return proxy
      end
   end

   return module
end

-- Publish the API before any export call. A missing export used to abort this
-- file first, so later scripts died with "attempt to index a nil value (global 'vx')".
local vx = setmetatable({
   name = "esrp_lib",
   context = context,
   serverConfig = {},
   sharedConfig = {},
   frameworkResource = nil,
   inventoryResource = nil,
   targetResource = nil,
}, {
   __index = call,
   __call = call
})

---@type VxCache
vx.cache = setmetatable({
   resource = resourceName
}, {
   __index = context == "client" and function(self, key)
      AddEventHandler(("vx:cache:set:%s"):format(key), function(value)
         self[key] = value
      end)

      local ok, value = pcall(function()
         return exports["esrp_lib"].getFromCache(nil, key)
      end)
      if ok and value ~= nil then
         rawset(self, key, value)
      end

      return rawget(self, key)
   end or nil,
})

_ENV.vx = vx
_ENV.esrp_lib = vx

local function readExport(method)
   local ok, result = pcall(function()
      return exports["esrp_lib"][method]()
   end)

   if not ok then
      print(("^3[esrp_lib]^7 Export %s niet beschikbaar voor %s: %s"):format(method, resourceName, result))
      return nil
   end

   return result
end

if context == "server" then
   vx.serverConfig = readExport("getServerConfig") or {}
end

vx.sharedConfig = readExport("getSharedConfig") or {}
vx.frameworkResource = readExport("getFramework")
vx.inventoryResource = readExport("getInventory")
vx.targetResource = readExport("getTarget")

local requireOk, requireFn = pcall(function()
   return vx.require
end)
if requireOk and type(requireFn) == "function" then
   _ENV.require = requireFn
end

if vx.frameworkResource == "es_extended" then
   local esxOk, esx = pcall(function()
      return exports[vx.frameworkResource]:getSharedObject()
   end)
   if esxOk then
      _ENV.ESX = esx
   end
elseif vx.frameworkResource == "qb-core" then
   local qbOk, core = pcall(function()
      return exports[vx.frameworkResource]:GetCoreObject()
   end)
   if qbOk then
      _ENV.QBCore = core
   end

   RegisterNetEvent(("QBCore:%s:UpdateObject"):format(context), function()
      _ENV.QBCore = exports[vx.frameworkResource]:GetCoreObject()
   end)
end
