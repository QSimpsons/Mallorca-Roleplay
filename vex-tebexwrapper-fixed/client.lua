ESX = exports["es_extended"]:getSharedObject()

local isWrapperOpen = false
local coins = '0'

local Config = lib.callback.await('vex-tebexwrapper:request:config', false)

function getPlayerMugshot()
    local playerPed = PlayerPedId()
    local mugshotHandle = RegisterPedheadshot(playerPed)
    
    while not IsPedheadshotReady(mugshotHandle) or not IsPedheadshotValid(mugshotHandle) do
        Wait(100)
    end
    
    local mugshotURL = GetPedheadshotTxdString(mugshotHandle)
    UnregisterPedheadshot(mugshotHandle)
    
    return mugshotURL
end

lib.callback.register('vex-tebexwrapper:client:update:coins', function(amount)
    coins = amount
end)

RegisterNetEvent('vex-tebexwrapper:starter:coins', function(amount)
    local value = tonumber(amount)
    if value then
        coins = value
    end
end)

RegisterCommand('store', function()
    local avatarURL = getPlayerMugshot() 
    SetNuiFocus(true, true)
    if coins == 0 then 
       coins = '0'
    end
    
    SendNUIMessage({ 
        action = "open", 
        coins = tonumber(coins) or 0, 
        avatar = avatarURL,
        storeData = Config.StoreData,
        discountCodes = Config.DiscountCodes,
        name = lib.callback.await('vex-tebexwrapper:request:name', false)
    }) 
    
    isWrapperOpen = true
end)

RegisterNUICallback("close", function()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    isWrapperOpen = false
end)

RegisterNUICallback("checkoutCart", function(data, cb)
    if coins == '0' then 
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "close" })
        isWrapperOpen = false

        ESX.ShowNotification('Je hebt niet genoeg coins!', 'error') 
        return 
    end
    
    if data.total > coins then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "close" })
        isWrapperOpen = false

        ESX.ShowNotification('Je hebt niet genoeg coins!', 'error') 
        return
    end

    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    isWrapperOpen = false

    lib.callback.await('vex-tebexwrapper:process:cart', false, data)

    if coins == 0 then 
        coins = '0'
    end
    cb('success')
end)

RegisterNUICallback("testDriveVehicle", function(data, cb)
    exports['tebex_testrit']:testDriveVehicle(data.productSpawn, data.productName)
    
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    isWrapperOpen = false

    cb('success')
end)

RegisterNUICallback("openCrate", function(data, cb)
    if coins == '0' then 
        ESX.ShowNotification('Je hebt niet genoeg coins!', 'error') 
        cb({success = false, message = 'Not enough coins'})
        return 
    end
    
    if data.price > coins then
        ESX.ShowNotification('Je hebt niet genoeg coins!', 'error') 
        cb({success = false, message = 'Not enough coins'})
        return
    end

    local result = lib.callback.await('vex-tebexwrapper:open:crate', false, data)
    
    if result.success then
        coins = coins - data.price
        if coins <= 0 then 
            coins = '0'
        end
    end
    
    cb(result)
end)

RegisterNUICallback("spinWheel", function(data, cb)
    if coins == '0' then 
        ESX.ShowNotification('Je hebt niet genoeg coins!', 'error') 
        cb({success = false, message = 'Not enough coins'})
        return 
    end
    
    if data.price > coins then
        ESX.ShowNotification('Je hebt niet genoeg coins!', 'error') 
        cb({success = false, message = 'Not enough coins'})
        return
    end

    local result = lib.callback.await('vex-tebexwrapper:spin:wheel', false, data)
    
    if result.success then
        coins = coins - data.price
        if coins <= 0 then 
            coins = '0'
        end
    end
    
    cb(result)
end)

Citizen.CreateThread(function()
    while coins == '0' do
        coins = tonumber(lib.callback.await('vex-tebexwrapper:request:coins', false)) or '0'
        Wait(100)  
    end
end)