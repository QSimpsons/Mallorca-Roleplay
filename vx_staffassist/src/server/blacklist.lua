Blacklist = {}

function LoadBlacklist()
  local file = LoadResourceFile(GetCurrentResourceName(), "blacklist.json")
  return file and json.decode(file) or {}
end

function SaveBlacklist(blacklist)
  SaveResourceFile(GetCurrentResourceName(), "blacklist.json", json.encode(blacklist, { indent = true }), -1)
  Blacklist.data = LoadBlacklist()
end

Blacklist.data = LoadBlacklist()

function Blacklist.AddUser(identifier, reason, source)
  local target = database.FindUserInDatabase(identifier)

  if target == nil then
    vx.notify(source, { message = "Speler bestaat niet!", type = "error" })
    return -1
  end

  local blacklistId = #Blacklist.data + 1
  local playerInfo = {
    blacklistId = blacklistId,
    targetName = target.pureName,
    reason = reason,
    date = os.date("%Y-%m-%d %H:%M:%S"),
    admin = GetPlayerName(source),
    identifiers = {
      steam = utils.getPlayerIdentifierFromTable(target.ids, true, "steam"),
      license = utils.getPlayerIdentifierFromTable(target.ids, true, "license"),
      discord = utils.getPlayerIdentifierFromTable(target.ids, true, "discord"),
      fivem = utils.getPlayerIdentifierFromTable(target.ids, true, "fivem"),
      tokens = target.hwids
    }
  }

  local targetId = utils.GetPlayerFromIdentifier(identifier)

  if targetId ~= nil then
    DropPlayer(targetId, "Je bent gekicked, (verbind opnieuw voor de details).")
  end

  table.insert(Blacklist.data, playerInfo)
  SaveBlacklist(Blacklist.data)
  vx.notify(source, { message = target.pureName .. " is blacklisted successfully!", type = "success" })
  return blacklistId
end

---@param blacklistId integer
function Blacklist.RemoveFromBlacklist(blacklistId)
  for i, data in ipairs(Blacklist.data) do
    if tostring(data.blacklistId) == tostring(blacklistId) then
      table.remove(Blacklist.data, i)
      SaveBlacklist(Blacklist.data)
      return true
    end
  end

  return false
end

vx.addCommand("vx_staffassist:unban", {
  restricted = "admin",
  params = {
    {
      name = "banId",
      type = "number"
    }
  }
}, function(_, args)
  Blacklist.RemoveFromBlacklist(args.banId)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
  local source = source
  deferrals.defer()
  deferrals.update('Checking blacklist...')

  local identifiers = {
    steam = GetPlayerIdentifier(source, 0),
    license = GetPlayerIdentifier(source, 1),
    discord = GetPlayerIdentifier(source, 2),
    fivem = GetPlayerIdentifier(source, 3),
    tokens = GetPlayerTokens(source)
  }

  for _, data in ipairs(Blacklist.data) do
    for idType, id in pairs(identifiers) do
      if idType == 'tokens' then
        for _, token in ipairs(identifiers.tokens) do
          for _, blacklistToken in ipairs(data.identifiers.tokens) do
            if token == blacklistToken then
              deferrals.done("[🚧] Je bent niet meer welkom! \n> Reden: " ..
              data.reason .. "\n> ID: " .. data.blacklistId .. "\n> Door: " .. data.admin)
              return
            end
          end
        end
      elseif id == data.identifiers[idType] then
        deferrals.done("[🚧] Je bent niet meer welkom! \n> Reden: " ..
          data.reason .. "\n> ID: " .. data.blacklistId .. "\n> Door: " .. data.admin)
        return
      end
    end
  end

  deferrals.done()
end)
