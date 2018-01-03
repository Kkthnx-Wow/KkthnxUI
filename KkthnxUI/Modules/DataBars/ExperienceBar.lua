local K, C, L = unpack(select(2, ...))

local Module = K:NewModule("Experience_DataBar", "AceEvent-3.0")

local _G = _G
local format = format
local min = min

local GetPetExperience, UnitXP, UnitXPMax = GetPetExperience, UnitXP, UnitXPMax
local UnitLevel = UnitLevel
local IsXPUserDisabled, GetXPExhaustion = IsXPUserDisabled, GetXPExhaustion
local GetExpansionLevel = GetExpansionLevel
local MAX_PLAYER_LEVEL_TABLE = MAX_PLAYER_LEVEL_TABLE
local InCombatLockdown = InCombatLockdown

local ExperienceFont = K.GetFont(C["DataBars"].Font)
local ExperienceTexture = K.GetTexture(C["DataBars"].Texture)

function Module:GetXP(unit)
	if(unit == "pet") then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

function Module:UpdateExperience(event)
	if C["DataBars"].ExperienceEnable ~= true then return end

	local bar = self.expBar
	local hideXP = ((UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) or IsXPUserDisabled())

	if hideXP then
		bar:Hide()
	elseif not hideXP then
		bar:Show()

		local cur, max = self:GetXP("player")
		if max <= 0 then max = 1 end
		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(cur - 1 >= 0 and cur - 1 or 0)
		bar.statusBar:SetValue(cur)

		local rested = GetXPExhaustion()
		local text = ""

		if rested and rested > 0 then
			bar.rested:SetMinMaxValues(0, max)
			bar.rested:SetValue(min(cur + rested, max))

			text = format("%d%% R:%d%%", cur / max * 100, rested / max * 100)
		else
			bar.rested:SetMinMaxValues(0, 1)
			bar.rested:SetValue(0)

			text = format("%d%%", cur / max * 100)
		end

		bar.text:SetText(text)
	end
end

function Module:ExperienceBar_OnEnter()
	GameTooltip:ClearLines()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)

	local cur, max = Module:GetXP("player")
	local rested = GetXPExhaustion()
	GameTooltip:AddLine("Experience")
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine("XP:", format(" %d / %d (%d%%)", cur, max, cur/max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine("Remaining:", format(" %d (%d%% - %d ".."Bars"..")", max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)

	if rested then
		GameTooltip:AddDoubleLine("XP:", format("+%d (%d%%)", rested, rested / max * 100), 1, 1, 1)
	end

	GameTooltip:Show()
end

function Module:ExperienceBar_OnLeave()
	GameTooltip:Hide()
end

function Module:UpdateExperienceDimensions()
	self.expBar:SetSize(Minimap:GetWidth() or C["DataBars"].ExperienceWidth, C["DataBars"].ExperienceHeight)
	self.expBar.text:SetFont(C["Media"].Font, C["Media"].FontSize - 1, C["DataBars"].Outline and "OUTLINE" or "", "CENTER")
	self.expBar.text:SetShadowOffset(C["DataBars"].Outline and 0 or 1.25, C["DataBars"].Outline and -0 or -1.25)
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
	self.expBar = CreateFrame("Button", "KkthnxUI_ExperienceBar", UIParent)
	self.expBar:SetPoint("TOP", Minimap, "BOTTOM", 0, -6)
	self.expBar:SetScript("OnEnter", Module.ExperienceBar_OnEnter)
	self.expBar:SetScript("OnLeave", Module.ExperienceBar_OnLeave)
	self.expBar:SetFrameStrata("LOW")
	self.expBar:Hide()

	self.expBar.statusBar = CreateFrame("StatusBar", nil, self.expBar)
	self.expBar.statusBar:SetAllPoints()
	self.expBar.statusBar:SetStatusBarTexture(ExperienceTexture)
	self.expBar.statusBar:SetStatusBarColor(0, 0.4, 1, .8)
	self.expBar.statusBar:SetTemplate("Transparent")

	self.expBar.rested = CreateFrame("StatusBar", nil, self.expBar)
	self.expBar.rested:SetAllPoints()
	self.expBar.rested:SetStatusBarTexture(ExperienceTexture)
	self.expBar.rested:SetStatusBarColor(1, 0, 1, 0.2)
	self.expBar.rested:SetFrameLevel(self.expBar.statusBar:GetFrameLevel())

	self.expBar.text = self.expBar.statusBar:CreateFontString(nil, "OVERLAY")
	self.expBar.text:SetFont(C["Media"].Font, C["Media"].FontSize - 1, C["DataBars"].Outline and "OUTLINE" or "", "CENTER")
	self.expBar.text:SetShadowOffset(C["DataBars"].Outline and 0 or 1.25, C["DataBars"].Outline and -0 or -1.25)
	self.expBar.text:SetPoint("CENTER")

	self.expBar.spark = self.expBar.statusBar:CreateTexture(nil, "ARTWORK", nil, 1)
	self.expBar.spark:SetWidth(12)
	self.expBar.spark:SetHeight(self.expBar.statusBar:GetHeight() * 3)
	self.expBar.spark:SetTexture(C["Media"].Spark)
	self.expBar.spark:SetBlendMode("ADD")
	self.expBar.spark:SetPoint("CENTER", self.expBar.statusBar:GetStatusBarTexture(), "RIGHT", 0, 0)

	self.expBar.eventFrame = CreateFrame("Frame")
	self.expBar.eventFrame:Hide()
	self.expBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.expBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.expBar.eventFrame:SetScript("OnEvent", function(self, event) Module:UpdateExperience(event) end)

	self:UpdateExperienceDimensions()

	self:RegisterEvent("PLAYER_LEVEL_UP")

	K.Movers:RegisterFrame(self.expBar)
	self:EnableDisable_ExperienceBar()
end
