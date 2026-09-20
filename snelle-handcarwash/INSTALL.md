# Snelle Handcarwash — Installatie (ESX)

Handwas-script voor ESX Legacy: spelers wassen een voertuig **met items**, overal, met animatie. Inclusief winkel, waterpunten en SQL.

## Dependencies

- `es_extended` (ESX Legacy)
- `ox_lib` (aanbevolen: menu, progress, notify, target-tekst)
- Inventaris: `ox_inventory` **of** standaard ESX items-tabel
- Optioneel: `ox_target` of `qtarget`

## 1. Resource plaatsen

Kopieer de map `snelle-handcarwash` naar je `resources` folder.

## 2. SQL (ESX items-tabel)

Importeer `sql/items.sql` in je database:

- phpMyAdmin / HeidiSQL
- of CLI: `mysql -u root -p jouw_database < sql/items.sql`

Sectie A is voor ESX Legacy (`weight`).  
Faalt die query? Importeer dan `sql/esx_limit_items.sql` (`limit`).  
Wil je de items ook in 24/7? Importeer extra `sql/esx_shops.sql`. Niet verplicht: dit script heeft een eigen winkel.

## 3. ox_inventory (als je dat gebruikt)

1. Open `ox_inventory/data/items.lua`
2. Plak de inhoud van `sql/ox_inventory_items.lua` in de items-tabel
3. (Optioneel) zet iconen in `ox_inventory/web/images/` met deze namen:
   - `empty_bucket.png`
   - `water_bucket.png`
   - `car_sponge.png`
   - `car_soap.png`
   - `microfiber_cloth.png`
   - `car_wax.png`
   - `tire_cleaner.png`
   - `hand_carwash_kit.png`
4. Restart `ox_inventory`

SQL `items`-tabel is dan niet verplicht, de eigen winkel van dit script werkt via `ox_inventory` exports.

## 4. server.cfg

```cfg
ensure ox_lib
ensure es_extended
ensure ox_inventory
ensure ox_target
ensure snelle-handcarwash
```

Geen `ox_lib`? Zet in `fxmanifest.lua` de regel `@ox_lib/init.lua` uit. Het script valt dan terug op ESX notify + een simpele progressbalk.

## 5. Config

Open `config.lua`:

| Optie | Standaard | Betekenis |
|---|---|---|
| `Config.Locale` | `nl` | Taal (`nl` / `en`) |
| `Config.Inventory` | `auto` | `ox_inventory` of `esx` |
| `Config.PayAccount` | `money` | `money` of `bank` |
| `Config.Wash.requireEngineOff` | `false` | Motor verplicht uit |
| `Config.Wash.waxDurationMinutes` | `45` | Hoe lang wax vuil tegengaat |
| `Config.Shop.items` | — | Prijzen van de handwas-winkel |

## 6. Items & gebruik

| Item | Wat doet het |
|---|---|
| **Lege emmer** | Vul bij een kraan, winkel, of in zee/rivier (`[E]` of item gebruiken) |
| **Emmer water** | Verplicht voor een gewone handwas (wordt weer een lege emmer) |
| **Autospong** | Blijft in je inventory, opent het was-menu |
| **Autoshampoo** | 1 per basis/complete/premium was |
| **Microvezeldoek** | Complete was (afdrogen) |
| **Autowax** | Premium was, voertuig blijft langer schoon |
| **Velgenreiniger** | Alleen velgen, of als onderdeel van premium |
| **Handwas set** | Alles-in-één, wordt verbruikt |

**Wasbeurten**

- **Basis** — spons + shampoo + emmer water
- **Compleet** — basis + microvezeldoek
- **Premium** — compleet + wax + velgenreiniger
- **Wax** — alleen wax + microvezeldoek
- **Velgen** — velgenreiniger + spons
- **Set** — alleen `hand_carwash_kit`

## 7. Hoe wassen spelers?

1. Koop spullen bij een **Handwas winkel** (blip op de map, 4 locaties)
2. Vul de emmer bij een waterpunt of in open water
3. Ga naast een vies voertuig staan
4. Gebruik de **spons** / **set** in je inventory, of target het voertuig, of `/handwas`

Test-items (staff):

```
/giveitem [id] empty_bucket 1
/giveitem [id] car_sponge 1
/giveitem [id] car_soap 5
/giveitem [id] microfiber_cloth 5
/giveitem [id] car_wax 2
/giveitem [id] tire_cleaner 2
/giveitem [id] hand_carwash_kit 1
```

ox_inventory: `giveitem` via het admin-commando van ox, of `ox_inventory:AddItem`.

## Winkel-locaties

- Strawberry carwash
- Little Seoul carwash
- Davis
- Paleto Bay

Prijzen en coordinaten staan in `config.lua`.
