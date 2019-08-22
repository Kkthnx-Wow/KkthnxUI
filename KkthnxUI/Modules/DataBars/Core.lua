local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DataBars")

local _G = _G
local math_floor = math.floor
local pairs = pairs
local string_format = string.format
local select = select

local ARTIFACT_POWER = _G.ARTIFACT_POWER
local backupColor = _G.FACTION_BAR_COLORS[1]
local C_AzeriteItem_FindActiveAzeriteItem = _G.C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = _G.C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = _G.C_AzeriteItem.GetPowerLevel
local C_Reputation_GetFactionParagonInfo = _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = _G.C_Reputation.IsFactionParagon
local CreateFrame = _G.CreateFrame
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local FactionStandingLabelUnknown = _G.UNKNOWN
local GameTooltip = _G.GameTooltip
local GetExpansionLevel = _G.GetExpansionLevel
local GetFactionInfo = _G.GetFactionInfo
local GetFriendshipReputation = _G.GetFriendshipReputation
local GetNumFactions = _G.GetNumFactions
local GetPetExperience = _G.GetPetExperience
local GetRestrictedAccountData = _G.GetRestrictedAccountData
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
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

local function GetUnitXP(unit)
	if (unit == "pet") then
		return GetPetExperience()
	else
		return UnitXP(unit), UnitXPMax(unit)
	end
end

local function IsPlayerMaxLevel()
	local maxLevel = GetRestrictedAccountData()
	if (maxLevel == 0) then
		maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
	end

	return maxLevel == UnitLevel("player")
end

function Module:SetupExperience()
	local expbar = CreateFrame("StatusBar", "KkthnxUI_ExperienceBar", self.Container)
	expbar:SetStatusBarTexture(self.DatabaseTexture)
	expbar:SetStatusBarColor(C["DataBars"].ExperienceColor[1], C["DataBars"].ExperienceColor[2], C["DataBars"].ExperienceColor[3], C["DataBars"].ExperienceColor[4])
	expbar:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	expbar:CreateBorder()

	local restbar = CreateFrame("StatusBar", "KkthnxUI_RestBar", self.Container)
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
	local reputation = CreateFrame("StatusBar", "KkthnxUI_ReputationBar", self.Container)
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
	local azerite = CreateFrame("Statusbar", "KkthnxUI_AzeriteBar", self.Container)
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
	local honor = CreateFrame("StatusBar", "KkthnxUI_HonorBar", self.Container)
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
	local ID, isFriend, friendText, standingLabel
	local isCapped
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
	else
		if reaction == MAX_REPUTATION_REACTION then
			-- max rank, make it look like a full bar
			min, max, value = 0, 1, 1
			isCapped = true
		end
	end

	local numFactions = GetNumFactions()
	if not name then
		self.Bars.Reputation:Hide()
	elseif name then
		self.Bars.Reputation:Show()

		local text
		local color = FACTION_BAR_COLORS[reaction] or backupColor
		self.Bars.Reputation:SetStatusBarColor(color.r, color.g, color.b)
		self.Bars.Reputation:SetMinMaxValues(min, max)
		self.Bars.Reputation:SetValue(value)

		for i = 1, numFactions do
			local factionName, _, standingID, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)
			local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
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

		if C["DataBars"].Text then
			if isCapped then
				text = string_format("%s: [%s]", name, isFriend and friendText or standingLabel)
			else
				text = string_format("%s: %s - %d%% [%s]", name, K.ShortValue(value - min), ((value - min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)
			end

			self.Bars.Reputation.Text:SetText(text)
		end
	end
end

function Module:UpdateExperience()
	local hideXP = ((UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) or IsXPUserDisabled())

	if hideXP then
		self.Bars.Experience:Hide()
	elseif not hideXP then
		self.Bars.Experience:Show()

		local cur, max = GetUnitXP("player")
		local rested = GetXPExhaustion()

		if max <= 0 then
			max = 1
		end

		self.Bars.Experience:SetMinMaxValues(0, max)
		self.Bars.Experience:SetValue(cur - 1 >= 0 and cur - 1 or 0)
		self.Bars.Experience:SetValue(cur)

		if rested and rested > 0 then
			self.Bars.Experience.RestBar:SetMinMaxValues(0, max)
			self.Bars.Experience.RestBar:SetValue(min(cur + rested, max))

			if C["DataBars"].Text then
				self.Bars.Experience.Text:SetText(string_format("%s - %d%% R:%s [%d%%]", K.ShortValue(cur), cur / max * 100, K.ShortValue(rested), rested / max * 100))
			end
		else
			self.Bars.Experience.RestBar:SetMinMaxValues(0, 1)
			self.Bars.Experience.RestBar:SetValue(0)

			if C["DataBars"].Text then
				self.Bars.Experience.Text:SetText(string_format("%s - %d%%", K.ShortValue(cur), cur / max * 100))
			end
		end
	end
end

function Module:UpdateAzerite(event, unit)
	if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
		return
	end

	local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	if not azeriteItemLocation or C_AzeriteItem_GetPowerLevel(azeriteItemLocation) == 50 then
		self.Bars.Azerite:Hide()
	elseif azeriteItemLocation then
		self.Bars.Azerite:Show()

		local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)

		self.Bars.Azerite:SetMinMaxValues(0, totalLevelXP)
		self.Bars.Azerite:SetValue(xp)

		if C["DataBars"].Text then
			self.Bars.Azerite.Text:SetText(string_format("%s - %s%% [%s]", K.ShortValue(xp), math_floor(xp / totalLevelXP * 100), currentLevel))
		end
	end
end

function Module:UpdateHonor(event, unit)
	if not C["DataBars"].TrackHonor then
		self.Bars.Honor:Hide()
		return
	end

	if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then
		return
	end

	local showHonor = true
	if not UnitIsPVP("player") then
		showHonor = false
	elseif UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
		showHonor = false
	end

	if not showHonor then
		self.Bars.Honor:Hide()
	else
		self.Bars.Honor:Show()

		local current = UnitHonor("player")
		local max = UnitHonorMax("player")

		if max == 0 then
			max = 1
		end

		self.Bars.Honor:SetMinMaxValues(0, max)
		self.Bars.Honor:SetValue(current)

		if C["DataBars"].Text then
			self.Bars.Honor.Text:SetText(string_format("%s - %d%%", K.ShortValue(current), current / max * 100))
		end
	end
end

function Module:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:ClearLines()

	if C["DataBars"].MouseOver then
		K.UIFrameFadeIn(self.Container, 0.25, self.Container:GetAlpha(), 1)
	end

	if (not IsPlayerMaxLevel() and not IsXPUserDisabled()) then
		local cur, max = GetUnitXP("player")
		local rested = GetXPExhaustion()

		GameTooltip:AddDoubleLine(L["Experience"], PLAYER.." "..LEVEL.." ("..K.Level..")", nil, nil, nil, 0.90, 0.80, 0.50)
		GameTooltip:AddDoubleLine(L["XP"], string_format("%s / %s (%d%%)", K.ShortValue(cur), K.ShortValue(max), math_floor(cur / max * 100)), 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Remaining"], string_format("%s (%s%% - %s "..L["Bars"]..")", K.ShortValue(max - cur), math_floor((max - cur) / max * 100), math_floor(20 * (max - cur) / max)), 1, 1, 1)

		if rested then
			GameTooltip:AddDoubleLine(L["Rested"], string_format("+%s (%s%%)", K.ShortValue(rested), math_floor(rested / max * 100)), 1, 1, 1)
		end
		GameTooltip:AddDoubleLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:118:218|t "..L["Middle Click"], L["Share Your Experience"], 1, 1, 1)
	end

	if GetWatchedFactionInfo() then
		if (not IsPlayerMaxLevel() and not IsXPUserDisabled()) then
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
			GameTooltip:AddLine(name)

			local friendID, friendTextLevel, _
			if factionID then
				friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
			end

			GameTooltip:AddDoubleLine(STANDING..":", (friendID and friendTextLevel) or _G["FACTION_STANDING_LABEL" .. reaction], 1, 1, 1)
			if reaction ~= MAX_REPUTATION_REACTION or C_Reputation_IsFactionParagon(factionID) then
				GameTooltip:AddDoubleLine(REPUTATION..":", string_format("%d / %d (%d%%)", value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
			end
			GameTooltip:AddDoubleLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t "..L["Left Click"], L["Toggle Reputation"], 1, 1, 1)
		end
	end

	if C_AzeriteItem_FindActiveAzeriteItem() then
		if (not IsPlayerMaxLevel() and not IsXPUserDisabled()) or GetWatchedFactionInfo() then
			GameTooltip:AddLine(" ")
		end

		local azeriteItemLocation = C_AzeriteItem_FindActiveAzeriteItem()
		local azeriteItem = Item:CreateFromItemLocation(azeriteItemLocation)
		local xp, totalLevelXP = C_AzeriteItem_GetAzeriteItemXPInfo(azeriteItemLocation)
		local currentLevel = C_AzeriteItem_GetPowerLevel(azeriteItemLocation)
		local xpToNextLevel = totalLevelXP - xp

		self.itemDataLoadedCancelFunc = azeriteItem:ContinueWithCancelOnItemLoad(function()
			local azeriteItemName = azeriteItem:GetItemName()

			GameTooltip:AddDoubleLine(ARTIFACT_POWER, azeriteItemName.." ("..currentLevel..")", nil, nil, nil, 0.90, 0.80, 0.50) -- Temp Locale
			GameTooltip:AddDoubleLine(L["AP"], string_format(" %d / %d (%d%%)", xp, totalLevelXP, xp / totalLevelXP * 100), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %d (%d%% - %d "..L["Bars"]..")", xpToNextLevel, xpToNextLevel / totalLevelXP * 100, 10 * xpToNextLevel / totalLevelXP), 1, 1, 1)
		end)
	end

	if C["DataBars"].TrackHonor then
		if IsPlayerMaxLevel() and UnitIsPVP("player") then
			GameTooltip:AddLine(" ")

			local current = UnitHonor("player")
			local max = UnitHonorMax("player")
			local level = UnitHonorLevel("player")

			GameTooltip:AddDoubleLine(HONOR.." "..LEVEL, level)
			GameTooltip:AddDoubleLine(L["Honor XP"], string_format(" %d / %d (%d%%)", current, max, current/max * 100), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Honor Remaining"], string_format(" %d (%d%% - %d "..L["Bars"]..")", max - current, (max - current) / max * 100, 20 * (max - current) / max), 1, 1, 1)
			GameTooltip:AddDoubleLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t "..L["Right Click"], L["Toggle PvP"], 1, 1, 1)
		end
	end

	GameTooltip:Show()
end

function Module:OnLeave()
	if C["DataBars"].MouseOver then
		K.UIFrameFadeOut(self.Container, 1, self.Container:GetAlpha(), 0.25)
	end

	GameTooltip:Hide()
end

function Module:OnClick(_, clicked)
	if K.CodeDebug then
		K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 430 - KkthnxUI|Modules|DataBars|Core -|r |cFFFFFF00" .. clicked .. " Clicked|r")
	end

	if clicked == "LeftButton" then
		if GetWatchedFactionInfo() then
			ToggleCharacter("ReputationFrame")
		end
	elseif clicked == "RightButton" then
		if C["DataBars"].TrackHonor then
			if IsPlayerMaxLevel() and UnitIsPVP("player") then
				TogglePVPUI()
			end
		end
	elseif clicked == "MiddleButton" then
		if not IsPlayerMaxLevel() and not IsXPUserDisabled() then
			local cur, max = GetUnitXP("player")

			if IsInGroup(LE_PARTY_CATEGORY_HOME) then
				SendChatMessage(L["XP"] .." ".. string_format("%s / %s (%d%%)", K.ShortValue(cur), K.ShortValue(max), math.floor(cur / max * 100)), "PARTY")
				SendChatMessage(L["Remaining"] .." ".. string_format("%s (%s%% - %s "..L["Bars"]..")", K.ShortValue(max - cur), math.floor((max - cur) / max * 100), math.floor(20 * (max - cur) / max)), "PARTY")
			end
		end
	end
end

function Module.OnUpdate()
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

	if C["DataBars"].Enable ~= true then
		return
    end

    Module.Bars = {}

	self.Container = CreateFrame("button", "KkthnxUI_Databars", K.PetBattleHider)
	self.Container:SetWidth(C["DataBars"].Width)
	self.Container:SetPoint("TOP", "Minimap", "BOTTOM", 0, -6)
	self.Container:RegisterForClicks("RightButtonUp", "LeftButtonUp", "MiddleButtonUp")

	self.Container:HookScript("OnEnter", self.OnEnter)
	self.Container:HookScript("OnLeave", self.OnLeave)
    self.Container:HookScript("OnClick", self.OnClick)

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