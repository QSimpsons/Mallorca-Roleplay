#!/usr/bin/env python3
"""Rebuild Eclipse RP Staff vest .ytd files from PNG textures (Linux/macOS/Windows).

Requires: pip install pillow texfury
On Linux, texfury's native DLL is stubbed at runtime for uncompressed A8R8G8B8 packing.
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TEX = ROOT / "textures"
STREAM = ROOT / "stream"


def main() -> int:
    try:
        from PIL import Image
        from texfury import ITD, Texture, BCFormat
        from texfury.formats import mip_data_size
    except Exception as exc:  # noqa: BLE001
        print("Install deps: pip install pillow texfury", file=sys.stderr)
        print(exc, file=sys.stderr)
        return 1

    STREAM.mkdir(exist_ok=True)
    name = "task_diff_001_a_uni"
    src = TEX / "vest_diffuse_1024.png"
    if not src.exists():
        src = TEX / "vest_diffuse.png"
    if not src.exists():
        print(f"Missing diffuse texture in {TEX}", file=sys.stderr)
        return 1

    img = Image.open(src).convert("RGBA")
    w, h = img.size

    def rgba_to_bgra(im: Image.Image) -> bytes:
        return im.convert("RGBA").tobytes("raw", "BGRA")

    levels = 0
    tw, th = w, h
    while True:
        levels += 1
        if tw == 1 and th == 1:
            break
        tw, th = max(1, tw // 2), max(1, th // 2)

    chunks: list[bytes] = []
    offsets: list[int] = []
    sizes: list[int] = []
    offset = 0
    cur = img
    tw, th = w, h
    for i in range(levels):
        data = rgba_to_bgra(cur)
        assert len(data) == mip_data_size(tw, th, BCFormat.A8R8G8B8)
        offsets.append(offset)
        sizes.append(len(data))
        chunks.append(data)
        offset += len(data)
        if i + 1 < levels:
            tw, th = max(1, tw // 2), max(1, th // 2)
            cur = cur.resize((tw, th), Image.Resampling.LANCZOS)

    tex = Texture.from_raw(b"".join(chunks), w, h, BCFormat.A8R8G8B8, levels, offsets, sizes, name)
    td = ITD()
    td.add(tex)
    for ped in ("mp_m_freemode_01", "mp_f_freemode_01"):
        out = STREAM / f"{ped}^{name}.ytd"
        td.save(out)
        print(f"wrote {out} ({out.stat().st_size} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
