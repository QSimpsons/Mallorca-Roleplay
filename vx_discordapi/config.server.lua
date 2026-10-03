ServerConfig = {}
ServerConfig.debug = false

-- Set in server.cfg: set discordToken "YOUR_BOT_TOKEN"
ServerConfig.token = GetConvar("discordToken", "none")
ServerConfig.guildId = GetConvar("discordGuildId", "1526967144636481616")

ServerConfig.refreshCommandEnabled = true
ServerConfig.refreshCommandCooldown = 60 * 1000 -- 1 minute
ServerConfig.refreshCommandName = "refreshDiscord"
