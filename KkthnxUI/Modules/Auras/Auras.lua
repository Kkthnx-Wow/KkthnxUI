local K, C, L = unpack(select(2, ...))
local A = K:NewModule("Auras", "AceEvent-3.0", "AceHook-3.0")

-- Lua API
local _G = _G
local next = next
local select = select
local unpack = unpack

-- Wow API
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetTime = _G.GetTime
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo
local UnitAura = _G.UnitAura
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local RegisterAttributeDriver = _G.RegisterAttributeDriver

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: BuffFrame, TemporaryEnchantFrame, InterfaceOptionsFrameCategoriesButton12
-- GLOBALS: DebuffTypeColor, PetBattleFrameHider, SecureHandlerSetFrameRef

local buttonsize = C["Auras"].ButtonSize -- Buff Size
local spacing = C["Auras"].ButtonSpace -- Buff Spacing
local buffsperrow = C["Auras"].ButtonPerRow
local buffholder, debuffholder, enchantholder
local BUFF_FLASH_TIME_ON = 0.75
local BUFF_FLASH_TIME_OFF = 0.75
local BUFF_MIN_ALPHA = 0.3

function A:UpdateAlpha(elapsed)
    self.BuffFrameFlashTime = self.BuffFrameFlashTime - elapsed
    if (self.BuffFrameFlashTime < 0) then
        local overtime = -self.BuffFrameFlashTime
        if (self.BuffFrameFlashState == 0) then
            self.BuffFrameFlashState = 1
            self.BuffFrameFlashTime = BUFF_FLASH_TIME_ON
        else
            self.BuffFrameFlashState = 0
            self.BuffFrameFlashTime = BUFF_FLASH_TIME_OFF
        end
        if (overtime < self.BuffFrameFlashTime) then
            self.BuffFrameFlashTime = self.BuffFrameFlashTime - overtime
        end
    end

    if ( self.BuffFrameFlashState == 1 ) then
        self.BuffAlphaValue = (BUFF_FLASH_TIME_ON - self.BuffFrameFlashTime) / BUFF_FLASH_TIME_ON
    else
        self.BuffAlphaValue = self.BuffFrameFlashTime / BUFF_FLASH_TIME_ON
    end
    self.BuffAlphaValue = (self.BuffAlphaValue * (1 - BUFF_MIN_ALPHA)) + BUFF_MIN_ALPHA
end

function A:UpdateTime(elapsed)
    if (self.offset) then
        local expiration = select(self.offset, GetWeaponEnchantInfo())
        if (expiration) then
            self.timeLeft = expiration / 1e3
        else
            self.timeLeft = 0
        end
    end

    if (self.timeLeft) then
        self.timeLeft = math.max(self.timeLeft - elapsed, 0)
        if (self.timeLeft <= 0) then
            self:SetAlpha(1)
            self.time:SetText("")
        else
            local time = K.FormatTime(self.timeLeft)
            if self.timeLeft <= 86400.5 and self.timeLeft > 3600.5 then
                self.time:SetText(NORMAL_FONT_COLOR_CODE..time.."|r")
                self:SetAlpha(1)
            elseif self.timeLeft <= 3600.5 and self.timeLeft > 60.5 then
                self.time:SetText(NORMAL_FONT_COLOR_CODE..time.."|r")
                self:SetAlpha(1)
            elseif self.timeLeft <= 60.5 then
                self.time:SetText("|cffff0000"..time.."|r")
                if A.AlphaFrame then
                    self:SetAlpha(A.AlphaFrame.BuffAlphaValue)
                end
            end
        end
    end
end

function A:CreateIcon(button)
    button.texture = button:CreateTexture(nil, "BORDER")
    button.texture:SetTexCoord(.08, .92, .08, .92)
    button.texture:SetAllPoints()

    button.count = button:CreateFontString(nil, "ARTWORK")
    button.count:SetPoint("TOPRIGHT", 1, 1)
    button.count:SetFont(C["Media"].Font, 12, "OUTLINE")

    button.time = button:CreateFontString(nil, "ARTWORK")
    button.time:SetPoint("CENTER", button, "BOTTOM", 0, -8)
    button.time:SetFont(C["Media"].Font, 12, "OUTLINE")

    button:SetScript("OnUpdate", A.UpdateTime)

    button:SetTemplate("ActionButton", true)

    -- Really do not need this with our new SetTemplate
    -- button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    -- button.highlight:SetAllPoints(button.texture)
    -- button.highlight:SetVertexColor(1, 1, 1)
        -- button.highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
        -- button.highlight:SetBlendMode("ADD")

    button:SetScript("OnAttributeChanged", A.OnAttributeChanged)
end

function A:UpdateAura(button, index)
    local filter = button:GetParent():GetAttribute("filter")
    local unit = button:GetParent():GetAttribute("unit")
    local name, rank, texture, count, dtype, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff = UnitAura(unit, index, filter)

    if (name) then
        if (duration > 0 and expirationTime) then
            local timeLeft = expirationTime - GetTime()
            if (not button.timeLeft) then
                button.timeLeft = timeLeft
                button:SetScript("OnUpdate", A.UpdateTime)
            else
                button.timeLeft = timeLeft
            end

            button.nextUpdate = -1
            A.UpdateTime(button, 0)
        else
            button.timeLeft = nil
            button.time:SetText("")
            button:SetScript("OnUpdate", nil)
            button:SetAlpha(1)
        end

        if (count > 1) then
            button.count:SetText(count)
        else
            button.count:SetText("")
        end

        if filter == "HARMFUL" then
            local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
            button:SetBackdropBorderColor(color.r, color.g, color.b)
            button.texture:SetInside(button, 1, 1)
        end

        button.texture:SetTexture(texture)
        button.offset = nil
    end
end

function A:UpdateTempEnchant(button, index)
    local quality = GetInventoryItemQuality("player", index)
    button.texture:SetTexture(GetInventoryItemTexture("player", index))

    -- time left
    local offset = 2
    local weapon = button:GetName():sub(-1)
    if weapon:match("2") then
        offset = 5
    end

    if (quality) then
        button:SetBackdropBorderColor(GetItemQualityColor(quality))
    end

    local expirationTime = select(offset, GetWeaponEnchantInfo())
    if (expirationTime) then
        button.offset = offset
        button:SetScript("OnUpdate", A.UpdateTime)
        button.nextUpdate = -1
        A.UpdateTime(button, 0)
    else
        button.timeLeft = nil
        button.offset = nil
        button:SetScript("OnUpdate", nil)
        button:SetAlpha(1)
        button.time:SetText("")
    end
end

function A:OnAttributeChanged(attribute, value)
    if (attribute == "index") then
        A:UpdateAura(self, value)
    elseif (attribute == "target-slot") then
        A:UpdateTempEnchant(self, value)
    end
end

function A:UpdateHeader(header)
    header:SetAttribute("consolidateTo", 0)
    header:SetAttribute("maxWraps", 3)
    header:SetAttribute("sortMethod", "TIME")
    header:SetAttribute("sortDirection", "-")
    header:SetAttribute("wrapAfter", buffsperrow)

    header:SetAttribute("minWidth", buffsperrow == 1 and 0 or spacing + buttonsize * (buffsperrow))
    header:SetAttribute("minHeight", buttonsize)
    header:SetAttribute("wrapYOffset", -(buttonsize + spacing))
    AurasHolder:SetWidth(header:GetAttribute("minWidth"))

    if header:GetAttribute("filter") == "HELPFUL" then
        header:SetAttribute("separateOwn", 1)
        header:SetAttribute("maxWraps", 3)
        header:SetAttribute("minHeight", buttonsize* 3 + spacing* 2)
        header:SetAttribute("weaponTemplate", ("KkthnxUIAuraTemplate%d"):format(buttonsize))
    end

    header:SetAttribute("template", ("KkthnxUIAuraTemplate%d"):format(buttonsize))
    A:PostDrag()
end

function A:CreateAuraHeader(filter)
    local name
    if filter == "HELPFUL" then name = "KkthnxUIPlayerBuffs" else name = "KkthnxUIPlayerDebuffs" end

    local header = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
    header:SetClampedToScreen(true)
    header:SetAttribute("template", "KkthnxUIAuraTemplate30")
    header:SetAttribute("unit", "player")
    header:SetAttribute("filter", filter)
    RegisterStateDriver(header, "visibility", "[petbattle] hide; show")

    if filter == "HELPFUL" then
        header:SetAttribute("consolidateDuration", -1)
        header:SetAttribute("includeWeapons", 1)
    end

    A:UpdateHeader(header)
    header:Show()

    return header
end

function A:PostDrag(position)
    if InCombatLockdown() then return end
    local headers = {KkthnxUIPlayerBuffs, KkthnxUIPlayerDebuffs}
    for _, header in pairs(headers) do
        if header then
            if not position then position = K.GetScreenQuadrant(header) end
            if string.find(position, "LEFT") then
                header:SetAttribute("point", "TOPLEFT")
                header:SetAttribute("xOffset", buttonsize + spacing)
            else
                header:SetAttribute("point", "TOPRIGHT")
                header:SetAttribute("xOffset", -(buttonsize + spacing))
            end

            header:ClearAllPoints()
        end
    end

    if string.find(position, "LEFT") then
        KkthnxUIPlayerBuffs:SetPoint("TOPLEFT", AurasHolder, "TOPLEFT", 0, 0)

        if KkthnxUIPlayerDebuffs then
            KkthnxUIPlayerDebuffs:SetPoint("BOTTOMLEFT", KkthnxUIPlayerBuffs, "BOTTOMLEFT", 0,0)
        end
    else
        KkthnxUIPlayerBuffs:SetPoint("TOPRIGHT", AurasHolder, "TOPRIGHT", 0, 0)

        if KkthnxUIPlayerDebuffs then
            KkthnxUIPlayerDebuffs:SetPoint("BOTTOMRIGHT", AurasHolder, "BOTTOMRIGHT", 0, 0)
        end
    end
end

function A:OnEnable()
    if C["Auras"].Enable ~= true then return end

    local AurasHolder = CreateFrame("Frame", "AurasHolder", UIParent)
    AurasHolder:SetHeight(K.Scale(buttonsize)* 4 + K.Scale(spacing)* 3)
    AurasHolder:SetWidth(K.Scale(buttonsize)* buffsperrow + K.Scale(spacing)* (buffsperrow-1))
    AurasHolder:SetFrameStrata("BACKGROUND")
    AurasHolder:SetClampedToScreen(true)
    AurasHolder:SetAlpha(0)
    if C["Minimap"].CollectButtons then
      AurasHolder:SetPoint(C.Position.PlayerBuffs[1], C.Position.PlayerBuffs[2], C.Position.PlayerBuffs[3], C.Position.PlayerBuffs[4], C.Position.PlayerBuffs[5])
    else
      AurasHolder:SetPoint("TOPRIGHT", "Minimap", "TOPLEFT", -8, 0)
    end
    K.Movers:RegisterFrame(AurasHolder)

    self.BuffFrame = self:CreateAuraHeader("HELPFUL")
    self.DebuffFrame = self:CreateAuraHeader("HARMFUL")

    self.AlphaFrame = CreateFrame("Frame")
    self.AlphaFrame.BuffAlphaValue = 1
    self.AlphaFrame.BuffFrameFlashState = 1
    self.AlphaFrame.BuffFrameFlashTime = 0
    self.AlphaFrame:SetScript("OnUpdate", A.UpdateAlpha)
end