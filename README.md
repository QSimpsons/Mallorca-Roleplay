# Snelle Events

Volledig FiveM event-beheersysteem voor **Mallorca Roleplay**. Staff kunnen events aanmaken en beheren via een modern NUI-panel. Spelers kunnen deelnemen via commando's of het join-menu.

## Features

- **6 eventtypes**: Meetup, Race, PvP/Redzone, Sumo/Derby, Party, Custom
- **NUI beheerpaneel** voor staff (F6 of `/event`)
- **Join-menu** voor spelers (`/eventjoin`)
- **Teleportatie** naar eventlocatie met terugkeer naar originele positie
- **Countdown timer** voor event start
- **Blips** op de kaart voor actieve events
- **Beloningssysteem** (ESX/QBCore)
- **Discord webhook** logging
- **Meertalig**: Nederlands & Engels
- **Framework support**: ESX, QBCore, Standalone (auto-detect)

## Installatie

1. Plaats de `snelle-events` map in je `resources` folder
2. Voeg toe aan je `server.cfg`:

```cfg
ensure snelle-events

# Permissies (kies één of beide)
add_ace group.admin snelle-events.manage allow
add_ace group.admin snelle-events.host allow
add_principal identifier.license:YOUR_LICENSE group.admin
```

3. Pas `config.lua` aan naar wens (framework, beloningen, locaties, webhook)

## Commando's

| Commando | Beschrijving |
|---|---|
| `/event` | Open staff beheerpaneel |
| `/eventjoin` | Open join-menu of `/eventjoin [id]` |
| `/eventleave` | Verlaat huidig event |
| `/eventinfo` | Toon info over je huidige event |

## Toetsen

| Toets | Actie |
|---|---|
| `F6` | Open event panel (staff) |

## Eventtypes

| Type | Beschrijving |
|---|---|
| `meetup` | Verzameling / community event |
| `race` | Race met voertuig spawn |
| `pvp` | PvP gevecht met wapens |
| `derby` | Auto sumo derby |
| `party` | Feest / sociaal event |
| `custom` | Vrij instelbaar |

## Exports

```lua
-- Event aanmaken vanuit ander script
exports['snelle-events']:CreateEvent(source, {
    name = 'Mijn Event',
    type = 'meetup',
    maxPlayers = 32
})

-- Actieve events ophalen
local events = exports['snelle-events']:GetActiveEvents()

-- Check of speler in event zit
local inEvent = exports['snelle-events']:IsPlayerInEvent(source)
```

## Configuratie

Alle instellingen staan in `snelle-events/config.lua`:

- Framework detectie (`auto`, `esx`, `qbcore`, `standalone`)
- Permissies (ACE, ESX groepen, QBCore permissions)
- Eventtypes en standaardinstellingen
- Voorgedefinieerde locaties
- Beloningen voor winnaar en deelnemers
- Discord webhook URL

## Resources

- [FiveM Documentation](https://docs.fivem.net/)
- [Mallorca Roleplay](https://github.com/QSimpsons/Mallorca-Roleplay)
