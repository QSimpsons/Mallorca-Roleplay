local GROEN, ROOD, GEEL = 0, 1, 2

local jobNaam = nil
local laatsteFlits = 0
local hint = nil
local gespawned = {}
local lichtCache = {}
local lichtAanwezig = {}
local objectPool = nil
local overriden = {}

local stoplichtHashes = {}

local function hashModels()
    for i = 1, #Config.StoplichtModellen do
        stoplichtHashes[joaat(Config.StoplichtModellen[i])] = true
    end
end

local function hoekVerschil(a, b)
    local verschil = math.abs((a - b) % 360.0)
    if verschil > 180.0 then
        verschil = 360.0 - verschil
    end
    return verschil
end

local function asVanHeading(heading)
    local kwart = math.floor(((heading % 360.0) / 90.0) + 0.5) % 4
    return kwart % 2
end

local function bestuurdersVoertuig()
    local ped = PlayerPedId()
    if IsEntityDead(ped) or not IsPedInAnyVehicle(ped, false) then
        return 0
    end

    local voertuig = GetVehiclePedIsIn(ped, false)
    if GetPedInVehicleSeat(voertuig, -1) ~= ped then
        return 0
    end

    local klasse = GetVehicleClass(voertuig)
    if klasse == 14 or klasse == 15 or klasse == 16 or klasse == 21 then
        return 0
    end

    return voertuig
end

local function isVrijgesteld(voertuig)
    if jobNaam then
        for i = 1, #Config.VrijgesteldeJobs do
            if Config.VrijgesteldeJobs[i] == jobNaam then
                return true
            end
        end
    end

    if Config.NoodvoertuigMetSireneVrij and GetVehicleClass(voertuig) == 18 and IsVehicleSirenOn(voertuig) then
        return true
    end

    return false
end

local function kleurVoorAs(offset, as)
    local groen = Config.GroenMs
    local geel = Config.GeelMs
    local half = groen + geel
    local cyclus = half * 2
    local tijd = (GetNetworkTime() + (offset or 0)) % cyclus
    local actieveAs = tijd < half and 0 or 1

    if as ~= actieveAs then
        return ROOD
    end

    if (tijd % half) < groen then
        return GROEN
    end

    return GEEL
end

local function magFlitsen()
    local nu = GetGameTimer()
    if (nu - laatsteFlits) < Config.CooldownMs then
        return false
    end
    laatsteFlits = nu
    return true
end

local function toonFlits(data)
    PlaySoundFrontend(-1, 'Camera_Shoot', 'Phone_SoundSet_Franklin', true)
    SendNUIMessage({
        action = 'flits',
        data = data
    })
end

local function stuurBekeuring(id, snelheid, doorRood, coords)
    TriggerServerEvent('flitspalen:bekeuren', {
        id = id,
        snelheid = snelheid,
        doorRood = doorRood,
        x = coords.x,
        y = coords.y,
        z = coords.z
    })
end

local function stoplichtObjecten()
    local nu = GetGameTimer()
    if objectPool and (nu - objectPool.tijd) < 1500 then
        return objectPool.lijst
    end

    local lijst = {}
    local objecten = GetGamePool('CObject')
    for i = 1, #objecten do
        local obj = objecten[i]
        if stoplichtHashes[GetEntityModel(obj)] then
            lijst[#lijst + 1] = obj
        end
    end

    objectPool = { tijd = nu, lijst = lijst }
    return lijst
end

local function vindLichten(centrum, straal)
    local gevonden = {}
    local objecten = stoplichtObjecten()

    for i = 1, #objecten do
        local obj = objecten[i]
        if DoesEntityExist(obj) then
            local positie = GetEntityCoords(obj)
            if #(positie - centrum) <= straal then
                gevonden[#gevonden + 1] = obj
            end
        end
    end

    return gevonden
end

local function zetStoplichten(kruispunt, index)
    local cache = lichtCache[index]
    local nu = GetGameTimer()

    if not cache or (nu - cache.tijd) > 1500 then
        cache = {
            tijd = nu,
            lichten = vindLichten(kruispunt.centrum, kruispunt.zoekstraal or 40.0)
        }
        lichtCache[index] = cache
    end

    local gezien = {}

    for i = 1, #cache.lichten do
        local licht = cache.lichten[i]
        if DoesEntityExist(licht) then
            local as = asVanHeading(GetEntityHeading(licht))
            SetEntityTrafficlightOverride(licht, kleurVoorAs(kruispunt.offset, as))
            overriden[licht] = true
            gezien[licht] = true
        end
    end

    return #cache.lichten > 0, gezien
end

local function resetLichtenBuiten(gezien)
    for licht in pairs(overriden) do
        if not gezien[licht] then
            if DoesEntityExist(licht) then
                SetEntityTrafficlightOverride(licht, -1)
            end
            overriden[licht] = nil
        end
    end
end

local function rijdtDezeKant(heading, richting, beide)
    if beide ~= false then
        return true
    end
    return hoekVerschil(heading, richting or 0.0) <= Config.RichtingTolerantie
end

local function teHard(snelheid, limiet)
    if not limiet then
        return 0
    end
    if snelheid <= (limiet + Config.Tolerantie) then
        return 0
    end
    return math.floor(snelheid - limiet)
end

local function controleerSnelheid(coords, heading, snelheid)
    local dichtstbij = nil
    local dichtsteAfstand = nil

    for i = 1, #Config.Flitspalen do
        local paal = Config.Flitspalen[i]
        local afstand = #(coords - paal.coords)
        local bereik = (paal.straal or 18.0) + 40.0

        if afstand <= bereik then
            if not dichtsteAfstand or afstand < dichtsteAfstand then
                dichtsteAfstand = afstand
                dichtstbij = paal
            end
        end

        if afstand <= (paal.straal or 18.0) and rijdtDezeKant(heading, paal.richting, paal.beideRichtingen) then
            local over = teHard(snelheid, paal.limiet)
            if over > 0 and magFlitsen() then
                local afgerond = math.floor(snelheid + 0.5)
                toonFlits({
                    naam = paal.naam,
                    limiet = paal.limiet,
                    snelheid = afgerond,
                    doorRood = false,
                    bedrag = Config.BerekenBoete(over, false),
                    afgeschreven = false
                })
                stuurBekeuring('snelheid:' .. i, afgerond, false, paal.coords)
                return true, nil
            end
        end
    end

    return false, dichtstbij
end

local function controleerRood(coords, heading, snelheid)
    local inDeBuurt = false
    local hintPaal = nil
    local geflitst = false

    for i = 1, #Config.Roodlicht do
        local kruispunt = Config.Roodlicht[i]
        local afstand = #(coords - kruispunt.centrum)
        local volgAfstand = (kruispunt.zoekstraal or 40.0) + 30.0

        if afstand <= volgAfstand then
            inDeBuurt = true

            if not hintPaal or afstand < hintPaal.afstand then
                hintPaal = {
                    afstand = afstand,
                    naam = kruispunt.naam,
                    limiet = kruispunt.limiet,
                    straal = (kruispunt.straal or 14.0) + 28.0
                }
            end

            if not geflitst and afstand <= (kruispunt.straal or 14.0) then
                local over = teHard(snelheid, kruispunt.limiet)
                local doorRood = false

                if lichtAanwezig[i] and snelheid >= Config.RoodMinSnelheid then
                    local kleur = kleurVoorAs(kruispunt.offset, asVanHeading(heading))
                    doorRood = kleur == ROOD or (Config.FlitsOpGeel and kleur == GEEL)
                end

                if doorRood or over > 0 then
                    if magFlitsen() then
                        local afgerond = math.floor(snelheid + 0.5)
                        toonFlits({
                            naam = kruispunt.naam,
                            limiet = kruispunt.limiet,
                            snelheid = afgerond,
                            doorRood = doorRood,
                            bedrag = Config.BerekenBoete(over, doorRood),
                            afgeschreven = false
                        })
                        stuurBekeuring('rood:' .. i, afgerond, doorRood, kruispunt.centrum)
                    end
                    geflitst = true
                end
            end
        end
    end

    return geflitst, inDeBuurt, hintPaal
end

local function rechtsVan(coords, heading, meters)
    local rad = math.rad(heading or 0.0)
    return vector3(
        coords.x + (math.cos(rad) * meters),
        coords.y + (math.sin(rad) * meters),
        coords.z
    )
end

local function grondHoogte(x, y, z)
    RequestCollisionAtCoord(x, y, z)
    local gevonden, hoogte = GetGroundZFor_3dCoord(x, y, z + 2.0, false)
    if gevonden then
        return hoogte
    end

    gevonden, hoogte = GetGroundZFor_3dCoord(x, y, z + 40.0, false)
    if gevonden then
        return hoogte
    end

    return z
end

local function laadModel(naam)
    local model = joaat(naam)
    if not IsModelInCdimage(model) then
        return nil
    end

    RequestModel(model)
    local timeout = GetGameTimer() + 3000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do
        Wait(10)
    end

    if not HasModelLoaded(model) then
        return nil
    end

    return model
end

local function spawnPaal(paal)
    local model = laadModel(Config.PaalModel) or laadModel('prop_cctv_pole_01a') or laadModel('prop_cctv_pole_02')
    if not model then
        return nil
    end

    local plek = rechtsVan(paal.coords, paal.richting, Config.PaalOpzij)
    local z = grondHoogte(plek.x, plek.y, plek.z)
    local obj = CreateObject(model, plek.x, plek.y, z, false, false, false)
    SetEntityHeading(obj, paal.richting or 0.0)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)
    SetModelAsNoLongerNeeded(model)
    return obj
end

local function ruimPalenOp()
    for index, obj in pairs(gespawned) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
        gespawned[index] = nil
    end

    for licht in pairs(overriden) do
        if DoesEntityExist(licht) then
            SetEntityTrafficlightOverride(licht, -1)
        end
        overriden[licht] = nil
    end
end

local function tekenHint(tekst)
    SetTextFont(4)
    SetTextScale(0.42, 0.42)
    SetTextColour(255, 255, 255, 230)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(tekst)
    EndTextCommandDisplayText(0.5, 0.86)
end

local function tekenDebug(coords)
    for i = 1, #Config.Flitspalen do
        local paal = Config.Flitspalen[i]
        if #(coords - paal.coords) < 80.0 then
            DrawMarker(1, paal.coords.x, paal.coords.y, paal.coords.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.2, 1.2, 1.2, 220, 40, 40, 160, false, false, 2, false, nil, nil, false)
        end
    end

    for i = 1, #Config.Roodlicht do
        local kruispunt = Config.Roodlicht[i]
        if #(coords - kruispunt.centrum) < 80.0 then
            DrawMarker(1, kruispunt.centrum.x, kruispunt.centrum.y, kruispunt.centrum.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, kruispunt.straal * 2.0, kruispunt.straal * 2.0, 1.4, 255, 170, 0, 80, false, false, 2, false, nil, nil, false)
        end
    end
end

local function maakRodeCameraBlip(coords, label)
    local bol = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(bol, 1)
    SetBlipColour(bol, 1)
    SetBlipScale(bol, 0.95)
    SetBlipDisplay(bol, 4)
    SetBlipAsShortRange(bol, Config.BlipKorteAfstand)
    SetBlipHiddenOnLegend(bol, true)

    local camera = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(camera, 184)
    SetBlipColour(camera, 0)
    SetBlipScale(camera, 0.55)
    SetBlipDisplay(camera, 4)
    SetBlipAsShortRange(camera, Config.BlipKorteAfstand)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(label)
    EndTextCommandSetBlipName(camera)
end

local function laadJob()
    if GetResourceState('es_extended') == 'started' then
        local ok, ESX = pcall(function()
            return exports['es_extended']:getSharedObject()
        end)
        if ok and ESX and ESX.GetPlayerData then
            local data = ESX.GetPlayerData()
            if data and data.job then
                jobNaam = data.job.name
            end
        end
    end

    if GetResourceState('qb-core') == 'started' then
        local ok, QBCore = pcall(function()
            return exports['qb-core']:GetCoreObject()
        end)
        if ok and QBCore and QBCore.Functions and QBCore.Functions.GetPlayerData then
            local data = QBCore.Functions.GetPlayerData()
            if data and data.job then
                jobNaam = data.job.name
            end
        end
    end
end

CreateThread(function()
    hashModels()
    Wait(1500)
    laadJob()

    if Config.ToonBlips then
        for i = 1, #Config.Flitspalen do
            local paal = Config.Flitspalen[i]
            maakRodeCameraBlip(paal.coords, ('Flitspaal %d km/h'):format(paal.limiet))
        end
    end
end)

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    if xPlayer and xPlayer.job then
        jobNaam = xPlayer.job.name
    end
end)

RegisterNetEvent('esx:setJob', function(job)
    jobNaam = job and job.name or nil
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    laadJob()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    jobNaam = job and job.name or nil
end)

RegisterNetEvent('flitspalen:resultaat', function(data)
    if type(data) ~= 'table' then
        return
    end
    SendNUIMessage({
        action = 'bijwerken',
        data = data
    })
end)

local zichtbareFlitsen = {}

RegisterNetEvent('flitspalen:zichtbareFlits', function(x, y, z)
    zichtbareFlitsen[#zichtbareFlitsen + 1] = {
        coords = vector3(x, y, z),
        tot = GetGameTimer() + 180
    }
end)

CreateThread(function()
    while true do
        if #zichtbareFlitsen == 0 then
            Wait(250)
        else
            local nu = GetGameTimer()
            local pedCoords = GetEntityCoords(PlayerPedId())

            for i = #zichtbareFlitsen, 1, -1 do
                local flits = zichtbareFlitsen[i]
                if nu > flits.tot then
                    table.remove(zichtbareFlitsen, i)
                elseif #(pedCoords - flits.coords) < 90.0 then
                    DrawLightWithRange(flits.coords.x, flits.coords.y, flits.coords.z + 2.4, 255, 255, 255, 16.0, 10.0)
                end
            end

            Wait(0)
        end
    end
end)

CreateThread(function()
    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local gezien = {}
        local inDeBuurt = false

        for i = 1, #Config.Roodlicht do
            local kruispunt = Config.Roodlicht[i]
            local afstand = #(coords - kruispunt.centrum)
            local volgAfstand = (kruispunt.zoekstraal or 40.0) + 80.0

            if afstand <= volgAfstand then
                inDeBuurt = true
                local heeftLicht, lichten = zetStoplichten(kruispunt, i)
                lichtAanwezig[i] = heeftLicht
                for licht in pairs(lichten) do
                    gezien[licht] = true
                end
            else
                lichtAanwezig[i] = false
            end
        end

        resetLichtenBuiten(gezien)
        Wait(inDeBuurt and 200 or 900)
    end
end)

CreateThread(function()
    while true do
        local pedCoords = GetEntityCoords(PlayerPedId())
        local wacht = 700
        local voertuig = bestuurdersVoertuig()
        local actieveHint = nil

        if voertuig ~= 0 and not isVrijgesteld(voertuig) then
            local coords = GetEntityCoords(voertuig)
            local heading = GetEntityHeading(voertuig)
            local snelheid = GetEntitySpeed(voertuig) * 3.6
            local _, inDeBuurt, roodHint = controleerRood(coords, heading, snelheid)
            local _, paal = controleerSnelheid(coords, heading, snelheid)

            if inDeBuurt or (paal and #(coords - paal.coords) < ((paal.straal or 18.0) + 30.0)) then
                wacht = 50
            end

            if Config.ToonLimietTekst then
                if paal and #(coords - paal.coords) <= ((paal.straal or 18.0) + 22.0) then
                    actieveHint = ('Flitspaal · max %d km/h'):format(paal.limiet)
                elseif roodHint and roodHint.afstand <= roodHint.straal then
                    actieveHint = ('Roodlicht · max %d km/h'):format(roodHint.limiet)
                end
            end
        end

        if Config.Debug then
            tekenDebug(pedCoords)
            wacht = math.min(wacht, 0)
        end

        hint = actieveHint
        Wait(wacht)
    end
end)

CreateThread(function()
    while true do
        if hint then
            tekenHint(hint)
            Wait(0)
        else
            Wait(200)
        end
    end
end)

CreateThread(function()
    if not Config.SpawnPalen then
        return
    end

    while true do
        local coords = GetEntityCoords(PlayerPedId())

        for i = 1, #Config.Flitspalen do
            local paal = Config.Flitspalen[i]
            local afstand = #(coords - paal.coords)
            local obj = gespawned[i]

            if afstand < 160.0 then
                if not obj or not DoesEntityExist(obj) then
                    gespawned[i] = spawnPaal(paal)
                end
            elseif obj then
                if DoesEntityExist(obj) then
                    DeleteEntity(obj)
                end
                gespawned[i] = nil
            end
        end

        Wait(1500)
    end
end)

if Config.PlaatsCommando then
    RegisterCommand('flitslocatie', function()
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)
        local regel = ('{ naam = \'Nieuwe paal\', coords = vector3(%.2f, %.2f, %.2f), richting = %.1f, limiet = 50, straal = 18.0 },'):format(
            coords.x, coords.y, coords.z, heading
        )
        print(('[flitspalen] %s'):format(regel))
        TriggerEvent('chat:addMessage', {
            color = { 255, 80, 80 },
            args = { 'Flitspaal', 'Locatie staat in F8. Plak die regel in config.lua.' }
        })
    end, false)
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end
    ruimPalenOp()
end)
