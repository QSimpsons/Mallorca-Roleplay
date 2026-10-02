Skinchanger = {}

local resolvedExports = {}

local function resolveExport(name)
    local cached = resolvedExports[name]
    if cached ~= nil then
        return cached or nil
    end

    local fn
    TriggerEvent(("__cfx_export_skinchanger_%s"):format(name), function(exportFn)
        fn = exportFn
    end)

    resolvedExports[name] = fn or false
    return fn
end

function Skinchanger:GetSkin()
    local fn = resolveExport("GetSkin")
    if fn then
        local ok, skin = pcall(fn)
        if ok and type(skin) == "table" then
            return skin
        end
    end

    local skin
    TriggerEvent("skinchanger:getSkin", function(current)
        skin = current
    end)

    if type(skin) ~= "table" then
        return {}
    end

    return skin
end

function Skinchanger:GetData(noMax)
    local fn = resolveExport("GetData")
    if fn then
        local ok, components, maxValues = pcall(fn, noMax)
        if ok and type(components) == "table" then
            return components, maxValues or {}
        end
    end

    local components, maxValues
    TriggerEvent("skinchanger:getData", function(comps, maxVals)
        components, maxValues = comps, maxVals
    end)

    return components or {}, maxValues or {}
end

function Skinchanger:Change(name, value)
    local fn = resolveExport("Change")
    if fn then
        local ok = pcall(fn, name, value)
        if ok then
            return
        end
    end

    TriggerEvent("skinchanger:change", name, value)
end

function Skinchanger:LoadSkin(skin, cb)
    local fn = resolveExport("LoadSkin")
    if fn then
        local ok = pcall(fn, skin, cb)
        if ok then
            return
        end
    end

    TriggerEvent("skinchanger:loadSkin", skin, cb)
end
