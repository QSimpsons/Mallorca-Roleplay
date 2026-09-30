# Snelle Garage

Garage voor **ESX Legacy**. Je parkeert een voertuig, roept het weer op, of haalt het tegen betaling uit de impound.

Werkt samen met de inbeslagname van `mallorca-takel` (`mallorca_impound`). Zonder dat script kun je voertuigen nog steeds in beslag nemen met `/inbeslagnemen`.

## Installatie

1. Zet de map `snelle-garage` in `resources`.
2. Importeer `sql/install.sql` in je ESX-database (HeidiSQL of phpMyAdmin).
3. Zet dit in `server.cfg`, **na** `oxmysql` en `es_extended`:

```cfg
ensure oxmysql
ensure es_extended
ensure snelle-garage
```

`ox_target` is optioneel. Zonder oogje werken de markers en de **E**-toets.

## In het spel

| Actie | Hoe |
| --- | --- |
| Garage openen | Marker of oogje, **E**, of `/garage` als je erbij staat |
| Parkeren | Rijd als bestuurder op de marker en druk **E** |
| Voertuig oproepen bij de garage | Kies **Oproepen** |
| Voertuig naar je toe roepen | **F7** of `/oproep` (alleen auto's die in de garage staan) |
| Impound | Marker bij Davis, Sandy, de haven of LSIA, of `/impound` |
| In beslag nemen | Politie, takel, ANWB of monteur: `/inbeslagnemen [reden]` |

Toetsen aanpassen: FiveM → Settings → Key Bindings → FiveM.

Een voertuig uit de impound halen is gratis, ook als het door de takel in beslag is genomen. Een voertuig dat buiten staat of weg is, zet je daar ook gratis weer neer.

Boten en vliegtuigen haal je op bij hun eigen garage of impound. `/oproep` zet alleen auto's bij je neer.

## Config

Alles staat in `config.lua`: locaties, prijzen, jobs, sleutels en of elke garage alle auto's van dat type mag geven (`Config.ShareGarages`).

Sleutels (`Config.Keys.system = 'auto'`) werken met qs-vehiclekeys, wasabi_carlock, mk_vehiclekeys, vehicles_keys en cd_garage. Brandstof wordt gezet voor ox_fuel, LegacyFuel, cdn-fuel en ps-fuel.

## Browserdemo

Open `html/auto-demo.html` om het menu te zien zonder FiveM.
