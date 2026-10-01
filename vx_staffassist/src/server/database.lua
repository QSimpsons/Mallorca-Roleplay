database = {}

function database.GetTxPlayerData()
  local file = LoadResourceFile(GetCurrentResourceName(), "playersDB.json")
  return file and json.decode(file) or {}
end

function database.FindUserInDatabase(license)
  local data = database.GetTxPlayerData()

  if not data or not data.players then
    return nil
  end

  for _, player in pairs(data.players) do
    if player.license == license then
      return player
    end
  end

  return nil
end

---@param user SrpPlayer
---@return SrpVehicle | nil
function serverCallbackProxy.GetVehiclesFromPlayerIdentifier(user, source)
  if not GroupCheck(source) then
    vx.notify(source, { message = "You are not allowed to execute this trigger" })
    return nil
  end

  local query = MySQL.query.await(
    "SELECT plate, type, name, vehicle, glovebox, trunk FROM owned_vehicles WHERE owner = @owner", {
      ["@owner"] = user.identifier
    })

  if query == nil or #query == 0 or query[1] == nil then
    return nil
  end

  local data = {}
  for _, v in pairs(query) do
    local metadata = json.decode(v.vehicle)

    table.insert(data, {
      name = v.name and v.name or "Voertuig",
      type = v.type,
      plate = v.plate,
      hash = metadata.model,
      hasGlovebox = v.glovebox ~= nil,
      hasTrunk = v.trunk ~= nil
    })
  end

  return data
end

function serverCallbackProxy.GetVehicleFromPlate(plate, source)
  if not GroupCheck(source) then
    vx.notify(source, { message = "You are not allowed to execute this trigger" })
    return nil
  end

  local query = MySQL.query.await(
    "SELECT plate, type, name, vehicle, glovebox, trunk FROM owned_vehicles WHERE plate = @plate", {
      ["@plate"] = plate
    })

  if query == nil or #query == 0 or query[1] == nil then
    return nil
  end

  return query[1]
end

---@param user SrpPlayer
function serverCallbackProxy.GetPropertiesFromPlayerIdentifier(user, source)
  if not GroupCheck(source) then
    vx.notify(source, { message = "You are not allowed to execute this trigger" })
    return nil
  end

  local query = MySQL.query.await("SELECT id, name FROM owned_properties WHERE owner = @owner", {
    ["@owner"] = user.identifier
  })

  if query == nil or #query == 0 then
    return nil
  end

  return query
end

---@param user SrpPlayer
function serverCallbackProxy.GetLoodsenFromPlayerIdentifier(user, source)
  if not GroupCheck(source) then
    vx.notify(source, { message = "You are not allowed to execute this trigger" })
    return nil
  end

  local query = MySQL.query.await("SELECT id, property FROM vx_loodsen WHERE owner = @owner", {
    ["@owner"] = user.identifier
  })

  if query == nil or #query == 0 then
    return nil
  end

  return query
end
