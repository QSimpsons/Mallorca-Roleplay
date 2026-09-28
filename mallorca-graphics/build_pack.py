#!/usr/bin/env python3
"""Build a complete Mallorca Roleplay FiveM graphics pack with high-contrast, readable assets."""

from __future__ import annotations

import math
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont, ImageOps

ROOT = Path(__file__).resolve().parent
REPO = ROOT.parent
FONT = ROOT / "fonts" / "Outfit-var.ttf"
FALLBACK = Path("/usr/share/fonts/truetype/noto/NotoSans-Bold.ttf")

# Brand — Mediterranean neon, high contrast for readability
NAVY = (5, 16, 32, 255)
NAVY_DEEP = (3, 10, 20, 255)
TEAL = (45, 230, 255, 255)
SEA = (20, 184, 166, 255)
GOLD = (255, 214, 74, 255)
SUNSET = (255, 140, 26, 255)
WHITE = (244, 246, 251, 255)
MUTED = (180, 196, 214, 255)


def font(size: int, weight: int = 800) -> ImageFont.FreeTypeFont:
    """Load Outfit (or fallback) at a bold weight — critical for readability."""
    path = FONT if FONT.exists() else FALLBACK
    fnt = ImageFont.truetype(str(path), size=size)
    try:
        # Variable font axis (Outfit[wght]) — default is often Thin without this.
        fnt.set_variation_by_axes([float(weight)])
    except Exception:
        try:
            fnt.set_variation_by_name("ExtraBold" if weight >= 800 else "Bold")
        except Exception:
            pass
    return fnt


def ensure(path: Path) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    return path


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(len(a)))


def vertical_gradient(size, top, bottom):
    w, h = size
    img = Image.new("RGBA", size)
    px = img.load()
    for y in range(h):
        c = lerp(top, bottom, y / max(h - 1, 1))
        for x in range(w):
            px[x, y] = c
    return img


def diagonal_gradient(size, colors):
    """colors: list of (stop 0-1, rgba)."""
    w, h = size
    img = Image.new("RGBA", size)
    px = img.load()
    for y in range(h):
        for x in range(w):
            t = (x / max(w - 1, 1) * 0.72) + (y / max(h - 1, 1) * 0.28)
            t = max(0.0, min(1.0, t))
            for i in range(len(colors) - 1):
                t0, c0 = colors[i]
                t1, c1 = colors[i + 1]
                if t0 <= t <= t1 or i == len(colors) - 2:
                    local = 0 if t1 == t0 else (t - t0) / (t1 - t0)
                    local = max(0.0, min(1.0, local))
                    px[x, y] = lerp(c0, c1, local)
                    break
    return img


GRAD_STOPS = [
    (0.0, TEAL),
    (0.38, SEA),
    (0.72, GOLD),
    (1.0, SUNSET),
]


def draw_centered_text(draw, xy, text, fnt, fill, stroke_width=0, stroke_fill=None):
    x, y = xy
    bbox = draw.textbbox((0, 0), text, font=fnt)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text(
        (x - tw / 2 - bbox[0], y - th / 2 - bbox[1]),
        text,
        font=fnt,
        fill=fill,
        stroke_width=stroke_width,
        stroke_fill=stroke_fill,
    )


def palm_icon(size: int, color=WHITE) -> Image.Image:
    """Bold palm + island mark — thick shapes so 96px stays readable."""
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    s = float(size)
    cx, cy = s / 2, s / 2 + s * 0.02

    # Soft ground mound (island)
    d.pieslice(
        [cx - s * 0.30, cy + s * 0.10, cx + s * 0.30, cy + s * 0.40],
        0,
        180,
        fill=color,
    )

    # Trunk — tapered via stacked rounded rects
    trunk_top = cy - s * 0.05
    trunk_bot = cy + s * 0.24
    for i in range(6):
        t = i / 5
        y0 = trunk_top + (trunk_bot - trunk_top) * t
        y1 = trunk_top + (trunk_bot - trunk_top) * min(1, t + 0.22)
        w = s * (0.055 + 0.035 * t)
        d.rounded_rectangle([cx - w, y0, cx + w, y1], radius=w, fill=color)

    # Fronds — curved thick leaves (clearer palm silhouette)
    crown_y = cy - s * 0.08
    leaves = [
        (-78, 0.36, 0.10),
        (-48, 0.40, 0.11),
        (-18, 0.42, 0.12),
        (18, 0.42, 0.12),
        (48, 0.40, 0.11),
        (78, 0.36, 0.10),
    ]
    for angle, length, bend in leaves:
        rad = math.radians(angle - 90)
        # control point bends leaf downward like real fronds
        mid_x = cx + math.cos(rad) * s * length * 0.55
        mid_y = crown_y + math.sin(rad) * s * length * 0.45 + s * bend
        tip_x = cx + math.cos(rad) * s * length
        tip_y = crown_y + math.sin(rad) * s * length * 0.75 + s * bend * 1.4
        width = max(4, int(s * 0.07))
        # approximate thick bezier with polygon ribbon
        pts = []
        steps = 8
        for i in range(steps + 1):
            t = i / steps
            # quadratic bezier
            x = (1 - t) ** 2 * cx + 2 * (1 - t) * t * mid_x + t**2 * tip_x
            y = (1 - t) ** 2 * crown_y + 2 * (1 - t) * t * mid_y + t**2 * tip_y
            # taper width toward tip
            w = width * (1 - t * 0.85)
            # perpendicular
            if i < steps:
                t2 = (i + 0.01) / steps
                x2 = (1 - t2) ** 2 * cx + 2 * (1 - t2) * t2 * mid_x + t2**2 * tip_x
                y2 = (1 - t2) ** 2 * crown_y + 2 * (1 - t2) * t2 * mid_y + t2**2 * tip_y
                dx, dy = x2 - x, y2 - y
            else:
                dx, dy = tip_x - mid_x, tip_y - mid_y
            L = math.hypot(dx, dy) or 1
            px, py = -dy / L * w, dx / L * w
            pts.append((x + px, y + py))
        for i in range(steps, -1, -1):
            t = i / steps
            x = (1 - t) ** 2 * cx + 2 * (1 - t) * t * mid_x + t**2 * tip_x
            y = (1 - t) ** 2 * crown_y + 2 * (1 - t) * t * mid_y + t**2 * tip_y
            w = width * (1 - t * 0.85)
            if i < steps:
                t2 = (i + 0.01) / steps
                x2 = (1 - t2) ** 2 * cx + 2 * (1 - t2) * t2 * mid_x + t2**2 * tip_x
                y2 = (1 - t2) ** 2 * crown_y + 2 * (1 - t2) * t2 * mid_y + t2**2 * tip_y
                dx, dy = x2 - x, y2 - y
            else:
                dx, dy = tip_x - mid_x, tip_y - mid_y
            L = math.hypot(dx, dy) or 1
            px, py = -dy / L * w, dx / L * w
            pts.append((x - px, y - py))
        d.polygon(pts, fill=color)

    # Coconut cluster accent
    r = max(2, int(s * 0.035))
    d.ellipse([cx - r, crown_y - r, cx + r, crown_y + r], fill=color)
    return img


def circular_badge(size: int, with_text: bool = False) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    # Gradient ring
    ring = diagonal_gradient((size, size), GRAD_STOPS)
    mask = Image.new("L", (size, size), 0)
    md = ImageDraw.Draw(mask)
    md.ellipse([0, 0, size - 1, size - 1], fill=255)
    inner = int(size * 0.10)
    md.ellipse([inner, inner, size - 1 - inner, size - 1 - inner], fill=0)
    ring.putalpha(mask)
    img = Image.alpha_composite(img, ring)

    # Fill
    fill = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    fd = ImageDraw.Draw(fill)
    pad = inner + max(1, size // 80)
    fd.ellipse([pad, pad, size - 1 - pad, size - 1 - pad], fill=NAVY)
    img = Image.alpha_composite(img, fill)

    # Icon
    icon = palm_icon(int(size * (0.52 if with_text else 0.62)), WHITE)
    ix = (size - icon.width) // 2
    iy = int(size * (0.14 if with_text else 0.19))
    img.alpha_composite(icon, (ix, iy))

    if with_text:
        d = ImageDraw.Draw(img)
        f = font(max(10, int(size * 0.11)))
        draw_centered_text(d, (size / 2, size * 0.78), "MALLORCA", f, WHITE)
        f2 = font(max(8, int(size * 0.07)))
        draw_centered_text(d, (size / 2, size * 0.88), "ROLEPLAY", f2, GOLD)

    return img


def wordmark(width: int = 1400, height: int = 420) -> Image.Image:
    img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    title = font(int(height * 0.38))
    sub = font(int(height * 0.14))
    draw_centered_text(
        d,
        (width / 2, height * 0.38),
        "MALLORCA",
        title,
        WHITE,
        stroke_width=max(1, height // 120),
        stroke_fill=(0, 0, 0, 180),
    )
    # Gradient underline
    bar_h = max(6, height // 28)
    bar = diagonal_gradient((int(width * 0.55), bar_h), GRAD_STOPS)
    bx = int((width - bar.width) / 2)
    by = int(height * 0.56)
    img.alpha_composite(bar, (bx, by))
    d = ImageDraw.Draw(img)
    draw_centered_text(d, (width / 2, height * 0.72), "ROLEPLAY  ·  NL SEMI RP", sub, MUTED)
    return img


def logo_lockup(size: int = 1024) -> Image.Image:
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    badge = circular_badge(int(size * 0.58), with_text=False)
    bx = (size - badge.width) // 2
    img.alpha_composite(badge, (bx, int(size * 0.06)))
    wm = wordmark(int(size * 0.92), int(size * 0.28))
    img.alpha_composite(wm, ((size - wm.width) // 2, int(size * 0.68)))
    return img


def make_server_icon_96() -> Image.Image:
    """Exactly 96×96 PNG for load_server_icon — solid fill, thick mark."""
    size = 96
    img = Image.new("RGBA", (size, size), NAVY)
    # rounded square feel via circle crop for list (but keep full square filled)
    ring = diagonal_gradient((size, size), GRAD_STOPS)
    mask = Image.new("L", (size, size), 0)
    md = ImageDraw.Draw(mask)
    md.ellipse([2, 2, size - 3, size - 3], fill=255)
    md.ellipse([8, 8, size - 9, size - 9], fill=0)
    ring.putalpha(mask)
    img.alpha_composite(ring)
    d = ImageDraw.Draw(img)
    d.ellipse([8, 8, size - 9, size - 9], fill=NAVY)
    icon = palm_icon(58, WHITE)
    img.alpha_composite(icon, ((size - 58) // 2, 14))
    return img


def wide_banner(width: int, height: int, title: str, subtitle: str) -> Image.Image:
    """Server list / connecting banner — text in central third for safe cropping."""
    base = vertical_gradient((width, height), NAVY_DEEP, NAVY)
    # soft glow
    glow = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse(
        [width * 0.25, -height * 1.2, width * 0.75, height * 1.8],
        fill=(45, 230, 255, 28),
    )
    glow = glow.filter(ImageFilter.GaussianBlur(40))
    img = Image.alpha_composite(base, glow)

    # top/bottom gradient bars
    bar = diagonal_gradient((width, max(4, height // 18)), GRAD_STOPS)
    img.alpha_composite(bar, (0, 0))
    img.alpha_composite(bar, (0, height - bar.height))

    badge = circular_badge(int(height * 0.72), with_text=False)
    title_f = font(max(26, int(height * 0.42)), 800)
    sub_f = font(max(16, int(height * 0.22)), 700)

    # Measure text for true horizontal centering of the whole cluster
    tmp = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
    tb = tmp.textbbox((0, 0), title, font=title_f)
    sb = tmp.textbbox((0, 0), subtitle, font=sub_f)
    text_w = max(tb[2] - tb[0], sb[2] - sb[0])
    gap = max(18, int(height * 0.12))
    cluster_w = badge.width + gap + text_w
    start_x = (width - cluster_w) // 2
    by = (height - badge.height) // 2
    img.alpha_composite(badge, (start_x, by))

    d = ImageDraw.Draw(img)
    tx = start_x + badge.width + gap
    title_h = tb[3] - tb[1]
    sub_h = sb[3] - sb[1]
    block_h = title_h + max(6, height // 20) + sub_h
    ty = (height - block_h) // 2
    d.text(
        (tx, ty - tb[1]),
        title,
        font=title_f,
        fill=WHITE,
        stroke_width=max(2, height // 60),
        stroke_fill=(0, 0, 0, 180),
    )
    d.text((tx, ty + title_h + max(6, height // 20) - sb[1]), subtitle, font=sub_f, fill=GOLD)
    return img


def discord_banner(width=1920, height=1080) -> Image.Image:
    img = vertical_gradient((width, height), NAVY_DEEP, (8, 28, 48, 255))
    # atmosphere orbs
    overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.ellipse([-200, -100, 700, 600], fill=(45, 230, 255, 40))
    od.ellipse([width - 800, height - 500, width + 100, height + 100], fill=(255, 140, 26, 35))
    overlay = overlay.filter(ImageFilter.GaussianBlur(80))
    img = Image.alpha_composite(img, overlay)

    badge = circular_badge(420, with_text=False)
    img.alpha_composite(badge, ((width - badge.width) // 2, int(height * 0.14)))
    d = ImageDraw.Draw(img)
    draw_centered_text(
        d,
        (width / 2, height * 0.62),
        "MALLORCA ROLEPLAY",
        font(86),
        WHITE,
        stroke_width=3,
        stroke_fill=(0, 0, 0, 180),
    )
    bar = diagonal_gradient((520, 10), GRAD_STOPS)
    img.alpha_composite(bar, ((width - bar.width) // 2, int(height * 0.70)))
    d = ImageDraw.Draw(img)
    draw_centered_text(
        d,
        (width / 2, height * 0.78),
        "NL SEMI RP  ·  24/7  ·  CUSTOM CARS  ·  JOBS  ·  EVENTS",
        font(34),
        MUTED,
    )
    return img


def invite_background(width=1920, height=1080) -> Image.Image:
    img = discord_banner(width, height)
    # darker vignette for invite readability
    vignette = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    vd = ImageDraw.Draw(vignette)
    for i in range(40):
        alpha = int(i * 2.2)
        vd.rectangle([i, i, width - 1 - i, height - 1 - i], outline=(0, 0, 0, alpha))
    img = Image.alpha_composite(img, vignette)
    return img


def loading_background(width=1920, height=1080) -> Image.Image:
    # Prefer local hero art from preview/ if present
    hero_candidates = [
        ROOT / "preview" / "mallorca-hero-bg.png",
        REPO / "mallorca-hero-bg.png",
    ]

    hero = None
    for p in hero_candidates:
        if p.exists():
            hero = Image.open(p).convert("RGBA")
            break

    if hero:
        hero = ImageOps.fit(hero, (width, height), method=Image.Resampling.LANCZOS)
        dark = Image.new("RGBA", (width, height), (3, 10, 20, 150))
        img = Image.alpha_composite(hero, dark)
    else:
        img = vertical_gradient((width, height), (4, 22, 40, 255), NAVY_DEEP)
        overlay = Image.new("RGBA", (width, height), (0, 0, 0, 0))
        od = ImageDraw.Draw(overlay)
        od.ellipse([width * 0.55, -200, width * 1.2, height * 0.7], fill=(255, 180, 60, 50))
        od.ellipse([-100, height * 0.4, width * 0.5, height * 1.2], fill=(20, 180, 200, 45))
        overlay = overlay.filter(ImageFilter.GaussianBlur(60))
        img = Image.alpha_composite(img, overlay)

    # bottom safe panel for UI text
    panel = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    pd = ImageDraw.Draw(panel)
    for y in range(int(height * 0.55), height):
        a = int(200 * ((y - height * 0.55) / (height * 0.45)))
        pd.line([(0, y), (width, y)], fill=(3, 10, 20, min(220, a)))
    img = Image.alpha_composite(img, panel)
    return img


def store_header(width=1600, height=400) -> Image.Image:
    img = vertical_gradient((width, height), NAVY_DEEP, NAVY)
    bar = diagonal_gradient((width, 8), GRAD_STOPS)
    img.alpha_composite(bar, (0, 0))
    img.alpha_composite(bar, (0, height - 8))
    badge = circular_badge(220, with_text=False)
    img.alpha_composite(badge, (80, (height - badge.height) // 2))
    d = ImageDraw.Draw(img)
    d.text((340, height * 0.28), "MALLORCA SHOP", font=font(64), fill=WHITE)
    d.text(
        (340, height * 0.58),
        "Coins · Unbans · Ranks · Cosmetics",
        font=font(30),
        fill=GOLD,
    )
    return img


def social_post(width=1080, height=1080) -> Image.Image:
    img = invite_background(width, height)
    d = ImageDraw.Draw(img)
    draw_centered_text(d, (width / 2, height * 0.88), "JOIN NU OP FIVEM", font(42), TEAL)
    return img


def save(img: Image.Image, path: Path, **kwargs):
    ensure(path)
    if path.suffix.lower() == ".png":
        img.save(path, "PNG", optimize=True)
    else:
        img.convert("RGB").save(path, quality=92, **kwargs)
    print(f"wrote {path.relative_to(REPO)} ({img.size[0]}x{img.size[1]})")


def build():
    logo_dir = ROOT / "logo"
    server_dir = ROOT / "server"
    discord_dir = ROOT / "discord"
    social_dir = ROOT / "social"
    preview_dir = ROOT / "preview"
    load_assets = REPO / "mallorca_loadscreen" / "assets"

    # Logos
    save(circular_badge(1024, with_text=False), logo_dir / "logo-mark-1024.png")
    save(circular_badge(512, with_text=True), logo_dir / "logo-badge-512.png")
    save(logo_lockup(1024), logo_dir / "logo-lockup-1024.png")
    save(wordmark(1600, 480), logo_dir / "logo-wordmark.png")
    # transparent + dark variants for overlays
    dark_bg = Image.new("RGBA", (1024, 1024), NAVY)
    dark_bg.alpha_composite(circular_badge(820, with_text=False), (102, 60))
    save(dark_bg, logo_dir / "logo-on-dark-1024.png")

    # FiveM server
    save(make_server_icon_96(), server_dir / "logo.png")  # load_server_icon
    save(make_server_icon_96(), server_dir / "server-icon-96.png")
    save(
        wide_banner(
            1920,
            200,
            "MALLORCA ROLEPLAY",
            "NL SEMI RP  ·  €15M START  ·  250+ CARS  ·  24/7",
        ),
        server_dir / "banner-detail-1920x200.png",
    )
    save(
        wide_banner(
            1920,
            200,
            "JE BENT AAN HET VERBINDEN",
            "MALLORCA ROLEPLAY  ·  DISCORD.GG  ·  WELKOM",
        ),
        server_dir / "banner-connecting-1920x200.png",
    )
    save(
        wide_banner(1865, 108, "MALLORCA ROLEPLAY", "NL SEMI RP · CUSTOM · EVENTS"),
        server_dir / "banner-detail-1865x108.png",
    )

    # Discord
    badge512 = circular_badge(512, with_text=False)
    disc_icon = Image.new("RGBA", (512, 512), NAVY)
    disc_icon.alpha_composite(badge512)
    save(disc_icon, discord_dir / "discord-icon-512.png")
    badge1024 = circular_badge(1024, with_text=False)
    disc_icon_l = Image.new("RGBA", (1024, 1024), NAVY)
    disc_icon_l.alpha_composite(badge1024)
    save(disc_icon_l, discord_dir / "discord-icon-1024.png")
    save(discord_banner(1920, 1080), discord_dir / "discord-banner-1920x1080.png")
    save(
        ImageOps.fit(discord_banner(1920, 1080), (960, 540), Image.Resampling.LANCZOS),
        discord_dir / "discord-banner-960x540.png",
    )
    save(invite_background(1920, 1080), discord_dir / "invite-background-1920x1080.png")
    save(circular_badge(256, with_text=False), discord_dir / "emoji-mallorca-128.png")
    # role icon 64
    save(
        ImageOps.fit(circular_badge(256, with_text=False), (64, 64), Image.Resampling.LANCZOS),
        discord_dir / "role-icon-64.png",
    )
    save(circular_badge(1024, with_text=False), discord_dir / "rich-presence-1024.png")

    # Social / store
    save(store_header(), social_dir / "store-header-1600x400.png")
    save(social_post(), social_dir / "social-square-1080.png")
    save(
        ImageOps.fit(discord_banner(1920, 1080), (1500, 500), Image.Resampling.LANCZOS),
        social_dir / "social-cover-1500x500.png",
    )

    # Loading screen assets
    bg = loading_background(1920, 1080)
    save(bg, load_assets / "background.png")
    save(circular_badge(512, with_text=False), load_assets / "logo.png")
    save(bg, preview_dir / "loading-preview.png")
    save(logo_lockup(1024), preview_dir / "brand-preview.png")

    # Contact sheet
    sheet = Image.new("RGBA", (1920, 1080), NAVY_DEEP)
    tiles = [
        (circular_badge(280), 60, 60),
        (make_server_icon_96().resize((280, 280), Image.Resampling.NEAREST), 380, 60),
        (
            ImageOps.fit(
                wide_banner(1920, 200, "MALLORCA ROLEPLAY", "DETAIL BANNER"),
                (900, 100),
                Image.Resampling.LANCZOS,
            ),
            720,
            80,
        ),
        (
            ImageOps.fit(
                wide_banner(1920, 200, "JE BENT AAN HET VERBINDEN", "CONNECTING"),
                (900, 100),
                Image.Resampling.LANCZOS,
            ),
            720,
            220,
        ),
        (
            ImageOps.fit(discord_banner(1920, 1080), (900, 506), Image.Resampling.LANCZOS),
            60,
            420,
        ),
    ]
    for tile, x, y in tiles:
        if tile.mode != "RGBA":
            tile = tile.convert("RGBA")
        sheet.alpha_composite(tile, (x, y))
    d = ImageDraw.Draw(sheet)
    d.text((1040, 420), "MALLORCA GRAPHICS PACK", font=font(42), fill=WHITE)
    d.text((1040, 490), "Alles high-contrast & leesbaar", font=font(28), fill=GOLD)
    d.text((1040, 560), "• Server icon 96×96", font=font(24), fill=MUTED)
    d.text((1040, 610), "• Banners 1920×200 / 1865×108", font=font(24), fill=MUTED)
    d.text((1040, 660), "• Discord icon + banner", font=font(24), fill=MUTED)
    d.text((1040, 710), "• Loading screen resource", font=font(24), fill=MUTED)
    save(sheet, preview_dir / "pack-overview.png")


if __name__ == "__main__":
    build()
