Config = {}

-- ═══════════════════════════════════════════════════════════════
-- Eclipse Politie Garage · ESX Legacy
-- Licht NUI-menu met categorieën, zoeken, favorieten en spawn.
-- ═══════════════════════════════════════════════════════════════

Config.Debug = false
Config.Locale = 'nl'

-- Job die de garage mag openen (ook off-duty job wordt geblokkeerd tenzij AllowOffDuty).
Config.JobName = 'police'
Config.AllowOffDuty = false
Config.OffJobName = 'offpolice'

-- Minimum grade om überhaupt de garage te openen.
Config.MinGrade = 1

-- In het voertuig zetten na spawn.
Config.WarpIntoVehicle = true

-- Spawn-cooldown in ms (anti-spam).
Config.SpawnCooldown = 2500

-- Max afstand tot een spawnpoint (OneSync / ESX client-spawn limiet).
-- Verder weg → spawn voor de speler i.p.v. Mission Row-coords.
Config.MaxSpawnDistance = 80.0

-- Marker / interactie
Config.MarkerDistance = 28.0
Config.InteractDistance = 2.2
Config.StoreDistance = 8.0

-- Sleutels: resource-export of event. 'none' slaat over.
-- Bekende systemen: jg-givekey, wasabi_carlock, qs-vehiclekeys, vehicles_keys
Config.Keys = {
    system = 'auto', -- auto | none | event
    event = 'vehiclekeys:client:SetOwner',
    resource = nil, -- bv. 'jg-givekey'
}

Config.Fuel = {
    resource = 'jg-benzine', -- of nil / 'ox_fuel' / 'LegacyFuel'
    default = 100.0
}

Config.Plate = {
    prefix = 'POL',
    digits = 3
}

Config.VehicleExtras = {
    livery = 0,
    extras = { [1] = true, [2] = true, [3] = true }
}

Config.Commands = {
    open = 'politiegarage', -- /politiegarage (debug / admin test)
    store = 'parkeerpd'
}

Config.KeysBind = {
    openHint = 'E',
    storeHint = 'E'
}

Config.Text = {
    open = 'Druk op ~INPUT_CONTEXT~ om de politiegarage te openen',
    store = 'Druk op ~INPUT_CONTEXT~ om het dienstvoertuig te parkeren',
    spawned = 'Dienstvoertuig staat klaar.',
    stored = 'Voertuig geparkeerd.',
    blocked = 'De uitrijplaats is geblokkeerd.',
    noJob = 'Alleen politie in dienst kan de garage gebruiken.',
    noGrade = 'Je rang mag deze garage nog niet gebruiken.',
    noPerm = 'Je hebt geen toegang tot dit voertuig.',
    modelFail = 'Dit voertuig kon niet geladen worden.',
    cooldown = 'Wacht even voor je opnieuw spawnt.',
    notDriver = 'Je moet op de bestuurdersstoel zitten.',
    noVehicle = 'Je zit niet in een voertuig.',
}

Config.Blip = {
    enabled = true,
    sprite = 357,
    colour = 29,
    scale = 0.75,
    label = 'Politiegarage'
}

Config.Marker = {
    type = 36,
    r = 30,
    g = 90,
    b = 180,
    a = 160,
    scale = 0.55
}

-- Thumbnails: FiveM docs CDN. Override per voertuig met image = 'nui://...' of https://...
Config.ImageBase = 'https://docs.fivem.net/vehicles/%s.webp'

------------------------------------------------------------------------
-- Sidebar-categorieën (id moet uniek zijn)
-- icon: star | radio | car | ghost | bike | air | shield | armor | heart
------------------------------------------------------------------------
Config.Categories = {
    { id = 'favorites', label = 'Favorieten',   icon = 'star',   special = 'favorites' },
    { id = 'patrol',    label = 'Patrouille',   icon = 'car' },
    { id = 'unmarked',  label = 'Onopvallend',  icon = 'ghost' },
    { id = 'motor',     label = 'Motor',        icon = 'bike' },
    { id = 'special',   label = 'Speciale eenheid', icon = 'shield' },
    { id = 'air',       label = 'Luchtsteun',   icon = 'air' },
}

------------------------------------------------------------------------
-- Locaties (pas coords aan naar jullie MLO)
------------------------------------------------------------------------
Config.Garages = {
    {
        id = 'mission_row',
        label = 'Politiegarage',
        coords = vector3(452.6, -1017.4, 28.5),
        deleteCoords = vector3(452.6, -1014.4, 28.5),
        minGrade = 1,
        -- Leeg = alle categorieën behalve special/air filters via vehicles zelf
        categories = nil,
        spawnPoints = {
            vector4(446.0, -1025.5, 28.6, 5.0),
            vector4(442.4, -1025.8, 28.7, 5.0),
            vector4(438.7, -1026.0, 28.8, 5.0),
        },
    },
    {
        id = 'heli_pad',
        label = 'Luchtsteun',
        coords = vector3(449.2, -981.4, 43.69),
        deleteCoords = vector3(449.2, -981.4, 43.69),
        minGrade = 6,
        categories = { 'favorites', 'air' },
        spawnPoints = {
            vector4(449.2, -981.4, 43.69, 90.0),
        },
        blip = false,
    },
}

------------------------------------------------------------------------
-- Stats: 0–100 (UI progress bars)
-- category = sidebar-id
------------------------------------------------------------------------
Config.Vehicles = {
    {
        id = 'police',
        label = 'Politie Cruiser',
        model = 'police',
        category = 'patrol',
        minGrade = 1,
        badge = 'PATROUILLE',
        stats = { speed = 72, accel = 68, brake = 70, handling = 74 },
    },
    {
        id = 'police2',
        label = 'Politie Buffalo',
        model = 'police2',
        category = 'patrol',
        minGrade = 1,
        badge = 'PATROUILLE',
        stats = { speed = 78, accel = 74, brake = 72, handling = 76 },
    },
    {
        id = 'police3',
        label = 'Politie Interceptor',
        model = 'police3',
        category = 'patrol',
        minGrade = 2,
        badge = 'PATROUILLE',
        stats = { speed = 82, accel = 80, brake = 74, handling = 78 },
    },
    {
        id = 'police4',
        label = 'Onopvallende Sedan',
        model = 'police4',
        category = 'unmarked',
        minGrade = 4,
        badge = 'ONOPVALLEND',
        stats = { speed = 76, accel = 70, brake = 68, handling = 72 },
    },
    {
        id = 'fbi',
        label = 'Onopvallende Buffalo',
        model = 'fbi',
        category = 'unmarked',
        minGrade = 5,
        badge = 'ONOPVALLEND',
        stats = { speed = 80, accel = 76, brake = 70, handling = 74 },
    },
    {
        id = 'fbi2',
        label = 'Onopvallende SUV',
        model = 'fbi2',
        category = 'unmarked',
        minGrade = 5,
        badge = 'ONOPVALLEND',
        stats = { speed = 74, accel = 68, brake = 72, handling = 70 },
    },
    {
        id = 'policeb',
        label = 'Politie Motor',
        model = 'policeb',
        category = 'motor',
        minGrade = 3,
        badge = 'MOTOR',
        stats = { speed = 88, accel = 90, brake = 78, handling = 86 },
    },
    {
        id = 'riot',
        label = 'ME-wagen',
        model = 'riot',
        category = 'special',
        minGrade = 6,
        badge = 'SPECIAAL',
        stats = { speed = 55, accel = 48, brake = 62, handling = 50 },
    },
    {
        id = 'policet',
        label = 'Transporter',
        model = 'policet',
        category = 'special',
        minGrade = 6,
        badge = 'SPECIAAL',
        stats = { speed = 62, accel = 55, brake = 66, handling = 58 },
    },
    {
        id = 'riot2',
        label = 'Panservoertuig',
        model = 'riot2',
        category = 'special',
        minGrade = 8,
        badge = 'RANG',
        stats = { speed = 50, accel = 42, brake = 60, handling = 46 },
    },
    {
        id = 'polmav',
        label = 'Politieheli',
        model = 'polmav',
        category = 'air',
        minGrade = 6,
        badge = 'LUCHT',
        stats = { speed = 90, accel = 70, brake = 65, handling = 80 },
    },
}
