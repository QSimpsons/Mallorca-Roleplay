# Tebex store thema — Zoetermeer Shop

Custom Tebex webstore template in de stijl van de dark shop met neon gradient-randen, categorie-sidebar en productkaarten met **Bekijken**.

Dit is geen FiveM resource. Je plakt deze bestanden in het **Tebex Control Panel** (Appearance → Template). Daarvoor is **Tebex Plus** nodig.

## Bestanden

| Bestand | Waar plakken in Tebex |
| --- | --- |
| `layout.html` | Pages → layout.html |
| `index.html` | Pages → index.html |
| `category.html` | Pages → category.html |
| `package.html` | Pages → package.html |
| `checkout.html` | Pages → checkout.html |
| `username.html` | Pages → username.html |
| `options.html` | Pages → options.html |
| `cms/page.html` | Pages → cms/page.html |
| `package-card.html` | Assets (Twig include) |
| `theme.css` | Assets, of Appearance → Custom Theme |
| `schema.json` | Change Schema |
| `module.*.html` | Pages → bijbehorende sidebar modules |
| `preview.html` | Alleen lokaal openen om het design te zien |

## Installatie

1. Ga in Tebex naar **Appearance → Change Template → Create Custom Template**.
2. Kies Exo als basis, geef het thema een naam (bijvoorbeeld Zoetermeer Shop).
3. Plak per pagina de inhoud van de HTML-bestanden hierboven.
4. Upload `theme.css` en `package-card.html` als **Assets**.
5. Plak `schema.json` onder **Change Schema** en vul Discord-link + ledentekst in.
6. **Save and Publish**.
7. Maak in Tebex je echte producten: categorieën **Coins**, **Unbans**, **Staff Ranks** en pakketten met afbeeldingen en prijzen.
8. Maak CMS-pagina’s **Over ons**, **Regels**, **Reviews** en **Levels** als je die in de header wilt.

Zonder Plus-plan kun je alleen `theme.css` als custom theme plakken. De layout (sidebar + kaarten) komt dan **niet** overeen, omdat de standaard Exo-HTML anders is.

## Design

- Donkere achtergrond
- Gradient rand (cyaan → groen → geel → oranje)
- Linkerkolom **Categorieën** met NEW-badge
- Productgrid met prijs en **Bekijken**
- Winkelwagen en Tebex checkout (`POST /checkout/pay`)

Open `preview.html` in je browser voor een lokale demo van het uiterlijk.
