# Eclipse Overheid Voertuigen

Maakt overheids-/hulpdienstvoertuigen **kogelvrij** en **onverwoestbaar** (geen schade, banden knappen niet, motor blijft heel).

## Installatie

1. Zet `eclipse-overheid-voertuigen` in je `resources`-map.
2. In `server.cfg`:

```cfg
ensure eclipse-overheid-voertuigen
```

3. Pas `config.lua` aan:
   - `Config.Models` → jullie politie/ambulance addon-modellen
   - `Config.Jobs` → welke jobs bescherming krijgen

## Gedrag

- Standaard: alleen met job `police` of `ambulance` (zie config)
- Match op spawnmodel (`polargento1`, `police`, …) en optioneel emergency-class 18
- Blijft elke seconde opnieuw toepassen (tegen damage-scripts)
- Export na spawn:

```lua
exports['eclipse-overheid-voertuigen']:ProtectVehicle(vehicle)
```

## Let op

Dit is **client-side**. Elke speler past bescherming toe op voertuigen die aan de checks voldoen. Voor anti-cheat / sync is dat normaal genoeg voor RP; wil je het strikt server-side, zeg het even.
