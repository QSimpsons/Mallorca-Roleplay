Config = {}

-- Spawnnaam van de fiets.
-- Standaard: inductor (vanilla GTA e-bike, werkt zonder extra pack).
-- Heb je de Super73/fatbike uit de screenshot? Zet hier de modelnaam
-- uit vehicles.meta van jouw vehicle-pack, bijvoorbeeld 'super73'.
Config.Model = 'inductor'

-- Commando zonder slash. /ebike spawnt of bergt op.
Config.Command = 'ebike'

-- Toets om dichtbij op te bergen (nil = alleen via commando/item).
-- Controleer in GTA Settings → Key Bindings → FiveM.
Config.StoreKey = 'G'

-- Max afstand (meter) om een geplaatste fiets op te bergen.
Config.StoreDistance = 3.0

-- Speler automatisch op de fiets zetten bij spawn.
Config.WarpIntoBike = true

-- Kenteken op de plaat (max 8 tekens).
Config.Plate = 'SNELLE'

-- Seconden tussen twee spawns / opbergen.
Config.Cooldown = 3

-- true: ESX-item gebruiken. false: iedereen mag /ebike.
Config.UseItem = false

-- Itemnaam in de database (alleen als UseItem = true).
Config.ItemName = 'ebike'

-- Item verwijderen bij spawn en teruggeven bij opbergen.
Config.ConsumeItem = true

-- Framework: 'auto', 'esx', 'qb', 'standalone'
Config.Framework = 'auto'

-- Blip op de kaart zolang jouw fiets bestaat.
Config.ShowBlip = true
Config.Blip = {
    sprite = 226,
    color = 47,
    scale = 0.7,
    label = 'E-bike',
}

-- Batterij-HUD (visueel, geen echte motoruitschakeling).
Config.Battery = {
    enabled = true,
    startPercent = 100,
    -- Percentage per minuut rijden.
    drainPerMinute = 2.5,
    -- Minimum om te mogen rijden (0 = altijd).
    minToDrive = 0,
}

Config.Messages = {
    spawned = 'E-bike uitgezet.',
    stored = 'E-bike opgeborgen.',
    alreadyOut = 'Je hebt al een e-bike buiten. Ga dichterbij en berg hem eerst op.',
    tooFar = 'Je bent te ver van je e-bike.',
    noBike = 'Je hebt geen e-bike buiten staan.',
    cooldown = 'Wacht even voordat je de e-bike opnieuw gebruikt.',
    modelMissing = 'Fietsmodel niet geladen. Controleer Config.Model of je vehicle-pack.',
    noItem = 'Je hebt geen e-bike bij je.',
    inVehicle = 'Stap eerst uit je huidige voertuig.',
    dead = 'Je kunt dit nu niet doen.',
}

if type(Config.Command) ~= 'string' or not Config.Command:match('^[%w_-]+$') then
    Config.Command = 'ebike'
end

if type(Config.Model) ~= 'string' or Config.Model == '' then
    Config.Model = 'inductor'
end
