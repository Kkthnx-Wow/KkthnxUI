local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DataBars")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local string_format = _G.string.format

local C_Reputation_GetFactionParagonInfo = _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = _G.C_Reputation.IsFactionParagon
local CreateFrame = _G.CreateFrame
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GameTooltip = _G.GameTooltip
local GetFriendshipReputation = _G.GetFriendshipReputation
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
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

-- Experience
local CurrentXP, XPToLevel, RestedXP, PercentRested
local PercentXP, RemainXP, RemainTotal, RemainBars
-- Reputation
local backupColor = _G.FACTION_BAR_COLORS[1]
-- Honor
local CurrentHonor, MaxHonor, CurrentLevel, PercentHonor, RemainingHonor

function Module:ExperienceBar_ShouldBeVisible()
	return not IsPlayerAtEffectiveMaxLevel() and not IsXPUserDisabled()
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
	espark:SetTexture(C["Media"].Textures.Spark16Texture)
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
	expbar.Text = etext
end

function Module:SetupReputation()
	local reputation = CreateFrame("StatusBar", "KKUI_ReputationBar", self.Container)
	reputation:SetStatusBarTexture(self.DatabaseTexture)
	reputation:SetStatusBarColor(1, 1, 1)
	reputation:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	reputation:CreateBorder()

	local rspark = reputation:CreateTexture(nil, "OVERLAY")
	rspark:SetTexture(C["Media"].Textures.Spark16Texture)
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
	reputation.Text = rtext
end

function Module:SetupHonor()
	local honor = CreateFrame("StatusBar", "KKUI_HonorBar", self.Container)
	honor:SetStatusBarTexture(self.DatabaseTexture)
	honor:SetStatusBarColor(C["DataBars"].HonorColor[1], C["DataBars"].HonorColor[2], C["DataBars"].HonorColor[3])
	honor:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	honor:CreateBorder()

	local hspark = honor:CreateTexture(nil, "OVERLAY")
	hspark:SetTexture(C["Media"].Textures.Spark16Texture)
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
	honor.Text = htext
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

	local displayString, textFormat = "", C["DataBars"].Text.Value
	if not Module:ExperienceBar_ShouldBeVisible() then
		expBar:SetMinMaxValues(0, 1)
		expBar:SetValue(1)

		if textFormat ~= 0 then
			displayString = IsXPUserDisabled() and "Disabled" or "Max Level"
		end
	else
		expBar:SetMinMaxValues(0, XPToLevel)
		expBar:SetValue(CurrentXP)

		if textFormat == 1 then
			displayString = string_format("%.2f%%", PercentXP)
		elseif textFormat == 2 then
			displayString = string_format("%s - %s", K.ShortValue(CurrentXP), K.ShortValue(XPToLevel))
		elseif textFormat == 3 then
			displayString = string_format("%s - %.2f%%", K.ShortValue(CurrentXP), PercentXP)
		elseif textFormat == 4 then
			displayString = string_format("%s", K.ShortValue(CurrentXP))
		elseif textFormat == 5 then
			displayString = string_format("%s", RemainXP)
		elseif textFormat == 6 then
			displayString = string_format("%s - %s", K.ShortValue(CurrentXP), RemainXP)
		elseif textFormat == 7 then
			displayString = string_format("%s - %.2f%% (%s)", K.ShortValue(CurrentXP), PercentXP, RemainXP)
		end

		local isRested = RestedXP and RestedXP > 0
		if isRested then
			expBar.RestBar:SetMinMaxValues(0, XPToLevel)
			expBar.RestBar:SetValue(math.min(CurrentXP + RestedXP, XPToLevel))

			PercentRested = (RestedXP / XPToLevel) * 100

			if textFormat == 1 then
				displayString = string_format("%s R:%.2f%%", displayString, PercentRested)
			elseif textFormat == 3 then
				displayString = string_format("%s R:%s [%.2f%%]", displayString, K.ShortValue(RestedXP), PercentRested)
			elseif textFormat ~= 0 then
				displayString = string_format("%s R:%s", displayString, K.ShortValue(RestedXP))
			end
		end

		if C["DataBars"].showXPLevel then
			displayString = string_format("%s %s : %s", LEVEL, K.Level, displayString)
		end

		expBar.RestBar:SetShown(isRested)
	end

	expBar.Text:SetText(displayString)
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

	local displayString, textFormat = "", C["DataBars"].Text.Value
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

	if isCapped and textFormat ~= 0 then
		-- show only name and standing on exalted
		displayString = string_format("%s: [%s]", name, isFriend and friendText or K.ShortenString(standingLabel, 1, false))
	else
		if textFormat == 1 then
			displayString = string_format("%s: %d%% [%s]", name, ((value - Min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
		elseif textFormat == 2 then
			displayString = string_format("%s: %s - %s [%s]", name, K.ShortValue(value - Min), K.ShortValue(Max - Min), isFriend and friendText or standingLabel)
		elseif textFormat == 3 then
			displayString = string_format("%s: %s - %d%% [%s]", name, K.ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
		elseif textFormat == 4 then
			displayString = string_format("%s: %s [%s]", name, K.ShortValue(value - Min), isFriend and friendText or standingLabel)
		elseif textFormat == 5 then
			displayString = string_format("%s: %s [%s]", name, K.ShortValue((Max - Min) - (value-Min)), isFriend and friendText or standingLabel)
		elseif textFormat == 6 then
			displayString = string_format("%s: %s - %s [%s]", name, K.ShortValue(value - Min), K.ShortValue((Max - Min) - (value-Min)), isFriend and friendText or standingLabel)
		elseif textFormat == 7 then
			displayString = string_format("%s: %s - %d%% (%s) [%s]", name, K.ShortValue(value - Min), ((value - Min) / (maxMinDiff) * 100), K.ShortValue((Max - Min) - (value-Min)), isFriend and friendText or standingLabel)
		end
	end

	repBar.Text:SetText(displayString)
end

function Module:UpdateHonor(event, unit)
	local honBar = self.Bars.Honor

	if not C["DataBars"].TrackHonor or (event == "PLAYER_FLAGS_CHANGED" and unit ~= "player") then
		honBar:Hide()
	else
		honBar:Show()

		CurrentHonor, MaxHonor, CurrentLevel = UnitHonor("player"), UnitHonorMax("player"), UnitHonorLevel("player")

		-- Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
		if MaxHonor == 0 then
			MaxHonor = 1
		end

		PercentHonor, RemainingHonor = (CurrentHonor / MaxHonor) * 100, MaxHonor - CurrentHonor
		local displayString, textFormat = "", C["DataBars"].Text.Value

		honBar:SetMinMaxValues(0, MaxHonor)
		honBar:SetValue(CurrentHonor)

		if textFormat == 1 then
			displayString = string_format("%d%%", PercentHonor)
		elseif textFormat == 2 then
			displayString = string_format("%s - %s", K.ShortValue(CurrentHonor), K.ShortValue(MaxHonor))
		elseif textFormat == 3 then
			displayString = string_format("%s - %d%%", K.ShortValue(CurrentHonor), PercentHonor)
		elseif textFormat == 4 then
			displayString = string_format("%s", K.ShortValue(CurrentHonor))
		elseif textFormat == 5 then
			displayString = string_format("%s", K.ShortValue(RemainingHonor))
		elseif textFormat == 6 then
			displayString = string_format("%s - %s", K.ShortValue(CurrentHonor), K.ShortValue(RemainingHonor))
		elseif textFormat == 7 then
			displayString = string_format("%s - %d%% (%s)", K.ShortValue(CurrentHonor), CurrentHonor, K.ShortValue(RemainingHonor))
		end

		honBar.Text:SetText(displayString)
	end
end

function Module:OnEnter()
	if GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:ClearLines()

	if C["DataBars"].MouseOver then
		UIFrameFadeIn(Module.Container, 0.2, Module.Container:GetAlpha(), 1)
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

	if C["DataBars"].TrackHonor then
		if IsPlayerAtEffectiveMaxLevel() then
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
		UIFrameFadeOut(Module.Container, 0.2, Module.Container:GetAlpha(), 0)
	end

	GameTooltip:Hide()
end

function Module:OnUpdate()
	Module:UpdateExperience()
	Module:UpdateReputation()
	Module:UpdateHonor()

	if C["DataBars"].MouseOver then
		Module.Container:SetAlpha(0)
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

function Module:UpdateDataBarsSize()
	KKUI_ExperienceBar:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	KKUI_ReputationBar:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	KKUI_HonorBar:SetSize(C["DataBars"].Width, C["DataBars"].Height)

	local num_bars = 0
	for _, bar in pairs(Module.Bars) do
		if bar:IsShown() then
			num_bars = num_bars + 1
		end
	end

	Module.Container:SetSize(C["DataBars"].Width, num_bars * (C["DataBars"].Height + 6) - 6)
	self.Container.mover:SetSize(C["DataBars"].Width, num_bars * (C["DataBars"].Height + 6) - 6)
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
	self.Container:SetPoint("TOP", _G.Minimap, "BOTTOM", 0, -6)
	self.Container:HookScript("OnEnter", self.OnEnter)
	self.Container:HookScript("OnLeave", self.OnLeave)

	self:SetupExperience()
	self:SetupReputation()
	self:SetupHonor()
	self:OnUpdate()

	-- Experience
	if Module:ExperienceBar_ShouldBeVisible() then
		K:RegisterEvent("PLAYER_XP_UPDATE", self.OnUpdate)
		K:RegisterEvent("DISABLE_XP_GAIN", self.OnUpdate)
		K:RegisterEvent("ENABLE_XP_GAIN", self.OnUpdate)
		K:RegisterEvent("UPDATE_EXHAUSTION", self.OnUpdate)
	else
		K:UnregisterEvent("PLAYER_XP_UPDATE", self.OnUpdate)
		K:UnregisterEvent("DISABLE_XP_GAIN", self.OnUpdate)
		K:UnregisterEvent("ENABLE_XP_GAIN", self.OnUpdate)
		K:UnregisterEvent("UPDATE_EXHAUSTION", self.OnUpdate)
	end

	-- Reputation
	K:RegisterEvent("UPDATE_FACTION", self.OnUpdate)
	K:RegisterEvent("COMBAT_TEXT_UPDATE", self.OnUpdate)

	-- Honor
	if C["DataBars"].TrackHonor then
		K:RegisterEvent("HONOR_XP_UPDATE", self.OnUpdate)
		K:RegisterEvent("PLAYER_FLAGS_CHANGED", self.OnUpdate)
	else
		K:UnregisterEvent("HONOR_XP_UPDATE", self.OnUpdate)
		K:UnregisterEvent("PLAYER_FLAGS_CHANGED", self.OnUpdate)
	end

	if not self.Container.mover then
		self.Container.mover = K.Mover(self.Container, "DataBars", "DataBars", {"TOP", _G.Minimap, "BOTTOM", 0, -6})
	end
end