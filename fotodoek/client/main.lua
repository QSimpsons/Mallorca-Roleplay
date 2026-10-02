local doeken = {}
local duiObject = nil
local duiHandle = nil
local txdName = 'fotodoek_txd'
local txnName = 'fotodoek_txn'
local textureReady = false
local nextId = 1

local function notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function brandQuery()
    local b = Config.Brand
    local parts = {
        'title=' .. (b.title or 'ECLIPSE'),
        'subtitle=' .. (b.subtitle or 'ROLEPLAY'),
        'bg=' .. (b.background or '#0b2f7a'):gsub('#', '%%23'),
        'accent=' .. (b.accent or '#3b82f6'):gsub('#', '%%23'),
        'color=' .. (b.textColor or '#ffffff'):gsub('#', '%%23')
    }

    if b.logo and b.logo ~= '' then
        parts[#parts + 1] = 'logo=' .. b.logo
    else
        parts[#parts + 1] = 'logo='
    end

    return table.concat(parts, '&')
end

local function ensureDui()
    if textureReady then
        return true
    end

    local url = ('nui://%s/html/doek.html?%s'):format(GetCurrentResourceName(), brandQuery())
    duiObject = CreateDui(url, Config.DuiBreedte, Config.DuiHoogte)
    if not duiObject then
        return false
    end

    duiHandle = GetDuiHandle(duiObject)
    local txd = CreateRuntimeTxd(txdName)
    CreateRuntimeTextureFromDuiHandle(txd, txnName, duiHandle)

    -- DUI even laten renderen voordat we tekenen
    Wait(600)

    textureReady = true
    return true
end

local function headingToForward(heading)
    local rad = math.rad(heading)
    return vector3(-math.sin(rad), math.cos(rad), 0.0)
end

local function headingToRight(heading)
    local rad = math.rad(heading)
    return vector3(math.cos(rad), math.sin(rad), 0.0)
end

local function drawTexturedQuad(p1, p2, p3, p4, r, g, b, a)
    DrawSpritePoly(
        p1.x, p1.y, p1.z,
        p2.x, p2.y, p2.z,
        p3.x, p3.y, p3.z,
        r, g, b, a,
        txdName, txnName,
        0.0, 0.0, 0.0,
        1.0, 0.0, 0.0,
        1.0, 1.0, 0.0
    )
    DrawSpritePoly(
        p1.x, p1.y, p1.z,
        p3.x, p3.y, p3.z,
        p4.x, p4.y, p4.z,
        r, g, b, a,
        txdName, txnName,
        0.0, 0.0, 0.0,
        1.0, 1.0, 0.0,
        0.0, 1.0, 0.0
    )
end

--- Tekent een textured quad (het doek) rechtop in de wereld.
local function drawCloth(center, heading, width, height)
    local right = headingToRight(heading) * (width * 0.5)
    local up = vector3(0.0, 0.0, height * 0.5)

    local bl = center - right - up
    local br = center + right - up
    local tl = center - right + up
    local tr = center + right + up

    -- Voorkant
    drawTexturedQuad(tl, tr, br, bl, 255, 255, 255, 255)

    -- Achterkant (donkerder, zodat je niet doorheen kijkt)
    drawTexturedQuad(tr, tl, bl, br, 30, 40, 70, 255)
end

--- Vloerdoek: zelfde print ligt plat vóór het frame op de grond.
local function drawFloorCloth(base, heading, width, depth)
    if not Config.VloerDoek or depth <= 0.05 then
        return
    end

    local right = headingToRight(heading)
    local forward = headingToForward(heading)
    local half = width * 0.5
    local z = base.z + (Config.VloerHoogte or 0.018)

    -- Voorkant van het frame = +forward (kant waar je op de foto staat)
    local backLeft = vector3(
        base.x + right.x * (-half),
        base.y + right.y * (-half),
        z
    )
    local backRight = vector3(
        base.x + right.x * half,
        base.y + right.y * half,
        z
    )
    local frontLeft = vector3(
        backLeft.x + forward.x * depth,
        backLeft.y + forward.y * depth,
        z
    )
    local frontRight = vector3(
        backRight.x + forward.x * depth,
        backRight.y + forward.y * depth,
        z
    )

    -- Bovenkant (zichtbaar vanaf boven / schuin)
    drawTexturedQuad(backLeft, backRight, frontRight, frontLeft, 255, 255, 255, 255)
    -- Onderkant (anti z-fighting / doorzicht)
    drawTexturedQuad(backRight, backLeft, frontLeft, frontRight, 40, 55, 90, 220)
end

local function drawSolidQuad(a, b, c, d, r, g, bl, achan)
    DrawPoly(a.x, a.y, a.z, b.x, b.y, b.z, c.x, c.y, c.z, r, g, bl, achan)
    DrawPoly(a.x, a.y, a.z, c.x, c.y, c.z, d.x, d.y, d.z, r, g, bl, achan)
end

--- Dunne metalen balk als box (4 lange vlakken).
local function drawBar(fromPos, toPos, thickness, r, g, bl)
    local dir = toPos - fromPos
    local length = #dir
    if length < 0.001 then
        return
    end

    local forward = dir / length
    local up = vector3(0.0, 0.0, 1.0)
    local right = vector3(
        forward.y * up.z - forward.z * up.y,
        forward.z * up.x - forward.x * up.z,
        forward.x * up.y - forward.y * up.x
    )
    local rightLen = #right
    if rightLen < 0.001 then
        right = vector3(1.0, 0.0, 0.0)
    else
        right = right / rightLen
    end
    up = vector3(
        right.y * forward.z - right.z * forward.y,
        right.z * forward.x - right.x * forward.z,
        right.x * forward.y - right.y * forward.x
    )

    local ht = thickness * 0.5
    local ru = right * ht
    local uu = up * ht

    local f1 = fromPos + ru + uu
    local f2 = fromPos + ru - uu
    local f3 = fromPos - ru - uu
    local f4 = fromPos - ru + uu
    local t1 = toPos + ru + uu
    local t2 = toPos + ru - uu
    local t3 = toPos - ru - uu
    local t4 = toPos - ru + uu

    drawSolidQuad(f1, t1, t2, f2, r, g, bl, 255)
    drawSolidQuad(f2, t2, t3, f3, r, g, bl, 255)
    drawSolidQuad(f3, t3, t4, f4, r, g, bl, 255)
    drawSolidQuad(f4, t4, t1, f1, r, g, bl, 255)
end

--- Zwarte metalen poten + bovenbalk (geen custom props nodig).
local function drawFrame(base, heading, width, height)
    local right = headingToRight(heading)
    local half = width * 0.5
    local dikte = Config.FrameDikte
    local topZ = base.z + Config.GrondOffset + height
    local poleBottom = base.z
    local poleTop = topZ + dikte * 0.35

    local leftFoot = base + right * (-half)
    local rightFoot = base + right * half
    local leftTop = vector3(leftFoot.x, leftFoot.y, poleTop)
    local rightTop = vector3(rightFoot.x, rightFoot.y, poleTop)

    -- Poten
    drawBar(vector3(leftFoot.x, leftFoot.y, poleBottom), leftTop, dikte, 18, 18, 22)
    drawBar(vector3(rightFoot.x, rightFoot.y, poleBottom), rightTop, dikte, 18, 18, 22)
    -- Bovenbalk
    drawBar(leftTop, rightTop, dikte * 1.15, 18, 18, 22)

    -- Voetplaten
    DrawMarker(
        1,
        leftFoot.x, leftFoot.y, base.z,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        dikte * 3.2, dikte * 3.2, 0.04,
        20, 20, 24, 255,
        false, false, 2, false, nil, nil, false
    )
    DrawMarker(
        1,
        rightFoot.x, rightFoot.y, base.z,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        dikte * 3.2, dikte * 3.2, 0.04,
        20, 20, 24, 255,
        false, false, 2, false, nil, nil, false
    )
end

local function clothCenter(entry)
    local h = entry.hoogte or Config.Hoogte
    return vector3(
        entry.coords.x,
        entry.coords.y,
        entry.coords.z + Config.GrondOffset + (h * 0.5)
    )
end

local function addDoek(data)
    local id = data.id and tostring(data.id) or ('l' .. nextId)
    nextId = nextId + 1

    local entry = {
        id = id,
        label = data.label or 'Fotodoek',
        coords = data.coords,
        heading = data.heading or 0.0,
        breedte = data.breedte or Config.Breedte,
        hoogte = data.hoogte or Config.Hoogte,
        persistent = data.persistent == true,
        source = data.source or 'config'
    }

    doeken[#doeken + 1] = entry
    return entry
end

local function removeDoekById(id)
    for i = #doeken, 1, -1 do
        if doeken[i].id == id then
            table.remove(doeken, i)
            return true
        end
    end
    return false
end

local function nearestDoek(maxDist)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local best, bestDist = nil, maxDist or 6.0

    for i = 1, #doeken do
        local d = #(pos - doeken[i].coords)
        if d < bestDist then
            bestDist = d
            best = doeken[i]
        end
    end

    return best, bestDist
end

local function loadConfigDoeken()
    for i = 1, #Config.Doeken do
        local d = Config.Doeken[i]
        addDoek({
            id = 'c' .. i,
            label = d.label or ('Config #' .. i),
            coords = d.coords,
            heading = d.heading or 0.0,
            breedte = d.breedte,
            hoogte = d.hoogte,
            persistent = true,
            source = 'config'
        })
    end
end

CreateThread(function()
    ensureDui()
    loadConfigDoeken()
    TriggerServerEvent('fotodoek:requestSync')
end)

RegisterNetEvent('fotodoek:sync', function(list)
    -- Verwijder eerder gesyncte dynamische doeken
    for i = #doeken, 1, -1 do
        if doeken[i].source == 'dynamic' then
            table.remove(doeken, i)
        end
    end

    if type(list) ~= 'table' then
        return
    end

    for i = 1, #list do
        local d = list[i]
        addDoek({
            id = d.id,
            label = d.label,
            coords = vector3(d.x + 0.0, d.y + 0.0, d.z + 0.0),
            heading = d.heading or 0.0,
            breedte = d.breedte,
            hoogte = d.hoogte,
            persistent = true,
            source = 'dynamic'
        })
    end
end)

RegisterNetEvent('fotodoek:add', function(d)
    if type(d) ~= 'table' then
        return
    end

    removeDoekById(d.id)
    addDoek({
        id = d.id,
        label = d.label,
        coords = vector3(d.x + 0.0, d.y + 0.0, d.z + 0.0),
        heading = d.heading or 0.0,
        breedte = d.breedte,
        hoogte = d.hoogte,
        persistent = true,
        source = 'dynamic'
    })
end)

RegisterNetEvent('fotodoek:remove', function(id)
    removeDoekById(id)
end)

RegisterNetEvent('fotodoek:notify', function(msg)
    notify(msg)
end)

-- Render-loop
CreateThread(function()
    while true do
        local sleep = 750
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        if textureReady and #doeken > 0 then
            for i = 1, #doeken do
                local entry = doeken[i]
                local dist = #(pos - entry.coords)
                if dist < Config.RenderAfstand then
                    sleep = 0
                    local width = entry.breedte or Config.Breedte
                    local height = entry.hoogte or Config.Hoogte
                    local floorDepth = entry.vloerDiepte or Config.VloerDiepte

                    drawFloorCloth(entry.coords, entry.heading, width, floorDepth)
                    drawFrame(entry.coords, entry.heading, width, height)
                    drawCloth(clothCenter(entry), entry.heading, width, height)

                    if Config.Debug then
                        DrawMarker(
                            28,
                            entry.coords.x, entry.coords.y, entry.coords.z + 0.05,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            0.2, 0.2, 0.2,
                            0, 180, 255, 180,
                            false, false, 2, false, nil, nil, false
                        )
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

RegisterCommand(Config.CommandoPlaatsen, function(_, args)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    -- Doek achter je: jij staat er vóór voor de foto
    local heading = (GetEntityHeading(ped) + 180.0) % 360.0
    local label = table.concat(args, ' ')
    if label == '' then
        label = 'Fotodoek'
    end

    -- Klein stukje achteruit zodat je niet in het doek staat
    local forward = headingToForward(GetEntityHeading(ped))
    local place = coords - (forward * 1.6)
    local found, groundZ = GetGroundZFor_3dCoord(place.x, place.y, place.z + 1.0, false)
    if found then
        place = vector3(place.x, place.y, groundZ)
    end

    print(('[fotodoek] { label = %q, coords = vector3(%.2f, %.2f, %.2f), heading = %.1f },'):format(
        label, place.x, place.y, place.z, heading
    ))

    TriggerServerEvent('fotodoek:place', {
        label = label,
        x = place.x,
        y = place.y,
        z = place.z,
        heading = heading,
        breedte = Config.Breedte,
        hoogte = Config.Hoogte
    })
end, false)

RegisterCommand(Config.CommandoVerwijderen, function()
    local entry = nearestDoek(8.0)
    if not entry then
        notify('Geen doek in de buurt.')
        return
    end

    if entry.source == 'config' then
        notify('Dit is een config-doek. Haal hem uit Config.Doeken.')
        return
    end

    TriggerServerEvent('fotodoek:delete', entry.id)
end, false)

RegisterCommand(Config.CommandoLijst, function()
    if #doeken == 0 then
        notify('Er staan geen doeken.')
        return
    end

    print('===== Fotodoeken =====')
    for i = 1, #doeken do
        local d = doeken[i]
        print(('%s | %s | %.1f, %.1f, %.1f | h=%.0f | %s'):format(
            d.id, d.label, d.coords.x, d.coords.y, d.coords.z, d.heading, d.source
        ))
    end
    notify(('Er staan %s doek(en). Zie F8 voor details.'):format(#doeken))
end, false)

TriggerEvent('chat:addSuggestion', '/' .. Config.CommandoPlaatsen, 'Plaats een fotodoek op jouw positie', {
    { name = 'label', help = 'Optionele naam' }
})
TriggerEvent('chat:addSuggestion', '/' .. Config.CommandoVerwijderen, 'Verwijder het dichtstbijzijnde fotodoek')
TriggerEvent('chat:addSuggestion', '/' .. Config.CommandoLijst, 'Toon alle actieve fotodoeken in F8')

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then
        return
    end
    if duiObject then
        DestroyDui(duiObject)
        duiObject = nil
    end
end)
