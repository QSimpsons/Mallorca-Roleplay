local function generateLicensePlate()
   local plate = ""
   local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

   for i = 1, 8 do
      local rand = math.random(1, #chars)
      plate = plate .. chars:sub(rand, rand)
   end

   return plate
end

local function getAvailableLicensePlate()
   local attempts = 0
   while attempts < 50 do
      local plate = generateLicensePlate()
      local result = MySQL.query.await("SELECT plate FROM owned_vehicles WHERE plate = @plate", {
         ["@plate"] = plate
      })

      if not result[1] then
         return plate
      end

      attempts = attempts + 1
   end

   return nil
end

local function notifySender(source, type, message)
   if source > 0 then
      vx.notify(source, {
         message = message,
         type = type
      })
   else
      vx.print.info(message)
   end
end

vx.addCommand("givevehicle", {
   restricted = SharedConfig.restrictions,
   params = {
      {
         name = "playerId",
         help = "ID van de speler",
         type = "playerId"
      },
      {
         name = "type",
         help = string.format("[%s]", table.concat(SharedConfig.types, "/")),
         type = "string"
      },
      {
         name = "model",
         help = "Model van het voertuig",
         type = "string"
      },
      {
         name = "plate",
         help = "Kenteken van het voertuig",
         type = "string",
         optional = true
      }
   }
}, function(source, args)
   local licensePlate = args.plate or getAvailableLicensePlate()
   if not licensePlate then
      return notifySender(source, "error", "Kon geen kenteken genereren!")
   end

   local properties = clientCallbacks.getVehicleProperties(args.playerId, args.model, licensePlate)
   if not properties then
      return notifySender(source, "error", ("Ongeldig voertuigmodel: %s"):format(args.model))
   end
   local identifier = vx.player.getIdentifier(args.playerId, false, SharedConfig.identifier)
   local playerName = GetPlayerName(args.playerId)
   local result = MySQL.query.await(
      "INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (@owner, @plate, @vehicle, @type)",
      {
         ["@owner"] = identifier,
         ["@plate"] = properties.plate,
         ["@vehicle"] = json.encode(properties),
         ["@type"] = args.type
      })

   if result.affectedRows <= 0 then
      return vx.notify(source, {
         title = "Fout!",
         message = "Er is iets fout gegaan!"
      })
   end

   notifySender(source, "success",
      string.format("Je heb successvol een %s gegeven met kenteken %s aan %s", args.model, licensePlate, playerName))

   vx.notify(args.playerId, {
      title = "Success!",
      message = string.format("Je heb successvol een %s gekregen met kenteken %s", args.model, licensePlate),
      type = "success"
   })

   if ServerConfig.webhookUrl ~= "" then
      vx.sendWebhook(ServerConfig.webhookUrl, {
         embeds = {
            {
               title = "Give Vehicle",
               color = 0x00ff00,
               description = string.format("*Model*: %s\n*Kenteken*: %s\n*Type*: %s", args.model, licensePlate,
                  args.type),
               fields = {
                  {
                     name = "Gegeven door",
                     value = source > 0 and
                         string.format("**Speler Naam**:%s\n**Speler ID**: %s\n**License**: %s", GetPlayerName(source),
                            source, vx.player.getIdentifier(source, false, "license")) or "Console",
                     inline = false
                  },
                  {
                     name = "Gegeven aan",
                     value = string.format("**Speler Naam**:%s\n**Speler ID**: %s\n**License**: %s", playerName,
                        args.playerId, identifier),
                     inline = false
                  }
               }
            }
         }
      })
   end
end)
