-- ═══════════════════════════════════════════════════════════════
-- Snelle Events · ESX Legacy · MySQL / MariaDB
-- Importeer dit bestand in je database (phpMyAdmin / HeidiSQL / mysql CLI)
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `snelle_events` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `event_id` VARCHAR(64) NOT NULL,
    `name` VARCHAR(128) NOT NULL,
    `type` VARCHAR(32) NOT NULL DEFAULT 'custom',
    `host_identifier` VARCHAR(80) DEFAULT NULL,
    `host_name` VARCHAR(64) DEFAULT NULL,
    `status` VARCHAR(32) NOT NULL DEFAULT 'ended',
    `max_players` INT NOT NULL DEFAULT 32,
    `player_count` INT NOT NULL DEFAULT 0,
    `coords_x` FLOAT DEFAULT NULL,
    `coords_y` FLOAT DEFAULT NULL,
    `coords_z` FLOAT DEFAULT NULL,
    `winner_identifier` VARCHAR(80) DEFAULT NULL,
    `winner_name` VARCHAR(64) DEFAULT NULL,
    `started_at` TIMESTAMP NULL DEFAULT NULL,
    `ended_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_event_id` (`event_id`),
    KEY `idx_type` (`type`),
    KEY `idx_ended_at` (`ended_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `snelle_event_players` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `event_db_id` INT NOT NULL,
    `event_id` VARCHAR(64) NOT NULL,
    `identifier` VARCHAR(80) NOT NULL,
    `player_name` VARCHAR(64) DEFAULT NULL,
    `kills` INT NOT NULL DEFAULT 0,
    `deaths` INT NOT NULL DEFAULT 0,
    `eliminated` TINYINT(1) NOT NULL DEFAULT 0,
    `is_winner` TINYINT(1) NOT NULL DEFAULT 0,
    `role` VARCHAR(32) DEFAULT NULL,
    `reward_money` INT NOT NULL DEFAULT 0,
    `joined_at` TIMESTAMP NULL DEFAULT NULL,
    `left_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_event_db_id` (`event_db_id`),
    KEY `idx_event_id` (`event_id`),
    KEY `idx_identifier` (`identifier`),
    CONSTRAINT `fk_snelle_event_players_event`
        FOREIGN KEY (`event_db_id`) REFERENCES `snelle_events` (`id`)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `snelle_event_stats` (
    `id` INT NOT NULL AUTO_INCREMENT,
    `identifier` VARCHAR(80) NOT NULL,
    `player_name` VARCHAR(64) DEFAULT NULL,
    `events_joined` INT NOT NULL DEFAULT 0,
    `events_won` INT NOT NULL DEFAULT 0,
    `total_kills` INT NOT NULL DEFAULT 0,
    `total_deaths` INT NOT NULL DEFAULT 0,
    `total_reward` INT NOT NULL DEFAULT 0,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uniq_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
