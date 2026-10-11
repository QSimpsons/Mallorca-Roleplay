local nuiReady = false

CreateThread(function()
    while not ESX.PlayerLoaded do
        Wait(100)

        if NetworkIsPlayerActive(ESX.playerId) then
            ESX.DisableSpawnManager()
            DoScreenFadeOut(0)
            Multicharacter:SetupCharacters()
            break
        end
    end
end)

-- Events

ESX.SecureNetEvent("esx_multicharacter:SetupUI", function(data, slots)
    if not Config.SkipCharacterSelection and not nuiReady then
        print('[WARNING]', 'NUI not ready yet, awaiting...')
        xLib.waitFor(function()
            return nuiReady == true
        end, 'NUI Failed to load after 10000ms', 10000)
    end
    Multicharacter:SetupUI(data, slots)
end)

local function saveCurrentOutfit()
    if not Multicharacter.outfitReady then
        return
    end

    local skin

    if Multicharacter.preferStoredSkin and type(Multicharacter.activeSkin) == "table" then
        skin = Multicharacter.activeSkin
        Multicharacter.preferStoredSkin = false
    else
        local ok, worn = pcall(function()
            return exports["skinchanger"]:GetSkin()
        end)

        if not ok or type(worn) ~= "table" then
            return
        end

        skin = worn
    end

    if skin.tshirt_1 == nil and skin.torso_1 == nil and skin.pants_1 == nil then
        return
    end

    TriggerServerEvent("esx_multicharacter:saveSkin", skin)
end

RegisterNetEvent('esx:playerLoaded', function(playerData, isNew, skin)
    Multicharacter:PlayerLoaded(playerData, isNew, skin)
end)

ESX.SecureNetEvent('esx:onPlayerLogout', function()
    saveCurrentOutfit()
    Multicharacter.outfitReady = false
    DoScreenFadeOut(500)
    Wait(5000)

    Multicharacter.spawned = false

    Multicharacter:SetupCharacters()
    TriggerEvent("esx_skin:resetFirstSpawn")
end)

AddEventHandler("esx_multicharacter:outfitReady", function()
    SetTimeout(500, saveCurrentOutfit)
end)

CreateThread(function()
    while true do
        Wait(45000)
        saveCurrentOutfit()
    end
end)

-- Relog

if Config.Relog then
    RegisterCommand("relog", function()
        if Multicharacter.canRelog then
            Multicharacter.canRelog = false
            saveCurrentOutfit()
            TriggerServerEvent("esx_multicharacter:relog")

            xLib.timeout.setTimeout(10000, function()
                Multicharacter.canRelog = true
            end)
        end
    end, false)
end

RegisterNuiCallback('nuiReady', function(_, cb)
    nuiReady = true
    cb(1)
end)