-- Annis Minor voor ESX (esx_vehicleshop)
-- Importeer dit bestand één keer in dezelfde database als je ESX-server.
-- HeidiSQL, phpMyAdmin of de database-tab in txAdmin kan dit bestand uitvoeren.
-- Opnieuw importeren vervangt alleen deze twee auto's.

INSERT IGNORE INTO `vehicle_categories` (`name`, `label`) VALUES
    ('compacts', 'Compacts'),
    ('sports', 'Sports');

DELETE FROM `vehicles` WHERE `model` IN ('aminor', 'aminorv6');

INSERT INTO `vehicles` (`name`, `model`, `price`, `category`) VALUES
    ('Annis Minor', 'aminor', 24500, 'compacts'),
    ('Annis Minor V6', 'aminorv6', 41000, 'sports');
