# Eclipse-airbags

FiveM-script: rijd je met een auto ergens tegenaan, dan blazen echte airbags op uit het stuur en het dashboard. Geen ballen en geen tekstmelding. De auto vat geen vuur.

Het effect gaat af als bestuurder wanneer de snelheid hoog genoeg is en in één klap hard daalt. De airbag van de bestuurder groeit uit het stuur, die van de bijrijder uit het dashboard. Op de grond blijven benzine, olie en groene koelvloeistof achter. De auto is total loss: de motor is dood, de ruiten zijn kapot en je kunt niet wegrijden tot hij hersteld is. Na een reparatie verdwijnen de airbags.

Raak je iemand of een muur aan de zijkant, dan komt de deuk op die kant, zoals in het echt. Dat geldt voor jouw auto en voor de auto waar je tegenaan rijdt. Bij een harde tik aan de zijkant klapt de band aan die kant. Een lichte schuur is geen total loss en laat de airbags met rust. Een harde botsing doet beide.

Motoren, fietsen, boten, helikopters, vliegtuigen en treinen doen niet mee. Na een reparatie kunnen de airbags opnieuw.

## Download

https://github.com/QSimpsons/Mallorca-Roleplay/raw/cursor/side-impact-damage-df38/Eclipse-airbags.zip

Pak het zip uit in je `resources` map. De map heet `Eclipse-airbags`.

## Installatie

1. Zet de map `Eclipse-airbags` in je `resources`.
2. Zet in `server.cfg`:

```
ensure Eclipse-airbags
```

Geen ESX, ox_lib of andere resources nodig.

## Instellingen

In `config.lua`:

| Optie | Betekenis |
| --- | --- |
| `MinSpeed` | Minimumsnelheid in km/u vóór de airbags |
| `SpeedDrop` | Hoeveel km/u je in één meting moet verliezen voor airbags |
| `ScrapeMinSpeed` | Minimumsnelheid voor een deuk zonder airbags |
| `ScrapeDrop` | Snelheidsverlies waarbij de geraakte kant indeukt |
| `BlowoutSeverity` | Vanaf welke klap een band aan de zijkant klapt |
| `SideDamage` | Zijschade en klapband aan of uit |
| `InflateMs` | Hoe snel de airbags opblazen |
| `AirbagModel` | Modelnaam. Standaard het echte airbag-model `prop_carairbag` |
| `PopWindscreen` | Voorruit springt eruit bij een airbag-klap |
