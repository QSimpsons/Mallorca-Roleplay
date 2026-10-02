Menu = {}
Menu._index = Menu

Menu.isOpen = false
Menu.saveable = false
Menu.focusIndex = 1

local function round(value)
    return math.floor((tonumber(value) or 0) + 0.5)
end

local function normalizeNumber(value, fallback)
    value = tonumber(value)
    if not value or value ~= value or value == math.huge or value == -math.huge then
        return fallback
    end

    return value
end

local function normalizeString(value)
    if type(value) ~= "string" or value == "" or #value > 64 then
        return nil
    end

    return value
end

local function wrapValue(value, min, max)
    value = round(value)
    min = round(min)
    max = round(max)

    if max < min then
        max = min
    end

    if value > max then
        return min
    elseif value < min then
        return max
    end

    return value
end

local function safeMax(max)
    max = normalizeNumber(max, 0)
    if max < 0 then
        return 0
    end

    return round(max)
end

local blockedControls = {
    [32] = true, -- Move up only (W)
    [33] = true, -- Move down (S)
    [36] = true, -- Sprint / Multiplayer info
    [21] = true, -- Sprint (alt)
    [37] = true, -- Jump
    [44] = true, -- Cover / duck
    [25] = true, -- Aim
    [24] = true, -- Attack
    [47] = true, -- Switch weapon
    [45] = true, -- Reload
    [14] = true, -- Dodge
    [75] = true, -- Detail
    [73] = true, -- Enter vehicle
    [72] = true, -- Leave vehicle
    [289] = true, -- Secondary interaction
}

local function blockInputThread()
    while Menu.isOpen do
        for control, _ in pairs(blockedControls) do
            DisableControlAction(0, control, true)
            DisableControlAction(1, control, true)
            DisableControlAction(2, control, true)
        end
        Wait(0)
    end
end

local function createMenuHandle()
    return {
        close = function()
            Menu:Close()
        end,
        update = function(_, element)
            if type(element) == "table" and element.name then
                Menu:UpdateElement(element.name, element)
            end
        end,
        refresh = function()
            Menu:Refresh()
        end
    }
end

function Menu:FindElementIndex(name)
    if not name or not self.elements then
        return nil
    end

    for i = 1, #self.elements do
        if self.elements[i].name == name then
            return i
        end
    end

    return nil
end

function Menu:GetElement(name)
    local index = self:FindElementIndex(name)
    return index and self.elements[index] or nil
end

function Menu:Restrict()
    local _components = {}

    for i = 1, #self.components, 1 do
        local found = false

        for j = 1, #self.restricted, 1 do
            if self.components[i].name == self.restricted[j] then
                found = true
                break
            end
        end

        if found then
            _components[#_components + 1] = self.components[i]
        end
    end

    return _components
end

function Menu:InsertElements()
    local playerPed = PlayerPedId()
    local currentSkin = Skinchanger:GetSkin()

    self.elements = {}
    for i = 1, #self.components, 1 do
        local component = self.components[i]
        local value = currentSkin[component.name]

        if value == nil then
            value = component.value
        end

        if component.componentId == 0 and component.name == "helmet_1" then
            value = GetPedPropIndex(playerPed, component.componentId)
        end

        local data = table.clone(component)
        data.value = round(value)
        data.type = "slider"
        data.min = normalizeNumber(data.min, 0)
        data.max = safeMax(self.maxValues and self.maxValues[component.name] or data.max)

        if data.max < data.min then
            data.max = data.min
        end

        data.value = wrapValue(data.value, data.min, data.max)
        self.elements[#self.elements + 1] = data
    end
end

function Menu:BuildPayload(activeName)
    local submitLabel = "CONFIRM"

    if self.saveable and self.creating then
        submitLabel = "CREATE CHARACTER"
    elseif self.saveable then
        submitLabel = "SAVE CHANGES"
    end

    return {
        action = "skinMenu:open",
        title = TranslateCap("skin_menu"),
        submitLabel = submitLabel,
        active = activeName or (self.elements[1] and self.elements[1].name) or nil,
        elements = self.elements or {},
        saveable = self.saveable == true,
        creating = self.creating == true,
        restricted = self.restricted ~= nil
    }
end

function Menu:Refresh(activeName)
    if not self.isOpen then
        return
    end

    SendNUIMessage(self:BuildPayload(activeName))
end

function Menu:UpdateElement(name, element)
    local index = self:FindElementIndex(name)
    if not index then
        return
    end

    self.elements[index] = element
end

function Menu:Close()
    if self.isOpen then
        SendNUIMessage({ action = "skinMenu:close" })
    end

    SetNuiFocus(false, false)
    SetNuiFocusKeepInput(false)
    Camera:Destroy()

    self.isOpen = false
end

function Menu:Submit(data)
    if not self.isOpen then
        return
    end

    local current = self:GetElement(type(data) == "table" and data.name or nil) or self.elements[self.focusIndex] or self.elements[1]
    local payload = {
        current = current,
        elements = self.elements
    }
    local skin = self:CollectSkin()
    local submitCb = self.submitCb

    self:Close()
    self:Persist(skin, function()
        if submitCb then
            submitCb(payload, createMenuHandle())
        end
    end)
end

function Menu:Cancel(data)
    if not self.isOpen then
        return
    end

    local current = self:GetElement(type(data) == "table" and data.name or nil) or self.elements[self.focusIndex] or self.elements[1]
    local payload = {
        current = current,
        elements = self.elements
    }

    self:Close()

    if Skin.Last then
        local previous = Clothing.copy(Skin.Last)
        Skinchanger:LoadSkin(previous)
        self:ApplyWornClothes(previous)
    end

    if self.cancelCb then
        self.cancelCb(payload, createMenuHandle())
    end
end

function Menu:RebuildAfterModelChange(activeName)
    SetTimeout(450, function()
        if not self.isOpen then
            return
        end

        self.components, self.maxValues = Skinchanger:GetData()
        if self.restricted then
            self.components = self:Restrict()
        end
        self:InsertElements()
        self:Refresh(activeName)
    end)
end

function Menu:CollectSkin()
    return Clothing.compose(Skinchanger:GetSkin(), self.elements)
end

function Menu:ApplyWornClothes(skin)
    local ped = PlayerPedId()

    for i = 1, #Clothing.slots do
        local slot = Clothing.slots[i]
        if skin[slot.drawable] ~= nil then
            local texture = Clothing.apply(ped, slot, skin[slot.drawable], skin[slot.texture] or 0)
            skin[slot.texture] = texture

            local textureElement = self:GetElement(slot.texture)
            if textureElement then
                textureElement.value = texture
                textureElement.max = Clothing.textureMax(ped, slot, skin[slot.drawable])
            end
        end
    end
end

function Menu:CommitComponent(name, value, skin)
    skin[name] = value
    Skinchanger:Change(name, value)

    local slot = Clothing.byName[name]
    if not slot or skin[slot.drawable] == nil then
        return
    end

    local ped = PlayerPedId()
    local texture = Clothing.apply(ped, slot, skin[slot.drawable], skin[slot.texture] or 0)
    local maxTexture = Clothing.textureMax(ped, slot, skin[slot.drawable])
    skin[slot.texture] = texture

    if skin[slot.texture] ~= value or name ~= slot.texture then
        Skinchanger:Change(slot.texture, texture)
    end

    local textureElement = self:GetElement(slot.texture)
    if textureElement then
        textureElement.value = texture
        textureElement.max = maxTexture
    end
end

function Menu:Persist(skin, done)
    self:ApplyWornClothes(skin)
    Skinchanger:LoadSkin(Clothing.copy(skin))
    self:ApplyWornClothes(skin)
    Skin.Last = Clothing.copy(skin)

    local finished = false
    local function finish()
        if finished then
            return
        end

        finished = true
        if done then
            done()
        end
    end

    TriggerServerEvent("esx_skin:save", skin)

    local invoked = xLib and xLib.callback and pcall(function()
        xLib.callback("esx_skin:saveSkin", false, function()
            finish()
        end, skin)
    end)

    if not invoked then
        finish()
        return
    end

    SetTimeout(1500, finish)
end

function Menu:UpdateTextureLimits(changedName, skin)
    if Clothing.byName[changedName] then
        return
    end

    for i = 1, #self.elements, 1 do
        local element = self.elements[i]

        if element.textureof == changedName then
            local component = self:FindComponent(element.name)

            if component and ESX.IsFunctionReference(component.max) then
                element.max = safeMax(component.max(PlayerPedId(), skin))
            end

            local current = element.value

            if current == nil or current < (element.min or 0) or current > element.max or (element.max or 0) < (element.min or 0) then
                current = wrapValue(element.min or 0, element.min or 0, element.max or 0)
            end

            element.value = current
            self:CommitComponent(element.name, element.value, skin)
        end
    end
end

function Menu:FindComponent(name)
    if not name or not self.components then
        return nil
    end

    for i = 1, #self.components do
        if self.components[i].name == name then
            return self.components[i]
        end
    end

    return nil
end

function Menu:Focus(data)
    local name = normalizeString(type(data) == "table" and data.name or nil)
    local index = self:FindElementIndex(name)
    if not index then
        return
    end

    self.focusIndex = index
    local element = self.elements[index]
    Skin.zoomOffset = normalizeNumber(element.zoomOffset, Skin.zoomOffset)
    Skin.camOffset = normalizeNumber(element.camOffset, Skin.camOffset)
end

function Menu:Apply(values)
    if not self.isOpen or type(values) ~= "table" then
        return
    end

    local skin = Skinchanger:GetSkin()
    local changedNames = {}

    for name, value in pairs(values) do
        if type(name) == "string" and type(value) == "number" and value == value then
            local element = self:GetElement(name)

            if element then
                local normalized = wrapValue(value, element.min or 0, element.max or 0)
                element.value = normalized
                self:CommitComponent(name, normalized, skin)
                changedNames[#changedNames + 1] = name
            end
        end
    end

    if #changedNames < 1 then
        return
    end

    local changedSex = false
    for i = 1, #changedNames, 1 do
        if changedNames[i] == "sex" then
            changedSex = true
            break
        end
    end

    if changedSex then
        self:RebuildAfterModelChange(self.elements[1] and self.elements[1].name or nil)
    else
        for i = 1, #changedNames, 1 do
            self:UpdateTextureLimits(changedNames[i], skin)
        end

        self:Refresh(self.elements[1] and self.elements[1].name or nil)
    end
end

function Menu:Change(data)
    if not self.isOpen or type(data) ~= "table" then
        return
    end

    local name = normalizeString(data.name)
    local element = self:GetElement(name)
    if not element then
        return
    end

    local value = wrapValue(data.value, element.min or 0, element.max or 0)
    element.value = value

    self:Focus({ name = name })

    local skin = Skinchanger:GetSkin()
    self:CommitComponent(name, value, skin)

    if name == "sex" then
        self:RebuildAfterModelChange(name)
    elseif not element.textureof then
        self:UpdateTextureLimits(name, skin)
    end

    self:Refresh(name)
end

function Menu:Reset()
    if not self.isOpen or not Skin.Last then
        return
    end

    Skinchanger:LoadSkin(Clothing.copy(Skin.Last), function()
        self.components, self.maxValues = Skinchanger:GetData()
        if self.restricted then
            self.components = self:Restrict()
        end
        self:InsertElements()
        self:Refresh(self.elements[1] and self.elements[1].name or nil)
    end)
end

function Menu:Rotate(direction)
    direction = direction == "left" and -1 or 1
    Skin.heading = Skin.heading + (direction * 18.0)

    if Skin.heading > 360 then
        Skin.heading = Skin.heading - 360
    elseif Skin.heading < 0 then
        Skin.heading = Skin.heading + 360
    end
end

function Menu:SetCameraPreset(preset)
    if preset == "face" then
        Skin.zoomOffset = 0.4
        Skin.camOffset = 0.65
    elseif preset == "legs" then
        Skin.zoomOffset = 0.8
        Skin.camOffset = -0.65
    elseif preset == "shoes" then
        Skin.zoomOffset = 0.75
        Skin.camOffset = -0.95
    elseif preset == "torso" then
        Skin.zoomOffset = 0.75
        Skin.camOffset = 0.15
    else
        Skin.zoomOffset = 1.5
        Skin.camOffset = 0.1
    end
end

function Menu:Open(submit, cancel, restrict)
    self.submitCb = submit
    self.cancelCb = cancel
    self.restricted = restrict
    self.saveable = false
    self.creating = false
    self.focusIndex = 1
    Skin.Last = Clothing.copy(Skinchanger:GetSkin())

    self.components, self.maxValues = Skinchanger:GetData()
    if restrict then
        self.components = self:Restrict()
    end

    self:InsertElements()

    if #self.elements < 1 then
        return
    end

    Skin.zoomOffset = self.elements[1].zoomOffset
    Skin.camOffset = self.elements[1].camOffset
    Camera:Create()

    self.isOpen = true
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)
    CreateThread(blockInputThread)
    SendNUIMessage(self:BuildPayload(self.elements[1].name))
end

function Menu:Saveable(submitCb, cancelCb, restrict, creating)
    self:Open(function(data, menu)
        menu.close()
        Camera:Destroy()

        if submitCb ~= nil then
            submitCb(data, menu)
        end
    end, cancelCb, restrict)

    self.saveable = true
    self.creating = creating == true
    self:Refresh(self.elements and self.elements[1] and self.elements[1].name or nil)
end

RegisterNUICallback("skinMenu:change", function(data, cb)
    Menu:Change(data)
    cb({ ok = true })
end)

RegisterNUICallback("skinMenu:focus", function(data, cb)
    Menu:Focus(data)
    cb({ ok = true })
end)

RegisterNUICallback("skinMenu:submit", function(data, cb)
    Menu:Submit(data)
    cb({ ok = true })
end)

RegisterNUICallback("skinMenu:cancel", function(data, cb)
    Menu:Cancel(data)
    cb({ ok = true })
end)

RegisterNUICallback("skinMenu:reset", function(_, cb)
    Camera:Reset()
    cb({ ok = true })
end)

RegisterNUICallback("skinMenu:rotate", function(data, cb)
    Menu:Rotate(type(data) == "table" and data.direction or "right")
    cb({ ok = true })
end)

RegisterNUICallback("skinMenu:camera", function(data, cb)
    Menu:SetCameraPreset(type(data) == "table" and data.preset or "full")
    cb({ ok = true })
end)

RegisterNUICallback("skinMenu:apply", function(data, cb)
    Menu:Apply(type(data) == "table" and data.values or {})
    cb({ ok = true })
end)
