local WEBHOOK_URL = "https://discord.com/api/webhooks/1399016619736567969/aHV3V49UbR4xX1hLppzwU1jvDRP50dDPDB-iXXlb--dFsoUF--zm3HEB89C3Tbo0PON6"
local blacklistedHashes = vx.array:new()

Citizen.CreateThread(function()
  blacklistedHashes = SharedConfig.blacklist:map(function(model)
    return joaat(model)
  end)
end)

vx.addCommand("geefsleutels", {
  help = "Zet je auto op iemand zijn naam",
  params = {
    {
      name = "playerId",
      type = "playerId",
      label = "Speler ID"
    }
  }
}, function(source, args)
  local ped = GetPlayerPed(source)
  local targetPed = GetPlayerPed(args.playerId)

  local pedCoords = GetEntityCoords(ped)
  local targetCoords = GetEntityCoords(targetPed)
  local distance = #(pedCoords - targetCoords)
  if distance > 5 then
    return vx.notify(source, {
      title = "Fout!",
      message = "De speler is niet dichtbij genoeg!",
      type = "error"
    })
  end

  local vehicle = GetVehiclePedIsIn(ped, false)
  if not vehicle or vehicle == 0 then
    return vx.notify(source, {
      title = "Fout!",
      message = "Je moet in een voertuig zitten!",
      type = "error"
    })
  end

  local model = GetEntityModel(vehicle)
  if blacklistedHashes:contains(model) then
    return vx.notify(source, {
      title = "Fout!",
      message = "Dit voertuig kan je niet overschrijven!",
      type = "error"
    })
  end

  local identifier = vx.player.getIdentifier(source, false, "license")
  local targetIdentifier = vx.player.getIdentifier(args.playerId, false, "license")
  local plate = GetVehicleNumberPlateText(vehicle)

  local result = MySQL.query.await(
    "UPDATE owned_vehicles SET owner = @newOwner WHERE owner = @owner AND plate = @plate", {
      ["@newOwner"] = targetIdentifier,
      ["@owner"] = identifier,
      ["@plate"] = plate
    })

  if result.affectedRows < 1 then
    return vx.notify(source, {
      title = "Fout!",
      message = "Dit is niet jouw voertuig!",
      type = "error"
    })
  end

  local sourceName = GetPlayerName(source)
  local targetName = GetPlayerName(args.playerId)
  local tijd = os.date('%d-%m-%Y %H:%M:%S')

  local webhookUrl = (type(ServerConfig) == "table" and ServerConfig.webhookUrl) or WEBHOOK_URL

  vx.sendWebhook(webhookUrl, {
    embeds = {{
      title = "Voertuig Overgeschreven",
      color = 0x00ff00,
      description = string.format("*Kenteken*: %s\n*Tijdstip*: %s", plate, tijd),
      fields = {
        {
          name = "Gegeven door",
          value = source > 0 and string.format(
            "**Speler Naam**: %s\n**Speler ID**: %s\n**License**: %s",
            sourceName, source, identifier
          ) or "Console",
          inline = false
        },
        {
          name = "Gegeven aan",
          value = string.format(
            "**Speler Naam**: %s\n**Speler ID**: %s\n**License**: %s",
            targetName, args.playerId, targetIdentifier
          ),
          inline = false
        }
      }
    }}
  })

  vx.notify(source, {
    title = "Success!",
    message = "Je hebt het voertuig succesvol overgeschreven!",
    type = "success"
  })

  vx.notify(args.playerId, {
    title = "Success!",
    message = string.format("Je hebt een voertuig met kenteken %s ontvangen!", plate),
    type = "success"
  })
end)