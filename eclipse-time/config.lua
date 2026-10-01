Config = {}

-- Commando in de chat. Standaard: /time
Config.Command = 'time'

-- true = alleen spelers met de ace of een identifier hieronder.
-- In server.cfg, als je admins nog geen algemene command-rechten hebben:
--   add_ace group.admin command.time allow
Config.RequirePermission = true
Config.AcePermission = 'command.time'

-- Extra mensen die het menu mogen openen, naast de ace.
-- Voorbeeld: 'license:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
Config.AllowedIdentifiers = {}

-- Echte milliseconden per spelminuut. 2000 = een dag van 48 minuten.
Config.MillisecondsPerGameMinute = 2000

-- Hoe snel de klok vooruit loopt als "Instant time change" uit staat (seconden).
Config.SmoothTimeChangeSeconds = 15

-- Overgang bij weer als "Instant weather change" uit staat (seconden).
Config.WeatherTransitionSeconds = 20.0

-- Dynamisch weer wisselt elke zoveel echte minuten, zolang de optie aan staat.
Config.DynamicWeatherMinutes = 15

-- Weertypes die dynamisch weer mag kiezen. Sneeuw en events blijven handmatig.
Config.DynamicWeatherTypes = {
    'EXTRASUNNY',
    'CLEAR',
    'NEUTRAL',
    'SMOG',
    'FOGGY',
    'OVERCAST',
    'CLOUDS',
    'CLEARING',
    'RAIN',
    'THUNDER'
}

-- Hoogte van het water als tsunami aan staat (0.0 = normaal, 1.0 = hoog).
Config.TsunamiStrength = 1.0
-- Tijd in ms om het water te laten stijgen of dalen.
Config.TsunamiRampMs = 15000

-- Teksten. De menulabels volgen het voorbeeld; meldingen zijn Nederlands.
Config.Locale = {
    freeze = 'Freeze time',
    blackout = 'Blackout',
    dynamic = 'Dynamic weather',
    instantTime = 'Instant time change',
    h24 = '24 hr',
    instantWeather = 'Instant weather change',
    tsunami = 'Tsunami',
    save = 'Save Settings',
    change = 'Change',
    close = 'Close',
    applied = 'Tijd en weer aangepast.',
    saved = 'Instellingen opgeslagen.',
    denied = 'Je hebt geen toestemming om /time te gebruiken.',
    invalid = 'Ongeldige instellingen.',
    saveFailed = 'Opslaan is mislukt. Controleer of de resource-map schrijfbaar is.',
    suggestion = 'Pas de tijd en het weer aan'
}

-- Startwaarden. "Save Settings" schrijft daarna data/settings.json.
Config.Defaults = {
    hour = 14,
    minute = 0,
    weather = 'EXTRASUNNY',
    freeze = true,
    blackout = false,
    dynamic = true,
    instantTime = true,
    h24 = false,
    instantWeather = true,
    tsunami = false
}

-- rain: 0.0–1.0, wind: windsnelheid, snow: sporen in sneeuw, icon: icoon in het menu.
Config.Weathers = {
    { id = 'EXTRASUNNY', label = 'Extra Sunny', icon = 'sun', rain = 0.0, wind = 0.2, snow = false },
    { id = 'CLEAR', label = 'Clear', icon = 'sun-soft', rain = 0.0, wind = 0.4, snow = false },
    { id = 'NEUTRAL', label = 'Neutral', icon = 'neutral', rain = 0.0, wind = 0.3, snow = false },
    { id = 'SMOG', label = 'Smog', icon = 'smog', rain = 0.0, wind = 0.1, snow = false },
    { id = 'FOGGY', label = 'Foggy', icon = 'fog', rain = 0.0, wind = 0.1, snow = false },
    { id = 'OVERCAST', label = 'Overcast', icon = 'overcast', rain = 0.0, wind = 1.0, snow = false },
    { id = 'CLOUDS', label = 'Clouds', icon = 'clouds', rain = 0.0, wind = 0.8, snow = false },
    { id = 'CLEARING', label = 'Clearing', icon = 'clearing', rain = 0.0, wind = 1.2, snow = false },
    { id = 'RAIN', label = 'Rain', icon = 'rain', rain = 0.4, wind = 2.0, snow = false },
    { id = 'THUNDER', label = 'Thunder', icon = 'thunder', rain = 0.8, wind = 8.0, snow = false },
    { id = 'SNOWLIGHT', label = 'Light Snow', icon = 'snowlight', rain = 0.0, wind = 1.0, snow = true },
    { id = 'SNOW', label = 'Snow', icon = 'snow', rain = 0.0, wind = 2.5, snow = true },
    { id = 'BLIZZARD', label = 'Blizzard', icon = 'blizzard', rain = 0.0, wind = 12.0, snow = true },
    { id = 'XMAS', label = 'Christmas', icon = 'xmas', rain = 0.0, wind = 0.5, snow = true },
    { id = 'HALLOWEEN', label = 'Halloween', icon = 'halloween', rain = 0.0, wind = 1.5, snow = false }
}

function Config.CopyState(source)
    local src = source or Config.Defaults
    return {
        hour = src.hour,
        minute = src.minute,
        weather = src.weather,
        freeze = src.freeze,
        blackout = src.blackout,
        dynamic = src.dynamic,
        instantTime = src.instantTime,
        h24 = src.h24,
        instantWeather = src.instantWeather,
        tsunami = src.tsunami
    }
end

function Config.WeatherById(id)
    for i = 1, #Config.Weathers do
        if Config.Weathers[i].id == id then
            return Config.Weathers[i]
        end
    end
end
