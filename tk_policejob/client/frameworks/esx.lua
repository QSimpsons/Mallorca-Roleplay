if Config.Framework ~= 'esx' then return end

local function loadESX()
    local ok, obj = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if ok and obj then
        ESX = obj
    end

    return ESX
end

loadESX()

TriggerCallback = function(name, cb, ...)
    local esx = loadESX()
    return esx.TriggerServerCallback(name, cb, ...)
end

function ShowNotification(text)
    ESX.ShowNotification(text)
end

function GetIdentifier()
    return ESX.PlayerData.identifier
end

function GetCharName()
    return ('%s %s'):format(ESX.PlayerData.firstName, ESX.PlayerData.lastName)
end

function GetDateOfBirth()
    return ESX.PlayerData.dateofbirth
end

function GetGender()
    return (ESX.PlayerData.sex == 1 or ESX.PlayerData.sex == 'f') and 'female' or 'male'
end

local function playerJob(data)
    data = data or (ESX and (ESX.PlayerData or (ESX.GetPlayerData and ESX.GetPlayerData())))
    return data and data.job
end

function GetJobName()
    local job = playerJob()
    return job and job.name
end

local function bindJobMethods(data)
    if type(data) ~= 'table' or data.GetJobName then return data end

    -- Escrowed files call player:GetJobName(). The bridge only used to expose a global.
    data.GetJobName = function()
        local job = data.job or (ESX and ESX.PlayerData and ESX.PlayerData.job)
        return job and job.name
    end

    data.GetGradeId = function()
        local job = data.job or (ESX and ESX.PlayerData and ESX.PlayerData.job)
        return job and job.grade
    end

    data.GetGradeLabel = function()
        local job = data.job or (ESX and ESX.PlayerData and ESX.PlayerData.job)
        return job and job.grade_label
    end

    return data
end

local function bindESX()
    local esx = loadESX()
    if not esx or esx.GetJobName then return end

    esx.GetJobName = GetJobName
    esx.GetGradeId = GetGradeId
    esx.GetGradeLabel = GetGradeLabel

    if esx.GetPlayerData then
        local original = esx.GetPlayerData
        esx.GetPlayerData = function(...)
            return bindJobMethods(original(...))
        end

        AddEventHandler('onResourceStop', function(resource)
            if resource ~= GetCurrentResourceName() then return end
            esx.GetPlayerData = original
            esx.GetJobName = nil
            esx.GetGradeId = nil
            esx.GetGradeLabel = nil
        end)
    end

    if esx.PlayerData then
        bindJobMethods(esx.PlayerData)
    end
end

function GetGradeId()
    return ESX.PlayerData?.job?.grade
end

function GetGradeLabel()
    return ESX.PlayerData?.job?.grade_label
end

bindESX()

function IsBoss()
    return ESX.PlayerData.job.grade >= 3
end

function IsOnDuty()
    return true
end

function IsDead(targetId)
    if targetId then
        local playerIndex = GetPlayerFromServerId(targetId)
        local targetPed = GetPlayerPed(playerIndex)
        local dead = IsEntityDead(targetPed)
        Utils.Debug('IsDead', targetId, dead)
        return dead
    end

    local dead = ESX?.GetPlayerData()?.dead
    Utils.Debug('IsDead local player', dead)
    return dead
end

function GetItemLabel(item)
    local p = promise.new()
    TriggerCallback('tk_policejob:getItemLabel', function(label)
        p:resolve(label)
    end, item)
    return Citizen.Await(p)
end

function GetWeaponLabel(weapon)
    return ESX.GetWeaponFromHash(weapon)?.label or weapon
end

function GetItemAmount(item)
    if Config.Inventory == 'qs' then
        return exports['qs-inventory']:Search(item) or 0
    end

    for _,v in pairs(ESX.GetPlayerData().inventory) do
        if v.name == item then
            return v.count or v.amount or 0
        end
    end

    return 0
end

RegisterNetEvent('esx:playerLoaded', function(playerData)
    local esx = loadESX()
    esx.PlayerData = bindJobMethods(playerData)
    bindESX()
    PlayerLoaded()
end)

RegisterNetEvent('esx:setJob', function(job)
    Wait(500)
    local esx = loadESX()
    esx.PlayerData = esx.PlayerData or {}
    esx.PlayerData.job = job
    bindJobMethods(esx.PlayerData)
    JobChanged()
end)

CreateThread(function()
    while not loadESX() do
        Wait(500)
    end

    bindESX()

    repeat
        Wait(2000)
        bindESX()
        if ESX.PlayerData then
            bindJobMethods(ESX.PlayerData)
        end
    until ESX.PlayerData?.job

    frameworkLoaded = true
end)