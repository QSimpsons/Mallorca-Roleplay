local function _(key, ...)
    local str = (Locales[Config.Locale] and Locales[Config.Locale][key]) or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

function OpenArmory()
    if not IsOnDuty() then
        Notify(_('not_on_duty'), 'error')
        return
    end
    if not HasMinGrade('armory') then
        Notify(_('no_permission'), 'error')
        return
    end

    local grade = GetGrade()
    local options = {}

    options[#options + 1] = {
        title = 'Wapens',
        description = 'Dienstwapens pakken',
        menu = 'politie_armory_weapons',
    }
    options[#options + 1] = {
        title = 'Uitrusting',
        description = 'Items / munitie',
        menu = 'politie_armory_items',
    }
    options[#options + 1] = {
        title = 'Wapens inleveren',
        description = 'Lever je dienstwapens in',
        onSelect = function()
            TriggerServerEvent('eclipse-politie:server:storeWeapons')
        end,
    }

    local weaponOptions = {}
    for i = 1, #Config.Armory.weapons do
        local w = Config.Armory.weapons[i]
        if grade >= w.grade then
            weaponOptions[#weaponOptions + 1] = {
                title = w.label,
                description = ('Rang %s+'):format(w.grade),
                onSelect = function()
                    TriggerServerEvent('eclipse-politie:server:giveWeapon', w.name)
                end,
            }
        end
    end

    local itemOptions = {}
    for i = 1, #Config.Armory.items do
        local it = Config.Armory.items[i]
        if grade >= it.grade then
            itemOptions[#itemOptions + 1] = {
                title = it.label,
                description = ('x%s · Rang %s+'):format(it.count, it.grade),
                onSelect = function()
                    TriggerServerEvent('eclipse-politie:server:giveItem', it.name, it.count)
                end,
            }
        end
    end

    lib.registerContext({
        id = 'politie_armory',
        title = 'Wapenkamer',
        options = options,
    })
    lib.registerContext({
        id = 'politie_armory_weapons',
        title = 'Wapens',
        menu = 'politie_armory',
        options = #weaponOptions > 0 and weaponOptions or { { title = 'Geen wapens beschikbaar' } },
    })
    lib.registerContext({
        id = 'politie_armory_items',
        title = 'Uitrusting',
        menu = 'politie_armory',
        options = #itemOptions > 0 and itemOptions or { { title = 'Geen items beschikbaar' } },
    })

    lib.showContext('politie_armory')
end
