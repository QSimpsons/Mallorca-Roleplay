local function hasFixPermission(src)
    if src == 0 then
        return true
    end
    return IsPlayerAceAllowed(src, Config.FixAce) or IsPlayerAceAllowed(src, 'command')
end

RegisterCommand('cayofix', function(source)
    if source == 0 then
        print('[snelle-cayo] /cayofix is een client-commando; gebruik het in-game.')
        return
    end

    if not hasFixPermission(source) then
        TriggerClientEvent('chat:addMessage', source, {
            color = { 220, 60, 60 },
            args = { 'Cayo', 'Geen rechten voor /cayofix.' },
        })
        return
    end

    TriggerClientEvent('snelle-cayo:client:fix', source)
end, false)

RegisterCommand('cayostatus', function(source)
    if source == 0 then
        print('[snelle-cayo] resource actief. AlwaysLoaded=' .. tostring(Config.AlwaysLoaded))
        return
    end

    TriggerClientEvent('chat:addMessage', source, {
        color = { 120, 180, 255 },
        args = {
            'Cayo',
            ('Loader actief. AlwaysLoaded=%s LoadDistance=%.0f'):format(
                tostring(Config.AlwaysLoaded),
                Config.LoadDistance
            ),
        },
    })
end, false)

print('[snelle-cayo] Cayo Perico IPL/island hopper geladen.')
