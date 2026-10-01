Config = {}

-- Midden van Cayo Perico; binnen deze straal wordt het eiland geactiveerd
Config.IslandCenter = vector3(4840.571, -5174.425, 2.0)
Config.LoadDistance = 2200.0

-- Check-interval (ms) voor aan/uit van het eiland
Config.CheckInterval = 2000

-- Veilige landing (airstrip) voor /cayofix
Config.SafeCoords = vector4(4440.19, -4461.58, 4.33, 200.0)

-- Als Z onder dit niveau zit terwijl je op Cayo bent, meld "onder de map"
Config.UnderMapZ = -5.0

-- true = eiland altijd aan (ook vanaf LS). Meestal false houden.
Config.AlwaysLoaded = false

-- ACE voor /cayofix (teleport + force reload)
Config.FixAce = 'command.cayofix'
