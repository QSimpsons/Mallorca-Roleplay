# Snelle Events — Installatie (ESX)

## 1. SQL importeren

Importeer `sql/snelle_events.sql` in je database via:
- phpMyAdmin
- HeidiSQL
- of CLI: `mysql -u root -p jouw_database < sql/snelle_events.sql`

Tabellen:
- `snelle_events` — event geschiedenis
- `snelle_event_players` — deelnemers per event
- `snelle_event_stats` — speler stats (wins, kills, rewards)

## 2. Resource plaatsen

Kopieer de map `snelle-events` naar je `resources` folder.

## 3. server.cfg

```cfg
ensure es_extended
ensure oxmysql
ensure snelle-events

add_ace group.admin snelle-events.manage allow
add_ace group.admin snelle-events.host allow
```

## 4. Config

Open `config.lua`:
- `Config.Teleport.onJoin = true` → `/joinevent` spawnt op eventlocatie
- `Config.Database.enabled = true` → logs opslaan in SQL
- ESX groepen: admin / superadmin / mod

## 5. Gebruik

| Commando | Wie | Actie |
|---|---|---|
| `/event` | Staff | Panel openen |
| `/event Meetup` | Staff | Snel event op jouw positie |
| `/joinevent` | Iedereen | Joinen + spawn op locatie |
| `/eventleave` | Iedereen | Verlaten |

## Dependencies

- es_extended (ESX Legacy)
- oxmysql (aanbevolen) of mysql-async
- ox_lib (optioneel, notificaties)
