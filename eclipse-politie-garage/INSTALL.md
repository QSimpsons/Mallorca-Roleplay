# Installatie — Eclipse Politie Garage

1. Kopieer de map `eclipse-politie-garage` naar je server `resources/`.
2. Voeg toe aan `server.cfg` (na `es_extended`):

```cfg
ensure eclipse-politie-garage
```

3. Pas `config.lua` aan:
   - `Config.Garages` → coords/spawns naar jullie MLO
   - `Config.Vehicles` → jullie politie-addonmodellen
   - `Config.JobName` als jullie job anders heet

4. Herstart de resource: `ensure eclipse-politie-garage`

## Integratie met eclipse-politie

Je kunt het oude ox_lib garagemenu vervangen door:

```lua
exports['eclipse-politie-garage']:OpenPoliceGarage('mission_row')
```

of gewoon deze resource naast de politie-job draaien (eigen markers).
