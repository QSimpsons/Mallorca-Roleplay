Config = {}

Config.ServerName = 'ECLIPSE RP'

-- Zet hier de echte uitnodiging van de server.
Config.Discord = 'https://discord.gg/eclipserp'
Config.Rules = 'https://discord.gg/eclipserp'

-- Datum die naar esx_identity gaat. Gebruik hetzelfde formaat als in esx_identity/config.lua.
-- DD/MM/YYYY | DD-MM-YYYY | MM/DD/YYYY | YYYY-MM-DD
Config.DateFormat = 'DD/MM/YYYY'

Config.MinNameLength = 2
Config.MaxNameLength = 16
Config.MinHeight = 120
Config.MaxHeight = 220
Config.MinAge = 18
Config.MaxAge = 100

-- true = opslaan via esx_identity als die resource draait.
-- false = zelf wegschrijven in de ESX users-tabel.
Config.UseEsxIdentity = true

-- Opnieuw openen als de registratie nog niet af is.
Config.Command = 'identiteit'

Config.Debug = false
