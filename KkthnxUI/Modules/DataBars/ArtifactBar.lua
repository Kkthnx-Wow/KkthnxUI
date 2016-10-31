local K, C, L = select(2, ...):unpack()
if C.DataBars.ArtifactEnable ~= true then return end

local Bars = 20
local Movers = K.Movers

local Anchor = CreateFrame("Frame", "ArtifactAnchor", UIParent)
Anchor:SetSize(C.DataBars.ArtifactWidth, C.DataBars.ArtifactHeight)
Anchor:SetPoint("TOP", KkthnxUIMinimapStats, "BOTTOM", 0, -34)
Movers:RegisterFrame(Anchor)

local ArtifactBar = CreateFrame("StatusBar", nil, UIParent)
ArtifactBar:SetOrientation("HORIZONTAL")
ArtifactBar:SetSize(C.DataBars.ArtifactWidth, C.DataBars.ArtifactHeight)
ArtifactBar:SetPoint("CENTER", ArtifactAnchor, "CENTER", 0, 0)
ArtifactBar:SetStatusBarTexture(C.Media.Texture)
ArtifactBar:SetStatusBarColor(unpack(C.DataBars.ArtifactColor))

K.CreateBorder(ArtifactBar, 10, 3)
ArtifactBar:SetBackdrop({bgFile = C.Media.Blank,insets = {left = -1, right = -1, top = -1, bottom = -1}})
ArtifactBar:SetBackdropColor(unpack(C.Media.Backdrop_Color))

if C.Blizzard.ColorTextures == true then
	ArtifactBar:SetBorderTexture("white")
	ArtifactBar:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
end

ArtifactBar:SetScript("OnMouseDown", function(self, button)
	if (button == "LeftButton") then
		local HasArtifactEquip = HasArtifactEquipped()

		if not ArtifactFrame then
			LoadAddOn("Blizzard_ArtifactUI")
		end

		if HasArtifactEquip then
			local frame = ArtifactFrame
			local activeID = C_ArtifactUI.GetArtifactInfo()
			local equippedID = C_ArtifactUI.GetEquippedArtifactInfo()

			if frame:IsShown() and activeID == equippedID then
				HideUIPanel(frame)
			else
				SocketInventoryItem(16)
			end
		end
	end
end)

local function GetArtifact()
	local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop = C_ArtifactUI.GetEquippedArtifactInfo()
	local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)

	return xp, xpForNextPoint
end

local function UpdateArtifactBar()
	local HasArtifactEquip = HasArtifactEquipped()

	if not HasArtifactEquip then
		ArtifactBar:Hide()
	else
		local _, _, _, _, TotalExp, PointsSpent, _, _, _, _, _, _ = C_ArtifactUI.GetEquippedArtifactInfo()
		local _, Exp, ExpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(PointsSpent, TotalExp)

		ArtifactBar:SetMinMaxValues(min(0, Exp), ExpForNextPoint)
		ArtifactBar:SetValue(Exp)
		ArtifactBar:Show()
	end
end

ArtifactBar:SetScript("OnEnter", function(self)
	local HasArtifactEquip = HasArtifactEquipped()
	local _, _, _, _, totalxp, pointsSpent, _, _, _, _, _, _ = C_ArtifactUI.GetEquippedArtifactInfo()
	local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalxp)

	Current, Max = GetArtifact()

	if Max == 0 then
		return
	end

	if HasArtifactEquip then
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

		GameTooltip:AddLine(string.format("|cffe6cc80"..ARTIFACT_POWER..": %d / %d (%d%% - %d/%d)|r", Current, Max, Current / Max * 100, Bars - (Bars * (Max - Current) / Max), Bars))
		GameTooltip:AddLine(string.format(L_DATABARS_ARTIFACT_REMANING, xpForNextPoint - xp)) L_DATABARS_ARTIFACT_REMANING = "|cffe6cc80Remaining: %s|r"
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(ARTIFACT_POWER_TOOLTIP_BODY:format(PointsAvailableToSpend), nil, nil, nil, true)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L_DATABARS_ARTIFACT_CLICK)

		GameTooltip:Show()
	end
end)

ArtifactBar:SetScript("OnLeave", function() GameTooltip:Hide() end)

if C.DataBars.ArtifactFade then
	ArtifactBar:SetAlpha(0)
	ArtifactBar:SetScript("OnEnter", function() ArtifactBar:FadeIn() end)
	ArtifactBar:SetScript("OnLeave", function() ArtifactBar:FadeOut() end)
end

ArtifactBar:RegisterEvent("PLAYER_ENTERING_WORLD")
ArtifactBar:RegisterEvent("ARTIFACT_XP_UPDATE")
ArtifactBar:RegisterEvent("UNIT_INVENTORY_CHANGED")

ArtifactBar:SetScript("OnEvent", UpdateArtifactBar)