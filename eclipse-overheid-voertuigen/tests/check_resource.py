#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []

def must(rel):
    p = ROOT / rel
    if not p.exists():
        errors.append(f"missing {rel}")
    return p

def main():
    files = {
        "fxmanifest.lua": must("fxmanifest.lua"),
        "config.lua": must("config.lua"),
        "client/main.lua": must("client/main.lua"),
        "README.md": must("README.md"),
    }
    if errors:
        print("\n".join(errors)); return 1

    manifest = files["fxmanifest.lua"].read_text(encoding="utf-8")
    for n in ("config.lua", "client/main.lua"):
        if n not in manifest:
            errors.append(f"fxmanifest missing {n}")

    cfg = files["config.lua"].read_text(encoding="utf-8")
    for n in ("Config.Models", "Config.Jobs", "Config.Proofs", "polargento1"):
        if n not in cfg:
            errors.append(f"config missing {n}")

    client = files["client/main.lua"].read_text(encoding="utf-8")
    for n in ("SetEntityProofs", "SetVehicleTyresCanBurst", "applyProtection", "ProtectVehicle", "applySpeedSettings", "ModifyVehicleTopSpeed", "SetEntityInvincible", "lockZeroDamage", "ZeroDamage"):
        if n not in client and n != "ZeroDamage":
            errors.append(f"client missing {n}")
    if "ZeroDamage" not in cfg:
        errors.append("config missing ZeroDamage")
    if "SetVehicleFixed(" in client:
        errors.append("client must not call SetVehicleFixed (causes high-speed stutter)")
    if "MaxSpeedKmh" not in cfg:
        errors.append("config missing MaxSpeedKmh")

    if errors:
        print("FAIL"); print("\n".join(errors)); return 1
    print("OK — eclipse-overheid-voertuigen checks passed")
    return 0

if __name__ == "__main__":
    sys.exit(main())
