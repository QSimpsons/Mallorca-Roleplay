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

-- Prop die als airbag wordt gebruikt. Wit en rond.
-- Vervang dit als je een eigen airbag-model in de server hebt.
Config.Prop = 'prop_beach_volball01'

-- Als een auto geen stuur-bone heeft, gebruiken we deze plek in de cabine.
-- x negatief = bestuurderskant, y = naar de motorkap, z = omhoog.
Config.FallbackWheel = { x = -0.34, y = 0.34, z = 0.48 }

-- Kussens per airbag, net uit het stuur of dashboard de cabine in,
-- zodat je ze ziet vertrekken voordat ze door de voorruit gaan.
Config.Burst = {
    { x = 0.00, y = 0.16, z = 0.16 },
    { x = 0.10, y = 0.22, z = 0.26 },
    { x = -0.10, y = 0.20, z = 0.20 }
}

-- Hoe hard de airbags vanuit het stuur en dashboard naar voren en omhoog schieten.
-- Omhoog zodat ze door de voorruit gaan en niet in het dashboard verdwijnen.
Config.LaunchForward = 9.0
Config.LaunchUp = 8.0
Config.Spread = 1.15

-- Heel even zichtbaar op het stuur en dashboard, daarna vliegen ze eruit.
Config.PopDelayMs = 180

-- Na hoeveel milliseconden de props weer worden opgeruimd.
Config.DespawnMs = 12000

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
