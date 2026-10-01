# Eclipse Politie

Volledige Nederlandse politie-job voor ESX Legacy met **10 officiële rangen**.

## Rangen (grade 1 → 10)

| Grade | Naam | Label | Salaris |
|------:|------|-------|--------:|
| 1 | aspirant | Aspirant | €250 |
| 2 | surveillant | Surveillant van politie | €350 |
| 3 | agent | Agent | €450 |
| 4 | hoofdagent | Hoofdagent | €550 |
| 5 | brigadier | Brigadier | €650 |
| 6 | inspecteur | Inspecteur | €800 |
| 7 | hoofdinspecteur | Hoofdinspecteur | €950 |
| 8 | commissaris | Commissaris | €1100 |
| 9 | hoofdcommissaris | Hoofdcommissaris | €1300 |
| 10 | eerste_hoofdcommissaris | Eerste hoofdcommissaris | €1600 |

## Functies

- In-/uitklokken (`police` ↔ `offpolice`)
- Omkleedkamer (uniform + kogelvrij vest)
- Wapenkamer (wapens & uitrusting per rang)
- Garage + helikopter (voertuigen per rang)
- F6 actiemenu: ID, boeien, meeslepen, in/uit voertuig, fouilleren, boetes, kenteken, inbeslagname
- Korpsleiding / society (vanaf hoofdcommissaris)
- Volledige SQL: jobs, grades, society, datastore, items, logtabellen

## Installatie

1. Zet de map `eclipse-politie` in je resources-folder.
2. Importeer `sql/install.sql` in je database.
3. Voeg toe aan `server.cfg`:

```cfg
ensure ox_lib
ensure oxmysql
ensure es_extended
ensure esx_society
ensure esx_addonaccount
ensure eclipse-politie
```

4. Geef jezelf de job (voorbeeld):

```sql
UPDATE users SET job = 'police', job_grade = 10 WHERE identifier = 'char1:JOUW_ID';
```

5. Pas in `config.lua` de locaties, voertuigen en uniformen aan naar jullie MLO/EUP.

## Dependencies

- `es_extended` (ESX Legacy)
- `ox_lib`
- `oxmysql`
- Optioneel: `esx_society`, `esx_addonaccount`, `esx_billing`, `esx_skin` / `skinchanger`, `jg-benzine`, `jg-givekey`

## Controls

- **E** bij markers: duty / omkleden / wapen / garage / baas
- **F6**: politie actiemenu (`politieacties`)
