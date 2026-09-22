ESX = exports["es_extended"]:getSharedObject()

local isWrapperOpen = false
local coins = '0'

local function awaitServer(name, ...)
    local ok, result = pcall(lib.callback.await, name, false, ...)
    if ok then
        return result
    end
    local legacy = name:gsub('^Mallorca%-tebexwrapper:', 'vex-tebexwrapper:', 1)
    if legacy ~= name then
        return lib.callback.await(legacy, false, ...)
    end
    error(result)
end

local Config = awaitServer('Mallorca-tebexwrapper:request:config')

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

local function applyCoinUpdate(amount)
    coins = amount
end

lib.callback.register('Mallorca-tebexwrapper:client:update:coins', applyCoinUpdate)
lib.callback.register('vex-tebexwrapper:client:update:coins', applyCoinUpdate)

local function applyStarterCoins(amount)
    local value = tonumber(amount)
    if value then
        coins = value
    end
end

RegisterNetEvent('Mallorca-tebexwrapper:starter:coins', applyStarterCoins)
RegisterNetEvent('vex-tebexwrapper:starter:coins', applyStarterCoins)

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
        name = awaitServer('Mallorca-tebexwrapper:request:name')
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

    awaitServer('Mallorca-tebexwrapper:process:cart', data)

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

    local result = awaitServer('Mallorca-tebexwrapper:open:crate', data)
    
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

    local result = awaitServer('Mallorca-tebexwrapper:spin:wheel', data)
    
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
        coins = tonumber(awaitServer('Mallorca-tebexwrapper:request:coins')) or '0'
        Wait(100)  
    end
end)