# Eclipse RP — Staff Hesje (FiveM Addon)

Volledige addon-resource met **.ydd**, **.ytd**, **.ymt** en **.meta**.

## Installatie

1. Zet `eclipse-rp-staff-vest-fivem` in `resources/`
2. In `server.cfg`:

```cfg
ensure eclipse-rp-staff-vest-fivem
```

3. Herstart de resource/server
4. In-game (male freemode): **Armor / Vest (task)** → kies het **Eclipse staff** item
   (meestal de **laatste** armor-opties van deze addon-collectie)

## Bestanden

```
eclipse-rp-staff-vest-fivem/
  fxmanifest.lua
  mp_m_freemode_01_eclipse_staffvest.meta
  stream/
    mp_m_freemode_01_eclipse_staffvest.ymt
    mp_m_freemode_01_eclipse_staffvest/
      mp_m_freemode_01_eclipse_staffvest^task_000_u.ydd ... task_003_u.ydd
      mp_m_freemode_01_eclipse_staffvest^task_diff_000_a_uni.ytd ... task_diff_003_a_uni.ytd
```

- Drawable **0** (task_000): beste match voor onze square staff-texture (2048²)
- Drawables 1–3: zelfde branding, andere UV-resolutie van het basismodel

## Credits

- 3D vest models (`.ydd`) & `.ymt`: adapted from [WolfPack-Development/military-police_vestpack](https://github.com/WolfPack-Development/military-police_vestpack) (MIT)
- Textures / branding: Eclipse RP Staff design
