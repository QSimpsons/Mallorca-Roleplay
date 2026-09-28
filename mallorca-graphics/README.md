# Mallorca Roleplay — Graphics Pack

Volledige grafische pack voor **Mallorca Roleplay** (NL Semi RP). Alle assets zijn high-contrast zodat logo, tekst en banners op de serverlijst, Discord en loading screen goed leesbaar blijven.

## Inhoud

| Map | Gebruik |
| --- | --- |
| `logo/` | Master logo’s (mark, badge, lockup, wordmark) |
| `server/` | FiveM server icon + connect/detail banners |
| `discord/` | Discord icon, banner, invite background, role/emoji |
| `social/` | Shop header + social covers |
| `preview/` | Overzicht + bronbeelden |
| `../mallorca_loadscreen/` | FiveM loadscreen resource |

## FiveM installatie

### 1. Server icon (verplicht formaat)

Kopieer `server/logo.png` (exact **96×96 PNG**) naar je server-root (naast `server.cfg`) en zorg dat dit erin staat:

```cfg
load_server_icon "logo.png"
```

### 2. Server banners

Host de PNG’s ergens stabiel (niet via Discord CDN-attachments) en zet in `server.cfg`:

```cfg
sets banner_detail "https://JOUW-CDN/banner-detail-1920x200.png"
sets banner_connecting "https://JOUW-CDN/banner-connecting-1920x200.png"
```

Bestanden:

- `server/banner-detail-1920x200.png`
- `server/banner-connecting-1920x200.png`
- Alternatief smal: `server/banner-detail-1865x108.png`

### 3. Loading screen resource

1. Kopieer de map `mallorca_loadscreen` naar `resources/[local]/mallorca_loadscreen`
2. In `server.cfg`:

```cfg
ensure mallorca_loadscreen
```

3. Zet eventuele andere loadscreens uit (`ensure` / `start` verwijderen).

Optioneel: in je spawn/framework resource na load:

```lua
ShutdownLoadingScreen()
ShutdownLoadingScreenNui()
```

## Discord

| Bestand | Formaat | Waar |
| --- | --- | --- |
| `discord/discord-icon-512.png` of `1024` | Vierkant | Serverinstellingen → Icoon |
| `discord/discord-banner-960x540.png` | 16:9 | Server banner (boost lvl 2) |
| `discord/invite-background-1920x1080.png` | 1920×1080 | Invite splash (boost lvl 1) |
| `discord/role-icon-64.png` | 64×64 | Roliconen |
| `discord/rich-presence-1024.png` | 1024×1024 | Discord Developer Portal |

## Merkkleuren

| Token | Hex | Gebruik |
| --- | --- | --- |
| Navy | `#051020` | Achtergrond |
| Teal | `#2DE6FF` | Accent / progress |
| Sea | `#14B8A6` | Gradient |
| Gold | `#FFD64A` | Taglines |
| Sunset | `#FF8C1A` | Gradient einde |
| Text | `#F4F6FB` | Koppen |

Gradient: `teal → sea → gold → sunset`.

## Opnieuw genereren

```bash
pip install Pillow
python3 mallorca-graphics/build_pack.py
```

Font: `fonts/Outfit-var.ttf` (Google Fonts / OFL).

## Tips voor leesbaarheid

- Server icon: dik palm-icoon op navy, geen dunne lijnen.
- Banners: tekst in het **midden** (veilige crop-zone).
- Loading screen: witte/gouden tekst met schaduw op donkere onderzijde.
- Geen Rockstar/GTA logo’s gebruiken.
