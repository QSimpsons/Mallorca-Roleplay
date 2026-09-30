# Eclipse Roleplay HUD

Volledige custom FiveM HUD in **Eclipse-blauw**, met jouw logo boven voeding/drinken en ID + jobs ernaast.

## Layout

```
┌──────────────────────────────────────┐
│   [LOGO]        │  ID       #42      │
│   Voeding ████  │  Job 2   Monteur  │
│   Drinken ████  │  Job 1   Politie  │
└──────────────────────────────────────┘
```

Ook inbegrepen:
- Health / armor / stamina / voice ringen (linksonder)
- Cash & bank
- Straat + zone
- ESX / QBCore / QBX auto-detect

## Installatie

1. Kopieer de map `eclipse-hud` naar `resources/[standalone]/` (of een andere map).
2. Zet in `server.cfg`:

```cfg
ensure eclipse-hud
```

3. Herstart de resource of de server:

```
ensure eclipse-hud
```

4. Optioneel: open `html/preview.html` in je browser om de look te checken zonder FiveM.

## Commands

| Command | Actie |
|---------|--------|
| `/togglehud` of `/hud` | HUD aan/uit |

## Config

Pas `config.lua` aan voor framework, job labels, geld, locatie en voice.

## Exports

```lua
exports['eclipse-hud']:SetVisible(true)
exports['eclipse-hud']:UpdateNeeds(80, 55)
exports['eclipse-hud']:Push()
```

## Events

```lua
TriggerEvent('eclipse-hud:client:setVisible', true)
TriggerEvent('eclipse-hud:client:updateNeeds', 80, 55)
```

## Framework notes

- **ESX**: hunger/thirst via `esx_status` (`esx_status:onTick`). Job2 via `esx:setJob2` / `PlayerData.job2` of `secondjob`.
- **QBCore / QBX**: needs via `PlayerData.metadata` + `hud:client:UpdateNeeds`. Job2 toont de gang als die gezet is.
- **Standalone**: defaults uit config; update needs via export/event.
