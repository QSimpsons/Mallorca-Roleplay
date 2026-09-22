local active     = false
local areaLock   = false
local doingTask  = false

local visibleTasks = {}
local broomProp    = nil

local AREA_RADIUS = 120.0
local CLEAN_TIME  = 5000

local ignoreAreaUntil = 0




RegisterNetEvent('fx-taakstraf:start', function(data)
    local ped = PlayerPedId()

    active    = true
    areaLock  = true
    doingTask = false

    SetEntityCoords(ped, Config.StartTeleport.xyz)
    SetEntityHeading(ped, Config.StartTeleport.w)

    giveBroom()
    refreshTasks()

    SendNUIMessage({
        action = "open",
        left   = data.left,
        by     = data.by,
        reason = data.reason
    })
end)




RegisterNetEvent('fx-taakstraf:update', function(left)
    SendNUIMessage({ action = "update", left = left })
    refreshTasks()
end)




RegisterNetEvent('fx-taakstraf:finish', function()
    local ped = PlayerPedId()

    active    = false
    areaLock  = false
    doingTask = false
    ignoreAreaUntil = GetGameTimer() + 3000

    removeBroom()
    SendNUIMessage({ action = "close" })

    Wait(300)

    SetEntityInvincible(ped, false)
    SetEntityCoords(ped, Config.EndTeleport.xyz)
    SetEntityHeading(ped, Config.EndTeleport.w)
end)




RegisterNetEvent('fx-taakstraf:stop', function()
    local ped = PlayerPedId()

    active    = false
    areaLock  = false
    doingTask = false
    ignoreAreaUntil = GetGameTimer() + 5000

    removeBroom()
    SendNUIMessage({ action = "close" })
    ClearPedTasksImmediately(ped)

    SetEntityInvincible(ped, false)
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)

    Wait(500)

    SetEntityCoords(ped, Config.EndTeleport.xyz)
    SetEntityHeading(ped, Config.EndTeleport.w)
end)




RegisterNetEvent('fx-taakstraf:forceTP', function()
    if not active then return end
    local ped = PlayerPedId()
    SetEntityCoords(ped, Config.StartTeleport.xyz)
    SetEntityHeading(ped, Config.StartTeleport.w)
    TriggerEvent('ox_lib:notify', {
        title       = 'Taakstraf',
        description = 'Blijf in het taakstraf gebied!',
        type        = 'error'
    })
end)



RegisterNetEvent("fx-taakstraf:triggerDoneTask", function()
    TriggerServerEvent("fx-taakstraf:shopRemoveTask")
end)



-- PH_R_Hand. De veeganimatie is op dit bot gebouwd, zodat de steel
-- in beide handen valt en de borstelkop naar de grond wijst.
local BROOM_BONE   = 28422
local BROOM_OFFSET = vector3(-0.005, 0.0, 0.0)
local BROOM_ROT    = vector3(360.0, 360.0, 0.0)

function attachBroom()
    if not broomProp or not DoesEntityExist(broomProp) then return end

    local ped = PlayerPedId()
    AttachEntityToEntity(
        broomProp, ped,
        GetPedBoneIndex(ped, BROOM_BONE),
        BROOM_OFFSET.x, BROOM_OFFSET.y, BROOM_OFFSET.z,
        BROOM_ROT.x, BROOM_ROT.y, BROOM_ROT.z,
        true, true, false, true, 1, true
    )
end

function giveBroom()
    removeBroom()

    local ped   = PlayerPedId()
    local model = `prop_tool_broom`

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local coords = GetEntityCoords(ped)
    broomProp = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    SetEntityAsMissionEntity(broomProp, true, true)
    SetEntityCollision(broomProp, false, false)

    if NetworkGetEntityIsNetworked(broomProp) then
        local netId = NetworkGetNetworkIdFromEntity(broomProp)
        SetNetworkIdCanMigrate(netId, false)
        SetNetworkIdExistsOnAllMachines(netId, true)
    end

    attachBroom()
    SetModelAsNoLongerNeeded(model)
end

function removeBroom()
    if broomProp and DoesEntityExist(broomProp) then
        DeleteEntity(broomProp)
        broomProp = nil
    end
end




function refreshTasks()
    visibleTasks = {}
    while #visibleTasks < Config.MaxVisibleTasks do
        visibleTasks[#visibleTasks + 1] =
            Config.TaskLocations[math.random(#Config.TaskLocations)]
    end
end



function doCleanTask()
    local ped = PlayerPedId()
    doingTask = true

    SendNUIMessage({ action = "forceProgress", time = CLEAN_TIME })

    RequestAnimDict("amb@world_human_janitor@male@idle_a")
    while not HasAnimDictLoaded("amb@world_human_janitor@male@idle_a") do Wait(10) end

    TaskPlayAnim(
        ped,
        "amb@world_human_janitor@male@idle_a",
        "idle_a",
        8.0, -8.0,
        CLEAN_TIME,
        1, 0,
        false, false, false
    )

    -- Opnieuw vastzetten zodra de veegpose staat, anders blijft de steel langs de arm hangen.
    Wait(100)
    attachBroom()

    Wait(CLEAN_TIME - 100)

    ClearPedTasks(ped)
    SendNUIMessage({ action = "forceProgressEnd" })

    doingTask = false
    TriggerServerEvent("fx-taakstraf:doneTask")
end


CreateThread(function()
    while true do
        if not active then
            Wait(750)
        else
            Wait(0)

            local ped    = PlayerPedId()
            local coords = GetEntityCoords(ped)

            if areaLock
                and GetGameTimer() > ignoreAreaUntil
                and #(coords - Config.StartTeleport.xyz) > AREA_RADIUS then

                SetEntityCoords(ped, Config.StartTeleport.xyz)
                SetEntityHeading(ped, Config.StartTeleport.w)
            end

            if areaLock then
                DisablePlayerFiring(PlayerId(), true)
                SetEntityInvincible(ped, true)

                -- Elke frame het wapen forceren rukt de borstel uit de hand.
                if not doingTask and GetSelectedPedWeapon(ped) ~= `WEAPON_UNARMED` then
                    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                end
            end

            for i, v in ipairs(visibleTasks) do
                DrawMarker(
                    2,
                    v.x, v.y, v.z + 0.3,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.45, 0.45, 0.45,
                    0, 120, 255, 200,
                    false, true, 2, false
                )

                if not doingTask and #(coords - v.xyz) < Config.InteractDistance then
                    BeginTextCommandDisplayHelp("STRING")
                    AddTextComponentSubstringPlayerName("Druk ~INPUT_CONTEXT~ om schoon te maken")
                    EndTextCommandDisplayHelp(0, false, true, -1)

                    if IsControlJustPressed(0, 38) then
                        table.remove(visibleTasks, i)
                        doCleanTask()
                        break
                    end
                end
            end
        end
    end
end)



AddEventHandler("gameEventTriggered", function(name)
    if areaLock and name == "CEventNetworkEntityDamage" then
        CancelEvent()
    end
end)


CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/taakstraf', 'Geef een speler taakstraf', {
        { name = 'id',         help = 'Speler ID' },
        { name = 'hoeveelheid', help = 'Aantal taken' },
        { name = 'reden',      help = 'Reden van taakstraf' }
    })
end)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/stoptaakstraf', 'Stop een speler zijn taakstraf', {
        { name = 'id', help = 'Speler ID' }
    })
end)
