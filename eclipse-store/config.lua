Config = {}

-- Tebex Public Token (Creators → Integrations → API Keys → Public Token).
-- Zonder geldige token toont /store een lokale demo-catalogus.
Config.PublicToken = 'YOUR_PUBLIC_TOKEN'

-- Optionele fallback-URL naar je webstore (opent in de browser).
Config.StoreUrl = 'https://eclipserp.tebex.io'

-- Merktekst in de NUI (wordt overschreven door Tebex store.name als beschikbaar).
Config.StoreName = 'Eclipse Store'
Config.ServerName = 'ECLIPSE RP'

Config.DiscordUrl = 'https://discord.gg/eclipserp'
Config.DiscordMembers = 'Discord Community'

Config.Banner = {
    'Nieuwe Producten',
    'Direct Ontvangen',
    'Betalen via Tebex',
}

-- Chatcommando om de store te openen.
Config.Command = 'store'
Config.OpenKey = nil -- bijv. 'F7' of nil om uit te zetten

-- Categorie-naam die de NEW-badge krijgt (leeg = eerste categorie).
Config.NewBadgeCategory = 'Coins'

-- Return-URL na Tebex-login (mag een willekeurige https-pagina zijn).
Config.AuthReturnUrl = 'https://eclipserp.nl/store-auth'

-- Cache categorieën/pakketten (seconden).
Config.CatalogCacheSeconds = 60

-- true = print debug naar server/client console.
Config.Debug = false

--[[
  Optionele lokale demo-catalogus als PublicToken nog niet is ingevuld.
  Vervang dit door echte Tebex-pakketten zodra de token werkt.
]]
Config.DemoCatalog = {
    {
        id = 'coins',
        name = 'Coins',
        description = 'Met deze coins kan je packs kopen via /store in game.',
        packages = {
            { id = 'demo-600', ident = 'demo-600', name = '600 Coins', description = 'Met deze coins kan je packs kopen via /store in game.', total_price = 400.49, currency = 'EUR', image = nil },
            { id = 'demo-300', ident = 'demo-300', name = '300 Coins', description = 'Met deze coins kan je packs kopen via /store in game.', total_price = 224.99, currency = 'EUR', image = nil },
            { id = 'demo-150', ident = 'demo-150', name = '150 Coins', description = 'Met deze coins kan je packs kopen via /store in game.', total_price = 112.49, currency = 'EUR', image = nil },
            { id = 'demo-100', ident = 'demo-100', name = '100 Coins', description = 'Met deze coins kan je packs kopen via /store in game.', total_price = 80.99, currency = 'EUR', image = nil },
            { id = 'demo-75', ident = 'demo-75', name = '75 Coins', description = 'Met deze coins kan je packs kopen via /store in game.', total_price = 60.74, currency = 'EUR', image = nil },
            { id = 'demo-50', ident = 'demo-50', name = '50 Coins', description = 'Met deze coins kan je packs kopen via /store in game.', total_price = 40.49, currency = 'EUR', image = nil },
            { id = 'demo-25', ident = 'demo-25', name = '25 Coins', description = 'Met deze coins kan je packs kopen via /store in game.', total_price = 22.49, currency = 'EUR', image = nil },
            { id = 'demo-10', ident = 'demo-10', name = '10 Coins', description = 'Met deze coins kan je packs kopen via /store in game.', total_price = 9.99, currency = 'EUR', image = nil },
        },
    },
    {
        id = 'unbans',
        name = 'Unbans',
        description = 'Koop een unban veilig via Tebex.',
        packages = {
            { id = 'demo-unban', ident = 'demo-unban', name = 'Unban', description = 'Eenmalige unban voor je account.', total_price = 25.00, currency = 'EUR', image = nil },
        },
    },
    {
        id = 'vip',
        name = 'VIP',
        description = 'VIP ranks en voordelen.',
        packages = {
            { id = 'demo-vip', ident = 'demo-vip', name = 'VIP', description = 'VIP rank voor Eclipse RP.', total_price = 14.99, currency = 'EUR', image = nil },
        },
    },
}