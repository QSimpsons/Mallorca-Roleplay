# Installatie

1. Pak `snelle-voertuigduwen.zip` uit in je `resources`-map. Daar zit de resource én `sql/install.sql`.
2. Importeer `snelle-voertuigduwen/sql/install.sql` in je database. Dat maakt `snelle_voertuig_duwen` en `snelle_voertuig_duwen_stats`.
3. Zet in `server.cfg`, ná `oxmysql`, `es_extended` en `ox_lib`:

```cfg
ensure oxmysql
ensure es_extended
ensure ox_lib
ensure ox_target
ensure snelle-voertuigduwen
```

`ox_lib` en `ox_target` zijn niet verplicht. Zonder `ox_lib`: comment in `fxmanifest.lua` de regel `@ox_lib/init.lua` uit. Meldingen vallen dan terug op ESX, en zonder target gebruik je `[G]`, `[H]` en de commands.

4. Herstart de server, of:

```
ensure snelle-voertuigduwen
```

5. Toetsen staan de eerste keer op `G` (duwen) en `H` (aan de kant). Spelers kunnen ze daarna zelf wijzigen bij **Instellingen → Toetskoppelingen → FiveM**. Een latere wijziging in `config.lua` overschrijft een al opgeslagen toets niet.

## Alleen hulpdiensten

In `config.lua`:

```lua
Config.AllowedJobs = { 'police', 'anwb', 'mechanic' }
Config.RequireOnDuty = true
```

Jobnamen moeten overeenkomen met je ESX-jobs.

## Alleen kapotte auto's

```lua
Config.RequireBroken = true
Config.BrokenEngineHealth = 350.0
```

## Toetsenbord

Standaard werken AZERTY en QWERTY allebei tijdens het duwen: `Z`/`S` of `W`/`S` vooruit en achteruit, `Q`/`D` of `A`/`D` links en rechts.

Alleen AZERTY:

```lua
Config.Keyboard = 'azerty'
```

## Taal

`Config.Locale = 'nl'` of `'en'`.
