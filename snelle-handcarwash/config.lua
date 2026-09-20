Config = {}

-- ═══════════════════════════════════════════════════════════════
-- Snelle Handcarwash · ESX Legacy
-- Overal met de hand wassen als je de juiste items hebt.
-- ═══════════════════════════════════════════════════════════════

Config.Locale = 'nl'
Config.Notify = 'auto'       -- 'auto' | 'ox_lib' | 'esx'
Config.Target = 'auto'       -- 'auto' | 'ox_target' | 'qtarget' | 'none'
Config.Progress = 'auto'     -- 'auto' | 'ox_lib' | 'native'
Config.Inventory = 'auto'    -- 'auto' | 'ox_inventory' | 'esx'
Config.TextUI = 'auto'       -- 'auto' | 'ox_lib' | 'esx'

-- Account waarmee de winkel betaald wordt (ESX Legacy: 'money' of 'bank')
Config.PayAccount = 'money'

-- ═══════════════════════════════════════════════════════════════
-- Items  (namen moeten 1-op-1 overeenkomen met SQL / ox_inventory)
-- ═══════════════════════════════════════════════════════════════

Config.Items = {
    emptyBucket   = 'empty_bucket',
    waterBucket   = 'water_bucket',
    sponge        = 'car_sponge',
    soap          = 'car_soap',
    cloth         = 'microfiber_cloth',
    wax           = 'car_wax',
    tireCleaner   = 'tire_cleaner',
    kit           = 'hand_carwash_kit'
}

-- ═══════════════════════════════════════════════════════════════
-- Was-opties
-- consume = item wordt na een geslaagde was verwijderd
-- give    = item dat je terugkrijgt (volle emmer → lege emmer)
-- ═══════════════════════════════════════════════════════════════

Config.WashTypes = {
    basic = {
        label = 'Basis handwas',
        description = 'Spons, shampoo en een emmer water',
        duration = 14000,
        dirtLevel = 0.12,
        waxed = false,
        cleanTires = false,
        items = {
            { name = 'car_sponge',     count = 1, consume = false },
            { name = 'car_soap',       count = 1, consume = true },
            { name = 'water_bucket',   count = 1, consume = true, give = 'empty_bucket' }
        }
    },
    complete = {
        label = 'Complete handwas',
        description = 'Wassen + afdrogen met microvezeldoek',
        duration = 18000,
        dirtLevel = 0.02,
        waxed = false,
        cleanTires = false,
        items = {
            { name = 'car_sponge',       count = 1, consume = false },
            { name = 'car_soap',         count = 1, consume = true },
            { name = 'water_bucket',     count = 1, consume = true, give = 'empty_bucket' },
            { name = 'microfiber_cloth', count = 1, consume = true }
        }
    },
    premium = {
        label = 'Premium was + wax',
        description = 'Complete was, velgen en een laag wax',
        duration = 24000,
        dirtLevel = 0.0,
        waxed = true,
        cleanTires = true,
        items = {
            { name = 'car_sponge',       count = 1, consume = false },
            { name = 'car_soap',         count = 1, consume = true },
            { name = 'water_bucket',     count = 1, consume = true, give = 'empty_bucket' },
            { name = 'microfiber_cloth', count = 1, consume = true },
            { name = 'car_wax',          count = 1, consume = true },
            { name = 'tire_cleaner',     count = 1, consume = true }
        }
    },
    tires = {
        label = 'Alleen velgen',
        description = 'Velgenreiniger op de banden/velgen',
        duration = 8000,
        dirtLevel = nil, -- vuil op de carrosserie blijft
        waxed = false,
        cleanTires = true,
        items = {
            { name = 'tire_cleaner', count = 1, consume = true },
            { name = 'car_sponge',   count = 1, consume = false }
        }
    },
    kit = {
        label = 'Handwas set',
        description = 'Alles-in-één set: wassen, drogen, waxen',
        duration = 20000,
        dirtLevel = 0.0,
        waxed = true,
        cleanTires = true,
        items = {
            { name = 'hand_carwash_kit', count = 1, consume = true }
        }
    },
    wax = {
        label = 'Alleen waxen',
        description = 'Waxlaag op een (bijna) schone auto',
        duration = 10000,
        dirtLevel = 0.0,
        waxed = true,
        cleanTires = false,
        items = {
            { name = 'car_wax',          count = 1, consume = true },
            { name = 'microfiber_cloth', count = 1, consume = true }
        }
    }
}

-- Welke was-optie start bij welk usable item
Config.ItemToWashType = {
    car_sponge       = nil,          -- opent het was-menu
    hand_carwash_kit = 'kit',
    car_wax          = 'wax',
    microfiber_cloth = nil,          -- opent het was-menu
    tire_cleaner     = 'tires',
    car_soap         = nil,          -- opent het was-menu
    water_bucket     = nil           -- opent het was-menu
}

-- ═══════════════════════════════════════════════════════════════
-- Was-gedrag
-- ═══════════════════════════════════════════════════════════════

Config.Wash = {
    maxDistance = 3.2,
    requireOutOfVehicle = true,
    requireEngineOff = false,
    minDirtLevel = 0.05,          -- schoner dan dit = al schoon (behalve wax/velgen)
    cancelOnMove = true,
    disableCombat = true,
    headingToVehicle = true,      -- kijk naar het voertuig tijdens het wassen
    waxDurationMinutes = 45,      -- hoe lang wax vuil tegengaat (0 = uit)
    cooldownSeconds = 8
}

-- ═══════════════════════════════════════════════════════════════
-- Emmer vullen
-- ═══════════════════════════════════════════════════════════════

Config.Water = {
    fillDuration = 6000,
    allowNaturalWater = true,     -- zee / rivier / zwembad
    interactDistance = 2.0,
    -- Extra kranen / slangpunten (naast de winkels hieronder)
    taps = {
        vector3(26.15, -1391.95, 29.36),
        vector3(-699.62, -932.70, 19.01),
        vector3(167.10, -1719.30, 29.29),
        vector3(-216.50, 6199.90, 31.49)
    }
}

-- ═══════════════════════════════════════════════════════════════
-- Winkels (handwas-benodigdheden)
-- ═══════════════════════════════════════════════════════════════

Config.Shop = {
    enabled = true,
    interactDistance = 2.2,
    marker = {
        enabled = true,
        type = 29,
        size = vector3(0.35, 0.35, 0.35),
        color = { r = 56, g = 189, b = 248, a = 180 },
        bobUpAndDown = true,
        rotate = true
    },
    blip = {
        enabled = true,
        sprite = 100,
        color = 3,
        scale = 0.75,
        label = 'Handwas winkel'
    },
    ped = {
        enabled = true,
        model = `s_m_m_autoshop_02`,
        scenario = 'WORLD_HUMAN_CLIPBOARD'
    },
    items = {
        { name = 'empty_bucket',     price = 45,  amount = 1 },
        { name = 'car_sponge',       price = 25,  amount = 1 },
        { name = 'car_soap',         price = 20,  amount = 1 },
        { name = 'microfiber_cloth', price = 18,  amount = 1 },
        { name = 'car_wax',          price = 55,  amount = 1 },
        { name = 'tire_cleaner',     price = 30,  amount = 1 },
        { name = 'hand_carwash_kit', price = 150, amount = 1 }
    }
}

Config.Shops = {
    {
        name = 'Strawberry Handwas',
        coords = vector3(31.48, -1394.12, 29.36),
        pedHeading = 270.0
    },
    {
        name = 'Little Seoul Handwas',
        coords = vector3(-702.85, -925.40, 19.01),
        pedHeading = 180.0
    },
    {
        name = 'Davis Handwas',
        coords = vector3(169.82, -1716.55, 29.29),
        pedHeading = 140.0
    },
    {
        name = 'Paleto Handwas',
        coords = vector3(-215.12, 6202.40, 31.49),
        pedHeading = 45.0
    }
}

-- ═══════════════════════════════════════════════════════════════
-- Commando (optioneel, items zijn nog steeds verplicht)
-- ═══════════════════════════════════════════════════════════════

Config.Command = {
    enabled = true,
    name = 'handwas',
    suggestion = 'Was het dichtstbijzijnde voertuig met de hand'
}

-- Debug prints in F8 / server console
Config.Debug = false
