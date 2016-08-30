local K, C, L, _ = select(2, ...):unpack()

-- THIS FILE IS FOR TESTING AND REMINDERS BULLSHIT :D
-- [[ -*- NOTES -*- ]] --

-- ARTIFACTBAR LOCALIZATION
L_ARTIFACTBAR_XPTITLE = "Artifact Experience"
L_ARTIFACTBAR_CURRENTXP = "Current Experience: %s"
L_ARTIFACTBAR_XP = "Experience: %s/%s (%d%%)"
L_ARTIFACTBAR_XPREMAINING = "Remaining: %s"
L_ARTIFACTBAR_TRAITS = "Traits avaiable: %s"

local BarHeight, BarWidth = 8, 150
local Texture = C.Media.Texture
local Color = RAID_CLASS_COLORS[K.Class]

local Artifact_Backdrop = CreateFrame("Frame", "Artifact_Backdrop", UIParent)
Artifact_Backdrop:SetSize(BarWidth, BarHeight)
Artifact_Backdrop:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -1, -40)
Artifact_Backdrop:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 1, -40)
Artifact_Backdrop:SetBackdropColor(C.Media.Backdrop_Color)
Artifact_Backdrop:SetBackdropBorderColor(C.Media.Backdrop_Color)
Artifact_Backdrop:SetFrameStrata("LOW")
Artifact_Backdrop:CreatePixelShadow()

local Artifact_BackdropBG = CreateFrame("Frame", "StatusBarBG", Artifact_Backdrop)
Artifact_BackdropBG:SetFrameLevel(Artifact_Backdrop:GetFrameLevel() - 1)
Artifact_BackdropBG:SetPoint("TOPLEFT", -1, 1)
Artifact_BackdropBG:SetPoint("BOTTOMRIGHT", 1, -1)
Artifact_BackdropBG:SetBackdrop(K.BorderBackdrop)
Artifact_BackdropBG:SetBackdropColor(unpack(C.Media.Backdrop_Color))

local ArtifactBar = CreateFrame("StatusBar", "XP_ArtifactBar", Artifact_Backdrop, "TextStatusBar")
ArtifactBar:SetSize(BarWidth, BarHeight)
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

local Frame = CreateFrame("Frame", nil, UIParent)
Frame:RegisterEvent("ARTIFACT_XP_UPDATE")
Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
Frame:SetScript("OnEvent", updateStatus)


local OHSkin = CreateFrame("Frame")
OHSkin:RegisterEvent("ADDON_LOADED")
OHSkin:SetScript("OnEvent", function(self, event, addon)
	if (addon ~= "Blizzard_OrderHallUI") then
		return
	end

	OrderHallCommandBar:StripTextures()
	OrderHallCommandBar:SetTemplate("Transparent")
	OrderHallCommandBar:ClearAllPoints()
	OrderHallCommandBar:SetPoint("TOP", UIParent, 0, 0)
	OrderHallCommandBar:SetWidth(480)
	OrderHallCommandBar.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
	OrderHallCommandBar.ClassIcon:SetSize(46, 20)
	OrderHallCommandBar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
	OrderHallCommandBar.AreaName:ClearAllPoints()
	OrderHallCommandBar.AreaName:SetPoint("RIGHT", OrderHallCommandBar, "RIGHT", -10, 0)
	OrderHallCommandBar.WorldMapButton:Hide()
	--OrderHallCommandBar.WorldMapButton:SetPoint("RIGHT", OrderHallCommandBar, -5, -2)

	self:UnregisterEvent("ADDON_LOADED")
end)