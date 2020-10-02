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
local GetExpansionLevel = _G.GetExpansionLevel
local GetFactionInfo = _G.GetFactionInfo
local GetFriendshipReputation = _G.GetFriendshipReputation
local GetNumFactions = _G.GetNumFactions
local GetPetExperience = _G.GetPetExperience
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetXPExhaustion = _G.GetXPExhaustion
local HONOR = _G.HONOR
local IsXPUserDisabled = _G.IsXPUserDisabled
local LEVEL = _G.LEVEL
local MAX_PLAYER_LEVEL_TABLE = _G.MAX_PLAYER_LEVEL_TABLE
local MAX_REPUTATION_REACTION = _G.MAX_REPUTATION_REACTION
local REPUTATION = _G.REPUTATION
local STANDING = _G.STANDING
local UnitHonor = _G.UnitHonor
local UnitHonorLevel = _G.UnitHonorLevel
local UnitHonorMax = _G.UnitHonorMax
local UnitIsPVP = _G.UnitIsPVP
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

local FactionStandingLabelUnknown = _G.UNKNOWN
local backupColor = _G.FACTION_BAR_COLORS[1]

function Module:GetUnitXP(unit)
	if (unit == "pet") then
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
	etext:SetPoint("CENTER")

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
	rtext:SetPoint("CENTER")

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
	atext:SetPoint("CENTER")

	self.Bars.Azerite = azerite
	azerite.Spark = aspark
	azerite.Text = atext
end

function Module:SetupHonor()
	if not C["DataBars"].TrackHonor then
		return
	end

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
	htext:SetPoint("CENTER")

	self.Bars.Honor = honor
	honor.Spark = hspark
	honor.Text = htext
end

function Module:UpdateReputation()
	local repBar = self.Bars.Reputation
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()

	local numFactions = GetNumFactions()
	if not name then
		repBar:Hide()
	else
		repBar:Show()

		local ID, isFriend, friendText, standingLabel
		local isCapped

		if factionID and C_Reputation_IsFactionParagon(factionID) then
			local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
			if currentValue and threshold then
				min, max = 0, threshold
				value = currentValue % threshold
				if hasRewardPending then
					value = value + threshold
				end
			end
		else
			if reaction == _G.MAX_REPUTATION_REACTION then
				-- max rank, make it look like a full bar
				min, max, value = 0, 1, 1
				isCapped = true
			end
		end

		repBar:SetMinMaxValues(min, max)
		repBar:SetValue(value)
		local color = FACTION_BAR_COLORS[reaction] or backupColor
		if factionID and C_Reputation_IsFactionParagon(factionID) then
			repBar:SetStatusBarColor(51/255, 80/255, 194/255)
		else
			repBar:SetStatusBarColor(color.r, color.g, color.b)
		end

		for i = 1, numFactions do
			local factionName, _, standingID,_,_,_,_,_,_,_,_,_,_, FactionID = GetFactionInfo(i)
			local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(FactionID)
			if factionName == name then
				if friendID ~= nil then
					isFriend = true
					friendText = friendTextLevel
				else
					ID = standingID
				end
			end
		end

		if ID then
			standingLabel = K.ShortenString(_G["FACTION_STANDING_LABEL" .. ID], 1, false) -- F = Friendly, N = Neutral and so on.
		else
			standingLabel = FactionStandingLabelUnknown
		end

		local maxMinDiff = max - min
		if (maxMinDiff == 0) then
			maxMinDiff = 1
		end

		local text
		if C["DataBars"].Text then
			if isCapped then
				text = string_format("%s: [%s]", name, isFriend and friendText or standingLabel)
			else
				text = string_format("%s: %s - %d%% [%s]", name, K.ShortValue(value - min), ((value - min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
			end

			repBar.Text:SetText(text)
		end
	end
end

function Module:UpdateExperience()
	local expBar = self.Bars.Experience

	if (K.Level == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) or IsXPUserDisabled() then
		expBar:Hide()
	else
		expBar:Show()

		local cur, max = Module:GetUnitXP("player")
		if max <= 0 then
			max = 1
		end

		expBar:SetMinMaxValues(0, max)
		expBar:SetValue(cur)

		local rested = GetXPExhaustion()

		if rested and rested > 0 then
			expBar.RestBar:SetMinMaxValues(0, max)
			expBar.RestBar:SetValue(min(cur + rested, max))

			if C["DataBars"].Text then
				expBar.Text:SetText(string_format("%s - %d%% R:%s [%d%%]", K.ShortValue(cur), cur / max * 100, K.ShortValue(rested), rested / max * 100))
			end
		else
			expBar.RestBar:SetMinMaxValues(0, 1)
			expBar.RestBar:SetValue(0)

			if C["DataBars"].Text then
				expBar.Text:SetText(string_format("%s - %d%%", K.ShortValue(cur), cur / max * 100))
			end
		end
	end
end

function Module:UpdateAzerite(event, unit)
	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
	end

	local azBar = self.Bars.Azerite

	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	if not azeriteItemLocation or C_AzeriteItem.IsAzeriteItemAtMaxLevel() then
		azBar:Hide()
	else
		azBar:Show()

		local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		azBar:SetMinMaxValues(0, totalLevelXP)
		azBar:SetValue(xp)

		if C["DataBars"].Text then
			azBar.Text:SetText(string_format("%s - %s%% [%s]", K.ShortValue(xp), math_floor(xp / totalLevelXP * 100), currentLevel))
		end
	end
end

function Module:UpdateHonor(event, unit)
	if not C["DataBars"].TrackHonor then
		return
	end

	if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then
		return
	end

	local honBar = self.Bars.Honor

	if (not UnitIsPVP("player")) or (K.Level < MAX_PLAYER_LEVEL) then
		honBar:Hide()
	else
		honBar:Show()

		local current = UnitHonor("player")
		local max = UnitHonorMax("player")

		if max == 0 then
			max = 1
		end

		honBar:SetMinMaxValues(0, max)
		honBar:SetValue(current)

		if C["DataBars"].Text then
			honBar.Text:SetText(string_format("%s - %d%%", K.ShortValue(current), current / max * 100))
		end
	end
end

function Module:OnEnter()
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	if C["DataBars"].MouseOver then
		K.UIFrameFadeIn(Module.Container, 0.25, Module.Container:GetAlpha(), 1)
	end

	if MAX_PLAYER_LEVEL ~= K.Level then
		local cur, max = Module:GetUnitXP("player")
		local rested = GetXPExhaustion()

		GameTooltip:AddDoubleLine(L["Experience"], PLAYER.." "..LEVEL.." ("..K.Level..")", nil, nil, nil, 0.90, 0.80, 0.50)
		GameTooltip:AddDoubleLine(L["XP"], string_format("%s / %s (%d%%)", K.ShortValue(cur), K.ShortValue(max), math_floor(cur / max * 100)), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Remaining"], string_format("%s (%s%% - %s "..L["Bars"]..")", K.ShortValue(max - cur), math_floor((max - cur) / max * 100), math_floor(20 * (max - cur) / max)), 1, 1, 1)

		if rested then
			GameTooltip:AddDoubleLine(L["Rested"], string_format("+%s (%s%%)", K.ShortValue(rested), math_floor(rested / max * 100)), 1, 1, 1)
		end
	end

	if GetWatchedFactionInfo() then
		if MAX_PLAYER_LEVEL ~= K.Level then
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

			GameTooltip:AddDoubleLine(STANDING..":", (friendID and friendTextLevel) or _G["FACTION_STANDING_LABEL" .. reaction], 1, 1, 1)
			if reaction ~= MAX_REPUTATION_REACTION or C_Reputation_IsFactionParagon(factionID) then
				GameTooltip:AddDoubleLine(REPUTATION..":", string_format("%d / %d (%d%%)", value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
			end
		end
	end

	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	if azeriteItemLocation then
		if MAX_PLAYER_LEVEL ~= K.Level or GetWatchedFactionInfo() then
			GameTooltip:AddLine(" ")
		end

		local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
		local cur, max = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		self.itemDataLoadedCancelFunc = azeriteItem:ContinueWithCancelOnItemLoad(function()
				local azeriteItemName = azeriteItem:GetItemName()
				GameTooltip:AddDoubleLine(ARTIFACT_POWER, azeriteItemName.." ("..currentLevel..")", nil,  nil, nil, 0.90, 0.80, 0.50) -- Temp Locale
				GameTooltip:AddDoubleLine(L["AP"], string_format(" %d / %d (%d%%)", cur, max, cur / max  * 100), 1, 1, 1)
				GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %d (%d%% - %d "..L["Bars"]..")", max - cur, (max - cur) / max * 100, 10 * (max - cur) / max), 1, 1, 1)
				GameTooltip:Show()
		end)
	end

	if C["DataBars"].TrackHonor then
		if K.Level == MAX_PLAYER_LEVEL and UnitIsPVP("player") then
			GameTooltip:AddLine(" ")

			local current = UnitHonor("player")
			local max = UnitHonorMax("player")
			local level = UnitHonorLevel("player")

			GameTooltip:AddDoubleLine(HONOR.." "..LEVEL, level)
			GameTooltip:AddDoubleLine(L["Honor XP"], string_format(" %d / %d (%d%%)", current, max, current/max * 100), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Honor Remaining"], string_format(" %d (%d%% - %d "..L["Bars"]..")", max - current, (max - current) / max * 100, 20 * (max - current) / max), 1, 1, 1)
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

	K:RegisterEvent("PLAYER_ENTERING_WORLD", self.OnUpdate)
	K:RegisterEvent("PLAYER_LEVEL_UP", self.OnUpdate)
	K:RegisterEvent("PLAYER_XP_UPDATE", self.OnUpdate)
	K:RegisterEvent("UPDATE_EXHAUSTION", self.OnUpdate)
	K:RegisterEvent("DISABLE_XP_GAIN", self.OnUpdate)
	K:RegisterEvent("ENABLE_XP_GAIN", self.OnUpdate)
	K:RegisterEvent("UPDATE_FACTION", self.OnUpdate)
	K:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED", self.OnUpdate)
	K:RegisterEvent("UNIT_INVENTORY_CHANGED", self.OnUpdate)
	K:RegisterEvent("HONOR_XP_UPDATE", self.OnUpdate)
	K:RegisterEvent("PLAYER_FLAGS_CHANGED", self.OnUpdate)

	K.Mover(self.Container, "DataBars", "DataBars", {"TOP", "Minimap", "BOTTOM", 0, -6}, C["DataBars"].Width, self.Container:GetHeight())
end