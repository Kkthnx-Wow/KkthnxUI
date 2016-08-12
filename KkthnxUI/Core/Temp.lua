local K, C, L, _ = select(2, ...):unpack()

-- THIS FILE IS FOR TESTING AND REMINDERS BULLSHIT :D
-- [[ -*- NOTES -*- ]] --

-- [[ -*- COMBAT_LOG_EVENT_UNFILTERED -*- ]] --
-- timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID = ...
-- timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName = select (1, ...)

local format = string.format

if (K.Name == "Kkthnx" or K.Name == "Rollndots" or K.Name == "Safeword" or K.Name == "Broflex" or K.Name == "Broflexin") and (K.Realm == "Stormreaver") then
	
	local GetZonePVPInfo = GetZonePVPInfo
	local GetSpellInfo = GetSpellInfo
	local SendChatMessage = SendChatMessage
	local UnitName = UnitName
	local UnitClass = UnitClass
	
	--if C.Announcements.ArenaDrinking ~= true then return end
	L_MISC_DRINKING = " is drinking."
	
	-- Announce enemy drinking in arena(by Duffed)
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	frame:SetScript("OnEvent", function(self, event, ...)
		if not (event == "UNIT_SPELLCAST_SUCCEEDED" and GetZonePVPInfo() == "arena") then return end
		
		local unit, _, _, _, spellID = ...
		if UnitIsEnemy("player", unit) and (GetSpellInfo(spellID) == GetSpellInfo(118358) or GetSpellInfo(spellID) == GetSpellInfo(167152) or GetSpellInfo(spellID) == GetSpellInfo(167268)) then
			SendChatMessage(UnitClass(unit).." "..UnitName(unit)..L_MISC_DRINKING, K.CheckChat(true))
		end
	end)
end

-- ARTIFACTBAR FOR LEGION WIP (DUFFEDUI)
L_ARTIFACTBAR_XPTITLE = "Artifact Experience"
L_ARTIFACTBAR_CURRENTXP = "Current Experience: %s"
L_ARTIFACTBAR_XP = "Experience: %s/%s (%d%%)"
L_ARTIFACTBAR_XPREMAINING = "Remaining: %s"
L_ARTIFACTBAR_TRAITS = "Traits avaiable: %s"

local BarHeight, BarWidth = 5, 378
local Texture = C.Media.Texture
local Color = RAID_CLASS_COLORS[K.Class]

local Artifact_Backdrop = CreateFrame("Frame", "Artifact_Backdrop", UIParent)
Artifact_Backdrop:SetSize(BarWidth, BarHeight)
Artifact_Backdrop:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -7, 178)
Artifact_Backdrop:SetBackdropColor(C.Media.Backdrop_Color)
Artifact_Backdrop:SetBackdropBorderColor(C.Media.Backdrop_Color)
Artifact_Backdrop:CreateBackdrop("Transparent")
Artifact_Backdrop:SetFrameStrata("LOW")

local ArtifactBar = CreateFrame("StatusBar",  "XP_ArtifactBar", Artifact_Backdrop, "TextStatusBar")
ArtifactBar:SetWidth(BarWidth)
ArtifactBar:SetHeight(BarHeight)
ArtifactBar:SetPoint("TOP", Artifact_Backdrop, "TOP", 0, 0)
ArtifactBar:SetStatusBarTexture(Texture)
ArtifactBar:SetStatusBarColor(157/255, 138/255, 108/255)

local ArtifactMouseFrame = CreateFrame("Frame", "Artifact_MouseFrame", Artifact_Backdrop)
ArtifactMouseFrame:SetAllPoints(Artifact_Backdrop)
ArtifactMouseFrame:EnableMouse(true)
ArtifactMouseFrame:SetFrameLevel(3)

local function updateStatus()
	local HasArtBar = HasArtifactEquipped()

	if HasArtBar then
		local _, _, _, _, totalxp, pointsSpent, _, _, _, _, _, _ = C_ArtifactUI.GetEquippedArtifactInfo()
		local _, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalxp)

		Artifact_Backdrop:Show()
		ArtifactBar:SetMinMaxValues(min(0, xp), xpForNextPoint)
		ArtifactBar:SetValue(xp)
	else
		Artifact_Backdrop:Hide()
	end

	ArtifactMouseFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(ArtifactMouseFrame, "ANCHOR_TOPRIGHT", 2, 5)
		GameTooltip:ClearLines()
		if HasArtBar then
			local _, _, _, _, totalxp, pointsSpent, _, _, _, _, _, _ = C_ArtifactUI.GetEquippedArtifactInfo()
			local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalxp)

			GameTooltip:AddLine(L_ARTIFACTBAR_XPTITLE)
			GameTooltip:AddLine(format(L_ARTIFACTBAR_XP, xp, xpForNextPoint, (xp / xpForNextPoint) * 100))
			GameTooltip:AddLine(format(L_ARTIFACTBAR_XPREMAINING, xpForNextPoint - xp))
			GameTooltip:AddLine(format(L_ARTIFACTBAR_TRAITS, numPointsAvailableToSpend))
		end

		GameTooltip:Show()
	end)

	ArtifactMouseFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:RegisterEvent("ARTIFACT_XP_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
frame:SetScript("OnEvent", updateStatus)


-- !BEAUTYCASE (NEAVUI)
--[[
    How to use:
    myFrame:CreateBeautyBorder(borderSize or nothing)
    myFrame:SetBeautyBorderSize(borderSize)
    myFrame:SetBeautyBorderPadding(number or [uL1, uL2, uR1, uR2, bL1, bL2, bR1, bR2])
    myFrame:SetBeautyBorderTexture(texture or "default" or "white")
    myFrame:SetBeautyShadowTexture(texture)
    myFrame:SetBeautyBorderColor(r, g, b)
    myFrame:SetBeautyShadowColor(r, g, b)
    myFrame:HideBeautyBorder()
    myFrame:ShowBeautyBorder()
    myFrame:HasBeautyBorder() - true if has a beautycase border, false if not
    local borderSize, texture, r, g, b, alpha = myFrame:GetBeautyBorderInfo()
--]]

local addonName = select(1, GetAddOnInfo("KkthnxUI"))
local formatName = "|cffFF0000"..addonName

local textureNormal = "Interface\\AddOns\\KkthnxUI\\Media\\Test\\BeautyCaseNormal"
local textureWhite = "Interface\\AddOns\\KkthnxUI\\Media\\Test\\BeautyCaseWhite"
local textureShadow = "Interface\\AddOns\\KkthnxUI\\Media\\Test\\BeautyCaseShadow"

local function HasBeautyBorder(self)
    if (self.beautyBorder) then
        return true
    else
        return false
    end
end

local function GetBeautyBorderInfo(self)
    if (not self) then
        print(formatName.." error:|r This frame does not exist!")
    elseif (self.beautyBorder) then
        local tex = self.beautyBorder[1]:GetTexture()
        local size = self.beautyBorder[1]:GetSize()
        local r, g, b, a = self.beautyBorder[1]:GetVertexColor()

        return size, tex, r, g, b, a
    else
        print(formatName.." error:|r Invalid frame! This object has no "..addonName.." border")
    end
end

local function SetBeautyBorderPadding(self, uL1, ...)
    if (not self) then
        print(formatName.." error:|r This frame does not exist!")
        return
    end

    if (not self:IsObjectType("Frame")) then
        local frame  = "frame"
        print(formatName.." error:|r The entered object is not a "..frame.."!")
        return
    end

    local uL2, uR1, uR2, bL1, bL2, bR1, bR2 = ...
    if (uL1) then
        if (not uL2 and not uR1 and not uR2 and not bL1 and not bL2 and not bR1 and not bR2) then
            uL2, uR1, uR2, bL1, bL2, bR1, bR2 = uL1, uL1, uL1, uL1, uL1, uL1, uL1
        end
    end

    local space
    if (GetBeautyBorderInfo(self) >= 10) then
        space = 3
    else
        space = GetBeautyBorderInfo(self)/3.5
    end

    if (self.beautyBorder) then
        self.beautyBorder[1]:SetPoint("TOPLEFT", self, -(uL1 or 0), uL2 or 0)
        self.beautyShadow[1]:SetPoint("TOPLEFT", self, -(uL1 or 0)-space, (uL2 or 0)+space)

        self.beautyBorder[2]:SetPoint("TOPRIGHT", self, uR1 or 0, uR2 or 0)
        self.beautyShadow[2]:SetPoint("TOPRIGHT", self, (uR1 or 0)+space, (uR2 or 0)+space)

        self.beautyBorder[3]:SetPoint("BOTTOMLEFT", self, -(bL1 or 0), -(bL2 or 0))
        self.beautyShadow[3]:SetPoint("BOTTOMLEFT", self, -(bL1 or 0)-space, -(bL2 or 0)-space)

        self.beautyBorder[4]:SetPoint("BOTTOMRIGHT", self, bR1 or 0, -(bR2 or 0))
        self.beautyShadow[4]:SetPoint("BOTTOMRIGHT", self, (bR1 or 0)+space, -(bR2 or 0)-space)
    end
end

local function SetBeautyBorderColor(self, r, ...)
    local r, g, b, a = r, ...

    if (type(r) == "table") then
        r, g, b, a = unpack(r)
    end

    if (not self) then
        print(formatName.." error:|r This frame does not exist!")
    elseif (self.beautyBorder) then
        for i = 1, 8 do
            self.beautyBorder[i]:SetVertexColor(r, g, b, a or 1)
        end
    else
        print(formatName.." error:|r Invalid frame! This object has no "..addonName.." border")
    end
end

local function SetBeautyShadowColor(self, r, ...)
    local r, g, b, a = r, ...

    if (type(r) == "table") then
        r, g, b, a = unpack(r)
    end

    if (not self) then
        print(formatName.." error:|r This frame does not exist!")
    elseif (self.beautyShadow) then
        for i = 1, 8 do
            self.beautyShadow[i]:SetVertexColor(r, g, b, a or 1)
        end
    else
        print(formatName.." error:|r Invalid frame! This object has no "..addonName.." border")
    end
end

local function SetBeautyBorderTexture(self, texture)
    if (not self) then
        print(formatName.." error:|r This frame does not exist!")
    elseif (self.beautyBorder) then
        for i = 1, 8 do
            if (texture == "default") then
                self.beautyBorder[i]:SetTexture(textureNormal)
            elseif (texture == "white") then
                self.beautyBorder[i]:SetTexture(textureWhite)
            else
                self.beautyBorder[i]:SetTexture(texture)
            end
        end
    else
        print(formatName.." error:|r Invalid frame! This object has no "..addonName.." border")
    end
end

local function SetBeautyShadowTexture(self, texture)
    if (not self) then
        print(formatName.." error:|r This frame does not exist!")
    elseif (self.beautyShadow) then
        for i = 1, 8 do
            self.beautyShadow[i]:SetTexture(texture)
        end
    else
        print(formatName.." error:|r Invalid frame! This object has no "..addonName.." border")
    end
end

local function SetBeautyBorderSize(self, size)
    if (not self) then
        print(formatName.." error:|r This frame does not exist!")
    elseif (self.beautyShadow) then
        for i = 1, 8 do
            self.beautyBorder[i]:SetSize(size, size)
            self.beautyShadow[i]:SetSize(size, size)
        end
    else
        print(formatName.." error:|r Invalid frame! This object has no "..addonName.." border")
    end
end

local function HideBeautyBorder(self)
    if (not self) then
        print(formatName.." error:|r This frame does not exist!")
    elseif (self.beautyShadow) then
        for i = 1, 8 do
            self.beautyBorder[i]:Hide()
            self.beautyShadow[i]:Hide()
        end
    else
        print(formatName.." error:|r Invalid frame! This object has no "..addonName.." border")
    end
end

local function ShowBeautyBorder(self)
    if (not self) then
        print(formatName.." error:|r This frame does not exist!")
    elseif (self.beautyShadow) then
        for i = 1, 8 do
            self.beautyBorder[i]:Show()
            self.beautyShadow[i]:Show()
        end
    else
        print(formatName.." error:|r Invalid frame! This object has no "..addonName.." border")
    end
end

local function FuncCreateBorder(self, borderSize, R, G, B, uL1, ...)
    if (not self) then
        print(formatName.." error:|r This frame does not exist!")
        return
    end

    if (not self:IsObjectType("Frame")) then
        local frame  = "frame"
        print(formatName.." error:|r The entered object is not a "..frame.."!")
        return
    end

    if (self.beautyBorder) then
        return
    end

    local uL2, uR1, uR2, bL1, bL2, bR1, bR2 = ...
    if (uL1) then
        if (not uL2 and not uR1 and not uR2 and not bL1 and not bL2 and not bR1 and not bR2) then
            uL2, uR1, uR2, bL1, bL2, bR1, bR2 = uL1, uL1, uL1, uL1, uL1, uL1, uL1
        end
    end

    local space
    if (borderSize >= 10) then
        space = 3
    else
        space = borderSize/3.5
    end

    if (not self.beautyBorder) then

        self.beautyShadow = {}
        for i = 1, 8 do
            self.beautyShadow[i] = self:CreateTexture(nil, "BORDER")
            self.beautyShadow[i]:SetParent(self)
            self.beautyShadow[i]:SetTexture(textureShadow)
            self.beautyShadow[i]:SetSize(borderSize, borderSize)
            self.beautyShadow[i]:SetVertexColor(0, 0, 0, 1)
        end

        self.beautyBorder = {}
        for i = 1, 8 do
            self.beautyBorder[i] = self:CreateTexture(nil, "OVERLAY")
            self.beautyBorder[i]:SetParent(self)
            self.beautyBorder[i]:SetTexture(textureNormal)
            self.beautyBorder[i]:SetSize(borderSize, borderSize)
            self.beautyBorder[i]:SetVertexColor(R or 1, G or 1, B or 1)
        end

        self.beautyBorder[1]:SetTexCoord(0, 1/3, 0, 1/3)
        self.beautyBorder[1]:SetPoint("TOPLEFT", self, -(uL1 or 0), uL2 or 0)

        self.beautyBorder[2]:SetTexCoord(2/3, 1, 0, 1/3)
        self.beautyBorder[2]:SetPoint("TOPRIGHT", self, uR1 or 0, uR2 or 0)

        self.beautyBorder[3]:SetTexCoord(0, 1/3, 2/3, 1)
        self.beautyBorder[3]:SetPoint("BOTTOMLEFT", self, -(bL1 or 0), -(bL2 or 0))

        self.beautyBorder[4]:SetTexCoord(2/3, 1, 2/3, 1)
        self.beautyBorder[4]:SetPoint("BOTTOMRIGHT", self, bR1 or 0, -(bR2 or 0))

        self.beautyBorder[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
        self.beautyBorder[5]:SetPoint("TOPLEFT", self.beautyBorder[1], "TOPRIGHT")
        self.beautyBorder[5]:SetPoint("TOPRIGHT", self.beautyBorder[2], "TOPLEFT")

        self.beautyBorder[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
        self.beautyBorder[6]:SetPoint("BOTTOMLEFT", self.beautyBorder[3], "BOTTOMRIGHT")
        self.beautyBorder[6]:SetPoint("BOTTOMRIGHT", self.beautyBorder[4], "BOTTOMLEFT")

        self.beautyBorder[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
        self.beautyBorder[7]:SetPoint("TOPLEFT", self.beautyBorder[1], "BOTTOMLEFT")
        self.beautyBorder[7]:SetPoint("BOTTOMLEFT", self.beautyBorder[3], "TOPLEFT")

        self.beautyBorder[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
        self.beautyBorder[8]:SetPoint("TOPRIGHT", self.beautyBorder[2], "BOTTOMRIGHT")
        self.beautyBorder[8]:SetPoint("BOTTOMRIGHT", self.beautyBorder[4], "TOPRIGHT")

        self.beautyShadow[1]:SetTexCoord(0, 1/3, 0, 1/3)
        self.beautyShadow[1]:SetPoint("TOPLEFT", self, -(uL1 or 0)-space, (uL2 or 0)+space)

        self.beautyShadow[2]:SetTexCoord(2/3, 1, 0, 1/3)
        self.beautyShadow[2]:SetPoint("TOPRIGHT", self, (uR1 or 0)+space, (uR2 or 0)+space)

        self.beautyShadow[3]:SetTexCoord(0, 1/3, 2/3, 1)
        self.beautyShadow[3]:SetPoint("BOTTOMLEFT", self, -(bL1 or 0)-space, -(bL2 or 0)-space)

        self.beautyShadow[4]:SetTexCoord(2/3, 1, 2/3, 1)
        self.beautyShadow[4]:SetPoint("BOTTOMRIGHT", self, (bR1 or 0)+space, -(bR2 or 0)-space)

        self.beautyShadow[5]:SetTexCoord(1/3, 2/3, 0, 1/3)
        self.beautyShadow[5]:SetPoint("TOPLEFT", self.beautyShadow[1], "TOPRIGHT")
        self.beautyShadow[5]:SetPoint("TOPRIGHT", self.beautyShadow[2], "TOPLEFT")

        self.beautyShadow[6]:SetTexCoord(1/3, 2/3, 2/3, 1)
        self.beautyShadow[6]:SetPoint("BOTTOMLEFT", self.beautyShadow[3], "BOTTOMRIGHT")
        self.beautyShadow[6]:SetPoint("BOTTOMRIGHT", self.beautyShadow[4], "BOTTOMLEFT")

        self.beautyShadow[7]:SetTexCoord(0, 1/3, 1/3, 2/3)
        self.beautyShadow[7]:SetPoint("TOPLEFT", self.beautyShadow[1], "BOTTOMLEFT")
        self.beautyShadow[7]:SetPoint("BOTTOMLEFT", self.beautyShadow[3], "TOPLEFT")

        self.beautyShadow[8]:SetTexCoord(2/3, 1, 1/3, 2/3)
        self.beautyShadow[8]:SetPoint("TOPRIGHT", self.beautyShadow[2], "BOTTOMRIGHT")
        self.beautyShadow[8]:SetPoint("BOTTOMRIGHT", self.beautyShadow[4], "TOPRIGHT")
    end
end

local function addapi(object)
    local mt = getmetatable(object).__index

    mt.CreateBeautyBorder = FuncCreateBorder

    mt.SetBeautyBorderSize = SetBeautyBorderSize
    mt.SetBeautyBorderPadding = SetBeautyBorderPadding

    mt.SetBeautyBorderColor = SetBeautyBorderColor
    mt.SetBeautyBorderTexture = SetBeautyBorderTexture

    mt.SetBeautyShadowColor = SetBeautyShadowColor
    mt.SetBeautyShadowTexture = SetBeautyShadowTexture

    mt.HideBeautyBorder = HideBeautyBorder
    mt.ShowBeautyBorder = ShowBeautyBorder

    mt.HasBeautyBorder = HasBeautyBorder
    mt.GetBeautyBorderInfo = GetBeautyBorderInfo
end


local handled = {
    ["Frame"] = true
}

local object = CreateFrame("Frame")
addapi(object)

object = EnumerateFrames()

while object do
    if (not handled[object:GetObjectType()]) then
        addapi(object)
        handled[object:GetObjectType()] = true
    end

    object = EnumerateFrames(object)
end