# POLITIE 3D logo

Streamable FiveM-prop van het Nederlandse POLITIE-woordmerk, als 3D-letters met gouden embleem.

Het gouden logo zit **iets hoger** dan op de referentiefoto, zodat er meer van de blauwe O zichtbaar blijft.

## Gebruik

1. Zet de resource `politie_logo` in je resources-map en start hem.
2. Spawn het object `politie_logo` (CodeWalker, Object Spawner, of script).

Breedte is ongeveer **6 meter**. Schalen kan via de entity-scale of in je ymap.

```lua
local hash = `politie_logo`
RequestModel(hash)
while not HasModelLoaded(hash) do Wait(0) end
CreateObject(hash, x, y, z, false, false, false)
```

## Bestanden

- `stream/politie_logo.ydr` — drawable (blauw + goud, textures embedded)
- `stream/politie_logo.ytyp` — archetype `politie_logo`

Opnieuw bouwen: `python tools/politie_logo/build_politie_logo.py`
