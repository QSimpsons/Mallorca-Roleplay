# Eclipse Politie Garage

Licht NUI-menu voor politie-dienstvoertuigen — sidebar-categorieën, zoeken, favorieten, stats en spawn.

Geïnspireerd op moderne “police garage” menus (zoals Politi Garage), maar volledig Nederlands en afgestemd op Eclipse / ESX.

## Functies

- Schoon licht UI-panel met sidebar + voertuiggrid
- Categorieën: Favorieten, Patrouille, Onopvallend, Motor, Speciale eenheid, Luchtsteun
- Zoekbalk, favorieten (lokaal opgeslagen), performance-balken
- Spawn met kenteken, brandstof, extras/livery en sleutels
- Job- + rangcheck (`police`, minGrade per voertuig)
- Marker bij Mission Row + helikopterpad (aanpasbaar)
- Export: `exports['eclipse-politie-garage']:OpenPoliceGarage('mission_row')`

## Installatie

1. Zet `eclipse-politie-garage` in je `resources`-map.
2. In `server.cfg`:

```cfg
ensure es_extended
ensure eclipse-politie-garage
```

3. Pas in `config.lua` locaties, voertuigen en rangen aan.
4. Optioneel: `ox_lib` voor nettere notificaties; `jg-benzine` / key-resource voor brandstof en sleutels.

## Commands

| Command | Actie |
|---------|--------|
| `/politiegarage` | Opent de garage (dichtstbijzijnde of eerste) |
| `/parkeerpd` | Parkeert/verwijdert het huidige dienstvoertuig |

In-game: **E** bij de garage-marker om te openen, **E** bij de delete-spot om te parkeren, **ESC** om te sluiten.

## Preview in de browser

Open `html/preview.html` via een lokale webserver om het menu te bekijken zonder FiveM.

## Config tips

- Voeg custom packs toe in `Config.Vehicles` met `model`, `category`, `minGrade`, `stats` en optioneel `image`.
- Thumbnails standaard via `https://docs.fivem.net/vehicles/<model>.webp`.
- Beperk een garage tot bepaalde categorieën met `categories = { 'air' }`.
