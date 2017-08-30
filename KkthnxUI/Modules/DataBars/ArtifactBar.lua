local K, C, L = unpack(select(2, ...))
if C.DataBars.ArtifactEnable ~= true or K.Level <= 99 then return end

-- WoW Lua
local _G = _G
local format = string.format
local min = math.min

-- Wow API
local ARTIFACT_POWER = _G.ARTIFACT_POWER
local ARTIFACT_POWER_TOOLTIP_BODY = _G.ARTIFACT_POWER_TOOLTIP_BODY
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
local C_ArtifactUI_GetEquippedArtifactInfo = _G.C_ArtifactUI.GetEquippedArtifactInfo
local HasArtifactEquipped = _G.HasArtifactEquipped
local HideUIPanel = _G.HideUIPanel
local LoadAddOn = _G.LoadAddOn
local MainMenuBar_GetNumArtifactTraitsPurchasableFromXP = _G.MainMenuBar_GetNumArtifactTraitsPurchasableFromXP
local ShowUIPanel = _G.ShowUIPanel
local SocketInventoryItem = _G.SocketInventoryItem

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: GameTooltip, ArtifactFrame, C_ArtifactUI, Max, Current

local Bars = 20
local Movers = K.Movers

local Anchor = CreateFrame("Frame", "ArtifactAnchor", UIParent)
local AnchorY
if K.Level ~= MAX_PLAYER_LEVEL then
	AnchorY = -50
else
	AnchorY = -34
end
Anchor:SetSize(C.DataBars.ArtifactWidth, C.DataBars.ArtifactHeight)
Anchor:SetPoint("TOP", Minimap, "BOTTOM", 0, AnchorY)
Movers:RegisterFrame(Anchor, C.DataBars.ArtifactWidth, C.DataBars.ArtifactHeight)

local ArtifactBar = CreateFrame("StatusBar", nil, UIParent)
ArtifactBar:SetOrientation("HORIZONTAL")
ArtifactBar:SetSize(C.DataBars.ArtifactWidth, C.DataBars.ArtifactHeight)
ArtifactBar:SetPoint("CENTER", ArtifactAnchor, "CENTER", 0, 0)
ArtifactBar:SetStatusBarTexture(C.Media.Texture)
ArtifactBar:SetStatusBarColor(unpack(C.DataBars.ArtifactColor))
ArtifactBar:SetMinMaxValues(0, 325)

ArtifactBar.Spark = ArtifactBar:CreateTexture(nil, "ARTWORK", nil, 1)
ArtifactBar.Spark:SetSize(C.DataBars.ArtifactHeight, C.DataBars.ArtifactHeight * 2)
ArtifactBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
ArtifactBar.Spark:SetPoint("CENTER", ArtifactBar:GetStatusBarTexture(), "RIGHT", 0, 0)
ArtifactBar.Spark:SetAlpha(0.6)
ArtifactBar.Spark:SetBlendMode("ADD")

K.CreateBorder(ArtifactBar, -1)
ArtifactBar:SetBackdrop({bgFile = C.Media.Blank,insets = {left = -1, right = -1, top = -1, bottom = -1}})
ArtifactBar:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])

ArtifactBar.Text = K.SetFontString(ArtifactBar, C.Media.Font, C.Media.Font_Size - 1, C.DataBars.Outline and "OUTLINE" or "", "CENTER")
ArtifactBar.Text:SetShadowOffset(C.DataBars.Outline and 0 or 1.25, C.DataBars.Outline and -0 or -1.25)
ArtifactBar.Text:SetPoint("CENTER", ArtifactBar, "CENTER", 0, 0)
ArtifactBar.Text:SetHeight(C.Media.Font_Size)
ArtifactBar.Text:SetTextColor(1, 1, 1)
ArtifactBar.Text:SetJustifyH("CENTER")

if C.Blizzard.ColorTextures == true then
	ArtifactBar:SetBackdropBorderColor(C.Blizzard.TexturesColor[1], C.Blizzard.TexturesColor[2], C.Blizzard.TexturesColor[3])
end

ArtifactBar:SetScript("OnMouseDown", function()
	if not ArtifactFrame or not ArtifactFrame:IsShown() then
		ShowUIPanel(SocketInventoryItem(16))
	elseif ArtifactFrame and ArtifactFrame:IsShown() then
		HideUIPanel(ArtifactFrame)
	end
end)

local function GetArtifact()
	local itemID, altItemID, name, icon, totalXP, pointsSpent, quality, artifactAppearanceID, appearanceModID, itemAppearanceID, altItemAppearanceID, altOnTop, ArtifactTier = C_ArtifactUI_GetEquippedArtifactInfo()
	local numPointsAvailableToSpend, xp, xpForNextPoint
	if K.WoWBuild >= 23623 then --7.2
		numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, ArtifactTier)
	else
		numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
	end

	return xp, xpForNextPoint
end

local function UpdateArtifactBar(event, unit)
	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
	end
	local HasArtifactEquip = HasArtifactEquipped()

	if not HasArtifactEquip then
		ArtifactBar:Hide()
	elseif HasArtifactEquip then
		ArtifactBar:Show()

		local _, _, _, _, TotalExp, PointsSpent, _, _, _, _, _, _, ArtifactTier = C_ArtifactUI_GetEquippedArtifactInfo()
		local _, Exp, ExpForNextPoint
		if K.WoWBuild >= 23623 then --7.2
			_, Exp, ExpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(PointsSpent, TotalExp, ArtifactTier)
		else
			_, Exp, ExpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(PointsSpent, TotalExp)
		end

		ArtifactBar:SetMinMaxValues(0, ExpForNextPoint)
		ArtifactBar:SetValue(Exp)

		local Text = format("%d%%", Exp / ExpForNextPoint * 100)
		if C.DataBars.InfoText then
			ArtifactBar.Text:SetText(Text)
		else
			ArtifactBar.Text:SetText("")
		end
	end
end

ArtifactBar:SetScript("OnEnter", function(self)
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))

	local _, _, artifactName, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo()

	local numPointsAvailableToSpend, xp, xpForNextPoint
	if K.WoWBuild >= 23623 then --7.2
		numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)
	else
		numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP)
	end

	local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)
	local remaining = xpForNextPoint - xp

	GameTooltip:AddDoubleLine(ARTIFACT_POWER, artifactName, nil, nil, nil, 0.90, 0.80,	0.50)
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine("XP:", format(" %s / %s (%d%%)", BreakUpLargeNumbers(xp), BreakUpLargeNumbers(xpForNextPoint), xp/xpForNextPoint * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine("Remaining:", format(" %s (%d%% - %d %s)", BreakUpLargeNumbers(xpForNextPoint - xp), remaining / xpForNextPoint * 100, 20 * remaining / xpForNextPoint, "Bars"), 1, 1, 1)

	if (numPointsAvailableToSpend > 0) then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(format(ARTIFACT_POWER_TOOLTIP_BODY, numPointsAvailableToSpend), nil, nil, nil, true)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["<Left-Click to toggle Artifact Window>"])
	GameTooltip:Show()
end)

if C.DataBars.ArtifactFade then
	ArtifactBar:SetAlpha(0)
	ArtifactBar:HookScript("OnEnter", function(self) K.UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1) end)
	ArtifactBar:HookScript("OnLeave", function(self) self:SetAlpha(0) GameTooltip:Hide() end)
	ArtifactBar.Tooltip = true
else
	ArtifactBar:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

ArtifactBar:RegisterEvent("PLAYER_LOGIN")
ArtifactBar:RegisterEvent("ARTIFACT_XP_UPDATE")
ArtifactBar:RegisterEvent("UNIT_INVENTORY_CHANGED")
ArtifactBar:SetScript("OnEvent", UpdateArtifactBar)