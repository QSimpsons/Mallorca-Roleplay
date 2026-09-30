# Eclipse Roleplay HUD

Custom FiveM HUD in **STA-stijl** (pill bars + icon kolom), blauw thema, met Eclipse logo.

## Layout (rechtsonder)

```
[ ID  #42              ]  [LOGO]
[ Job 2  Staff|Beheer  ]  [Food]
[ Job 1  Politie|...   ]  [Drink]
[ €cash ] [ €bank ] [ €zwart ]
```

## Installatie

1. Zet `eclipse-hud` in je resources-map
2. In `server.cfg`:

```cfg
ensure eclipse-hud
```

3. Zet oude HUD’s uit die overlappen
4. Preview: open `html/preview.html` in de browser

## Commands

| Command | Actie |
|---------|--------|
| `/togglehud` of `/hud` | HUD aan/uit |

## Config

`config.lua` — framework, job labels, geld, locatie, voice.
