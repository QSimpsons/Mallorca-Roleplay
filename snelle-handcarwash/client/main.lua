ESX = nil
Handwash = Handwash or {}
Handwash.busy = false
Handwash.lastWash = 0
Handwash.textUiOpen = false

local function loadESX()
    if ESX then
        return
    end

    if exports and exports['es_extended'] then
        local ok, obj = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and obj then
            ESX = obj
            return
        end
    end

    TriggerEvent('esx:getSharedObject', function(obj)
        ESX = obj
    end)
end

CreateThread(function()
    loadESX()
    while not ESX do
        loadESX()
        Wait(100)
    end
end)

function Handwash.Notify(message, nType)
    nType = nType or 'inform'
    local method = GetNotifyType()

    if method == 'ox_lib' and HasOxLib() then
        lib.notify({
            title = L('notify_title'),
            description = message,
            type = nType
        })
        return
    end

    if ESX and ESX.ShowNotification then
        ESX.ShowNotification(message)
        return
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

function Handwash.ShowTextUI(text)
    if Handwash.textUiOpen then
        return
    end

    Handwash.textUiOpen = true
    local method = GetTextUIType()

    if method == 'ox_lib' and HasOxLib() and lib.showTextUI then
        lib.showTextUI(text)
        return
    end

    Handwash.helpText = text
end

function Handwash.HideTextUI()
    if not Handwash.textUiOpen then
        return
    end

    Handwash.textUiOpen = false
    Handwash.helpText = nil

    if HasOxLib() and lib.hideTextUI then
        lib.hideTextUI()
    end
end

CreateThread(function()
    while true do
        local sleep = 500
        if Handwash.helpText then
            sleep = 0
            BeginTextCommandDisplayHelp('STRING')
            AddTextComponentSubstringPlayerName(Handwash.helpText)
            EndTextCommandDisplayHelp(0, false, false, -1)
        end
        Wait(sleep)
    end
end)

function Handwash.ServerCallback(name, cb, ...)
    while not ESX do
        Wait(50)
    end

    ESX.TriggerServerCallback(name, cb, ...)
end

function Handwash.GetClosestVehicle(maxDistance)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closest, closestDist = nil, maxDistance or Config.Wash.maxDistance

    local pool = GetGamePool('CVehicle')
    for i = 1, #pool do
        local veh = pool[i]
        if DoesEntityExist(veh) then
            local dist = #(coords - GetEntityCoords(veh))
            if dist < closestDist then
                closest = veh
                closestDist = dist
            end
        end
    end

    return closest, closestDist
end

function Handwash.CanWashVehicle(vehicle, washType)
    if Handwash.busy then
        return false, 'busy'
    end

    if (GetGameTimer() - Handwash.lastWash) < (Config.Wash.cooldownSeconds * 1000) then
        return false, 'cooldown'
    end

    local ped = PlayerPedId()

    if Config.Wash.requireOutOfVehicle and IsPedInAnyVehicle(ped, false) then
        return false, 'in_vehicle'
    end

    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return false, 'no_vehicle'
    end

    local dist = #(GetEntityCoords(ped) - GetEntityCoords(vehicle))
    if dist > Config.Wash.maxDistance then
        return false, 'too_far'
    end

    if Config.Wash.requireEngineOff and GetIsVehicleEngineRunning(vehicle) then
        return false, 'engine_on'
    end

    local data = GetWashType(washType)
    if not data then
        return false, 'invalid_wash'
    end

    local dirt = GetVehicleDirtLevel(vehicle)
    local allowDirtyCheck = data.dirtLevel ~= nil and not data.waxed and not (data.cleanTires and data.dirtLevel == nil)

    if allowDirtyCheck and dirt <= Config.Wash.minDirtLevel then
        return false, 'already_clean'
    end

    return true
end

function Handwash.NotifyReason(reason, extra)
    if reason == 'missing_items' then
        Handwash.Notify(L('missing_items', extra or ''), 'error')
        return
    end

    if reason == 'not_enough_money' then
        Handwash.Notify(L('not_enough_money', extra or 0), 'error')
        return
    end

    local key = reason or 'busy'
    local text = L(key)
    Handwash.Notify(text, 'error')
end

function Handwash.LoadAnim(dict)
    if not dict or dict == '' then
        return false
    end

    if HasAnimDictLoaded(dict) then
        return true
    end

    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(10)
    end

    return true
end

function Handwash.LoadModel(model)
    if type(model) == 'string' then
        model = joaat(model)
    end

    if not IsModelValid(model) then
        return false
    end

    RequestModel(model)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model) do
        if GetGameTimer() > timeout then
            return false
        end
        Wait(10)
    end

    return true
end

function Handwash.CreateProp(model, ped, bone, pos, rot)
    if not Handwash.LoadModel(model) then
        return nil
    end

    local coords = GetEntityCoords(ped)
    local obj = CreateObject(model, coords.x, coords.y, coords.z + 0.2, true, true, false)
    if obj == 0 then
        return nil
    end

    AttachEntityToEntity(
        obj,
        ped,
        GetPedBoneIndex(ped, bone or 28422),
        pos.x, pos.y, pos.z,
        rot.x, rot.y, rot.z,
        true, true, false, true, 1, true
    )
    SetModelAsNoLongerNeeded(model)
    return obj
end

function Handwash.ClearProps(props)
    if not props then
        return
    end

    for i = 1, #props do
        local obj = props[i]
        if obj and DoesEntityExist(obj) then
            DetachEntity(obj, true, true)
            DeleteEntity(obj)
        end
    end
end

function Handwash.StopAnim()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)
end

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    Handwash.HideTextUI()
    Handwash.StopAnim()
    Handwash.busy = false
end)
