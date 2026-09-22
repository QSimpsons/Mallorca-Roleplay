Locales = Locales or {}

function L(key, ...)
    local locale = (Config and Config.Locale) or 'nl'
    local pack = Locales[locale] or Locales['en'] or {}
    local str = pack[key] or (Locales['en'] and Locales['en'][key]) or key

    if select('#', ...) > 0 then
        return string.format(str, ...)
    end

    return str
end
