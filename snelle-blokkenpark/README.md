# snelle-blokkenpark

Volledig aangekleed Blokkenpark op Legion Square, plus de ondergrondse parking die in de standaardmap wel onder het plein ligt maar niet bereikbaar is.

De noordelijke garage (rond `214, -809`) en de zuidelijke stalling (rond `128, -1055`) van `snelle-garage` blijven staan. Dit is een extra laag: het plein zelf, en een kelder eronder.

## Wat je ziet

- Entreebord **BLOKKENPARK** aan de noordkant van het plein
- Fonteinplein met planten, lantaarns en de banken die er al stonden
- Oost- en westpromenade met bomen en banken
- Prieel, picknick, burger- en hotdogkraam, fietsenrek, krantenbak en brievenbus
- Blauwe parkeerblip naar een inrit op de weg rond het plein

## Ondergrondse parking

De inrit zoekt een echt wegpunt naast het plein, uit de buurt van de bestaande Blokkenpark-garages. Druk daar met de auto op **E**. Je komt in de native 10-vaks garage die onder Legion Square hangt (`229.96, -981.79, -99.66`). Geen extra mapbestanden nodig.

- 10 vakken, maximaal 2 voertuigen per speler
- Alleen de eigenaar rijdt zijn auto weer uit
- Kenteken, kleur, mods, schade en brandstof blijven bewaard in `data/parked.json`
- Boten, helikopters, vliegtuigen, bussen en vrachtwagens worden geweigerd
- Met **E** bij de pijl onderaan rijd je weer naar buiten

Geparkeerde auto's staan los van `owned_vehicles`. Een auto die hier staat, blijft "buiten" voor de gewone garage.

## Installatie

Zie `INSTALL.txt`.

```cfg
ensure snelle-blokkenpark
```

## Verplaatsen

Props en borden staan in `config.lua`. Na een restart zie je het meteen.

De inrit kiest zelf een weg. Het gekozen punt staat in F8:

```text
[snelle-blokkenpark] Ingang: x, y, z, heading
```

Andere zoekpunten zet je in `Config.Parking.candidates`. `Config.Parking.avoid` houdt de bestaande garagepunten vrij.

`/blokkenpos` (admin) print je huidige `vector4`.

## Commands

| Command | Wie | Doet |
| --- | --- | --- |
| `/blokkenpark` | admin | naar het plein |
| `/blokkenpark parking` | admin | in de kelder |
| `/blokkenpos` | admin | print huidige coördinaat |
