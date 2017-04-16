local K, C, L = unpack(select(2, ...))
if C.DataBars.ExperienceEnable ~= true or K.Level == MAX_PLAYER_LEVEL then return end

-- WoW Lua
local _G = _G
local format = string.format
local unpack = unpack

-- Wow API
local GetExpansionLevel = _G.GetExpansionLevel
local GetRestState = _G.GetRestState
local GetXPExhaustion = _G.GetXPExhaustion
local IsXPUserDisabled = _G.IsXPUserDisabled
local MAX_PLAYER_LEVEL_TABLE = _G.MAX_PLAYER_LEVEL_TABLE
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CreateFrame, XP, TUTORIAL_TITLE26, GameTooltip

local Bars = 20
local Movers = K.Movers

-- Temp fix for a backdrop atm.
local function XPBackdrop(f)
	if f.backdrop then return end

	local b = CreateFrame("Frame", nil, f)
	b:SetPoint("TOPLEFT", -1, 1)
	b:SetPoint("BOTTOMRIGHT", 1, -1)
	b:SetBackdrop({bgFile = C.Media.Blank})
	b:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end

	f.backdrop = b
end

local Anchor = CreateFrame("Frame", "ExperienceAnchor", UIParent)
Anchor:SetSize(C.DataBars.ExperienceWidth, C.DataBars.ExperienceHeight)
Anchor:SetPoint("TOP", Minimap, "BOTTOM", 0, -33)
K.Movers:RegisterFrame(Anchor)

local ExperienceBar = CreateFrame("StatusBar", nil, UIParent)

K.CreateBorder(ExperienceBar, -1)
XPBackdrop(ExperienceBar)
ExperienceBar:SetOrientation("HORIZONTAL")
ExperienceBar:SetSize(C.DataBars.ExperienceWidth, C.DataBars.ExperienceHeight)
ExperienceBar:SetParent(UIParent)
ExperienceBar:ClearAllPoints()
ExperienceBar:SetPoint("CENTER", Anchor, "CENTER", 0, 0)
ExperienceBar:SetStatusBarTexture(C.Media.Texture)
ExperienceBar:SetStatusBarColor(unpack(C.DataBars.ExperienceColor))

local ExperienceBarRested = CreateFrame("StatusBar", nil, ExperienceBar)
ExperienceBarRested:SetOrientation("HORIZONTAL")
ExperienceBarRested:SetSize(C.DataBars.ExperienceWidth, C.DataBars.ExperienceHeight)
ExperienceBarRested:SetParent(ExperienceBar)
ExperienceBarRested:SetAllPoints()
ExperienceBarRested:SetStatusBarTexture(C.Media.Texture)
ExperienceBarRested:SetStatusBarColor(unpack(C.DataBars.ExperienceRestedColor))

ExperienceBar.Spark = ExperienceBar:CreateTexture(nil, "ARTWORK", nil, 1)
ExperienceBar.Spark:SetSize(C.DataBars.ExperienceHeight, C.DataBars.ExperienceHeight * 2)
ExperienceBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
ExperienceBar.Spark:SetPoint("CENTER", ExperienceBar:GetStatusBarTexture(), "RIGHT", 0, 0)
ExperienceBar.Spark:SetAlpha(0.6)
ExperienceBar.Spark:SetBlendMode("ADD")

ExperienceBar.Text = ExperienceBar:CreateFontString(nil, "OVERLAY")
ExperienceBar.Text:SetFont(C.Media.Font, C.Media.Font_Size - 1)
ExperienceBar.Text:SetShadowOffset(K.Mult, -K.Mult)
ExperienceBar.Text:SetPoint("CENTER", ExperienceBar, "CENTER", 0, 0)
ExperienceBar.Text:SetHeight(C.Media.Font_Size)
ExperienceBar.Text:SetTextColor(1, 1, 1)
ExperienceBar.Text:SetJustifyH("CENTER")

if C.Blizzard.ColorTextures == true then
	ExperienceBar:SetBackdropBorderColor(C.Blizzard.TexturesColor[1], C.Blizzard.TexturesColor[2], C.Blizzard.TexturesColor[3])
end

local function UpdateExperienceBar()
	local Current, Max = UnitXP("player"), UnitXPMax("player")
	local Rested = GetXPExhaustion()
	local IsRested = GetRestState()
	local HideXP = ((UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) or IsXPUserDisabled())

	if HideXP then
		ExperienceBar:Hide()
	elseif not HideXP then
		ExperienceBar:Show()

		local Text = ""
		if Rested and Rested > 0 then
			Text = format("%d%% R:%d%%", Current / Max * 100, Rested / Max * 100)
		else
			Text = format("%d%%", Current / Max * 100)
		end

		if C.DataBars.InfoText then
			ExperienceBar.Text:SetText(Text)
		else
			ExperienceBar.Text:SetText("")
		end

		ExperienceBar:SetMinMaxValues(0, Max)
		ExperienceBar:SetValue(Current)

		if (IsRested == 1 and Rested) then
			ExperienceBar:RegisterEvent("UPDATE_EXHAUSTION")
			ExperienceBarRested:SetFrameLevel(ExperienceBar:GetFrameLevel() - 1)
			ExperienceBarRested:SetMinMaxValues(0, Max)
			ExperienceBarRested:SetValue(Rested + Current)
		else
			ExperienceBar:UnregisterEvent("UPDATE_EXHAUSTION")
			ExperienceBarRested:Hide()
		end
	end
end

ExperienceBar:SetScript("OnEnter", function(self)
	local Current, Max = UnitXP("player"), UnitXPMax("player")
	local Rested = GetXPExhaustion()
	local IsRested = GetRestState()

	if Max == 0 then
		return
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	GameTooltip:AddLine("Experience")
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine("XP:", format(" %d / %d (%d%%)", Current, Max, Current/Max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine("Remaining:", format(" %d (%d%% - %d ".."Bars"..")", Max - Current, (Max - Current) / Max * 100, 20 * (Max - Current) / Max), 1, 1, 1)

	if (IsRested == 1 and Rested) then
		GameTooltip:AddDoubleLine("Rested:", format("+%d (%d%%)", Rested, Rested / Max * 100), 1, 1, 1)
	end

	GameTooltip:Show()
end)

if C.DataBars.ExperienceFade then
	ExperienceBar:SetAlpha(0)
	ExperienceBar:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
	ExperienceBar:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
	ExperienceBar.Tooltip = true
end

ExperienceBar:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)
function ExperienceBar:PLAYER_LEVEL_UP(level)
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
	if (level ~= maxLevel) and C.DataBars.ExperienceEnable then
		UpdateExperienceBar("PLAYER_LEVEL_UP", level)
	else
		ExperienceBar:Hide()
	end
end

ExperienceBar:RegisterEvent("PLAYER_LOGIN")
ExperienceBar:RegisterEvent("PLAYER_XP_UPDATE")
ExperienceBar:RegisterEvent("DISABLE_XP_GAIN")
ExperienceBar:RegisterEvent("ENABLE_XP_GAIN")
ExperienceBar:RegisterEvent("UPDATE_EXHAUSTION")
ExperienceBar:RegisterEvent("PLAYER_LEVEL_UP")
-- be careful with this.
ExperienceBar:UnregisterEvent("UPDATE_EXPANSION_LEVEL")
ExperienceBar:SetScript("OnLeave", function() GameTooltip:Hide() end)
ExperienceBar:SetScript("OnEvent", UpdateExperienceBar)