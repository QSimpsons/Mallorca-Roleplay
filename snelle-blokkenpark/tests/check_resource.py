#!/usr/bin/env python3
"""Controleert snelle-blokkenpark zonder FiveM: syntax, indeling en bestanden."""

import math
import os
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
REPO = os.path.abspath(os.path.join(ROOT, '..'))

BENCHES = [
    (172.57, -980.61),
    (173.14, -981.66),
    (183.61, -986.71),
    (184.77, -986.34),
    (190.24, -981.94),
    (190.62, -980.86),
    (188.39, -970.14),
    (187.40, -969.39),
    (181.44, -967.49),
    (180.15, -967.68),
    (173.71, -971.83),
    (173.09, -973.03),
    (214.33, -867.11),
    (213.72, -866.20),
]
SPAWN = (202.331, -931.175)
GARAGES = [
    (213.93, -809.30, 16.0),
    (208.31, -795.98, 12.0),
    (127.85, -1055.32, 16.0),
    (140.00, -1075.00, 18.0),
]

REQUIRED = [
    'fxmanifest.lua',
    'config.lua',
    'client/util.lua',
    'client/props.lua',
    'client/parking.lua',
    'server/main.lua',
    'html/sign.html',
    'html/img/logo.png',
    'client/logos.lua',
    'data/parked.json',
    'README.md',
    'INSTALL.txt',
]


def dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])


def fail(msg):
    print('FAIL:', msg)
    return 1


def lua_bin():
    for name in ('lua5.4', 'lua'):
        path = subprocess.run(['bash', '-lc', f'command -v {name}'], capture_output=True, text=True)
        if path.returncode == 0 and path.stdout.strip():
            return path.stdout.strip()
    return None


def syntax_check(lua):
    errors = 0
    for dirpath, _, files in os.walk(ROOT):
        for name in files:
            if not name.endswith('.lua'):
                continue
            path = os.path.join(dirpath, name)
            proc = subprocess.run([lua, '-e', f"assert(loadfile({path!r}))"], capture_output=True, text=True)
            if proc.returncode != 0:
                print(proc.stderr)
                errors += fail(f'syntax {os.path.relpath(path, ROOT)}')
    return errors


def load_config(lua):
    script = r'''
function vector3(x, y, z)
  return { x = x, y = y, z = z }
end
function vector4(x, y, z, w)
  return { x = x, y = y, z = z, w = w }
end
dofile(__CONFIG__)
local function line(kind, ...)
  print(kind .. " " .. table.concat({ ... }, " "))
end
line("count", #Config.Props)
for i = 1, #Config.Props do
  local p = Config.Props[i]
  line("prop", p.model, p.coords.x, p.coords.y, p.coords.z, p.heading)
end
line("signs", #Config.Signs)
for i = 1, #Config.Signs do
  local s = Config.Signs[i]
  line("sign", s.id, s.x, s.y, s.heading, s.kind)
end
line("spots", #Config.Parking.spots)
for i = 1, #Config.Parking.spots do
  local s = Config.Parking.spots[i]
  line("spot", s.id, s.coords.x, s.coords.y, s.coords.z, s.coords.w)
end
line("candidates", #Config.Parking.candidates)
line("max", Config.MaxPerPlayer)
line("center", Config.ParkCenter.x, Config.ParkCenter.y)
'''
    config_path = os.path.join(ROOT, 'config.lua').replace('\\', '\\\\')
    script = script.replace('__CONFIG__', repr(config_path))
    proc = subprocess.run([lua, '-e', script], capture_output=True, text=True)
    if proc.returncode != 0:
        print(proc.stderr)
        raise RuntimeError('config.lua kon niet geladen worden')
    props, signs, spots = [], [], []
    meta = {}
    for raw in proc.stdout.splitlines():
        parts = raw.split()
        kind = parts[0]
        if kind == 'prop':
            props.append({
                'model': parts[1],
                'x': float(parts[2]),
                'y': float(parts[3]),
                'z': float(parts[4]),
                'h': float(parts[5]),
            })
        elif kind == 'sign':
            signs.append({'id': parts[1], 'x': float(parts[2]), 'y': float(parts[3])})
        elif kind == 'spot':
            spots.append({
                'id': int(parts[1]),
                'x': float(parts[2]),
                'y': float(parts[3]),
                'z': float(parts[4]),
                'w': float(parts[5]),
            })
        elif kind in ('count', 'signs', 'spots', 'candidates', 'max'):
            meta[kind] = int(float(parts[1]))
        elif kind == 'center':
            meta['center'] = (float(parts[1]), float(parts[2]))
    return props, signs, spots, meta


def main():
    errors = 0
    for rel in REQUIRED:
        if not os.path.isfile(os.path.join(ROOT, rel)):
            errors += fail(f'ontbreekt: {rel}')

    manifest = open(os.path.join(ROOT, 'fxmanifest.lua'), encoding='utf-8').read()
    for rel in ('config.lua', 'client/util.lua', 'client/logos.lua', 'client/props.lua', 'client/parking.lua', 'server/main.lua', 'html/sign.html', 'html/img/logo.png'):
        if rel not in manifest:
            errors += fail(f'fxmanifest noemt {rel} niet')

    html = open(os.path.join(ROOT, 'html/sign.html'), encoding='utf-8').read()
    if 'BLOKKENPARK' not in html or 'ONDERGRONDS' not in html:
        errors += fail('bord mist de teksten')
    if "type') === 'parking'" not in html and 'type") === "parking"' not in html:
        errors += fail('parkeerbord wisselt niet op ?type=parking')

    parked = open(os.path.join(ROOT, 'data/parked.json'), encoding='utf-8').read().strip()
    if parked not in ('{}', '[]'):
        errors += fail('data/parked.json hoort leeg te starten')

    lua = lua_bin()
    if not lua:
        print('GEEN LUA: syntax en indeling overgeslagen')
        return 1 if errors else 0

    errors += syntax_check(lua)
    props, signs, spots, meta = load_config(lua)

    if meta.get('count', 0) != 0:
        errors += fail('het bestaande Blokkenpark hoort leeg te blijven, geen extra props')
    if meta.get('spots') != 10:
        errors += fail(f'verwacht 10 vakken, kreeg {meta.get("spots")}')
    if meta.get('max') != 2:
        errors += fail('MaxPerPlayer hoort 2 te zijn')
    if len({s['id'] for s in spots}) != 10:
        errors += fail('parkeervak-ids zijn niet uniek')

    ids = [s['id'] for s in spots]
    if ids != list(range(1, 11)):
        errors += fail(f'vaknummers kloppen niet: {ids}')

    for i, a in enumerate(props):
        if not a['model'].startswith('prop_'):
            errors += fail(f'onverwacht model {a["model"]}')
        if not (28.0 <= a['z'] <= 32.0):
            errors += fail(f'{a["model"]} z={a["z"]} ligt niet op straatniveau')
        for b in props[i + 1:]:
            gap = dist((a['x'], a['y']), (b['x'], b['y']))
            if gap < 2.2:
                errors += fail(f'{a["model"]} en {b["model"]} staan {gap:.2f}m uit elkaar')
        for bench in BENCHES:
            gap = dist((a['x'], a['y']), bench)
            if gap < 2.8:
                errors += fail(f'{a["model"]} staat {gap:.2f}m van een bestaand bankje')
        if dist((a['x'], a['y']), SPAWN) < 7.0:
            errors += fail(f'{a["model"]} blokkeert de Legion-spawn')
        for gx, gy, radius in GARAGES:
            if dist((a['x'], a['y']), (gx, gy)) < radius:
                errors += fail(f'{a["model"]} staat in een bestaande Blokkenpark-garage')

    for i, a in enumerate(spots):
        if a['z'] > -90:
            errors += fail(f'vak {a["id"]} is niet ondergronds')
        for b in spots[i + 1:]:
            if dist((a['x'], a['y']), (b['x'], b['y'])) < 3.5:
                errors += fail(f'vak {a["id"]} en {b["id"]} staan te dicht op elkaar')

    center = meta['center']
    for prop in props:
        if dist((prop['x'], prop['y']), center) > 160:
            errors += fail(f'{prop["model"]} ligt buiten het plein')

    if len(signs) < 2:
        errors += fail('er horen minstens twee borden te zijn')

    print(f'props={len(props)} vakken={len(spots)} borden={len(signs)}')
    if errors:
        print(f'{errors} fouten')
        return 1
    print('OK')
    return 0


if __name__ == '__main__':
    sys.exit(main())
