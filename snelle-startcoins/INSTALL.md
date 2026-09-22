# Snelle Startcoins

Elke **nieuwe** speler krijgt eenmalig **10.000 coins**. Bestaande spelers krijgen niks.

De coins komen standaard op het ESX-account `money` (contant). In de melding heten ze coins.

## Installatie

1. Pak `snelle-startcoins.zip` uit in je `resources` map. Je krijgt de map `snelle-startcoins`.
2. Zet dit in `server.cfg`, **na** `oxmysql` en `es_extended`:

```cfg
ensure oxmysql
ensure es_extended
ensure snelle-startcoins
```

3. Herstart de server, of:

```
ensure snelle-startcoins
```

De tabel `snelle_startcoins` wordt vanzelf aangemaakt. Wil je hem zelf importeren, gebruik `sql/install.sql`.

## Wat er gebeurt

- Nieuw character (ESX `isNew`) → meteen 10.000 coins.
- Opgeslagen per character, dus een tweede character krijgt ook 10.000. Een reconnect krijgt niks extra.
- Maakt iemand een character terwijl de resource uit stond, dan telt `users.created_at`. Alleen characters jonger dan 3 minuten krijgen de coins alsnog. Daarna gebruik je het staffcommando.

## Staff

```
geefstartcoins [id]
geefstartcoins [id] force
```

`force` geeft het bedrag nog een keer, ook als de speler hem al had.

Toegestaan voor ESX-groepen `admin` en `superadmin`, de serverconsole, en ace `command.geefstartcoins`.

```cfg
add_ace group.admin command.geefstartcoins allow
```

## Aanpassen

In `config.lua`:

| Optie | Standaard | Betekenis |
| --- | --- | --- |
| `Config.Amount` | `10000` | Aantal coins |
| `Config.Account` | `money` | `money` (contant) of `bank` |
| `Config.Mode` | `add` | `add` telt op, `set` zet het saldo exact op het bedrag |
| `Config.OncePerCharacter` | `true` | `false` = één keer per license, niet per character |

Eigen account `coins` kan alleen als dat account in `es_extended` bij `Config.Accounts` staat. Anders blijft de uitkering staan en zie je een fout in de serverconsole.

## Testen

1. Maak een nieuw character.
2. Je krijgt de melding: `Welkom! Je hebt 10.000 coins ontvangen.`
3. Contant geld is 10.000 hoger (of exact 10.000 als `Config.Mode` op `set` staat).
4. Reconnect: geen tweede uitkering.
5. Oud character: geen coins, tenzij je `geefstartcoins [id]` doet.
