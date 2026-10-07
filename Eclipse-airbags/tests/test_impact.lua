local folder = arg[0]:match('^(.*)/[^/]+$') or '.'
local root = folder:match('^(.*)/tests$') or '.'
dofile(root .. '/shared/impact.lua')

local failures = 0

local function eq(actual, expected, name)
    if actual ~= expected then
        failures = failures + 1
        print('FAIL ' .. name .. ' expected ' .. tostring(expected) .. ' got ' .. tostring(actual))
    end
end

local function close(actual, expected, name)
    if math.abs(actual - expected) > 0.001 then
        failures = failures + 1
        print('FAIL ' .. name .. ' expected ' .. tostring(expected) .. ' got ' .. tostring(actual))
    end
end

local right = Impact.classify(5, 1)
eq(right.side, 'right', 'right side')
eq(right.spread, 0.4, 'tight side spread')

local scrape = Impact.classify(5, 3)
eq(scrape.side, 'right', 'scrape still right')
eq(scrape.spread, 0.95, 'long scrape spread')

local left = Impact.classify(-4, -0.2)
eq(left.side, 'left', 'left side')

local front = Impact.classify(0.2, 6)
eq(front.side, 'front', 'front')

local rear = Impact.classify(0, -3)
eq(rear.side, 'rear', 'rear')

eq(Impact.classify(0, 0), nil, 'no impact')

close(Impact.severityFromDrop(12, 12, 40), 0.2, 'light severity floor')
close(Impact.severityFromDrop(26, 12, 40), 0.5, 'mid severity')
close(Impact.severityFromDrop(80, 12, 40), 1.0, 'heavy severity cap')

local bad = Impact.sanitize({ side = 'up', along = 4 })
eq(bad, nil, 'reject bad side')

local clean = Impact.sanitize({ side = 'left', along = 5, spread = 2, severity = -1 })
eq(clean.side, 'left', 'sanitize side')
close(clean.along, 1.0, 'sanitize along')
close(clean.spread, 1.0, 'sanitize spread')
close(clean.severity, 0.0, 'sanitize severity')

local names = Impact.tyresFor({ side = 'right', along = 0.4, spread = 0.4 }, 0.5, 0.42)
eq(names[1], 'front', 'front tyre')
eq(#names, 1, 'one front tyre')

local rearNames = Impact.tyresFor({ side = 'left', along = -0.4, spread = 0.4 }, 0.5, 0.42)
eq(rearNames[1], 'rear', 'rear tyre')

local none = Impact.tyresFor({ side = 'left', along = 0.4, spread = 0.4 }, 0.3, 0.42)
eq(#none, 0, 'no blowout when light')

local frontTyres = Impact.tyresFor({ side = 'front', along = 0, spread = 0.4 }, 1, 0.42)
eq(#frontTyres, 0, 'front crash is not a side blowout')

local both = Impact.tyresFor({ side = 'left', along = 0, spread = 0.95 }, 0.9, 0.42)
eq(#both, 2, 'hard center hit blows both')

local indexes = Impact.tyreIndexes('left', { 'front', 'rear' })
eq(indexes[1], 0, 'left front index')
eq(indexes[2], 4, 'left rear index')
eq(Impact.tyreIndexes('right', { 'rear' })[1], 5, 'right rear index')

local minDim = { x = -1, y = -2, z = 0 }
local maxDim = { x = 1, y = 2, z = 1.5 }
local dents = Impact.dentOffsets({ side = 'right', along = 0.2, spread = 0.9 }, minDim, maxDim)
eq(#dents >= 2, true, 'side scrape has several dents')
eq(dents[1].x > 0.8, true, 'right dent sits on the right')

local leftDents = Impact.dentOffsets({ side = 'left', along = -0.3, spread = 0.4 }, minDim, maxDim)
eq(leftDents[1].x < -0.8, true, 'left dent sits on the left')

local nose = Impact.dentOffsets({ side = 'front', along = 0, spread = 0.45 }, minDim, maxDim)
eq(nose[1].y > 1.8, true, 'front dent sits on the nose')

local sidePanels = Impact.panels({ side = 'left', along = 0.55, spread = 0.42 })
eq(#sidePanels, 1, 'front-left clip hits one door')
eq(sidePanels[1].door, 0, 'driver door')
eq(sidePanels[1].window, 0, 'driver window')

local rearPanels = Impact.panels({ side = 'right', along = -0.55, spread = 0.42 })
eq(rearPanels[1].door, 3, 'rear right door')

local bothPanels = Impact.panels({ side = 'left', along = 0, spread = 0.95 })
eq(#bothPanels, 2, 'full side hits both doors')

close(Impact.bodyAfter(1000, 1, 280, 450), 720, 'body loss')
close(Impact.bodyAfter(500, 1, 280, 450), 450, 'body floor')
close(Impact.bodyAfter(200, 1, 280, 450), 200, 'body never rises')

eq(Impact.repaired(720, 1000, 40, 950), true, 'repaired after a fix')
eq(Impact.repaired(720, 740, 40, 950), false, 'still broken')
eq(Impact.repaired(150, 1000, 40, 950), true, 'total loss repaired')

if failures > 0 then
    print(failures .. ' failed')
    os.exit(1)
end

print('ok')
