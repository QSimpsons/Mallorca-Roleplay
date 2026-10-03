ServerConfig = {}

-- Discord stays disabled until a bot token is configured.
-- Override with the discordToken / discordGuildId convars, or set these directly.
ServerConfig.token = GetConvar("discordToken", "none")
ServerConfig.guildId = GetConvar("discordGuildId", "")
ServerConfig.debug = false
ServerConfig.refreshCommandCooldown = 60000

ServerConfig.txHost = "http://localhost:3000"
ServerConfig.txUsername = "thoo0224"
ServerConfig.txPassword = "password"

ServerConfig.logger = {
   username = "Haarlem Roleplay Logs",
   avatarUrl = "https://cdn.discordapp.com/icons/1071583675243835464/a_ff24afb8837ba6c80f12908467de1a21.png",
   defaults = {
      includeAccounts = true
   },
   color = 0x1b4de3
}
