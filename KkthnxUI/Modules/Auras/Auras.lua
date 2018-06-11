local K, C = unpack(select(2, ...))
local Module = K:NewModule("Auras", "AceEvent-3.0", "AceHook-3.0")
if (not C["Auras"].Enable) then
    return
end

-- Sourced: ElvUI (Elvz)

local _G = _G
local select = select
local floor = math.floor

local CreateFrame = _G.CreateFrame
local GetInventoryItemQuality = _G.GetInventoryItemQuality
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetItemQualityColor = _G.GetItemQualityColor
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo
local RegisterAttributeDriver = _G.RegisterAttributeDriver
local RegisterStateDriver = _G.RegisterStateDriver
local UnitAura = _G.UnitAura

local DIRECTION_TO_POINT = {
    DOWN_RIGHT = "TOPLEFT",
    DOWN_LEFT = "TOPRIGHT",
    UP_RIGHT = "BOTTOMLEFT",
    UP_LEFT = "BOTTOMRIGHT",
    RIGHT_DOWN = "TOPLEFT",
    RIGHT_UP = "BOTTOMLEFT",
    LEFT_DOWN = "TOPRIGHT",
    LEFT_UP = "BOTTOMRIGHT",
}

local DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER = {
    DOWN_RIGHT = 1,
    DOWN_LEFT = -1,
    UP_RIGHT = 1,
    UP_LEFT = -1,
    RIGHT_DOWN = 1,
    RIGHT_UP = 1,
    LEFT_DOWN = -1,
    LEFT_UP = -1,
}

local DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER = {
    DOWN_RIGHT = -1,
    DOWN_LEFT = -1,
    UP_RIGHT = 1,
    UP_LEFT = 1,
    RIGHT_DOWN = -1,
    RIGHT_UP = 1,
    LEFT_DOWN = -1,
    LEFT_UP = 1,
}

local IS_HORIZONTAL_GROWTH = {
    RIGHT_DOWN = true,
    RIGHT_UP = true,
    LEFT_DOWN = true,
    LEFT_UP = true,
}

function Module:UpdateTime(elapsed)
    if (self.offset) then
        local expiration = select(self.offset, GetWeaponEnchantInfo())
        if (expiration) then
            self.timeLeft = expiration / 1e3
        else
            self.timeLeft = 0
        end
    else
        self.timeLeft = self.timeLeft - elapsed
    end

    if (self.nextUpdate > 0) then
        self.nextUpdate = self.nextUpdate - elapsed
        return
    end

    local timerValue, formatID
    timerValue, formatID, self.nextUpdate = K.GetTimeInfo(self.timeLeft, C["Auras"].FadeThreshold)
    self.time:SetFormattedText(("%s%s|r"):format(K.TimeColors[formatID], K.TimeFormats[formatID][1]), timerValue)

    if self.timeLeft > C["Auras"].FadeThreshold then
        K.UIFrameStopFlash(self)
    else
        K.UIFrameFlash(self, 1)
    end
end

function Module:CreateIcon(button)
    button.texture = button:CreateTexture(nil, "BORDER")
    button.texture:SetAllPoints()
    button.texture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

    button.count = button:CreateFontString(nil, "ARTWORK")
    button.count:SetPoint("BOTTOMRIGHT", -1, 1)
    button.count:FontTemplate(nil, 12, "OUTLINE")

    button.time = button:CreateFontString(nil, "ARTWORK")
    button.time:SetPoint("TOP", button, "BOTTOM", 1, -4)
    button.time:FontTemplate(nil, 12, "OUTLINE")

    K.SetAnimationGroup(button)

    button:SetScript("OnAttributeChanged", Module.OnAttributeChanged)

    local header = button:GetParent()
    local auraType = header:GetAttribute("filter")

    if auraType == "HELPFUL" then
        button:SetTemplate("ActionButton", true)
    elseif auraType == "HARMFUL" then
        button:SetTemplate("ActionButton", true)
    end
end

function Module:UpdateAura(button, index)
    local filter = button:GetParent():GetAttribute("filter")
    local unit = button:GetParent():GetAttribute("unit")
    local name, _, texture, count, dtype, duration, expirationTime = UnitAura(unit, index, filter)

    if (name) then
        if (duration > 0 and expirationTime) then
            local timeLeft = expirationTime - _G.GetTime()
            if (not button.timeLeft) then
                button.timeLeft = timeLeft
                button:SetScript("OnUpdate", Module.UpdateTime)
            else
                button.timeLeft = timeLeft
            end

            button.nextUpdate = -1
            Module.UpdateTime(button, 0)
        else
            button.timeLeft = nil
            button.time:SetText("")
            button:SetScript("OnUpdate", nil)
        end

        if (count > 1) then
            button.count:SetText(count)
        else
            button.count:SetText("")
        end

        if filter == "HARMFUL" then
            local color = _G.DebuffTypeColor[dtype or ""]
            button:SetBackdropBorderColor(color.r, color.g, color.b)
        else
            button:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
        end

        button.texture:SetTexture(texture)
        button.offset = nil
    end
end

function Module:UpdateTempEnchant(button, index)
    local quality = GetInventoryItemQuality("player", index)
    button.texture:SetTexture(GetInventoryItemTexture("player", index))

    -- time left
    local offset = 2
    local weapon = button:GetName():sub(-1)
    if weapon:match("2") then
        offset = 6
    end

    if (quality) then
        button:SetBackdropBorderColor(GetItemQualityColor(quality))
    end

    local expirationTime = select(offset, GetWeaponEnchantInfo())
    if (expirationTime) then
        button.offset = offset
        button:SetScript("OnUpdate", Module.UpdateTime)
        button.nextUpdate = -1
        Module.UpdateTime(button, 0)
    else
        button.timeLeft = nil
        button.offset = nil
        button:SetScript("OnUpdate", nil)
        button.time:SetText("")
    end
end

function Module:OnAttributeChanged(attribute, value)
    if (attribute == "index") then
        Module:UpdateAura(self, value)
    elseif (attribute == "target-slot") then
        Module:UpdateTempEnchant(self, value)
    end
end

function Module:UpdateHeader(header)
    if (not C["Auras"].Enable) then return end
    if header:GetAttribute("filter") == "HELPFUL" then
        header:SetAttribute("consolidateTo", 0)
        header:SetAttribute("weaponTemplate", ("AuraTemplate%d"):format(C["Auras"].Size))
    end

    header:SetAttribute("separateOwn", C["Auras"].SeperateOwn)
    header:SetAttribute("sortMethod", C["Auras"].SortMethod.Value)
    header:SetAttribute("sortDirection", C["Auras"].SortDir.Value)
    header:SetAttribute("maxWraps", C["Auras"].MaxWraps)
    header:SetAttribute("wrapAfter", C["Auras"].WrapAfter)

    header:SetAttribute("point", DIRECTION_TO_POINT[C["Auras"].GrowthDirection.Value])

    if (IS_HORIZONTAL_GROWTH[C["Auras"].GrowthDirection.Value]) then
        header:SetAttribute("minWidth", ((C["Auras"].WrapAfter == 1 and 0 or C["Auras"].HorizontalSpacing) + C["Auras"].Size) * C["Auras"].WrapAfter)
        header:SetAttribute("minHeight", (C["Auras"].VerticalSpacing + C["Auras"].Size) * C["Auras"].MaxWraps)
        header:SetAttribute("xOffset", DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[C["Auras"].GrowthDirection.Value] * (C["Auras"].HorizontalSpacing + C["Auras"].Size))
        header:SetAttribute("yOffset", 0)
        header:SetAttribute("wrapXOffset", 0)
        header:SetAttribute("wrapYOffset", DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[C["Auras"].GrowthDirection.Value] * (C["Auras"].VerticalSpacing + C["Auras"].Size))
    else
        header:SetAttribute("minWidth", (C["Auras"].HorizontalSpacing + C["Auras"].Size) * C["Auras"].MaxWraps)
        header:SetAttribute("minHeight", ((C["Auras"].WrapAfter == 1 and 0 or C["Auras"].VerticalSpacing) + C["Auras"].Size) * C["Auras"].WrapAfter)
        header:SetAttribute("xOffset", 0)
        header:SetAttribute("yOffset", DIRECTION_TO_VERTICAL_SPACING_MULTIPLIER[C["Auras"].GrowthDirection.Value] * (C["Auras"].VerticalSpacing + C["Auras"].Size))
        header:SetAttribute("wrapXOffset", DIRECTION_TO_HORIZONTAL_SPACING_MULTIPLIER[C["Auras"].GrowthDirection.Value] * (C["Auras"].HorizontalSpacing + C["Auras"].Size))
        header:SetAttribute("wrapYOffset", 0)
    end

    header:SetAttribute("template", ("AuraTemplate%d"):format(C["Auras"].Size))
    local index = 1
    local child = select(index, header:GetChildren())
    while(child) do
        if ((floor(child:GetWidth() * 100 + 0.5) / 100) ~= C["Auras"].Size) then
            child:SetSize(C["Auras"].Size, C["Auras"].Size)
        end

        if (child.time) then
            child.time:ClearAllPoints()
            child.time:SetPoint("TOP", child, "BOTTOM", 1, -4)
            child.time:FontTemplate(nil, 12, "OUTLINE")

            child.count:ClearAllPoints()
            child.count:SetPoint("BOTTOMRIGHT", -1, 0)
            child.count:FontTemplate(nil, 12, "OUTLINE")
        end

        -- Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
        if (index > (C["Auras"].MaxWraps * C["Auras"].WrapAfter) and child:IsShown()) then
            child:Hide()
        end

        index = index + 1
        child = select(index, header:GetChildren())
    end
end

function Module:CreateAuraHeader(filter)
    local name = "PlayerDebuffs"
    if filter == "HELPFUL" then
        name = "PlayerBuffs"
    end

    local header = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
    header:SetClampedToScreen(true)
    header:SetAttribute("unit", "player")
    header:SetAttribute("filter", filter)
    RegisterStateDriver(header, "visibility", "[petbattle] hide; show")
    RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

    if filter == "HELPFUL" then
        header:SetAttribute("consolidateDuration", -1)
        header:SetAttribute("includeWeapons", 1)
    end

    Module:UpdateHeader(header)
    header:Show()

    return header
end

function Module:OnInitialize()
    if (not C["Auras"].Enable) then
        return
    end

    BuffFrame:SetScript("OnLoad", nil)
    BuffFrame:SetScript("OnUpdate", nil)
    BuffFrame:SetScript("OnEvent", nil)
    BuffFrame:SetParent(K["UIFrameHider"])
    BuffFrame:UnregisterAllEvents()

    TemporaryEnchantFrame:SetScript("OnUpdate", nil)
    TemporaryEnchantFrame:SetParent(K["UIFrameHider"])

    K.KillMenuPanel(12, "InterfaceOptionsFrameCategoriesButton")

    local AurasHolder = CreateFrame("Frame", "AurasHolder", Minimap)
    if C["Minimap"].CollectButtons then
      AurasHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -28, 3)
    else
      AurasHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -3, 3)
    end
    AurasHolder:SetWidth((Minimap:GetWidth() + 29))
    AurasHolder:SetHeight(Minimap:GetHeight() + 53)

    self.BuffFrame = self:CreateAuraHeader("HELPFUL")
    self.BuffFrame:SetPoint("TOPRIGHT", AurasHolder, "TOPLEFT", -(6 + 4), -4 - 4)
    K["Movers"]:RegisterFrame(self.BuffFrame)

    self.DebuffFrame = self:CreateAuraHeader("HARMFUL")
    self.DebuffFrame:SetPoint("BOTTOMRIGHT", AurasHolder, "BOTTOMLEFT", -(6 + 4), -4 - 93)
    K["Movers"]:RegisterFrame(self.DebuffFrame)
end