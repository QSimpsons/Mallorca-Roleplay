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

local props = {}

local function add(model, x, y, z, heading)
    props[#props + 1] = {
        model = model,
        coords = vector3(x, y, z),
        heading = heading or 0.0,
    }
end

local function ring(model, cx, cy, cz, radius, count, angleOffset)
    angleOffset = angleOffset or 0.0
    for i = 1, count do
        local ang = angleOffset + ((i - 1) / count) * math.pi * 2.0
        add(
            model,
            cx + math.cos(ang) * radius,
            cy + math.sin(ang) * radius,
            cz,
            0.0
        )
    end
end

-- Zuidelijke fonteinplein. De bestaande bankjes zitten op ongeveer 9-11m
-- rond dit middelpunt; de ringen blijven daarbinnen of ruim daarbuiten.
local fx, fy, fz = 181.80, -976.20, 29.46
ring('prop_pot_plant_05a', fx, fy, fz, 4.60, 8, 0.0)
ring('prop_plant_fern_02a', fx, fy, fz, 5.80, 8, math.pi / 8.0)
ring('prop_streetlight_03b', fx, fy, fz, 14.80, 6, 0.15)

-- Noordelijke entree, tussen het plein en de grote garage.
add('prop_tree_maple_02', 180.00, -862.00, 29.50, 0.0)
add('prop_tree_maple_02', 222.00, -864.00, 29.50, 0.0)
add('prop_bench_01a', 196.00, -878.00, 29.45, 180.0)
add('prop_bench_01a', 208.00, -878.00, 29.45, 180.0)
add('prop_pot_plant_05a', 188.00, -848.00, 29.50, 0.0)
add('prop_pot_plant_05a', 212.00, -848.00, 29.50, 0.0)
add('prop_news_disp_02a', 193.00, -846.00, 29.50, 180.0)
add('prop_postbox_01a', 207.00, -846.00, 29.50, 180.0)
add('prop_streetlight_03b', 200.00, -890.00, 29.60, 0.0)

-- Oostelijke promenade.
add('prop_tree_birch_03b', 236.00, -888.00, 29.55, 0.0)
add('prop_tree_birch_03b', 236.00, -922.00, 29.55, 0.0)
add('prop_tree_birch_03b', 236.00, -956.00, 29.55, 0.0)
add('prop_tree_birch_03b', 236.00, -986.00, 29.50, 0.0)
add('prop_bench_06', 226.00, -905.00, 29.50, 90.0)
add('prop_bench_06', 226.00, -940.00, 29.50, 90.0)
add('prop_bench_06', 226.00, -972.00, 29.50, 90.0)
add('prop_streetlight_03b', 244.00, -930.00, 29.55, 0.0)
add('prop_bin_05a', 242.00, -960.00, 29.50, 0.0)

-- Westelijke promenade en eetkraampjes.
add('prop_tree_birch_03b', 164.00, -910.00, 29.50, 0.0)
add('prop_tree_birch_03b', 164.00, -948.00, 29.50, 0.0)
add('prop_tree_maple_02', 164.00, -978.00, 29.50, 0.0)
add('prop_bench_06', 174.00, -918.00, 29.50, 270.0)
add('prop_bench_06', 174.00, -952.00, 29.50, 270.0)
add('prop_streetlight_03b', 152.00, -934.00, 29.50, 0.0)
add('prop_bin_05a', 172.00, -900.00, 29.50, 90.0)
add('prop_burgerstand_01', 156.00, -892.00, 29.50, 90.0)
add('prop_hotdogstand_01', 156.00, -876.00, 29.50, 90.0)
add('prop_bikerack_2', 168.00, -930.00, 29.50, 90.0)
add('prop_vend_soda_01', 198.00, -948.00, 29.55, 180.0)

-- Tuin met prieel en picknick, oost van het middenpad.
add('prop_gazebo_02', 214.00, -904.00, 29.55, 20.0)
add('prop_pot_plant_05a', 208.00, -898.00, 29.55, 0.0)
add('prop_pot_plant_05a', 220.00, -898.00, 29.55, 0.0)
add('prop_pot_plant_05a', 208.00, -910.00, 29.55, 0.0)
add('prop_pot_plant_05a', 220.00, -910.00, 29.55, 0.0)
add('prop_picnictable_01', 231.00, -952.00, 29.50, 90.0)
add('prop_parasol_02', 233.50, -952.00, 29.50, 0.0)
add('prop_picnictable_01', 231.00, -966.00, 29.50, 90.0)
add('prop_parasol_02', 233.50, -966.00, 29.50, 0.0)
add('prop_bench_05', 224.50, -952.00, 29.50, 90.0)
add('prop_bench_05', 224.50, -966.00, 29.50, 90.0)

Config.Props = props

-- Bordheading is de richting waar de voorkant naartoe wijst.
Config.Signs = {
    { id = 'north', x = 200.00, y = -842.00, heading = 0.0, kind = 'park', width = 3.52, height = 1.10 },
    { id = 'fountain', x = 181.80, y = -958.00, heading = 180.0, kind = 'park', width = 3.52, height = 1.10 },
}
