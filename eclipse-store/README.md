# Eclipse Store (`/store`)

In-game Tebex store voor **Eclipse Roleplay**. Spelers openen met `/store` een custom NUI die producten ophaalt via de **Tebex Headless API** en checkout in de browser afhandelt.

## Installatie

1. Kopieer `eclipse-store` naar je `resources`-map.
2. Zet in `config.lua` je **Tebex Public Token** (`Config.PublicToken`).
3. Pas `Config.StoreUrl` aan naar je echte Tebex-webstore.
4. Voeg toe in `server.cfg`:

```cfg
ensure eclipse-store
```

5. Herstart de resource / server.

## Tebex setup

1. In Tebex: **Integrations → API Keys** → kopieer de **Public Token**.
2. Zorg dat je packages/categorieën in Tebex staan (Coins, VIP, Unbans, …).
3. Levering van items blijft via je bestaande Tebex plugin / package commands (RCON of game-server commands).
4. Checkout: speler logt in via Tebex (FiveM), daarna opent de betaalpagina in de browser.

## Commando’s

| Commando | Actie |
| --- | --- |
| `/store` | Open / sluit de Eclipse Store |

Optioneel: `Config.OpenKey = 'F7'` voor een keybind.

## Exports

```lua
exports['eclipse-store']:OpenStore()
exports['eclipse-store']:CloseStore()
```

## Demo-modus

Zonder geldige `PublicToken` toont `/store` een lokale demo-catalogus. Checkout opent dan alleen `Config.StoreUrl`.

## Preview

Open lokaal `html/preview.html` (of `html/index.html?preview=1`) om de UI in de browser te bekijken.