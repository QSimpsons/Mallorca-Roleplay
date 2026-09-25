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

-- Prop die als airbag wordt gebruikt. Wit en rond, zodat het
-- als een kussen uit de voorruit leest. Vervang dit als je
-- een eigen airbag-model in de server hebt.
Config.Prop = 'prop_beach_volball01'

-- Posities in de auto: links bestuurder, rechts passagier.
-- Twee kussens per kant, op de voorruit, zodat ze naar voren de auto uit vliegen.
Config.Airbags = {
    { x = -0.36, y = 1.05, z = 0.52 },
    { x = -0.22, y = 1.28, z = 0.70 },
    { x = 0.36, y = 1.05, z = 0.52 },
    { x = 0.22, y = 1.28, z = 0.70 }
}

-- Hoe hard de airbags naar voren en omhoog de auto uit schieten.
Config.LaunchForward = 24.0
Config.LaunchUp = 8.0
Config.Spread = 2.4

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

Config.Notify = 'De airbags zijn uit de auto gevlogen.'
