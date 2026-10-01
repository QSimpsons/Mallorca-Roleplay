EclipseOwner = {}

function EclipseOwner.bare(value)
    value = tostring(value or ''):lower()
    value = value:gsub('^char%d+:', '')
    value = value:gsub('^license2?:', '')
    return value
end

function EclipseOwner.same(owner, idents)
    if type(owner) ~= 'string' or owner == '' or type(idents) ~= 'table' then
        return false
    end

    local ownerBare = EclipseOwner.bare(owner)
    if ownerBare == '' then
        return false
    end

    for i = 1, #idents do
        local ident = idents[i]
        if type(ident) == 'string' and ident ~= '' then
            if ident == owner or ident:lower() == owner:lower() or EclipseOwner.bare(ident) == ownerBare then
                return true
            end
        end
    end

    return false
end

function EclipseOwner.unique(list)
    local seen = {}
    local out = {}

    for i = 1, #(list or {}) do
        local value = list[i]
        if type(value) == 'string' and value ~= '' and not seen[value] then
            seen[value] = true
            out[#out + 1] = value
        end
    end

    return out
end
