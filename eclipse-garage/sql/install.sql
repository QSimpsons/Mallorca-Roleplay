-- ═══════════════════════════════════════════════════════════════
-- Eclipse Garage · ESX Legacy · MySQL / MariaDB
-- Eenmalig importeren in HeidiSQL of phpMyAdmin.
-- owned_vehicles moet al bestaan (es_extended).
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `mallorca_impound` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `plate` VARCHAR(12) NOT NULL,
    `owner` VARCHAR(64) DEFAULT NULL,
    `props` LONGTEXT NOT NULL,
    `reason` VARCHAR(128) NOT NULL DEFAULT 'In beslag genomen',
    `officer` VARCHAR(64) DEFAULT NULL,
    `officer_name` VARCHAR(80) DEFAULT NULL,
    `price` INT NOT NULL DEFAULT 1500,
    `model` VARCHAR(64) DEFAULT NULL,
    `impounded_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `plate` (`plate`),
    KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `eclipse_garage_log` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(80) NOT NULL,
    `player_name` VARCHAR(64) DEFAULT NULL,
    `action` VARCHAR(24) NOT NULL,
    `plate` VARCHAR(16) DEFAULT NULL,
    `location` VARCHAR(64) DEFAULT NULL,
    `amount` INT NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_identifier` (`identifier`),
    KEY `idx_plate` (`plate`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Kolommen die oudere ESX-databases soms missen.
-- Fout "duplicate column" negeren als de kolom al bestaat.

ALTER TABLE `owned_vehicles` ADD COLUMN IF NOT EXISTS `stored` TINYINT(1) NOT NULL DEFAULT 1;
ALTER TABLE `owned_vehicles` ADD COLUMN IF NOT EXISTS `parking` VARCHAR(60) DEFAULT NULL;
ALTER TABLE `owned_vehicles` ADD COLUMN IF NOT EXISTS `pound` VARCHAR(60) DEFAULT NULL;
