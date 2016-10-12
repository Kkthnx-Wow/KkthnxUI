local K, C, L = select(2, ...):unpack()
if C.DataBars.Artifact ~= true then return end

-- LUA API
local unpack = unpack
local format = string.format

-- WOW API
local Bars = 20
local Movers = K.Movers

local function GetArtifact()
	local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = C_ArtifactUI.GetEquippedArtifactInfo()
	local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)

	return xp, xpForNextPoint
end

local ArtifactAnchor = CreateFrame("Frame", "ArtifactAnchor", UIParent)
ArtifactAnchor:SetSize(C.DataBars.Width, 18)
ArtifactAnchor:SetPoint("TOP", KkthnxUIMinimapStats, "BOTTOM", 0, -13)
Movers:RegisterFrame(ArtifactAnchor)

local Backdrop = CreateFrame("Frame", "Artifact_Backdrop", UIParent)
Backdrop:SetSize(C.DataBars.Width, C.DataBars.Height)
Backdrop:SetPoint("CENTER", ArtifactAnchor, "CENTER", 0, 0)
Backdrop:SetBackdropColor(C.Media.Backdrop_Color)
Backdrop:SetFrameStrata("LOW")
K.CreateBorder(Backdrop, 10, 3)

local BackdropBG = CreateFrame("Frame", "Artifact_BackdropBG", Backdrop)
BackdropBG:SetFrameLevel(Backdrop:GetFrameLevel() - 1)
BackdropBG:SetPoint("TOPLEFT", -1, 1)
BackdropBG:SetPoint("BOTTOMRIGHT", 1, -1)
BackdropBG:SetBackdrop(K.BorderBackdrop)
BackdropBG:SetBackdropColor(unpack(C.Media.Backdrop_Color))

local ArtifactBar = CreateFrame("StatusBar", "ArtifactBar", Backdrop, "TextStatusBar")
ArtifactBar:SetSize(C.DataBars.Width, C.DataBars.Height)
ArtifactBar:SetPoint("TOP", Backdrop, "TOP", 0, 0)
ArtifactBar:SetStatusBarTexture(C.Media.Texture)
ArtifactBar:SetStatusBarColor(229/255, 204/255, 127/255)

-- Hacky way to quickly display the artifact frame.
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
		local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = C_ArtifactUI.GetEquippedArtifactInfo()
		local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)

		Backdrop:Show()
		ArtifactBar:SetMinMaxValues(min(0, xp), xpForNextPoint)
		ArtifactBar:SetValue(xp)
	else
		Backdrop:Hide()
	end

	ArtifactMouseFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(ArtifactMouseFrame, "ANCHOR_BOTTOMLEFT", -2, 5)
		GameTooltip:ClearLines()
		if HasArtBar then
			local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = C_ArtifactUI.GetEquippedArtifactInfo()
			local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
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
Frame:RegisterEvent("PLAYER_LOGIN")
Frame:RegisterEvent("ARTIFACT_XP_UPDATE")
Frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
Frame:SetScript("OnEvent", UpdateStatus)