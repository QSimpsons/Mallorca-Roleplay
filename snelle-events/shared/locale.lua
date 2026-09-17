Locales = Locales or {}

function L(key, ...)
    local locale = Config.Locale or 'nl'
    local str = (Locales[locale] and Locales[locale][key]) or (Locales['en'] and Locales['en'][key]) or key

    if select('#', ...) > 0 then
        return string.format(str, ...)
    end

    return str
end

do
    local resource = GetCurrentResourceName()
    local localeFile = LoadResourceFile(resource, ('locales/%s.lua'):format(Config.Locale or 'nl'))
    if localeFile then
        load(localeFile)()
    end

    if Config.Locale ~= 'en' then
        local fallback = LoadResourceFile(resource, 'locales/en.lua')
        if fallback then
            load(fallback)()
        end
    end
end
