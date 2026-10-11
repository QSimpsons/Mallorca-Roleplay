local ESX = exports['es_extended']:getSharedObject()

-- Server-side grade check voor spawn (anti-cheat licht).
RegisterNetEvent('eclipse-politie-garage:server:canSpawn', function(vehicleId)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if xPlayer.getJob().name ~= Config.JobName then
        TriggerClientEvent('eclipse-politie-garage:client:spawnDenied', src, 'job')
        return
    end

    local grade = xPlayer.getJob().grade or 0
    local vehicle
    for i = 1, #Config.Vehicles do
        if Config.Vehicles[i].id == vehicleId then
            vehicle = Config.Vehicles[i]
            break
        end
    end

    if not vehicle or grade < (vehicle.minGrade or 0) then
        TriggerClientEvent('eclipse-politie-garage:client:spawnDenied', src, 'grade')
        return
    end

    TriggerClientEvent('eclipse-politie-garage:client:spawnAllowed', src, vehicleId)
end)

if Config.Debug then
    print('[eclipse-politie-garage] server loaded')
end
