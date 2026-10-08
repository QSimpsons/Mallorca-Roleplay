# Annis Minor

Lore-friendly compacte coupé voor FiveM. Twee deuren, voorwielaandrijving, een kleine achterbank, en twee motoren.

In het spel is dit een **Annis**, hetzelfde merk als de Savestra en de ZR350. Spelers zien geen echte autofabrikant en geen echt modelnummer.

| Spawn | Naam in het spel | Klasse | Prijs (voorstel) |
| --- | --- | --- | --- |
| `aminor` | Minor | Compact | 24.500 |
| `aminorv6` | Minor V6 | Sport | 41.000 |

De viercilinder is de dagelijkse auto: licht, kort en iets vlotter dan een Blista. De V6 zit zwaarder op de neus, draait sneller op en loopt verder door. Die blijft onder een Kanjo van de streep en onder een Sugoi, en wint het duidelijk van de viercilinder.

## 3D-model

Deze resource heeft de handling, de namen, de kleuren en de dealer-gegevens. Het koetswerk zelf zit er niet bij: een `.yft` is een GTA-model en hoort bij je eigen model, niet in deze meta.

Zet de bestanden in `annis-minor/stream/`. De naam moet exact overeenkomen met de spawnnaam. Op een Linux-server is dat hoofdlettergevoelig.

```text
stream/aminor.yft
stream/aminor.ytd
stream/aminor_hi.yft          optioneel, hoge details van dichtbij

stream/aminorv6.yft
stream/aminorv6.ytd
stream/aminorv6_hi.yft        optioneel
```

De V6 mag hetzelfde model zijn. Kopieer dan de bestanden van `aminor` en hernoem ze naar `aminorv6`. Textures mogen ook gedeeld worden: zet in `data/vehicles.meta` bij de V6 `<txdName>aminor</txdName>`.

Het model zelf moet lore-friendly zijn: geen echte logo's, geen merkbadge, geen modeltype op de achterklep. Ontbreken de bestanden, dan print de client na het inladen welke spawnnaam geen model heeft. De resource start wel, maar `/car aminor` kan dan geen auto tonen.

Wielgrootte staat op `0.262` (viercilinder) en `0.270` (V6), in de buurt van een Blista. Zijn de wielen in jouw model te groot of te klein, pas dan `wheelScale` en `wheelScaleRear` aan in `data/vehicles.meta`.

## Installatie

1. Zet de map `annis-minor` in `resources` (of in een map zoals `resources/[voertuigen]`).
2. Voeg toe aan `server.cfg`:

```cfg
ensure annis-minor
```

3. Herstart de server.

Spawn, als het model in `stream/` staat:

```text
/car aminor
/car aminorv6
```

## Dealer, garage en kofferbak

De meta maakt de auto spawnbaar. Je shop en inventory kennen hem daarna nog niet.

- QBCore / Qbox: `install/qb-core.lua`
- ESX: `install/esx.sql`
- ox_inventory (klein dashboardkastje, krappe kofferbak): `install/ox_inventory.lua`

Prijzen zijn een voorstel voor een gewone RP-economie. Zet ze gelijk aan de rest van je server.

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
