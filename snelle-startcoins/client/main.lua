local function feed(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

local function show(message)
    if GetResourceState('ox_lib') == 'started' then
        local ok = pcall(function()
            TriggerEvent('ox_lib:notify', {
                title = 'Startcoins',
                description = message,
                type = 'success',
                duration = 8000
            })
        end)
        if ok then
            return
        end
    end
    feed(message)
end

RegisterNetEvent('snelle-startcoins:notify', function(message)
    if type(message) ~= 'string' or message == '' then
        return
    end
    show(message)
end)
