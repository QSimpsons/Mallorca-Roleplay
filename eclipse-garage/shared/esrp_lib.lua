--- Local stand-in for esrp_lib.
--- The external `@esrp_lib/init.lua` calls `load()` on a missing file, so the
--- global is never created and client startup dies on the first `esrp_lib.*` use.

esrp_lib = {}

esrp_lib.callback = lib.callback
esrp_lib.cache = cache

function esrp_lib.notify(data)
    local payload = type(data) == 'table' and data or { description = tostring(data) }

    if IsDuplicityVersion() then
        return
    end

    lib.notify({
        id = payload.id,
        title = payload.title,
        description = payload.message or payload.description,
        type = payload.type or 'inform',
        duration = payload.duration,
    })
end

if not IsDuplicityVersion() then
    function esrp_lib.showTextUi(text, options)
        lib.showTextUI(text, options)
    end

    function esrp_lib.hideTextUi()
        lib.hideTextUI()
    end

    function esrp_lib.getVehicleProperties(vehicle)
        return lib.getVehicleProperties(vehicle)
    end

    ---@param data { coords: vector3|vector4|{x:number,y:number,z:number}, sprite: number, color: number, scale: number, text: string, shortRange: boolean }
    function esrp_lib.addBlipForCoords(data)
        local coords = data.coords or {}
        local x = coords.x or coords[1]
        local y = coords.y or coords[2]
        local z = coords.z or coords[3]
        local blip = AddBlipForCoord((x or 0.0) + 0.0, (y or 0.0) + 0.0, (z or 0.0) + 0.0)

        SetBlipSprite(blip, data.sprite or data.id or 1)
        SetBlipColour(blip, data.color or data.colour or 0)
        SetBlipScale(blip, (data.scale or 0.8) + 0.0)
        SetBlipAsShortRange(blip, data.shortRange ~= false)
        SetBlipDisplay(blip, data.display or 4)

        local label = data.text or data.label or data.name
        if label then
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(label)
            EndTextCommandSetBlipName(blip)
        end

        return blip
    end
end

esrp_lib.player = {}

function esrp_lib.player.getIdentifier(playerId)
    if not ESX or not ESX.GetPlayerFromId then
        return nil
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer or not xPlayer.identifier or xPlayer.identifier == '' then
        return nil
    end

    return xPlayer.identifier
end

function esrp_lib.player.getFromId(playerId)
    if not ESX or not ESX.GetPlayerFromId then
        return nil
    end

    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then
        return nil
    end

    local player = {
        source = playerId,
        identifier = xPlayer.identifier,
    }

    function player:removeAccountMoney(account, amount)
        return xPlayer.removeAccountMoney(account, amount)
    end

    return player
end
