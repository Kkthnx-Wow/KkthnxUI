local K, C, L = unpack(select(2, ...))
if C.DataBars.HonorEnable ~= true or K.Level ~= MAX_PLAYER_LEVEL then return end

-- WoW Lua
local _G = _G
local format = string.format

-- Wow API
local GetMaxPlayerHonorLevel = GetMaxPlayerHonorLevel
local HideUIPanel = HideUIPanel

local LoadAddOn = LoadAddOn
local PlayerTalentTab_OnClick = PlayerTalentTab_OnClick
local PVP_HONOR_PRESTIGE_AVAILABLE = PVP_HONOR_PRESTIGE_AVAILABLE
local PVP_HONOR_XP_BAR_CANNOT_PRESTIGE_HERE = PVP_HONOR_XP_BAR_CANNOT_PRESTIGE_HERE
local PVP_PRESTIGE_RANK_UP_TITLE = PVP_PRESTIGE_RANK_UP_TITLE
local ShowUIPanel = ShowUIPanel
local TogglePVPUI = TogglePVPUI
local UnitHonor = UnitHonor
local UnitHonorLevel = UnitHonorLevel
local UnitHonorMax = UnitHonorMax
local UnitPrestige = UnitPrestige

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: PVPFrame, PlayerTalentFrame, PVP_TALENTS_TAB, GameTooltip, HONOR, RANK

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

K.CreateBorder(HonorBar, -1)
HonorBar:SetBackdrop({bgFile = C.Media.Blank,insets = {left = -1, right = -1, top = -1, bottom = -1}})
HonorBar:SetBackdropColor(unpack(C.Media.Backdrop_Color))

HonorBar.Text = HonorBar:CreateFontString(nil, "OVERLAY")
HonorBar.Text:SetFont(C.Media.Font, C.Media.Font_Size - 1)
HonorBar.Text:SetShadowOffset(K.Mult, -K.Mult)
HonorBar.Text:SetPoint("CENTER", HonorBar, "CENTER", 0, 0)
HonorBar.Text:SetHeight(C.Media.Font_Size)
HonorBar.Text:SetTextColor(1, 1, 1)
HonorBar.Text:SetJustifyH("CENTER")

if C.Blizzard.ColorTextures == true then
	HonorBar:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
end

HonorBar:SetScript("OnMouseUp", function()
	ToggleTalentFrame(3) --3 is PvP
end)

local function UpdateHonorBar()
	if event == "HONOR_PRESTIGE_UPDATE" and unit ~= "player" then return end
	if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then return end

	local Current, Max = UnitHonor("player"), UnitHonorMax("player")
	local Level, LevelMax = UnitHonorLevel("player"), GetMaxPlayerHonorLevel()
	local ShowHonor = UnitLevel("player") >= MAX_PLAYER_LEVEL

	if event == "PLAYER_REGEN_DISABLED" or InCombatLockdown() then
		ShowHonor = false
	elseif not UnitIsPVP("player") then
		ShowHonor = false
	end

	if not ShowHonor then
		HonorBar:Hide()
	else
		HonorBar:Show()

		if event == "PLAYER_ENTERING_WORLD" then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		end

		-- Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
		if Max == 0 then Max = 1 end

		local Text = ""
		if (CanPrestige()) then
			Text = PVP_HONOR_PRESTIGE_AVAILABLE
		elseif (Level == LevelMax) then
			Text = MAX_HONOR_LEVEL
		else
			Text = format("%d%%", Current / Max * 100)
		end
		if C.DataBars.InfoText then
			HonorBar.Text:SetText(Text)
		else
			HonorBar.Text:SetText(nil)
		end
		HonorBar:SetMinMaxValues(0, Max)
		HonorBar:SetValue(Current)
	end
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
		GameTooltip:AddLine(format("|cffee2222"..HONOR..": %d / %d (%d%% - %d/%d)|r", Current, Max, Current / Max * 100, Bars - (Bars * (Max - Current) / Max), Bars))
		GameTooltip:AddLine(format("|cffcccccc"..RANK..": %d / %d|r", Level, LevelMax))
		GameTooltip:AddLine(format("|cffcccccc"..PVP_PRESTIGE_RANK_UP_TITLE..": %d|r", Prestige))
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L.DataBars.HonorLeftClick)

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
HonorBar:RegisterEvent("PLAYER_REGEN_DISABLED")
HonorBar:RegisterEvent("PLAYER_REGEN_ENABLED")
HonorBar:RegisterEvent("HONOR_XP_UPDATE", UpdateHonorBar)
HonorBar:RegisterEvent("HONOR_PRESTIGE_UPDATE", UpdateHonorBar)
HonorBar:SetScript("OnEvent", UpdateHonorBar)