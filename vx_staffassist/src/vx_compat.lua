--[[
  Vervangt vx_lib met ox_lib.
  vx_lib zette de global `vx`. Zonder die resource crasht het script op `vx.*`.
]]

vx = vx or {}

if not lib or not lib.callback then
  error('[vx_staffassist] ox_lib is niet geladen. Start ox_lib voor deze resource.')
end

local function getESX()
  if ESX then
    return ESX
  end

  local ok, obj = pcall(function()
    return exports['es_extended']:getSharedObject()
  end)

  if ok and obj then
    ESX = obj
  end

  return ESX
end

ensureESX = getESX

local function toNotifyData(data)
  if type(data) ~= 'table' then
    return { description = tostring(data), type = 'inform' }
  end

  return {
    id = data.id,
    title = data.title,
    description = data.description or data.message,
    type = data.type or 'inform',
    duration = data.duration,
    position = data.position,
    icon = data.icon,
  }
end

function vx.notify(target, data)
  if IsDuplicityVersion() then
    if type(target) ~= 'number' and type(target) ~= 'string' then
      return
    end

    TriggerClientEvent('ox_lib:notify', target, toNotifyData(data))
    return
  end

  lib.notify(toNotifyData(target))
end

vx.print = vx.print or {}

function vx.print.info(...)
  if lib and lib.print and lib.print.info then
    lib.print.info(...)
    return
  end

  print(...)
end

local function playerHasAccess(source, restricted)
  if restricted == nil or restricted == false then
    return true
  end

  if source == 0 then
    return true
  end

  local esx = getESX()
  local playerGroup

  if esx then
    local xPlayer = esx.GetPlayerFromId(source)

    if xPlayer then
      if type(xPlayer.getGroup) == 'function' then
        playerGroup = xPlayer.getGroup()
      else
        playerGroup = xPlayer.group
      end
    end
  end

  local function matches(required)
    if playerGroup ~= nil and playerGroup == required then
      return true
    end

    if IsPlayerAceAllowed(source, required) then
      return true
    end

    if IsPlayerAceAllowed(source, 'group.' .. required) then
      return true
    end

    return false
  end

  if type(restricted) == 'table' then
    for i = 1, #restricted do
      if matches(restricted[i]) then
        return true
      end
    end

    return false
  end

  return matches(restricted)
end

function vx.addCommand(commandName, properties, cb)
  if not IsDuplicityVersion() then
    return
  end

  if not lib.addCommand then
    error('[vx_staffassist] ox_lib addCommand ontbreekt. Update ox_lib.')
  end

  properties = properties or {}

  local restricted = properties.restricted

  lib.addCommand(commandName, {
    help = properties.help,
    params = properties.params,
  }, function(source, args, raw)
    local allowed = playerHasAccess(source, restricted)

    if not allowed and Config and Config.group then
      allowed = playerHasAccess(source, Config.group)
    end

    if not allowed then
      vx.notify(source, {
        message = 'Je hebt geen rechten om dit commando te gebruiken.',
        type = 'error',
      })
      return
    end

    cb(source, args, raw)
  end)
end

vx.player = vx.player or {}

function vx.player.getFromId(playerId)
  local esx = getESX()
  local xPlayer = esx and esx.GetPlayerFromId(playerId) or nil

  return {
    getGroup = function()
      if not xPlayer then
        return 'user'
      end

      if type(xPlayer.getGroup) == 'function' then
        return xPlayer.getGroup()
      end

      return xPlayer.group or 'user'
    end,
  }
end

function vx.player.getIdentifier(playerId, keepPrefix, identifierType)
  identifierType = identifierType or 'license'

  local identifier = GetPlayerIdentifierByType(playerId, identifierType)

  if not identifier or identifier == '' then
    local count = GetNumPlayerIdentifiers(playerId) or 0

    for i = 0, count - 1 do
      local id = GetPlayerIdentifier(playerId, i)

      if id and id:sub(1, #identifierType + 1) == (identifierType .. ':') then
        identifier = id
        break
      end
    end
  end

  if not identifier then
    return nil
  end

  if keepPrefix then
    return identifier
  end

  return identifier:gsub('^' .. identifierType .. ':', '')
end

function vx.registerContextMenu(data)
  lib.registerContext(data)
  return data
end

function vx.openContextMenu(menu)
  local id = type(menu) == 'table' and menu.id or menu
  lib.showContext(id)
end

local proxyCount = 0

function vx.createCallbackProxy()
  proxyCount = proxyCount + 1

  local prefix = ('%s:proxy%d:'):format(GetCurrentResourceName(), proxyCount)
  local proxy = {}

  return setmetatable(proxy, {
    __newindex = function(self, key, value)
      rawset(self, key, value)

      if type(value) ~= 'function' then
        return
      end

      local event = prefix .. key

      if IsDuplicityVersion() then
        lib.callback.register(event, function(playerId, ...)
          return value(..., playerId)
        end)
      else
        lib.callback.register(event, function(...)
          return value(...)
        end)
      end
    end,

    __index = function(_, key)
      local event = prefix .. key

      return function(...)
        if IsDuplicityVersion() then
          local playerId = ...
          return lib.callback.await(event, playerId, select(2, ...))
        end

        return lib.callback.await(event, false, ...)
      end
    end,
  })
end
