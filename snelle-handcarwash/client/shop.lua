local shopPeds = {}
local shopBlips = {}
local shopPoints = {}
local waterPoints = {}

local function shopItemLabel(name)
    return ItemLabel(name)
end

function Handwash.OpenShop()
    if not Config.Shop.enabled then
        return
    end

    local items = Config.Shop.items or {}

    if HasOxLib() and lib.registerContext then
        local options = {}
        for i = 1, #items do
            local item = items[i]
            options[#options + 1] = {
                title = shopItemLabel(item.name),
                description = L('shop_item_desc', item.price),
                icon = 'basket-shopping',
                onSelect = function()
                    Handwash.ServerCallback('snelle-handcarwash:buyItem', function(result)
                        if result and result.ok then
                            Handwash.Notify(L('purchased', shopItemLabel(item.name), item.amount or 1, item.price), 'success')
                        else
                            Handwash.NotifyReason(result and result.reason or 'not_enough_money', result and result.extra)
                        end
                    end, item.name)
                end
            }
        end

        lib.registerContext({
            id = 'snelle_handwash_shop',
            title = L('shop_title'),
            options = options
        })
        lib.showContext('snelle_handwash_shop')
        return
    end

    if ESX and ESX.UI and ESX.UI.Menu then
        local elements = {}
        for i = 1, #items do
            local item = items[i]
            elements[#elements + 1] = {
                label = ('%s - $%s'):format(shopItemLabel(item.name), item.price),
                value = item.name
            }
        end

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'handwash_shop', {
            title = L('shop_title'),
            align = 'top-left',
            elements = elements
        }, function(data, menu)
            Handwash.ServerCallback('snelle-handcarwash:buyItem', function(result)
                if result and result.ok then
                    Handwash.Notify(L('purchased', shopItemLabel(data.current.value), 1, result.price or 0), 'success')
                else
                    Handwash.NotifyReason(result and result.reason or 'not_enough_money', result and result.extra)
                end
            end, data.current.value)
        end, function(_, menu)
            menu.close()
        end)
        return
    end

    Handwash.Notify('Gebruik /handwaskoop [item]  (empty_bucket, car_sponge, car_soap, ...)', 'inform')
end

local function isNearWater()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    if Config.Water.allowNaturalWater and IsEntityInWater(ped) then
        return true
    end

    local maxDist = Config.Water.interactDistance

    for i = 1, #Config.Shops do
        if #(coords - Config.Shops[i].coords) <= (maxDist + 8.0) then
            return true
        end
    end

    for i = 1, #Config.Water.taps do
        if #(coords - Config.Water.taps[i]) <= maxDist then
            return true
        end
    end

    return false
end

function Handwash.TryFillBucket()
    if Handwash.busy then
        Handwash.NotifyReason('busy')
        return
    end

    if not isNearWater() then
        Handwash.NotifyReason('not_near_water')
        return
    end

    Handwash.busy = true
    Handwash.ServerCallback('snelle-handcarwash:canFillBucket', function(result)
        if not result or not result.ok then
            Handwash.busy = false
            Handwash.NotifyReason(result and result.reason or 'need_empty_bucket')
            return
        end

        local ped = PlayerPedId()
        local props = {}
        local filled = false

        if Handwash.LoadAnim('amb@world_human_bum_wash@male@high@base') then
            TaskPlayAnim(ped, 'amb@world_human_bum_wash@male@high@base', 'base', 2.0, 2.0, -1, 49, 0.0, false, false, false)
        else
            TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_BUM_WASH', 0, true)
        end

        local bucket = Handwash.CreateProp(bucketModel, ped, 28422, vector3(0.20, 0.0, -0.12), vector3(-80.0, 0.0, 0.0))
        if bucket then
            props[#props + 1] = bucket
        end

        FreezeEntityPosition(ped, true)

        if GetProgressType() == 'ox_lib' and HasOxLib() and lib.progressBar then
            filled = lib.progressBar({
                duration = Config.Water.fillDuration,
                label = L('filling_bucket'),
                useWhileDead = false,
                canCancel = true,
                disable = { move = true, car = true, combat = true }
            })
        else
            local start = GetGameTimer()
            filled = true
            while GetGameTimer() - start < Config.Water.fillDuration do
                if IsControlJustPressed(0, 73) or IsControlJustPressed(0, 200) then
                    filled = false
                    break
                end
                Wait(0)
            end
        end

        Handwash.ClearProps(props)
        Handwash.StopAnim()

        if not filled then
            Handwash.busy = false
            Handwash.Notify(L('cancelled'), 'error')
            return
        end

        Handwash.ServerCallback('snelle-handcarwash:fillBucket', function(fillResult)
            Handwash.busy = false
            if fillResult and fillResult.ok then
                Handwash.Notify(L('bucket_filled'), 'success')
            else
                Handwash.NotifyReason(fillResult and fillResult.reason or 'need_empty_bucket')
            end
        end)
    end)
end

local function spawnShopPed(shop)
    if not Config.Shop.ped.enabled then
        return nil
    end

    local model = Config.Shop.ped.model
    if not Handwash.LoadModel(model) then
        return nil
    end

    local ped = CreatePed(0, model, shop.coords.x, shop.coords.y, shop.coords.z - 1.0, shop.pedHeading or 0.0, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetPedCanPlayAmbientAnims(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetModelAsNoLongerNeeded(model)

    if Config.Shop.ped.scenario then
        TaskStartScenarioInPlace(ped, Config.Shop.ped.scenario, 0, true)
    end

    return ped
end

local function addShopBlip(shop)
    if not Config.Shop.blip.enabled then
        return
    end

    local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
    SetBlipSprite(blip, Config.Shop.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Shop.blip.scale)
    SetBlipColour(blip, Config.Shop.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Shop.blip.label or L('blip_shop'))
    EndTextCommandSetBlipName(blip)
    shopBlips[#shopBlips + 1] = blip
end

local function registerTargetOnPed(ped)
    local targetType = GetTargetType()
    if targetType == 'ox_target' and HasOxTarget() then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'snelle_handwash_shop',
                icon = 'fa-solid fa-shop',
                label = L('target_shop'),
                distance = Config.Shop.interactDistance,
                onSelect = function()
                    Handwash.OpenShop()
                end
            }
        })
        return
    end

    if targetType == 'qtarget' and HasQTarget() then
        exports.qtarget:AddTargetEntity(ped, {
            options = {
                {
                    icon = 'fas fa-shop',
                    label = L('target_shop'),
                    action = function()
                        Handwash.OpenShop()
                    end
                }
            },
            distance = Config.Shop.interactDistance
        })
    end
end

local function registerWaterTargets()
    local targetType = GetTargetType()
    if targetType ~= 'ox_target' or not HasOxTarget() then
        return
    end

    for i = 1, #Config.Water.taps do
        local id = exports.ox_target:addSphereZone({
            coords = Config.Water.taps[i],
            radius = 1.15,
            debug = Config.Debug,
            options = {
                {
                    name = 'snelle_fill_bucket_' .. i,
                    icon = 'fa-solid fa-fill-drip',
                    label = L('target_water'),
                    distance = Config.Water.interactDistance,
                    onSelect = function()
                        Handwash.TryFillBucket()
                    end
                }
            }
        })
        waterPoints[#waterPoints + 1] = id
    end
end

CreateThread(function()
    local waited = 0
    while GetTargetType() == 'none' and waited < 6000 do
        Wait(250)
        waited = waited + 250
    end

    if Config.Shop.enabled then
        for i = 1, #Config.Shops do
            local shop = Config.Shops[i]
            addShopBlip(shop)
            local ped = spawnShopPed(shop)
            if ped then
                shopPeds[#shopPeds + 1] = ped
                registerTargetOnPed(ped)
            end
            shopPoints[#shopPoints + 1] = shop
        end
    end

    registerWaterTargets()
end)

CreateThread(function()
    local marker = Config.Shop.marker
    local targetType = GetTargetType()
    local useMarkers = targetType == 'none' or not Config.Shop.ped.enabled

    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local showing = false

        if Config.Shop.enabled then
            for i = 1, #shopPoints do
                local shop = shopPoints[i]
                local dist = #(coords - shop.coords)
                if dist < 25.0 then
                    sleep = 0
                    if marker.enabled and (useMarkers or dist > Config.Shop.interactDistance) then
                        DrawMarker(
                            marker.type,
                            shop.coords.x, shop.coords.y, shop.coords.z + 0.15,
                            0.0, 0.0, 0.0,
                            0.0, 0.0, 0.0,
                            marker.size.x, marker.size.y, marker.size.z,
                            marker.color.r, marker.color.g, marker.color.b, marker.color.a,
                            marker.bobUpAndDown, false, 2, marker.rotate, nil, nil, false
                        )
                    end

                    if dist <= Config.Shop.interactDistance then
                        showing = true
                        Handwash.ShowTextUI(L('press_shop'))
                        if IsControlJustReleased(0, 38) then
                            Handwash.OpenShop()
                        end
                    end
                end
            end
        end

        for i = 1, #Config.Water.taps do
            local tap = Config.Water.taps[i]
            local dist = #(coords - tap)
            if dist < 15.0 then
                sleep = 0
                DrawMarker(
                    2,
                    tap.x, tap.y, tap.z + 0.2,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    0.2, 0.2, 0.2,
                    56, 189, 248, 160,
                    false, false, 2, true, nil, nil, false
                )

                if dist <= Config.Water.interactDistance then
                    showing = true
                    Handwash.ShowTextUI(L('press_water'))
                    if IsControlJustReleased(0, 38) then
                        Handwash.TryFillBucket()
                    end
                end
            end
        end

        if Config.Water.allowNaturalWater and IsEntityInWater(ped) and not showing then
            sleep = 0
            showing = true
            Handwash.ShowTextUI(L('press_water'))
            if IsControlJustReleased(0, 38) then
                Handwash.TryFillBucket()
            end
        end

        if not showing then
            Handwash.HideTextUI()
        end

        Wait(sleep)
    end
end)

RegisterCommand('handwaskoop', function(_, args)
    local name = args[1]
    if not name then
        Handwash.OpenShop()
        return
    end

    Handwash.ServerCallback('snelle-handcarwash:buyItem', function(result)
        if result and result.ok then
            Handwash.Notify(L('purchased', shopItemLabel(name), 1, result.price or 0), 'success')
        else
            Handwash.NotifyReason(result and result.reason or 'not_enough_money', result and result.extra)
        end
    end, name)
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for i = 1, #shopPeds do
        if DoesEntityExist(shopPeds[i]) then
            DeleteEntity(shopPeds[i])
        end
    end

    for i = 1, #shopBlips do
        RemoveBlip(shopBlips[i])
    end

    if HasOxTarget() then
        for i = 1, #waterPoints do
            exports.ox_target:removeZone(waterPoints[i])
        end
    end
end)
