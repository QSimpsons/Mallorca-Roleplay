# Eclipse RP — Staff Hesje (FiveM)

Kant-en-klare staff-vest textures. **Alleen zilveren reflectoren — geen glow.**

## Snelle installatie (aanbevolen)

Gebruik de drop-in zip: `eclipse-rp-staff-vest-fivem.zip`

1. Unzip naar je server `resources/` folder
2. In `server.cfg`:

```cfg
ensure eclipse-rp-staff-vest-fivem
```

3. Herstart resource/server
4. In-game: **Armor / Vest (task)** → drawable **1**, texture **0**

## Wat zit erin

| Bestand | Doel |
|---|---|
| `stream/mp_m_freemode_01^task_diff_001_a_uni.ytd` | Male |
| `stream/mp_f_freemode_01^task_diff_001_a_uni.ytd` | Female |
| `fxmanifest.lua` | Resource manifest |

Optioneel in deze repo-map: bron-PNG's onder `textures/` en een lokale demo onder `demo/`.

## Hernoemen naar ander vest-slot

Als drawable `1` al bezet is, hernoem beide stream-bestanden én de interne textuurnaam naar bijv.:

```text
mp_m_freemode_01^task_diff_005_a_uni.ytd
```

(interne texture = `task_diff_005_a_uni`)
