-- ═══════════════════════════════════════════════════════════════
-- Snelle Handcarwash · ESX items
-- Importeer dit bestand in je database (phpMyAdmin / HeidiSQL / mysql CLI)
--
-- ESX Legacy / ESX 1.2+  (kolom `weight`)
-- Oudere ESX met `limit`: gebruik sql/esx_limit_items.sql
-- 24/7 via esx_shops:     gebruik sql/esx_shops.sql (optioneel)
--
-- ox_inventory: SQL is niet nodig. Plak sql/ox_inventory_items.lua
-- in ox_inventory/data/items.lua
-- ═══════════════════════════════════════════════════════════════

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
    ('empty_bucket',     'Lege emmer',       500,  0, 1),
    ('water_bucket',     'Emmer water',      3500, 0, 1),
    ('car_sponge',       'Autospong',        200,  0, 1),
    ('car_soap',         'Autoshampoo',      400,  0, 1),
    ('microfiber_cloth', 'Microvezeldoek',   150,  0, 1),
    ('car_wax',          'Autowax',          350,  0, 1),
    ('tire_cleaner',     'Velgenreiniger',   400,  0, 1),
    ('hand_carwash_kit', 'Handwas set',      4500, 0, 1)
ON DUPLICATE KEY UPDATE
    `label` = VALUES(`label`),
    `weight` = VALUES(`weight`),
    `rare` = VALUES(`rare`),
    `can_remove` = VALUES(`can_remove`);

