Config = {}

-- ═══════════════════════════════════════════════════════════════
-- Snelle Events · ESX Legacy · Mallorca Roleplay
-- ═══════════════════════════════════════════════════════════════

Config.Framework = 'esx'
Config.Notify = 'auto' -- ox_lib → ESX notify
Config.Locale = 'nl'

-- Aankondigingen
Config.AnnounceMethod = 'both' -- 'chat', 'notify', 'both'
Config.ChatPrefix = '[EVENT]'
Config.ChatColor = { 56, 189, 248 }

-- Routing buckets (aparte RP-wereld per event)
Config.UseRoutingBuckets = true
Config.RoutingBucketBase = 5000

-- RP gedrag
Config.StripWeaponsOnJoin = true
Config.DeleteEventVehicleOnLeave = true
Config.ReturnToPosition = true
Config.AllowDeadPlayers = false
Config.CleanupOnRestart = true
Config.MaxActiveEvents = 8
Config.DefaultCountdown = 10
Config.DefaultMinPlayers = 1
Config.DefaultZoneRadius = 80.0
Config.MarkerJoinDistance = 2.5
Config.OutOfBoundsWarnSeconds = 5
Config.InviteExpireSeconds = 60

-- Commando's
Config.Commands = {
    manage = 'event',
    join = 'joinevent',
    leave = 'eventleave',
    info = 'eventinfo',
    invite = 'eventinvite',
    spectate = 'eventspectate'
}

Config.Keys = {
    openPanel = 'F6'
}

-- Permissies
Config.Permissions = {
    aceManage = 'snelle-events.manage',
    aceHost = 'snelle-events.host',
    esxGroups = { 'admin', 'superadmin' },
    esxHostGroups = { 'mod' }
}

Config.AllowPublicHosting = false

-- Blips
Config.Blips = {
    enabled = true,
    sprite = 484,
    color = 5,
    scale = 0.9
}

-- Markers bij eventlocatie (E om te joinen)
Config.Markers = {
    enabled = true,
    type = 1,
    scale = { x = 1.5, y = 1.5, z = 1.0 },
    color = { r = 56, g = 189, b = 248, a = 180 },
    bobUpAndDown = true
}

-- Eventtypes
Config.EventTypes = {
    meetup = {
        label = 'Meetup / Verzameling',
        icon = 'users',
        description = 'Spelers verzamelen op een locatie voor een community event.',
        defaultMaxPlayers = 50,
        defaultMinPlayers = 1,
        allowWeapons = false,
        pvpEnabled = false,
        freezeOnStart = false,
        zoneRadius = 100.0,
        enforceZone = false
    },
    race = {
        label = 'Race',
        icon = 'flag',
        description = 'Race naar de finishlijn. Eerste over de streep wint.',
        defaultMaxPlayers = 16,
        defaultMinPlayers = 2,
        allowWeapons = false,
        pvpEnabled = false,
        freezeOnStart = true,
        vehicle = 'sultanrs',
        zoneRadius = 200.0,
        enforceZone = false,
        finishDistance = 8.0,
        -- Finish relatief t.o.v. start (of override via panel)
        finishOffset = { x = 0.0, y = 120.0, z = 0.0 }
    },
    pvp = {
        label = 'PvP / Redzone',
        icon = 'crosshair',
        description = 'Last man standing PvP in een afgesloten zone.',
        defaultMaxPlayers = 32,
        defaultMinPlayers = 2,
        allowWeapons = true,
        pvpEnabled = true,
        freezeOnStart = true,
        loadout = { 'WEAPON_PISTOL', 'WEAPON_SMG', 'WEAPON_ASSAULTRIFLE' },
        ammo = 250,
        zoneRadius = 60.0,
        enforceZone = true,
        autoWinner = true
    },
    derby = {
        label = 'Sumo / Derby',
        icon = 'car',
        description = 'Auto sumo derby — laatste voertuig overeind wint.',
        defaultMaxPlayers = 12,
        defaultMinPlayers = 2,
        allowWeapons = false,
        pvpEnabled = true,
        freezeOnStart = true,
        vehicle = 'blista',
        zoneRadius = 50.0,
        enforceZone = true,
        autoWinner = true
    },
    deathmatch = {
        label = 'Deathmatch',
        icon = 'skull',
        description = 'Timed deathmatch — meeste kills wint.',
        defaultMaxPlayers = 24,
        defaultMinPlayers = 2,
        allowWeapons = true,
        pvpEnabled = true,
        freezeOnStart = true,
        loadout = { 'WEAPON_PISTOL', 'WEAPON_MICROSMG', 'WEAPON_CARBINERIFLE' },
        ammo = 300,
        zoneRadius = 70.0,
        enforceZone = true,
        duration = 180,
        scoreToWin = 10,
        autoWinner = true
    },
    hunt = {
        label = 'Manhunt',
        icon = 'search',
        description = 'Eén target, rest is hunter. Target overleeft of hunters elimineren.',
        defaultMaxPlayers = 20,
        defaultMinPlayers = 3,
        allowWeapons = true,
        pvpEnabled = true,
        freezeOnStart = true,
        loadout = { 'WEAPON_PISTOL' },
        ammo = 100,
        zoneRadius = 150.0,
        enforceZone = true,
        duration = 300,
        autoWinner = true
    },
    hideandseek = {
        label = 'Hide & Seek',
        icon = 'eye',
        description = 'Verstoppertje — seekers zoeken hiders binnen de tijd.',
        defaultMaxPlayers = 24,
        defaultMinPlayers = 3,
        allowWeapons = false,
        pvpEnabled = false,
        freezeOnStart = true,
        zoneRadius = 120.0,
        enforceZone = true,
        duration = 240,
        autoWinner = true
    },
    party = {
        label = 'Feest / Party',
        icon = 'music',
        description = 'Feestevent met verzameling en sociale activiteiten.',
        defaultMaxPlayers = 40,
        defaultMinPlayers = 1,
        allowWeapons = false,
        pvpEnabled = false,
        freezeOnStart = false,
        zoneRadius = 80.0,
        enforceZone = false
    },
    parachute = {
        label = 'Parachute Drop',
        icon = 'plane',
        description = 'Spelers spawnen in de lucht met parachute.',
        defaultMaxPlayers = 20,
        defaultMinPlayers = 1,
        allowWeapons = false,
        pvpEnabled = false,
        freezeOnStart = false,
        dropHeight = 800.0,
        zoneRadius = 200.0,
        enforceZone = false
    },
    custom = {
        label = 'Custom Event',
        icon = 'star',
        description = 'Vrij instelbaar event voor staff.',
        defaultMaxPlayers = 64,
        defaultMinPlayers = 1,
        allowWeapons = false,
        pvpEnabled = false,
        freezeOnStart = false,
        zoneRadius = 100.0,
        enforceZone = false
    }
}

-- Voorgedefinieerde locaties
Config.PresetLocations = {
    { name = 'Pillbox Hill (Centrum)', coords = vector3(215.76, -810.12, 30.73), heading = 160.0 },
    { name = 'Maze Bank Arena', coords = vector3(-248.49, -2010.47, 30.15), heading = 70.0 },
    { name = 'Sandy Shores Airfield', coords = vector3(1747.02, 3273.72, 41.12), heading = 120.0 },
    { name = 'Paleto Bay Strand', coords = vector3(-160.0, 6432.0, 31.9), heading = 45.0 },
    { name = 'Vinewood Bowl', coords = vector3(686.0, 577.0, 130.46), heading = 0.0 },
    { name = 'Legion Square', coords = vector3(195.17, -933.77, 30.69), heading = 140.0 },
    { name = 'Mount Chiliad Top', coords = vector3(501.77, 5604.87, 797.91), heading = 0.0 },
    { name = 'Los Santos International', coords = vector3(-1037.68, -2737.95, 20.17), heading = 330.0 },
    { name = 'Observatory', coords = vector3(-425.48, 1123.49, 325.85), heading = 250.0 },
    { name = 'Dockyard', coords = vector3(120.0, -3100.0, 6.0), heading = 90.0 }
}

-- Beloningen via ESX
Config.Rewards = {
    enabled = true,
    winner = { money = 5000, account = 'money' },
    participant = { money = 500, account = 'money' },
    secondPlace = { money = 2500, account = 'money' },
    thirdPlace = { money = 1000, account = 'money' }
}

-- Discord webhook (leeg = uit)
Config.DiscordWebhook = ''
