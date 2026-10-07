#!/usr/bin/env python3
"""Render the Eclipse Roleplay loading-screen background and theme.

The background is a seamless 1920x1080 loop: a solar eclipse over a night
skyline, with the server wordmark baked in so the mp4 stands on its own.
"""

from __future__ import annotations

import argparse
import subprocess
import wave
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
ASSET_DIR = ROOT / "eclipse-loadscreen" / "assets"
FONT_DIR = ASSET_DIR / "fonts"

W, H = 1920, 1080
FPS = 24
DURATION = 12.0

CX = W // 2
CY = 268
RADIUS = 122
GROUND = 1012
TOWER_SPAN = 330

CINZEL_BOLD = str(FONT_DIR / "Cinzel-Bold.ttf")
CINZEL_MEDIUM = str(FONT_DIR / "Cinzel-Medium.ttf")
INTER_MEDIUM = str(FONT_DIR / "Inter-Medium.ttf")
INTER_REGULAR = str(FONT_DIR / "Inter-Regular.ttf")

# x0, x1, height (0-1), style. Tall masses sit on the sides so the wordmark
# keeps a clear patch of sky in the center.
FRONT = [
    (0.000, 0.042, 0.34, "box"),
    (0.036, 0.090, 0.66, "step"),
    (0.084, 0.122, 0.24, "box"),
    (0.116, 0.170, 0.90, "antenna"),
    (0.164, 0.208, 0.42, "box"),
    (0.202, 0.258, 1.00, "spire"),
    (0.252, 0.304, 0.52, "crown"),
    (0.298, 0.346, 0.30, "box"),
    (0.340, 0.392, 0.58, "slant"),
    (0.386, 0.442, 0.20, "box"),
    (0.436, 0.492, 0.13, "box"),
    (0.486, 0.544, 0.17, "step"),
    (0.538, 0.592, 0.12, "box"),
    (0.586, 0.640, 0.28, "box"),
    (0.634, 0.686, 0.60, "crown"),
    (0.680, 0.728, 0.36, "box"),
    (0.722, 0.780, 0.98, "spire"),
    (0.774, 0.822, 0.54, "antenna"),
    (0.816, 0.866, 0.32, "box"),
    (0.860, 0.914, 0.68, "step"),
    (0.908, 0.956, 0.36, "slant"),
    (0.950, 1.000, 0.18, "box"),
]

BACK = [
    (0.000, 0.070, 0.22, "box"),
    (0.060, 0.130, 0.34, "box"),
    (0.120, 0.190, 0.18, "box"),
    (0.180, 0.260, 0.40, "step"),
    (0.250, 0.330, 0.26, "box"),
    (0.320, 0.400, 0.16, "box"),
    (0.390, 0.470, 0.22, "box"),
    (0.460, 0.540, 0.14, "box"),
    (0.530, 0.610, 0.20, "box"),
    (0.600, 0.680, 0.28, "step"),
    (0.670, 0.750, 0.18, "box"),
    (0.740, 0.820, 0.36, "box"),
    (0.810, 0.890, 0.24, "box"),
    (0.880, 0.950, 0.32, "step"),
    (0.940, 1.000, 0.16, "box"),
]


def roof_y(height: float, span: float = TOWER_SPAN) -> int:
    return int(GROUND - height * span)


def building_polygons(x0: float, x1: float, height: float, style: str, span: float):
    left = x0 * W
    right = x1 * W
    ground = GROUND
    roof = GROUND - height * span
    polys = []

    def box(a, b, top, bottom=ground):
        polys.append([(a, bottom), (a, top), (b, top), (b, bottom)])

    if style == "box":
        box(left, right, roof)
    elif style == "step":
        mid = (left + right) * 0.5
        step = roof + (ground - roof) * 0.34
        polys.append(
            [
                (left, ground),
                (left, step),
                (mid, step),
                (mid, roof),
                (right, roof),
                (right, ground),
            ]
        )
    elif style == "antenna":
        box(left, right, roof)
        cx = (left + right) * 0.5
        mast = roof - (ground - roof) * 0.22
        w = max(1.5, (right - left) * 0.035)
        box(cx - w, cx + w, mast, roof)
    elif style == "crown":
        shoulder = roof + (ground - roof) * 0.16
        box(left, right, shoulder)
        step_w = (right - left) * 0.18
        box(left + step_w, right - step_w, roof, shoulder)
        cap_w = (right - left) * 0.34
        cap = roof - (ground - roof) * 0.06
        box((left + right) * 0.5 - cap_w * 0.5, (left + right) * 0.5 + cap_w * 0.5, cap, roof)
    elif style == "slant":
        polys.append([(left, ground), (left, roof + (ground - roof) * 0.18), (right, roof), (right, ground)])
    elif style == "spire":
        inset = (right - left) * 0.16
        shoulder = roof + (ground - roof) * 0.10
        box(left, right, shoulder)
        polys.append(
            [
                (left + inset, shoulder),
                ((left + right) * 0.5, roof - (ground - roof) * 0.08),
                (right - inset, shoulder),
            ]
        )
    else:
        box(left, right, roof)
    return polys


def draw_polygons(polys, scale: int, fill: int) -> np.ndarray:
    img = Image.new("L", (W * scale, H * scale), 0)
    draw = ImageDraw.Draw(img)
    for poly in polys:
        scaled = [(x * scale, y * scale) for x, y in poly]
        draw.polygon(scaled, fill=fill)
    if scale == 1:
        return np.asarray(img, dtype=np.float32) / 255.0
    small = img.resize((W, H), Image.Resampling.LANCZOS)
    return np.asarray(small, dtype=np.float32) / 255.0


def column_roofs(mask: np.ndarray) -> np.ndarray:
    hit = mask > 0.35
    roofs = np.full(W, GROUND, dtype=np.int32)
    has = hit.any(axis=0)
    roofs[has] = np.argmax(hit, axis=0)[has]
    return roofs


def paint_buildings(specs, span: float, scale: int = 2):
    polys = []
    for spec in specs:
        polys.extend(building_polygons(*spec, span))
    mask = draw_polygons(polys, scale, 255)
    roofs = column_roofs(mask)
    ys = np.arange(H, dtype=np.float32)[:, None]
    height = np.maximum(GROUND - roofs, 1).astype(np.float32)
    vertical = np.clip((GROUND - ys) / height, 0, 1)
    shade = (0.45 + 0.55 * vertical) * mask
    return mask, roofs, shade


def window_layers(specs, roofs_hint: np.ndarray):
    """Lit windows as RGB plus a flicker-group id (0 steady, 1-4 animated)."""
    del roofs_hint
    rgb = np.zeros((H, W, 3), dtype=np.float32)
    group = np.full((H, W), -1, dtype=np.int8)
    rng = np.random.default_rng(19)
    warm = np.array(
        [
            [1.00, 0.72, 0.38],
            [1.00, 0.86, 0.58],
            [0.96, 0.55, 0.26],
            [1.00, 0.80, 0.64],
        ],
        dtype=np.float32,
    )
    cool = np.array([0.62, 0.78, 1.00], dtype=np.float32)

    for x0, x1, height, style in specs:
        if height < 0.15:
            continue
        density = float(rng.uniform(0.22, 0.55))
        if height < 0.24:
            density *= 0.55
        left = int(x0 * W) + int(rng.integers(7, 14))
        right = int(x1 * W) - int(rng.integers(7, 14))
        roof = roof_y(height) + (36 if style == "spire" else 16)
        bottom = GROUND - 8
        if right - left < 18 or bottom - roof < 30:
            continue
        win_w = int(rng.integers(5, 8))
        win_h = int(rng.integers(8, 14))
        gap_x = int(rng.integers(7, 12))
        gap_y = int(rng.integers(8, 13))
        stagger = int(rng.integers(0, win_w + gap_x))
        y = roof
        row = 0
        while y + win_h < bottom:
            if rng.random() < 0.14:
                y += win_h + gap_y
                row += 1
                continue
            x = left + (stagger if row % 2 else 0)
            while x + win_w < right:
                if rng.random() > density:
                    x += win_w + gap_x
                    continue
                ww = win_w
                if rng.random() < 0.07 and x + win_w * 2 + 2 < right:
                    ww = win_w * 2 + 2
                color = cool if rng.random() < 0.06 else warm[int(rng.integers(0, len(warm)))]
                intensity = float(rng.uniform(0.28, 1.0))
                if style in {"spire", "crown"} and row == 0:
                    intensity = 1.0
                    color = np.array([1.0, 0.88, 0.58], dtype=np.float32)
                gid = 0 if rng.random() < 0.78 else int(rng.integers(1, 5))
                rgb[y : y + win_h, x : x + ww] = color * intensity
                group[y : y + win_h, x : x + ww] = gid
                x += ww + gap_x
            y += win_h + gap_y
            row += 1
    return rgb, group


def sky_gradient() -> np.ndarray:
    stops = [
        (0.00, np.array([0.020, 0.018, 0.055], dtype=np.float32)),
        (0.22, np.array([0.055, 0.032, 0.110], dtype=np.float32)),
        (0.40, np.array([0.110, 0.045, 0.090], dtype=np.float32)),
        (0.55, np.array([0.200, 0.075, 0.060], dtype=np.float32)),
        (0.70, np.array([0.090, 0.032, 0.050], dtype=np.float32)),
        (0.86, np.array([0.030, 0.018, 0.032], dtype=np.float32)),
        (1.00, np.array([0.012, 0.010, 0.018], dtype=np.float32)),
    ]
    y = np.linspace(0, 1, H, dtype=np.float32)
    rgb = np.zeros((H, 3), dtype=np.float32)
    for (a, ca), (b, cb) in zip(stops, stops[1:]):
        t = np.clip((y - a) / (b - a), 0, 1)
        # smoothstep
        t = t * t * (3 - 2 * t)
        band = (y >= a) & (y <= b)
        rgb[band] = ca + (cb - ca) * t[band, None]
    rgb[(y >= stops[-1][0])] = stops[-1][1]
    return np.repeat(rgb[:, None, :], W, axis=1)


def star_field(front_mask: np.ndarray):
    rng = np.random.default_rng(7)
    count = 220
    xs = rng.integers(0, W, count)
    ys = rng.integers(8, int(H * 0.62), count)
    mag = rng.uniform(0.25, 1.0, count)
    phase = rng.uniform(0, 1, count)
    cycles = rng.integers(1, 3, count)
    dx = xs - CX
    dy = ys - CY
    dist = np.sqrt(dx * dx + dy * dy)
    keep = (dist > RADIUS * 1.35) & (front_mask[ys, xs] < 0.2) & (ys < GROUND - 40)
    return xs[keep], ys[keep], mag[keep], phase[keep], cycles[keep]


def ember_field():
    rng = np.random.default_rng(11)
    count = 56
    return {
        "x": rng.uniform(0.04, 0.96, count),
        "y": rng.uniform(0.0, 1.0, count),
        "speed": rng.uniform(0.18, 0.55, count),
        "drift": rng.uniform(-0.015, 0.015, count),
        "size": rng.integers(1, 3, count),
        "phase": rng.uniform(0, 1, count),
        "warm": rng.random(count),
    }


def make_disc_sprites():
    sprites = {}
    for radius in (1, 2):
        d = np.arange(-radius * 2, radius * 2 + 1)
        xx, yy = np.meshgrid(d, d)
        sprites[radius] = np.exp(-(xx**2 + yy**2) / (2 * (radius * 0.9) ** 2)).astype(np.float32)
    return sprites


def paste_add(frame, sprite, cx, cy, color):
    r = sprite.shape[0] // 2
    x0, y0 = int(cx) - r, int(cy) - r
    x1, y1 = x0 + sprite.shape[1], y0 + sprite.shape[0]
    if x1 <= 0 or y1 <= 0 or x0 >= W or y0 >= H:
        return
    sx0 = max(0, -x0)
    sy0 = max(0, -y0)
    sx1 = sprite.shape[1] - max(0, x1 - W)
    sy1 = sprite.shape[0] - max(0, y1 - H)
    x0, y0 = max(0, x0), max(0, y0)
    patch = sprite[sy0:sy1, sx0:sx1, None] * color
    frame[y0 : y0 + patch.shape[0], x0 : x0 + patch.shape[1]] += patch


def corona_image(phase: float) -> np.ndarray:
    hs, ws = H // 2, W // 2
    ys, xs = np.ogrid[0:hs, 0:ws]
    dx = xs - CX * 0.5
    dy = ys - CY * 0.5
    dist = np.sqrt(dx * dx + dy * dy) / (RADIUS * 0.5)
    ang = np.arctan2(dy, dx)
    turn = phase * np.pi * 2

    envelope = (
        0.72
        + 0.16 * np.sin(ang * 5 + turn)
        + 0.10 * np.sin(ang * 9 - turn * 2)
        + 0.06 * np.sin(ang * 14 + turn)
        + 0.04 * np.sin(ang * 23 - turn * 3)
    )
    envelope = np.clip(envelope, 0.35, 1.2)
    rays = np.sin(ang * 8 + turn) ** 2
    rays = rays**2

    inner = np.exp(-((dist - 1.04) ** 2) / (2 * (0.055 * envelope) ** 2))
    outer = np.exp(-((dist - 1.08) ** 2) / (2 * (0.22 * envelope) ** 2)) * (0.30 + 0.70 * rays)
    far = np.exp(-((dist - 1.0) ** 2) / (2 * 0.62**2)) * 0.22
    hole = np.clip((dist - 0.985) / 0.045, 0, 1)

    white = np.array([1.00, 0.96, 0.88], dtype=np.float32)
    gold = np.array([1.00, 0.62, 0.24], dtype=np.float32)
    red = np.array([0.78, 0.16, 0.12], dtype=np.float32)
    col = inner[..., None] * white * 1.05
    col += outer[..., None] * gold * 0.75
    col += (outer * np.clip(dist - 1.15, 0, 1))[..., None] * red * 0.65
    col += far[..., None] * np.array([0.45, 0.16, 0.18], dtype=np.float32)
    col *= hole[..., None]

    image = Image.fromarray(np.clip(col * 255.0, 0, 255).astype(np.uint8), "RGB")
    image = image.resize((W, H), Image.Resampling.BILINEAR)
    return np.asarray(image, dtype=np.float32) / 255.0


def sharp_eclipse(phase: float) -> tuple[np.ndarray, np.ndarray]:
    """Full-resolution disc, ring, diamond and prominences in a crop."""
    pad = int(RADIUS * 1.85)
    y0, y1 = max(0, CY - pad), min(H, CY + pad)
    x0, x1 = max(0, CX - pad), min(W, CX + pad)
    yy, xx = np.ogrid[y0:y1, x0:x1]
    dx = xx - CX
    dy = yy - CY
    dist = np.sqrt(dx * dx + dy * dy) / RADIUS
    ang = np.arctan2(dy, dx)
    turn = phase * np.pi * 2

    disc = np.clip((1.002 - dist) / 0.018, 0, 1)
    ring = np.exp(-((dist - 1.012) ** 2) / (2 * 0.0115**2))
    limb = np.exp(-((dist - 0.985) ** 2) / (2 * 0.02**2)) * np.clip(dist - 0.9, 0, 1)

    delta = (ang - turn + np.pi) % (2 * np.pi) - np.pi
    diamond = np.exp(-(delta**2) / (2 * 0.11**2))
    ring_i = ring * (0.18 + 2.6 * diamond)
    bead = np.exp(-((dist - 1.045) ** 2) / (2 * 0.018**2)) * np.exp(-(delta**2) / (2 * 0.035**2))

    prominences = np.zeros_like(dist)
    for angle, width, reach in (
        (-0.70, 0.13, 0.10),
        (0.50, 0.10, 0.075),
        (1.85, 0.15, 0.12),
        (2.55, 0.09, 0.06),
    ):
        da = (ang - angle + np.pi) % (2 * np.pi) - np.pi
        prominences += np.exp(-(da**2) / (2 * width**2)) * np.exp(
            -((dist - (1.03 + reach * 0.35)) ** 2) / (2 * (reach * 0.65) ** 2)
        )

    rgb = np.zeros(dist.shape + (3,), dtype=np.float32)
    rgb += ring_i[..., None] * np.array([1.0, 0.93, 0.78], dtype=np.float32)
    rgb += (bead * 1.35)[..., None] * np.array([1.0, 0.98, 0.94], dtype=np.float32)
    rgb += (limb * 0.16)[..., None] * np.array([1.0, 0.72, 0.40], dtype=np.float32)
    rgb += prominences[..., None] * np.array([1.0, 0.32, 0.14], dtype=np.float32)

    return (y0, y1, x0, x1, disc, rgb)


def text_layer() -> np.ndarray:
    canvas = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(canvas)
    glow_draw = ImageDraw.Draw(glow)
    title_font = ImageFont.truetype(CINZEL_BOLD, 92)
    sub_font = ImageFont.truetype(CINZEL_MEDIUM, 22)
    tag_font = ImageFont.truetype(INTER_REGULAR, 18)

    def tracked(target, text, y, font, fill, tracking):
        probe = ImageDraw.Draw(target)
        widths = []
        for ch in text:
            box = probe.textbbox((0, 0), ch, font=font)
            widths.append(box[2] - box[0])
        total = sum(widths) + tracking * (len(text) - 1)
        x = (W - total) / 2
        for ch, w in zip(text, widths):
            probe.text((x, y), ch, font=font, fill=fill)
            x += w + tracking

    tracked(glow, "ECLIPSE", 528, title_font, (231, 186, 110, 255), 18)
    glow = glow.filter(ImageFilter.GaussianBlur(16))
    glow_px = np.asarray(glow).astype(np.float32)
    glow_px[..., 3] *= 0.55

    tracked(canvas, "ECLIPSE", 530, title_font, (8, 6, 10, 150), 18)
    tracked(canvas, "ECLIPSE", 526, title_font, (246, 239, 226, 255), 18)

    rule_y = 632
    rule_w = 210
    gap = 18
    center_gap = 16
    draw.line((CX - rule_w - center_gap, rule_y, CX - center_gap, rule_y), fill=(231, 201, 138, 210), width=1)
    draw.line((CX + center_gap, rule_y, CX + rule_w + center_gap, rule_y), fill=(231, 201, 138, 210), width=1)
    diamond = [(CX, rule_y - 5), (CX + 5, rule_y), (CX, rule_y + 5), (CX - 5, rule_y)]
    draw.polygon(diamond, fill=(246, 239, 226, 230))

    tracked(canvas, "ROLEPLAY", 648, sub_font, (231, 201, 138, 235), 16)

    tag = "Als de zon verdwijnt, ontwaakt de stad."
    tag_w = draw.textlength(tag, font=tag_font)
    draw.text(((W - tag_w) / 2, 692), tag, font=tag_font, fill=(214, 206, 196, 210))

    # Scrim so the wordmark survives the corona and the h264 encode.
    scrim = Image.new("L", (W, H), 0)
    scrim_draw = ImageDraw.Draw(scrim)
    scrim_draw.ellipse((CX - 430, 500, CX + 430, 760), fill=170)
    scrim = scrim.filter(ImageFilter.GaussianBlur(28))
    scrim_a = (np.asarray(scrim).astype(np.float32) / 255.0) * 0.42

    text = np.asarray(canvas).astype(np.float32)
    text_rgb = text[..., :3] / 255.0
    text_a = text[..., 3:4] / 255.0
    glow_rgb = glow_px[..., :3] / 255.0
    glow_a = glow_px[..., 3:4] / 255.0
    return scrim_a, glow_rgb, glow_a, text_rgb, text_a


def vignette() -> np.ndarray:
    ys = (np.linspace(-1, 1, H, dtype=np.float32) ** 2)[:, None]
    xs = np.linspace(-1, 1, W, dtype=np.float32) ** 2
    radial = np.clip((ys + xs) / 1.35, 0, 1)
    return 1.0 - radial * 0.55


def build_caches():
    print("building skyline…", flush=True)
    back_mask, back_roofs, back_shade = paint_buildings(BACK, TOWER_SPAN * 0.42, scale=2)
    front_mask, front_roofs, front_shade = paint_buildings(FRONT, TOWER_SPAN, scale=2)
    windows, groups = window_layers(FRONT, front_roofs)
    sky = sky_gradient()
    stars = star_field(front_mask)
    embers = ember_field()
    sprites = make_disc_sprites()
    scrim_a, glow_rgb, glow_a, text_rgb, text_a = text_layer()
    vig = vignette()
    grain = np.random.default_rng(3).uniform(-1, 1, (H, W)).astype(np.float32)
    beacons = []
    for x0, x1, height, style in FRONT:
        if style in {"spire", "antenna"} and height > 0.8:
            beacons.append((int((x0 + x1) * 0.5 * W), roof_y(height) - 8))
    return {
        "back_mask": back_mask,
        "back_roofs": back_roofs,
        "back_shade": back_shade,
        "front_mask": front_mask,
        "front_roofs": front_roofs,
        "front_shade": front_shade,
        "windows": windows,
        "groups": groups,
        "sky": sky,
        "stars": stars,
        "embers": embers,
        "sprites": sprites,
        "scrim_a": scrim_a,
        "glow_rgb": glow_rgb,
        "glow_a": glow_a,
        "text_rgb": text_rgb,
        "text_a": text_a,
        "vig": vig,
        "grain": grain,
        "beacons": beacons,
    }


def render_frame(phase: float, cache: dict) -> np.ndarray:
    frame = cache["sky"].copy()

    # Stars.
    xs, ys, mag, star_phase, cycles = cache["stars"]
    twinkle = 0.55 + 0.45 * np.sin(np.pi * 2 * (cycles * phase + star_phase))
    bright = np.clip(mag * twinkle, 0, 1)
    frame[ys, xs] += np.array([0.75, 0.82, 1.0], dtype=np.float32) * bright[:, None]

    corona = corona_image(phase)
    frame += corona * (1.0 - cache["back_mask"][..., None] * 0.15)

    # Distant skyline, then the near one.
    back_color = np.array([0.10, 0.07, 0.14], dtype=np.float32)
    frame = frame * (1.0 - cache["back_mask"][..., None] * 0.92) + back_color * cache["back_shade"][..., None]

    front_color = np.array([0.020, 0.016, 0.028], dtype=np.float32)
    shade = cache["front_shade"]
    building = front_color * (0.65 + shade)[..., None]
    # Warm rim along roofs facing the eclipse.
    roofs = cache["front_roofs"]
    ys = np.arange(H, dtype=np.float32)[:, None]
    above = roofs.astype(np.float32) - ys
    rim = np.exp(-(np.clip(above, 0, None) ** 2) / (2 * 22.0**2))
    rim *= (above > 0).astype(np.float32)
    rim *= np.exp(-((np.arange(W, dtype=np.float32) - CX) ** 2) / (2 * 520.0**2))
    rim *= 1.0 - cache["front_mask"]
    frame += rim[..., None] * np.array([1.0, 0.62, 0.28], dtype=np.float32) * 0.55

    mask = cache["front_mask"][..., None]
    frame = frame * (1.0 - mask) + building * np.clip(shade[..., None] * 1.4, 0, 1.15)

    y0, y1, x0, x1, disc, eclipse_rgb = sharp_eclipse(phase)
    region = frame[y0:y1, x0:x1]
    disc_m = disc[..., None]
    # Only replace sky; buildings stay in front.
    open_sky = 1.0 - cache["front_mask"][y0:y1, x0:x1][..., None]
    region[:] = region * (1.0 - disc_m * open_sky) + np.array([0.012, 0.010, 0.016], dtype=np.float32) * disc_m * open_sky
    region += eclipse_rgb * open_sky

    # Windows and beacons.
    factors = np.ones(5, dtype=np.float32)
    factors[1:] = 0.62 + 0.38 * np.sin(np.pi * 2 * (phase + np.array([0.0, 0.23, 0.51, 0.77])))
    flicker = np.ones((H, W), dtype=np.float32)
    groups = cache["groups"]
    for gid in range(5):
        flicker[groups == gid] = factors[gid]
    frame += cache["windows"] * flicker[..., None]

    blink = 0.2 + 0.8 * (np.sin(np.pi * 2 * phase * 2) ** 8)
    for bx, by in cache["beacons"]:
        if 0 <= by < H:
            frame[by - 1 : by + 2, bx - 1 : bx + 2] += np.array([1.0, 0.25, 0.18], dtype=np.float32) * blink

    # Rising embers.
    embers = cache["embers"]
    sprites = cache["sprites"]
    for i in range(embers["x"].shape[0]):
        px = (embers["x"][i] + embers["drift"][i] * phase) % 1.0
        py = (embers["y"][i] - embers["speed"][i] * phase) % 1.0
        x = int(px * (W - 1))
        y = int(0.42 * H + py * (H - 0.42 * H - 1))
        if y >= roofs[min(x, W - 1)]:
            continue
        pulse = 0.45 + 0.55 * (0.5 + 0.5 * np.sin(np.pi * 2 * (phase + embers["phase"][i])))
        color = np.array([1.0, 0.55 + 0.3 * embers["warm"][i], 0.22], dtype=np.float32) * pulse * 0.55
        paste_add(frame, sprites[int(embers["size"][i])], x, y, color)

    # Wet-street reflection of the band just above the ground line.
    band = 78
    src_top = GROUND - band
    if src_top > 0:
        reflected = frame[src_top:GROUND][::-1]
        fade = np.linspace(0.18, 0.0, reflected.shape[0], dtype=np.float32)[:, None, None]
        y_a = GROUND
        y_b = min(H, GROUND + reflected.shape[0])
        frame[y_a:y_b] = np.clip(frame[y_a:y_b] + reflected[: y_b - y_a] * fade[: y_b - y_a], 0, 1)

    # Floor fade so the HTML loading bar has a quiet place to sit.
    ramp_y = np.clip((np.arange(H, dtype=np.float32) - 860) / 220.0, 0, 1)[:, None, None]
    frame *= 1.0 - ramp_y * 0.38

    frame *= cache["vig"][..., None]
    frame = np.clip(frame + cache["grain"][..., None] * 0.012, 0, 1)

    # Wordmark.
    scrim = cache["scrim_a"][..., None]
    frame = frame * (1.0 - scrim) + frame * scrim * 0.25
    frame = frame * (1.0 - cache["glow_a"]) + cache["glow_rgb"] * cache["glow_a"] + frame * (1.0 - cache["glow_a"]) * 0
    # The line above double-counts. Composite glow then text properly.
    # Recompute from pre-glow frame: undo is messy, so composite sequentially below.

    return frame


def composite_text(frame: np.ndarray, cache: dict) -> np.ndarray:
    """Apply scrim, glow and wordmark. `frame` must be the graded picture."""
    scrim = cache["scrim_a"][..., None]
    base = frame * (1.0 - scrim * 0.72)
    glow_a = cache["glow_a"]
    base = base * (1.0 - glow_a) + cache["glow_rgb"] * glow_a
    text_a = cache["text_a"]
    base = base * (1.0 - text_a) + cache["text_rgb"] * text_a
    return np.clip(base, 0, 1)


def render_frame(phase: float, cache: dict) -> np.ndarray:  # noqa: F811
    frame = cache["sky"].copy()

    xs, ys, mag, star_phase, cycles = cache["stars"]
    twinkle = 0.55 + 0.45 * np.sin(np.pi * 2 * (cycles * phase + star_phase))
    bright = np.clip(mag * twinkle, 0, 1)
    frame[ys, xs] += np.array([0.78, 0.84, 1.0], dtype=np.float32) * bright[:, None]

    frame += corona_image(phase)

    back_color = np.array([0.11, 0.07, 0.15], dtype=np.float32)
    back_a = np.clip(cache["back_mask"] * 0.95, 0, 1)[..., None]
    frame = frame * (1.0 - back_a) + back_color * cache["back_shade"][..., None]

    roofs = cache["front_roofs"]
    ys_grid = np.arange(H, dtype=np.float32)[:, None]
    above = roofs.astype(np.float32) - ys_grid
    rim = np.exp(-(np.clip(above, 0, None) ** 2) / (2 * 14.0**2))
    rim *= (above > 0).astype(np.float32)
    rim *= np.exp(-((np.arange(W, dtype=np.float32) - CX) ** 2) / (2 * 340.0**2))
    rim *= 1.0 - np.clip(cache["front_mask"], 0, 1)
    frame += rim[..., None] * np.array([1.0, 0.62, 0.28], dtype=np.float32) * 0.28

    shade = cache["front_shade"]
    front_rgb = np.array([0.018, 0.014, 0.026], dtype=np.float32) * (0.55 + shade * 1.5)[..., None]
    front_a = np.clip(cache["front_mask"], 0, 1)[..., None]
    frame = frame * (1.0 - front_a) + front_rgb

    y0, y1, x0, x1, disc, eclipse_rgb = sharp_eclipse(phase)
    open_sky = 1.0 - np.clip(cache["front_mask"][y0:y1, x0:x1], 0, 1)[..., None]
    region = frame[y0:y1, x0:x1]
    disc_m = disc[..., None] * open_sky
    region[:] = region * (1.0 - disc_m) + np.array([0.008, 0.007, 0.012], dtype=np.float32) * disc_m
    region += eclipse_rgb * open_sky
    frame[y0:y1, x0:x1] = region

    factors = np.ones(5, dtype=np.float32)
    factors[1:] = 0.60 + 0.40 * np.sin(np.pi * 2 * (phase + np.array([0.0, 0.23, 0.51, 0.77])))
    flicker = np.ones((H, W), dtype=np.float32)
    groups = cache["groups"]
    for gid in range(5):
        flicker[groups == gid] = factors[gid]
    frame += cache["windows"] * flicker[..., None]

    blink = 0.25 + 0.75 * (np.sin(np.pi * 2 * phase * 2) ** 8)
    beacon = np.array([1.0, 0.28, 0.18], dtype=np.float32) * float(blink)
    for bx, by in cache["beacons"]:
        paste_add(frame, cache["sprites"][2], bx, by, beacon)

    embers = cache["embers"]
    for i in range(embers["x"].shape[0]):
        px = (embers["x"][i] + embers["drift"][i] * np.sin(np.pi * 2 * phase)) % 1.0
        py = (embers["y"][i] - embers["speed"][i] * phase) % 1.0
        x = int(px * (W - 1))
        y = int(0.46 * H + py * 0.50 * H)
        if not (0 <= y < H and y < roofs[x] - 6):
            continue
        pulse = 0.4 + 0.6 * (0.5 + 0.5 * np.sin(np.pi * 2 * (phase * 2 + embers["phase"][i])))
        color = np.array([1.0, 0.52 + 0.28 * embers["warm"][i], 0.18], dtype=np.float32) * pulse * 0.7
        paste_add(frame, cache["sprites"][int(embers["size"][i])], x, y, color)

    band = 70
    src_top = max(0, GROUND - band)
    reflected = frame[src_top:GROUND][::-1]
    fade = np.linspace(0.16, 0.0, reflected.shape[0], dtype=np.float32)[:, None, None]
    y_a = min(H - 1, GROUND)
    y_b = min(H, y_a + reflected.shape[0])
    frame[y_a:y_b] += reflected[: y_b - y_a] * fade[: y_b - y_a]

    ramp = np.clip((np.arange(H, dtype=np.float32) - 880.0) / 200.0, 0, 1)[:, None]
    frame *= (1.0 - ramp * 0.42)[..., None]
    frame *= cache["vig"][..., None]
    frame = np.clip(frame + cache["grain"][..., None] * 0.011, 0, 1)
    frame = composite_text(frame, cache)
    return np.clip(frame * 255.0, 0, 255).astype(np.uint8)


def write_preview(cache: dict, directory: Path):
    directory.mkdir(parents=True, exist_ok=True)
    for phase in (0.0, 0.25, 0.5, 0.75):
        frame = render_frame(phase, cache)
        path = directory / f"frame_{int(phase * 100):02d}.png"
        Image.fromarray(frame, "RGB").save(path, optimize=True)
        print(path, flush=True)


def write_video(cache: dict, path: Path):
    frames = int(FPS * DURATION)
    path.parent.mkdir(parents=True, exist_ok=True)
    cmd = [
        "ffmpeg",
        "-y",
        "-f",
        "rawvideo",
        "-pix_fmt",
        "rgb24",
        "-s",
        f"{W}x{H}",
        "-r",
        str(FPS),
        "-i",
        "pipe:0",
        "-an",
        "-c:v",
        "libx264",
        "-preset",
        "slow",
        "-crf",
        "17",
        "-pix_fmt",
        "yuv420p",
        "-profile:v",
        "high",
        "-movflags",
        "+faststart",
        "-tune",
        "film",
        str(path),
    ]
    proc = subprocess.Popen(cmd, stdin=subprocess.PIPE)
    assert proc.stdin is not None
    for index in range(frames):
        phase = index / frames
        frame = render_frame(phase, cache)
        proc.stdin.write(frame.tobytes())
        if index % FPS == 0:
            print(f"frame {index}/{frames}", flush=True)
    proc.stdin.close()
    code = proc.wait()
    if code != 0:
        raise SystemExit(f"ffmpeg exited {code}")
    poster = render_frame(0.08, cache)
    Image.fromarray(poster, "RGB").save(ASSET_DIR / "poster.jpg", quality=92, optimize=True)
    print(path, flush=True)


def loop_freq(hz: float, seconds: int) -> float:
    return round(hz * seconds) / seconds


def render_audio(path: Path, seconds: int = 24, sr: int = 44100):
    """Original seamless pad. Replace the ogg if the server has its own theme."""
    n = seconds * sr
    t = np.arange(n, dtype=np.float64) / sr

    def tone(hz: float, amp: float, harmonic: int = 1) -> np.ndarray:
        freq = loop_freq(hz, seconds) * harmonic
        return amp * np.sin(2 * np.pi * freq * t)

    pad = (
        tone(55.0, 0.20)
        + tone(55.0 + 2 / seconds, 0.12)
        + tone(82.41, 0.09)
        + tone(110.0, 0.07)
        + tone(130.81, 0.055)
        + tone(164.81, 0.035)
        + tone(220.0, 0.015)
        + tone(55.0, 0.05, harmonic=3)
    )
    trem = 0.84 + 0.16 * np.sin(2 * np.pi * t * (2 / seconds))
    pad *= trem

    rng = np.random.default_rng(5)
    air = np.zeros(n, dtype=np.float64)
    for _ in range(28):
        k = int(rng.integers(180 * seconds, 480 * seconds))
        amp = rng.uniform(0.0003, 0.0011)
        phase = rng.uniform(0, 2 * np.pi)
        air += amp * np.sin(2 * np.pi * (k / seconds) * t + phase)

    beat = np.zeros(n, dtype=np.float64)
    decay_n = int(0.28 * sr)
    env = np.exp(-np.linspace(0, 5.5, decay_n))
    thump = np.sin(2 * np.pi * loop_freq(46, seconds) * np.arange(decay_n) / sr) * env
    for second in range(seconds):
        start = second * sr
        beat[start : start + decay_n] += thump * 0.09

    audio = np.tanh(pad * 1.35) * 0.85 + air + beat
    peak = np.max(np.abs(audio))
    audio *= 0.24 / max(peak, 1e-6)
    samples = np.clip(audio * 32767.0, -32767, 32767).astype(np.int16)

    wav_path = path.with_suffix(".wav")
    with wave.open(str(wav_path), "w") as handle:
        handle.setnchannels(1)
        handle.setsampwidth(2)
        handle.setframerate(sr)
        handle.writeframes(samples.tobytes())
    cmd = [
        "ffmpeg",
        "-y",
        "-i",
        str(wav_path),
        "-c:a",
        "libvorbis",
        "-q:a",
        "6",
        str(path),
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    wav_path.unlink(missing_ok=True)
    print(path, flush=True)


def main():
    parser = argparse.ArgumentParser(description="Render the Eclipse Roleplay loading screen media.")
    parser.add_argument("--preview", action="store_true", help="Write four preview stills and stop.")
    parser.add_argument("--preview-dir", type=Path, default=Path("/tmp/eclipse-preview"))
    parser.add_argument("--skip-audio", action="store_true")
    args = parser.parse_args()

    cache = build_caches()
    if args.preview:
        write_preview(cache, args.preview_dir)
        return
    write_video(cache, ASSET_DIR / "background.mp4")
    if not args.skip_audio:
        render_audio(ASSET_DIR / "theme.ogg")


if __name__ == "__main__":
    main()
