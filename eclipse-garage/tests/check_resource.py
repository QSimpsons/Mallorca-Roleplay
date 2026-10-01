#!/usr/bin/env python3
"""Lightweight checks for eclipse-garage (no FiveM runtime)."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []

required = [
    'fxmanifest.lua',
    'config.lua',
    'client/main.lua',
    'server/main.lua',
    'sql/install.sql',
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/auto-demo.html',
    'README.md',
    'INSTALL.md',
]
for rel in required:
    if not (ROOT / rel).exists():
        errors.append(f'missing {rel}')

sql = (ROOT / 'sql/install.sql').read_text(encoding='utf-8')
for needle in ('mallorca_impound', 'eclipse_garage_log', 'owned_vehicles', 'stored', 'parking', 'pound'):
    if needle not in sql:
        errors.append(f'sql missing {needle}')

manifest = (ROOT / 'fxmanifest.lua').read_text(encoding='utf-8')
for needle in ("ui_page 'html/index.html'", 'client/main.lua', 'server/main.lua', 'config.lua', 'es_extended'):
    if needle not in manifest:
        errors.append(f'manifest missing {needle}')

config = (ROOT / 'config.lua').read_text(encoding='utf-8')
for needle in ('Config.Garages', 'Config.Impounds', 'Config.NormalizePlate', 'impound_davis', 'legion', 'oproep'):
    if needle not in config:
        errors.append(f'config missing {needle}')

server = (ROOT / 'server/main.lua').read_text(encoding='utf-8')
client = (ROOT / 'client/main.lua').read_text(encoding='utf-8')
for needle in (
    'eclipse-garage:server:list',
    'eclipse-garage:server:spawn',
    'eclipse-garage:server:store',
    'eclipse-garage:server:staffImpound',
    'mallorca_impound',
    'owned_vehicles',
):
    if needle not in server:
        errors.append(f'server missing {needle}')

for needle in (
    'eclipse-garage:client:spawn',
    'eclipse-garage:client:stored',
    'RegisterNUICallback',
    'CreateVehicle',
    'oproep',
):
    if needle not in client:
        errors.append(f'client missing {needle}')

html = (ROOT / 'html/index.html').read_text(encoding='utf-8')
for needle in ('id="list"', 'id="search"', 'id="close"', 'Eclipse Garage'):
    if needle not in html:
        errors.append(f'html missing {needle}')

js = (ROOT / 'html/app.js').read_text(encoding='utf-8')
for needle in ("post('take'", "post('close'", "post('refresh'", 'demoPayload', 'Impound'):
    if needle not in js:
        errors.append(f'app.js missing {needle}')

for path in (ROOT / 'client/main.lua', ROOT / 'server/main.lua', ROOT / 'config.lua'):
    text = path.read_text(encoding='utf-8')
    if 'TODO' in text or 'FIXME' in text:
        errors.append(f'{path.name} still has TODO/FIXME')

if errors:
    print('FAIL')
    for err in errors:
        print(' -', err)
    sys.exit(1)

print('OK eclipse-garage files complete')
