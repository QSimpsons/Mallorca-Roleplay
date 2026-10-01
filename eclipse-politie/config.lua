Config = {}

Config.Locale = 'nl'
Config.JobName = 'police'
Config.OffJobName = 'offpolice'
Config.Society = 'society_police'

-- True = ox_lib notify, false = ESX notify
Config.UseOxLibNotify = true

------------------------------------------------------------------------
-- 10 Nederlandse politierangen (laag → hoog)
-- grade 1 = Aspirant  …  grade 10 = Eerste hoofdcommissaris (boss)
------------------------------------------------------------------------
Config.Grades = {
    [1]  = { name = 'aspirant',                 label = 'Aspirant',                 salary = 250,  boss = false },
    [2]  = { name = 'surveillant',              label = 'Surveillant van politie',  salary = 350,  boss = false },
    [3]  = { name = 'agent',                    label = 'Agent',                    salary = 450,  boss = false },
    [4]  = { name = 'hoofdagent',               label = 'Hoofdagent',               salary = 550,  boss = false },
    [5]  = { name = 'brigadier',                label = 'Brigadier',                salary = 650,  boss = false },
    [6]  = { name = 'inspecteur',               label = 'Inspecteur',               salary = 800,  boss = false },
    [7]  = { name = 'hoofdinspecteur',          label = 'Hoofdinspecteur',          salary = 950,  boss = false },
    [8]  = { name = 'commissaris',              label = 'Commissaris',              salary = 1100, boss = false },
    [9]  = { name = 'hoofdcommissaris',         label = 'Hoofdcommissaris',         salary = 1300, boss = true  },
    [10] = { name = 'eerste_hoofdcommissaris',  label = 'Eerste hoofdcommissaris',  salary = 1600, boss = true  },
}

-- Minimum grade per actie
Config.MinGrade = {
    armory        = 1,  -- aspirant
    garage        = 1,
    cloakroom     = 1,
    cuff          = 2,  -- surveillant+
    escort        = 2,
    vehicle       = 2,
    search        = 2,
    fine          = 3,  -- agent+
    id            = 1,
    license       = 5,  -- brigadier+
    impound       = 4,  -- hoofdagent+
    boss          = 9,  -- hoofdcommissaris+
    heli          = 6,  -- inspecteur+
    heavy_weapons = 5,  -- brigadier+
}

Config.Keys = {
    actions = 'F6',
}

Config.Blip = {
    enabled = true,
    coords  = vector3(425.1, -979.5, 30.7),
    sprite  = 60,
    colour  = 29,
    scale   = 0.9,
    label   = 'Politiebureau',
}

Config.Markers = {
    type = 1,
    size = vec3(1.2, 1.2, 0.6),
    colour = { r = 0, g = 90, b = 180, a = 120 },
    bob = false,
    face = false,
    drawDistance = 18.0,
    interactDistance = 1.6,
}

------------------------------------------------------------------------
-- Locaties (Mission Row PD – pas aan naar jullie MLO)
------------------------------------------------------------------------
Config.Locations = {
    duty = {
        { coords = vector3(441.0, -981.9, 30.69), label = 'In-/uitklokken' },
    },
    cloakroom = {
        { coords = vector3(452.6, -992.8, 30.69), label = 'Omkleedkamer', minGrade = 1 },
    },
    armory = {
        { coords = vector3(452.6, -980.0, 30.69), label = 'Wapenkamer', minGrade = 1 },
    },
    boss = {
        { coords = vector3(448.4, -973.2, 30.69), label = 'Korpsleiding', minGrade = 9 },
    },
    garage = {
        {
            coords = vector3(452.6, -1017.4, 28.5),
            label = 'Garage',
            minGrade = 1,
            spawnPoints = {
                vector4(446.0, -1025.5, 28.6, 5.0),
                vector4(442.4, -1025.8, 28.7, 5.0),
                vector4(438.7, -1026.0, 28.8, 5.0),
            },
            deleteCoords = vector3(452.6, -1014.4, 28.5),
        },
    },
    heli = {
        {
            coords = vector3(449.2, -981.4, 43.69),
            label = 'Helikopter',
            minGrade = 6,
            spawnPoints = {
                vector4(449.2, -981.4, 43.69, 90.0),
            },
            deleteCoords = vector3(449.2, -981.4, 43.69),
        },
    },
}

------------------------------------------------------------------------
-- Wapenkamer (ox_inventory / ESX inventory items)
------------------------------------------------------------------------
Config.Armory = {
    weapons = {
        { name = 'WEAPON_FLASHLIGHT',     label = 'Zaklamp',           grade = 1,  price = 0 },
        { name = 'WEAPON_NIGHTSTICK',     label = 'Wapenstok',         grade = 1,  price = 0 },
        { name = 'WEAPON_STUNGUN',        label = 'Taser',             grade = 2,  price = 0 },
        { name = 'WEAPON_COMBATPISTOL',   label = 'Dienstpistool',     grade = 3,  price = 0 },
        { name = 'WEAPON_PUMPSHOTGUN',    label = 'Shotgun',           grade = 5,  price = 0 },
        { name = 'WEAPON_CARBINERIFLE',   label = 'Karabijn',          grade = 6,  price = 0 },
        { name = 'WEAPON_SMG',            label = 'SMG',               grade = 6,  price = 0 },
    },
    items = {
        { name = 'radio',       label = 'Portofoon',   grade = 1, count = 1 },
        { name = 'handcuffs',   label = 'Handboeien',  grade = 1, count = 1 },
        { name = 'armor',       label = 'Kogelvrij vest', grade = 2, count = 1 },
        { name = 'ammo-9',      label = '9mm munitie', grade = 3, count = 50 },
        { name = 'ammo-shotgun', label = 'Shotgun ammo', grade = 5, count = 20 },
        { name = 'ammo-rifle',  label = 'Geweer ammo', grade = 6, count = 60 },
    },
}

------------------------------------------------------------------------
-- Dienstvoertuigen per minimumrang
------------------------------------------------------------------------
Config.Vehicles = {
    cars = {
        {
            category = 'Patrouille',
            minGrade = 1,
            vehicles = {
                { label = 'Politie Cruiser',   model = 'police' },
                { label = 'Politie Cruiser 2', model = 'police2' },
                { label = 'Politie Cruiser 3', model = 'police3' },
            },
        },
        {
            category = 'Onopvallend',
            minGrade = 4,
            vehicles = {
                { label = 'Onopvallende Sedan', model = 'police4' },
                { label = 'FBI SUV',            model = 'fbi2' },
            },
        },
        {
            category = 'Speciale eenheden',
            minGrade = 6,
            vehicles = {
                { label = 'Riot',   model = 'riot' },
                { label = 'Transporter', model = 'policet' },
            },
        },
        {
            category = 'Motor',
            minGrade = 3,
            vehicles = {
                { label = 'Politie Motor', model = 'policeb' },
            },
        },
    },
    helis = {
        {
            category = 'Luchtsteun',
            minGrade = 6,
            vehicles = {
                { label = 'Politieheli', model = 'polmav' },
            },
        },
    },
}

Config.VehicleExtras = {
    livery = 0,
    extras = { [1] = true, [2] = true, [3] = true },
}

------------------------------------------------------------------------
-- Uniformen per rang (pas componenten aan naar jullie EUP)
------------------------------------------------------------------------
Config.Uniforms = {
    [1] = { -- Aspirant
        male = {
            tshirt_1 = 58, tshirt_2 = 0,
            torso_1 = 55, torso_2 = 0,
            decals_1 = 0, decals_2 = 0,
            arms = 41,
            pants_1 = 25, pants_2 = 0,
            shoes_1 = 25, shoes_2 = 0,
            helmet_1 = 46, helmet_2 = 0,
            chain_1 = 0, chain_2 = 0,
            ears_1 = 2, ears_2 = 0,
        },
        female = {
            tshirt_1 = 35, tshirt_2 = 0,
            torso_1 = 48, torso_2 = 0,
            decals_1 = 0, decals_2 = 0,
            arms = 44,
            pants_1 = 34, pants_2 = 0,
            shoes_1 = 27, shoes_2 = 0,
            helmet_1 = 45, helmet_2 = 0,
            chain_1 = 0, chain_2 = 0,
            ears_1 = 2, ears_2 = 0,
        },
    },
    [2] = { -- Surveillant
        male = {
            tshirt_1 = 58, tshirt_2 = 0,
            torso_1 = 55, torso_2 = 0,
            decals_1 = 0, decals_2 = 0,
            arms = 41,
            pants_1 = 25, pants_2 = 0,
            shoes_1 = 25, shoes_2 = 0,
            helmet_1 = -1, helmet_2 = 0,
            chain_1 = 0, chain_2 = 0,
            ears_1 = 2, ears_2 = 0,
        },
        female = {
            tshirt_1 = 35, tshirt_2 = 0,
            torso_1 = 48, torso_2 = 0,
            decals_1 = 0, decals_2 = 0,
            arms = 44,
            pants_1 = 34, pants_2 = 0,
            shoes_1 = 27, shoes_2 = 0,
            helmet_1 = -1, helmet_2 = 0,
            chain_1 = 0, chain_2 = 0,
            ears_1 = 2, ears_2 = 0,
        },
    },
    -- Hogere rangen hergebruiken standaardagent-look; pas aan naar EUP
    default = {
        male = {
            tshirt_1 = 58, tshirt_2 = 0,
            torso_1 = 55, torso_2 = 0,
            decals_1 = 8, decals_2 = 0,
            arms = 41,
            pants_1 = 25, pants_2 = 0,
            shoes_1 = 25, shoes_2 = 0,
            helmet_1 = -1, helmet_2 = 0,
            chain_1 = 0, chain_2 = 0,
            ears_1 = 2, ears_2 = 0,
        },
        female = {
            tshirt_1 = 35, tshirt_2 = 0,
            torso_1 = 48, torso_2 = 0,
            decals_1 = 7, decals_2 = 0,
            arms = 44,
            pants_1 = 34, pants_2 = 0,
            shoes_1 = 27, shoes_2 = 0,
            helmet_1 = -1, helmet_2 = 0,
            chain_1 = 0, chain_2 = 0,
            ears_1 = 2, ears_2 = 0,
        },
    },
}

Config.Bulletproof = {
    male = { bproof_1 = 11, bproof_2 = 1 },
    female = { bproof_1 = 13, bproof_2 = 1 },
}

------------------------------------------------------------------------
-- Boetes (snelmenu)
------------------------------------------------------------------------
Config.Fines = {
    { label = 'Te hard rijden (licht)',  amount = 250  },
    { label = 'Te hard rijden (zwaar)',  amount = 750  },
    { label = 'Rood licht',              amount = 300  },
    { label = 'Geen rijbewijs',          amount = 1000 },
    { label = 'Wapenbezit illegaal',     amount = 2500 },
    { label = 'Diefstal',                amount = 1500 },
    { label = 'Geweldpleging',           amount = 2000 },
    { label = 'Vluchten voor politie',   amount = 3500 },
    { label = 'Custom bedrag',           amount = 0, custom = true },
}

Config.MaxFine = 25000
Config.BillingSociety = true -- boete gaat naar society_police

Config.HandcuffItem = 'handcuffs' -- optioneel; leeg = geen item check
Config.RequireHandcuffItem = false

Config.FuelResource = 'jg-benzine' -- of nil
Config.KeyResource = 'jg-givekey'  -- of 'jg-carkeys' / nil
