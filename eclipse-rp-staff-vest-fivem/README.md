# Eclipse RP — Staff Hesje (FiveM)

Kant-en-klare resource. Alleen reflecterende stroken (zilver), **geen glow**.

## Installatie

1. Zet de map `eclipse-rp-staff-vest-fivem` in je `resources/` folder
2. In `server.cfg`:

```cfg
ensure eclipse-rp-staff-vest-fivem
```

3. Herstart resource/server
4. In-game: **Armor / Vest (task)** → drawable **1**, texture **0**

## Bestanden

- `stream/mp_m_freemode_01^task_diff_001_a_uni.ytd` (male)
- `stream/mp_f_freemode_01^task_diff_001_a_uni.ytd` (female)
- `fxmanifest.lua`

Als je een ander vest-drawable nummer gebruikt, hernoem de `.ytd` zodat die matcht
(bijv. `task_diff_005_a_uni`) — de interne textuurnaam moet gelijk zijn aan de naam
zonder ped-prefix.
