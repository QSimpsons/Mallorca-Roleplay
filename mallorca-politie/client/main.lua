local ESX = exports['es_extended']:getSharedObject()

PlayerData = {}
IsHandcuffed = false
IsEscorted = false
DragStatus = { isDragged = false, copId = -1 }

local function _(key, ...)
    local str = (Locales[Config.Locale] and Locales[Config.Locale][key]) or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

function Notify(msg, nType)
    nType = nType or 'inform'
    if Config.UseOxLibNotify and lib and lib.notify then
        lib.notify({ description = msg, type = nType })
    else
        ESX.ShowNotification(msg)
    end
end

function IsPoliceJob()
    if not PlayerData.job then return false end
    local name = PlayerData.job.name
    return name == Config.JobName or name == Config.OffJobName
end

function IsOnDuty()
    return PlayerData.job and PlayerData.job.name == Config.JobName
end

function GetGrade()
    return (PlayerData.job and PlayerData.job.grade) or 0
end

function HasMinGrade(action)
    local needed = Config.MinGrade[action] or 0
    return GetGrade() >= needed
end

function GetClosestPlayer(maxDist)
    maxDist = maxDist or 2.5
    local players = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), maxDist)
    local closest, closestDist = -1, maxDist + 0.01
    local myId = PlayerId()

    for i = 1, #players do
        local ply = players[i]
        if ply ~= myId then
            local ped = GetPlayerPed(ply)
            local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(ped))
            if dist < closestDist then
                closest = GetPlayerServerId(ply)
                closestDist = dist
            end
        end
    end

    if closest == -1 then
        return nil
    end
    return closest
end

local function createBlip()
    if not Config.Blip.enabled then return end
    local c = Config.Blip.coords
    local blip = AddBlipForCoord(c.x, c.y, c.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipColour(blip, Config.Blip.colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(Config.Blip.label)
    EndTextCommandSetBlipName(blip)
end

local function drawMarker(coords)
    local m = Config.Markers
    DrawMarker(
        m.type, coords.x, coords.y, coords.z - 1.0,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        m.size.x, m.size.y, m.size.z,
        m.colour.r, m.colour.g, m.colour.b, m.colour.a,
        m.bob, m.face, 2, false, nil, nil, false
    )
end

local function openDutyMenu()
    if not IsPoliceJob() then
        Notify(_('not_police'), 'error')
        return
    end
    TriggerServerEvent('mallorca-politie:server:toggleDuty')
end

local function openBossMenu()
    if not IsOnDuty() then
        Notify(_('not_on_duty'), 'error')
        return
    end
    if not HasMinGrade('boss') then
        Notify(_('no_permission'), 'error')
        return
    end

    if GetResourceState('esx_society') == 'started' then
        TriggerEvent('esx_society:openBossMenu', Config.JobName, function(_, menu)
            if menu then menu.close() end
        end, { wash = false })
    else
        lib.registerContext({
            id = 'politie_boss',
            title = _('boss_menu'),
            options = {
                {
                    title = 'Maatschappij saldo opvragen',
                    onSelect = function()
                        TriggerServerEvent('mallorca-politie:server:getSocietyMoney')
                    end,
                },
            },
        })
        lib.showContext('politie_boss')
    end
end

CreateThread(function()
    while not ESX.PlayerLoaded do Wait(100) end
    PlayerData = ESX.GetPlayerData()
    createBlip()
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('mallorca-politie:client:notify', function(msg, nType)
    Notify(msg, nType)
end)

-- Interactiepunten
CreateThread(function()
    while true do
        local sleep = 1000
        if IsPoliceJob() then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local drawDist = Config.Markers.drawDistance
            local interact = Config.Markers.interactDistance

            local points = {
                { list = Config.Locations.duty, action = openDutyMenu, needDuty = false },
                { list = Config.Locations.cloakroom, action = OpenCloakroom, needDuty = true },
                { list = Config.Locations.armory, action = OpenArmory, needDuty = true },
                { list = Config.Locations.boss, action = openBossMenu, needDuty = true },
                { list = Config.Locations.garage, action = function(loc) OpenGarage(loc, 'cars') end, needDuty = true },
                { list = Config.Locations.heli, action = function(loc) OpenGarage(loc, 'helis') end, needDuty = true },
            }

            for i = 1, #points do
                local group = points[i]
                for j = 1, #(group.list or {}) do
                    local loc = group.list[j]
                    local dist = #(coords - loc.coords)
                    if dist < drawDist then
                        sleep = 0
                        drawMarker(loc.coords)
                        if dist < interact then
                            ESX.ShowHelpNotification(('~INPUT_CONTEXT~ %s'):format(loc.label or 'Openen'))
                            if IsControlJustReleased(0, 38) then -- E
                                if group.needDuty and not IsOnDuty() then
                                    Notify(_('not_on_duty'), 'error')
                                elseif loc.minGrade and GetGrade() < loc.minGrade then
                                    Notify(_('no_permission'), 'error')
                                else
                                    group.action(loc)
                                end
                            end
                        end
                    end

                    if loc.deleteCoords then
                        local dDist = #(coords - loc.deleteCoords)
                        if dDist < drawDist then
                            sleep = 0
                            drawMarker(loc.deleteCoords)
                            if dDist < interact and IsPedInAnyVehicle(ped, false) then
                                ESX.ShowHelpNotification('~INPUT_CONTEXT~ Voertuig wegzetten')
                                if IsControlJustReleased(0, 38) then
                                    StoreCurrentVehicle()
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

-- Handcuff restricties
CreateThread(function()
    while true do
        local sleep = 500
        if IsHandcuffed then
            sleep = 0
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 47, true)
            DisableControlAction(0, 58, true)
            DisableControlAction(0, 263, true)
            DisableControlAction(0, 264, true)
            DisableControlAction(0, 257, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
            DisableControlAction(0, 143, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(27, 75, true)
            DisableControlAction(0, 22, true)
            DisableControlAction(0, 21, true)
            if not IsEntityPlayingAnim(PlayerPedId(), 'mp_arresting', 'idle', 3) then
                RequestAnimDict('mp_arresting')
                while not HasAnimDictLoaded('mp_arresting') do Wait(10) end
                TaskPlayAnim(PlayerPedId(), 'mp_arresting', 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)
            end
        end
        Wait(sleep)
    end
end)

-- Escort sync
CreateThread(function()
    while true do
        Wait(0)
        if DragStatus.isDragged then
            local copPed = GetPlayerPed(GetPlayerFromServerId(DragStatus.copId))
            if DoesEntityExist(copPed) and not IsPedDeadOrDying(copPed, true) then
                AttachEntityToEntity(
                    PlayerPedId(), copPed, 11816,
                    0.54, 0.54, 0.0, 0.0, 0.0, 0.0,
                    false, false, false, false, 2, true
                )
            else
                DragStatus.isDragged = false
                DetachEntity(PlayerPedId(), true, false)
            end
        else
            Wait(500)
        end
    end
end)

RegisterNetEvent('mallorca-politie:client:setHandcuff', function(state)
    IsHandcuffed = state == true
    local ped = PlayerPedId()
    if IsHandcuffed then
        RequestAnimDict('mp_arresting')
        while not HasAnimDictLoaded('mp_arresting') do Wait(10) end
        TaskPlayAnim(ped, 'mp_arresting', 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)
        SetEnableHandcuffs(ped, true)
        DisablePlayerFiring(ped, true)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        SetPedCanPlayGestureAnims(ped, false)
    else
        ClearPedSecondaryTask(ped)
        SetEnableHandcuffs(ped, false)
        DisablePlayerFiring(ped, false)
        SetPedCanPlayGestureAnims(ped, true)
        DragStatus.isDragged = false
        DetachEntity(ped, true, false)
    end
end)

RegisterNetEvent('mallorca-politie:client:drag', function(copId)
    if not IsHandcuffed then return end
    DragStatus.isDragged = not DragStatus.isDragged
    DragStatus.copId = copId
    if not DragStatus.isDragged then
        DetachEntity(PlayerPedId(), true, false)
    end
end)

RegisterNetEvent('mallorca-politie:client:putInVehicle', function()
    if not IsHandcuffed then return end
    local ped = PlayerPedId()
    local vehicle = ESX.Game.GetVehicleInDirection()
    if not vehicle or vehicle == 0 then
        vehicle = GetClosestVehicle(GetEntityCoords(ped), 6.0, 0, 71)
    end
    if vehicle and vehicle ~= 0 then
        for seat = 0, GetVehicleMaxNumberOfPassengers(vehicle) - 1 do
            if IsVehicleSeatFree(vehicle, seat) then
                TaskWarpPedIntoVehicle(ped, vehicle, seat)
                DragStatus.isDragged = false
                DetachEntity(ped, true, false)
                return
            end
        end
    end
end)

RegisterNetEvent('mallorca-politie:client:outVehicle', function()
    local ped = PlayerPedId()
    if IsPedSittingInAnyVehicle(ped) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        TaskLeaveVehicle(ped, vehicle, 16)
    end
end)

exports('IsHandcuffed', function()
    return IsHandcuffed
end)

exports('IsOnDuty', IsOnDuty)
exports('IsPoliceJob', IsPoliceJob)
