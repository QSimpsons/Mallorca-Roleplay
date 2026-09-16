Config = {}

-- ═══════════════════════════════════════════════════════════════
-- FiveM GTA Roleplay instellingen (Mallorca Roleplay / ESX / QBCore)
-- ═══════════════════════════════════════════════════════════════

-- Framework: ingesteld op ESX voor Mallorca Roleplay
Config.Framework = 'esx'

-- Notificaties: 'auto' = ox_lib (indien aanwezig) anders ESX notify
Config.Notify = 'auto'

-- Serverbrede aankondigingen: 'chat', 'notify', 'both'
Config.AnnounceMethod = 'both'

-- Chat prefix voor RP aankondigingen
Config.ChatPrefix = '[EVENT]'
Config.ChatColor = { 56, 189, 248 }

-- Routing buckets: isoleer event deelnemers in aparte wereld (aanbevolen voor RP)
Config.UseRoutingBuckets = true
Config.RoutingBucketBase = 5000

-- Wapens afnemen bij join (behalve PvP events)
Config.StripWeaponsOnJoin = true

-- Voertuig despawnen bij verlaten event
Config.DeleteEventVehicleOnLeave = true

-- Taal: 'nl' of 'en'
Config.Locale = 'nl'

-- Commando's
Config.Commands = {
    manage = 'event',
    join = 'eventjoin',
    leave = 'eventleave',
    info = 'eventinfo'
}

-- Toetsen
Config.Keys = {
    openPanel = 'F6' -- Alleen voor staff met permissie
}

-- Permissies (ACE of framework groepen)
Config.Permissions = {
    -- ACE permissies (server.cfg: add_ace group.admin snelle-events.manage allow)
    aceManage = 'snelle-events.manage',
    aceHost = 'snelle-events.host',

    -- ESX groepen met event-rechten (pas aan jouw server)
    esxGroups = { 'admin', 'superadmin' },
    esxHostGroups = { 'mod' } -- mod mag hosten, geen volledig beheer
}

-- Wie mag events hosten zonder admin-rechten
Config.AllowPublicHosting = false

-- Spelers terugzetten naar originele positie na event
Config.ReturnToPosition = true

-- Dode spelers mogen deelnemen
Config.AllowDeadPlayers = false

-- Automatisch oude events opruimen bij resource restart
Config.CleanupOnRestart = true

-- Maximale events tegelijk actief
Config.MaxActiveEvents = 5

-- Standaard countdown (seconden) voordat event start
Config.DefaultCountdown = 10

-- Blip instellingen
Config.Blips = {
    enabled = true,
    sprite = 484,
    color = 5,
    scale = 0.9
}

-- Eventtypes
Config.EventTypes = {
    meetup = {
        label = 'Meetup / Verzameling',
        icon = 'users',
        description = 'Spelers verzamelen op een locatie voor een community event.',
        defaultMaxPlayers = 50,
        allowWeapons = false,
        pvpEnabled = false,
        freezeOnStart = false
    },
    race = {
        label = 'Race',
        icon = 'flag',
        description = 'Race-event met voertuig spawn en finishlijn.',
        defaultMaxPlayers = 16,
        allowWeapons = false,
        pvpEnabled = false,
        freezeOnStart = true,
        vehicle = 'sultanrs'
    },
    pvp = {
        label = 'PvP / Redzone',
        icon = 'crosshair',
        description = 'Player vs Player gevecht in een afgesloten zone.',
        defaultMaxPlayers = 32,
        allowWeapons = true,
        pvpEnabled = true,
        freezeOnStart = true,
        loadout = {
            'WEAPON_PISTOL',
            'WEAPON_SMG',
            'WEAPON_ASSAULTRIFLE'
        },
        ammo = 250
    },
    derby = {
        label = 'Sumo / Derby',
        icon = 'car',
        description = 'Auto sumo derby - laatste voertuig wint.',
        defaultMaxPlayers = 12,
        allowWeapons = false,
        pvpEnabled = true,
        freezeOnStart = true,
        vehicle = 'blista'
    },
    party = {
        label = 'Feest / Party',
        icon = 'music',
        description = 'Feestevent met muziek, dansen en sociale activiteiten.',
        defaultMaxPlayers = 40,
        allowWeapons = false,
        pvpEnabled = false,
        freezeOnStart = false
    },
    custom = {
        label = 'Custom Event',
        icon = 'star',
        description = 'Vrij instelbaar event voor staff.',
        defaultMaxPlayers = 64,
        allowWeapons = false,
        pvpEnabled = false,
        freezeOnStart = false
    }
}

-- Voorgedefinieerde locaties (optioneel snel selecteren in panel)
Config.PresetLocations = {
    {
        name = 'Pillbox Hill (Centrum)',
        coords = vector3(215.76, -810.12, 30.73),
        heading = 160.0
    },
    {
        name = 'Maze Bank Arena',
        coords = vector3(-248.49, -2010.47, 30.15),
        heading = 70.0
    },
    {
        name = 'Sandy Shores Airfield',
        coords = vector3(1747.02, 3273.72, 41.12),
        heading = 120.0
    },
    {
        name = 'Paleto Bay Strand',
        coords = vector3(-160.0, 6432.0, 31.9),
        heading = 45.0
    },
    {
        name = 'Vinewood Bowl',
        coords = vector3(686.0, 577.0, 130.46),
        heading = 0.0
    }
}

-- Beloningen via ESX (addMoney / addAccountMoney)
Config.Rewards = {
    enabled = true,
    winner = {
        money = 5000,
        account = 'money' -- 'money' = cash, 'bank' = bankrekening
    },
    participant = {
        money = 500,
        account = 'money'
    }
}

-- Discord webhook voor event logs (leeg = uitgeschakeld)
Config.DiscordWebhook = ''
