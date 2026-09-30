local function disablePopulation(bucket)
    local ok = pcall(SetRoutingBucketPopulationEnabled, bucket, false)
    return ok
end

local function bucketsToDisable()
    local buckets = { [0] = true }

    if not Config.DisablePopulationInAllBuckets then
        return buckets
    end

    local playersOk, players = pcall(GetPlayers)
    if not playersOk or type(players) ~= 'table' then
        return buckets
    end

    for _, playerId in ipairs(players) do
        local bucketOk, bucket = pcall(GetPlayerRoutingBucket, playerId)
        if bucketOk and bucket then
            buckets[bucket] = true
        end
    end

    return buckets
end

CreateThread(function()
    while true do
        for bucket in pairs(bucketsToDisable()) do
            disablePopulation(bucket)
        end
        Wait(5000)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    disablePopulation(0)

    if GetConvar('onesync_population', 'true') ~= 'false' then
        print('[geen-npc] Zet in server.cfg ook: set onesync_population false')
    end
end)
