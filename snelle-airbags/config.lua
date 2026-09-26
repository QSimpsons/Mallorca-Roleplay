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
Config.RepairHealth = 850.0

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

-- Voorruit eruit, motor slaat af, camera schudt.
Config.PopWindscreen = true
Config.StallEngine = true
Config.StallMs = 3500
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
