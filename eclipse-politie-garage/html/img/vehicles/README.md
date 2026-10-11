# Voertuig-afbeeldingen

Plaats hier je eigen foto’s. Bestandsnaam = **modelnaam** van het voertuig.

Voorbeelden:
- `polargento1.png`
- `police2.webp`

## In config.lua

```lua
{
    id = 'polargento1',
    label = 'Pol Argento',
    model = 'polargento1',
    category = 'patrol',
    minGrade = 1,
    badge = 'PATROUILLE',
    image = 'img/vehicles/polargento1.png', -- of weglaten als bestand = modelnaam.png
    stats = { speed = 80, accel = 76, brake = 72, handling = 78 },
},
```

## Belangrijk

- Pas **`config.lua`** aan, niet `preview.html` (dat is alleen browser-demo).
- Gebruik een **directe** image-url (`...png` / `...webp`), geen imagetourls-viewerpagina.
- Lokaal bestand is het meest betrouwbaar in FiveM.
- Na toevoegen: `ensure eclipse-politie-garage`
