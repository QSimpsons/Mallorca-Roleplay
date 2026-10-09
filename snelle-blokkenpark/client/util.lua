local dui = {}

BP = {
    pending = {},
    propsActive = false,
    entrance = nil,
    nextRequest = 0,
}

function BP.notify(text)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandThefeedPostTicker(false, false)
end

function BP.help(text)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

function BP.headingToForward(heading)
    local rad = math.rad(heading)
    return vector3(-math.sin(rad), math.cos(rad), 0.0)
end

function BP.headingToRight(heading)
    local rad = math.rad(heading)
    return vector3(math.cos(rad), math.sin(rad), 0.0)
end

function BP.flatDistance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

function BP.groundZ(x, y, fallback)
    RequestCollisionAtCoord(x, y, fallback)
    local a, b = GetGroundZFor_3dCoord(x, y, fallback + 30.0, false)
    if type(a) == 'boolean' and a and type(b) == 'number' then
        return b
    end
    if type(a) == 'number' then
        return a
    end
    return fallback
end

function BP.prepareCoords(x, y, z)
    RequestCollisionAtCoord(x, y, z)
    local interior = GetInteriorAtCoords(x, y, z)
    if interior ~= 0 then
        PinInteriorInMemory(interior)
        LoadInterior(interior)
        local timeout = GetGameTimer() + 4000
        while not IsInteriorReady(interior) and GetGameTimer() < timeout do
            Wait(0)
        end
        RefreshInterior(interior)
    end

    NewLoadSceneStart(x, y, z, x, y, z, 40.0, 0)
    local timeout = GetGameTimer() + 4000
    while not IsNewLoadSceneLoaded() and GetGameTimer() < timeout do
        Wait(0)
    end
    NewLoadSceneStop()
end

function BP.rpc(eventName, payload)
    BP.nextRequest = BP.nextRequest + 1
    local id = BP.nextRequest
    local p = promise.new()
    BP.pending[id] = p
    TriggerServerEvent(eventName, id, payload)

    CreateThread(function()
        Wait(5000)
        if BP.pending[id] then
            BP.pending[id]:resolve({ ok = false, message = Config.Messages.timeout })
            BP.pending[id] = nil
        end
    end)

    return Citizen.Await(p)
end

RegisterNetEvent('snelle-blokkenpark:rpcResult', function(id, result)
    local pending = BP.pending[id]
    if not pending then
        return
    end
    BP.pending[id] = nil
    pending:resolve(result or { ok = false, message = Config.Messages.timeout })
end)

function BP.signsReady()
    return dui.ready == true
end

function BP.captureProps(vehicle)
    SetVehicleModKit(vehicle, 0)
    local color1, color2 = GetVehicleColours(vehicle)
    local pearl, wheel = GetVehicleExtraColours(vehicle)
    local nr, ng, nb = GetVehicleNeonLightsColour(vehicle)
    local sr, sg, sb = GetVehicleTyreSmokeColor(vehicle)
    local extras = {}
    local mods = {}

    for i = 0, 16 do
        if DoesExtraExist(vehicle, i) then
            extras[tostring(i)] = IsVehicleExtraTurnedOn(vehicle, i)
        end
    end

    for i = 0, 49 do
        mods[tostring(i)] = GetVehicleMod(vehicle, i)
    end

    local props = {
        model = GetEntityModel(vehicle),
        plate = GetVehicleNumberPlateText(vehicle),
        plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
        bodyHealth = GetVehicleBodyHealth(vehicle),
        engineHealth = GetVehicleEngineHealth(vehicle),
        fuelLevel = GetVehicleFuelLevel(vehicle),
        dirtLevel = GetVehicleDirtLevel(vehicle),
        color1 = color1,
        color2 = color2,
        pearlescentColor = pearl,
        wheelColor = wheel,
        wheels = GetVehicleWheelType(vehicle),
        windowTint = GetVehicleWindowTint(vehicle),
        livery = GetVehicleLivery(vehicle),
        turbo = IsToggleModOn(vehicle, 18),
        xenon = IsToggleModOn(vehicle, 22),
        neonEnabled = {
            IsVehicleNeonLightEnabled(vehicle, 0),
            IsVehicleNeonLightEnabled(vehicle, 1),
            IsVehicleNeonLightEnabled(vehicle, 2),
            IsVehicleNeonLightEnabled(vehicle, 3),
        },
        neonColor = { nr, ng, nb },
        tyreSmokeColor = { sr, sg, sb },
        extras = extras,
        mods = mods,
    }

    if GetIsVehiclePrimaryColourCustom(vehicle) then
        local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
        props.customPrimary = { r, g, b }
    end
    if GetIsVehicleSecondaryColourCustom(vehicle) then
        local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
        props.customSecondary = { r, g, b }
    end

    return props
end

function BP.applyProps(vehicle, props)
    if not props then
        return
    end

    SetVehicleModKit(vehicle, 0)

    if props.plate then
        SetVehicleNumberPlateText(vehicle, props.plate)
    end
    if props.plateIndex then
        SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
    end
    if props.wheels then
        SetVehicleWheelType(vehicle, props.wheels)
    end
    if props.color1 and props.color2 then
        SetVehicleColours(vehicle, props.color1, props.color2)
    end
    if props.pearlescentColor and props.wheelColor then
        SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor)
    end
    if props.customPrimary then
        SetVehicleCustomPrimaryColour(vehicle, props.customPrimary[1], props.customPrimary[2], props.customPrimary[3])
    end
    if props.customSecondary then
        SetVehicleCustomSecondaryColour(vehicle, props.customSecondary[1], props.customSecondary[2], props.customSecondary[3])
    end
    if props.windowTint then
        SetVehicleWindowTint(vehicle, props.windowTint)
    end

    if props.extras then
        for id, enabled in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(id), not enabled)
        end
    end

    if props.mods then
        for modType, modIndex in pairs(props.mods) do
            SetVehicleMod(vehicle, tonumber(modType), modIndex, false)
        end
    end

    ToggleVehicleMod(vehicle, 18, props.turbo == true)
    ToggleVehicleMod(vehicle, 22, props.xenon == true)

    if props.neonEnabled then
        for i = 0, 3 do
            SetVehicleNeonLightEnabled(vehicle, i, props.neonEnabled[i + 1] == true)
        end
    end
    if props.neonColor then
        SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
    end
    if props.tyreSmokeColor then
        ToggleVehicleMod(vehicle, 20, true)
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end
    if props.livery and props.livery >= 0 then
        SetVehicleLivery(vehicle, props.livery)
    end
    if props.dirtLevel then
        SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
    end
    if props.bodyHealth then
        SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
    end
    if props.engineHealth then
        SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
    end
    if props.fuelLevel then
        SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
    end
end

local function drawQuad(p1, p2, p3, p4, txd, txn, r, g, b, flipH)
    local u0, u1 = 0.0, 1.0
    if flipH then
        u0, u1 = 1.0, 0.0
    end

    DrawSpritePoly(
        p1.x, p1.y, p1.z,
        p2.x, p2.y, p2.z,
        p3.x, p3.y, p3.z,
        r, g, b, 255,
        txd, txn,
        u0, 0.0, 0.0,
        u1, 0.0, 0.0,
        u1, 1.0, 0.0
    )
    DrawSpritePoly(
        p1.x, p1.y, p1.z,
        p3.x, p3.y, p3.z,
        p4.x, p4.y, p4.z,
        r, g, b, 255,
        txd, txn,
        u0, 0.0, 0.0,
        u1, 1.0, 0.0,
        u0, 1.0, 0.0
    )
end

function BP.ensureSigns()
    if dui.ready or dui.failed then
        return dui.ready == true
    end
    if dui.pending then
        while not dui.ready and not dui.failed do
            Wait(50)
        end
        return dui.ready == true
    end
    dui.pending = true

    local base = ('nui://%s/html/sign.html'):format(GetCurrentResourceName())
    local park = CreateDui(base .. '?type=park', 1024, 320)
    local parking = CreateDui(base .. '?type=parking', 1024, 320)
    if not park or not parking then
        dui.failed = true
        return false
    end

    local txd = CreateRuntimeTxd('blokkenpark_txd')
    CreateRuntimeTextureFromDuiHandle(txd, 'park', GetDuiHandle(park))
    CreateRuntimeTextureFromDuiHandle(txd, 'parking', GetDuiHandle(parking))
    dui.park = park
    dui.parking = parking
    Wait(700)
    dui.ready = true
    return true
end

function BP.drawSign(center, heading, width, height, kind)
    if not dui.ready then
        return
    end

    local txn = kind == 'parking' and 'parking' or 'park'
    local right = BP.headingToRight(heading) * (width * 0.5)
    local up = vector3(0.0, 0.0, height * 0.5)
    local bl = center - right - up
    local br = center + right - up
    local tl = center - right + up
    local tr = center + right + up

    drawQuad(tl, tr, br, bl, 'blokkenpark_txd', txn, 255, 255, 255, true)
    drawQuad(tr, tl, bl, br, 'blokkenpark_txd', txn, 18, 28, 24, false)
end

function BP.drawText(x, y, z, text)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then
        return
    end
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 220)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(sx, sy)
end

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then
        return
    end
    if dui.park then
        DestroyDui(dui.park)
    end
    if dui.parking then
        DestroyDui(dui.parking)
    end
end)
