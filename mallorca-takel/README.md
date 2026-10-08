# Mallorca Takel v2

Volledig opnieuw gebouwd takelscript voor **ESX Legacy**. Alleen **fmltow** en **dlbrickade**.

## Installatie

1. Zet `mallorca-takel` in `resources`.
2. Voer `sql/install.sql` uit.
3. In `server.cfg`, na `es_extended`:

```cfg
ensure oxmysql
ensure es_extended
ensure ox_target
ensure mallorca-takel
```

4. Job **mechanic / Wegenwacht rang 1 t/m 6**.
5. `ensure fmltow` en `ensure dlbrickade` moeten al draaien.

## Bediening

| Actie | Hoe |
|--------|-----|
| Tablet | **F1** of `/takel` |
| Op de bak / afzetten | In **fmltow** of **dlbrickade**, auto achter de bak, **O** |
| Oogje | ox_target op de auto of de takelwagen |
| Pechhulp | `/takelhulp` of oogje op je auto |
| Depot | Marker bij Mallorca Takel, **E** |
| Inbeslagname | Met lading naar de rode marker, **E** |

## Wat is nieuw in v2

- Auto schuift de bak op (geen GTA-haak, geen flatbed/towtruck)
- Blijft vast tijdens rijden (her-pin als hij losraakt)
- Andere spelers zien de lading meegaan
- Alleen extras van jouw twee wagens

Depot-coördinaten en prijzen staan in `config.lua`.
