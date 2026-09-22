local pendingArrival = false

local function isDowned()
    if GetResourceState('tk_ambulancejob') ~= 'started' then
        return LocalPlayer.state.isDead or LocalPlayer.state.isInLastStand or false
    end

    local dead, inLastStand = false, false

    local okDead, resultDead = pcall(function()
        return exports.tk_ambulancejob:isDead()
    end)
    if okDead then
        dead = resultDead
    end

    local okStand, resultStand = pcall(function()
        return exports.tk_ambulancejob:isInLastStand()
    end)
    if okStand then
        inLastStand = resultStand
    end

    return dead or inLastStand or LocalPlayer.state.isDead or LocalPlayer.state.isInLastStand or false
end

local function hasAllowedJob()
    local playerData = ESX.GetPlayerData()
    if not playerData or not playerData.job then
        return false
    end

    for _, job in pairs(Config.AllowedJobs) do
        if playerData.job.name == job then
            return true
        end
    end

    return false
end

local function finishArrival(coords)
    local ped = PlayerPedId()
    local deadline = GetGameTimer() + 5000

    while (LocalPlayer.state.isDead or LocalPlayer.state.isInLastStand) and GetGameTimer() < deadline do
        Wait(50)
    end

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, 0.0, true, false)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    ClearPedTasksImmediately(ped)
    ClearPedBloodDamage(ped)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    RemoveAllPedWeapons(ped, true)

    Wait(500)
    DoScreenFadeIn(500)

    lib.notify({
        title = 'Overheids Newlife',
        description = 'Je bent succesvol Gerevived!',
        type = 'success'
    })

    if Config.weapondelay then
        lib.notify({
            title = 'Overheids Newlife',
            icon = 'gun',
            description = 'Je kan nog '..Config.weapondelaycooldown..' minuten je wapens NIET meer pakken.',
            type = 'inform'
        })
        LocalPlayer.state.invHotkeys = false
        Wait(Config.weapondelaycooldown * 60 * 1000)
        LocalPlayer.state.invHotkeys = true
        lib.notify({
            title = 'Overheids Newlife',
            description = 'Je kan je wapens weer pakken.',
            type = 'success'
        })
    end
end

RegisterCommand("overheidnewlife", function()
    lib.callback('prp-newlife:args', false, function(response)
        if not response.allowed then
            lib.notify({
                title = 'Overheids Newlife',
                description = response.reason,
                type = 'error'
            })
            return
        end

        if not isDowned() then
            lib.notify({
                title = 'Overheids Newlife',
                description = 'Je moet dood zijn om dit menu te openen.',
                type = 'error'
            })
            return
        end

        local options = {}

        for key, data in pairs(Config.NewLifeSpawns) do
            options[#options + 1] = {
                title = data.label,
                description = data.description,
                icon = data.icon,
                onSelect = function()
                    TriggerServerEvent("prp-newlife:spawn", key)
                end
            }
        end

        lib.registerContext({
            id = "newlife_menu",
            title = "Newlife Menu",
            options = options
        })

        lib.showContext('newlife_menu')
    end)
end)

RegisterNetEvent('prp-newlife:client:teleport', function(coords)
    if not hasAllowedJob() then
        return
    end

    lib.notify({
        title = 'Overheids Newlife',
        description = 'Je wordt over '..Config.TeleportDelay..' minuten geteleporteerd',
        type = 'inform'
    })

    Wait(Config.TeleportDelay * 60 * 1000)

    DoScreenFadeOut(500)
    Wait(1000)

    pendingArrival = true
    TriggerServerEvent('prp-newlife:complete')

    local started = GetGameTimer()
    while pendingArrival and (GetGameTimer() - started) < 8000 do
        Wait(50)
    end

    if not pendingArrival then
        return
    end

    pendingArrival = false
    finishArrival(coords)
end)

RegisterNetEvent('prp-newlife:client:arrive', function(coords)
    if not pendingArrival then
        return
    end

    pendingArrival = false
    finishArrival(coords)
end)
