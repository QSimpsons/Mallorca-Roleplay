AddEventHandler('playerConnecting', function(_, _, deferrals)
    deferrals.handover({
        name = GetPlayerName(source)
    })
end)
