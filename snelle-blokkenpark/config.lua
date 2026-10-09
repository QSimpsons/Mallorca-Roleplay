Config = {}

-- Blokkenpark is Legion Square: het plein tussen de noordelijke garage
-- (rond 214, -809) en de zuidelijke stalling (rond 128, -1055).
Config.ParkCenter = vector3(195.20, -933.80, 30.69)
Config.StreamRadius = 185.0

Config.Blip = {
    sprite = 409,
    color = 2,
    scale = 0.85,
    label = 'Blokkenpark',
}

Config.MaxPerPlayer = 2

-- Voertuigklassen die niet in de ondergrondse bak passen.
-- 10 industrial, 11 utility, 14 boot, 15 heli, 16 vliegtuig,
-- 17 service, 19 military, 20 commercial, 21 trein.
Config.BlockedClasses = {
    [10] = true,
    [11] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [17] = true,
    [19] = true,
    [20] = true,
    [21] = true,
}

Config.Messages = {
    entered = 'Ondergrondse parking van Blokkenpark.',
    left = 'Je staat weer buiten bij Blokkenpark.',
    parked = 'Geparkeerd. Alleen jij kunt dit voertuig hier weer uitrijden.',
    retrieved = 'Voertuig staat klaar.',
    notYours = 'Dit voertuig is van iemand anders.',
    full = 'De ondergrondse parking zit vol.',
    limit = 'Je kunt hier maximaal twee voertuigen parkeren.',
    blockedClass = 'Dit voertuig past niet in de ondergrondse parking.',
    occupied = 'Dit vak is bezet.',
    driverOnly = 'Alleen de bestuurder kan de parking in of uit.',
    noPlate = 'Dit voertuig heeft geen kenteken.',
    invalid = 'Dit voertuig kan niet worden opgeslagen.',
    timeout = 'Geen antwoord van de server.',
    spawnFailed = 'Het voertuig kon niet worden neergezet.',
}

Config.Help = {
    enterVehicle = 'Druk op ~INPUT_CONTEXT~ om de ondergrondse parking in te rijden',
    enterFoot = 'Druk op ~INPUT_CONTEXT~ om de ondergrondse parking in te lopen',
    leaveVehicle = 'Druk op ~INPUT_CONTEXT~ om naar buiten te rijden',
    leaveFoot = 'Druk op ~INPUT_CONTEXT~ om naar buiten te lopen',
    park = 'Druk op ~INPUT_CONTEXT~ om te parkeren',
    retrieve = 'Druk op ~INPUT_CONTEXT~ om je voertuig uit te halen',
    taken = 'Dit vak is bezet',
}

-- Zoekpunten voor de ingang. De client kiest het eerste punt dat op een
-- echte weg ligt en niet op de bestaande Blokkenpark-garages valt.
Config.Parking = {
    label = 'Blokkenpark Ondergronds',
    blip = { sprite = 357, color = 3, scale = 0.8 },
    candidates = {
        vector3(170.00, -835.00, 30.30),
        vector3(148.00, -1005.00, 29.40),
        vector3(255.00, -945.00, 29.80),
        vector3(110.00, -945.00, 29.50),
    },
    avoid = {
        { coords = vector3(213.93, -809.30, 31.01), radius = 24.0 },
        { coords = vector3(208.31, -795.98, 30.55), radius = 18.0 },
        { coords = vector3(127.85, -1055.32, 29.20), radius = 22.0 },
        { coords = vector3(140.00, -1075.00, 29.19), radius = 32.0 },
    },
    -- Native 10-car garage, fysiek onder Legion Square. Geen extra IPL nodig.
    interior = vector3(229.9559, -981.7928, -99.66071),
    insideVehicle = vector4(228.15, -1002.00, -99.05, 0.0),
    insideFoot = vector4(228.05, -1005.52, -99.00, 0.46),
    insideExit = vector3(228.05, -1007.20, -99.00),
    exitRadius = 3.4,
    enterRadius = 3.3,
    spots = {
        { id = 1, coords = vector4(233.44, -998.65, -99.40, 121.72) },
        { id = 2, coords = vector4(233.38, -994.87, -99.40, 124.62) },
        { id = 3, coords = vector4(233.24, -991.16, -99.40, 127.59) },
        { id = 4, coords = vector4(233.18, -987.34, -99.40, 130.14) },
        { id = 5, coords = vector4(233.28, -983.14, -99.40, 129.06) },
        { id = 6, coords = vector4(223.89, -998.69, -99.40, 238.26) },
        { id = 7, coords = vector4(223.85, -994.79, -99.40, 237.37) },
        { id = 8, coords = vector4(223.70, -990.64, -99.40, 238.73) },
        { id = 9, coords = vector4(223.54, -986.43, -99.40, 239.08) },
        { id = 10, coords = vector4(223.68, -982.79, -99.40, 235.46) },
    },
}

-- Het bestaande Blokkenpark (de blokken) blijft staan. Geen extra bomen of kraampjes.
Config.Props = {}

-- Bordheading is de richting waar de voorkant naartoe wijst.
Config.Signs = {
    { id = 'north', x = 200.00, y = -842.00, heading = 0.0, kind = 'park', width = 3.52, height = 1.10 },
    { id = 'fountain', x = 181.80, y = -958.00, heading = 180.0, kind = 'park', width = 3.52, height = 1.10 },
}
