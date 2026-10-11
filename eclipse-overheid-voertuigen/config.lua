Config = {}

-- ═══════════════════════════════════════════════════════════════
-- Eclipse Overheid Voertuigen
-- Kogelvrij + niet kapot (schade / banden / explosies)
-- ═══════════════════════════════════════════════════════════════

Config.Debug = false

-- Alleen toepassen als de bestuurder deze job heeft (leeg = altijd op gematchte modellen).
Config.RequireJob = true
Config.Jobs = {
    police = true,
    ambulance = true,
    mechanic = false, -- zet true als ANWB/takel ook mee moet
    -- kmar = true,
    -- brandweer = true,
}

-- Match op modelnaam (spawnnaam). Kleine letters.
-- Voeg hier jullie addon-modellen toe, bv. 'polargento1'.
Config.Models = {
    -- Politie (GTA + addons)
    police = true,
    police2 = true,
    police3 = true,
    police4 = true,
    policeb = true,
    policet = true,
    fbi = true,
    fbi2 = true,
    riot = true,
    riot2 = true,
    polmav = true,
    polargento1 = true,

    -- Ambulance / brandweer
    ambulance = true,
    firetruk = true,
    lguard = true,
}

-- Ook voertuigen met deze class beschermen (18 = Emergency).
-- true = naast de modellijst ook class 18 meenemen.
Config.ProtectEmergencyClass = true
Config.EmergencyClass = 18

-- Alleen het voertuig van de lokale speler, of ook andere dichtbij.
Config.OnlyOccupiedByPlayer = false -- false = ook andere overheidswagens in de buurt
Config.NearbyDistance = 60.0

-- Hoe vaak opnieuw toepassen (ms). Lager = strakker, iets meer load.
Config.RefreshMs = 1000

-- Wat er beschermd wordt
Config.Proofs = {
    bullet = true,      -- kogels
    fire = true,        -- vuur
    explosion = true,   -- explosies
    collision = true,   -- botsingen
    melee = true,       -- melee
    steam = true,
    drown = true,
}

Config.TyresCanBurst = false      -- banden knappen niet
Config.CanBeVisiblyDamaged = false
Config.StrongAxles = true
Config.EngineNeverDegrade = true
Config.KeepEngineHealthy = true   -- motor altijd ~1000 health
Config.KeepBodyHealthy = true     -- body/health hoog houden ZONDER SetVehicleFixed tijdens rijden
Config.DisableVehicleWeapons = false -- true = voertuigwapens uit (meestal niet nodig)

-- Snelheid: geen harde limiet (voorkomt “stoppen en weer wegrijden” rond hoge km/u).
-- MaxSpeedKmh = 0 → geen cap (sneller dan 295 mag).
-- TopSpeedMultiplier > 1.0 → voertuig trekt harder door naar hoge snelheid.
Config.MaxSpeedKmh = 0
Config.TopSpeedMultiplier = 1.35
Config.DisableAutoBrakeAtHighSpeed = true

Config.Text = {
    applied = 'Overheidsvoertuig: kogelvrij & onverwoestbaar.',
}
