# Fotodoek

Branded step-and-repeat fotodoek voor events en foto’s — zelfde soort backdrop als op RP-servers, met **Eclipse ROLEPLAY**-look (aanpasbaar).

Geen custom props nodig: het doek is een DUI-textuur op een metalen frame.

## Installatie

1. Zet de map `fotodoek` in je `resources` folder.
2. In `server.cfg`:

```
ensure fotodoek
add_ace group.admin fotodoek.manage allow
```

3. (Optioneel) pas merk, kleur en vaste locaties aan in `config.lua`.

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
