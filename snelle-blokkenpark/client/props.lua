local spawned = {}
local entranceSpawned = {}

local function requestModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelInCdimage(hash) or not IsModelValid(hash) then
        return nil
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 4000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(0)
    end

    if not HasModelLoaded(hash) then
        return nil
    end
    return hash
end

local function spawnObject(model, coords, heading, bucket)
    local hash = requestModel(model)
    if not hash then
        return
    end

    local obj = CreateObjectNoOffset(hash, coords.x, coords.y, coords.z, false, false, false)
    if not obj or obj == 0 then
        SetModelAsNoLongerNeeded(hash)
        return
    end

    SetEntityHeading(obj, heading or 0.0)
    PlaceObjectOnGroundProperly(obj)
    SetEntityHeading(obj, heading or 0.0)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)
    SetEntityLodDist(obj, 220)
    SetModelAsNoLongerNeeded(hash)
    bucket[#bucket + 1] = obj
end

local function deleteBucket(bucket)
    for i = 1, #bucket do
        if DoesEntityExist(bucket[i]) then
            DeleteEntity(bucket[i])
        end
    end
    for i = #bucket, 1, -1 do
        bucket[i] = nil
    end
end

function BP.spawnEntranceKit()
    deleteBucket(entranceSpawned)
    local entrance = BP.entrance
    if not entrance then
        return
    end

    local right = BP.headingToRight(entrance.w)
    local forward = BP.headingToForward(entrance.w)
    local base = vector3(entrance.x, entrance.y, entrance.z)

    local points = {
        { model = 'prop_bollard_02a', offset = right * 3.6 },
        { model = 'prop_bollard_02a', offset = right * -3.6 },
        { model = 'prop_park_ticket_01', offset = right * 4.8 + forward * 1.4, heading = entrance.w },
    }

    for i = 1, #points do
        local point = points[i]
        spawnObject(point.model, base + point.offset, point.heading or entrance.w, entranceSpawned)
    end
end

local function spawnWorld()
    for i = 1, #Config.Props do
        local prop = Config.Props[i]
        spawnObject(prop.model, prop.coords, prop.heading, spawned)
        if i % 4 == 0 then
            Wait(0)
        end
    end
    BP.propsActive = true
    if BP.entrance then
        BP.spawnEntranceKit()
    end
end

local function clearWorld()
    deleteBucket(spawned)
    deleteBucket(entranceSpawned)
    BP.propsActive = false
end

local function nearPark(pos)
    return pos.z > 10.0 and #(pos - Config.ParkCenter) < Config.StreamRadius
end

CreateThread(function()
    local blip = AddBlipForCoord(Config.ParkCenter.x, Config.ParkCenter.y, Config.ParkCenter.z)
    SetBlipSprite(blip, Config.Blip.sprite)
    SetBlipColour(blip, Config.Blip.color)
    SetBlipScale(blip, Config.Blip.scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Blip.label)
    EndTextCommandSetBlipName(blip)

    BP.ensureSigns()

    while true do
        local pos = GetEntityCoords(PlayerPedId())
        if nearPark(pos) and not BP.propsActive then
            spawnWorld()
        elseif not nearPark(pos) and BP.propsActive then
            clearWorld()
        end
        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local waitMs = 1000
        local pos = GetEntityCoords(PlayerPedId())

        if BP.signsReady() and pos.z > 10.0 then
            for i = 1, #Config.Signs do
                local sign = Config.Signs[i]
                local spot = vector3(sign.x, sign.y, pos.z)
                if #(pos - spot) < 45.0 then
                    waitMs = 0
                    local gz = BP.groundZ(sign.x, sign.y, 30.0)
                    BP.drawSign(vector3(sign.x, sign.y, gz + 2.45), sign.heading, sign.width, sign.height, sign.kind)
                end
            end

            if BP.entrance and BP.flatDistance(pos, BP.entrance) < 45.0 then
                waitMs = 0
                local face = (BP.entrance.w + 180.0) % 360.0
                BP.drawSign(
                    vector3(BP.entrance.x, BP.entrance.y, BP.entrance.z + 3.15),
                    face,
                    3.52,
                    1.10,
                    'parking'
                )
            end
        end

        Wait(waitMs)
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then
        return
    end
    clearWorld()
end)
