# jg-anwb

ANWB / mechanic job.

## Fix: ontbrekende `Progress` export

Error:

```
SCRIPT ERROR: @jg-anwb/client/client.lua:872: No such export Progress in resource jg-progressbar
> callback (@ox_target/client/main.lua:443)
```

Oud (crash):

```lua
exports['jg-progressbar']:Progress({ ... }, function(cancelled) end)
```

Nieuw: `client/client.lua` v8 definieert `SafeProgress` bovenaan het bestand
(drop-in: alleen dit bestand overschrijven is genoeg). Het probeert
`Config.Progress` en valt terug op `ox_lib` `lib.progressBar`.

Als F8 nog `client.lua v6 geladen` toont, laadt de server het oude bestand.

Repareren, wassen en VIN-check gebruiken `SafeProgress`. Items (`repairkit` / `washand`) gaan pas van de speler af als de progress niet geannuleerd is.

## Vereisten

- `es_extended`
- `ox_lib`
- `oxmysql`
- `qtarget` of `ox_target`
- optioneel: `jg-progressbar` met een `Progress` export

In `server.cfg`:

```cfg
ensure ox_lib
ensure jg-anwb
```

`Config.Progress = 'jg-progressbar'` blijft de default. Zet dit op `'ox_lib'` of `'ox-circle'` om ox_lib altijd te gebruiken.

Optioneel: zet `ZET-IN-JG-PROGRESSBAR/Progress.lua` in je bestaande `jg-progressbar` zodat andere scripts dezelfde export ook kunnen aanroepen.
