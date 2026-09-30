--[[ Eclipse Roleplay HUD - client ]]

local visible = false
local framework = 'standalone'
local PlayerData = {}
local hunger = Config.DefaultHunger or 100
local thirst = Config.DefaultThirst or 100

local function notifyNui(action, data)
    SendNUIMessage({
        action = action,
        data = data,
        visible = data and data.visible,
        hunger = data and data.hunger,
        thirst = data and data.thirst,
        id = data and data.id,
        job1 = data and data.job1,
        job2 = data and data.job2,
        health = data and data.health,
        armor = data and data.armor,
        stamina = data and data.stamina,
        voice = data and data.voice,
        talking = data and data.talking,
        showVoice = data and data.showVoice,
        showMoney = data and data.showMoney,
        cash = data and data.cash,
        bank = data and data.bank,
        showLocation = data and data.showLocation,
        street = data and data.street,
        zone = data and data.zone,
    })
end

local function setVisible(state)
    visible = state and true or false
    notifyNui('show', { visible = visible })
    if visible then
        pushHud(true)
    end
end

local function detectFramework()
    local mode = Config.Framework or 'auto'
    if mode ~= 'auto' then
        return mode
    end
    if GetResourceState('qbx_core') == 'started' then
        return 'qbx'
    end
    if GetResourceState('qb-core') == 'started' then
        return 'qb'
    end
    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end
    return 'standalone'
end

local function jobLabel(name, gradeLabel)
    if not name or name == '' then
        return Config.UnemployedLabel or 'Werkloos'
    end
    local mapped = Config.JobLabels and Config.JobLabels[name]
    if gradeLabel and gradeLabel ~= '' then
        if mapped then
            return ('%s — %s'):format(mapped, gradeLabel)
        end
        return ('%s — %s'):format(name, gradeLabel)
    end
    return mapped or name
end

local function getPlayerId()
    return GetPlayerServerId(PlayerId())
end

local function getJobs()
    local job1 = Config.UnemployedLabel or 'Werkloos'
    local job2 = Config.NoJob2Label or 'Geen'

    if framework == 'esx' and PlayerData.job then
        job1 = jobLabel(PlayerData.job.name, PlayerData.job.grade_label or PlayerData.job.grade_name)
        if PlayerData.job2 and PlayerData.job2.name then
            job2 = jobLabel(PlayerData.job2.name, PlayerData.job2.grade_label or PlayerData.job2.grade_name)
        elseif PlayerData.secondjob and PlayerData.secondjob.name then
            job2 = jobLabel(PlayerData.secondjob.name, PlayerData.secondjob.grade_label)
        end
    elseif (framework == 'qb' or framework == 'qbx') and PlayerData.job then
        local j = PlayerData.job
        local grade = j.grade and (j.grade.name or j.grade.level) or nil
        job1 = jobLabel(j.name, grade)
        if PlayerData.gang and PlayerData.gang.name and PlayerData.gang.name ~= 'none' then
            local g = PlayerData.gang
            local gGrade = g.grade and g.grade.name or nil
            job2 = jobLabel(g.name, gGrade)
        end
    end

    return job1, job2
end

local function getMoney()
    local cash, bank = 0, 0
    if framework == 'esx' and PlayerData.accounts then
        for _, acc in pairs(PlayerData.accounts) do
            if acc.name == 'money' then cash = acc.money or 0 end
            if acc.name == 'bank' then bank = acc.money or 0 end
        end
    elseif (framework == 'qb' or framework == 'qbx') and PlayerData.money then
        cash = PlayerData.money.cash or 0
        bank = PlayerData.money.bank or 0
    end
    return cash, bank
end

local function getNeeds()
    if framework == 'esx' then
        -- filled by esx_status events
        return hunger, thirst
    end
    if framework == 'qb' or framework == 'qbx' then
        local meta = PlayerData.metadata or {}
        local h = meta[Config.QB.Hunger] or meta.hunger or hunger
        local t = meta[Config.QB.Thirst] or meta.thirst or thirst
        return tonumber(h) or hunger, tonumber(t) or thirst
    end
    return hunger, thirst
end

local function getHealthArmorStamina()
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped)
    local maxHealth = GetEntityMaxHealth(ped)
    local hpPct = 0
    if maxHealth > 100 then
        hpPct = ((health - 100) / (maxHealth - 100)) * 100
    else
        hpPct = (health / math.max(maxHealth, 1)) * 100
    end
    hpPct = math.max(0.0, math.min(100.0, hpPct))

    local armor = math.max(0.0, math.min(100.0, GetPedArmour(ped) + 0.0))
    local stamina = 100.0
    local ok, val = pcall(function()
        return GetPlayerSprintStaminaRemaining(PlayerId())
    end)
    if ok and type(val) == 'number' then
        stamina = math.max(0.0, math.min(100.0, val + 0.0))
    end
    return hpPct, armor, stamina
end

local function getVoice()
    local talking = false
    local level = 66
    if NetworkIsPlayerTalking(PlayerId()) then
        talking = true
    end
    -- pma-voice proximity if available
    local ok, prox = pcall(function()
        return LocalPlayer.state and LocalPlayer.state['proximity']
    end)
    if ok and type(prox) == 'table' and prox.distance then
        local d = prox.distance
        if d <= 1.5 then level = 33
        elseif d <= 3.0 then level = 66
        else level = 100 end
    end
    return level, talking
end

local function getLocation()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local streetHash, crossingHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    local street = GetStreetNameFromHashKey(streetHash) or ''
    if crossingHash and crossingHash ~= 0 then
        local cross = GetStreetNameFromHashKey(crossingHash)
        if cross and cross ~= '' then
            street = street .. ' / ' .. cross
        end
    end
    local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    if not zone or zone == 'NULL' then zone = GetNameOfZone(coords.x, coords.y, coords.z) or '' end
    return street, zone
end

function pushHud(force)
    if not visible and not force then return end

    local h, t = getNeeds()
    local job1, job2 = getJobs()
    local hp, armor, stamina = getHealthArmorStamina()
    local voice, talking = getVoice()
    local cash, bank = getMoney()
    local street, zone = getLocation()

    notifyNui('update', {
        visible = visible,
        hunger = h,
        thirst = t,
        id = getPlayerId(),
        job1 = job1,
        job2 = job2,
        health = hp,
        armor = armor,
        stamina = stamina,
        voice = voice,
        talking = talking,
        showVoice = Config.ShowVoice ~= false,
        showMoney = Config.ShowMoney ~= false,
        cash = cash,
        bank = bank,
        showLocation = Config.ShowLocation ~= false,
        street = street,
        zone = zone,
    })
end

local function hideDefaultBars()
    if not Config.HideDefaultBars then return end
    local ped = PlayerPedId()
    SetPedMaxHealth(ped, GetEntityMaxHealth(ped))
end

-- Framework bootstrap
CreateThread(function()
    framework = detectFramework()

    if framework == 'esx' then
        local ESX = exports['es_extended']:getSharedObject()
        while not ESX.GetPlayerData().job do
            Wait(200)
        end
        PlayerData = ESX.GetPlayerData()

        RegisterNetEvent('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
            if Config.ShowOnStart then setVisible(true) end
        end)

        RegisterNetEvent('esx:setJob', function(job)
            PlayerData.job = job
        end)

        RegisterNetEvent('esx:setJob2', function(job)
            PlayerData.job2 = job
        end)

        RegisterNetEvent('esx:setAccountMoney', function(account)
            if not PlayerData.accounts then return end
            for i = 1, #PlayerData.accounts do
                if PlayerData.accounts[i].name == account.name then
                    PlayerData.accounts[i] = account
                    break
                end
            end
        end)

        -- esx_status hunger/thirst (values often 0-1000000)
        RegisterNetEvent('esx_status:onTick', function(data)
            if type(data) ~= 'table' then return end
            for i = 1, #data do
                local s = data[i]
                if s.name == (Config.ESX.Hunger or 'hunger') then
                    hunger = math.floor((s.percent or (s.val / 10000)) + 0.5)
                elseif s.name == (Config.ESX.Thirst or 'thirst') then
                    thirst = math.floor((s.percent or (s.val / 10000)) + 0.5)
                end
            end
        end)

        AddEventHandler('esx_status:loaded', function()
            TriggerEvent('esx_status:getStatus', Config.ESX.Hunger or 'hunger', function(status)
                if status then hunger = math.floor((status.getPercent and status.getPercent()) or 100) end
            end)
            TriggerEvent('esx_status:getStatus', Config.ESX.Thirst or 'thirst', function(status)
                if status then thirst = math.floor((status.getPercent and status.getPercent()) or 100) end
            end)
        end)

    elseif framework == 'qb' or framework == 'qbx' then
        local coreName = framework == 'qbx' and 'qbx_core' or 'qb-core'
        local QBCore = exports[coreName]:GetCoreObject()
        PlayerData = QBCore.Functions.GetPlayerData() or {}

        RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = QBCore.Functions.GetPlayerData() or {}
            if Config.ShowOnStart then setVisible(true) end
        end)

        RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
            PlayerData = {}
            setVisible(false)
        end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            PlayerData.job = job
        end)

        RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
            PlayerData.gang = gang
        end)

        RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
            PlayerData = val or PlayerData
        end)

        RegisterNetEvent('hud:client:UpdateNeeds', function(newHunger, newThirst)
            if newHunger then hunger = tonumber(newHunger) or hunger end
            if newThirst then thirst = tonumber(newThirst) or thirst end
        end)
    end

    if Config.ShowOnStart then
        Wait(500)
        setVisible(true)
    end
end)

-- Main tick
CreateThread(function()
    while true do
        local sleep = Config.TickMs or 200
        if visible then
            if Config.HideInPauseMenu and IsPauseMenuActive() then
                notifyNui('show', { visible = false })
            else
                if Config.HideInPauseMenu then
                    notifyNui('show', { visible = true })
                end
                pushHud()
            end

            if Config.HideDefaultBars then
                DisplayRadar(true)
                -- Hide only health/armor component hints where possible
            end
        else
            sleep = 500
        end
        Wait(sleep)
    end
end)

-- Exports / commands
exports('SetVisible', setVisible)
exports('IsVisible', function() return visible end)
exports('UpdateNeeds', function(h, t)
    if h then hunger = tonumber(h) or hunger end
    if t then thirst = tonumber(t) or thirst end
end)
exports('Push', function() pushHud(true) end)

RegisterCommand('togglehud', function()
    setVisible(not visible)
end, false)

RegisterCommand('hud', function()
    setVisible(not visible)
end, false)

-- External event API
RegisterNetEvent('eclipse-hud:client:setVisible', function(state)
    setVisible(state)
end)

RegisterNetEvent('eclipse-hud:client:updateNeeds', function(h, t)
    if h then hunger = tonumber(h) or hunger end
    if t then thirst = tonumber(t) or thirst end
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    framework = detectFramework()
    if Config.ShowOnStart then
        setVisible(true)
    end
end)
