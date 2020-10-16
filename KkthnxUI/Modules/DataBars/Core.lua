local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DataBars")

local _G = _G
local math_floor = _G.math.floor
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string.format

local ARTIFACT_POWER = _G.ARTIFACT_POWER
local C_AzeriteItem_FindActiveAzeriteItem = _G.C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = _G.C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = _G.C_AzeriteItem.GetPowerLevel
local C_Reputation_GetFactionParagonInfo = _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = _G.C_Reputation.IsFactionParagon
local CreateFrame = _G.CreateFrame
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GameTooltip = _G.GameTooltip
local GetFriendshipReputation = _G.GetFriendshipReputation
local GetPetExperience = _G.GetPetExperience
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetXPExhaustion = _G.GetXPExhaustion
local HONOR = _G.HONOR
local IsPlayerAtEffectiveMaxLevel = _G.IsPlayerAtEffectiveMaxLevel
local IsXPUserDisabled = _G.IsXPUserDisabled
local LEVEL = _G.LEVEL
local REPUTATION = _G.REPUTATION
local STANDING = _G.STANDING
local UnitHonor = _G.UnitHonor
local UnitHonorLevel = _G.UnitHonorLevel
local UnitHonorMax = _G.UnitHonorMax
local UnitIsPVP = _G.UnitIsPVP
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

local backupColor = _G.FACTION_BAR_COLORS[1]
-- Experience
local CurrentXP, XPToLevel, RestedXP, PercentRested
local PercentXP, RemainXP, RemainTotal, RemainBars
-- Honor
local CurrentHonor, MaxHonor, CurrentLevel, PercentHonor, RemainingHonor

function Module:ExperienceBar_ShouldBeVisible()
	return not IsPlayerAtEffectiveMaxLevel() and not IsXPUserDisabled()
end

function Module:GetUnitXP(unit)
	if unit == "pet" then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

function Module:SetupExperience()
	local expbar = CreateFrame("StatusBar", "KKUI_ExperienceBar", self.Container)
	expbar:SetStatusBarTexture(self.DatabaseTexture)
	expbar:SetStatusBarColor(C["DataBars"].ExperienceColor[1], C["DataBars"].ExperienceColor[2], C["DataBars"].ExperienceColor[3], C["DataBars"].ExperienceColor[4])
	expbar:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	expbar:CreateBorder()

	local restbar = CreateFrame("StatusBar", "KKUI_RestBar", self.Container)
	restbar:SetStatusBarTexture(self.DatabaseTexture)
	restbar:SetStatusBarColor(C["DataBars"].RestedColor[1], C["DataBars"].RestedColor[2], C["DataBars"].RestedColor[3], C["DataBars"].RestedColor[4])
	restbar:SetFrameLevel(3)
	restbar:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	restbar:SetAlpha(0.5)
	restbar:SetAllPoints(expbar)

	local espark = expbar:CreateTexture(nil, "OVERLAY")
	espark:SetTexture(C["Media"].Spark_16)
	espark:SetHeight(C["DataBars"].Height)
	espark:SetBlendMode("ADD")
	espark:SetPoint("CENTER", expbar:GetStatusBarTexture(), "RIGHT", 0, 0)

	local etext = expbar:CreateFontString(nil, "OVERLAY")
	etext:SetFontObject(self.DatabaseFont)
	etext:SetFont(select(1, etext:GetFont()), 11, select(3, etext:GetFont()))
	etext:SetPoint("LEFT", expbar, "RIGHT", -3, 0)
	etext:SetPoint("RIGHT", expbar, "LEFT", 3, 0)

	self.Bars.Experience = expbar
	expbar.RestBar = restbar
	expbar.Spark = espark
	expbar.Text = etext
end

function Module:SetupReputation()
	local reputation = CreateFrame("StatusBar", "KKUI_ReputationBar", self.Container)
	reputation:SetStatusBarTexture(self.DatabaseTexture)
	reputation:SetStatusBarColor(1, 1, 1)
	reputation:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	reputation:CreateBorder()

	local rspark = reputation:CreateTexture(nil, "OVERLAY")
	rspark:SetTexture(C["Media"].Spark_16)
	rspark:SetHeight(C["DataBars"].Height)
	rspark:SetBlendMode("ADD")
	rspark:SetPoint("CENTER", reputation:GetStatusBarTexture(), "RIGHT", 0, 0)

	local rtext = reputation:CreateFontString(nil, "OVERLAY")
	rtext:SetFontObject(self.DatabaseFont)
	rtext:SetFont(select(1, rtext:GetFont()), 11, select(3, rtext:GetFont()))
	rtext:SetWidth(C["DataBars"].Width - 6)
	rtext:SetWordWrap(false)
	rtext:SetPoint("LEFT", reputation, "RIGHT", -3, 0)
	rtext:SetPoint("RIGHT", reputation, "LEFT", 3, 0)

	self.Bars.Reputation = reputation
	reputation.Spark = rspark
	reputation.Text = rtext
end

function Module:SetupAzerite()
	local azerite = CreateFrame("Statusbar", "KKUI_AzeriteBar", self.Container)
	azerite:SetStatusBarTexture(self.DatabaseTexture)
	azerite:SetStatusBarColor(C["DataBars"].AzeriteColor[1], C["DataBars"].AzeriteColor[2], C["DataBars"].AzeriteColor[3])
	azerite:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	azerite:CreateBorder()

	local aspark = azerite:CreateTexture(nil, "OVERLAY")
	aspark:SetTexture(C["Media"].Spark_16)
	aspark:SetHeight(C["DataBars"].Height)
	aspark:SetBlendMode("ADD")
	aspark:SetPoint("CENTER", azerite:GetStatusBarTexture(), "RIGHT", 0, 0)

	local atext = azerite:CreateFontString(nil, "OVERLAY")
	atext:SetFontObject(self.DatabaseFont)
	atext:SetFont(select(1, atext:GetFont()), 11, select(3, atext:GetFont()))
	atext:SetPoint("LEFT", azerite, "RIGHT", -3, 0)
	atext:SetPoint("RIGHT", azerite, "LEFT", 3, 0)

	self.Bars.Azerite = azerite
	azerite.Spark = aspark
	azerite.Text = atext
end

function Module:SetupHonor()
	local honor = CreateFrame("StatusBar", "KKUI_HonorBar", self.Container)
	honor:SetStatusBarTexture(self.DatabaseTexture)
	honor:SetStatusBarColor(C["DataBars"].HonorColor[1], C["DataBars"].HonorColor[2], C["DataBars"].HonorColor[3])
	honor:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	honor:CreateBorder()

	local hspark = honor:CreateTexture(nil, "OVERLAY")
	hspark:SetTexture(C["Media"].Spark_16)
	hspark:SetHeight(C["DataBars"].Height)
	hspark:SetBlendMode("ADD")
	hspark:SetPoint("CENTER", honor:GetStatusBarTexture(), "RIGHT", 0, 0)

	local htext = honor:CreateFontString(nil, "OVERLAY")
	htext:SetFontObject(self.DatabaseFont)
	htext:SetFont(select(1, htext:GetFont()), 11, select(3, htext:GetFont()))
	htext:SetWidth(C["DataBars"].Width - 6)
	htext:SetWordWrap(false)
	htext:SetPoint("LEFT", honor, "RIGHT", -3, 0)
	htext:SetPoint("RIGHT", honor, "LEFT", 3, 0)

	self.Bars.Honor = honor
	honor.Spark = hspark
	honor.Text = htext
end

function Module:UpdateReputation()
	local repBar = self.Bars.Reputation
	local name, reaction, Min, Max, value, factionID = GetWatchedFactionInfo()

	if not name then
		repBar:Hide()
		return
	else
		repBar:Show()
	end

	local displayString
	local isCapped, isFriend, friendText, standingLabel
	local friendshipID = GetFriendshipReputation(factionID)
	local color = FACTION_BAR_COLORS[reaction] or backupColor

	if friendshipID then
		local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
		isFriend, reaction, friendText = true, 5, friendTextLevel
		if nextFriendThreshold then
			Min, Max, value = friendThreshold, nextFriendThreshold, friendRep;
		else
			Min, Max, value = 0, 1, 1
			isCapped = true
		end
	elseif C_Reputation_IsFactionParagon(factionID) then
		local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
		if currentValue and threshold then
			Min, Max = 0, threshold
			value = currentValue % threshold
			if hasRewardPending then
				value = value + threshold
			end
		end
	elseif reaction == _G.MAX_REPUTATION_REACTION then
		Min, Max, value = 0, 1, 1
		isCapped = true
	end

	repBar:SetMinMaxValues(Min, Max)
	repBar:SetValue(value)
	repBar:SetStatusBarColor(color.r, color.g, color.b)

	standingLabel = _G["FACTION_STANDING_LABEL"..reaction]

	-- Prevent a division by zero
	local maxMinDiff = Max - Min
	if maxMinDiff == 0 then
		maxMinDiff = 1
	end

	if isCapped and C["DataBars"].Text then
		-- show only name and standing on exalted
		displayString = string_format("%s: [%s]", name, isFriend and friendText or standingLabel)
	else
		displayString = string_format("%s: %s - %d%% [%s]", name, K.ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
	end

	repBar.Text:SetText(displayString)
end

function Module:UpdateExperience()
	local expBar = self.Bars.Experience

	if (not Module:ExperienceBar_ShouldBeVisible()) then
		expBar:Hide()
		return
	else
		expBar:Show()
	end

	CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
	if XPToLevel <= 0 then
		XPToLevel = 1
	end

	local remainXP = XPToLevel - CurrentXP
	local remainPercent = remainXP / XPToLevel
	RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
	PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, K.ShortValue(remainXP)

	local displayString
	if not Module:ExperienceBar_ShouldBeVisible() then
		expBar:SetMinMaxValues(0, 1)
		expBar:SetValue(1)

		if C["DataBars"].Text then
			displayString = IsXPUserDisabled() and "Disabled" or "Max Level"
		end
	else
		expBar:SetMinMaxValues(0, XPToLevel)
		expBar:SetValue(CurrentXP)

		displayString = string_format("%s - %.2f%%", K.ShortValue(CurrentXP), PercentXP)

		local isRested = RestedXP and RestedXP > 0
		if isRested then
			expBar.RestBar:SetMinMaxValues(0, XPToLevel)
			expBar.RestBar:SetValue(math.min(CurrentXP + RestedXP, XPToLevel))

			PercentRested = (RestedXP / XPToLevel) * 100

			displayString = string_format("%s R:%s [%.2f%%]", displayString, K.ShortValue(RestedXP), PercentRested)
		end

		expBar.RestBar:SetShown(isRested)
	end

	if C["DataBars"].Text then
		expBar.Text:SetText(displayString)
	end
end

function Module:UpdateAzerite(event, unit)
	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
	end

	local azBar = self.Bars.Azerite

	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	if not azeriteItemLocation or C_AzeriteItem.IsAzeriteItemAtMaxLevel() or K.Level > 50 then
		azBar:Hide()
	else
		azBar:Show()

		local cur, max = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		azBar:SetMinMaxValues(0, max)
		azBar:SetValue(cur)

		if C["DataBars"].Text then
			azBar.Text:SetFormattedText("%s - %s%% [%s]", K.ShortValue(cur), math_floor(cur / max * 100), currentLevel)
		end
	end
end

function Module:UpdateHonor(event, unit)
	local honBar = self.Bars.Honor

	if not C["DataBars"].TrackHonor or not UnitIsPVP("player") or (event == "PLAYER_FLAGS_CHANGED" and unit ~= "player") then
		honBar:Hide()
	else
		honBar:Show()

		CurrentHonor, MaxHonor, CurrentLevel = UnitHonor("player"), UnitHonorMax("player"), UnitHonorLevel("player")

		-- Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
		if MaxHonor == 0 then
			MaxHonor = 1
		end

		PercentHonor, RemainingHonor = (CurrentHonor / MaxHonor) * 100, MaxHonor - CurrentHonor

		honBar:SetMinMaxValues(0, MaxHonor)
		honBar:SetValue(CurrentHonor)


		if C["DataBars"].Text then
			honBar.Text:SetText(string_format("%s - %d%%", K.ShortValue(CurrentHonor), PercentHonor))
		end
	end
end

function Module:OnEnter()
	if GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	if C["DataBars"].MouseOver then
		K.UIFrameFadeIn(Module.Container, 0.25, Module.Container:GetAlpha(), 1)
	end

	if Module:ExperienceBar_ShouldBeVisible() then
		GameTooltip:AddLine(L["Experience"])

		GameTooltip:AddDoubleLine(LEVEL, string_format("%s", K.Level), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["XP"], string_format(" %d / %d (%.2f%%)", CurrentXP, XPToLevel, PercentXP), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %d "..L["Bars"]..")", RemainXP, RemainTotal, RemainBars), 1, 1, 1)

		if RestedXP and RestedXP > 0 then
			GameTooltip:AddDoubleLine(L["Rested"], string_format("+%d (%.2f%%)", RestedXP, PercentRested), 1, 1, 1)
		end
	end

	if GetWatchedFactionInfo() then
		if not IsPlayerAtEffectiveMaxLevel() then
			GameTooltip:AddLine(" ")
		end

		local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()
		if factionID and C_Reputation_IsFactionParagon(factionID) then
			local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
			if currentValue and threshold then
				min, max = 0, threshold
				value = currentValue % threshold
				if hasRewardPending then
					value = value + threshold
				end
			end
		end

		if name then
			local color = FACTION_BAR_COLORS[reaction] or backupColor
			GameTooltip:AddLine(name, color.r, color.g, color.b)

			local friendID, friendTextLevel, _
			if factionID then
				friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
			end

			GameTooltip:AddDoubleLine(STANDING..":", (friendID and friendTextLevel) or _G["FACTION_STANDING_LABEL"..reaction], 1, 1, 1)
			if reaction ~= _G.MAX_REPUTATION_REACTION or C_Reputation_IsFactionParagon(factionID) then
				GameTooltip:AddDoubleLine(REPUTATION..":", string_format("%d / %d (%d%%)", value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
			end
		end
	end

	local azeriteItem, currentLevel, curXP, maxXP
	local function dataLoadedCancelFunc()
		if not IsPlayerAtEffectiveMaxLevel() or GetWatchedFactionInfo() or IsPlayerAtEffectiveMaxLevel and C["DataBars"].TrackHonor then
			GameTooltip:AddLine(" ")
		end
		GameTooltip:AddDoubleLine(ARTIFACT_POWER, azeriteItem:GetItemName().." ("..currentLevel..")", nil, nil, nil, 0.90, 0.80, 0.50) -- Temp Locale
		GameTooltip:AddDoubleLine(L["AP"], string_format(" %d / %d (%d%%)", curXP, maxXP, curXP / maxXP * 100), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %d (%d%% - %d "..L["Bars"]..")", maxXP - curXP, (maxXP - curXP) / maxXP * 100, 10 * (maxXP - curXP) / maxXP), 1, 1, 1)
	end

	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	if azeriteItemLocation then
		curXP, maxXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
		azeriteItem:ContinueWithCancelOnItemLoad(dataLoadedCancelFunc)
	end

	if C["DataBars"].TrackHonor then
		if IsPlayerAtEffectiveMaxLevel() and UnitIsPVP("player") then
			GameTooltip:AddLine(" ")

			GameTooltip:AddLine(HONOR)
			GameTooltip:AddDoubleLine(LEVEL, CurrentLevel, 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Honor XP"], string_format(" %d / %d (%d%%)", CurrentHonor, MaxHonor, PercentHonor), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Honor Remaining"], string_format(" %d (%d%% - %d "..L["Bars"]..")", RemainingHonor, (RemainingHonor) / MaxHonor * 100, 20 * (RemainingHonor) / MaxHonor), 1, 1, 1)
		end
	end

	GameTooltip:Show()
end

function Module:OnLeave()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeOut(Module.Container, 1, Module.Container:GetAlpha(), 0.25)
	end

	GameTooltip:Hide()
end

function Module:OnUpdate()
	Module:UpdateExperience()
	Module:UpdateReputation()
	Module:UpdateAzerite()
	Module:UpdateHonor()

	if C["DataBars"].MouseOver then
		Module.Container:SetAlpha(0.25)
	else
		Module.Container:SetAlpha(1)
	end

	local num_bars = 0
	local prev
	for _, bar in pairs(Module.Bars) do
		if bar:IsShown() then
			num_bars = num_bars + 1

			bar:ClearAllPoints()
			if prev then
				bar:SetPoint("TOP", prev, "BOTTOM", 0, -6)
			else
				bar:SetPoint("TOP", Module.Container)
			end
			prev = bar
		end
	end

	Module.Container:SetHeight(num_bars * (C["DataBars"].Height + 6) - 6)
end

function Module:OnEnable()
	self.DatabaseTexture = K.GetTexture(C["UITextures"].DataBarsTexture)
	self.DatabaseFont = K.GetFont(C["UIFonts"].DataBarsFonts)

	if not C["DataBars"].Enable then
		return
	end

	self.Bars = {}

	self.Container = CreateFrame("button", "KKUI_Databars", K.PetBattleHider)
	self.Container:SetWidth(C["DataBars"].Width)
	self.Container:SetPoint("TOP", "Minimap", "BOTTOM", 0, -6)
	self.Container:HookScript("OnEnter", self.OnEnter)
	self.Container:HookScript("OnLeave", self.OnLeave)

	self:SetupExperience()
	self:SetupReputation()
	self:SetupAzerite()
	self:SetupHonor()
	self:OnUpdate()

	-- All Events
	--K:RegisterEvent("PLAYER_ENTERING_WORLD", self.OnUpdate)

	-- Exp Events
	K:RegisterEvent("PLAYER_XP_UPDATE", self.OnUpdate)
	K:RegisterEvent("DISABLE_XP_GAIN", self.OnUpdate)
	K:RegisterEvent("ENABLE_XP_GAIN", self.OnUpdate)
	K:RegisterEvent("UPDATE_EXHAUSTION", self.OnUpdate)

	-- Rep Events
	K:RegisterEvent("UPDATE_FACTION", self.OnUpdate)
	K:RegisterEvent("COMBAT_TEXT_UPDATE", self.OnUpdate)

	-- Azerite Events
	K:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", self.OnUpdate)
	K:RegisterEvent("UNIT_INVENTORY_CHANGED", self.OnUpdate)

	-- Honor Events
	K:RegisterEvent("HONOR_XP_UPDATE", self.OnUpdate)
	K:RegisterEvent("PLAYER_FLAGS_CHANGED", self.OnUpdate)

	K.Mover(self.Container, "DataBars", "DataBars", {"TOP", "Minimap", "BOTTOM", 0, -6}, C["DataBars"].Width, self.Container:GetHeight())
end