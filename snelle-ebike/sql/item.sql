-- ESX items (ox_inventory of esx default)
-- ox_inventory: zet dit in ox_inventory/data/items.lua in plaats van SQL.

INSERT INTO `items` (`name`, `label`, `weight`, `rare`, `can_remove`) VALUES
    ('ebike', 'E-bike', 1, 0, 1)
ON DUPLICATE KEY UPDATE `label` = 'E-bike';
