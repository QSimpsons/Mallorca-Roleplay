--[[ Eclipse Roleplay HUD - server ]]

-- Server ID is already available client-side via GetPlayerServerId.
-- This file exposes a small helper for other resources.

RegisterNetEvent('eclipse-hud:server:requestSync', function()
    local src = source
    TriggerClientEvent('eclipse-hud:client:setVisible', src, true)
end)

exports('SetPlayerHudVisible', function(src, state)
    TriggerClientEvent('eclipse-hud:client:setVisible', src, state and true or false)
end)

exports('UpdatePlayerNeeds', function(src, hunger, thirst)
    TriggerClientEvent('eclipse-hud:client:updateNeeds', src, hunger, thirst)
end)
