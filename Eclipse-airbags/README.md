# Eclipse-airbags

FiveM-script: rijd je met een auto ergens tegenaan, dan blazen echte airbags op uit het stuur en het dashboard. Geen ballen en geen tekstmelding. De auto vat geen vuur.

Het effect gaat af als bestuurder wanneer de snelheid hoog genoeg is en in één klap hard daalt. De airbag van de bestuurder groeit uit het stuur, die van de bijrijder uit het dashboard. Op de grond blijven benzine, olie en groene koelvloeistof achter. De auto is total loss: de motor is dood, de ruiten zijn kapot en je kunt niet wegrijden tot hij hersteld is. Na een reparatie verdwijnen de airbags.

Motoren, fietsen, boten, helikopters, vliegtuigen en treinen doen niet mee. Na een reparatie kunnen de airbags opnieuw.

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
| `MinSpeed` | Minimumsnelheid in km/u vóór de klap |
| `SpeedDrop` | Hoeveel km/u je in één meting moet verliezen |
| `InflateMs` | Hoe snel de airbags opblazen |
| `AirbagModel` | Modelnaam. Standaard het echte airbag-model `prop_carairbag` |
| `StallEngine` | Motor slaat kort af na de klap |
| `PopWindscreen` | Voorruit springt eruit |
