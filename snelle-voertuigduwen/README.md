# Snelle Voertuigduwen

ESX-script om een stilstaand voertuig **aan de kant van de weg te duwen**. Je kunt het in één beweging de berm in schuiven, of zelf duwen en sturen.

## Gebruik

Sta naast een stilstaand voertuig (niet erin):

| Invoer | Actie |
|---|---|
| `[H]` of `/aandekant` | Schuift het voertuig zijwaarts de berm in |
| `[G]` of `/duw` | Duw zelf. AZERTY: `Z`/`S` vooruit en achteruit, `Q`/`D` links en rechts. QWERTY `W`/`A`/`S`/`D` werkt ook |
| `[X]` | Stoppen |
| ox_target / qtarget | **Aan de kant duwen** en **Duwen** op het voertuig |

Tijdens het aan de kant duwen loopt je personage mee en duwt. Het voertuig draait parallel aan de weg, de motor gaat uit en de alarmlichten blijven aan. `[X]` zet het neer waar het op dat moment staat.

Zonder weg in de buurt (parkeerplaats, terrein) schuift de auto naar zijn rechterkant.

## Voorwaarden

Standaard kan iedereen duwen, zolang het voertuig:

- stilstaat
- op de grond staat
- leeg is
- geen boot, helikopter, vliegtuig of trein is
- nergens aan vastzit (takel, trailer)

In `config.lua` kun je dit beperken tot banen (`police`, `anwb`, `mechanic`), alleen pechgevallen, of alleen voertuigen met uitgezette motor.

## Installatie

Pak `snelle-voertuigduwen.zip` uit in je `resources`-map, of kopieer de map `snelle-voertuigduwen`. Zie [INSTALL.md](INSTALL.md).

## Exports

Andere resources kunnen het zo aanroepen:

```lua
exports['snelle-voertuigduwen']:PushAside(vehicle)
exports['snelle-voertuigduwen']:StartPush(vehicle)
exports['snelle-voertuigduwen']:StopPush()
```

## Bestanden

```
snelle-voertuigduwen/
├── fxmanifest.lua
├── config.lua
├── client/main.lua
├── server/main.lua
├── shared/
└── locales/
    ├── nl.lua
    └── en.lua
```
