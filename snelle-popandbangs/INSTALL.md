# Snelle Pop & Bangs — installatie

Pop & bangs voor ESX, stage 1 tot en met 6. Je bouwt het in met een item. Hogere stages geven meer knallen, vlammen en (vanaf stage 4) antilag.

Er is **geen SQL**. De items zet je in `ox_inventory`, de PNG's leg je in de images-map, en welk voertuig welke stage heeft staat in `data/installed.json` (per kenteken).

## Wat je nodig hebt

- `es_extended` (ESX Legacy)
- `ox_inventory`
- `ox_lib` (aanbevolen: progress, notify, keuzemenu)
- OneSync
- Optioneel: `ox_target` (inbouwen via het oogje op het voertuig)

De map moet `snelle-popandbangs` heten. De item-export verwijst naar die naam.

## 1. Resource

Kopieer de map `snelle-popandbangs` naar je `resources` folder.

## 2. Items (geen SQL)

1. Open `ox_inventory/data/items.lua`.
2. Plak de blokken uit `install/ox_inventory_items.lua` **tussen de andere items**. Vervang het bestand niet.
3. Kopieer de PNG's uit `install/images/` naar `ox_inventory/web/images/`:

- `popbang_stage1.png`
- `popbang_stage2.png`
- `popbang_stage3.png`
- `popbang_stage4.png`
- `popbang_stage5.png`
- `popbang_stage6.png`
- `popbang_remover.png`

4. Herstart `ox_inventory`.

## 3. server.cfg

```cfg
ensure ox_lib
ensure es_extended
ensure ox_inventory
ensure ox_target
ensure snelle-popandbangs
```

Geen `ox_lib`? Zet in `fxmanifest.lua` de regel `@ox_lib/init.lua` uit.

Staff-commands (niet verplicht):

```cfg
add_ace group.admin command.popbangset allow
add_ace group.admin command.popbangclear allow
```

## 4. Items geven

Als het item eenmaal in `items.lua` staat:

```
/giveitem [id] popbang_stage1 1
/giveitem [id] popbang_stage6 1
/giveitem [id] popbang_remover 1
```

## Gebruik

1. Sta naast een stilstaande auto, motor, of quad. Niet op een fiets, boot, heli of vliegtuig.
2. Gebruik het stage-item, of kijk met ox_target op het voertuig en kies **Pop & Bangs inbouwen**.
3. Het item gaat eraf als de inbouw lukt.
4. Een hogere stage vervangt een lagere. Een lagere stage kan pas nadat je de verwijderkit hebt gebruikt.
5. Stap in als bestuurder. Pops komen bij gas loslaten, bij schakelen, en bij stage 4–6 ook tijdens het gas geven.
6. `/popbang` dempt het geluid en de vlammen alleen bij jou. De inbouw blijft op het kenteken staan.

Het kenteken wordt bewaard zonder spaties. Een kentekenwissel haalt de stage niet automatisch mee.

## Stages

| Stage | Gedrag |
|---|---|
| 1 | Af en toe een zachte pop als je het gas loslaat |
| 2 | Vaker, soms twee knallen, kleine vlam |
| 3 | Bangs op twee uitlaten |
| 4 | Antilag en revven op de plaats |
| 5 | Harder, meer uitlaten, grotere vlam |
| 6 | Maximaal: korte cooldown, bursts, grote vlammen |

De tijden en kansen staan in `config.lua`.

## Geluid en anticheat

Standaard gaat er bij elke knal een onzichtbare explosie af (type 61, schade 0). Dat is het knalgeluid. Krijg je daar een anticheat-ban op, zet dan in `config.lua`:

```lua
Config.SoundMode = 'off'
```

De vlammen blijven dan werken.

## Monteur-only

Standaard mag iedereen met het item inbouwen. Alleen monteurs:

```lua
Config.RequireJob = true
Config.Jobs = { 'mechanic', 'tuner' }
```

## Staff

In de bestuurdersstoel, met de ace hierboven:

- `/popbangset 1` t/m `/popbangset 6` — stage zetten zonder item
- `/popbangclear` — stage eraf halen zonder verwijderkit

`data/installed.json` moet schrijfbaar zijn voor de server. Daar staan de kentekens in.
