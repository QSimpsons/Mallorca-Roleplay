local parked = {}
local displays = {}
local busy = false
local exitLockUntil = 0
local parkingBlip = nil

local function spotById(id)
    for i = 1, #Config.Parking.spots do
        local spot = Config.Parking.spots[i]
        if spot.id == id then
            return spot
        end
    end
end

local function avoided(pos)
    for i = 1, #Config.Parking.avoid do
        local zone = Config.Parking.avoid[i]
        if BP.flatDistance(pos, zone.coords) < zone.radius then
            return true
        end
    end
    return false
end

local function closestNode(anchor)
    local found, node, heading = GetClosestVehicleNodeWithHeading(anchor.x, anchor.y, anchor.z, 1, 3.0, 0)
    if not found or not node then
        found, node, heading = GetClosestVehicleNodeWithHeading(anchor.x, anchor.y, anchor.z, 0, 3.0, 0)
    end
    if not found or not node then
        return nil
    end
    if BP.flatDistance(node, anchor) > 22.0 then
        return nil
    end
    if node.z < 27.0 or node.z > 36.0 then
        return nil
    end
    if avoided(node) then
        return nil
    end
    return vector4(node.x, node.y, node.z, heading or 0.0)
end

local function shift(pos, heading, distance)
    local forward = BP.headingToForward(heading)
    return vector3(pos.x + forward.x * distance, pos.y + forward.y * distance, pos.z)
end

function BP.resolveEntrance()
    if BP.entrance then
        return BP.entrance
    end

    for i = 1, #Config.Parking.candidates do
        local chosen = closestNode(Config.Parking.candidates[i])
        if chosen then
            local outside = shift(chosen, chosen.w, 14.0)
            if avoided(outside) then
                outside = shift(chosen, chosen.w, -14.0)
            end
            BP.entrance = chosen
            BP.outside = vector4(outside.x, outside.y, outside.z, (chosen.w + 180.0) % 360.0)
            print(('[snelle-blokkenpark] Ingang: %.2f, %.2f, %.2f, heading %.1f'):format(
                chosen.x, chosen.y, chosen.z, chosen.w
            ))
            return chosen
        end
    end
end

local function updateBlip()
    local entrance = BP.entrance
    if not entrance then
        return
    end
    if parkingBlip then
        SetBlipCoords(parkingBlip, entrance.x, entrance.y, entrance.z)
        return
    end

    parkingBlip = AddBlipForCoord(entrance.x, entrance.y, entrance.z)
    SetBlipSprite(parkingBlip, Config.Parking.blip.sprite)
    SetBlipColour(parkingBlip, Config.Parking.blip.color)
    SetBlipScale(parkingBlip, Config.Parking.blip.scale)
    SetBlipAsShortRange(parkingBlip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Parking.label)
    EndTextCommandSetBlipName(parkingBlip)
end

local function isInside(pos)
    local interior = Config.Parking.interior
    return pos.z < -50.0 and BP.flatDistance(pos, interior) < 48.0
end

local function clearDisplays()
    for id, veh in pairs(displays) do
        if DoesEntityExist(veh) then
            DeleteEntity(veh)
        end
        displays[id] = nil
    end
end

local function settleVehicle(vehicle)
    local timeout = GetGameTimer() + 2000
    while GetGameTimer() < timeout do
        SetVehicleOnGroundProperly(vehicle)
        if GetEntityHeightAboveGround(vehicle) < 1.6 then
            break
        end
        Wait(50)
    end
end

local function spawnDisplay(entry)
    local spot = spotById(entry.id)
    if not spot or displays[entry.id] then
        return
    end

    local hash = entry.props and entry.props.model
    if not hash or not IsModelInCdimage(hash) then
        return
    end

    local occupied = GetVehiclePedIsIn(PlayerPedId(), false)
    if occupied ~= 0 then
        local occupiedPos = GetEntityCoords(occupied)
        if #(occupiedPos - vector3(spot.coords.x, spot.coords.y, spot.coords.z)) < 4.5 then
            return
        end
    end

    RequestModel(hash)
    local timeout = GetGameTimer() + 4000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(0)
    end
    if not HasModelLoaded(hash) then
        return
    end

    local c = spot.coords
    local veh = CreateVehicle(hash, c.x, c.y, c.z, c.w, false, false)
    if not veh or veh == 0 then
        SetModelAsNoLongerNeeded(hash)
        return
    end

    BP.applyProps(veh, entry.props)
    SetEntityHeading(veh, c.w)
    settleVehicle(veh)
    SetEntityHeading(veh, c.w)
    SetVehicleEngineOn(veh, false, true, true)
    SetVehicleDoorsLocked(veh, 2)
    SetEntityInvincible(veh, true)
    SetVehicleUndriveable(veh, true)
    FreezeEntityPosition(veh, true)
    SetModelAsNoLongerNeeded(hash)
    displays[entry.id] = veh
end

local function refreshDisplays()
    local pos = GetEntityCoords(PlayerPedId())
    if not isInside(pos) then
        clearDisplays()
        return
    end

    local alive = {}
    for i = 1, #parked do
        alive[parked[i].id] = true
        if not displays[parked[i].id] or not DoesEntityExist(displays[parked[i].id]) then
            displays[parked[i].id] = nil
            spawnDisplay(parked[i])
        end
    end

    for id, veh in pairs(displays) do
        if not alive[id] then
            if DoesEntityExist(veh) then
                DeleteEntity(veh)
            end
            displays[id] = nil
        end
    end
end

local function deleteOwnedVehicle(vehicle)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        return true
    end

    local timeout = GetGameTimer() + 1500
    NetworkRequestControlOfEntity(vehicle)
    while not NetworkHasControlOfEntity(vehicle) and GetGameTimer() < timeout do
        NetworkRequestControlOfEntity(vehicle)
        Wait(0)
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
    return not DoesEntityExist(vehicle)
end

local function teleportTo(x, y, z, heading, inVehicle)
    local ped = PlayerPedId()
    local vehicle = inVehicle and GetVehiclePedIsIn(ped, false) or 0

    DoScreenFadeOut(350)
    while not IsScreenFadedOut() do
        Wait(0)
    end

    BP.prepareCoords(x, y, z)
    FreezeEntityPosition(vehicle ~= 0 and vehicle or ped, true)

    if vehicle ~= 0 then
        SetPedCoordsKeepVehicle(ped, x, y, z)
        SetEntityHeading(vehicle, heading)
        settleVehicle(vehicle)
        SetEntityHeading(vehicle, heading)
        SetPedIntoVehicle(ped, vehicle, -1)
    else
        SetEntityCoords(ped, x, y, z, false, false, false, false)
        SetEntityHeading(ped, heading)
    end

    local entity = vehicle ~= 0 and vehicle or ped
    local timeout = GetGameTimer() + 2500
    while not HasCollisionLoadedAroundEntity(entity) and GetGameTimer() < timeout do
        RequestCollisionAtCoord(x, y, z)
        Wait(0)
    end

    FreezeEntityPosition(entity, false)
    exitLockUntil = GetGameTimer() + 2500
    DoScreenFadeIn(350)
end

local function closestSpot(pos, maxDistance)
    local best, bestDist
    for i = 1, #Config.Parking.spots do
        local spot = Config.Parking.spots[i]
        local dist = #(pos - vector3(spot.coords.x, spot.coords.y, spot.coords.z))
        if dist < (bestDist or maxDistance) then
            best = spot
            bestDist = dist
        end
    end
    return best, bestDist
end

local function parkedEntry(id)
    for i = 1, #parked do
        if parked[i].id == id then
            return parked[i]
        end
    end
end

local function tryPark(spot)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then
        BP.notify(Config.Messages.driverOnly)
        return
    end
    if displays[spot.id] and displays[spot.id] == vehicle then
        return
    end

    local class = GetVehicleClass(vehicle)
    if Config.BlockedClasses[class] then
        BP.notify(Config.Messages.blockedClass)
        return
    end

    local props = BP.captureProps(vehicle)
    local result = BP.rpc('snelle-blokkenpark:park', { spotId = spot.id, props = props })
    if not result.ok then
        BP.notify(result.message or Config.Messages.occupied)
        return
    end

    SetEntityAlpha(vehicle, 0, false)
    SetEntityCollision(vehicle, false, false)
    deleteOwnedVehicle(vehicle)
    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    BP.notify(result.message or Config.Messages.parked)
    refreshDisplays()
end

local function tryRetrieve(entry)
    local result = BP.rpc('snelle-blokkenpark:retrieve', { spotId = entry.id })
    if not result.ok then
        BP.notify(result.message or Config.Messages.notYours)
        return
    end

    if displays[entry.id] and DoesEntityExist(displays[entry.id]) then
        DeleteEntity(displays[entry.id])
    end
    displays[entry.id] = nil

    local props = result.props
    local spot = spotById(entry.id)
    local hash = props.model
    RequestModel(hash)
    local timeout = GetGameTimer() + 4000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(0)
    end

    if not HasModelLoaded(hash) then
        BP.rpc('snelle-blokkenpark:restore', { spotId = entry.id, props = props })
        BP.notify(Config.Messages.spawnFailed)
        return
    end

    local c = spot.coords
    local veh = CreateVehicle(hash, c.x, c.y, c.z, c.w, true, true)
    if not veh or veh == 0 then
        SetModelAsNoLongerNeeded(hash)
        BP.rpc('snelle-blokkenpark:restore', { spotId = entry.id, props = props })
        BP.notify(Config.Messages.spawnFailed)
        return
    end

    BP.applyProps(veh, props)
    SetEntityHeading(veh, c.w)
    settleVehicle(veh)
    SetEntityHeading(veh, c.w)
    SetVehicleEngineOn(veh, true, true, false)
    SetModelAsNoLongerNeeded(hash)

    local ped = PlayerPedId()
    SetPedIntoVehicle(ped, veh, -1)
    TriggerServerEvent('snelle-blokkenpark:commitRetrieve')
    if props.fuelLevel then
        pcall(function()
            Entity(veh).state:set('fuel', props.fuelLevel + 0.0, true)
        end)
    end
    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    BP.notify(result.message or Config.Messages.retrieved)
end

RegisterNetEvent('snelle-blokkenpark:sync', function(list)
    parked = list or {}
    refreshDisplays()
end)

RegisterNetEvent('snelle-blokkenpark:tp', function(where)
    if where == 'interior' then
        local foot = Config.Parking.insideFoot
        teleportTo(foot.x, foot.y, foot.z, foot.w, false)
        return
    end
    local center = Config.ParkCenter
    teleportTo(center.x, center.y, center.z, 180.0, false)
end)

CreateThread(function()
    local interior = Config.Parking.interior
    local id = GetInteriorAtCoords(interior.x, interior.y, interior.z)
    if id ~= 0 then
        PinInteriorInMemory(id)
        RefreshInterior(id)
    end

    for _ = 1, 8 do
        if BP.resolveEntrance() then
            break
        end
        Wait(2500)
    end

    if not BP.entrance then
        local fallback = Config.Parking.candidates[1]
        local outside = shift(fallback, 180.0, 14.0)
        BP.entrance = vector4(fallback.x, fallback.y, fallback.z, 180.0)
        BP.outside = vector4(outside.x, outside.y, outside.z, 0.0)
        print('[snelle-blokkenpark] Geen wegpunt gevonden, ingang op de eerste kandidaat.')
    end

    updateBlip()
    if BP.propsActive then
        BP.spawnEntranceKit()
    end

    TriggerServerEvent('snelle-blokkenpark:requestSync')
end)

CreateThread(function()
    while true do
        local waitMs = 800
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local driving = vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped
        local now = GetGameTimer()

        if BP.entrance and pos.z > 10.0 and BP.flatDistance(pos, BP.entrance) < 30.0 then
            waitMs = 0
            local e = BP.entrance
            DrawMarker(36, e.x, e.y, e.z + 0.45, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.1, 1.1, 1.1, 47, 125, 235, 180, false, true, 2, false, nil, nil, false)

            if BP.flatDistance(pos, e) < Config.Parking.enterRadius and now >= exitLockUntil then
                if vehicle ~= 0 and not driving then
                    BP.help(Config.Messages.driverOnly)
                else
                    BP.help(driving and Config.Help.enterVehicle or Config.Help.enterFoot)
                    if IsControlJustReleased(0, 38) and not busy then
                        busy = true
                        CreateThread(function()
                            if driving then
                                local dest = Config.Parking.insideVehicle
                                teleportTo(dest.x, dest.y, dest.z, dest.w, true)
                            else
                                local dest = Config.Parking.insideFoot
                                teleportTo(dest.x, dest.y, dest.z, dest.w, false)
                            end
                            BP.notify(Config.Messages.entered)
                            refreshDisplays()
                            busy = false
                        end)
                    end
                end
            end
        elseif isInside(pos) then
            waitMs = 0
            local exitPos = Config.Parking.insideExit
            DrawMarker(2, exitPos.x, exitPos.y, exitPos.z + 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.45, 0.45, 0.45, 47, 125, 235, 180, false, true, 2, true, nil, nil, false)
            BP.drawText(228.15, -992.0, -98.15, 'BLOKKENPARK  P1')

            if #(pos - exitPos) < Config.Parking.exitRadius and now >= exitLockUntil then
                BP.help(driving and Config.Help.leaveVehicle or Config.Help.leaveFoot)
                if IsControlJustReleased(0, 38) and not busy then
                    if vehicle ~= 0 and not driving then
                        BP.notify(Config.Messages.driverOnly)
                    else
                        busy = true
                        CreateThread(function()
                            local outside = BP.outside or BP.entrance
                            teleportTo(outside.x, outside.y, outside.z, outside.w or 0.0, driving)
                            BP.notify(Config.Messages.left)
                            clearDisplays()
                            busy = false
                        end)
                    end
                end
            end

            local spot = closestSpot(pos, 2.4)
            if spot then
                local entry = parkedEntry(spot.id)
                local c = spot.coords
                local r, g, b = 47, 160, 90
                if entry and not entry.mine then
                    r, g, b = 190, 60, 60
                elseif not entry then
                    r, g, b = 47, 125, 235
                end
                DrawMarker(1, c.x, c.y, c.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.3, 3.4, 0.35, r, g, b, 140, false, false, 2, false, nil, nil, false)

                if not busy then
                    if driving and not entry then
                        BP.help(Config.Help.park)
                        if IsControlJustReleased(0, 38) then
                            busy = true
                            CreateThread(function()
                                tryPark(spot)
                                busy = false
                            end)
                        end
                    elseif not driving and entry and entry.mine and vehicle == 0 then
                        BP.help(Config.Help.retrieve)
                        if IsControlJustReleased(0, 38) then
                            busy = true
                            CreateThread(function()
                                tryRetrieve(entry)
                                busy = false
                            end)
                        end
                    elseif entry and not entry.mine then
                        BP.help(Config.Help.taken)
                    end
                end
            end
        end

        Wait(waitMs)
    end
end)

CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        if isInside(pos) then
            refreshDisplays()
            Wait(1500)
        else
            if next(displays) then
                clearDisplays()
            end
            Wait(2000)
        end
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then
        return
    end
    clearDisplays()
    if parkingBlip then
        RemoveBlip(parkingBlip)
    end
end)

RegisterNetEvent('snelle-blokkenpark:printpos', function()
    local pos = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())
    local line = ('vector4(%.2f, %.2f, %.2f, %.2f)'):format(pos.x, pos.y, pos.z, heading)
    print('[snelle-blokkenpark] ' .. line)
    BP.notify(line)
end)

AddEventHandler('onClientResourceStart', function(name)
    if name ~= GetCurrentResourceName() then
        return
    end
    CreateThread(function()
        Wait(1500)
        TriggerServerEvent('snelle-blokkenpark:requestSync')
    end)
end)
