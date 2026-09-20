-- Oudere ESX met kolom `limit` in plaats van `weight`.
-- Alleen importeren als sql/items.sql faalt.

INSERT INTO `items` (`name`, `label`, `limit`, `rare`, `can_remove`) VALUES
    ('empty_bucket',     'Lege emmer',       10, 0, 1),
    ('water_bucket',     'Emmer water',      5,  0, 1),
    ('car_sponge',       'Autospong',        10, 0, 1),
    ('car_soap',         'Autoshampoo',      20, 0, 1),
    ('microfiber_cloth', 'Microvezeldoek',   20, 0, 1),
    ('car_wax',          'Autowax',          10, 0, 1),
    ('tire_cleaner',     'Velgenreiniger',   15, 0, 1),
    ('hand_carwash_kit', 'Handwas set',      5,  0, 1)
ON DUPLICATE KEY UPDATE
    `label` = VALUES(`label`),
    `limit` = VALUES(`limit`);
