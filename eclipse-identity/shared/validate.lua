Identity = Identity or {}

local function trim(value)
    local text = tostring(value or '')
    text = text:gsub('^%s+', ''):gsub('%s+$', '')
    text = text:gsub('%s+', ' ')
    return text
end

local function charCount(text)
    local _, count = text:gsub('[^\128-\191]', '')
    return count
end

local function invalidName(name, label, minLength, maxLength)
    local length = charCount(name)
    if length < minLength or length > maxLength then
        return ('%s moet tussen %d en %d tekens zijn.'):format(label, minLength, maxLength)
    end

    if name:find('%d') or name:find('%c') then
        return label .. ' mag alleen letters bevatten.'
    end

    if name:find("[%!%@%#%$%%%^%&%*%(%)%_%+%=%[%]%{%}%|\\%:%;%\"%<%>%?%,%/]") then
        return label .. ' mag alleen letters bevatten.'
    end

    if name:find("^['%-%.]") or name:find("['%-%.]$") then
        return label .. ' is niet geldig.'
    end

    return nil
end

local function parseDate(value)
    local day, month, year = value:match('^(%d%d)[/%-](%d%d)[/%-](%d%d%d%d)$')
    if not day then
        year, month, day = value:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)$')
    end

    day, month, year = tonumber(day), tonumber(month), tonumber(year)
    if not day or not month or not year then
        return nil
    end

    local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    if (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0) then
        days[2] = 29
    end

    if month < 1 or month > 12 or day < 1 or day > days[month] then
        return nil
    end

    return day, month, year
end

local function formatDate(day, month, year, format)
    local dd = ('%02d'):format(day)
    local mm = ('%02d'):format(month)
    local yyyy = ('%04d'):format(year)

    if format == 'MM/DD/YYYY' then
        return ('%s/%s/%s'):format(mm, dd, yyyy)
    end
    if format == 'DD-MM-YYYY' then
        return ('%s-%s-%s'):format(dd, mm, yyyy)
    end
    if format == 'YYYY-MM-DD' then
        return ('%s-%s-%s'):format(yyyy, mm, dd)
    end

    return ('%s/%s/%s'):format(dd, mm, yyyy)
end

function Identity.Validate(data, cfg)
    cfg = cfg or {}

    if type(data) ~= 'table' then
        return false, 'Ongeldige gegevens.'
    end

    if data.rules == false then
        return false, 'Je moet de regels van ECLIPSE RP accepteren.'
    end

    local minLength = cfg.MinNameLength or 2
    local maxLength = cfg.MaxNameLength or 16
    local firstname = trim(data.firstname)
    local lastname = trim(data.lastname)

    local nameError = invalidName(firstname, 'Voornaam', minLength, maxLength)
    if nameError then
        return false, nameError
    end

    nameError = invalidName(lastname, 'Achternaam', minLength, maxLength)
    if nameError then
        return false, nameError
    end

    local day, month, year = parseDate(trim(data.dateofbirth))
    if not day then
        return false, 'Vul een geldige geboortedatum in.'
    end

    local now = os.date('*t')
    local age = now.year - year
    if now.month < month or (now.month == month and now.day < day) then
        age = age - 1
    end

    local minAge = cfg.MinAge or 18
    local maxAge = cfg.MaxAge or 100
    if age < minAge then
        return false, ('Je moet minimaal %d jaar zijn.'):format(minAge)
    end
    if age > maxAge then
        return false, ('De maximale leeftijd is %d jaar.'):format(maxAge)
    end

    local height = tonumber(data.height)
    local minHeight = cfg.MinHeight or 120
    local maxHeight = cfg.MaxHeight or 220
    if not height or height < minHeight or height > maxHeight then
        return false, ('Lengte moet tussen %d en %d cm zijn.'):format(minHeight, maxHeight)
    end

    local sex = tostring(data.sex or ''):lower()
    if sex ~= 'm' and sex ~= 'f' then
        return false, 'Kies een geslacht.'
    end

    return true, {
        firstname = firstname,
        lastname = lastname,
        dateofbirth = formatDate(day, month, year, cfg.DateFormat or 'DD/MM/YYYY'),
        sex = sex,
        height = math.floor(height)
    }
end
