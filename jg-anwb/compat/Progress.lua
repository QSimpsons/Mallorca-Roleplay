--[[
    ZET DIT BESTAND IN JE BESTAANDE jg-progressbar RESOURCE.

    1. Kopieer dit bestand naar:
       resources/jg-progressbar/Progress.lua
       of:
       resources/jg-progressbar/client/Progress.lua

    2. Open resources/jg-progressbar/fxmanifest.lua

       Zorg dat ox_lib geladen wordt (bovenaan shared_scripts of client_scripts):
         '@ox_lib/init.lua',

       Voeg bij client_scripts deze regel toe:
         'Progress.lua',
       of (als het in de client-map staat):
         'client/Progress.lua',

    3. In de server console:
         ensure ox_lib
         ensure jg-progressbar
         ensure jg-anwb

    Dit maakt de ontbrekende export:
      exports['jg-progressbar']:Progress(data, cb)
]]

local function BuildOxPayload(data)
    data = data or {}
    local disable
    if type(data.controlDisables) == 'table' then
        disable = {
            move = data.controlDisables.disableMovement,
            car = data.controlDisables.disableCarMovement,
            mouse = data.controlDisables.disableMouse,
            combat = data.controlDisables.disableCombat,
        }
    end

    local anim
    if type(data.animation) == 'table' then
        if data.animation.animDict and data.animation.anim then
            anim = {
                dict = data.animation.animDict,
                clip = data.animation.anim,
                flag = data.animation.flags,
            }
        elseif data.animation.scenario then
            anim = { scenario = data.animation.scenario }
        end
    end

    return {
        duration = tonumber(data.duration) or 1000,
        label = data.label or '',
        useWhileDead = data.useWhileDead == true,
        canCancel = data.canCancel ~= false,
        disable = disable,
        anim = anim,
    }
end

local function RunOxProgress(data)
    local payload = BuildOxPayload(data)
    if lib and lib.progressBar then
        return lib.progressBar(payload)
    end
    local ok, result = pcall(function()
        return exports.ox_lib:progressBar(payload)
    end)
    if ok and type(result) == 'boolean' then
        return result
    end
    return nil
end

local function Progress(data, cb)
    data = type(data) == 'table' and data or {}
    CreateThread(function()
        local success = RunOxProgress(data)
        if success == nil then
            Wait(tonumber(data.duration) or 0)
            success = true
        end
        if type(cb) == 'function' then
            cb(not success)
        end
    end)
end

exports('Progress', Progress)
exports('progress', Progress)
