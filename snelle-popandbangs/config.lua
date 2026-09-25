Config = {}

-- ═══════════════════════════════════════════════════════════════
-- Snelle Pop & Bangs · stage 1 t/m 6
-- Items + PNG's, geen SQL. De inbouw wordt per kenteken bewaard
-- in data/installed.json.
-- ═══════════════════════════════════════════════════════════════

Config.Locale = 'nl'
Config.Notify = 'auto'        -- 'auto' | 'ox_lib' | 'esx'
Config.Target = 'auto'        -- 'auto' | 'ox_target' | 'none'
Config.Progress = 'auto'      -- 'auto' | 'ox_lib' | 'native'
Config.Inventory = 'auto'     -- 'auto' | 'ox_inventory' | 'esx'

Config.Debug = false
Config.NotifyOnEnter = true
Config.ToggleCommand = 'popbang'

-- Alleen deze jobs mogen inbouwen/verwijderen. Standaard uit,
-- zodat iedereen met het item het kan plaatsen.
Config.RequireJob = false
Config.Jobs = { 'mechanic', 'tuner' }

-- Kentekenbestand. Geen database.
Config.DataFile = 'data/installed.json'

Config.InstallDistance = 3.5
Config.ServerDistance = 6.0
Config.MaxInstallSpeed = 1.5       -- m/s, voertuig moet stilstaan
Config.MinSpeed = 18.0             -- km/h, daaronder alleen antilag bij hoge stages
Config.CheckInterval = 110         -- ms tussen controles terwijl je rijdt
Config.SyncDistance = 70.0         -- andere spelers horen/zien de pops tot hier

-- 'explosion' = korte knal via een onzichtbare explosie zonder schade.
-- Zet op 'off' als je anticheat AddExplosion blokkeert. De vlammen blijven.
Config.SoundMode = 'explosion'
Config.ExplosionType = 61

Config.RemoverItem = 'popbang_remover'

-- Voertuigklassen waarop het niet kan (client).
-- 13 fiets, 14 boot, 15 heli, 16 vliegtuig, 21 trein
Config.BlockedClasses = {
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [21] = true
}

-- Zelfde filter op de server (GetVehicleType).
Config.BlockedTypes = {
    boat = true,
    heli = true,
    plane = true,
    submarine = true,
    trailer = true,
    train = true
}

Config.ExhaustBones = {
    'exhaust', 'exhaust_2', 'exhaust_3', 'exhaust_4',
    'exhaust_5', 'exhaust_6', 'exhaust_7', 'exhaust_8',
    'exhaust_9', 'exhaust_10', 'exhaust_11', 'exhaust_12',
    'exhaust_13', 'exhaust_14', 'exhaust_15', 'exhaust_16'
}

-- ═══════════════════════════════════════════════════════════════
-- Stages
-- item         = itemnaam in ox_inventory (zelfde naam als de PNG)
-- minRpm       = vanaf dit toerental (0.0 - 1.0)
-- cooldown     = minimale tijd tussen bursts, in ms
-- chance       = kans op pops terwijl je uitrolt
-- antilag      = ook pops met het gas ingetrapt
-- flameScale   = grootte van veh_backfire
-- flameChance  = kans dat er een vlam bij de knal zit
-- exhausts     = hoeveel uitlaten tegelijk
-- burst        = aantal knallen per keer
-- allowStationary = revven op de plaats (2-step)
-- ═══════════════════════════════════════════════════════════════

Config.Stages = {
    [1] = {
        item = 'popbang_stage1',
        installTime = 8000,
        minRpm = 0.62,
        maxRpm = 1.05,
        cooldown = 1200,
        chance = 40,
        antilag = false,
        antilagRpm = 0.90,
        antilagChance = 0,
        flameScale = 0.40,
        flameChance = 35,
        exhausts = 1,
        burst = { min = 1, max = 1 },
        burstGap = { min = 80, max = 120 },
        allowStationary = false
    },
    [2] = {
        item = 'popbang_stage2',
        installTime = 10000,
        minRpm = 0.58,
        maxRpm = 1.05,
        cooldown = 950,
        chance = 55,
        antilag = false,
        antilagRpm = 0.88,
        antilagChance = 0,
        flameScale = 0.58,
        flameChance = 60,
        exhausts = 1,
        burst = { min = 1, max = 2 },
        burstGap = { min = 110, max = 170 },
        allowStationary = false
    },
    [3] = {
        item = 'popbang_stage3',
        installTime = 12000,
        minRpm = 0.52,
        maxRpm = 1.05,
        cooldown = 780,
        chance = 70,
        antilag = false,
        antilagRpm = 0.84,
        antilagChance = 0,
        flameScale = 0.78,
        flameChance = 85,
        exhausts = 2,
        burst = { min = 1, max = 2 },
        burstGap = { min = 90, max = 150 },
        allowStationary = false
    },
    [4] = {
        item = 'popbang_stage4',
        installTime = 14000,
        minRpm = 0.48,
        maxRpm = 1.05,
        cooldown = 560,
        chance = 85,
        antilag = true,
        antilagRpm = 0.80,
        antilagChance = 28,
        flameScale = 1.00,
        flameChance = 100,
        exhausts = 2,
        burst = { min = 2, max = 3 },
        burstGap = { min = 80, max = 130 },
        allowStationary = true
    },
    [5] = {
        item = 'popbang_stage5',
        installTime = 16000,
        minRpm = 0.42,
        maxRpm = 1.05,
        cooldown = 420,
        chance = 95,
        antilag = true,
        antilagRpm = 0.70,
        antilagChance = 48,
        flameScale = 1.25,
        flameChance = 100,
        exhausts = 4,
        burst = { min = 2, max = 3 },
        burstGap = { min = 70, max = 110 },
        allowStationary = true
    },
    [6] = {
        item = 'popbang_stage6',
        installTime = 18000,
        minRpm = 0.36,
        maxRpm = 1.05,
        cooldown = 400,
        chance = 100,
        antilag = true,
        antilagRpm = 0.60,
        antilagChance = 72,
        flameScale = 1.55,
        flameChance = 100,
        exhausts = 8,
        burst = { min = 2, max = 4 },
        burstGap = { min = 55, max = 95 },
        allowStationary = true
    }
}
