Config = Config or {}

-- Plak hier je eigen Discord webhook URLs. Leeg laten = geen logs.
Config.Webhooks = {
  AccountLogs = "",
  InventoryLogs = "",
  CarLogs = "",
}

-- Voor database
---@type VxTableRow[]
Config.Tables = {
  { key = "identifier", type = "steam",   keepPrefix = true,  table = "vx_tebexwrapper_coins", },
  { key = "identifier", type = "license", keepPrefix = false, table = "banking" },
  { key = "identifier", type = "license", keepPrefix = false, table = "users" },
  { key = "owner",      type = "license", keepPrefix = false, table = "ox_inventory" },
  { key = "owner",      type = "license", keepPrefix = false, table = "owned_properties" },
  { key = "owner",      type = "license", keepPrefix = false, table = "owned_vehicles" },
  { key = "owner",      type = "license", keepPrefix = false, table = "vx_loodsen" },
  { key = "owner",      type = "license", keepPrefix = false, table = "addon_account_data" },
  { key = "owner",      type = "license", keepPrefix = false, table = "datastore_data" },
  { key = "owner",      type = "license", keepPrefix = false, table = "user_licenses" },
  { key = "soldby",     type = "license", keepPrefix = false, table = "vehicle_sold" },
}