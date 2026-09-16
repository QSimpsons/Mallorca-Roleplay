# Snelle Events

Volledig **FiveM GTA Roleplay** event-beheersysteem voor **Mallorca Roleplay**. Staff kunnen events aanmaken en beheren via een modern NUI-panel. Spelers kunnen deelnemen via commando's of het join-menu.

> Werkt met **ESX**, **QBCore** en **Standalone** FiveM servers.

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

## Installatie (FiveM Server)

1. Download/plaats `snelle-events` in je `resources` folder
2. Kopieer de regels uit `snelle-events/server.cfg.example` naar je `server.cfg`
3. Start je server of run `ensure snelle-events` in de console
4. Pas `config.lua` aan:

| Instelling | Beschrijving |
|---|---|
| `Config.Framework` | `'auto'` detecteert ESX/QBCore automatisch |
| `Config.Notify` | `'auto'` gebruikt ox_lib, ESX of QBCore notify |
| `Config.UseRoutingBuckets` | Isoleert event spelers in aparte RP wereld |
| `Config.StripWeaponsOnJoin` | Neemt wapens af bij non-PvP events |
| `Config.Rewards` | Geld beloningen via ESX/QBCore |

### ESX Legacy server

```cfg
ensure es_extended
ensure ox_lib          # optioneel, aanbevolen
ensure snelle-events
```

### QBCore server

```cfg
ensure qb-core
ensure ox_lib          # optioneel, aanbevolen
ensure snelle-events
```

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
