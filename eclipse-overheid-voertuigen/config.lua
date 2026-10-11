Config = {}

-- ═══════════════════════════════════════════════════════════════
-- Eclipse Overheid Voertuigen
-- 0 damage: kogelvrij, geen deuken, geen kapotte motorkap
-- ═══════════════════════════════════════════════════════════════

Config.Debug = false

-- Jobs die bescherming krijgen
Config.RequireJob = true
Config.Jobs = {
    police = true,
    ambulance = true,
    mechanic = false,
    -- kmar = true,
    -- brandweer = true,
}

-- BELANGRIJK: als je police/ambulance bent, is ELKE auto waarin je zit protected.
-- Zo werken ook custom PD-addons (RS6, Argento, …) zonder modelnaam.
Config.ProtectAllJobVehicles = true

-- Extra: deze modellen altijd (ook als je job-check uitstaat)
Config.Models = {
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
    ambulance = true,
    firetruk = true,
    lguard = true,
}

-- Class 18 = Emergency (vaak PD/ambulance)
Config.ProtectEmergencyClass = true
Config.EmergencyClass = 18

-- Alleen jouw voertuig beschermen (aanbevolen)
Config.OnlyOccupiedByPlayer = true
Config.NearbyDistance = 60.0

Config.RefreshMs = 500

-- 0 damage
Config.ZeroDamage = true
Config.Invincible = true
Config.Proofs = {
    bullet = true,
    fire = true,
    explosion = true,
    collision = true,
    melee = true,
    steam = true,
    drown = true,
}

Config.TyresCanBurst = false
Config.WheelsCanBreak = false
Config.CanBeVisiblyDamaged = false
Config.StrongAxles = true
Config.EngineNeverDegrade = true
Config.KeepEngineHealthy = true
Config.KeepBodyHealthy = true
Config.DisableVehicleWeapons = false

-- Stilstaand (< RepairBelowKmh): volledige repair inclusief motorkap/deuren/deuken
Config.FullRepairWhenStopped = true
Config.RepairBelowKmh = 3.0

-- Snelheid onbeperkt
Config.MaxSpeedKmh = 0
Config.TopSpeedMultiplier = 1.35
Config.DisableAutoBrakeAtHighSpeed = true

Config.Text = {
    applied = 'Overheidsvoertuig: 0 damage actief.',
    repaired = 'Voertuigschade hersteld.',
}
