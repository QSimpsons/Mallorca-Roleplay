Server = {}
Server._index = Server

Server.oneSync = GetConvar("onesync", "off")
Server.slots = Config.Slots or 4
Server.prefix = Config.Prefix or "char"
Server.identifierType = ESX.GetConfig("Identifier") or GetConvar("sv_lan", "") == "true" and "ip" or "license"

AddEventHandler("playerConnecting", function(_, _, deferrals)
   local source = source
   Server:OnConnecting(source, deferrals)
end)

RegisterNetEvent("esx_multicharacter:SetupCharacters", function()
    local source = source
    Multicharacter:SetupCharacters(source)
end)

RegisterNetEvent("esx_multicharacter:CharacterChosen", function(charid, isNew)
    local source = source
    Multicharacter:CharacterChosen(source, charid, isNew)
end)

AddEventHandler("esx_identity:completedRegistration", function(source, data)
    Multicharacter:RegistrationComplete(source, data)
end)

local lastSkinSave = {}

AddEventHandler("playerDropped", function()
    local source = source
    lastSkinSave[source] = nil
    Multicharacter:PlayerDropped(source)
end)

RegisterNetEvent("esx_multicharacter:DeleteCharacter", function(charid)
    local source = source
    Multicharacter:DeleteCharacter(source, charid)
end)

local function sanitizeSkin(skin)
    if type(skin) ~= "table" then
        return nil
    end

    local clean = {}
    local count = 0

    for key, value in pairs(skin) do
        count = count + 1

        if count > 120 or type(key) ~= "string" or #key > 40 then
            return nil
        end

        if type(value) == "number" and value == value and value > -100000 and value < 100000 then
            clean[key] = value
        elseif type(value) == "string" and #value <= 64 then
            clean[key] = value
        end
    end

    if clean.tshirt_1 == nil and clean.torso_1 == nil and clean.pants_1 == nil and clean.hair_1 == nil then
        return nil
    end

    return clean
end

RegisterNetEvent("esx_multicharacter:saveSkin", function(skin)
    local src = source
    local now = os.time()

    if lastSkinSave[src] and (now - lastSkinSave[src]) < 10 then
        return
    end

    local xPlayer = ESX.GetPlayerFromId(src)

    if not xPlayer then
        return
    end

    local identifier = xPlayer.identifier

    if not identifier and xPlayer.getIdentifier then
        identifier = xPlayer.getIdentifier()
    end

    if type(identifier) ~= "string" or identifier == "" then
        return
    end

    local cleanSkin = sanitizeSkin(skin)

    if not cleanSkin then
        return
    end

    lastSkinSave[src] = now
    MySQL.update("UPDATE users SET skin = ? WHERE identifier = ?", { json.encode(cleanSkin), identifier })
end)

RegisterNetEvent("esx_multicharacter:relog", function()
    local source = source
    TriggerEvent("esx:playerLogout", source)
end)
