# Fotodoek

Branded step-and-repeat fotodoek voor events en foto’s — zelfde soort backdrop als op RP-servers, met **Eclipse ROLEPLAY**-look (aanpasbaar).

Geen custom props nodig: het doek is een DUI-textuur op een metalen frame.
Het print loopt door als **vloerdoek** vóór het frame, zodat je op het doek staat voor de foto.

## Download

**Zip (klaar om te installeren):**  
https://github.com/QSimpsons/Mallorca-Roleplay/raw/cursor/fotodoek-backdrop-b3f6/downloads/fotodoek.zip

Of in de repo: [`downloads/fotodoek.zip`](../downloads/fotodoek.zip)

Pak uit in je `resources`-map → map `fotodoek` → `ensure fotodoek` in `server.cfg`.

## Installatie

1. Download/unzip `fotodoek.zip` naar je `resources` folder.
2. In `server.cfg`:

```
ensure fotodoek
add_ace group.admin fotodoek.manage allow
```

3. (Optioneel) pas merk, kleur en vaste locaties aan in `config.lua`.

## Vloerdoek

Standaard aan. Zelfde print ligt plat op de grond vóór het frame.

```lua
Config.VloerDoek = true
Config.VloerDiepte = 2.8   -- meter naar voren
Config.VloerHoogte = 0.018 -- licht boven de grond
Config.GrondOffset = 0.02  -- wanddoek bijna tot op de grond
```

Zet `Config.VloerDoek = false` als je alleen het staande doek wilt.

## Commando’s

| Commando | Actie |
|----------|--------|
| `/doek [naam]` | Plaats een doek iets achter je (jij staat er vóór) |
| `/doekverwijder` | Verwijder het dichtstbijzijnde dynamische doek |
| `/doeklijst` | Overzicht in F8 |

Bij `/doek` verschijnt in **F8** ook een regel die je in `Config.Doeken` kunt plakken voor een vaste spawn.

## Merk aanpassen

In `config.lua`:

```lua
Config.Brand = {
    title = 'ECLIPSE',
    subtitle = 'ROLEPLAY',
    background = '#0b2f7a',
    accent = '#3b82f6',
    textColor = '#ffffff',
    logo = 'img/logo.jpg' -- of '' voor alleen tekst
}
```

Vervang `html/img/logo.jpg` door je eigen ronde logo (PNG/JPG).

## Vaste locaties

```lua
Config.Doeken = {
    { label = 'Legion event', coords = vector3(195.50, -933.20, 30.69), heading = 140.0 },
}
```

- `coords` — midden van het doek op de grond  
- `heading` — kant waar de foto-voorkant naartoe wijst  

Dynamische doeken (via `/doek`) worden opgeslagen in `data/doeken.json` en blijven na een restart staan zolang `Config.OpslaanDynamisch = true`.

## Exports

```lua
local id = exports['fotodoek']:PlaceDoek(vector3(x, y, z), heading, 'Event doek')
exports['fotodoek']:RemoveDoek(id)
```

## Permissies

- ACE: `fotodoek.manage`
- Of ESX-groep uit `Config.EsxGroups` (`admin`, `superadmin`)
