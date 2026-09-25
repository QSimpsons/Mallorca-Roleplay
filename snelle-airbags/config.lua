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

-- Extra kussens per airbag, vlak voor het stuur of het dashboard,
-- zodat het uit die plek openbarst en daarna de auto uit vliegt.
Config.Burst = {
    { x = 0.00, y = 0.06, z = 0.02 },
    { x = 0.07, y = 0.10, z = 0.06 },
    { x = -0.06, y = 0.12, z = 0.00 }
}

-- Hoe hard de airbags vanuit het stuur en dashboard naar voren schieten.
Config.LaunchForward = 18.0
Config.LaunchUp = 3.2
Config.Spread = 0.85

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

Config.Notify = 'De airbags zijn uit het stuur en het dashboard gevlogen.'
