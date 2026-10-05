local localDuty = false
local savedOutfit = nil
local notifications = {}
local femaleHash = (joaat or GetHashKey)('mp_f_freemode_01')

local function isListed(serverId, list)
    list = list or GlobalState.staffzaakOnDuty
    if type(list) ~= 'table' then
        return false
    end
    return list[tostring(serverId)] == true or list[serverId] == true
end

local function playDutySound(onDuty)
    if onDuty then
        PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    else
        PlaySoundFrontend(-1, 'CANCEL', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    end
end

local function restoreOutfit()
    if not savedOutfit then return end

    local ped = PlayerPedId()
    for id, data in pairs(savedOutfit.components) do
        SetPedComponentVariation(ped, id, data.drawable, data.texture, data.palette or 0)
    end
    for id, data in pairs(savedOutfit.props) do
        if data.drawable < 0 then
            ClearPedProp(ped, id)
        else
            SetPedPropIndex(ped, id, data.drawable, data.texture or 0, true)
        end
    end

    savedOutfit = nil
end

local function applyOutfit()
    if not Config.UseOutfit or savedOutfit then return end

    local ped = PlayerPedId()
    local outfit = GetEntityModel(ped) == femaleHash and Config.Outfit.female or Config.Outfit.male
    if type(outfit) ~= 'table' then return end

    local snapshot = { components = {}, props = {} }

    if type(outfit.components) == 'table' then
        for id, data in pairs(outfit.components) do
            if type(id) == 'number' and type(data) == 'table' and type(data.drawable) == 'number' then
                snapshot.components[id] = {
                    drawable = GetPedDrawableVariation(ped, id),
                    texture = GetPedTextureVariation(ped, id),
                    palette = GetPedPaletteVariation(ped, id),
                }
                SetPedComponentVariation(ped, id, data.drawable, data.texture or 0, data.palette or 0)
            end
        end
    end

    if type(outfit.props) == 'table' then
        for id, data in pairs(outfit.props) do
            if type(id) == 'number' and type(data) == 'table' and type(data.drawable) == 'number' then
                snapshot.props[id] = {
                    drawable = GetPedPropIndex(ped, id),
                    texture = GetPedPropTextureIndex(ped, id),
                }
                if data.drawable < 0 then
                    ClearPedProp(ped, id)
                else
                    SetPedPropIndex(ped, id, data.drawable, data.texture or 0, true)
                end
            end
        end
    end

    if next(snapshot.components) or next(snapshot.props) then
        savedOutfit = snapshot
    end
end

local function syncLocalDuty(onDuty, silent)
    onDuty = onDuty == true
    if onDuty == localDuty then return end

    localDuty = onDuty
    if onDuty then
        applyOutfit()
    else
        restoreOutfit()
    end

    if not silent then
        playDutySound(onDuty)
    end
end

local function pushNotify(message, kind)
    notifications[#notifications + 1] = {
        message = message,
        kind = kind or 'info',
        expires = GetGameTimer() + 4500,
    }
    while #notifications > 4 do
        table.remove(notifications, 1)
    end
end

local function drawNotifications()
    local now = GetGameTimer()
    local colors = {
        success = { 18, 92, 58, 210 },
        error = { 122, 36, 36, 210 },
        info = { 22, 28, 46, 210 },
    }
    local index = 0
    local i = 1

    while i <= #notifications do
        local item = notifications[i]
        if item.expires <= now then
            table.remove(notifications, i)
        else
            local color = colors[item.kind] or colors.info
            local y = 0.078 + (index * 0.042)
            DrawRect(0.5, y, 0.34, 0.034, color[1], color[2], color[3], color[4])
            SetTextFont(4)
            SetTextScale(0.30, 0.30)
            SetTextColour(255, 255, 255, 235)
            SetTextCentre(true)
            SetTextOutline()
            SetTextWrap(0.34, 0.66)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName(item.message)
            EndTextCommandDisplayText(0.5, y - 0.011)
            index = index + 1
            i = i + 1
        end
    end

    SetTextWrap(0.0, 1.0)
end

local function drawDutyLabel()
    SetTextFont(4)
    SetTextScale(0.42, 0.42)
    SetTextColour(255, 196, 64, 230)
    SetTextCentre(true)
    SetTextOutline()
    local position = Config.LabelPosition or {}
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(Config.LabelText or 'STAFFDIENST')
    EndTextCommandDisplayText(position.x or 0.5, position.y or 0.025)
end

local function drawText3d(coords, text)
    local onScreen, screenX, screenY = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end

    local distance = #(GetGameplayCamCoords() - coords)
    if distance < 0.5 then distance = 0.5 end

    local scale = (1.0 / distance) * 2.0 * ((1.0 / GetGameplayCamFov()) * 100.0) * 0.35
    if scale > 0.45 then scale = 0.45 end
    if scale < 0.22 then scale = 0.22 end

    local color = Config.TagColor or { 255, 196, 64, 230 }
    SetTextScale(0.0, scale)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(color[1] or 255, color[2] or 196, color[3] or 64, color[4] or 230)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(screenX, screenY)
end

local function tagCoords(ped, fallback)
    local head = GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.30)
    if head.x == 0.0 and head.y == 0.0 and head.z == 0.0 then
        return fallback + vector3(0.0, 0.0, 1.05)
    end
    return head
end

local function addSuggestion()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Ga in of uit staffdienst', {
        { name = 'aan/uit', help = 'Leeg laten wisselt de dienst' },
    })
end

RegisterNetEvent('staffzaak:notify', function(message, kind)
    if type(message) ~= 'string' or message == '' then return end

    local shown = false
    if GetResourceState('ox_lib') == 'started' then
        local ok = pcall(function()
            exports.ox_lib:notify({
                title = 'Staffdienst',
                description = message,
                type = kind == 'error' and 'error' or kind == 'success' and 'success' or 'inform',
            })
        end)
        shown = ok
    end

    if not shown then
        pushNotify(message, kind)
    end

    if Config.ChatMessages then
        local color = { 255, 200, 70 }
        if kind == 'error' then
            color = { 255, 90, 90 }
        elseif kind == 'success' then
            color = { 90, 220, 130 }
        end
        TriggerEvent('chat:addMessage', {
            color = color,
            args = { 'Staffdienst', message },
        })
    end
end)

AddStateBagChangeHandler('staffzaakOnDuty', nil, function(bagName, _, value)
    if bagName ~= 'global' then return end
    syncLocalDuty(isListed(GetPlayerServerId(PlayerId()), value), false)
end)

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(200)
    end

    local myId = GetPlayerServerId(PlayerId())
    while myId == 0 do
        Wait(200)
        myId = GetPlayerServerId(PlayerId())
    end

    -- GlobalState kan net na het joinen binnenkomen. Alleen aanzetten, nooit een echte dienst uitzetten.
    for _ = 1, 8 do
        if isListed(myId) then
            syncLocalDuty(true, true)
            return
        end
        Wait(500)
    end
end)

CreateThread(function()
    while true do
        local waitMs = 750

        if not IsPauseMenuActive() then
            if localDuty then
                waitMs = 0
                drawDutyLabel()
            end

            if #notifications > 0 then
                waitMs = 0
                drawNotifications()
            end

            if Config.ShowTag then
                local dutyMap = GlobalState.staffzaakOnDuty
                local canSee = type(dutyMap) == 'table' and next(dutyMap) ~= nil
                    and (Config.TagVisibility ~= 'staff' or localDuty)

                if canSee then
                    local myPed = PlayerPedId()
                    local myCoords = GetEntityCoords(myPed)
                    local maxDistance = Config.TagDistance or 25.0
                    local myId = PlayerId()

                    for _, player in ipairs(GetActivePlayers()) do
                        if player ~= myId or Config.ShowOwnTag then
                            local serverId = GetPlayerServerId(player)
                            if isListed(serverId, dutyMap) then
                                local ped = GetPlayerPed(player)
                                if ped ~= 0 and DoesEntityExist(ped) then
                                    local coords = GetEntityCoords(ped)
                                    if #(myCoords - coords) <= maxDistance then
                                        waitMs = 0
                                        drawText3d(tagCoords(ped, coords), Config.TagText or 'STAFF')
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end

        Wait(waitMs)
    end
end)

CreateThread(function()
    Wait(500)
    addSuggestion()
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() or resourceName == 'chat' then
        addSuggestion()
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    restoreOutfit()
    TriggerEvent('chat:removeSuggestion', '/' .. Config.Command)
end)

exports('isOnDuty', function()
    return localDuty
end)
