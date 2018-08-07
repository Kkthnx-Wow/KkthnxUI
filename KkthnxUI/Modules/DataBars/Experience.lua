local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Experience", "AceEvent-3.0")

-- Sourced: ElvUI (Elvz)

local _G = _G
local math_min = math.min
local string_format = string.format

local GetExpansionLevel = _G.GetExpansionLevel
local GetPetExperience, UnitXP, UnitXPMax = _G.GetPetExperience, _G.UnitXP, _G.UnitXPMax
local IsXPUserDisabled, GetXPExhaustion = _G.IsXPUserDisabled, _G.GetXPExhaustion
local MAX_PLAYER_LEVEL_TABLE = _G.MAX_PLAYER_LEVEL_TABLE
local UnitLevel = _G.UnitLevel

function Module:GetXP(unit)
	if (unit == "pet") then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

function Module:UpdateExperience()
	if C["DataBars"].ExperienceEnable ~= true then
		return
	end

	local bar = self.expBar
	local hideXP = ((UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) or IsXPUserDisabled())

	if hideXP then
		bar:Hide()
	elseif not hideXP then
		bar:Show()

		local cur, max = self:GetXP("player")
		if max <= 0 then
			max = 1
		end

		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur - 1 >= 0 and cur - 1 or 0)
		bar.statusBar:SetValue(cur)

		local rested = GetXPExhaustion()
		local text

		if rested and rested > 0 then
			bar.rested:SetMinMaxValues(0, max)
			bar.rested:SetValue(math_min(cur + rested, max))

			text = string_format("%d%% R:%d%%", cur / max * 100, rested / max * 100)
		else
			bar.rested:SetMinMaxValues(0, 1)
			bar.rested:SetValue(0)

			text = string_format("%d%%", cur / max * 100)
		end

		bar.text:SetText(text)
	end
end

function Module:ExperienceBar_OnEnter()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)

	local cur, max = Module:GetXP("player")
	local rested = GetXPExhaustion()
	GameTooltip:AddDoubleLine(L["Databars"].Experience)
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(L["Databars"].XP, string_format("%s / %s (%s%%)", K.ShortValue(cur), K.ShortValue(max), math.floor(cur / max * 100)), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Databars"].Remaining, string_format("%s (%s%% - %s "..L["Databars"].Bars..")", K.ShortValue(max - cur),  math.floor((max - cur) / max * 100),  math.floor(20 * (max - cur) / max)), 1, 1, 1)

	if rested then
		GameTooltip:AddDoubleLine(L["Databars"].Rested, string_format("+%s (%s%%)", K.ShortValue(rested), math.floor(rested / max * 100)), 1, 1, 1)
	end

	GameTooltip:Show()
end

function Module:ExperienceBar_OnLeave()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
	end

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end

function Module:UpdateExperienceDimensions()
	local ExperienceFont = K.GetFont(C["DataBars"].Font)

	self.expBar:SetSize(Minimap:GetWidth() or C["DataBars"].ExperienceWidth, C["DataBars"].ExperienceHeight)
	self.expBar.text:SetFontObject(ExperienceFont)
	self.expBar.text:SetFont(select(1, self.expBar.text:GetFont()), 11, select(3, self.expBar.text:GetFont()))
	self.expBar.spark:SetSize(16, self.expBar:GetHeight())

	if C["DataBars"].MouseOver then
		self.expBar:SetAlpha(0.25)
	else
		self.expBar:SetAlpha(1)
	end
end

function Module:PLAYER_LEVEL_UP(level)
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
	if (level ~= maxLevel) and C["DataBars"].ExperienceEnable then
		self:UpdateExperience("PLAYER_LEVEL_UP", level)
	else
		self.expBar:Hide()
	end
end

function Module:EnableDisable_ExperienceBar()
	local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
	if (UnitLevel("player") ~= maxLevel) and C["DataBars"].ExperienceEnable then
		self:RegisterEvent("PLAYER_XP_UPDATE", "UpdateExperience")
		self:RegisterEvent("DISABLE_XP_GAIN", "UpdateExperience")
		self:RegisterEvent("ENABLE_XP_GAIN", "UpdateExperience")
		self:RegisterEvent("UPDATE_EXHAUSTION", "UpdateExperience")
		self:UnregisterEvent("UPDATE_EXPANSION_LEVEL")
		self:UpdateExperience()
	else
		self:UnregisterEvent("PLAYER_XP_UPDATE")
		self:UnregisterEvent("DISABLE_XP_GAIN")
		self:UnregisterEvent("ENABLE_XP_GAIN")
		self:UnregisterEvent("UPDATE_EXHAUSTION")
		self:RegisterEvent("UPDATE_EXPANSION_LEVEL", "EnableDisable_ExperienceBar")
		self.expBar:Hide()
	end
end

function Module:OnEnable()
	local ExperienceFont = K.GetFont(C["DataBars"].Font)
	local ExperienceTexture = K.GetTexture(C["DataBars"].Texture)

	self.expBar = CreateFrame("Button", "Experience", K.PetBattleHider)
	self.expBar:SetPoint("TOP", Minimap, "BOTTOM", 0, -6)
	self.expBar:SetScript("OnEnter", Module.ExperienceBar_OnEnter)
	self.expBar:SetScript("OnLeave", Module.ExperienceBar_OnLeave)
	self.expBar:SetFrameStrata("LOW")
	self.expBar:Hide()

	self.expBar.statusBar = CreateFrame("StatusBar", nil, self.expBar)
	self.expBar.statusBar:SetAllPoints()
	self.expBar.statusBar:SetStatusBarTexture(ExperienceTexture)
	self.expBar.statusBar:SetStatusBarColor(C["DataBars"].ExperienceColor[1], C["DataBars"].ExperienceColor[2], C["DataBars"].ExperienceColor[3], C["DataBars"].ExperienceColor[4])

	self.expBar.statusBar.Backgrounds = self.expBar.statusBar:CreateTexture(nil, "BACKGROUND", -1)
	self.expBar.statusBar.Backgrounds:SetAllPoints()
	self.expBar.statusBar.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	K.CreateBorder(self.expBar.statusBar)

	self.expBar.rested = CreateFrame("StatusBar", nil, self.expBar)
	self.expBar.rested:SetAllPoints()
	self.expBar.rested:SetStatusBarTexture(ExperienceTexture)
	self.expBar.rested:SetStatusBarColor(C["DataBars"].ExperienceRestedColor[1], C["DataBars"].ExperienceRestedColor[2], C["DataBars"].ExperienceRestedColor[3], C["DataBars"].ExperienceRestedColor[4])
	self.expBar.rested:SetFrameLevel(self.expBar.statusBar:GetFrameLevel())

	self.expBar.text = self.expBar.statusBar:CreateFontString(nil, "OVERLAY")
	self.expBar.text:SetFontObject(ExperienceFont)
	self.expBar.text:SetFont(select(1, self.expBar.text:GetFont()), 11, select(3, self.expBar.text:GetFont()))
	self.expBar.text:SetPoint("CENTER")

	self.expBar.spark = self.expBar.statusBar:CreateTexture(nil, "OVERLAY")
	self.expBar.spark:SetTexture(C["Media"].Spark_16)
	self.expBar.spark:SetBlendMode("ADD")
	self.expBar.spark:SetPoint("CENTER", self.expBar.statusBar:GetStatusBarTexture(), "RIGHT", 0, 0)

	self.expBar.eventFrame = CreateFrame("Frame")
	self.expBar.eventFrame:Hide()
	self.expBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.expBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.expBar.eventFrame:SetScript("OnEvent", function(_, event)
		Module:UpdateExperience(event)
	end)

	self:UpdateExperienceDimensions()

	self:RegisterEvent("PLAYER_LEVEL_UP")

	K.Movers:RegisterFrame(self.expBar)
	self:EnableDisable_ExperienceBar()
end
