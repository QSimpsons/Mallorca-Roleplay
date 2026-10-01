# Flitspalen

Flitspalen over de kaart, elk met een eigen maximum. Op kruispunten flitsen ze ook als je door rood rijdt.

## Installatie

Zet in `server.cfg`:

```
ensure flitspalen
```

ESX en QBCore zijn niet verplicht. Draait een van de twee, dan gaat de boete van de bankrekening. Anders krijgt de bestuurder een proces-verbaal op het scherm.

## Limiet per paal

In `config.lua` staat bij elke paal `limiet`. Dat is het maximum in km/h op die plek.

```lua
{ naam = 'Legion Square', coords = vector3(215.76, -810.12, 30.73), richting = 340.0, limiet = 50, straal = 18.0 },
```

- `limiet` — maximum op die paal
- `straal` — hoe breed de meting pakt
- `richting` — kant die het verkeer op rijdt (0 = noord). De paal wordt opzij van het meetpunt gezet
- `beideRichtingen` — laat weg of `true` voor beide kanten. `false` pakt alleen `richting`

`Config.Tolerantie` is de meetmarge boven dat maximum. Standaard 5 km/h.

De palen staan niet op de minimap en niet op de pauzekaart. Ze flitsen nog wel. Zet `Config.ToonBlips` op `true` als je de rode bolletjes toch op de kaart wilt.

## Rood licht

`Config.Roodlicht` zijn de kruispunten. `limiet` is daar ook het maximum: te hard flitst, en door rood rijden flitst apart (of allebei tegelijk).

Het spel heeft geen uitlezing van het stoplicht. Daarom zet dit script de lichten op zo'n kruispunt zelf in een vaste cyclus (groen, geel, rood). De flits gebruikt diezelfde cyclus, dus het licht dat je ziet is het licht waarop je beoordeeld wordt. Andere kruispunten blijven zoals ze zijn.

Door rood telt pas boven `Config.RoodMinSnelheid`, zodat stilstaan op de streep geen flits geeft.

## Nieuwe paal

Ga in de game op de plek staan en typ `/flitslocatie`. In F8 staat een regel om in `Config.Flitspalen` te plakken. Zet daarna de juiste `limiet`.

`Config.Debug = true` tekent de meetpunten, handig bij het schuiven.

## Wie wordt niet geflitst

- Passagiers
- Boten, helikopters, vliegtuigen en treinen
- Jobs in `Config.VrijgesteldeJobs` (`police`, `ambulance`, `kmar`)
- Noodvoertuigen met de sirene aan

De boete is `Config.BoetePerKmh` per km/h boven de limiet, plus `Config.RoodlichtBoete` bij rood. Het totaal blijft tussen het minimum en het maximum.
