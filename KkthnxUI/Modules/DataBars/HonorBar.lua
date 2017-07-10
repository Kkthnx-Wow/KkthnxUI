local K, C, L = unpack(select(2, ...))
if C.DataBars.HonorEnable ~= true or K.Level ~= MAX_PLAYER_LEVEL then return end

-- WoW Lua
local _G = _G
local format = string.format

-- Wow API
local CanPrestige = _G.CanPrestige
local GetMaxPlayerHonorLevel = _G.GetMaxPlayerHonorLevel
local GUILD_RECRUITMENT_LEVEL = _G.GUILD_RECRUITMENT_LEVEL
local HideUIPanel = _G.HideUIPanel
local LoadAddOn = _G.LoadAddOn
local MAX_HONOR_LEVEL = _G.MAX_HONOR_LEVEL
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local PlayerTalentTab_OnClick = _G.PlayerTalentTab_OnClick
local PVP_HONOR_PRESTIGE_AVAILABLE = _G.PVP_HONOR_PRESTIGE_AVAILABLE
local PVP_HONOR_XP_BAR_CANNOT_PRESTIGE_HERE = _G.PVP_HONOR_XP_BAR_CANNOT_PRESTIGE_HERE
local PVP_PRESTIGE_RANK_UP_TITLE = _G.PVP_PRESTIGE_RANK_UP_TITLE
local ShowUIPanel = _G.ShowUIPanel
local TogglePVPUI = _G.TogglePVPUI
local UnitHonor = _G.UnitHonor
local UnitHonorLevel = _G.UnitHonorLevel
local UnitHonorMax = _G.UnitHonorMax
local UnitLevel = _G.UnitLevel
local UnitPrestige = _G.UnitPrestige

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: PVPFrame, PlayerTalentFrame, PVP_TALENTS_TAB, GameTooltip, HONOR, RANK, ToggleTalentFrame

local Bars = 20
local Movers = K.Movers

local Anchor = CreateFrame("Frame", "HonorAnchor", UIParent)
Anchor:SetSize(C.DataBars.HonorWidth, C.DataBars.HonorHeight)
Anchor:SetPoint("TOP", Minimap, "BOTTOM", 0, -50)
Movers:RegisterFrame(Anchor)

local HonorBar = CreateFrame("StatusBar", nil, UIParent)
HonorBar:SetOrientation("HORIZONTAL")
HonorBar:SetSize(C.DataBars.HonorWidth, C.DataBars.HonorHeight)
HonorBar:SetPoint("CENTER", HonorAnchor, "CENTER", 0, 0)
HonorBar:SetStatusBarTexture(C.Media.Texture)
HonorBar:SetStatusBarColor(unpack(C.DataBars.HonorColor))
HonorBar:SetMinMaxValues(0, 325)

HonorBar.Spark = HonorBar:CreateTexture(nil, "ARTWORK", nil, 1)
HonorBar.Spark:SetSize(C.DataBars.HonorHeight, C.DataBars.HonorHeight * 2)
HonorBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
HonorBar.Spark:SetPoint("CENTER", HonorBar:GetStatusBarTexture(), "RIGHT", 0, 0)
HonorBar.Spark:SetAlpha(0.6)
HonorBar.Spark:SetBlendMode("ADD")

K.CreateBorder(HonorBar, -1)
HonorBar:SetBackdrop({bgFile = C.Media.Blank,insets = {left = -1, right = -1, top = -1, bottom = -1}})
HonorBar:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])

HonorBar.Text = K.SetFontString(HonorBar, C.Media.Font, C.Media.Font_Size - 1, C.DataBars.Outline and "OUTLINE" or "", "CENTER")
HonorBar.Text:SetShadowOffset(C.DataBars.Outline and 0 or 1.25, C.DataBars.Outline and -0 or -1.25)
HonorBar.Text:SetPoint("CENTER", HonorBar, "CENTER", 0, 0)
HonorBar.Text:SetHeight(C.Media.Font_Size)
HonorBar.Text:SetTextColor(1, 1, 1)
HonorBar.Text:SetJustifyH("CENTER")

if C.Blizzard.ColorTextures == true then
	HonorBar:SetBackdropBorderColor(C.Blizzard.TexturesColor[1], C.Blizzard.TexturesColor[2], C.Blizzard.TexturesColor[3])
end

HonorBar:SetScript("OnMouseDown", function()
	ToggleTalentFrame(3) -- 3 is PvP
end)

local function UpdateHonorBar(event, unit)
	if event == "HONOR_PRESTIGE_UPDATE" and unit ~= "player" then return end
	if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then return end

	local ShowHonor = UnitLevel("player") >= MAX_PLAYER_LEVEL

	if not ShowHonor then
		HonorBar:Hide()
	else
		HonorBar:Show()

		local Current, Max = UnitHonor("player"), UnitHonorMax("player")
		local Level, LevelMax = UnitHonorLevel("player"), GetMaxPlayerHonorLevel()

		-- Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
		if Max == 0 then Max = 1 end

		if (Level == LevelMax) then
			-- Force the bar to full for the max level
			HonorBar:SetMinMaxValues(0, 1)
			HonorBar:SetValue(1)
		else
			HonorBar:SetMinMaxValues(0, Max)
			HonorBar:SetValue(Current)
		end

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
			HonorBar.Text:SetText("")
		end
	end
end

local PRESTIGE_TEXT = PVP_PRESTIGE_RANK_UP_TITLE..HEADER_COLON
HonorBar:SetScript("OnEnter", function(self)
	local Current, Max = UnitHonor("player"), UnitHonorMax("player")
	local Level = UnitHonorLevel("player")
	local LevelMax = GetMaxPlayerHonorLevel()
	local PrestigeLevel = UnitPrestige("player")

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))
	GameTooltip:ClearLines()

	GameTooltip:AddLine(HONOR)
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(GUILD_RECRUITMENT_LEVEL..":", Level, 1, 1, 1)
	GameTooltip:AddDoubleLine(PRESTIGE_TEXT, PrestigeLevel, 1, 1, 1)
	GameTooltip:AddLine(" ")

	if Max == 0 then Max = 1 end

	if (CanPrestige()) then
		GameTooltip:AddLine(PVP_HONOR_PRESTIGE_AVAILABLE)
	elseif (Level == LevelMax) then
		GameTooltip:AddLine(MAX_HONOR_LEVEL)
	else
		GameTooltip:AddDoubleLine("Honor XP:", format(" %d / %d (%d%%)", Current, Max, Current/Max * 100), 1, 1, 1)
		GameTooltip:AddDoubleLine("Honor Remaining:", format(" %d (%d%% - %d ".."Bars"..")", Max - Current, (Max - Current) / Max * 100, 20 * (Max - Current) / Max), 1, 1, 1)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L["<Left-Click to toggle Honor Window>"])

	GameTooltip:Show()
end)

if C.DataBars.HonorFade then
	HonorBar:SetAlpha(0)
	HonorBar:HookScript("OnEnter", function(self) K.UIFrameFadeIn(self, 0.4, self:GetAlpha(), 1) end)
	HonorBar:HookScript("OnLeave", function(self) self:SetAlpha(0) GameTooltip:Hide() end)
	HonorBar.Tooltip = true
else
	HonorBar:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

HonorBar:RegisterEvent("PLAYER_LOGIN")
HonorBar:RegisterEvent("HONOR_XP_UPDATE")
HonorBar:RegisterEvent("HONOR_PRESTIGE_UPDATE")
HonorBar:RegisterEvent("PLAYER_FLAGS_CHANGED")
HonorBar:SetScript("OnEvent", UpdateHonorBar)