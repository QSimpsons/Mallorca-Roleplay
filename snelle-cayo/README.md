# snelle-cayo

Lost Cayo Perico correct, zodat je geen blurry void meer ziet met alleen minimap + blips.

## Diagnose (jouw screenshot)

Op de screenshot:
- Minimap toont Cayo Perico
- Blips (vliegtuig, shop, weed, huis, etc.) zweven
- De 3D-wereld is een vage beige/blauwe plane

Dat betekent: **radar/blips werken, maar het eiland zelf (IPLs + island hopper) is niet (goed) geladen**, of je camera/speler zit onder de map.

In jullie `server.cfg` staat wel:

```cfg
sv_enforceGameBuild 3258
ensure [streaming]
ensure [MLO]
ensure [RTX]
```

Maar **geen** Cayo IPL / island-hopper resource. Game build 3258 bevat Cayo, maar FiveM activeert het eiland niet automatisch in freeroam.

## Installatie

1. Zet de map `snelle-cayo` in `resources/`
2. In `server.cfg`, **vóór** `[MLO]` / Cayo-maps:

```cfg
ensure snelle-cayo
# daarna pas:
ensure [streaming]
ensure [MLO]
```

3. Rechten voor de fix-teleport:

```cfg
add_ace group.admin command.cayofix allow
```

4. Server restart (of `ensure snelle-cayo`)

## Commands

| Command | Wie | Wat |
|---------|-----|-----|
| `/cayofix` | admin (ACE) | Forceer IPL reload + teleport naar Cayo airstrip |
| `/cayostatus` | iedereen | Check of de loader draait |

## Config

`config.lua`:

- `AlwaysLoaded` – eiland altijd aan (meestal `false`)
- `SafeCoords` – landingspunt voor `/cayofix`
- `UnderMapZ` – waarschuwing als je onder de grond zit

## Als het daarna nog mis gaat

1. **Dubbele Cayo-loaders** – stop andere island/cayo scripts (`cayo_perico`, `pmms` island packs, etc.)
2. **Map-conflict in `[streaming]` / `[MLO]`** – zet recent toegevoegde Cayo-MLO’s tijdelijk uit
3. **`[RTX]`** – grafische packs kunnen texture/LOD-problemen versterken; test met `stop` op die map
4. **CDN** – als `fileserver_add` (vibegames CDN) faalt, streamen ymaps niet; check of assets lokaal laden
5. **Game build 3258** – kent bekende SLOD/loading quirks; als alleen LODs stickig zijn, is dat een client/build issue, niet dit script

## Let op

`[streaming]` / `[MLO]` / bob74 staan niet in deze GitHub-repo (alleen op de live VibeGames-server). Deze resource dekt de ontbrekende Cayo freeroam-loader.
