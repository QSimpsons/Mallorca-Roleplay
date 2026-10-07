#!/usr/bin/env python3
"""Lightweight checks for snelle-garage (no FiveM runtime)."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []

required = [
    'fxmanifest.lua',
    'config.lua',
    'locations.lua',
    'shared/owner.lua',
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
for needle in ('mallorca_impound', 'snelle_garage_log', 'owned_vehicles', 'stored', 'parking', 'pound'):
    if needle not in sql:
        errors.append(f'sql missing {needle}')

manifest = (ROOT / 'fxmanifest.lua').read_text(encoding='utf-8')
for needle in ("ui_page 'html/index.html'", 'client/main.lua', 'server/main.lua', 'config.lua', 'locations.lua', 'shared/owner.lua', 'es_extended'):
    if needle not in manifest:
        errors.append(f'manifest missing {needle}')

config = (ROOT / 'config.lua').read_text(encoding='utf-8')
for needle in (
    'Config.Garages',
    'Config.Impounds',
    'Config.NormalizePlate',
    "label = 'Impound'",
    'impound_davis',
    'impound_sandy',
    'impound_boten',
    'impound_lsia',
    'vector4(401.28, -1632.77, 29.29, 230.0)',
    'vector4(-780.20, -1425.40, -0.30, 140.0)',
    'vector4(-1271.50, -3380.20, 13.94, 330.0)',
    'oproep',
    'airplane',
):
    if needle not in config:
        errors.append(f'config missing {needle}')

locations = (ROOT / 'locations.lua').read_text(encoding='utf-8')
for needle in (
    "id = 'car-blokkenpark'",
    "id = 'boat-haven'",
    "id = 'aircraft-cova-heli'",
    'vector4(-763.3487, -243.0397, 37.2421, 196.9950)',
    'vector4(46.80, 6364.92, 30.56, 0.0)',
):
    if needle not in locations:
        errors.append(f'locations missing {needle}')
if '1 -' in locations:
    errors.append('locations still has the broken vector expression')

ids = []
depth = 0
for ch in locations:
    if ch == '{':
        depth += 1
    elif ch == '}':
        depth -= 1
        if depth < 0:
            errors.append('locations.lua has extra closing brace')
            break
if depth != 0:
    errors.append(f'locations.lua brace depth ends at {depth}')

ids = re.findall(r"id = '([^']+)'", locations)
if len(ids) != 204:
    errors.append(f'expected 204 garage ids, found {len(ids)}')
if len(ids) != len(set(ids)):
    errors.append('garage ids are not unique')
if locations.count('vector4(') != 374:
    errors.append(f"expected 374 spawn points, found {locations.count('vector4(')}")
if locations.count('coords = vector3') != 204 or locations.count('store = vector3') != 204:
    errors.append('each garage place needs its own take-out and park marker')
id_marks = list(re.finditer(r"id = '([^']+)'", locations))
for index, match in enumerate(id_marks):
    end = id_marks[index + 1].start() if index + 1 < len(id_marks) else len(locations)
    chunk = locations[match.end():end]
    for field in ('coords = vector3', 'store = vector3'):
        if field not in chunk:
            errors.append(f"garage {match.group(1)} missing {field}")
            break

server = (ROOT / 'server/main.lua').read_text(encoding='utf-8')
client = (ROOT / 'client/main.lua').read_text(encoding='utf-8')
for needle in (
    'snelle-garage:server:list',
    'snelle-garage:server:spawn',
    'snelle-garage:server:store',
    'snelle-garage:server:staffImpound',
    'mallorca_impound',
    'owned_vehicles',
    'OnlyPurchasedVehicles',
    'storePurchases',
    'esx_vehicleshop:setVehicleOwnedPlayerId',
    'spawnedVehicle',
    'SnelleOwner.same',
    'ownedByPlayer',
    'fetchOwnedMany',
):
    if needle not in server:
        errors.append(f'server missing {needle}')

for needle in (
    'snelle-garage:client:spawn',
    'snelle-garage:client:stored',
    'RegisterNUICallback',
    'CreateVehicle',
    'oproep',
    'Voertuig uithalen',
    'loc.store',
    'drawMarkerAt',
):
    if needle not in client:
        errors.append(f'client missing {needle}')

html = (ROOT / 'html/index.html').read_text(encoding='utf-8')
for needle in ('id="list"', 'id="search"', 'id="close"', 'Eclipse Garage'):
    if needle not in html:
        errors.append(f'html missing {needle}')

js = (ROOT / 'html/app.js').read_text(encoding='utf-8')
for needle in ("post('take'", "post('close'", "post('refresh'", 'demoPayload', 'Impound', 'Uithalen'):
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

print('OK snelle-garage files complete')
