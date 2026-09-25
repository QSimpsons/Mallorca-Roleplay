# snelle-airbags

FiveM-script: rijd je met een auto ergens tegenaan, dan schieten de airbags door de voorruit de auto uit.

Het effect gaat af als bestuurder wanneer de snelheid hoog genoeg is en in één klap hard daalt. De voorruit springt eruit, er komt een stoomwolk, de motor slaat kort af en vier witte kussens vliegen naar voren de auto uit. Andere spelers in de buurt zien hetzelfde.

Motoren, fietsen, boten, helikopters, vliegtuigen en treinen doen niet mee. Na een reparatie kunnen de airbags opnieuw.

## Installatie

1. Zet de map `snelle-airbags` in je `resources`.
2. Zet in `server.cfg`:

```
ensure snelle-airbags
```

Geen ESX, ox_lib of andere resources nodig.

## Instellingen

In `config.lua`:

| Optie | Betekenis |
| --- | --- |
| `MinSpeed` | Minimumsnelheid in km/u vóór de klap |
| `SpeedDrop` | Hoeveel km/u je in één meting moet verliezen |
| `LaunchForward` / `LaunchUp` | Hoe hard de airbags de auto uit vliegen |
| `Prop` | Model van het kussen. Vervang dit door een eigen airbag als je die hebt |
| `StallEngine` | Motor slaat kort af na de klap |
| `PopWindscreen` | Voorruit springt eruit |
