-- ============================================================================
-- Mallorca Roleplay · Politie Job
-- Volledige SQL-installatie (ESX Legacy / MySQL / MariaDB)
--
-- 10 rangen (laag → hoog):
--   0 Aspirant
--   1 Surveillant van politie
--   2 Agent
--   3 Hoofdagent
--   4 Brigadier
--   5 Inspecteur
--   6 Hoofdinspecteur
--   7 Commissaris
--   8 Hoofdcommissaris
--   9 Eerste hoofdcommissaris  (boss)
--
-- Importeer dit bestand éénmalig via HeidiSQL / phpMyAdmin / mysql CLI.
-- ============================================================================

-- --------------------------------------------------------------------------
-- Jobs: actief + off-duty
-- --------------------------------------------------------------------------
INSERT INTO `jobs` (`name`, `label`)
SELECT 'police', 'Politie'
WHERE NOT EXISTS (SELECT 1 FROM `jobs` WHERE `name` = 'police');

INSERT INTO `jobs` (`name`, `label`)
SELECT 'offpolice', 'Politie (uit dienst)'
WHERE NOT EXISTS (SELECT 1 FROM `jobs` WHERE `name` = 'offpolice');

-- --------------------------------------------------------------------------
-- Job grades (vervangt bestaande police / offpolice grades)
-- --------------------------------------------------------------------------
DELETE FROM `job_grades` WHERE `job_name` IN ('police', 'offpolice');

INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('police', 0, 'aspirant',                 'Aspirant',                 250,  '{}', '{}'),
('police', 1, 'surveillant',              'Surveillant van politie',  350,  '{}', '{}'),
('police', 2, 'agent',                    'Agent',                    450,  '{}', '{}'),
('police', 3, 'hoofdagent',               'Hoofdagent',               550,  '{}', '{}'),
('police', 4, 'brigadier',                'Brigadier',                650,  '{}', '{}'),
('police', 5, 'inspecteur',               'Inspecteur',               800,  '{}', '{}'),
('police', 6, 'hoofdinspecteur',          'Hoofdinspecteur',          950,  '{}', '{}'),
('police', 7, 'commissaris',              'Commissaris',              1100, '{}', '{}'),
('police', 8, 'hoofdcommissaris',         'Hoofdcommissaris',         1300, '{}', '{}'),
('police', 9, 'eerste_hoofdcommissaris',  'Eerste hoofdcommissaris',  1600, '{}', '{}');

-- Off-duty grades (zelfde labels, salaris 0)
INSERT INTO `job_grades` (`job_name`, `grade`, `name`, `label`, `salary`, `skin_male`, `skin_female`) VALUES
('offpolice', 0, 'aspirant',                 'Aspirant',                 0, '{}', '{}'),
('offpolice', 1, 'surveillant',              'Surveillant van politie',  0, '{}', '{}'),
('offpolice', 2, 'agent',                    'Agent',                    0, '{}', '{}'),
('offpolice', 3, 'hoofdagent',               'Hoofdagent',               0, '{}', '{}'),
('offpolice', 4, 'brigadier',                'Brigadier',                0, '{}', '{}'),
('offpolice', 5, 'inspecteur',               'Inspecteur',               0, '{}', '{}'),
('offpolice', 6, 'hoofdinspecteur',          'Hoofdinspecteur',          0, '{}', '{}'),
('offpolice', 7, 'commissaris',              'Commissaris',              0, '{}', '{}'),
('offpolice', 8, 'hoofdcommissaris',         'Hoofdcommissaris',         0, '{}', '{}'),
('offpolice', 9, 'eerste_hoofdcommissaris',  'Eerste hoofdcommissaris',  0, '{}', '{}');

-- --------------------------------------------------------------------------
-- Society / addon account (esx_addonaccount + esx_society)
-- --------------------------------------------------------------------------
INSERT INTO `addon_account` (`name`, `label`, `shared`)
SELECT 'society_police', 'Politie', 1
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'addon_account'
)
AND NOT EXISTS (SELECT 1 FROM `addon_account` WHERE `name` = 'society_police');

INSERT INTO `addon_account_data` (`account_name`, `money`)
SELECT 'society_police', 0
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'addon_account_data'
)
AND NOT EXISTS (SELECT 1 FROM `addon_account_data` WHERE `account_name` = 'society_police');

INSERT INTO `addon_inventory` (`name`, `label`, `shared`)
SELECT 'society_police', 'Politie', 1
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'addon_inventory'
)
AND NOT EXISTS (SELECT 1 FROM `addon_inventory` WHERE `name` = 'society_police');

INSERT INTO `datastore` (`name`, `label`, `shared`)
SELECT 'society_police', 'Politie', 1
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'datastore'
)
AND NOT EXISTS (SELECT 1 FROM `datastore` WHERE `name` = 'society_police');

INSERT INTO `datastore_data` (`name`, `owner`, `data`)
SELECT 'society_police', NULL, '{}'
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'datastore_data'
)
AND NOT EXISTS (SELECT 1 FROM `datastore_data` WHERE `name` = 'society_police' AND `owner` IS NULL);

-- --------------------------------------------------------------------------
-- Optionele items (standaard ESX items-tabel)
-- Negeren als je ox_inventory gebruikt (zie ox_inventory sectie hieronder)
-- --------------------------------------------------------------------------
INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`)
SELECT 'handcuffs', 'Handboeien', 1, 0, 1
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'items'
)
AND NOT EXISTS (SELECT 1 FROM `items` WHERE `name` = 'handcuffs');

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`)
SELECT 'radio', 'Portofoon', 1, 0, 1
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'items'
)
AND NOT EXISTS (SELECT 1 FROM `items` WHERE `name` = 'radio');

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`)
SELECT 'armor', 'Kogelvrij vest', 2, 0, 1
WHERE EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = DATABASE() AND table_name = 'items'
)
AND NOT EXISTS (SELECT 1 FROM `items` WHERE `name` = 'armor');

-- --------------------------------------------------------------------------
-- Bewijskluis / inbeslagnames log (eigen tabel)
-- --------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `mallorca_politie_impound` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `plate` VARCHAR(12) NOT NULL,
    `owner` VARCHAR(64) DEFAULT NULL,
    `props` LONGTEXT DEFAULT NULL,
    `reason` VARCHAR(128) NOT NULL DEFAULT 'Inbeslagname politie',
    `officer` VARCHAR(64) DEFAULT NULL,
    `officer_name` VARCHAR(80) DEFAULT NULL,
    `impounded_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_plate` (`plate`),
    KEY `idx_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mallorca_politie_fines` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(64) NOT NULL,
    `player_name` VARCHAR(80) DEFAULT NULL,
    `officer` VARCHAR(64) DEFAULT NULL,
    `officer_name` VARCHAR(80) DEFAULT NULL,
    `amount` INT NOT NULL DEFAULT 0,
    `reason` VARCHAR(180) DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------------------------
-- Speler een politiebaan geven (voorbeeld – pas identifier aan)
-- --------------------------------------------------------------------------
-- UPDATE `users` SET `job` = 'police', `job_grade` = 9
-- WHERE `identifier` = 'char1:JOUW_LICENSE_HIER';

-- --------------------------------------------------------------------------
-- ox_inventory items (NIET in SQL, maar in ox_inventory/data/items.lua):
--
-- ['handcuffs'] = { label = 'Handboeien', weight = 100, stack = true, close = true },
-- ['radio']     = { label = 'Portofoon',  weight = 200, stack = false, close = true },
-- ['armor']     = { label = 'Kogelvrij vest', weight = 1000, stack = false, close = true },
--
-- ['ammo-9']       = { label = '9mm munitie', weight = 10, stack = true },
-- ['ammo-shotgun'] = { label = 'Shotgun ammo', weight = 20, stack = true },
-- ['ammo-rifle']   = { label = 'Geweer ammo', weight = 15, stack = true },
-- --------------------------------------------------------------------------
