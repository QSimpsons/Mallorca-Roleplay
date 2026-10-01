# Eclipse Garage

Garage voor **ESX Legacy**. Je parkeert een voertuig, roept het weer op, of haalt het gratis uit de impound via hetzelfde menu.

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
| Parkeren | Rijd als bestuurder op de marker en druk **E**. Ook een auto die je net bij de cardealer hebt gekocht |
| Voertuig oproepen bij de garage | Kies **Oproepen** |
| Voertuig naar je toe roepen | **F7** of `/oproep` |
| Uit de impound halen | In het garagemenu op **Uit impound halen**. Ook bij de impound-marker of `/impound` |
| In beslag nemen | Politie, takel, ANWB of monteur: `/inbeslagnemen [reden]` |

Toetsen aanpassen: FiveM → Settings → Key Bindings → FiveM.

Een voertuig uit de impound haal je gratis in het garagemenu. Het wordt uit de impound gehaald en bij die garage neergezet, ook als de takel het in beslag nam. Een voertuig dat buiten staat of weg is, zet je bij de impound ook gratis weer neer.

Een auto die je bij de cardealer koopt, rijd je naar een garage en parkeer je met **E**. De dealer zet die auto op jouw naam; een auto uit een spawnmenu of commando komt niet in de garage.

Boten en vliegtuigen haal je op bij hun eigen garage of impound. `/oproep` zet alleen auto's bij je neer.

## Config

Alles staat in `config.lua`: locaties, prijzen, jobs, sleutels en of elke garage alle auto's van dat type mag geven (`Config.ShareGarages`). `Config.OnlyPurchasedVehicles` en `Config.Cardealer.storePurchases` staan aan: alleen een gekocht voertuig, inclusief een auto van de cardealer, kan geparkeerd worden.

Sleutels (`Config.Keys.system = 'auto'`) werken met qs-vehiclekeys, wasabi_carlock, mk_vehiclekeys, vehicles_keys en cd_garage. Brandstof wordt gezet voor ox_fuel, LegacyFuel, cdn-fuel en ps-fuel.

## Browserdemo

Open `html/auto-demo.html` om het menu te zien zonder FiveM.
