local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Honor", "AceEvent-3.0")

-- Sourced: ElvUI (Elvz)

local _G = _G
local format = format

local GetMaxPlayerHonorLevel = _G.GetMaxPlayerHonorLevel
local HONOR = _G.HONOR
local IsInInstance = _G.IsInInstance
local MAX_HONOR_LEVEL = _G.MAX_HONOR_LEVEL
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local ToggleTalentFrame = _G.ToggleTalentFrame
local UnitHonor = _G.UnitHonor
local UnitHonorLevel = _G.UnitHonorLevel
local UnitHonorMax = _G.UnitHonorMax
local UnitLevel = _G.UnitLevel

function Module:UpdateHonor(event, unit)
	if not C["DataBars"].HonorEnable then
		return
	end

	if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then
		return
	end

	local bar = self.HonorBar
	local showHonor = UnitLevel("player") >= MAX_PLAYER_LEVEL
	local _, instanceType = IsInInstance()

	if not showHonor or not (instanceType == "pvp") or (instanceType == "arena") then
		bar:Hide()
	else
		bar:Show()

		local current = UnitHonor("player")
		local max = UnitHonorMax("player")

		-- Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
		if max == 0 then
			max = 1
		end

		bar.statusBar:SetMinMaxValues(0, max)
		bar.statusBar:SetValue(current)

		local text

		text = format("%d%%", current / max * 100)

		bar.text:SetText(text)
	end
end

function Module:HonorBar_OnEnter()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
	end

	GameTooltip:ClearLines()
	GameTooltip_SetDefaultAnchor(GameTooltip, self)

	local current = UnitHonor("player")
	local max = UnitHonorMax("player")
	local level = UnitHonorLevel("player")

	GameTooltip:AddLine(HONOR)

	GameTooltip:AddDoubleLine(L["Databars"].Current_Level, level, 1, 1, 1)
	GameTooltip:AddLine(" ")

	GameTooltip:AddDoubleLine(L["Databars"].Honor_XP, format(" %d / %d (%d%%)", current, max, current / max * 100), 1, 1, 1)
	GameTooltip:AddDoubleLine(L["Databars"].Honor_Remaining, format(" %d (%d%% - %d "..L["Databars"].Bars..")", max - current, (max - current) / max * 100, 20 * (max - current) / max), 1, 1, 1)

	GameTooltip:Show()
end

function Module:HonorBar_OnLeave()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
	end

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide() -- WHY??? BECAUSE FUCK GAMETOOLTIP, THATS WHY!!
	end
end

function Module:HonorBar_OnClick()
	ToggleTalentFrame(3) --3 is PvP
end

function Module:UpdateHonorDimensions()
	self.HonorBar:SetSize(Minimap:GetWidth() or C["DataBars"].HonorWidth, C["DataBars"].HonorHeight)
	self.HonorBar.text:SetFont(C["Media"].Font, C["Media"].FontSize - 1, C["DataBars"].Outline and "OUTLINE" or "", "CENTER")
	self.HonorBar.text:SetShadowOffset(C["DataBars"].Outline and 0 or 1.25, C["DataBars"].Outline and -0 or -1.25)
	self.HonorBar.spark:SetSize(16, self.HonorBar:GetHeight())

	if C["DataBars"].MouseOver then
		self.HonorBar:SetAlpha(0.25)
	else
		self.HonorBar:SetAlpha(1)
	end
end

function Module:PLAYER_LEVEL_UP(level)
	if (C["DataBars"].HonorEnable) then
		self:UpdateHonor("PLAYER_LEVEL_UP", level)
	else
		self.HonorBar:Hide()
	end
end

function Module:EnableDisable_HonorBar()
	if C["DataBars"].HonorEnable then
		self:RegisterEvent("HONOR_XP_UPDATE", "UpdateHonor")
		self:RegisterEvent("HONOR_LEVEL_UPDATE", "UpdateHonor")
		self:UpdateHonor()
	else
		self:UnregisterEvent("HONOR_XP_UPDATE")
		self.HonorBar:Hide()
	end
end

local AnchorY
function Module:OnEnable()
	local HonorFont = K.GetFont(C["DataBars"].Font)
	local HonorTexture = K.GetTexture(C["DataBars"].Texture)

	if K.Level <= 99 then
		AnchorY = -24
	else
		AnchorY = -42
	end

	self.HonorBar = CreateFrame("Button", "Honor", K.PetBattleHider)
	self.HonorBar:SetPoint("TOP", Minimap, "BOTTOM", 0, AnchorY)
	self.HonorBar:SetScript("OnEnter", Module.HonorBar_OnEnter)
	self.HonorBar:SetScript("OnLeave", Module.HonorBar_OnLeave)
	self.HonorBar:SetScript("OnClick", Module.HonorBar_OnClick)
	self.HonorBar:SetFrameStrata("LOW")
	self.HonorBar:Hide()

	self.HonorBar.statusBar = CreateFrame("StatusBar", nil, self.HonorBar)
	self.HonorBar.statusBar:SetAllPoints()
	self.HonorBar.statusBar:SetStatusBarTexture(HonorTexture)
	self.HonorBar.statusBar:SetStatusBarColor(C["DataBars"].HonorColor[1], C["DataBars"].HonorColor[2], C["DataBars"].HonorColor[3])
	self.HonorBar.statusBar:SetMinMaxValues(0, 325)

	self.HonorBar.statusBar:CreateBorder()

	self.HonorBar.text = self.HonorBar.statusBar:CreateFontString(nil, "OVERLAY")
	self.HonorBar.text:SetFontObject(HonorFont)
	self.HonorBar.text:SetFont(select(1, self.HonorBar.text:GetFont()), 11, select(3, self.HonorBar.text:GetFont()))
	self.HonorBar.text:SetPoint("CENTER")

	self.HonorBar.spark = self.HonorBar.statusBar:CreateTexture(nil, "OVERLAY")
	self.HonorBar.spark:SetTexture(C["Media"].Spark_16)
	self.HonorBar.spark:SetBlendMode("ADD")
	self.HonorBar.spark:SetPoint("CENTER", self.HonorBar.statusBar:GetStatusBarTexture(), "RIGHT", 0, 0)

	self.HonorBar.eventFrame = CreateFrame("Frame")
	self.HonorBar.eventFrame:Hide()
	self.HonorBar.eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.HonorBar.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.HonorBar.eventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	self.HonorBar.eventFrame:SetScript("OnEvent", function(_, event, unit)
		Module:UpdateHonor(event, unit)
	end)

	self:RegisterEvent("PLAYER_LEVEL_UP")

	self:UpdateHonorDimensions()
	K.Movers:RegisterFrame(self.HonorBar)
	self:EnableDisable_HonorBar()
end