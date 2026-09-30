if not Framework.ESX() then return end

local ESX = exports["es_extended"]:getSharedObject()
Framework.PlayerData = nil

RegisterNetEvent("esx:playerLoaded", function(xPlayer)
    Framework.PlayerData = xPlayer or ESX.GetPlayerData()
    if not Framework.PlayerData then return end

    client.job = Framework.PlayerData.job
    client.gang = Framework.PlayerData.gang
    client.citizenid = Framework.PlayerData.identifier
    InitAppearance()
end)

RegisterNetEvent("esx:onPlayerLogout", function()
    Framework.PlayerData = nil
end)

RegisterNetEvent("esx:setJob", function(job)
    if not Framework.PlayerData then
        local data = ESX.GetPlayerData()
        if data and data.identifier then
            Framework.PlayerData = data
        end
    end
    if not Framework.PlayerData then return end

    Framework.PlayerData.job = job
    client.job = job
    client.gang = job
end)

local function getRankInputValues(rankList)
    local rankValues = {}
    for _, v in pairs(rankList) do
        rankValues[#rankValues + 1] = {
            label = v.label,
            value = v.grade
        }
    end
    return rankValues
end

function Framework.GetPlayerGender()
    local data = ESX.GetPlayerData()
    if data and (data.sex or data.identifier) then
        Framework.PlayerData = data
    end
    if Framework.PlayerData and Framework.PlayerData.sex == "f" then
        return "Female"
    end
    return "Male"
end

function Framework.UpdatePlayerData()
    local data = ESX.GetPlayerData()
    if data and data.job then
        Framework.PlayerData = data
        client.job = data.job
        client.gang = data.job
        client.citizenid = data.identifier
        return true
    end

    -- PlayerData stays nil until esx:playerLoaded. Callers must not index it.
    return Framework.PlayerData ~= nil
end

function Framework.HasTracker()
    return false
end

function Framework.CheckPlayerMeta()
    local data = ESX.GetPlayerData()
    if not data or not data.identifier then
        return false
    end

    Framework.PlayerData = data
    return data.dead or IsPedCuffed(data.ped)
end

function Framework.IsPlayerAllowed(citizenid)
    return Framework.PlayerData and citizenid == Framework.PlayerData.identifier
end

function Framework.GetRankInputValues(type)
    local jobGrades = lib.callback.await("illenium-appearance:server:esx:getGradesForJob", false, client[type].name)
    return getRankInputValues(jobGrades)
end

function Framework.GetJobGrade()
    return client.job.grade
end

function Framework.GetGangGrade()
    return client.gang.grade
end

function Framework.CachePed()
    ESX.SetPlayerData("ped", cache.ped)
end

function Framework.RestorePlayerArmour()
    return nil
end
