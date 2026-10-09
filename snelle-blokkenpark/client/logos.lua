BP.cubeLogos = {}
BP.logoReady = false

local function probe(x1, y1, z1, x2, y2, z2)
    local handle = StartExpensiveSynchronousShapeTestLosProbe(x1, y1, z1, x2, y2, z2, 1, 0, 7)
    local _, hit, coords, normal = GetShapeTestResult(handle)
    if hit ~= 1 and hit ~= true then
        return nil
    end
    if not coords or not normal then
        return nil
    end
    local len = math.sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z)
    if len < 0.01 then
        return nil
    end
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        nx = normal.x / len,
        ny = normal.y / len,
        nz = normal.z / len,
    }
end

local function probeDown(x, y)
    return probe(x, y, 78.0, x, y, 28.0)
end

local function tooClose(list, x, y, z, gap)
    for i = 1, #list do
        local item = list[i]
        local dx = item.x - x
        local dy = item.y - y
        local dz = item.z - z
        if dx * dx + dy * dy + dz * dz < gap * gap then
            return true
        end
    end
    return false
end

local function horizontalDistance(a, b)
    local dx = a.x - b.x
    local dy = a.y - b.y
    return math.sqrt(dx * dx + dy * dy)
end

-- Alleen de twee buitenhoeken van het rode blok. Het grijze blok erboven blijft leeg.
local function twoRedCorners(faces, maxZ)
    local red = {}
    local ceiling = maxZ - 4.5
    for i = 1, #faces do
        local face = faces[i]
        if face.z < ceiling and face.z > 33.0 then
            red[#red + 1] = face
        end
    end

    if #red < 2 then
        return {}
    end

    local bestI, bestJ, bestD = 1, 2, -1.0
    for i = 1, #red do
        for j = i + 1, #red do
            local gap = horizontalDistance(red[i], red[j])
            if gap > bestD then
                bestD = gap
                bestI = i
                bestJ = j
            end
        end
    end

    if bestD < 4.0 then
        return {}
    end

    return { red[bestI], red[bestJ] }
end

local function scanCubes()
    local tops = {}
    local checks = 0
    for x = 168.0, 248.0, 8.0 do
        for y = -980.0, -860.0, 8.0 do
            local hit = probeDown(x, y)
            if hit and hit.z > 36.0 and hit.z < 62.0 then
                local east = probeDown(x + 2.0, y)
                local north = probeDown(x, y + 2.0)
                if east and north and math.abs(east.z - hit.z) < 1.5 and math.abs(north.z - hit.z) < 1.5 then
                    tops[#tops + 1] = hit
                end
            end
            checks = checks + 1
            if checks % 4 == 0 then
                Wait(0)
            end
        end
    end

    if #tops == 0 then
        return {}
    end

    local cx, cy, maxZ = 0.0, 0.0, 0.0
    for i = 1, #tops do
        cx = cx + tops[i].x
        cy = cy + tops[i].y
        if tops[i].z > maxZ then
            maxZ = tops[i].z
        end
    end
    cx = cx / #tops
    cy = cy / #tops

    -- Het rode blok steekt verder uit dan het grijze blok erboven.
    -- De hoogte met de grootste reikwijdte is dus het rood.
    local bestReach = -1.0
    local bestHits = {}
    local z = maxZ - 1.5
    while z > 33.0 do
        local hits = {}
        local reach = 0.0
        for i = 0, 23 do
            local ang = (i / 24.0) * math.pi * 2.0
            local sx = cx + math.cos(ang) * 22.0
            local sy = cy + math.sin(ang) * 22.0
            local hit = probe(sx, sy, z, cx, cy, z)
            if hit and math.abs(hit.nz) < 0.35 then
                local dx = hit.x - cx
                local dy = hit.y - cy
                local outward = dx * hit.nx + dy * hit.ny
                local dist = math.sqrt(dx * dx + dy * dy)
                if outward > 1.0 and dist > reach then
                    reach = dist
                end
                if outward > 1.0 and not tooClose(hits, hit.x, hit.y, hit.z, 1.6) then
                    hits[#hits + 1] = hit
                end
            end
        end
        if reach > bestReach and #hits >= 2 then
            bestReach = reach
            bestHits = hits
        end
        Wait(0)
        z = z - 1.8
    end

    local chosen = twoRedCorners(bestHits, bestHits[1] and (bestHits[1].z + 4.6) or maxZ)
    local logos = {}
    for i = 1, #chosen do
        local hit = chosen[i]
        local ix = cx - hit.x
        local iy = cy - hit.y
        local along = ix * hit.nx + iy * hit.ny
        ix = ix - hit.nx * along
        iy = iy - hit.ny * along
        local ilen = math.sqrt(ix * ix + iy * iy)
        if ilen > 0.01 then
            ix = ix / ilen
            iy = iy / ilen
        else
            ix, iy = 0.0, 0.0
        end

        logos[#logos + 1] = {
            x = hit.x + ix * 1.35 + hit.nx * 0.12,
            y = hit.y + iy * 1.35 + hit.ny * 0.12,
            z = hit.z,
            nx = hit.nx,
            ny = hit.ny,
            nz = hit.nz,
            size = 2.4,
        }
    end

    return logos
end

function BP.drawLogo(logo)
    if not BP.logoReady then
        return
    end

    local size = logo.size
    local rx = -logo.ny
    local ry = logo.nx
    local rlen = math.sqrt(rx * rx + ry * ry)
    if rlen < 0.01 then
        return
    end
    rx = (rx / rlen) * size * 0.5
    ry = (ry / rlen) * size * 0.5

    local cx = logo.x + logo.nx * 0.08
    local cy = logo.y + logo.ny * 0.08
    local cz = logo.z
    local hz = size * 0.5

    local tl = { x = cx - rx, y = cy - ry, z = cz + hz }
    local tr = { x = cx + rx, y = cy + ry, z = cz + hz }
    local br = { x = cx + rx, y = cy + ry, z = cz - hz }
    local bl = { x = cx - rx, y = cy - ry, z = cz - hz }

    DrawSpritePoly(
        tl.x, tl.y, tl.z,
        tr.x, tr.y, tr.z,
        br.x, br.y, br.z,
        255, 255, 255, 255,
        'eclipse_logo_txd', 'logo',
        1.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0.0, 1.0, 0.0
    )
    DrawSpritePoly(
        tl.x, tl.y, tl.z,
        br.x, br.y, br.z,
        bl.x, bl.y, bl.z,
        255, 255, 255, 255,
        'eclipse_logo_txd', 'logo',
        1.0, 0.0, 0.0,
        0.0, 1.0, 0.0,
        1.0, 1.0, 0.0
    )
end

CreateThread(function()
    local txd = CreateRuntimeTxd('eclipse_logo_txd')
    local tex = CreateRuntimeTextureFromImage(txd, 'logo', 'html/img/logo.png')
    BP.logoReady = tex ~= nil and tex ~= false

    local tries = 0
    while tries < 8 and #BP.cubeLogos == 0 do
        local pos = GetEntityCoords(PlayerPedId())
        if pos.z > 10.0 and #(pos - Config.ParkCenter) < 190.0 then
            tries = tries + 1
            local found = scanCubes()
            if #found > 0 then
                BP.cubeLogos = found
                print('[snelle-blokkenpark] Eclipse-logo op de twee hoeken van het rode blok.')
                break
            end
        end
        Wait(2500)
    end
end)

CreateThread(function()
    while true do
        local waitMs = 1000
        local logos = BP.cubeLogos
        if BP.logoReady and #logos > 0 then
            local pos = GetEntityCoords(PlayerPedId())
            for i = 1, #logos do
                local logo = logos[i]
                if #(pos - vector3(logo.x, logo.y, logo.z)) < 120.0 then
                    waitMs = 0
                    BP.drawLogo(logo)
                end
            end
        end
        Wait(waitMs)
    end
end)
