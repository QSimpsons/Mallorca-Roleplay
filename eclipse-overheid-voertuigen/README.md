# Eclipse Overheid Voertuigen

Maakt overheids-/hulpdienstvoertuigen **0 damage**: kogelvrij, invincible, geen schade (banden/motor/body blijven heel).

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

- Met job `police` / `ambulance`: **elke** auto waarin je zit krijgt 0 damage (ook custom PD-addons)
- Extra match op spawnmodellen + emergency-class 18
- Stilstaand: automatische full repair (motorkap/deuren/deuken)
- Tijdens rijden: geen `SetVehicleFixed` (voorkomt haperen)
- Geen snelheidslimiet — sneller dan 295 mag
- Command: `/repairovh` (stilstaand) om schade meteen weg te halen
- Export na spawn:

```lua
exports['eclipse-overheid-voertuigen']:ProtectVehicle(vehicle)
```

## Let op

Dit is **client-side**. Elke speler past bescherming toe op voertuigen die aan de checks voldoen. Voor anti-cheat / sync is dat normaal genoeg voor RP; wil je het strikt server-side, zeg het even.
