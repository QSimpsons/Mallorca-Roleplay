-- tk_ambulancejob (ESX)
-- Database: esxlegacy_bcde98
-- Importeer dit bestand volledig in HeidiSQL of phpMyAdmin.

USE `esxlegacy_bcde98`;

CREATE TABLE IF NOT EXISTS `tk_ambulancejob_injuries` (
  `identifier` VARCHAR(50) NOT NULL,
  `body_part` VARCHAR(10) NOT NULL,
  `id` VARCHAR(50) NOT NULL,
  `type` VARCHAR(20) NOT NULL,
  `cause` VARCHAR(50) NULL,
  `damage` INT NOT NULL,
  `timestamp` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `body_part` (`body_part`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tk_ambulancejob_bullets` (
  `identifier` VARCHAR(50) NOT NULL,
  `body_part` VARCHAR(10) NOT NULL,
  `id` VARCHAR(50) NOT NULL,
  `caliber` VARCHAR(10) NOT NULL,
  `entry_angle` INT NOT NULL,
  `damage` INT NOT NULL,
  `timestamp` BIGINT NOT NULL,
  PRIMARY KEY (`id`),
  KEY `identifier` (`identifier`),
  KEY `body_part` (`body_part`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tk_ambulancejob_vehicles` (
  `owner` VARCHAR(50) NOT NULL,
  `plate` VARCHAR(8) NOT NULL,
  `props` LONGTEXT NOT NULL,
  UNIQUE KEY `plate` (`plate`),
  KEY `owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `tk_ambulancejob_outfits` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(50) NOT NULL,
  `data` LONGTEXT NOT NULL,
  `gender` VARCHAR(10) NOT NULL,
  `hospital` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `hospital` (`hospital`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ESX: death state op de users-tabel. Slaat over als de kolom al bestaat.
SET @db_name = DATABASE();
SET @column_exists = (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = @db_name
    AND TABLE_NAME = 'users'
    AND COLUMN_NAME = 'isDead'
);
SET @add_is_dead = IF(
  @column_exists = 0,
  'ALTER TABLE `users` ADD COLUMN `isDead` TINYINT(1) NOT NULL DEFAULT 0',
  'SELECT 1'
);
PREPARE add_is_dead_stmt FROM @add_is_dead;
EXECUTE add_is_dead_stmt;
DEALLOCATE PREPARE add_is_dead_stmt;
