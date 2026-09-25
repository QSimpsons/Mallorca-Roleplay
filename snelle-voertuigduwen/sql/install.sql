-- ═══════════════════════════════════════════════════════════════
-- Snelle Voertuigduwen · ESX Legacy · MySQL / MariaDB
-- Importeer dit bestand één keer in je database
-- (phpMyAdmin, HeidiSQL of de mysql-cli) vóór je de resource start.
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `snelle_voertuig_duwen` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(80) NOT NULL,
    `player_name` VARCHAR(64) DEFAULT NULL,
    `mode` VARCHAR(16) NOT NULL,
    `result` VARCHAR(32) NOT NULL,
    `plate` VARCHAR(16) DEFAULT NULL,
    `model` VARCHAR(32) DEFAULT NULL,
    `pos_x` FLOAT DEFAULT NULL,
    `pos_y` FLOAT DEFAULT NULL,
    `pos_z` FLOAT DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_identifier` (`identifier`),
    KEY `idx_plate` (`plate`),
    KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `snelle_voertuig_duwen_stats` (
    `identifier` VARCHAR(80) NOT NULL,
    `player_name` VARCHAR(64) DEFAULT NULL,
    `pushes` INT NOT NULL DEFAULT 0,
    `aside_count` INT NOT NULL DEFAULT 0,
    `manual_count` INT NOT NULL DEFAULT 0,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
