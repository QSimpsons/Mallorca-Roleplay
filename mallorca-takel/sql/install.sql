-- ============================================================
-- Mallorca Takel v2 — SQL
-- Eenmalig uitvoeren in HeidiSQL / phpMyAdmin (ESX Legacy)
-- Gebruikt je bestaande mechanic / Wegenwacht job (rang 1 t/m 6).
-- ============================================================

CREATE TABLE IF NOT EXISTS `mallorca_impound` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `plate` VARCHAR(12) NOT NULL,
    `owner` VARCHAR(64) DEFAULT NULL,
    `props` LONGTEXT NOT NULL,
    `reason` VARCHAR(128) NOT NULL DEFAULT 'Getakeld',
    `officer` VARCHAR(64) DEFAULT NULL,
    `officer_name` VARCHAR(80) DEFAULT NULL,
    `price` INT NOT NULL DEFAULT 1500,
    `model` VARCHAR(64) DEFAULT NULL,
    `impounded_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `plate` (`plate`),
    KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mallorca_takel_calls` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `caller` VARCHAR(64) DEFAULT NULL,
    `caller_name` VARCHAR(80) DEFAULT NULL,
    `pos_x` FLOAT NOT NULL DEFAULT 0,
    `pos_y` FLOAT NOT NULL DEFAULT 0,
    `pos_z` FLOAT NOT NULL DEFAULT 0,
    `message` VARCHAR(180) DEFAULT NULL,
    `kind` VARCHAR(16) NOT NULL DEFAULT 'player',
    `status` VARCHAR(16) NOT NULL DEFAULT 'open',
    `taker` VARCHAR(64) DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
