local function applyPauseTitle()
    AddTextEntry('FE_THDR_GTAO', Config.PauseTitle)
end

CreateThread(function()
    applyPauseTitle()
end)

CreateThread(function()
    while true do
        if IsPauseMenuActive() then
            applyPauseTitle()
            Wait(0)
        else
            Wait(500)
        end
    end
end)
