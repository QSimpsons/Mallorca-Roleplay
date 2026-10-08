local models = {
    { spawn = 'aminor', label = 'Minor' },
    { spawn = 'aminorv6', label = 'Minor V6' },
}

CreateThread(function()
    for i = 1, #models do
        AddTextEntry(models[i].spawn, models[i].label)
    end

    Wait(1000)

    local missing = {}

    for i = 1, #models do
        local spawn = models[i].spawn

        if not IsModelInCdimage(GetHashKey(spawn)) then
            missing[#missing + 1] = spawn
        end
    end

    if #missing > 0 then
        print(('[annis-minor] Geen 3D-model voor: %s. Zet de .yft en .ytd in stream/ (zie README).'):format(table.concat(missing, ', ')))
    end
end)
