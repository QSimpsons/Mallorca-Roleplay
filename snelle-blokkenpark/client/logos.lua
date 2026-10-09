BP.cubeLogos = {}
BP.logoReady = false

local function atan2(y, x)
    return math.atan(y, x)
end

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

    local logos = {}
    local z = maxZ - 1.2
    while z > 33.0 and #logos < 8 do
        for i = 0, 15 do
            local ang = (i / 16.0) * math.pi * 2.0
            local sx = cx + math.cos(ang) * 26.0
            local sy = cy + math.sin(ang) * 26.0
            local hit = probe(sx, sy, z, cx, cy, z)
            if hit and math.abs(hit.nz) < 0.4 then
                local dx = hit.x - cx
                local dy = hit.y - cy
                if dx * hit.nx + dy * hit.ny > 1.2 and not tooClose(logos, hit.x, hit.y, hit.z, 5.0) then
                    local heading = math.deg(atan2(-hit.nx, hit.ny)) % 360.0
                    logos[#logos + 1] = {
                        x = hit.x + hit.nx * 0.18,
                        y = hit.y + hit.ny * 0.18,
                        z = hit.z,
                        heading = heading,
                        size = 6.2,
                    }
                end
            end
        end
        Wait(0)
        z = z - 3.4
    end

    return logos
end

function BP.drawLogo(center, heading, size)
    if not BP.logoReady then
        return
    end

    local right = BP.headingToRight(heading) * (size * 0.5)
    local up = vector3(0.0, 0.0, size * 0.5)
    local bl = center - right - up
    local br = center + right - up
    local tl = center - right + up
    local tr = center + right + up

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
                print(('[snelle-blokkenpark] %d Eclipse-logo\'s op de blokken gezet.'):format(#found))
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
                    BP.drawLogo(vector3(logo.x, logo.y, logo.z), logo.heading, logo.size)
                end
            end
        end
        Wait(waitMs)
    end
end)
