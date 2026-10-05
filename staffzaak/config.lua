Config = {}

-- Chatcommando zonder slash. /staffzaak wisselt, /staffzaak aan en /staffzaak uit dwingen een status.
Config.Command = 'staffzaak'

-- Seconden tussen twee wissels.
Config.Cooldown = 2

-- true: alleen staff mag het commando gebruiken.
Config.RequirePermission = true

-- Ace-permissies die staffdienst mogen. `command` dekt admins met de standaard txAdmin-ace
-- `add_ace group.admin command allow`. Haal die regel weg als je dat niet wilt.
Config.AllowedAces = {
    'staffzaak.duty',
    'command.staffzaak',
    'command',
}

-- ESX-groep, QBCore/Qbox-permissie. Hoofdletters maken niet uit.
Config.AllowedGroups = {
    'helper',
    'mod',
    'moderator',
    'admin',
    'superadmin',
    'staff',
    'management',
    'beheer',
    'hoofdstaff',
    'god',
}

-- Optioneel: ESX- of QBCore-jobnamen. Leeg = niet op job controleren.
Config.AllowedJobs = {}

-- Wie ziet het bericht dat iemand in of uit dienst gaat: 'staff', 'everyone' of 'none'.
Config.AnnounceTo = 'staff'

-- Bericht ook in de chat zetten.
Config.ChatMessages = true

-- Tekst boven staff die in dienst is.
Config.ShowTag = true
Config.TagText = 'STAFF'
Config.TagDistance = 25.0
Config.TagColor = { 255, 196, 64, 230 }
-- 'everyone' of 'staff' (alleen zichtbaar voor mensen die zelf in dienst zijn).
Config.TagVisibility = 'everyone'
Config.ShowOwnTag = false
Config.LabelText = 'STAFFDIENST'
Config.LabelPosition = { x = 0.5, y = 0.025 }

-- Staffkleding. Laat uit tot de drawable-nummers van jouw kledingpack kloppen.
Config.UseOutfit = false
Config.Outfit = {
    male = {
        components = {
            -- [componentId] = { drawable = 0, texture = 0 },
            -- 3 armen, 4 broek, 6 schoenen, 8 shirt, 11 jas, 9 vest
        },
        props = {
            -- [propId] = { drawable = -1, texture = 0 }, -- -1 haalt het item weg
        },
    },
    female = {
        components = {},
        props = {},
    },
}

Config.Messages = {
    onDuty = 'Je bent nu in staffdienst.',
    offDuty = 'Je bent uit staffdienst gegaan.',
    alreadyOn = 'Je bent al in staffdienst.',
    alreadyOff = 'Je bent niet in staffdienst.',
    noPermission = 'Je hebt geen toestemming om in staffdienst te gaan.',
    cooldown = 'Wacht even voordat je staffdienst opnieuw wisselt.',
    usage = 'Gebruik /staffzaak, /staffzaak aan of /staffzaak uit.',
    staffJoined = '%s is in staffdienst gegaan.',
    staffLeft = '%s is uit staffdienst gegaan.',
}

if type(Config.Command) ~= 'string' or not Config.Command:match('^[%w_-]+$') then
    Config.Command = 'staffzaak'
end
