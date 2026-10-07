Config = {}

-- Snelheid in km/u vlak voor de klap. Daaronder gebeurt er niets.
Config.MinSpeed = 50.0

-- Hoeveel km/u het voertuig in één meting moet verliezen.
-- Een noodstop haalt dit niet; een botsing wel.
Config.SpeedDrop = 26.0

-- Venster in milliseconden waarin de snelheidsdaling wordt gemeten.
-- Een noodstop haalt de drempel in dit korte venster niet.
Config.SampleMs = 200

-- Seconden voordat dezelfde auto opnieuw airbags kan krijgen,
-- en alleen nadat de auto weer is gerepareerd.
Config.MinRedeploySeconds = 25

-- Carrosserie en motor moeten minstens zo hoog zijn (0-1000)
-- voordat de airbags opnieuw mogen.
Config.RepairHealth = 950.0

-- Hoeveel de carrosserie of motor moet stijgen om als reparatie te tellen.
Config.RepairRise = 40.0

-- Bij de klap is de auto total loss. Lager = kapotter (0-1000).
-- De motor blijft boven de brandgrens, zodat de auto niet in brand vliegt.
-- Een reparatie zet de waarden weer omhoog, en dan verdwijnen de airbags.
Config.TotalLoss = true
Config.CrashBodyHealth = 150.0
Config.CrashEngineHealth = 280.0

-- Hoe lang (ms) vuur na de klap actief wordt gedoofd.
Config.NoFireMs = 180000

-- Plassen die op de grond achterblijven.
Config.Fluids = {
    petrol = { width = 1.9, transparency = 1.0 },
    oil = { width = 1.45, transparency = 0.95 },
    coolant = { width = 1.25, r = 0.12, g = 0.92, b = 0.18, opacity = 0.9, seconds = 300.0 }
}

-- Na de klap even wachten, zodat de schade zelf niet als reparatie telt.
Config.RepairGraceMs = 2000

-- Schade op de kant waar je iets raakt, zoals in het echt.
-- Een lichte tik deukt alleen. Een harde tik aan de zijkant geeft een klapband.
Config.SideDamage = true
Config.ScrapeMinSpeed = 30.0
Config.ScrapeDrop = 14.0
Config.HeavyDrop = 42.0
Config.ScrapeCooldownMs = 900
Config.StrikeDistance = 12.0
Config.MaxImpacts = 5

-- Hoe diep de deuk wordt. Hoger = meer ingedeukt.
Config.DentDamageMin = 700.0
Config.DentDamageMax = 5200.0
Config.DentRadiusMin = 0.32
Config.DentRadiusMax = 0.78

-- Vanaf deze zwaarte (0-1) klapt de band aan de geraakte kant.
Config.BlowoutSeverity = 0.42
-- Pas heel hoog vliegt het wiel eraf. Daaronder blijft het een klapband.
Config.WheelOffSeverity = 0.98
Config.GlassSeverity = 0.55
Config.DoorSeverity = 0.88
Config.DoorOffSeverity = 1.1

-- Carrosserieverlies bij een schampschot. De motor lijdt alleen bij een klap van voren.
-- De auto blijft rijden, tot een echte airbag-klap hem total loss maakt.
Config.ScrapeBodyLoss = 280.0
Config.ScrapeEngineLoss = 180.0
Config.MinBodyAfterScrape = 450.0
Config.MinEngineAfterScrape = 400.0

-- Echt airbag-model (geen bal). Zie third_party/NOTICE.txt.
Config.AirbagModel = 'prop_carairbag'

-- Hoe klein de airbag start en hoe lang het opblazen duurt.
Config.StartScale = 0.18
Config.InflateMs = 320

-- Bestuurder: groeit uit het stuur naar de bestuurder toe.
-- Bijrijder: groeit uit het dashboard.
-- Offsets staan op de stoel-bone, y = naar de motorkap, z = omhoog.
Config.Driver = {
    bone = 'seat_dside_f',
    from = { x = 0.0, y = 0.50, z = 0.55 },
    to = { x = 0.0, y = 0.30, z = 0.40 },
    rot = { x = 0.0, y = 0.0, z = 90.0 }
}

Config.Passenger = {
    bone = 'seat_pside_f',
    from = { x = 0.0, y = 0.68, z = 0.50 },
    to = { x = 0.0, y = 0.40, z = 0.40 },
    rot = { x = 0.0, y = 0.0, z = 90.0 }
}

-- Ruiten eruit en camera schudt. De motor blijft dood zolang Config.TotalLoss aan staat.
Config.PopWindscreen = true
Config.CameraShake = 0.72

-- Alleen de bestuurder laat het effect afgaan.
-- Andere spelers in de buurt zien dezelfde airbags.
Config.SyncDistance = 120.0

-- Boten, helikopters, vliegtuigen, treinen, motoren en fietsen.
Config.BlockedClasses = {
    [8] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [21] = true
}

-- Modelnamen die nooit airbags krijgen.
Config.BlacklistedModels = {
    -- 'rhino',
}
