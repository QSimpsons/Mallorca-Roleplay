CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(100)
    end

    SendLoadingScreenMessage(json.encode({
        eventName = 'eclipseShutdown'
    }))

    Wait(2600)
    ShutdownLoadingScreenNui()
end)
