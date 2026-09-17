# Snelle Events

Uitgebreid **FiveM ESX Legacy** event-systeem voor **Mallorca Roleplay**.

## Features

- **10 eventtypes**: Meetup, Race, PvP, Derby, Deathmatch, Manhunt, Hide & Seek, Party, Parachute Drop, Custom
- **Staff NUI panel** (`/event` / F6) met create, active list én spelerbeheer
- **Spelerlijst**: kick, promote host, set winner, invite
- **Race finishlijn** met auto-winnaar
- **Zone radius** met eliminatie bij te lang buiten
- **Deathmatch scoreboard** (kills/deaths)
- **Manhunt / Hide & Seek** rollen
- **Wachtwoord-events**, min/max spelers, duration timer
- **Markers + E** om te joinen
- **Invites** (`/eventinvite [id]`)
- **Spectate** (`/eventspectate`)
- Routing buckets, chat aankondigingen, ESX beloningen (1e/2e/3e)

## Installatie

```cfg
ensure es_extended
ensure ox_lib
ensure snelle-events
```

Zie `snelle-events/server.cfg.example`.

## Commando's & spawn

| Commando | Actie |
|---|---|
| `/event` | Staff panel openen |
| `/event [naam]` | Snel event op **jouw huidige positie** |
| `/joinevent` | Join-menu (of auto-join bij 1 event) → **spawn op eventlocatie** |
| `/joinevent [id]` | Direct joinen → **spawn op eventlocatie** |
| `/eventleave` | Verlaten → terug naar oude positie |
| `/eventinvite [id]` | Speler uitnodigen |
| `/eventspectate` | Spectate |
| `F6` | Panel openen |

Teleport staat in `config.lua` onder `Config.Teleport`:

```lua
Config.Teleport = {
    onJoin = true,              -- /joinevent → spawn op eventlocatie
    onCreate = true,            -- host ook op locatie bij create
    returnOnLeave = true,       -- /eventleave → terug
    autoJoinSingleEvent = true, -- 1 event = direct joinen
    quickCreateType = 'meetup', -- type bij /event [naam]
    spreadPlayers = true,       -- niet op elkaar spawnen
}
```

## Eventtypes

| Type | Gameplay |
|---|---|
| meetup | Verzameling |
| race | Finishlijn, eerste wint |
| pvp | Last man standing |
| derby | Auto sumo, zone |
| deathmatch | Meeste kills / score limiet |
| hunt | 1 target vs hunters |
| hideandseek | Hiders vs seekers |
| party | Sociaal |
| parachute | Drop vanuit de lucht |
| custom | Vrij |

## Exports

```lua
exports['snelle-events']:CreateEvent(source, { name = 'Event', type = 'meetup' })
exports['snelle-events']:GetActiveEvents()
exports['snelle-events']:IsPlayerInEvent(source)
exports['snelle-events']:SetWinner(source, eventId, winnerSource)
```
