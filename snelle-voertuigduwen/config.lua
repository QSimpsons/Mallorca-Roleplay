Config = {}

-- ═══════════════════════════════════════════════════════════════
-- Snelle Voertuigduwen · ESX Legacy
-- Duw een stilstaand voertuig zelf, of schuif het in één keer
-- aan de kant van de weg.
-- ═══════════════════════════════════════════════════════════════

Config.Locale = 'nl'

-- Logt elke duw in sql/install.sql. Zet op false als je geen database wilt.
Config.Database = {
    enabled = true
}
Config.Debug = false
Config.Notify = 'auto'   -- 'auto' | 'ox_lib' | 'esx'
Config.Target = 'auto'   -- 'auto' | 'ox_target' | 'qtarget' | 'none'
Config.TextUI = 'auto'   -- 'auto' | 'ox_lib' | 'esx'

-- Leeg = iedereen mag duwen.
-- Voorbeeld: { 'police', 'anwb', 'mechanic' }
Config.AllowedJobs = {}
Config.RequireOnDuty = false

Config.InteractDistance = 3.4
Config.MaxVehicleSpeed = 1.4          -- m/s, daarboven "rijdt nog"
Config.MaxHeightAboveGround = 2.8
Config.BlockLocked = false
Config.RequireEngineOff = false
Config.RequireBroken = false
Config.BrokenEngineHealth = 350.0
Config.AllowNpcPassengers = false
Config.HazardLights = true

-- Boten, helikopters, vliegtuigen en treinen.
Config.BlockedClasses = {
    [14] = true,
    [15] = true,
    [16] = true,
    [21] = true
}

-- Modelnamen die nooit geduwd mogen worden.
Config.BlacklistedModels = {
    -- 'rhino',
}

Config.Keys = {
    push = 'G',    -- handmatig duwen / loslaten
    aside = 'H'    -- aan de kant schuiven
}

-- Sturen tijdens het duwen.
-- 'both'   = ZQSD (AZERTY) én WASD (QWERTY)
-- 'azerty' = Z vooruit, S achteruit, Q links, D rechts
-- 'qwerty' = W vooruit, S achteruit, A links, D rechts
Config.Keyboard = 'both'

Config.Commands = {
    push = 'duw',
    aside = 'aandekant'
}

-- Hoe lang (seconden) er minimaal tussen twee starts zit.
Config.Cooldown = {
    manual = 1,
    aside = 6
}

Config.Anim = {
    dict = 'missfinale_c2ig_11',
    name = 'pushcar_offcliff_m',
    nameFemale = 'pushcar_offcliff_f',
    flag = 1
}

-- Handmatig duwen: Z/S of W/S vooruit en achteruit, Q/D of A/D sturen.
-- Sturen draait alleen de voorwielen. De auto zelf volgt pas terwijl hij rolt.
Config.Manual = {
    enabled = true,
    speed = 1.05,
    reverseSpeed = 0.55,
    maxSteer = 34.0,       -- maximale hoek van de voorwielen
    steerSpeed = 90.0,     -- hoe snel die wielen naar die hoek draaien
    turnRate = 32.0        -- carrosserie, graden per seconde, alleen tijdens rijden
}

-- Aan de kant: schuif het voertuig zijwaarts de berm in.
-- prefer: 'auto' (berm aan de kant waar de auto al staat, anders rechts),
--         'right' of 'left' ten opzichte van de rijrichting van de weg.
Config.Shoulder = {
    prefer = 'auto',
    offset = 5.4,             -- meters naast het midden van de weg
    minSlide = 0.85,          -- minder dan dit = staat al aan de kant
    maxSlide = 7.5,           -- nooit verder dan dit per keer
    fallbackDistance = 3.6,   -- als er geen weg in de buurt is
    maxNodeDistance = 28.0,
    speed = 1.15,             -- m/s
    alignToRoad = true
}
