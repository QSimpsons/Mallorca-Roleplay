if not Framework.ESX() then return end

local client = client
local firstSpawn = false

local function resourceProvided(resourceName)
    local current = GetCurrentResourceName()
    local total = GetNumResourceMetadata(current, "provide") or 0

    for i = 0, total - 1 do
        if GetResourceMetadata(current, "provide", i) == resourceName then
            return true
        end
    end

    return false
end

-- A started skinchanger/esx_skin resource owns those exports and events.
-- `provide` makes GetResourceState follow this resource, so that is not external.
local function externalResource(resourceName)
    if resourceProvided(resourceName) then
        return false
    end

    return GetResourceState(resourceName) ~= "missing"
end

local function readAppearance()
    local ped = cache.ped or PlayerPedId()

    if ped and ped ~= 0 then
        local ok, appearance = pcall(client.getPedAppearance, ped)
        if ok and type(appearance) == "table" then
            return appearance
        end
    end

    if lib and lib.callback and lib.callback.await then
        local ok, appearance = pcall(function()
            return lib.callback.await("illenium-appearance:server:getAppearance", false)
        end)

        if ok and type(appearance) == "table" then
            return appearance
        end
    end

    return {}
end

if not externalResource("esx_skin") then
    AddEventHandler("esx_skin:resetFirstSpawn", function()
        firstSpawn = true
    end)

    AddEventHandler("esx_skin:playerRegistered", function()
        if firstSpawn then
            InitializeCharacter(Framework.GetGender(true))
        end
    end)

    RegisterNetEvent("esx_skin:openSaveableMenu", function(onSubmit, onCancel)
        InitializeCharacter(Framework.GetGender(true), onSubmit, onCancel)
    end)
end

if not externalResource("skinchanger") then
    RegisterNetEvent("skinchanger:loadSkin2", function(ped, skin)
        if not skin.model then skin.model = "mp_m_freemode_01" end
        client.setPedAppearance(ped, skin)
        Framework.CachePed()
    end)

    RegisterNetEvent("skinchanger:getSkin", function(cb)
        if type(cb) == "function" then
            cb(readAppearance())
        end
        Framework.CachePed()
    end)

    local function LoadSkin(skin, cb)
        if type(skin) == "table" and skin.model then
            client.setPlayerAppearance(skin)
        else
            SetInitialClothes(Config.InitialPlayerClothes[Framework.GetGender(true)])
        end
        if Framework.PlayerData and Framework.PlayerData.loadout then
            TriggerEvent("esx:restoreLoadout")
        end
        Framework.CachePed()
        if cb ~= nil then
            cb()
        end
    end

    RegisterNetEvent("skinchanger:loadSkin", function(skin, cb)
        LoadSkin(skin, cb)
    end)

    local function loadClothes(_, clothes)
        local components = Framework.ConvertComponents(clothes, client.getPedComponents(cache.ped))
        local props = Framework.ConvertProps(clothes, client.getPedProps(cache.ped))

        client.setPedComponents(cache.ped, components)
        client.setPedProps(cache.ped, props)
    end

    RegisterNetEvent("skinchanger:loadClothes", function(_, clothes)
        loadClothes(_, clothes)
    end)

    local function exportHandler(exportName, func)
        AddEventHandler(("__cfx_export_skinchanger_%s"):format(exportName), function(setCB)
            if externalResource("skinchanger") then
                return
            end

            setCB(func)
        end)
    end

    exportHandler("GetSkin", function()
        return readAppearance()
    end)

    exportHandler("LoadSkin", function(skin)
        return LoadSkin(skin)
    end)

    exportHandler("LoadClothes", function(playerSkin, clothesSkin)
        return loadClothes(playerSkin, clothesSkin)
    end)
end
