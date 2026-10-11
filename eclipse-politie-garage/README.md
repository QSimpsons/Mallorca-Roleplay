# ECLIPSE RP — Politiegarage

Donkerblauw NUI-menu voor politie-dienstvoertuigen in de stijl van **ECLIPSE RP**.

## Functies

- ECLIPSE RP branding (logo, Exo 2, blauw thema)
- Nederlandse UI: categorieën, zoeken, favorieten, stats, **PAK VOERTUIG**
- Categorieën: Favorieten, Patrouille, Onopvallend, Motor, Speciale eenheid, Luchtsteun
- Spawn met kenteken, brandstof, extras/livery en sleutels
- Job- + rangcheck (`police`, minGrade per voertuig)
- Export: `exports['eclipse-politie-garage']:OpenPoliceGarage('mission_row')`

## Installatie

1. Zet `eclipse-politie-garage` in je `resources`-map.
2. In `server.cfg`:

```cfg
ensure es_extended
ensure eclipse-politie-garage
```

3. Pas in `config.lua` locaties, voertuigen en rangen aan.

## Commands

| Command | Actie |
|---------|--------|
| `/politiegarage` | Opent de garage |
| `/parkeerpd` | Parkeert het huidige dienstvoertuig |

**E** bij de marker om te openen · **ESC** om te sluiten.

## Eigen afbeeldingen

1. Zet je PNG/WebP in `html/img/vehicles/<model>.png` (bijv. `polargento1.png`).
2. Voeg het voertuig toe in **`config.lua`** (niet in `preview.html`):

```lua
image = 'img/vehicles/polargento1.png',
```

Of laat `image` weg als het bestand exact `<model>.png` heet — dan wordt het automatisch gevonden.

Gebruik geen imagetourls-viewerlinks (`/nl/v?u=...`). Alleen directe `.png`/`.webp`-urls of lokale bestanden.

## Preview

Open `html/preview.html` via een lokale webserver.
