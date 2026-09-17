-- Markers, zone enforcement, race finish, PvP kills, derby elimination

local function drawMarkerAt(coords)
    local cfg = Config.Markers
    DrawMarker(
        cfg.type,
        coords.x, coords.y, coords.z - 1.0,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        cfg.scale.x, cfg.scale.y, cfg.scale.z,
        cfg.color.r, cfg.color.g, cfg.color.b, cfg.color.a,
        cfg.bobUpAndDown, false, 2, false, nil, nil, false
    )
end

-- Join markers for waiting events
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local myCoords = GetEntityCoords(ped)

        if Config.Markers.enabled and syncedEvents and not currentEvent then
            for _, event in ipairs(syncedEvents) do
                if event.status == 'waiting' and event.coords then
                    local dist = #(myCoords - vector3(event.coords.x, event.coords.y, event.coords.z))
                    if dist < 40.0 then
                        sleep = 0
                        drawMarkerAt(event.coords)

                        if dist < (Config.MarkerJoinDistance or 2.5) then
                            BeginTextCommandDisplayHelp('STRING')
                            AddTextComponentSubstringPlayerName(L('press_to_join'))
                            EndTextCommandDisplayHelp(0, false, true, -1)

                            if IsControlJustReleased(0, 38) then -- E
                                if event.hasPassword then
                                    SendNUIMessage({ action = 'askPassword', eventId = event.id, eventName = event.name })
                                    SetNuiFocus(true, true)
                                else
                                    TriggerServerEvent('snelle-events:server:joinEvent', event.id)
                                end
                            end
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Active event gameplay loops
CreateThread(function()
    while true do
        local sleep = 1000

        if currentEvent and currentEvent.status == 'active' then
            sleep = 200
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)

            -- PvP friendly fire
            if currentEvent.settings and currentEvent.settings.pvpEnabled then
                SetEntityCanBeDamaged(ped, true)
                NetworkSetFriendlyFireOption(true)
            else
                SetEntityCanBeDamaged(ped, false)
                NetworkSetFriendlyFireOption(false)
            end

            -- Zone enforcement
            if currentEvent.enforceZone and currentEvent.coords and currentEvent.zoneRadius then
                local center = vector3(currentEvent.coords.x, currentEvent.coords.y, currentEvent.coords.z)
                local dist = #(coords - center)

                -- Draw zone circle hint
                DrawMarker(1, center.x, center.y, center.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    currentEvent.zoneRadius * 2.0, currentEvent.zoneRadius * 2.0, 1.0,
                    239, 68, 68, 40, false, false, 2, false, nil, nil, false)

                if dist > currentEvent.zoneRadius then
                    NotifyClient(L('out_of_bounds'))
                    outOfBoundsTimer = (outOfBoundsTimer or 0) + 0.2
                    if outOfBoundsTimer >= (Config.OutOfBoundsWarnSeconds or 5) then
                        TriggerServerEvent('snelle-events:server:eliminateSelf', L('out_of_bounds_eliminated'))
                        outOfBoundsTimer = 0
                    end
                else
                    outOfBoundsTimer = 0
                end
            end

            -- Race finish
            if currentEvent.type == 'race' and currentEvent.finishCoords and not raceFinished then
                local finish = vector3(currentEvent.finishCoords.x, currentEvent.finishCoords.y, currentEvent.finishCoords.z)
                local finishDist = currentEvent.settings and currentEvent.settings.finishDistance or 8.0

                DrawMarker(4, finish.x, finish.y, finish.z + 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    3.0, 3.0, 3.0, 34, 197, 94, 180, false, true, 2, false, nil, nil, false)

                if #(coords - finish) < finishDist then
                    raceFinished = true
                    NotifyClient(L('race_finish'))
                    TriggerServerEvent('snelle-events:server:raceFinish')
                end
            end

            -- Derby elimination
            if currentEvent.type == 'derby' and IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                if GetEntityHealth(vehicle) <= 0 or IsEntityInWater(vehicle) then
                    TriggerServerEvent('snelle-events:server:eliminateSelf', 'voertuig vernietigd')
                    Wait(2000)
                end
            end
        else
            outOfBoundsTimer = 0
        end

        Wait(sleep)
    end
end)

-- Kill detection for PvP / deathmatch / hunt
AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then return end
    if not currentEvent or not currentEvent.settings or not currentEvent.settings.pvpEnabled then return end
    if currentEvent.status ~= 'active' then return end

    local victim = args[1]
    local attacker = args[2]
    local isFatal = args[6] == 1

    if victim ~= PlayerPedId() then return end
    if not isFatal and GetEntityHealth(victim) > 0 then return end

    local killerServerId = 0
    if attacker and attacker ~= 0 and IsPedAPlayer(attacker) then
        killerServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(attacker))
    end

    TriggerServerEvent('snelle-events:server:playerKilled', killerServerId)
end)
