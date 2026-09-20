# Snelle Handcarwash

ESX-script waarmee spelers een voertuig **met de hand wassen**. Alle benodigde items zitten in de SQL / ox_inventory lijst. Er is een eigen winkel en je kunt emmers vullen bij kranen of in open water.

## Features

- Handwas overal, zolang je de juiste items hebt
- 5 was-types: basis, compleet, premium + wax, alleen velgen, alles-in-één set
- Emmer vullen bij waterpunten of in zee/rivier
- Winkel-NPC's + blips op GTA carwash-locaties
- ESX items-tabel **en** ox_inventory
- ox_target / qtarget, of `[E]` + markers
- ox_lib progress/menu, met native fallback
- Server-side itemcheck: items gaan er pas af na een geslaagde was
- Wax houdt het voertuig een instelbare tijd extra schoon
- Nederlands (standaard) en Engels

## Installatie

Zie [INSTALL.md](INSTALL.md).

## Items

| Spawn naam | Label | Verbruik |
|---|---|---|
| `empty_bucket` | Lege emmer | Nee (wordt `water_bucket`) |
| `water_bucket` | Emmer water | Ja (wordt weer leeg) |
| `car_sponge` | Autospong | Nee |
| `car_soap` | Autoshampoo | Ja |
| `microfiber_cloth` | Microvezeldoek | Ja |
| `car_wax` | Autowax | Ja |
| `tire_cleaner` | Velgenreiniger | Ja |
| `hand_carwash_kit` | Handwas set | Ja |

## Commando's

| Commando | Actie |
|---|---|
| `/handwas` | Open was-menu bij het dichtstbijzijnde voertuig |
| `/handwas basic` | Direct basis-handwas |
| `/handwaskoop` | Open de winkel (of koop als je bij een NPC bent) |

## Bestand

```
snelle-handcarwash/
├── fxmanifest.lua
├── config.lua
├── INSTALL.md
├── client/
├── server/
├── shared/
├── locales/
└── sql/
    ├── items.sql
    └── ox_inventory_items.lua
```
