Config = {}

-- Spawnnaam van de fatbike.
-- Standaard: snellefat (streamfiles in snelle-fatbike/stream/).
-- Fallback: inductor als de stream-resource niet draait.
Config.Model = 'snellefat'

-- Fallback als Config.Model niet geladen kan worden.
Config.FallbackModel = 'inductor'

-- Commando zonder slash. /fatbike spawnt of bergt op.
Config.Command = 'fatbike'

-- Toets om dichtbij op te bergen (nil = alleen via commando/item).
Config.StoreKey = 'G'

-- Max afstand (meter) om een geplaatste fiets op te bergen.
Config.StoreDistance = 3.0

-- Speler automatisch op de fiets zetten bij spawn.
Config.WarpIntoBike = true

-- Kenteken op de plaat (max 8 tekens).
Config.Plate = 'FATBIKE'

-- Seconden tussen twee spawns / opbergen.
Config.Cooldown = 3

-- true: ESX/QB-item gebruiken. false: iedereen mag /fatbike.
Config.UseItem = false
Config.ItemName = 'ebike'
Config.ConsumeItem = true

-- Framework: 'auto', 'esx', 'qb', 'standalone'
Config.Framework = 'auto'

Config.ShowBlip = true
Config.Blip = {
    sprite = 226,
    color = 47,
    scale = 0.7,
    label = 'Fatbike',
}

-- Uiterlijk: zwart frame + oranje zadel (zoals je screenshot).
-- Werkt het best op vanilla inductor; custom packs hebben vaak eigen kleuren.
Config.Appearance = {
    enabled = true,
    -- RGB frame (matzwart)
    primary = { r = 18, g = 18, b = 20 },
    -- RGB zadel / accent (fel oranje)
    secondary = { r = 232, g = 92, b = 28 },
    pearlescent = 0,
    wheelColor = 0,
    -- Bredere banden = meer "fatbike"-look (0.2–1.0, nil = niet wijzigen)
    wheelWidth = 0.55,
    wheelSize = 0.85,
}

Config.Battery = {
    enabled = true,
    startPercent = 100,
    drainPerMinute = 2.5,
    minToDrive = 0,
}

Config.Messages = {
    spawned = 'Fatbike uitgezet.',
    stored = 'Fatbike opgeborgen.',
    alreadyOut = 'Je hebt al een fatbike buiten. Ga dichterbij en berg hem eerst op.',
    tooFar = 'Je bent te ver van je fatbike.',
    noBike = 'Je hebt geen fatbike buiten staan.',
    cooldown = 'Wacht even voordat je de fatbike opnieuw gebruikt.',
    modelMissing = 'Fatbike-model niet geladen. Controleer of stream/snellefat.yft aanwezig is.',
    noItem = 'Je hebt geen fatbike bij je.',
    inVehicle = 'Stap eerst uit je huidige voertuig.',
    dead = 'Je kunt dit nu niet doen.',
    usingFallback = 'Streammodel niet geladen — vanilla e-bike met fatbike-kleuren gebruikt.',
}

if type(Config.Command) ~= 'string' or not Config.Command:match('^[%w_-]+$') then
    Config.Command = 'fatbike'
end

if type(Config.Model) ~= 'string' or Config.Model == '' then
    Config.Model = 'snellefat'
end

if type(Config.FallbackModel) ~= 'string' or Config.FallbackModel == '' then
    Config.FallbackModel = 'inductor'
end
