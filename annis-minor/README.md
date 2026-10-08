# Annis Minor

Lore-friendly compacte coupé voor FiveM. Twee deuren, voorwielaandrijving, een kleine achterbank, en twee motoren.

In het spel is dit een **Annis**, hetzelfde merk als de Savestra en de ZR350. Spelers zien geen echte autofabrikant en geen echt modelnummer.

| Spawn | Naam in het spel | Klasse | Prijs (voorstel) |
| --- | --- | --- | --- |
| `aminor` | Minor | Compact | 24.500 |
| `aminorv6` | Minor V6 | Sport | 41.000 |

De viercilinder is de dagelijkse auto: licht, kort en iets vlotter dan een Blista. De V6 zit zwaarder op de neus, draait sneller op en loopt verder door. Die blijft onder een Kanjo van de streep en onder een Sugoi, en wint het duidelijk van de viercilinder.

## Download en OpenIV

Alles zit in één zip: [`Annis-Minor.zip`](./Annis-Minor.zip). Pak die uit. Daarin staat de FiveM-map én het bestand voor OpenIV.

In OpenIV:

1. Bestand openen.
2. Kies `openiv/Annis-Minor.rpf`.
3. Dubbelklik `aminor.yft` of `aminorv6.yft`.

OpenIV toont dan het model. `handling.meta`, `vehicles.meta` en `carvariations.meta` zitten in hetzelfde archief.

Het model in die bestanden is een eigen low-poly coupé, zodat je de vorm, de textures en de meta kunt bekijken. Er zitten geen losse deuren, geen draaiende wielen en geen interieur in. Op de server kun je de bestanden in `stream/` later vervangen door je eigen model. De bestandsnaam moet exact gelijk blijven: `aminor.yft`, `aminor.ytd`, `aminorv6.yft` en `aminorv6.ytd`. Op een Linux-server is dat hoofdlettergevoelig.

Wielgrootte staat op `0.262` (viercilinder) en `0.270` (V6), in de buurt van een Blista. Zijn de wielen in jouw model te groot of te klein, pas dan `wheelScale` en `wheelScaleRear` aan in `data/vehicles.meta`.

## Installatie

1. Zet de map `annis-minor` in `resources` (of in een map zoals `resources/[voertuigen]`).
2. Voeg toe aan `server.cfg`:

```cfg
ensure annis-minor
```

3. Herstart de server.

Spawn:

```text
/car aminor
/car aminorv6
```

## ESX-voertuigenwinkel

De spawn werkt via deze resource. De ESX-shop leest de auto's uit de database. Importeer daarvoor het bestand `esx_vehicles.sql` in dezelfde database als `esx_vehicleshop`.

Daarna staan ze in de winkel:

| Naam in de shop | Model | Categorie | Prijs |
| --- | --- | --- | --- |
| Annis Minor | `aminor` | compacts | 24500 |
| Annis Minor V6 | `aminorv6` | sports | 41000 |

Prijzen wijzig je in dat SQL-bestand voordat je het importeert. Gebruik je ox_inventory, dan staat een kleine kofferbak in `install/ox_inventory.lua`.

## Rijgedrag

Beide auto's hebben vijf versnellingen en voorwielaandrijving. `0_default_modkit` zit erop, dus motor, remmen, bak, vering, turbo, xenon en velgen werken bij de tuner zonder eigen bodykit.

| | Minor | Minor V6 |
| --- | --- | --- |
| Massa | 1040 kg | 1135 kg |
| Aandrijving | voor | voor, meer gewicht op de neus |
| Karakter | licht, wil insturen | trekt harder, voorwielen slippen eerder, hogere top |
| Geluid | `BLISTA` | `FELON` |

Het geluid verander je met `<audioNameHash>` in `data/vehicles.meta`. `BLISTA`, `KANJO`, `FUTO`, `SULTAN` en `FELON` zijn vanilla-geluiden. Een zescilinder klinkt in GTA het meest als `FELON` of `JACKAL`. `KANJO` is scheller en meer viercilinder, als je de V6 hoger wilt laten gillen.

De getoonde naam wijzig je in `client/main.lua` (`AddTextEntry`). De spawnnaam laat je gelijk aan de bestandsnaam van het model.

## Lore

Annis zette de Minor begin jaren negentig naast de Savestra: lager, kleiner, en met een achterbank die vooral een jas kwijt kan. De gewone uitvoering redt zich met een viercilinder. De Minor V6 propt een kleine zescilinder in dezelfde neus. Veel toeren, weinig auto, en een geluid dat niet bij de afmetingen past.

Voor de server: dit is de lore-versie van die compacte Japanse coupé uit 1991-1998 die bekendstond om een hele kleine V6. In de stad blijft de echte merknaam achterwege. Annis is het huis van de Savestra en de ZR350, dus de Minor hoort in die familie.
