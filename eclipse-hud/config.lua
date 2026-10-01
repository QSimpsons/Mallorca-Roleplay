Config = {}

-- Framework: 'auto' | 'esx' | 'qb' | 'qbx' | 'standalone'
Config.Framework = 'auto'

-- HUD zichtbaarheid
Config.ShowOnStart = true
Config.HideInPauseMenu = true
Config.HideWhenDead = false

-- Update interval (ms)
Config.TickMs = 200

-- Status waarden (standalone / fallback)
Config.DefaultHunger = 100
Config.DefaultThirst = 100

-- ESX status namen (esx_status / esx_basicneeds)
Config.ESX = {
    Hunger = 'hunger',
    Thirst = 'thirst'
}

-- QBCore / QBX metadata keys
Config.QB = {
    Hunger = 'hunger',
    Thirst = 'thirst'
}

-- Job weergave
-- Job1 = primaire job, Job2 = secundaire job (indien aanwezig)
Config.JobLabels = {
    unemployed = 'Werkloos',
    police = 'Politie',
    ambulance = 'Ambulance',
    mechanic = 'Monteur',
    taxi = 'Taxi',
    cardealer = 'Autodealer',
    realestate = 'Makelaar',
    garbage = 'Afval',
    vinewood = 'Vinewood'
}

Config.UnemployedLabel = 'Werkloos'
Config.NoJob2Label = 'Geen'

-- Geld tonen
Config.ShowMoney = true

-- Locatie / straatnaam
Config.ShowLocation = true

-- Voice / microfoon indicator (uitgeschakeld)
Config.ShowVoice = false

-- Minimap health/armor bars verbergen (native GTA bars)
Config.HideDefaultBars = true
