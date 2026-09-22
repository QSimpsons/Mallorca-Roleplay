-- Eenmalig uitvoeren is niet verplicht: de resource maakt deze tabel zelf aan.
-- Handig als je de tabel liever zelf importeert in HeidiSQL of phpMyAdmin.

CREATE TABLE IF NOT EXISTS `snelle_startcoins` (
    `identifier` VARCHAR(80) NOT NULL,
    `amount` INT NOT NULL,
    `account` VARCHAR(32) NOT NULL,
    `reason` VARCHAR(32) NOT NULL,
    `granted_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
