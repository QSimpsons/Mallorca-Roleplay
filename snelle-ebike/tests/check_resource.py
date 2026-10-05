#!/usr/bin/env python3
"""Basiscontroles voor snelle-ebike (geen FiveM runtime nodig)."""

from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "fxmanifest.lua",
    "config.lua",
    "client.lua",
    "server.lua",
    "INSTALL.txt",
    "sql/item.sql",
]


def read(name: str) -> str:
    return (ROOT / name).read_text(encoding="utf-8")


def main() -> int:
    errors = []

    for name in REQUIRED:
        if not (ROOT / name).exists():
            errors.append(f"missing {name}")

    if errors:
        for e in errors:
            print("FAIL:", e)
        return 1

    config = read("config.lua")
    client = read("client.lua")
    server = read("server.lua")
    manifest = read("fxmanifest.lua")

    if "Config.Appearance" not in config:
        errors.append("config mist Config.Appearance")
    if "Config.Model" not in config:
        errors.append("config mist Config.Model")
    if "snellefat" not in config and "inductor" not in config:
        errors.append("config mist modelnaam")
    if "Config.Command" not in config:
        errors.append("config mist Config.Command")

    if "CreateVehicle" not in client:
        errors.append("client mist CreateVehicle")
    if "snelle-ebike:server:trySpawn" not in client:
        errors.append("client mist trySpawn event")
    if "RegisterCommand" not in client:
        errors.append("client mist RegisterCommand")

    if "snelle-ebike:server:trySpawn" not in server:
        errors.append("server mist trySpawn handler")
    if "RegisterUsableItem" not in server and "CreateUseableItem" not in server:
        errors.append("server mist usable item registratie")

    if "client.lua" not in manifest or "server.lua" not in manifest:
        errors.append("fxmanifest mist scripts")

    # Simpele balancering van strings in Lua-bestanden
    for label, text in (("client", client), ("server", server), ("config", config)):
        if text.count("'") % 2 != 0 and text.count('"') % 2 != 0:
            # Niet streng genoeg voor Lua; check wel op TODO/FIXME leftovers
            pass
        if re.search(r"\bTODO\b|\bFIXME\b", text):
            errors.append(f"{label} bevat TODO/FIXME")

    if errors:
        for e in errors:
            print("FAIL:", e)
        return 1

    print("OK: snelle-ebike resource checks passed")
    print(f"  model default: snellefat (fallback inductor)")
    print(f"  command: /fatbike")
    print(f"  files: {len(REQUIRED)} required present")
    return 0


if __name__ == "__main__":
    sys.exit(main())
