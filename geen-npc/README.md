# geen-npc

FiveM-resource die de stad leeg houdt: geen voetgangers, geen NPC-verkeer en geen geparkeerde NPC-auto's.

Script-NPC's van jobs, shops en andere resources blijven staan. Alleen ambient spawns van GTA zelf worden tegengehouden en opgeruimd.

## Installatie

1. Zet de map `geen-npc` in je `resources`.
2. Voeg dit toe aan `server.cfg`:

```cfg
set onesync_population false
ensure geen-npc
```

`onesync_population false` stopt de server-side ambient spawns. De resource zet daarnaast de client-density op 0 en schakelt population uit in de routing buckets van spelers.

## Config

In `config.lua` kun je onderdelen apart aan laten staan, bijvoorbeeld alleen voetgangers weg en verkeer houden. `Config.DisableWantedLevel` zet de GTA-sterren uit, anders blijven er alsnog politie-NPC's komen.
