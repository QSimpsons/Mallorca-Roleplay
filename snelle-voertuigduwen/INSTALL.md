# Installatie

1. Zet de map `snelle-voertuigduwen` in je `resources` (of pak `snelle-voertuigduwen.zip` uit).
2. Zet in `server.cfg`, ná `es_extended` en `ox_lib`:

```cfg
ensure es_extended
ensure ox_lib
ensure ox_target
ensure snelle-voertuigduwen
```

`ox_lib` en `ox_target` zijn niet verplicht. Zonder `ox_lib`: comment in `fxmanifest.lua` de regel `@ox_lib/init.lua` uit. Meldingen vallen dan terug op ESX, en zonder target gebruik je `[G]`, `[H]` en de commands.

3. Herstart de server, of:

```
ensure snelle-voertuigduwen
```

4. Toetsen staan de eerste keer op `G` (duwen) en `H` (aan de kant). Spelers kunnen ze daarna zelf wijzigen bij **Instellingen → Toetskoppelingen → FiveM**. Een latere wijziging in `config.lua` overschrijft een al opgeslagen toets niet.

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

## Taal

`Config.Locale = 'nl'` of `'en'`.
