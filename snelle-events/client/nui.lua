nuiOpen = false

function SetEventNuiFocus(state)
    nuiOpen = state == true
    SetNuiFocus(nuiOpen, nuiOpen)
    SetNuiFocusKeepInput(false)
end

function ForceCloseEventNui()
    nuiOpen = false
    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    SendNUIMessage({ action = 'forceClose' })
end

local function setFocus(state)
    SetEventNuiFocus(state)
end

local function forceCloseNui()
    ForceCloseEventNui()
end

RegisterNetEvent('snelle-events:client:openPanel', function(data)
    SendNUIMessage({ action = 'openPanel', data = data })
    setFocus(true)
    NotifyClient(L('panel_opened'))
end)

RegisterNetEvent('snelle-events:client:panelData', function(data)
    SendNUIMessage({ action = 'panelData', data = data })
end)

RegisterNetEvent('snelle-events:client:onlinePlayers', function(players)
    SendNUIMessage({ action = 'onlinePlayers', players = players })
end)

RegisterNetEvent('snelle-events:client:forceCloseNui', function()
    forceCloseNui()
end)

RegisterNUICallback('close', function(_, cb)
    forceCloseNui()
    cb({ ok = true })
end)

RegisterNUICallback('createEvent', function(data, cb)
    TriggerServerEvent('snelle-events:server:createEvent', data)
    cb({ ok = true })
end)

RegisterNUICallback('startEvent', function(data, cb)
    TriggerServerEvent('snelle-events:server:startEvent', data.eventId)
    cb({ ok = true })
end)

RegisterNUICallback('stopEvent', function(data, cb)
    TriggerServerEvent('snelle-events:server:stopEvent', data.eventId)
    cb({ ok = true })
end)

RegisterNUICallback('announceEvent', function(data, cb)
    TriggerServerEvent('snelle-events:server:announceEvent', data.eventId, data.message)
    cb({ ok = true })
end)

RegisterNUICallback('joinEvent', function(data, cb)
    TriggerServerEvent('snelle-events:server:joinEvent', data.eventId, data.password)
    forceCloseNui()
    cb({ ok = true })
end)

RegisterNUICallback('leaveEvent', function(_, cb)
    TriggerServerEvent('snelle-events:server:leaveEvent')
    cb({ ok = true })
end)

RegisterNUICallback('kickPlayer', function(data, cb)
    TriggerServerEvent('snelle-events:server:kickPlayer', data.eventId, data.targetId)
    cb({ ok = true })
end)

RegisterNUICallback('setWinner', function(data, cb)
    TriggerServerEvent('snelle-events:server:setWinner', data.eventId, data.winnerId)
    cb({ ok = true })
end)

RegisterNUICallback('promoteHost', function(data, cb)
    TriggerServerEvent('snelle-events:server:promoteHost', data.eventId, data.targetId)
    cb({ ok = true })
end)

RegisterNUICallback('invitePlayer', function(data, cb)
    TriggerServerEvent('snelle-events:server:invitePlayer', data.eventId, data.targetId)
    cb({ ok = true })
end)

RegisterNUICallback('acceptInvite', function(_, cb)
    TriggerServerEvent('snelle-events:server:acceptInvite')
    forceCloseNui()
    cb({ ok = true })
end)

RegisterNUICallback('teleportAll', function(data, cb)
    TriggerServerEvent('snelle-events:server:teleportAll', data.eventId)
    cb({ ok = true })
end)

RegisterNUICallback('refreshEvents', function(_, cb)
    TriggerServerEvent('snelle-events:server:requestEvents')
    cb({ ok = true })
end)

RegisterNUICallback('getEventDetail', function(data, cb)
    TriggerServerEvent('snelle-events:server:requestEventDetail', data.eventId)
    cb({ ok = true })
end)

RegisterNUICallback('getOnlinePlayers', function(_, cb)
    TriggerServerEvent('snelle-events:server:getOnlinePlayers')
    cb({ ok = true })
end)

RegisterNUICallback('getCurrentCoords', function(_, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    cb({
        x = coords.x,
        y = coords.y,
        z = coords.z,
        heading = GetEntityHeading(ped)
    })
end)

-- Noodcommando als het panel blijft hangen
RegisterCommand('eventclose', function()
    forceCloseNui()
    NotifyClient(L('panel_closed') or 'Event panel gesloten.')
end, false)

RegisterCommand('eventfix', function()
    forceCloseNui()
    NotifyClient(L('panel_closed') or 'Event panel gesloten.')
end, false)

-- Extra failsafe: Backspace + Escape via game controls wanneer focus vastzit
CreateThread(function()
    while true do
        if nuiOpen then
            -- Disable camera look while menu open
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)

            if IsDisabledControlJustReleased(0, 200) or IsDisabledControlJustReleased(0, 322) then -- ESC / ESC alt
                forceCloseNui()
            end

            Wait(0)
        else
            Wait(400)
        end
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    forceCloseNui()
end)
