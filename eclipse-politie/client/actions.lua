local function _(key, ...)
    local str = (Locales[Config.Locale] and Locales[Config.Locale][key]) or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

local function requireTarget(action)
    if not IsOnDuty() then
        Notify(_('not_on_duty'), 'error')
        return nil
    end
    if not HasMinGrade(action) then
        Notify(_('no_permission'), 'error')
        return nil
    end
    local target = GetClosestPlayer(2.8)
    if not target then
        Notify(_('player_too_far'), 'error')
        return nil
    end
    return target
end

local function openFineMenu()
    local target = requireTarget('fine')
    if not target then return end

    local options = {}
    for i = 1, #Config.Fines do
        local fine = Config.Fines[i]
        options[#options + 1] = {
            title = fine.label,
            description = fine.custom and 'Voer zelf een bedrag in' or ('€%s'):format(fine.amount),
            onSelect = function()
                if fine.custom then
                    local input = lib.inputDialog(_('fine_title'), {
                        { type = 'number', label = _('fine_amount'), min = 1, max = Config.MaxFine, required = true },
                        { type = 'input', label = _('fine_reason'), required = true },
                    })
                    if not input then return end
                    local amount = tonumber(input[1]) or 0
                    if amount < 1 or amount > Config.MaxFine then
                        Notify(_('invalid_amount'), 'error')
                        return
                    end
                    TriggerServerEvent('eclipse-politie:server:fine', target, amount, input[2])
                else
                    TriggerServerEvent('eclipse-politie:server:fine', target, fine.amount, fine.label)
                end
            end,
        }
    end

    lib.registerContext({
        id = 'politie_fines',
        title = _('fine_title'),
        menu = 'politie_actions',
        options = options,
    })
    lib.showContext('politie_fines')
end

function OpenPoliceActions()
    if not IsOnDuty() then
        Notify(_('not_on_duty'), 'error')
        return
    end

    local options = {
        {
            title = 'ID controleren',
            icon = 'id-card',
            disabled = not HasMinGrade('id'),
            onSelect = function()
                local target = requireTarget('id')
                if target then
                    TriggerServerEvent('eclipse-politie:server:checkId', target)
                end
            end,
        },
        {
            title = 'Boeien / ontboeien',
            icon = 'handcuffs',
            disabled = not HasMinGrade('cuff'),
            onSelect = function()
                local target = requireTarget('cuff')
                if target then
                    TriggerServerEvent('eclipse-politie:server:handcuff', target)
                end
            end,
        },
        {
            title = 'Meeslepen / loslaten',
            icon = 'person-walking',
            disabled = not HasMinGrade('escort'),
            onSelect = function()
                local target = requireTarget('escort')
                if target then
                    TriggerServerEvent('eclipse-politie:server:drag', target)
                end
            end,
        },
        {
            title = 'In voertuig zetten',
            icon = 'car',
            disabled = not HasMinGrade('vehicle'),
            onSelect = function()
                local target = requireTarget('vehicle')
                if target then
                    TriggerServerEvent('eclipse-politie:server:putInVehicle', target)
                end
            end,
        },
        {
            title = 'Uit voertuig halen',
            icon = 'car-side',
            disabled = not HasMinGrade('vehicle'),
            onSelect = function()
                local target = requireTarget('vehicle')
                if target then
                    TriggerServerEvent('eclipse-politie:server:outVehicle', target)
                end
            end,
        },
        {
            title = 'Fouilleren',
            icon = 'magnifying-glass',
            disabled = not HasMinGrade('search'),
            onSelect = function()
                local target = requireTarget('search')
                if target then
                    TriggerServerEvent('eclipse-politie:server:search', target)
                end
            end,
        },
        {
            title = 'Boete uitschrijven',
            icon = 'file-invoice-dollar',
            disabled = not HasMinGrade('fine'),
            onSelect = openFineMenu,
        },
        {
            title = 'Kenteken checken',
            icon = 'car',
            onSelect = function()
                local vehicle = ESX.Game.GetVehicleInDirection()
                if not vehicle or vehicle == 0 then
                    Notify(_('vehicle_too_far'), 'error')
                    return
                end
                local plate = ESX.Math.Trim(GetVehicleNumberPlateText(vehicle))
                Notify(_('radar_plate', plate), 'inform')
                TriggerServerEvent('eclipse-politie:server:checkPlate', plate)
            end,
        },
        {
            title = 'Voertuig inbeslagname',
            icon = 'warehouse',
            disabled = not HasMinGrade('impound'),
            onSelect = function()
                if not HasMinGrade('impound') then
                    Notify(_('no_permission'), 'error')
                    return
                end
                local vehicle = ESX.Game.GetVehicleInDirection()
                if not vehicle or vehicle == 0 then
                    Notify(_('vehicle_too_far'), 'error')
                    return
                end
                if lib.progressCircle({
                    duration = 6000,
                    label = 'Voertuig in beslag nemen...',
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = { move = true, car = true, combat = true },
                    anim = { dict = 'mini@repair', clip = 'fixing_a_player' },
                }) then
                    local props = ESX.Game.GetVehicleProperties(vehicle)
                    TriggerServerEvent('eclipse-politie:server:impound', props)
                    ESX.Game.DeleteVehicle(vehicle)
                    Notify(_('impounded'), 'success')
                end
            end,
        },
    }

    lib.registerContext({
        id = 'politie_actions',
        title = _('actions_menu'),
        options = options,
    })
    lib.showContext('politie_actions')
end

RegisterCommand('politieacties', function()
    OpenPoliceActions()
end, false)

RegisterKeyMapping('politieacties', 'Politie actiemenu', 'keyboard', Config.Keys.actions or 'F6')

-- Zoekresultaat tonen
RegisterNetEvent('eclipse-politie:client:showSearch', function(targetName, inventory)
    local lines = {}
    if type(inventory) == 'table' then
        for i = 1, #inventory do
            local item = inventory[i]
            lines[#lines + 1] = {
                title = ('%s x%s'):format(item.label or item.name, item.count or item.amount or 1),
            }
        end
    end
    if #lines == 0 then
        lines[1] = { title = 'Geen items gevonden' }
    end
    lib.registerContext({
        id = 'politie_search_result',
        title = ('Fouillering: %s'):format(targetName or 'Onbekend'),
        options = lines,
    })
    lib.showContext('politie_search_result')
end)

RegisterNetEvent('eclipse-politie:client:showId', function(data)
    lib.registerContext({
        id = 'politie_id_card',
        title = 'Identiteitsbewijs',
        options = {
            { title = 'Naam', description = data.name or '-' },
            { title = 'Geboortedatum', description = data.dob or '-' },
            { title = 'Geslacht', description = data.sex or '-' },
            { title = 'Lengte', description = tostring(data.height or '-') },
            { title = 'Baan', description = data.job or '-' },
        },
    })
    lib.showContext('politie_id_card')
end)
