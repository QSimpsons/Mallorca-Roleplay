Clothing = {}

Clothing.slots = {
    { drawable = "mask_1", texture = "mask_2", kind = "component", id = 1 },
    { drawable = "hair_1", texture = "hair_2", kind = "component", id = 2 },
    { drawable = "arms", texture = "arms_2", kind = "component", id = 3 },
    { drawable = "pants_1", texture = "pants_2", kind = "component", id = 4 },
    { drawable = "bags_1", texture = "bags_2", kind = "component", id = 5 },
    { drawable = "shoes_1", texture = "shoes_2", kind = "component", id = 6 },
    { drawable = "chain_1", texture = "chain_2", kind = "component", id = 7 },
    { drawable = "tshirt_1", texture = "tshirt_2", kind = "component", id = 8 },
    { drawable = "bproof_1", texture = "bproof_2", kind = "component", id = 9 },
    { drawable = "decals_1", texture = "decals_2", kind = "component", id = 10 },
    { drawable = "torso_1", texture = "torso_2", kind = "component", id = 11 },
    { drawable = "helmet_1", texture = "helmet_2", kind = "prop", id = 0 },
    { drawable = "glasses_1", texture = "glasses_2", kind = "prop", id = 1 },
    { drawable = "ears_1", texture = "ears_2", kind = "prop", id = 2 },
    { drawable = "watches_1", texture = "watches_2", kind = "prop", id = 6 },
    { drawable = "bracelets_1", texture = "bracelets_2", kind = "prop", id = 7 },
}

Clothing.byName = {}

for i = 1, #Clothing.slots do
    local slot = Clothing.slots[i]
    Clothing.byName[slot.drawable] = slot
    Clothing.byName[slot.texture] = slot
end

function Clothing.copy(skin)
    local copy = {}

    if type(skin) ~= "table" then
        return copy
    end

    for key, value in pairs(skin) do
        local valueType = type(value)
        if type(key) == "string" and (valueType == "number" or valueType == "string" or valueType == "boolean") then
            copy[key] = value
        end
    end

    return copy
end

function Clothing.compose(base, elements)
    local skin = Clothing.copy(base)

    if type(elements) ~= "table" then
        return skin
    end

    for i = 1, #elements do
        local element = elements[i]
        if type(element) == "table" and type(element.name) == "string" and type(element.value) == "number" then
            skin[element.name] = element.value
        end
    end

    return skin
end

function Clothing.clampTexture(texture, maxTexture)
    texture = math.floor(tonumber(texture) or 0)
    maxTexture = math.floor(tonumber(maxTexture) or 0)

    if maxTexture < 0 then
        maxTexture = 0
    end

    if texture < 0 or texture > maxTexture then
        return 0
    end

    return texture
end

function Clothing.textureMax(ped, slot, drawable)
    drawable = math.floor(tonumber(drawable) or 0)

    local maxTexture
    if slot.kind == "prop" then
        if drawable < 0 then
            return 0
        end
        maxTexture = GetNumberOfPedPropTextureVariations(ped, slot.id, drawable) - 1
    else
        maxTexture = GetNumberOfPedTextureVariations(ped, slot.id, drawable) - 1
    end

    if not maxTexture or maxTexture < 0 then
        return 0
    end

    return maxTexture
end

function Clothing.apply(ped, slot, drawable, texture)
    drawable = math.floor(tonumber(drawable) or 0)
    texture = Clothing.clampTexture(texture, Clothing.textureMax(ped, slot, drawable))

    if slot.kind == "prop" then
        if drawable < 0 then
            ClearPedProp(ped, slot.id)
            return 0
        end

        SetPedPropIndex(ped, slot.id, drawable, texture, true)
        return texture
    end

    SetPedComponentVariation(ped, slot.id, drawable, texture, 2)
    return texture
end
