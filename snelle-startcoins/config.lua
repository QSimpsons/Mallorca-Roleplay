Config = {}

-- ═══════════════════════════════════════════════════════════════
-- Snelle Startcoins · ESX Legacy
-- Elke nieuwe speler krijgt eenmalig startcoins.
-- ═══════════════════════════════════════════════════════════════

-- Hoeveel coins een nieuwe speler krijgt.
Config.Amount = 10000

-- ESX-account waar de coins op komen.
-- 'money' = contant (staat op elke ESX-server, direct zichtbaar)
-- 'bank'  = op de bank
-- Eigen account (bijv. 'coins') werkt alleen als dat account in es_extended staat.
Config.Account = 'money'

-- 'add' = tel het bedrag op bij wat de speler al heeft
-- 'set' = zet dit account exact op Config.Amount
Config.Mode = 'add'

-- Naam in de melding naar de speler.
Config.CoinLabel = 'coins'

-- true  = alleen nieuwe characters (char1, char2, ... krijgen elk hun eigen coins)
-- false = één keer per license (char1:license:abc en char2:license:abc delen één uitkering)
Config.OncePerCharacter = true

-- ESX geeft bij een nieuw character isNew = true. Dat is de normale weg.
-- Valt ESX dat niet door (of mislukte de uitkering), dan telt created_at in `users`.
-- Alleen characters die korter dan dit aantal seconden bestaan komen dan in aanmerking.
Config.UseCreatedAtFallback = true
Config.NewPlayerWindowSeconds = 180

-- Groepen die /geefstartcoins mogen gebruiken, naast ace command.geefstartcoins.
Config.AdminGroups = { 'admin', 'superadmin' }

Config.Messages = {
    received = 'Welkom! Je hebt %s %s ontvangen.',
    adminGranted = '%s %s gegeven aan %s.',
    adminReceived = 'Je hebt %s %s ontvangen van staff.',
    already = 'Deze speler heeft de startcoins al gehad.',
    noPlayer = 'Speler niet gevonden.',
    noPermission = 'Je hebt geen rechten voor dit commando.',
    failed = 'Startcoins konden niet worden gegeven. Controleer Config.Account.',
    usage = 'Gebruik: geefstartcoins [id] [force]'
}
