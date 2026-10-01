Discord = {}

local function sendWebhookMessage(uri, type, message)
  if not uri or uri == '' then
    return
  end

  local data = {
    {
      ["color"] = 5763719,
      ["title"] = type .. " Logs",
      ["description"] = message,
      ["footer"] = {
        ["text"] = os.date("%x %X %p"),
      },
    }
  }

  PerformHttpRequest(uri,
    function(err, text, headers) end,
    'POST',
    json.encode({ username = type .. " Logs", embeds = data }),
    {
      ['Content-Type'] = 'application/json'
    })
end

---@param source number
---@param message string
function Discord.LogInformation(source, message)
  sendWebhookMessage(Config.Webhooks.CarLogs, "Car", string.format([[
    **Executed by**: %s
    **Target Name**: %s
    **Target Identifier**: %s
    %s]], GetPlayerName(source), message))
end

---@param source number
---@param target SrpPlayer
---@param message string
function Discord.LogCarInformation(source, target, message)
  sendWebhookMessage(Config.Webhooks.CarLogs, "Car", string.format([[
**Executed by**: %s
**Target Name**: %s
**Target Identifier**: %s
%s]], GetPlayerName(source), target.name, target.identifier, message))
end

---@param source number
---@param target SrpPlayer
---@param message string
function Discord.LogInventoryInformation(source, target, type, message)
  sendWebhookMessage(Config.Webhooks.InventoryLogs, "Inventory", string.format([[
**Executed by**: %s
**Target Name**: %s
**Target Identifier**: %s
**Type inventory**: %s
%s]], GetPlayerName(source), target.name, target.identifier, type, message))
end

---@param source number
---@param target SrpPlayer
---@param message string
function Discord.LogAccountInformation(source, target, message)
  sendWebhookMessage(Config.Webhooks.AccountLogs, "Account", string.format([[
**Executed by**: %s
**Target Name**: %s
**Target Identifier**: %s
%s]], GetPlayerName(source), target.name, target.identifier, message))
end
