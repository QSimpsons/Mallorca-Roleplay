RegisterNetEvent('snelle-events:client:openPanel', function(data)
    SendNUIMessage({
        action = 'openPanel',
        data = data
    })
    SetNuiFocus(true, true)
    NotifyClient(L('panel_opened'))
end)

RegisterNetEvent('snelle-events:client:panelData', function(data)
    SendNUIMessage({
        action = 'panelData',
        data = data
    })
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('createEvent', function(data, cb)
    TriggerServerEvent('snelle-events:server:createEvent', data)
    cb('ok')
end)

RegisterNUICallback('startEvent', function(data, cb)
    TriggerServerEvent('snelle-events:server:startEvent', data.eventId)
    cb('ok')
end)

RegisterNUICallback('stopEvent', function(data, cb)
    TriggerServerEvent('snelle-events:server:stopEvent', data.eventId)
    cb('ok')
end)

RegisterNUICallback('announceEvent', function(data, cb)
    TriggerServerEvent('snelle-events:server:announceEvent', data.eventId, data.message)
    cb('ok')
end)

RegisterNUICallback('joinEvent', function(data, cb)
    TriggerServerEvent('snelle-events:server:joinEvent', data.eventId)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('leaveEvent', function(_, cb)
    TriggerServerEvent('snelle-events:server:leaveEvent')
    cb('ok')
end)

RegisterNUICallback('setWinner', function(data, cb)
    TriggerServerEvent('snelle-events:server:setWinner', data.eventId, data.winnerId)
    cb('ok')
end)

RegisterNUICallback('refreshEvents', function(_, cb)
    TriggerServerEvent('snelle-events:server:requestEvents')
    cb('ok')
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
