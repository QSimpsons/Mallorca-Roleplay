local callbackName = "illenium-appearance:server:getAppearance"

local function getAppearance(source, model)
    if type(Framework.GetPlayerID) ~= "function" or type(Framework.GetAppearance) ~= "function" then
        return nil
    end

    local citizenID = Framework.GetPlayerID(source)
    if not citizenID then
        return nil
    end

    return Framework.GetAppearance(citizenID, model)
end

local registered = false

if lib and lib.callback and lib.callback.register then
    local ok, err = pcall(lib.callback.register, callbackName, getAppearance)
    registered = ok

    if not ok then
        print(("^1[illenium-appearance] failed to register %s: %s^0"):format(callbackName, err))
    end
else
    print("^1[illenium-appearance] ox_lib callbacks are unavailable^0")
end

if GetResourceState("ox_lib") == "started" then
    pcall(function()
        exports.ox_lib:setValidCallback(callbackName, true)
    end)
end

if registered then
    return
end

RegisterNetEvent("__ox_cb_" .. callbackName, function(resource, key, ...)
    local src = source
    local ok, appearance = pcall(getAppearance, src, ...)

    if not ok then
        print(("^1[illenium-appearance] %s failed: %s^0"):format(callbackName, appearance))
        TriggerClientEvent("__ox_cb_" .. resource, src, key, false)
        return
    end

    TriggerClientEvent("__ox_cb_" .. resource, src, key, appearance)
end)
