-- PvP zone enforcement & derby elimination helper

local lastAttacker = nil

CreateThread(function()
    while true do
        local sleep = 1000

        if currentEvent and currentEvent.status == 'active' then
            sleep = 250
            local ped = PlayerPedId()

            if currentEvent.settings.pvpEnabled then
                SetEntityCanBeDamaged(ped, true)
                NetworkSetFriendlyFireOption(true)
            else
                SetEntityCanBeDamaged(ped, false)
                NetworkSetFriendlyFireOption(false)
            end

            if currentEvent.type == 'derby' and IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                if GetEntityHealth(vehicle) <= 0 or IsEntityInWater(vehicle) then
                    TriggerServerEvent('snelle-events:server:leaveEvent')
                    NotifyClient(L('left_event', currentEvent.name))
                end
            end
        end

        Wait(sleep)
    end
end)

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then return end
    if not currentEvent or not currentEvent.settings.pvpEnabled then return end

    local victim = args[1]
    local attacker = args[2]

    if victim == PlayerPedId() and attacker ~= 0 then
        lastAttacker = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
    end
end)
