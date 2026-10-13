local API_BASE = 'https://headless.tebex.io/api'
local catalogCache = { at = 0, data = nil, store = nil }
local playerBaskets = {}

local function dbg(...)
    if Config.Debug then
        print('[eclipse-store]', ...)
    end
end

local function hasToken()
    local token = Config.PublicToken
    return type(token) == 'string'
        and token ~= ''
        and token ~= 'YOUR_PUBLIC_TOKEN'
end

local function decodeJson(body)
    if type(body) ~= 'string' or body == '' then
        return nil
    end
    local ok, data = pcall(json.decode, body)
    if ok then
        return data
    end
    return nil
end

local function httpRequest(method, url, body, cb)
    local headers = {
        ['Content-Type'] = 'application/json',
        ['Accept'] = 'application/json',
    }

    PerformHttpRequest(url, function(status, response, _headers)
        dbg(method, url, '->', status)
        cb(status or 0, response or '', decodeJson(response or ''))
    end, method, body and json.encode(body) or '', headers)
end

local function normalizePackage(pkg)
    if type(pkg) ~= 'table' then
        return nil
    end

    local desc = pkg.description or ''
    if type(desc) == 'string' then
        desc = desc:gsub('<[^>]+>', ' '):gsub('%s+', ' '):gsub('^%s+', ''):gsub('%s+$', '')
    end

    return {
        id = pkg.id,
        ident = pkg.ident or tostring(pkg.id),
        name = pkg.name or 'Pakket',
        description = desc,
        total_price = tonumber(pkg.total_price or pkg.base_price) or 0,
        base_price = tonumber(pkg.base_price) or 0,
        currency = pkg.currency or 'EUR',
        image = pkg.image,
        slug = pkg.slug,
        order = pkg.order or 0,
    }
end

local function normalizeCategory(cat)
    if type(cat) ~= 'table' then
        return nil
    end

    local packages = {}
    if type(cat.packages) == 'table' then
        for _, pkg in ipairs(cat.packages) do
            local n = normalizePackage(pkg)
            if n then
                packages[#packages + 1] = n
            end
        end
        table.sort(packages, function(a, b)
            return (a.order or 0) < (b.order or 0)
        end)
    end

    return {
        id = cat.id or cat.slug or cat.name,
        name = cat.name or 'Categorie',
        slug = cat.slug,
        description = cat.description,
        order = cat.order or 0,
        packages = packages,
    }
end

local function uiConfig()
    return {
        storeName = Config.StoreName,
        serverName = Config.ServerName,
        discordUrl = Config.DiscordUrl,
        discordMembers = Config.DiscordMembers,
        banner = Config.Banner,
        newBadgeCategory = Config.NewBadgeCategory,
        storeUrl = Config.StoreUrl,
        hasToken = hasToken(),
    }
end

local function demoPayload()
    local categories = {}
    for _, cat in ipairs(Config.DemoCatalog or {}) do
        categories[#categories + 1] = normalizeCategory(cat)
    end

    return {
        ok = true,
        demo = true,
        store = {
            name = Config.StoreName,
            webstore_url = Config.StoreUrl,
            currency = 'EUR',
            logo = nil,
        },
        categories = categories,
        ui = uiConfig(),
    }
end

local function fetchCatalog(cb)
    if not hasToken() then
        cb(demoPayload())
        return
    end

    local now = os.time()
    if catalogCache.data and (now - catalogCache.at) < (Config.CatalogCacheSeconds or 60) then
        cb({
            ok = true,
            demo = false,
            store = catalogCache.store,
            categories = catalogCache.data,
            ui = uiConfig(),
        })
        return
    end

    local token = Config.PublicToken
    local storeUrl = ('%s/accounts/%s'):format(API_BASE, token)
    local catsUrl = ('%s/accounts/%s/categories?includePackages=1'):format(API_BASE, token)

    httpRequest('GET', storeUrl, nil, function(storeStatus, _body, storeJson)
        local store = {
            name = Config.StoreName,
            webstore_url = Config.StoreUrl,
            currency = 'EUR',
            logo = nil,
        }

        if storeStatus == 200 and storeJson and storeJson.data then
            local d = storeJson.data
            store.name = d.name or store.name
            store.webstore_url = d.webstore_url or store.webstore_url
            store.currency = d.currency or store.currency
            store.logo = d.logo
            store.description = d.description
        end

        httpRequest('GET', catsUrl, nil, function(catStatus, _cbody, catJson)
            if catStatus ~= 200 or not catJson or type(catJson.data) ~= 'table' then
                dbg('catalog failed', catStatus)
                local payload = demoPayload()
                payload.ok = false
                payload.error = 'Kon Tebex-catalogus niet laden. Demo-modus actief.'
                payload.store = store
                payload.ui = uiConfig()
                cb(payload)
                return
            end

            local categories = {}
            for _, cat in ipairs(catJson.data) do
                local n = normalizeCategory(cat)
                if n then
                    categories[#categories + 1] = n
                end
            end
            table.sort(categories, function(a, b)
                return (a.order or 0) < (b.order or 0)
            end)

            catalogCache.at = os.time()
            catalogCache.data = categories
            catalogCache.store = store

            cb({
                ok = true,
                demo = false,
                store = store,
                categories = categories,
                ui = uiConfig(),
            })
        end)
    end)
end

local function getBasketIdent(src)
    return playerBaskets[src]
end

local function setBasketIdent(src, ident)
    playerBaskets[src] = ident
end

local function createBasket(src, cb)
    if not hasToken() then
        cb(false, nil, 'Geen Tebex Public Token gezet in config.lua')
        return
    end

    local token = Config.PublicToken
    local url = ('%s/accounts/%s/baskets'):format(API_BASE, token)
    local license = GetPlayerIdentifierByType and GetPlayerIdentifierByType(src, 'license') or nil

    httpRequest('POST', url, {
        complete_url = Config.AuthReturnUrl,
        cancel_url = Config.StoreUrl,
        complete_auto_redirect = true,
        custom = {
            fivem_source = src,
            license = license,
            name = GetPlayerName(src),
        },
    }, function(status, _body, data)
        if status ~= 200 and status ~= 201 then
            cb(false, nil, 'Kon geen Tebex-winkelwagen aanmaken.')
            return
        end

        local basket = data and (data.data or data) or nil
        if not basket or not basket.ident then
            cb(false, nil, 'Ongeldige basket-response van Tebex.')
            return
        end

        setBasketIdent(src, basket.ident)
        cb(true, basket, nil)
    end)
end

local function ensureBasket(src, cb)
    local ident = getBasketIdent(src)
    if not ident then
        createBasket(src, cb)
        return
    end

    local token = Config.PublicToken
    local url = ('%s/accounts/%s/baskets/%s'):format(API_BASE, token, ident)
    httpRequest('GET', url, nil, function(status, _body, data)
        if status == 200 and data then
            local basket = data.data or data
            if basket and not basket.complete then
                cb(true, basket, nil)
                return
            end
        end
        createBasket(src, cb)
    end)
end

local function addPackageToBasket(ident, packageId, quantity, cb)
    local token = Config.PublicToken
    local body = {
        package_id = packageId,
        quantity = quantity or 1,
    }

    local primary = ('%s/baskets/%s/packages'):format(API_BASE, ident)
    httpRequest('POST', primary, body, function(status, raw, data)
        if status == 200 or status == 201 then
            cb(true, data and (data.data or data) or nil, nil)
            return
        end

        local fallback = ('%s/accounts/%s/%s/packages'):format(API_BASE, token, ident)
        httpRequest('POST', fallback, body, function(status2, _raw2, data2)
            if status2 == 200 or status2 == 201 then
                cb(true, data2 and (data2.data or data2) or nil, nil)
                return
            end
            local detail = (data and data.detail) or (data2 and data2.detail) or raw
            cb(false, nil, detail or 'Pakket toevoegen mislukt.')
        end)
    end)
end

local function removePackageFromBasket(ident, packageId, cb)
    local url = ('%s/baskets/%s/packages/remove'):format(API_BASE, ident)
    httpRequest('POST', url, { package_id = packageId }, function(status, raw, data)
        if status == 200 or status == 201 then
            cb(true, data and (data.data or data) or nil, nil)
            return
        end
        cb(false, nil, (data and data.detail) or raw or 'Verwijderen mislukt.')
    end)
end

local function getAuthLinks(ident, cb)
    local token = Config.PublicToken
    local returnUrl = Config.AuthReturnUrl or Config.StoreUrl or 'https://tebex.io'
    local url = ('%s/accounts/%s/baskets/%s/auth?returnUrl=%s'):format(
        API_BASE,
        token,
        ident,
        returnUrl
    )

    httpRequest('GET', url, nil, function(status, raw, data)
        if status ~= 200 then
            cb(false, nil, raw or 'Auth-links ophalen mislukt.')
            return
        end

        -- response can be a bare array or wrapped
        local links = data
        if type(data) == 'table' and data.data then
            links = data.data
        end
        cb(true, links, nil)
    end)
end

local function basketPayload(basket)
    if type(basket) ~= 'table' then
        return nil
    end

    local packages = {}
    if type(basket.packages) == 'table' then
        for _, pkg in ipairs(basket.packages) do
            packages[#packages + 1] = {
                id = pkg.id,
                ident = pkg.ident or tostring(pkg.id),
                name = pkg.name,
                image = pkg.image,
                quantity = pkg.in_basket and pkg.in_basket.quantity or 1,
                price = pkg.in_basket and pkg.in_basket.price or pkg.total_price or 0,
            }
        end
    end

    return {
        ident = basket.ident,
        username = basket.username,
        complete = basket.complete,
        total_price = basket.total_price or 0,
        currency = basket.currency or 'EUR',
        packages = packages,
        checkout = basket.links and basket.links.checkout or nil,
        authorized = basket.username ~= nil and basket.username ~= '',
    }
end

RegisterNetEvent('eclipse-store:server:getCatalog', function()
    local src = source
    fetchCatalog(function(payload)
        TriggerClientEvent('eclipse-store:client:catalog', src, payload)
    end)
end)

RegisterNetEvent('eclipse-store:server:addToBasket', function(packageIdent)
    local src = source
    if type(packageIdent) ~= 'string' and type(packageIdent) ~= 'number' then
        TriggerClientEvent('eclipse-store:client:basketResult', src, { ok = false, error = 'Ongeldig pakket.' })
        return
    end

    if not hasToken() then
        TriggerClientEvent('eclipse-store:client:basketResult', src, {
            ok = false,
            demo = true,
            error = 'Demo-modus: zet Config.PublicToken om te betalen via Tebex.',
            openUrl = Config.StoreUrl,
        })
        return
    end

    ensureBasket(src, function(ok, basket, err)
        if not ok then
            TriggerClientEvent('eclipse-store:client:basketResult', src, { ok = false, error = err })
            return
        end

        addPackageToBasket(basket.ident, packageIdent, 1, function(okAdd, updated, errAdd)
            if not okAdd then
                TriggerClientEvent('eclipse-store:client:basketResult', src, { ok = false, error = errAdd })
                return
            end
            TriggerClientEvent('eclipse-store:client:basketResult', src, {
                ok = true,
                basket = basketPayload(updated or basket),
            })
        end)
    end)
end)

RegisterNetEvent('eclipse-store:server:removeFromBasket', function(packageIdent)
    local src = source
    local ident = getBasketIdent(src)
    if not ident then
        TriggerClientEvent('eclipse-store:client:basketResult', src, { ok = false, error = 'Geen winkelwagen.' })
        return
    end

    removePackageFromBasket(ident, packageIdent, function(ok, updated, err)
        if not ok then
            TriggerClientEvent('eclipse-store:client:basketResult', src, { ok = false, error = err })
            return
        end
        TriggerClientEvent('eclipse-store:client:basketResult', src, {
            ok = true,
            basket = basketPayload(updated),
        })
    end)
end)

RegisterNetEvent('eclipse-store:server:getBasket', function()
    local src = source
    if not hasToken() then
        TriggerClientEvent('eclipse-store:client:basketResult', src, {
            ok = true,
            demo = true,
            basket = { packages = {}, total_price = 0, currency = 'EUR', authorized = false },
        })
        return
    end

    ensureBasket(src, function(ok, basket, err)
        if not ok then
            TriggerClientEvent('eclipse-store:client:basketResult', src, { ok = false, error = err })
            return
        end
        TriggerClientEvent('eclipse-store:client:basketResult', src, {
            ok = true,
            basket = basketPayload(basket),
        })
    end)
end)

RegisterNetEvent('eclipse-store:server:checkout', function()
    local src = source
    if not hasToken() then
        TriggerClientEvent('eclipse-store:client:openUrl', src, Config.StoreUrl)
        TriggerClientEvent('eclipse-store:client:basketResult', src, {
            ok = true,
            demo = true,
            message = 'Demo-modus: webstore geopend.',
        })
        return
    end

    ensureBasket(src, function(ok, basket, err)
        if not ok then
            TriggerClientEvent('eclipse-store:client:basketResult', src, { ok = false, error = err })
            return
        end

        local payload = basketPayload(basket)
        if not payload or not payload.packages or #payload.packages == 0 then
            TriggerClientEvent('eclipse-store:client:basketResult', src, {
                ok = false,
                error = 'Je winkelwagen is leeg.',
            })
            return
        end

        if not payload.authorized then
            getAuthLinks(basket.ident, function(okAuth, links, errAuth)
                if not okAuth then
                    TriggerClientEvent('eclipse-store:client:basketResult', src, {
                        ok = false,
                        error = errAuth or 'Login bij Tebex mislukt.',
                    })
                    return
                end

                local authUrl = nil
                if type(links) == 'table' then
                    for _, link in ipairs(links) do
                        if type(link) == 'table' and link.url then
                            local name = string.lower(tostring(link.name or ''))
                            if name:find('fivem', 1, true) or name:find('cfx', 1, true) then
                                authUrl = link.url
                                break
                            end
                            authUrl = authUrl or link.url
                        end
                    end
                end

                if not authUrl then
                    TriggerClientEvent('eclipse-store:client:basketResult', src, {
                        ok = false,
                        error = 'Geen Tebex login-link ontvangen.',
                    })
                    return
                end

                TriggerClientEvent('eclipse-store:client:openUrl', src, authUrl)
                TriggerClientEvent('eclipse-store:client:basketResult', src, {
                    ok = true,
                    needsAuth = true,
                    message = 'Log in via de geopende Tebex-pagina en klik daarna opnieuw op Afrekenen.',
                    basket = payload,
                })
            end)
            return
        end

        local checkout = payload.checkout
        if not checkout and basket.links then
            checkout = basket.links.checkout
        end

        if not checkout then
            -- refresh basket for checkout link
            local token = Config.PublicToken
            local url = ('%s/accounts/%s/baskets/%s'):format(API_BASE, token, basket.ident)
            httpRequest('GET', url, nil, function(status, _b, data)
                local fresh = data and (data.data or data) or nil
                local link = fresh and fresh.links and fresh.links.checkout
                if link then
                    TriggerClientEvent('eclipse-store:client:openUrl', src, link)
                    TriggerClientEvent('eclipse-store:client:basketResult', src, {
                        ok = true,
                        message = 'Checkout geopend in je browser.',
                        basket = basketPayload(fresh),
                    })
                else
                    TriggerClientEvent('eclipse-store:client:basketResult', src, {
                        ok = false,
                        error = 'Geen checkout-link beschikbaar. Log eerst in via Tebex.',
                    })
                end
            end)
            return
        end

        TriggerClientEvent('eclipse-store:client:openUrl', src, checkout)
        TriggerClientEvent('eclipse-store:client:basketResult', src, {
            ok = true,
            message = 'Checkout geopend in je browser.',
            basket = payload,
        })
    end)
end)

AddEventHandler('playerDropped', function()
    playerBaskets[source] = nil
end)

CreateThread(function()
    if hasToken() then
        print(('[eclipse-store] Tebex Headless actief (token …%s)'):format(Config.PublicToken:sub(-6)))
    else
        print('[eclipse-store] Geen PublicToken — /store draait in demo-modus. Vul Config.PublicToken in.')
    end
end)