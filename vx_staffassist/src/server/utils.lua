utils = {}

---@param identifier string
---@return string | nil
function utils.GetPlayerFromIdentifier(identifier)
  local esx = ensureESX()

  for _, ids in pairs(GetPlayers()) do
    local target = vx.player.getIdentifier(ids, false, "license")
    local prefixed = vx.player.getIdentifier(ids, true, "license")

    if target == identifier or prefixed == identifier then
      return ids
    end

    if esx then
      local xPlayer = esx.GetPlayerFromId(tonumber(ids) or ids)

      if xPlayer and xPlayer.identifier == identifier then
        return ids
      end
    end
  end

  return nil
end

---@param identifier string
---@return boolean
function utils.isPlayerOnline(identifier)
  local id = utils.GetPlayerFromIdentifier(identifier)

  if id ~= nil then
    return true
  end

  return false
end

---@param source integer
---@param vehicle SrpVehicle
function utils.spawnGhostVehicleAsync(source, vehicle)
  local ped = GetPlayerPed(source)
  local coords = GetEntityCoords(ped)

  local vehicleId = CreateVehicle(vehicle.hash,
    coords.x, coords.y, coords.z,
    0.0, true, false);

  SetVehicleNumberPlateText(vehicleId, vehicle.plate)

  while not DoesEntityExist(vehicleId) do
    Citizen.Wait(1)
  end

  -- SetEntityVisible(vehicleId, false, false)

  return vehicleId
end

---@param table string[]
---@param keepPrefix boolean
---@param type string
---@return string | nil
function utils.getPlayerIdentifierFromTable(table, keepPrefix, type)
  for _, id in pairs(table) do
    local idType, idValue = string.match(id, "([^:]+):([^:]+)")

    if idType == type then
      return keepPrefix and id or idValue
    end
  end

  return nil
end
