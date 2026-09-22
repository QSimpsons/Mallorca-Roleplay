-- Pure beslissingen, zonder FiveM of database.
-- server/main.lua en tests/test_grant.lua gebruiken dit bestand.

Grant = Grant or {}

function Grant.formatAmount(amount)
    local n = math.floor(tonumber(amount) or 0)
    if n < 0 then n = 0 end
    local s = tostring(n)
    local formatted = s:reverse():gsub('(%d%d%d)', '%1.'):reverse()
    if formatted:sub(1, 1) == '.' then
        formatted = formatted:sub(2)
    end
    return formatted
end

-- char1:license:xxx -> license:xxx wanneer coins één keer per persoon zijn.
function Grant.storageKey(identifier, oncePerCharacter)
    if type(identifier) ~= 'string' or identifier == '' then
        return nil
    end
    if oncePerCharacter == false then
        return (identifier:gsub('^char%d+:', ''))
    end
    return identifier
end

-- opts:
--   alreadyGranted (bool)
--   isNew (true / false / nil)
--   createdAgoSeconds (number / nil)
--   fallbackEnabled (bool)
--   windowSeconds (number)
-- returns: ok, reason
function Grant.shouldGrant(opts)
    opts = opts or {}

    if opts.alreadyGranted then
        return false, 'already'
    end

    if opts.isNew == true then
        return true, 'new_character'
    end

    local recent = false
    if opts.fallbackEnabled and type(opts.createdAgoSeconds) == 'number' and type(opts.windowSeconds) == 'number' then
        recent = opts.createdAgoSeconds >= 0 and opts.createdAgoSeconds <= opts.windowSeconds
    end

    if recent then
        return true, 'recent_character'
    end

    if opts.isNew == false then
        return false, 'existing'
    end

    return false, 'unknown'
end

-- ESX Legacy: (playerId, xPlayer, isNew)
-- Oudere forks geven soms alleen een id, of isNew op een andere plek.
function Grant.normalizeLoaded(a, b, c)
    local src, xPlayer, isNew

    if type(b) == 'table' then
        src = a
        xPlayer = b
        if c == true or c == false then
            isNew = c
        end
    elseif type(a) == 'number' then
        src = a
        if b == true or b == false then
            isNew = b
        end
    end

    if type(src) ~= 'number' then
        src = nil
    end

    return src, xPlayer, isNew
end
