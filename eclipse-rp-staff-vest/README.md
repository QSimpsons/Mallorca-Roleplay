# Eclipse RP — Staff Safety Vest (FiveM .ytd)

Ready-to-stream **texture dictionary** for an Eclipse RP black STAFF safety vest, built from your mockup.

## Wat zit erin

| Pad | Inhoud |
|---|---|
| `stream/mp_m_freemode_01^task_diff_001_a_uni.ytd` | Male freemode texture replace (armor/vest slot `task` #1, variant `a`) |
| `stream/mp_f_freemode_01^task_diff_001_a_uni.ytd` | Female variant (zelfde texture) |
| `textures/vest_diffuse.png` | 2048² flat front/back diffuse (bewerken in Photoshop/GIMP) |
| `textures/vest_diffuse_1024.png` | 1024² versie (in de gestreamde .ytd) |
| `textures/logo_back.png` / `logo_front.png` | Losse Eclipse RP logo’s |
| `textures/staff_text.png` | STAFF-tekst |
| `textures/eclipse_rp_staff_vest_assets.ytd` | Asset-pack met alle textures |
| `source/mockup.jpg` | Originele mockup |

## Installatie (FiveM)

1. Kopieer de map `eclipse-rp-staff-vest` naar je server `resources/` folder.
2. Zet in `server.cfg`:

```cfg
ensure eclipse-rp-staff-vest
```

3. Herstart de resource / server.
4. In-game: kies bij **Armor / Vest (component task)** drawable **1**, texture **0** (of je eigen slot als je hernoemt).

## Belangrijk over UV / model

De aangeleverde afbeelding is een **3D-mockup**, geen GTA UV-map.  
Deze resource bevat een **platte front/back template** + geldige `.ytd` (RSC7).  

Voor een **perfecte** pasvorm op een specifiek vest-model:

1. Open je vest `.ydd` in **OpenIV** → embedde texture exporteren (UV-template).
2. Plak `logo_back.png`, `logo_front.png` en `staff_text.png` op de juiste UV-plekken.
3. Vervang de diffuse in de `.ytd` (of run `tools/build_ytd.py` na het opslaan van je PNG).
4. Hernoem stream-bestanden zodat ze matchen met jouw drawable, bijvoorbeeld:

```text
mp_m_freemode_01^task_diff_00X_a_uni.ytd
```

De **interne textuurnaam** in de YTD moet gelijk zijn aan de bestandsnaam zonder ped-prefix (hier: `task_diff_001_a_uni`).

Zonder matching `.ydd` (of vanilla drawable met dezelfde textuurnaam) zie je de texture niet correct in-game.

## YTD opnieuw bouwen

```bash
pip install pillow texfury
# Op Linux: texfury native DLL stubben (zie tools), of bouw op Windows.
python3 tools/build_ytd.py
```

## Credits

- Design / mockup: Eclipse RP
- Texture pack & `.ytd` build: generated for FiveM streaming
