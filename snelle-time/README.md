# Snelle Time

FiveM-menu om de tijd en het weer voor de hele server te zetten. Het commando is `/time`.

## Installatie

1. Zet de map `snelle-time` in je `resources` folder.
2. Zet in `server.cfg`:

```cfg
ensure snelle-time
```

3. Geef jezelf rechten. Als admins nog geen algemene command-rechten hebben:

```cfg
add_ace group.admin command.time allow
add_principal identifier.license:JOUWLICENSE group.admin
```

Je kunt ook een identifier in `config.lua` bij `Config.AllowedIdentifiers` zetten, of `Config.RequirePermission` op `false` zetten als iedereen het menu mag gebruiken.

4. Herstart de resource of de server.

Stop andere weer- of tijd-scripts (zoals `qb-weathersync`, `vSync` of `cd_easytime`). Anders overschrijven ze elkaar.

## Gebruik

Typ `/time`. Het menu toont de huidige servertijd.

| Knop / optie | Wat het doet |
| --- | --- |
| Slider | Tijdstip. Het label staat op 12 uur, of op 24 uur als `24 hr` aan staat. |
| Weericonen | Extra sunny, clear, neutral, smog, foggy, overcast, clouds, clearing, rain, thunder, light snow, snow, blizzard, christmas en halloween. |
| Freeze time | De klok blijft stilstaan. |
| Blackout | Stadverlichting uit. |
| Dynamic weather | Het weer wisselt vanzelf. Standaard elke 15 echte minuten. Sneeuw en events blijven handmatig. |
| Instant time change | De klok springt meteen. Uit = de klok loopt vooruit naar de nieuwe tijd. |
| 24 hr | Alleen de weergave in dit menu (14:00 in plaats van 2:00 PM). |
| Instant weather change | Het weer springt meteen. Uit = overgang van ongeveer 20 seconden. |
| Tsunami | Het water stijgt voor iedereen. Zet hem weer uit om het water te laten zakken. |
| Change | Past de keuzes live toe. Na een restart komen de laatst opgeslagen instellingen terug. |
| Save Settings | Past toe en bewaart in `data/settings.json`, zodat het na een restart blijft. |
| Close | Sluit het menu. Escape doet hetzelfde. |

In de serverconsole print `/time` de huidige tijd en het weer, zonder het menu te openen.

De resource-map moet schrijfbaar zijn om `Save Settings` te kunnen gebruiken.
