local K, C, L = select(2, ...):unpack()
if C.DataBars.HonorEnable ~= true or K.Level ~= MAX_PLAYER_LEVEL then return end

local UnitHonor = UnitHonor
local UnitHonorMax = UnitHonorMax
local UnitHonorLevel = UnitHonorLevel
local GetMaxPlayerHonorLevel = GetMaxPlayerHonorLevel
local UnitPrestige = UnitPrestige
local TogglePVPUI = TogglePVPUI
local LoadAddOn = LoadAddOn
local IsAddOnLoaded = IsAddOnLoaded

local Bars = 20
local Movers = K.Movers

local Anchor = CreateFrame("Frame", "HonorAnchor", UIParent)
Anchor:SetSize(C.DataBars.HonorWidth, C.DataBars.HonorHeight)
Anchor:SetPoint("TOP", Minimap, "BOTTOM", 0, -48)
Movers:RegisterFrame(Anchor)

local HonorBar = CreateFrame("StatusBar", nil, UIParent)
HonorBar:SetOrientation("HORIZONTAL")
HonorBar:SetSize(C.DataBars.HonorWidth, C.DataBars.HonorHeight)
HonorBar:SetPoint("CENTER", HonorAnchor, "CENTER", 0, 0)
HonorBar:SetStatusBarTexture(C.Media.Texture)
HonorBar:SetStatusBarColor(unpack(C.DataBars.HonorColor))

K.CreateBorder(HonorBar, 10, 3)
HonorBar:SetBackdrop({bgFile = C.Media.Blank,insets = {left = -1, right = -1, top = -1, bottom = -1}})
HonorBar:SetBackdropColor(unpack(C.Media.Backdrop_Color))

if C.Blizzard.ColorTextures == true then
	HonorBar:SetBorderTexture("white")
	HonorBar:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
end

HonorBar:SetScript("OnMouseDown", function(self, button)
	if (button == "LeftButton") then
		if not PVPFrame then
			LoadAddOn("Blizzard_PVPUI")
		end
		if PVPFrame and PVPFrame:IsShown() then TogglePVPUI()
		else
			TogglePVPUI()
		end
	elseif(button == "RightButton") then

		if(not IsAddOnLoaded("Blizzard_TalentUI")) then
			LoadAddOn("Blizzard_TalentUI")
		end

		if not PlayerTalentFrame:IsShown() then
			ShowUIPanel(PlayerTalentFrame)
			PlayerTalentTab_OnClick(_G["PlayerTalentFrameTab" .. PVP_TALENTS_TAB])
		else
			HideUIPanel(PlayerTalentFrame)
		end
	end
end)

local function UpdateHonorBar()
	local Current, Max = UnitHonor("player"), UnitHonorMax("player")
	HonorBar:SetMinMaxValues(0, Max)
	HonorBar:SetValue(Current)
end

HonorBar:SetScript("OnEnter", function(self)
	local Current, Max = UnitHonor("player"), UnitHonorMax("player")
	local Level = UnitHonorLevel("player")
	local LevelMax = GetMaxPlayerHonorLevel()
	local Prestige = UnitPrestige("player")

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	if Max == 0 then
		GameTooltip:AddLine(PVP_HONOR_PRESTIGE_AVAILABLE)
		GameTooltip:AddLine(PVP_HONOR_XP_BAR_CANNOT_PRESTIGE_HERE)
	else
		GameTooltip:AddLine(string.format("|cffee2222"..HONOR..": %d / %d (%d%% - %d/%d)|r", Current, Max, Current / Max * 100, Bars - (Bars * (Max - Current) / Max), Bars))
		GameTooltip:AddLine(string.format("|cffcccccc"..RANK..": %d / %d|r", Level, LevelMax))
		GameTooltip:AddLine(string.format("|cffcccccc"..PVP_PRESTIGE_RANK_UP_TITLE..": %d|r", Prestige))
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L.DataBars.HonorLeftClick)
	GameTooltip:AddLine(L.DataBars.HonorRightClick)

	GameTooltip:Show()
end)

HonorBar:SetScript("OnLeave", function() GameTooltip:Hide() end)

if C.DataBars.HonorFade then
	HonorBar:SetAlpha(0)
	HonorBar:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
	HonorBar:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
	HonorBar.Tooltip = true
end

HonorBar:RegisterEvent("PLAYER_ENTERING_WORLD")
HonorBar:RegisterEvent("HONOR_XP_UPDATE")
HonorBar:RegisterEvent("HONOR_LEVEL_UPDATE")
HonorBar:RegisterEvent("HONOR_PRESTIGE_UPDATE")

HonorBar:SetScript("OnEvent", UpdateHonorBar)