# Eclipse Garage

Garage voor **ESX Legacy**. Je haalt een voertuig uit de garage, parkeert het weer, of haalt het gratis uit de impound via hetzelfde menu.

De markers, blips en uitrijplaatsen komen uit `ocean_garage` (`locations.lua`): blauwe marker om uit te halen, rode marker om te parkeren. Zet de oude `ocean_garage` uit, anders staan de punten dubbel.

Werkt samen met de inbeslagname van `mallorca-takel` (`mallorca_impound`). Zonder dat script kun je voertuigen nog steeds in beslag nemen met `/inbeslagnemen`.

## Installatie

1. Pak `snelle-garage.zip` uit in `resources` (de map `snelle-garage` staat daarin).
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
| Voertuig uithalen | Blauwe marker of oogje, **E**, of `/garage`. Kies daarna **Uithalen** |
| Parkeren | Rijd als bestuurder op de rode marker en druk **E**. Ook een auto die je net bij de cardealer hebt gekocht |
| Voertuig naar je toe roepen | **F7** of `/oproep` |
| Uit de impound halen | In het garagemenu op **Uit impound halen**. Ook bij de impound-marker of `/impound` |
| In beslag nemen | Politie, takel, ANWB of monteur: `/inbeslagnemen [reden]` |

Toetsen aanpassen: FiveM → Settings → Key Bindings → FiveM.

Een voertuig uit de impound haal je gratis in het garagemenu. Het wordt uit de impound gehaald en bij die garage neergezet, ook als de takel het in beslag nam. Een voertuig dat buiten staat of weg is, zet je bij de impound ook gratis weer neer.

Een auto die je bij de cardealer koopt, rijd je naar een garage en parkeer je met **E**. De garage herkent die aankoop ook als de dealer hem onder een license-id heeft gezet in plaats van je karakter-id. Een auto uit een spawnmenu of commando komt er niet in: die melding „Aankoop herkend” krijg je alleen bij een echte aankoop.

Boten en vliegtuigen haal je op bij hun eigen garage of impound. `/oproep` zet alleen auto's bij je neer.

## Config

Prijzen, jobs en sleutels staan in `config.lua`. De garages zelf staan in `locations.lua` en zijn de locaties van `ocean_garage`. `Config.ShareGarages` staat aan: een geparkeerde auto haal je bij elke garage van hetzelfde type uit (auto, boot of luchtvaartuig). `Config.OnlyPurchasedVehicles` en `Config.Cardealer.storePurchases` staan aan: alleen een gekocht voertuig, inclusief een auto van de cardealer, kan geparkeerd worden.

Sleutels (`Config.Keys.system = 'auto'`) werken met qs-vehiclekeys, wasabi_carlock, mk_vehiclekeys, vehicles_keys en cd_garage. Brandstof wordt gezet voor ox_fuel, LegacyFuel, cdn-fuel en ps-fuel.

## Browserdemo

Open `html/auto-demo.html` om het menu te zien zonder FiveM.
