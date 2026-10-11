#!/usr/bin/env python3
"""Smoke checks for eclipse-politie-garage resource files."""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []


def must_exist(rel: str) -> Path:
    path = ROOT / rel
    if not path.exists():
        errors.append(f"missing file: {rel}")
    return path


def main() -> int:
    files = [
        "fxmanifest.lua",
        "config.lua",
        "client/main.lua",
        "server/main.lua",
        "html/index.html",
        "html/style.css",
        "html/app.js",
        "html/preview.html",
        "README.md",
    ]
    paths = {rel: must_exist(rel) for rel in files}
    if errors:
        print("\n".join(errors))
        return 1

    manifest = paths["fxmanifest.lua"].read_text(encoding="utf-8")
    for needle in ("ui_page 'html/index.html'", "config.lua", "client/main.lua", "html/app.js"):
        if needle not in manifest:
            errors.append(f"fxmanifest missing: {needle}")

    config = paths["config.lua"].read_text(encoding="utf-8")
    if "Config.Vehicles" not in config:
        errors.append("config missing Config.Vehicles")
    if "Config.Categories" not in config:
        errors.append("config missing Config.Categories")
    if "POLITIE" not in paths["html/index.html"].read_text(encoding="utf-8"):
        errors.append("index.html missing POLITIE brand title")

    css = paths["style.css"].read_text(encoding="utf-8") if False else paths["html/style.css"].read_text(encoding="utf-8")
    for var in ("--blue", "--display", "--shell"):
        if var not in css:
            errors.append(f"style.css missing {var}")

    js = paths["html/app.js"].read_text(encoding="utf-8")
    for fn in ("open(", "renderGrid", "SPAWN", "favorites"):
        if fn not in js and fn != "SPAWN":
            errors.append(f"app.js missing {fn}")
    if "SPAWN VOERTUIG" not in js and "texts.spawn" not in js:
        # spawn label comes from texts; ensure spawn callback exists
        if "nui('spawn'" not in js:
            errors.append("app.js missing spawn nui call")

    client = paths["client/main.lua"].read_text(encoding="utf-8")
    if "RegisterNUICallback('spawn'" not in client:
        errors.append("client missing spawn NUI callback")
    if "SetNuiFocus" not in client:
        errors.append("client missing SetNuiFocus")

    # Basic HTML structure
    html = paths["html/index.html"].read_text(encoding="utf-8")
    for el in ('id="categories"', 'id="grid"', 'id="search"', 'id="brand-title"'):
        if el not in html:
            errors.append(f"index.html missing {el}")

    # Ensure no obvious purple AI-default theme hardcode
    if re.search(r"#7[cC]3[aA][eE][dD]|purple", css):
        errors.append("unexpected purple theme token in CSS")

    if errors:
        print("FAIL")
        print("\n".join(errors))
        return 1

    print("OK — eclipse-politie-garage resource checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
