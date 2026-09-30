Config = {}

-- Voetgangers, dieren en scenario-NPC's
Config.DisablePeds = true

-- Rijdend NPC-verkeer
Config.DisableTraffic = true

-- Geparkeerde NPC-auto's
Config.DisableParkedVehicles = true

-- Random politie, ambulance, boten, treinen en vuilniswagens
Config.DisableDispatch = true

-- GTA-wanted level uitzetten, anders spawnt de game alsnog agenten
Config.DisableWantedLevel = true

-- Ambient NPC's die al in de wereld staan opruimen.
-- Alleen population-types van de game zelf (random permanent t/m ambient).
-- Script-NPC's en spelersvoertuigen (mission/permanent) blijven staan.
Config.ClearExisting = true
Config.ClearInterval = 2000

-- OneSync: population uit in elke routing bucket waar een speler in zit.
-- Zet op false om alleen de standaardwereld (bucket 0) leeg te houden.
Config.DisablePopulationInAllBuckets = true
