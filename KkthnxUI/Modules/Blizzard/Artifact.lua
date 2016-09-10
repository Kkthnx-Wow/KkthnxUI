local K, C, L, _ = select(2, ...):unpack()
if C.Experience.Artifact ~= true then return end

-- LUA API
local unpack = unpack
local format = string.format

-- WOW API
local Bars = 20
local Movers = K["Movers"]

local BarHeight, BarWidth = C.Experience.ArtifactHeight, C.Experience.ArtifactWidth
local Texture = C.Media.Texture

local function GetArtifact()
	local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = C_ArtifactUI.GetEquippedArtifactInfo()
	local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
	
	return xp, xpForNextPoint
end

local ArtifactAnchor = CreateFrame("Frame", "ArtifactAnchor", UIParent)
ArtifactAnchor:SetSize(C.Experience.ArtifactWidth, 18)

if C.Minimap.Invert then
	ArtifactAnchor:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, 53)
	ArtifactAnchor:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 1, 53)
else
	ArtifactAnchor:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -1, -33)
	ArtifactAnchor:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 1, -33)
end
Movers:RegisterFrame(ArtifactAnchor)

local Backdrop = CreateFrame("Frame", "Artifact_Backdrop", UIParent)
Backdrop:SetSize(BarWidth, BarHeight)
Backdrop:SetPoint("CENTER", ArtifactAnchor, "CENTER", 0, 0)
Backdrop:SetBackdropColor(C.Media.Backdrop_Color)
Backdrop:SetBackdropBorderColor(C.Media.Backdrop_Color)
Backdrop:SetFrameStrata("LOW")
Backdrop:CreatePixelShadow()

local BackdropBG = CreateFrame("Frame", "Artifact_BackdropBG", Backdrop)
BackdropBG:SetFrameLevel(Backdrop:GetFrameLevel() - 1)
BackdropBG:SetPoint("TOPLEFT", -1, 1)
BackdropBG:SetPoint("BOTTOMRIGHT", 1, -1)
BackdropBG:SetBackdrop(K.BorderBackdrop)
BackdropBG:SetBackdropColor(unpack(C.Media.Backdrop_Color))

local ArtifactBar = CreateFrame("StatusBar", "ArtifactBar", Backdrop, "TextStatusBar")
ArtifactBar:SetSize(BarWidth, BarHeight)
ArtifactBar:SetPoint("TOP", Backdrop, "TOP", 0, 0)
ArtifactBar:SetStatusBarTexture(Texture)
ArtifactBar:SetStatusBarColor(229/255, 204/255, 127/255)

-- HACKY WAY TO QUICKLY DISPLAY THE ARTIFACT FRAME.
ArtifactAnchor:SetScript("OnMouseDown", function(self, btn)
	if (btn == "LeftButton") then
		if ArtifactFrame and ArtifactFrame:IsShown() then HideUIPanel(ArtifactFrame)
		else
			SocketInventoryItem(16)
		end
	end
end)

local ArtifactMouseFrame = CreateFrame("Frame", "Artifact_MouseFrame", Backdrop)
ArtifactMouseFrame:SetAllPoints(Backdrop)
ArtifactMouseFrame:EnableMouse(true)
ArtifactMouseFrame:SetFrameLevel(3)

local function UpdateStatus(event, owner)
	if (event == "UNIT_INVENTORY_CHANGED" and owner ~= "player") then
		return
	end
	
	local HasArtBar = HasArtifactEquipped()

	if HasArtBar then
		Backdrop:Show()
	else
		Backdrop:Hide()
	end

	ArtifactMouseFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(ArtifactMouseFrame, "ANCHOR_BOTTOMLEFT", -2, 5)
		GameTooltip:ClearLines()
		if HasArtBar then
			local Current, Max
			Current, Max = GetArtifact()

			GameTooltip:AddLine(string.format("|cffe6cc80"..ARTIFACT_POWER..": %d / %d (%d%% - %d/%d)|r", Current, Max, Current / Max * 100, Bars - (Bars * (Max - Current) / Max), Bars))
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(ARTIFACT_POWER_TOOLTIP_BODY:format(ArtifactWatchBar.numPointsAvailableToSpend), nil, nil, nil, true)
		end

		GameTooltip:Show()
	end)

	ArtifactMouseFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local Frame = CreateFrame("Frame", nil, UIParent)
Frame:RegisterEvent("ARTIFACT_XP_UPDATE")
Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
Frame:SetScript("OnEvent", UpdateStatus)