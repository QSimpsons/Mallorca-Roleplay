# ECLIPSE RP — burgerregistratie

Registratiemenu voor nieuwe inwoners. Het logo staat links, het formulier rechts. Mallorca RP komt er niet in voor.

Velden: voornaam, achternaam, geboortedatum, lengte, geslacht en akkoord met de regels/APV.

## Installatie

1. Zet de map `eclipse-identity` in `resources`.
2. Zet het oude Mallorca-registratiemenu uit.
3. In `server.cfg`, na `es_extended`:

```cfg
ensure esx_identity
ensure eclipse-identity
```

`esx_identity` blijft de opslag doen. Dit resource is het scherm.

Als het oude esx-scherm óók opent: haal in `esx_identity/client/main.lua` het openen van die NUI weg (`SetNuiFocus` / `SendNUIMessage`), en laat het event `esx_identity:showRegisterIdentity` staan. Eclipse vangt dat event.

Zonder `esx_identity` schrijft dit resource zelf naar de ESX-tabel `users` (`firstname`, `lastname`, `dateofbirth`, `sex`, `height`).

## Config

`config.lua`

| Optie | Betekenis |
| --- | --- |
| `ServerName` | Naam in het menu |
| `Discord` / `Rules` | Links onder het formulier en op de regels |
| `DateFormat` | Zelfde formaat als `esx_identity` (`DD/MM/YYYY`) |
| `MinAge` / `MaxAge` | Leeftijd |
| `MinHeight` / `MaxHeight` | Lengte in cm |
| `UseEsxIdentity` | `true` = opslaan via esx_identity |

## Commando

`/identiteit` opent het menu opnieuw als de speler nog geen naam heeft.

## Preview

Open `html/preview.html` in de browser. In-game is de achtergrond transparant, zodat de stad zichtbaar blijft.
