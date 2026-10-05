--[[
  QBCore item — plak in qb-core/shared/items.lua

  ebike = {
      name = 'ebike',
      label = 'E-bike',
      weight = 1000,
      type = 'item',
      image = 'ebike.png',
      unique = true,
      useable = true,
      shouldClose = true,
      combinable = nil,
      description = 'Opvouwbare elektrische fatbike'
  },
]]

--[[
  ox_inventory item — plak in ox_inventory/data/items.lua

  ['ebike'] = {
      label = 'E-bike',
      weight = 1000,
      stack = false,
      close = true,
      description = 'Opvouwbare elektrische fatbike',
      client = {
          event = 'snelle-ebike:client:useItem'
      }
  },
]]
