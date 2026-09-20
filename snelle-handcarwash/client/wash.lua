local ragModel = `p_cs_rag_01`
local bucketModel = `prop_cs_bucket_s`

local stagesByType = {
    basic = {
        { labelKey = 'progress_soap',  durationShare = 0.30, dict = 'timetable@floyd@clean_kitchen@base', clip = 'base', prop = 'bucket' },
        { labelKey = 'progress_scrub', durationShare = 0.45, dict = 'amb@world_human_maid_clean@idle_a', clip = 'idle_a', prop = 'rag' },
        { labelKey = 'progress_rinse', durationShare = 0.25, dict = 'timetable@floyd@clean_kitchen@base', clip = 'base', prop = 'bucket' }
    },
    complete = {
        { labelKey = 'progress_soap',  durationShare = 0.22, dict = 'timetable@floyd@clean_kitchen@base', clip = 'base', prop = 'bucket' },
        { labelKey = 'progress_scrub', durationShare = 0.32, dict = 'amb@world_human_maid_clean@idle_a', clip = 'idle_a', prop = 'rag' },
        { labelKey = 'progress_rinse', durationShare = 0.22, dict = 'timetable@floyd@clean_kitchen@base', clip = 'base', prop = 'bucket' },
        { labelKey = 'progress_dry',   durationShare = 0.24, dict = 'timetable@maid@cleaning_window@base', clip = 'base', prop = 'rag' }
    },
    premium = {
        { labelKey = 'progress_soap',  durationShare = 0.16, dict = 'timetable@floyd@clean_kitchen@base', clip = 'base', prop = 'bucket' },
        { labelKey = 'progress_scrub', durationShare = 0.22, dict = 'amb@world_human_maid_clean@idle_a', clip = 'idle_a', prop = 'rag' },
        { labelKey = 'progress_rinse', durationShare = 0.16, dict = 'timetable@floyd@clean_kitchen@base', clip = 'base', prop = 'bucket' },
        { labelKey = 'progress_dry',   durationShare = 0.16, dict = 'timetable@maid@cleaning_window@base', clip = 'base', prop = 'rag' },
        { labelKey = 'progress_tires', durationShare = 0.14, dict = 'amb@world_human_maid_clean@idle_a', clip = 'idle_a', prop = 'rag' },
        { labelKey = 'progress_wax',   durationShare = 0.16, dict = 'timetable@maid@cleaning_window@base', clip = 'base', prop = 'rag' }
    },
    tires = {
        { labelKey = 'progress_tires', durationShare = 1.0, dict = 'amb@world_human_maid_clean@idle_a', clip = 'idle_a', prop = 'rag' }
    },
    kit = {
        { labelKey = 'progress_kit',   durationShare = 0.25, dict = 'timetable@floyd@clean_kitchen@base', clip = 'base', prop = 'bucket' },
        { labelKey = 'progress_scrub', durationShare = 0.30, dict = 'amb@world_human_maid_clean@idle_a', clip = 'idle_a', prop = 'rag' },
        { labelKey = 'progress_dry',   durationShare = 0.20, dict = 'timetable@maid@cleaning_window@base', clip = 'base', prop = 'rag' },
        { labelKey = 'progress_wax',   durationShare = 0.25, dict = 'timetable@maid@cleaning_window@base', clip = 'base', prop = 'rag' }
    },
    wax = {
        { labelKey = 'progress_wax', durationShare = 1.0, dict = 'timetable@maid@cleaning_window@base', clip = 'base', prop = 'rag' }
    }
}

local function faceVehicle(ped, vehicle)
    if not Config.Wash.headingToVehicle then
        return
    end

    local pedCoords = GetEntityCoords(ped)
    local vehCoords = GetEntityCoords(vehicle)
    local heading = GetHeadingFromVector_2d(vehCoords.x - pedCoords.x, vehCoords.y - pedCoords.y)
    SetEntityHeading(ped, heading)
end

local function playStageAnim(ped, stage, props)
    Handwash.ClearProps(props)
    for i = #props, 1, -1 do
        props[i] = nil
    end

    if stage.dict and Handwash.LoadAnim(stage.dict) then
        TaskPlayAnim(ped, stage.dict, stage.clip or 'base', 2.0, 2.0, -1, 49, 0.0, false, false, false)
    else
        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
    end

    local pos = vector3(0.12, 0.0, -0.05)
    local rot = vector3(-90.0, 0.0, 0.0)

    if stage.prop == 'bucket' then
        local obj = Handwash.CreateProp(bucketModel, ped, 28422, vector3(0.20, 0.0, -0.12), vector3(-80.0, 0.0, 0.0))
        if obj then
            props[#props + 1] = obj
        end
    elseif stage.prop == 'rag' then
        local obj = Handwash.CreateProp(ragModel, ped, 28422, pos, rot)
        if obj then
            props[#props + 1] = obj
        end
    end
end

local function nativeProgress(duration, label, ped, vehicle)
    local start = GetGameTimer()
    local startCoords = GetEntityCoords(ped)

    while GetGameTimer() - start < duration do
        if Config.Wash.disableCombat then
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 140, true)
            DisableControlAction(0, 141, true)
            DisableControlAction(0, 142, true)
        end

        if IsControlJustPressed(0, 194) or IsControlJustPressed(0, 200) or IsControlJustPressed(0, 73) then
            return false
        end

        if Config.Wash.cancelOnMove and #(GetEntityCoords(ped) - startCoords) > 1.8 then
            return false
        end

        if vehicle and not DoesEntityExist(vehicle) then
            return false
        end

        DrawRect(0.5, 0.90, 0.22, 0.018, 0, 0, 0, 140)
        local pct = (GetGameTimer() - start) / duration
        DrawRect(0.5 - (0.22 * (1.0 - pct)) / 2, 0.90, 0.22 * pct, 0.018, 56, 189, 248, 220)

        SetTextFont(4)
        SetTextScale(0.32, 0.32)
        SetTextCentre(true)
        SetTextColour(255, 255, 255, 230)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName(label)
        EndTextCommandDisplayText(0.5, 0.872)

        Wait(0)
    end

    return true
end

local function runProgress(duration, label, anim)
    if GetProgressType() == 'ox_lib' and HasOxLib() and lib.progressBar then
        return lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = Config.Wash.disableCombat
            },
            anim = anim and anim.dict and {
                dict = anim.dict,
                clip = anim.clip or 'base',
                flag = 49
            } or nil
        })
    end

    return nativeProgress(duration, label, PlayerPedId(), Handwash.currentVehicle)
end

local function runWashStages(vehicle, washType, totalDuration)
    local ped = PlayerPedId()
    local stages = stagesByType[washType] or stagesByType.basic
    local props = {}
    local ok = true

    faceVehicle(ped, vehicle)
    FreezeEntityPosition(ped, true)
    Handwash.currentVehicle = vehicle

    for i = 1, #stages do
        local stage = stages[i]
        local duration = math.floor(totalDuration * stage.durationShare)
        if duration < 1200 then
            duration = 1200
        end

        playStageAnim(ped, stage, props)

        -- Animatie + props blijven via playStageAnim; ox_lib doet alleen de balk.
        local success = runProgress(duration, L(stage.labelKey), nil)
        if not success then
            ok = false
            break
        end
    end

    Handwash.ClearProps(props)
    Handwash.StopAnim()
    Handwash.currentVehicle = nil
    return ok
end

local function applyClean(vehicle, payload)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return
    end

    if payload.dirtLevel ~= nil then
        SetVehicleDirtLevel(vehicle, payload.dirtLevel + 0.0)
        WashDecalsFromVehicle(vehicle, 1.0)
    end

    if payload.cleanTires then
        SetVehicleDirtLevel(vehicle, payload.dirtLevel ~= nil and payload.dirtLevel + 0.0 or GetVehicleDirtLevel(vehicle) * 0.35)
        WashDecalsFromVehicle(vehicle, 1.0)
    end
end

local function finishWash(vehicle, washType)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdExistsOnAllMachines(netId, true)

    Handwash.ServerCallback('snelle-handcarwash:finishWash', function(result)
        Handwash.busy = false

        if not result or not result.ok then
            Handwash.NotifyReason(result and result.reason or 'cancelled', result and result.extra)
            return
        end

        Handwash.lastWash = GetGameTimer()
        applyClean(vehicle, result)

        if result.waxed then
            Handwash.Notify(L('wax_done', Config.Wash.waxDurationMinutes), 'success')
        elseif washType == 'tires' then
            Handwash.Notify(L('tires_done'), 'success')
        else
            Handwash.Notify(L('wash_done'), 'success')
        end
    end, netId, washType)
end

function Handwash.StartWash(vehicle, washType)
    local allowed, reason = Handwash.CanWashVehicle(vehicle, washType)
    if not allowed then
        Handwash.NotifyReason(reason)
        return
    end

    if Handwash.busy then
        Handwash.NotifyReason('busy')
        return
    end

    Handwash.busy = true
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    SetNetworkIdExistsOnAllMachines(netId, true)

    Handwash.ServerCallback('snelle-handcarwash:startWash', function(result)
        if not result or not result.ok then
            Handwash.busy = false
            Handwash.NotifyReason(result and result.reason or 'missing_items', result and result.extra)
            return
        end

        Handwash.Notify(L('wash_started'), 'inform')
        local data = GetWashType(washType)
        local success = runWashStages(vehicle, washType, data.duration or 15000)

        if not success then
            Handwash.busy = false
            Handwash.StopAnim()
            Handwash.Notify(L('cancelled'), 'error')
            TriggerServerEvent('snelle-handcarwash:cancelWash')
            return
        end

        finishWash(vehicle, washType)
    end, netId, washType)
end

local function washOptionsForMenu()
    local options = {}
    local order = { 'basic', 'complete', 'premium', 'wax', 'tires', 'kit' }

    for i = 1, #order do
        local name = order[i]
        local data = GetWashType(name)
        if data then
            options[#options + 1] = {
                name = name,
                title = data.label,
                description = data.description,
                label = data.label
            }
        end
    end

    return options
end

function Handwash.OpenWashMenu(vehicle)
    vehicle = vehicle or select(1, Handwash.GetClosestVehicle(Config.Wash.maxDistance))
    if not vehicle then
        Handwash.NotifyReason('no_vehicle')
        return
    end

    local options = washOptionsForMenu()

    if HasOxLib() and lib.registerContext then
        local ctx = {}
        for i = 1, #options do
            local opt = options[i]
            ctx[#ctx + 1] = {
                title = opt.title,
                description = opt.description,
                icon = 'soap',
                onSelect = function()
                    Handwash.StartWash(vehicle, opt.name)
                end
            }
        end

        lib.registerContext({
            id = 'snelle_handwash_menu',
            title = L('menu_title'),
            options = ctx
        })
        lib.showContext('snelle_handwash_menu')
        return
    end

    if ESX and ESX.UI and ESX.UI.Menu then
        local elements = {}
        for i = 1, #options do
            elements[#elements + 1] = {
                label = options[i].label,
                value = options[i].name
            }
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'handwash_menu', {
            title = L('menu_title'),
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            menu.close()
            Handwash.StartWash(vehicle, data.current.value)
        end, function(_, menu)
            menu.close()
        end)
        return
    end

    Handwash.Notify(L('help_command') .. ' (/handwas basic|complete|premium|tires|kit)', 'inform')
end

RegisterNetEvent('snelle-handcarwash:client:usedItem', function(itemName)
    if itemName == Config.Items.emptyBucket then
        if Handwash.TryFillBucket then
            Handwash.TryFillBucket()
        end
        return
    end

    local mapped = Config.ItemToWashType[itemName]
    local vehicle = select(1, Handwash.GetClosestVehicle(Config.Wash.maxDistance))

    if mapped then
        Handwash.StartWash(vehicle, mapped)
        return
    end

    Handwash.OpenWashMenu(vehicle)
end)

RegisterNetEvent('snelle-handcarwash:client:applyClean', function(netId, payload)
    if not netId or not payload then
        return
    end

    local vehicle = NetworkGetEntityFromNetworkId(netId)
    applyClean(vehicle, payload)
end)

AddStateBagChangeHandler('snelleHandwash', nil, function(bagName, _, value)
    if not value then
        return
    end

    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then
        return
    end

    applyClean(entity, value)
end)

CreateThread(function()
    if Config.Wash.waxDurationMinutes <= 0 then
        return
    end

    while true do
        Wait(12000)
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 and DoesEntityExist(vehicle) then
            local state = Entity(vehicle).state.snelleHandwash
            if state and state.waxedUntil and state.waxedUntil > GetCloudTimeAsInt() then
                if GetVehicleDirtLevel(vehicle) > 0.04 then
                    SetVehicleDirtLevel(vehicle, 0.0)
                end
            end
        end
    end
end)

if Config.Command.enabled then
    RegisterCommand(Config.Command.name, function(_, args)
        local washType = args[1] and string.lower(args[1]) or nil
        local vehicle = select(1, Handwash.GetClosestVehicle(Config.Wash.maxDistance))

        if washType and GetWashType(washType) then
            Handwash.StartWash(vehicle, washType)
            return
        end

        Handwash.OpenWashMenu(vehicle)
    end, false)

    TriggerEvent('chat:addSuggestion', '/' .. Config.Command.name, L('help_command'), {
        { name = 'type', help = 'basic | complete | premium | wax | tires | kit' }
    })
end

CreateThread(function()
    local waited = 0
    while GetTargetType() == 'none' and waited < 6000 do
        Wait(250)
        waited = waited + 250
    end

    local targetType = GetTargetType()
    if targetType == 'ox_target' and HasOxTarget() then
        exports.ox_target:addGlobalVehicle({
            {
                name = 'snelle_handwash_vehicle',
                icon = 'fa-solid fa-soap',
                label = L('target_wash'),
                distance = Config.Wash.maxDistance,
                canInteract = function()
                    return not IsPedInAnyVehicle(PlayerPedId(), false) and not Handwash.busy
                end,
                onSelect = function(data)
                    Handwash.OpenWashMenu(data.entity)
                end
            }
        })
        return
    end

    if targetType == 'qtarget' and HasQTarget() then
        exports.qtarget:Vehicle({
            options = {
                {
                    icon = 'fas fa-soap',
                    label = L('target_wash'),
                    canInteract = function()
                        return not IsPedInAnyVehicle(PlayerPedId(), false) and not Handwash.busy
                    end,
                    action = function(entity)
                        Handwash.OpenWashMenu(entity)
                    end
                }
            },
            distance = Config.Wash.maxDistance
        })
    end
end)
