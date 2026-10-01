local Config = {}

Config.Debug = false -- zet op true voor extra print()s in de server-console (zie onderaan dit bestand hoe)

Config.Command = { 'staffdienst', 'staffduty', 'sd' } -- duty toggle
Config.PanelCommand = 'staffpanel'                     -- (niet meer in gebruik, kan verwijderd worden)
Config.SettingsCommand = 'staffsettings'               -- open het instellingen-menu voor de eigen staff-tag

-- Groepen die /sd, /staffdienst of /staffduty mogen gebruiken.
-- Dit zijn GEWONE groepnamen (zelfde als in ox_adminmenu's Config.AdminGroups).
-- Als ESX (esx_extended) draait, wordt xPlayer.getGroup() gebruikt.
-- Draait er geen ESX, dan valt dit terug op ACE-permissies met principal
-- "group.<naam>" (bv. group.admin) zodat je nog steeds via add_principal kan werken.
Config.AllowedGroups = {
    'owner',
    'admin',
    'mod'
}

Config.RankLabels = {
    { group = 'owner', label = 'Owner' },
    { group = 'admin', label = 'Admin' },
    { group = 'mod',   label = 'Mod'   },
}
Config.DefaultRank = 'Staff'

-- ======== Discord rollen (voor de rang + avatar in de tag) ========
-- Wie er WEL/NIET in dienst mag gaan blijft bepaald door Config.AllowedGroups
-- (ESX-groep / ACE) hierboven. Dit blok bepaalt alleen wat er in de tag wordt
-- GETOOND: als je dit aanzet, haalt de tag de echte Discord-rol (rang + kleur)
-- en de echte Discord-avatar van de speler op, i.p.v. de ESX-groep.
--
-- Vereist: een Discord bot die in je server (guild) zit, met het
-- "Server Members Intent" aangezet, en de discord: identifier gekoppeld
-- aan het FiveM-account (bv. via ESX/txAdmin discord-login).
Config.Discord = {
    enabled = true, -- zet op true zodra botToken + guildId zijn ingevuld
    botToken = GetConvar('staffduty_discord_token', ''), -- zet in server.cfg: set staffduty_discord_token "..."
    guildId = GetConvar('staffduty_discord_guildid', ''), -- zet in server.cfg: set staffduty_discord_guildid "..."
    updateInterval = 1500, -- ms, hoe vaak de rol van in-dienst zijnde staff ververst wordt
}

-- Koppel hier Discord role-ID's aan een naam/kleur/prioriteit.
-- Bij meerdere rollen wint de rol met de hoogste priority.
-- Vervang de ID's hieronder door je eigen Discord role-ID's (rechtermuisknop
-- op een rol in Discord -> "ID kopiëren", vereist Developer Mode aan).
Config.Ranks = {
    ['1532459408792223964'] = { name = 'Founder', priority = 102, color = '#ff0000' },
    ['1532459414982754495'] = { name = 'Eigenaar', priority = 101, color = '#ff2200' },
    ['1532459421215494285'] = { name = 'Mede Beheer', priority = 100, color = '#ff4400' },
    ['1532459427947352085'] = { name = 'Raad V Beheer', priority = 99, color = '#ff6600' },
    ['1532459447052538006'] = { name = 'Assistent Beheer', priority = 98, color = '#ff8800' },
    ['1532459454040375507'] = { name = 'Beheer team', priority = 97, color = '#ffaa00' },
    ['1532459460768038932'] = { name = 'Lead Development', priority = 96, color = '#ffcc00' },
    ['1532459468112007420'] = { name = 'Development Team', priority = 95, color = '#ffee00' },
    ['1532459474382749906'] = { name = 'Development', priority = 94, color = '#ffd700' },
    ['1532459480355442951'] = { name = 'Skinner+', priority = 93, color = '#ffc107' },
    ['1532459492166340608'] = { name = 'Eclipse Boekhouder', priority = 92, color = '#ffb300' },
    ['1532459497577119756'] = { name = 'Eclipse  Head Executive', priority = 91, color = '#ffa000' },
    ['1532459502585254069'] = { name = 'Eclipse  Senior Executive', priority = 90, color = '#ff8f00' },
	['1532459508087918712'] = { name = 'Chief Executive Manager', priority = 89, color = '00FBFF' },
    ['1532459513725194340'] = { name = 'Operationeel Directeur', priority = 88, color = '#5b2ac3' },
    ['1532459520364904610'] = { name = 'Premier off  Eclipse', priority = 87, color = '#00ff66' },
    ['1532459526228541570'] = { name = 'Minister President', priority = 86, color = '#00ee66' },
    ['1532459533333692568'] = { name = 'The Gouveneur+', priority = 85, color = '#00dd66' },
    ['1532459538136170506'] = { name = 'Eclipse  Master Chief', priority = 84, color = '#00cc66' },
    ['1532459544209395944'] = { name = 'Eclipse  Officer', priority = 83, color = '#00bb66' },
    ['1532459562718990487'] = { name = 'Eclipse  Lead CEO', priority = 82, color = '#00aa66' },
    ['1532459568452341900'] = { name = 'Eclipse  CEO', priority = 81, color = '#0099ff' },
    ['1532459575834448053'] = { name = 'Eclipse  Vice CEO', priority = 80, color = '#0088ff' },
    ['1532459581135913061'] = { name = 'Hoofd Voorzitter', priority = 79, color = '#0077ff' },
    ['1532459586265681951'] = { name = 'Voorzitter', priority = 78, color = '#0066ff' },
    ['1532459590963302633'] = { name = 'Vice voorzitter', priority = 77, color = '#0055ff' },
    ['1532459597460275270'] = { name = 'The Dictator', priority = 76, color = '#0044ff' },
    ['1532459603785158856'] = { name = 'Rechter', priority = 75, color = '#9900ff' },
    ['1532459610693308477'] = { name = 'Ministerie', priority = 74, color = '#8800ff' },
    ['1532459618779922583'] = { name = 'Eclipse  Elite', priority = 73, color = '#7700ff' },
    ['1532459625197211839'] = { name = 'Eclipse  architect', priority = 72, color = '#6600ff' },
    ['1532459629181796532'] = { name = 'Eclipse  Analyst', priority = 71, color = '#5500ff' },
    ['1532459633887674399'] = { name = 'Eclipse  Onderhouder', priority = 70, color = '#ff66cc' },
    ['1532459639189274708'] = { name = 'Bestuur', priority = 69, color = '#ff55bb' },
    ['1532459645954822254'] = { name = 'Mede bestuur', priority = 68, color = '#ff44aa' },
    ['1532459651734569143'] = { name = 'Hoofd directeur', priority = 67, color = '#ff3399' },
    ['1532459658038739144'] = { name = 'Directeur', priority = 66, color = '#ff2288' },
    ['1532459665286238320'] = { name = 'Vice directeur', priority = 65, color = '#ff1199' },
    ['1532459671707717732'] = { name = 'Lead director', priority = 64, color = '#ff00aa' },
    ['1532459676115927061'] = { name = 'director', priority = 63, color = '#ff55ff' },
    ['1532459681589493840'] = { name = 'Vice director+', priority = 62, color = '#ee44ee' },
    ['1532459686970786034'] = { name = 'Adviseur', priority = 61, color = '#dd33dd' },
    ['1532459693275091187'] = { name = 'Eclipse  operator', priority = 60, color = '#ffaa00' },
    ['1532459700397019436'] = { name = 'Eclipse  Enforcer', priority = 59, color = '#ffbb22' },
    ['1532459708336832532'] = { name = 'President', priority = 58, color = '#ffcc44' },
    ['1532459715424948404'] = { name = 'Burgemeester', priority = 57, color = '#ffaa66' },
    ['1532459721376792676'] = { name = 'Hoge raad', priority = 56, color = '#ffbb77' },
    ['1532459732164542676'] = { name = 'Senior Manager', priority = 55, color = '#ffcc88' },
    ['1532459737814139010'] = { name = 'Head Supervisor', priority = 54, color = '#66ff99' },
    ['1532459744034296009'] = { name = 'Supervisor', priority = 53, color = '#99ff66' },
    ['1532459750330208347'] = { name = 'Jr Supervisor', priority = 52, color = '#cccccc' },
    ['1532459757435228202'] = { name = 'hoofd management', priority = 51, color = '#cd7f32' },
    ['1532459764062097428'] = { name = 'Management', priority = 50, color = '#55ff55' },
    ['1532459770190233610'] = { name = 'Jr management', priority = 49, color = '#44ee44' },
    ['1532459776531763350'] = { name = 'Headstaff', priority = 48, color = '#33dd33' },
    ['1532459781510664253'] = { name = 'Super Admin', priority = 47, color = '#00ffaa' },
    ['1532459787747590204'] = { name = 'Admin', priority = 46, color = '#00ddff' },
    ['1532459793569022126'] = { name = 'Jr Admin', priority = 45, color = '#00bbff' },
    ['1532459800775102635'] = { name = 'Super Moderator', priority = 44, color = '#0099ff' },
    ['1532459806848192682'] = { name = 'Moderator', priority = 43, color = '#777777' },
    ['1532459813676781790'] = { name = 'Junior Moderator', priority = 42, color = '#666666' },
	['1532459832546820218'] = { name = 'Content Creator', priority = 41, color = '2F00FF' },
}

Config.Outfits = {
    [`mp_m_freemode_01`] = {
        ['vest'] = { item = 101, texture = 0 },
    }
}

-- ======== Staff-tag boven het hoofd (NUI) ========
-- Iedereen in de buurt ziet een NUI-tagje (naam + rang + evt. avatar) boven het
-- hoofd van staff die in dienst is. Elke staff kan zijn eigen weergave aanpassen
-- via /staffsettings; die instellingen worden gesynchroniseerd naar andere clients.
--
-- BELANGRIJK: de afstandscheck gebeurt op de SERVER (met de echte, altijd
-- correcte positie van elke speler), niet meer client-side. Dat voorkomt dat
-- een tag "blijft hangen" op een oude/verkeerde positie als iemand buiten je
-- streaming-bereik gaat.
Config.Tag = {
    enabled = true,
    maxDistance = 25.0,   -- meter, buiten deze afstand wordt niks getekend
    updateInterval = 500, -- ms, hoe vaak de server checkt wie waar in de buurt is

    -- Kleur per rang, gebruikt voor de rank-regel in de tag.
    -- Rang-namen moeten overeenkomen met de 'label' velden in Config.RankLabels hierboven.
    rankColors = {
        Owner = { 255, 55, 55 },   -- rood
        Admin = { 40, 190, 255 },  -- blauw
        Mod   = { 80, 200, 255 },  -- lichtblauw
    },
    defaultRankColor = { 255, 255, 255 }, -- fallback (bv. voor Config.DefaultRank = 'Staff')

    -- Standaard weergave-instellingen voor spelers die nog nooit /staffsettings
    -- hebben geopend/opgeslagen. Elke speler kan dit zelf aanpassen; die keuze
    -- wordt bewaard (in-memory, per license) en gesynchroniseerd naar andere clients.
    defaultSettings = {
        tagEnabled = true,
        tagSize = 1.0,
        backgroundOpacity = 0.7,
        borderRadius = 12,
        showRank = true,
        showAvatar = true,
    },

    defaultAvatar = 'https://cdn.discordapp.com/embed/avatars/0.png',
    uiColor = '#1e7aff', -- accentkleur van het instellingen-menu (Eclipse blauw)
}

return Config
