#!/usr/bin/env python3
"""Lightweight checks for mallorca-takel v2 (no FiveM runtime)."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []

required = [
    'fxmanifest.lua',
    'config.lua',
    'client/main.lua',
    'client/tow.lua',
    'client/target.lua',
    'server/main.lua',
    'sql/install.sql',
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'README.md',
    'INSTALL.txt',
]
for rel in required:
    if not (ROOT / rel).exists():
        errors.append(f'missing {rel}')

sql = (ROOT / 'sql/install.sql').read_text(encoding='utf-8')
for needle in ('mallorca_impound', 'mallorca_takel_calls'):
    if needle not in sql:
        errors.append(f'sql missing {needle}')
if re.search(r"INSERT INTO `jobs`", sql):
    errors.append('sql must not create a separate takel job; use mechanic 1-6')

cfg = (ROOT / 'config.lua').read_text(encoding='utf-8')
for name in ('fmltow', 'dlbrickade'):
    if name not in cfg:
        errors.append('config missing ' + name)
if re.search(r'\[`towtruck', cfg) or re.search(r'\[`flatbed', cfg):
    errors.append('vanilla tow vehicles should not be in config')
if "menu = 'F1'" not in cfg or "toggle = 'O'" not in cfg:
    errors.append('keys must be F1 tablet and O attach')
if "CallCommand = 'takelnodig'" not in cfg:
    errors.append('config must expose /takelnodig for pechhulp alerts')
if "JobName = 'mechanic'" not in cfg:
    errors.append('config must use mechanic job')
if 'MinGrade = 1' not in cfg or 'MaxGrade = 6' not in cfg:
    errors.append('config must allow mechanic grades 1-6')

manifest = (ROOT / 'fxmanifest.lua').read_text(encoding='utf-8')
for needle in ("ui_page 'html/index.html'", 'client/tow.lua', 'client/target.lua', 'server/main.lua', 'config.lua'):
    if needle not in manifest:
        errors.append(f'manifest missing {needle}')

html = (ROOT / 'html/index.html').read_text(encoding='utf-8')
for needle in ('btn-attach', 'btn-impound', 'page-calls', 'page-garage', 'Mallorca Takel'):
    if needle not in html:
        errors.append(f'html missing {needle}')

tow = (ROOT / 'client/tow.lua').read_text(encoding='utf-8')
if 'AttachEntityToEntity' not in tow:
    errors.append('tow.lua must attach to the bed with AttachEntityToEntity')
if 'AttachVehicleToTowTruck' in tow:
    errors.append('do not use GTA hook native AttachVehicleToTowTruck')
if 'IsThisModelATowTruck' in tow:
    errors.append('client must not call IsThisModelATowTruck')
if 'pinToBed' not in tow:
    errors.append('tow.lua missing bed slide/pin')

client = (ROOT / 'client/main.lua').read_text(encoding='utf-8')
for needle in ('mallorca_takel_toggle', 'doAttach', 'doDetach', 'fmltow', 'dlbrickade', 'takelnodig'):
    if needle not in client:
        errors.append('client missing ' + needle)

server = (ROOT / 'server/main.lua').read_text(encoding='utf-8')
for needle in ('mallorca-takel:server:impound', 'mallorca-takel:server:syncAttach', 'isEmployee', 'call_none_online'):
    if needle not in server:
        errors.append('server missing ' + needle)

js = (ROOT / 'html/app.js').read_text(encoding='utf-8')
for needle in ('toggleDuty', 'attach', 'impound', 'acceptCall', 'spawnTruck'):
    if needle not in js:
        errors.append(f'app.js missing {needle}')


def lua_balance(text, label):
    stripped = re.sub(r'--\[\[.*?\]\]', '', text, flags=re.S)
    stripped = re.sub(r'--[^\n]*', '', stripped)
    stripped = re.sub(r"'[^']*'", "''", stripped)
    stripped = re.sub(r'"[^"]*"', '""', stripped)
    opens = len(re.findall(r'\b(function|then|do)\b', stripped))
    opens -= len(re.findall(r'\belseif\b', stripped))
    closes = len(re.findall(r'\bend\b', stripped))
    if opens != closes:
        errors.append(f'{label} function/then/do vs end imbalance ({opens} vs {closes})')
    if stripped.count('(') != stripped.count(')'):
        errors.append(f'{label} unmatched parentheses')


lua_files = {
    'config': cfg,
    'tow': tow,
    'client': client,
    'server': server,
    'target': (ROOT / 'client/target.lua').read_text(encoding='utf-8'),
}
for label, text in lua_files.items():
    lua_balance(text, label)
    if 'TODO' in text or 'FIXME' in text:
        errors.append(f'{label} still has TODO/FIXME')

if errors:
    print('FAIL')
    for err in errors:
        print(' -', err)
    sys.exit(1)

print('OK mallorca-takel')
