local function _(key, ...)
    local str = (Locales[Config.Locale] and Locales[Config.Locale][key]) or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

local function getUniformForGrade(grade)
    local data = Config.Uniforms[grade] or Config.Uniforms.default
    local sex = (GetEntityModel(PlayerPedId()) == `mp_f_freemode_01`) and 'female' or 'male'
    return data[sex]
end

function OpenCloakroom()
    if not IsOnDuty() then
        Notify(_('not_on_duty'), 'error')
        return
    end

    local options = {
        {
            title = 'Burgerkleding',
            description = 'Terug naar je eigen kleding',
            onSelect = function()
                ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                    TriggerEvent('skinchanger:loadSkin', skin)
                end)
            end,
        },
        {
            title = 'Dienstuniform',
            description = Config.Grades[GetGrade()] and Config.Grades[GetGrade()].label or 'Uniform',
            onSelect = function()
                local uniform = getUniformForGrade(GetGrade())
                if not uniform then return end
                TriggerEvent('skinchanger:getSkin', function(skin)
                    TriggerEvent('skinchanger:loadClothes', skin, uniform)
                end)
            end,
        },
        {
            title = 'Kogelvrij vest aan',
            onSelect = function()
                local sex = (GetEntityModel(PlayerPedId()) == `mp_f_freemode_01`) and 'female' or 'male'
                local vest = Config.Bulletproof[sex]
                TriggerEvent('skinchanger:getSkin', function(skin)
                    TriggerEvent('skinchanger:loadClothes', skin, vest)
                    SetPedArmour(PlayerPedId(), 100)
                end)
            end,
        },
        {
            title = 'Kogelvrij vest uit',
            onSelect = function()
                TriggerEvent('skinchanger:getSkin', function(skin)
                    local empty = { bproof_1 = 0, bproof_2 = 0 }
                    TriggerEvent('skinchanger:loadClothes', skin, empty)
                    SetPedArmour(PlayerPedId(), 0)
                end)
            end,
        },
    }

    lib.registerContext({
        id = 'politie_cloakroom',
        title = _('cloakroom'),
        options = options,
    })
    lib.showContext('politie_cloakroom')
end
