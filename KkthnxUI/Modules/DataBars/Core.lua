local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DataBars", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local pairs = pairs
local string_format = string.format

local C_AzeriteItem_FindActiveAzeriteItem = _G.C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = _G.C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = _G.C_AzeriteItem.GetPowerLevel
local CreateFrame = _G.CreateFrame
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GameTooltip = _G.GameTooltip
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetXPExhaustion = _G.GetXPExhaustion
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local UIParent = _G.UIParent
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

function Module:SetupExperience()
	local expbar = CreateFrame("StatusBar", "KkthnxUI_ExperienceBar", self.Container)
	expbar:SetStatusBarTexture(self.texture)
	expbar:SetStatusBarColor(C["DataBars"].ExperienceColor[1], C["DataBars"].ExperienceColor[2], C["DataBars"].ExperienceColor[3])
	expbar:SetSize(self.config.Width, self.config.Height)
	expbar:CreateBorder()

	local restbar = CreateFrame("StatusBar", "KkthnxUI_RestBar", self.Container)
	restbar:SetStatusBarTexture(self.texture)
	restbar:SetStatusBarColor(C["DataBars"].RestedColor[1], C["DataBars"].RestedColor[2], C["DataBars"].RestedColor[3])
	restbar:SetFrameLevel(3)
	restbar:SetSize(self.config.Width, self.config.Height)
	restbar:SetAlpha(0.5)

	local espark = expbar:CreateTexture(nil, "OVERLAY")
	espark:SetTexture(C["Media"].Spark_16)
	espark:SetHeight(self.config.Height)
	espark:SetBlendMode("ADD")
	espark:SetPoint("CENTER", expbar:GetStatusBarTexture(), "RIGHT", 0, 0)

	self.Bars.Experience = expbar
	expbar.RestBar = restbar
	expbar.Spark = espark
end

function Module:SetupReputation()
	local reputation = CreateFrame("StatusBar", "KkthnxUI_ReputationBar", self.Container)
	reputation:SetStatusBarTexture(self.texture)
	reputation:SetStatusBarColor(1, 1, 1)
	reputation:SetSize(self.config.Width, self.config.Height)
	reputation:CreateBorder()

	local rspark = reputation:CreateTexture(nil, "OVERLAY")
	rspark:SetTexture(C["Media"].Spark_16)
	rspark:SetHeight(self.config.Height)
	rspark:SetBlendMode("ADD")
	rspark:SetPoint("CENTER", reputation:GetStatusBarTexture(), "RIGHT", 0, 0)

	self.Bars.Reputation = reputation
	reputation.Spark = rspark
end

function Module:SetupAzerite()
	local azerite = CreateFrame("Statusbar", "KkthnxUI_AzeriteBar", self.Container)
	azerite:SetStatusBarTexture(self.texture)
	azerite:SetStatusBarColor(C["DataBars"].AzeriteColor[1], C["DataBars"].AzeriteColor[2], C["DataBars"].AzeriteColor[3])
	azerite:SetSize(self.config.Width, self.config.Height)
	azerite:CreateBorder()

	local aspark = azerite:CreateTexture(nil, "OVERLAY")
	aspark:SetTexture(C["Media"].Spark_16)
	aspark:SetHeight(self.config.Height)
	aspark:SetBlendMode("ADD")
	aspark:SetPoint("CENTER", azerite:GetStatusBarTexture(), "RIGHT", 0, 0)

	self.Bars.Azerite = azerite
	azerite.Spark = aspark
end

function Module:UpdateReputation()
	if GetWatchedFactionInfo() then
		local _, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		local current = value - minRep
		local max = maxRep - minRep

		self.Bars.Reputation:SetMinMaxValues(minRep, max)
		self.Bars.Reputation:SetValue(current)

		local c = FACTION_BAR_COLORS[rank]
		self.Bars.Reputation:SetStatusBarColor(c.r, c.g, c.b)

		self.Bars.Reputation:Show()
	else
		self.Bars.Reputation:Hide()
	end
end

function Module:UpdateExperience()
	if MAX_PLAYER_LEVEL ~= UnitLevel("player") then
		local current, max = UnitXP("player"), UnitXPMax("player")
		local rest = GetXPExhaustion()

		self.Bars.Experience:SetMinMaxValues(0, max)
		self.Bars.Experience:SetValue(current)

		self.Bars.Experience.RestBar:SetMinMaxValues(0, max)
		self.Bars.Experience.RestBar:SetValue(rest and current + rest or 0)

		self.Bars.Experience:Show()
	else
		self.Bars.Experience:Hide()
	end
end

function Module:UpdateAzerite()
	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()

	if azeriteItemLocation then
		local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)

		local current, max = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local level = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		self.Bars.Azerite:SetMinMaxValues(0, max)
		self.Bars.Azerite:SetValue(current)
		self.Bars.Azerite.info = {current, max, level}
		self.Bars.Azerite:Show()
	else
		self.Bars.Azerite:Hide()
	end
end

function Module:OnEnter()
	GameTooltip:ClearLines()
	GameTooltip_SetDefaultAnchor(GameTooltip, self.Container)

	if C["DataBars"].MouseOver then
		K.UIFrameFadeIn(self.Container, 0.25, self.Container:GetAlpha(), 1)
	end

	if MAX_PLAYER_LEVEL ~= UnitLevel("player") then
		local current, max = UnitXP("player"), UnitXPMax("player")
		local rest = GetXPExhaustion()

		GameTooltip:AddDoubleLine("Current:", string_format("%s/%s (%s%%)", K.ShortValue(current, 1), K.ShortValue(max, 1), K.Round(current / max * 100)), nil, nil, nil, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Databars"].Remaining, K.Comma(max - current), nil, nil, nil, 1, 1, 1)

		if rest then
			GameTooltip:AddDoubleLine(L["Databars"].Rested, string_format("%s (%s%%)", K.Comma(rest), K.Round(rest / max * 100)), nil, nil, nil, 0, 0.6, 1)
		end
	end

	if GetWatchedFactionInfo() then
		-- Add a space between exp and rep
		if MAX_PLAYER_LEVEL ~= UnitLevel("player") then
			GameTooltip:AddLine(" ")
		end

		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		local current = value - minRep
		local max = maxRep - minRep

		local c = FACTION_BAR_COLORS[rank]

		GameTooltip:AddDoubleLine(name, _G["FACTION_STANDING_LABEL" .. rank], nil,nil,nil, c.r, c.g, c.b)

		if max > 0 then
			GameTooltip:AddDoubleLine("Current:", string_format("%s/%s (%d%%)", K.ShortValue(current, 1), K.ShortValue(max, 1), K.Round(current / max * 100)), nil, nil, nil, 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Databars"].Remaining, K.Comma(max-current), nil, nil, nil, 1, 1, 1)
		end
	end

	if C_AzeriteItem_FindActiveAzeriteItem() then
		if MAX_PLAYER_LEVEL ~= UnitLevel("player") or GetWatchedFactionInfo() then
			GameTooltip:AddLine(" ")
		end

		local current, max, level = unpack(self.Bars.Azerite.info)
		GameTooltip:AddDoubleLine("Azerite Level:", level)
		GameTooltip:AddDoubleLine("Current:", string_format("%s/%s (%d%%)", K.ShortValue(current, 1), K.ShortValue(max, 1), K.Round(current / max * 100)), nil, nil, nil, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Databars"].Remaining, K.Comma(max - current), nil, nil, nil, 1, 1, 1)
	end

	GameTooltip:Show()
end

function Module:OnLeave()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeOut(self.Container, 1, self.Container:GetAlpha(), 0.25)
	end

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end

function Module:Update()
	self:UpdateExperience()
	self:UpdateReputation()
	self:UpdateAzerite()

	if C["DataBars"].MouseOver then
		self.Container:SetAlpha(0.25)
	else
		self.Container:SetAlpha(1)
	end

	local num_bars = 0
	local prev
	for _, bar in pairs(self.Bars) do
		if bar:IsShown() then
			num_bars = num_bars + 1

			bar:ClearAllPoints()
			if prev then
				bar:SetPoint("TOP", prev, "BOTTOM", 0, -6)
			else
				bar:SetPoint("TOP", self.Container)
			end
			prev = bar
		end
	end

	self.Container:SetHeight(num_bars * (self.config.Height + 6) - 6)
end

function Module:OnEnable()
	self.config = C["DataBars"]
	self.texture = K.GetTexture(C["DataBars"].Texture)

	if self.config.Enable ~= true then
		return
	end

	local container = CreateFrame("frame", "KkthnxUI_Databars", UIParent)
	container:SetWidth(self.config.Width)
	container:SetPoint("TOP", "Minimap", "BOTTOM", 0, -6)

	self:HookScript(container, "OnEnter")
	self:HookScript(container, "OnLeave")
	self.Container = container

	self.Bars = {}
	self:SetupExperience()
	self:SetupReputation()
	self:SetupAzerite()
	self:Update()

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update")

	self:RegisterEvent("PLAYER_LEVEL_UP", "Update")
	self:RegisterEvent("PLAYER_XP_UPDATE", "Update")
	self:RegisterEvent("UPDATE_EXHAUSTION", "Update")

	self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", "Update")
	self:RegisterEvent("UPDATE_FACTION", "Update")

	self:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", "Update")

	K.Movers:RegisterFrame(container)
end