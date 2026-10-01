local palen = {}
local laatsteFlits = {}

local function registreerPalen()
    for i = 1, #Config.Flitspalen do
        local paal = Config.Flitspalen[i]
        palen['snelheid:' .. i] = {
            naam = paal.naam,
            limiet = paal.limiet,
            coords = paal.coords,
            straal = (paal.straal or 18.0) + 45.0,
            rood = false
        }
    end

    for i = 1, #Config.Roodlicht do
        local kruispunt = Config.Roodlicht[i]
        palen['rood:' .. i] = {
            naam = kruispunt.naam,
            limiet = kruispunt.limiet,
            coords = kruispunt.centrum,
            straal = (kruispunt.straal or 14.0) + 45.0,
            rood = true
        }
    end
end

local function jobVan(src)
    if GetResourceState('es_extended') == 'started' then
        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and ESX then
            local xPlayer = ESX.GetPlayerFromId(src)
            if xPlayer and xPlayer.job then
                return xPlayer.job.name
            end
        end
    end

    if GetResourceState('qb-core') == 'started' then
        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and QBCore then
            local speler = QBCore.Functions.GetPlayer(src)
            if speler and speler.PlayerData and speler.PlayerData.job then
                return speler.PlayerData.job.name
            end
        end
    end

    return nil
end

local function isVrijgesteld(src)
    local job = jobVan(src)
    if not job then
        return false
    end

    for i = 1, #Config.VrijgesteldeJobs do
        if Config.VrijgesteldeJobs[i] == job then
            return true
        end
    end

    return false
end

local function schrijfAf(src, bedrag)
    if GetResourceState('es_extended') == 'started' then
        local ok, resultaat = pcall(function()
            local ESX = exports['es_extended']:getSharedObject()
            local xPlayer = ESX.GetPlayerFromId(src)
            if not xPlayer then
                return false
            end
            xPlayer.removeAccountMoney('bank', bedrag, 'Flitspaal')
            return true
        end)
        return ok and resultaat == true
    end

    if GetResourceState('qb-core') == 'started' then
        local ok, resultaat = pcall(function()
            local QBCore = exports['qb-core']:GetCoreObject()
            local speler = QBCore.Functions.GetPlayer(src)
            if not speler then
                return false
            end
            local gelukt = speler.Functions.RemoveMoney('bank', bedrag, 'flitspaal')
            if not gelukt then
                gelukt = speler.Functions.RemoveMoney('cash', bedrag, 'flitspaal')
            end
            return gelukt == true
        end)
        return ok and resultaat == true
    end

    return false
end

RegisterNetEvent('flitspalen:bekeuren', function(payload)
    local src = source
    if type(payload) ~= 'table' then
        return
    end

    if isVrijgesteld(src) then
        return
    end

    local paal = palen[payload.id]
    if not paal then
        return
    end

    local snelheid = tonumber(payload.snelheid)
    if not snelheid or snelheid < 0 or snelheid > 450 then
        return
    end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then
        return
    end

    local positie = GetEntityCoords(ped)
    if #(positie - paal.coords) > paal.straal then
        return
    end

    local nu = GetGameTimer()
    local vorige = laatsteFlits[src]
    if vorige and (nu - vorige) < Config.CooldownMs then
        return
    end

    local doorRood = payload.doorRood == true and paal.rood == true
    local over = 0
    if paal.limiet and snelheid > (paal.limiet + Config.Tolerantie) then
        over = math.floor(snelheid - paal.limiet)
    end

    if not doorRood and over <= 0 then
        return
    end

    laatsteFlits[src] = nu

    local bedrag = Config.BerekenBoete(over, doorRood)
    local afgeschreven = schrijfAf(src, bedrag)

    TriggerClientEvent('flitspalen:zichtbareFlits', -1, paal.coords.x, paal.coords.y, paal.coords.z)
    TriggerClientEvent('flitspalen:resultaat', src, {
        naam = paal.naam,
        limiet = paal.limiet,
        snelheid = math.floor(snelheid + 0.5),
        doorRood = doorRood,
        bedrag = bedrag,
        afgeschreven = afgeschreven
    })
end)

AddEventHandler('playerDropped', function()
    laatsteFlits[source] = nil
end)

registreerPalen()
