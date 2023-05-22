local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

local math_min = math.min
local mod = mod
local string_format = string.format
local pairs = pairs
local select = select
local math_floor = math.floor

local ARTIFACT_POWER = ARTIFACT_POWER
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem.GetPowerLevel
local C_AzeriteItem_IsAzeriteItemAtMaxLevel = C_AzeriteItem.IsAzeriteItemAtMaxLevel
local C_MajorFactions_GetMajorFactionData = C_MajorFactions.GetMajorFactionData
local C_MajorFactions_HasMaximumRenown = C_MajorFactions.HasMaximumRenown
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local C_Reputation_IsMajorFaction = C_Reputation.IsMajorFaction
local GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation
local GetWatchedFactionInfo = GetWatchedFactionInfo
local GetXPExhaustion = GetXPExhaustion
local HONOR = HONOR
local IsLevelAtEffectiveMaxLevel = IsLevelAtEffectiveMaxLevel
local IsPlayerAtEffectiveMaxLevel = IsPlayerAtEffectiveMaxLevel
local IsTrialAccount = IsTrialAccount
local IsVeteranTrialAccount = IsVeteranTrialAccount
local IsWatchingHonorAsXP = IsWatchingHonorAsXP
local IsXPUserDisabled = IsXPUserDisabled
local LEVEL = LEVEL
local REPUTATION_PROGRESS_FORMAT = REPUTATION_PROGRESS_FORMAT
local UnitHonor = UnitHonor
local UnitHonorLevel = UnitHonorLevel
local UnitHonorMax = UnitHonorMax
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax

local CurrentXP, XPToLevel, RestedXP, PercentRested
local PercentXP, RemainXP, RemainTotal, RemainBars

local function IsAzeriteAvailable()
	local itemLocation = C_AzeriteItem_FindActiveAzeriteItem()
	return itemLocation and itemLocation:IsEquipmentSlot() and not C_AzeriteItem_IsAzeriteItemAtMaxLevel()
end

local function GetValues(curValue, minValue, maxValue)
	local maximum = maxValue - minValue
	local current, diff = curValue - minValue, maximum

	if diff == 0 then -- prevent a division by zero
		diff = 1
	end

	if current == maximum then
		return 1, 1, 100, true
	else
		return current, maximum, current / diff * 100
	end
end

function Module:ExpBar_Update(event, unit)
	if not IsPlayerAtEffectiveMaxLevel() then
		CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion() or 0
		if XPToLevel <= 0 then
			XPToLevel = 1
		end

		local remainXP = XPToLevel - CurrentXP
		local remainPercent = remainXP / XPToLevel
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, K.ShortValue(remainXP)

		self:SetStatusBarColor(0, 0.4, 1, 0.8)
		self.restBar:SetStatusBarColor(1, 0, 1, 0.4)

		local displayString = ""

		self:SetMinMaxValues(0, XPToLevel)
		self:SetValue(CurrentXP)
		self:Show()

		displayString = string_format("%s - %.2f%%", K.ShortValue(CurrentXP), PercentXP)

		local isRested = RestedXP and RestedXP > 0
		if isRested then
			self.restBar:SetMinMaxValues(0, XPToLevel)
			self.restBar:SetValue(math_min(CurrentXP + RestedXP, XPToLevel))

			PercentRested = (RestedXP / XPToLevel) * 100
			displayString = string_format("%s R:%s [%.2f%%]", displayString, K.ShortValue(RestedXP), PercentRested)
		end
		self.restBar:SetShown(isRested)

		if IsLevelAtEffectiveMaxLevel(K.Level) or IsXPUserDisabled() or (IsTrialAccount() or IsVeteranTrialAccount()) and (K.Level == 20) then
			self:SetMinMaxValues(0, 1)
			self:SetValue(1)
			self:Show()

			displayString = IsXPUserDisabled() and "Disabled" or "Max Level"
		end

		self.text:SetText(displayString)
		self.text:Show()
	elseif GetWatchedFactionInfo() then
		local label, rewardPending
		local name, reaction, minValue, maxValue, curValue, factionID = GetWatchedFactionInfo()
		local info = factionID and GetFriendshipReputation(factionID)
		if info and info.friendshipFactionID then
			local isMajorFaction = factionID and C_Reputation_IsMajorFaction(factionID)

			if info and info.friendshipFactionID > 0 then
				label, minValue, maxValue, curValue = info.reaction, info.reactionThreshold or 0, info.nextThreshold or 1, info.standing or 1
			elseif isMajorFaction then
				local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
				local renownColor = { r = 0, g = 0.74, b = 0.95 }
				local renownHex = K.RGBToHex(renownColor.r, renownColor.g, renownColor.b) -- 10 (Renown)

				reaction, minValue, maxValue = 10, 0, majorFactionData.renownLevelThreshold
				curValue = C_MajorFactions_HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
				label = format("%s%s|r %s", renownHex, RENOWN_LEVEL_LABEL, majorFactionData.renownLevel)
			end
		end

		if not label and C_Reputation_IsFactionParagon(factionID) then
			local current, threshold
			current, threshold, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)

			if current and threshold then
				label, minValue, maxValue, curValue, reaction = L["Paragon"], 0, threshold, current % threshold, 9
			end
		end

		if not label then
			label = _G["FACTION_STANDING_LABEL" .. reaction] or UNKNOWN
		end

		local color = K.Colors.faction[reaction]
		self:SetStatusBarColor(color.r or 1, color.g or 1, color.b or 1, 1)
		self:SetMinMaxValues(minValue, maxValue)
		self:SetValue(curValue)

		self.reward:ClearAllPoints()
		self.reward:SetPoint("CENTER", self, "LEFT")
		self.reward:SetShown(rewardPending)

		local current, _, percent, capped = GetValues(curValue, minValue, maxValue)
		if capped then -- show only name and standing on exalted
			self.text:SetText(string_format("%s: [%s]", name, label))
		else
			self.text:SetText(string_format("%s: %s - %d%% [%s]", name, K.ShortValue(current), percent, label))
		end
		self:Show()
		self.text:Show()
	elseif IsWatchingHonorAsXP() then
		if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then
			return
		end

		local CurrentHonor, MaxHonor, CurrentLevel = UnitHonor("player"), UnitHonorMax("player"), UnitHonorLevel("player")

		-- Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
		if MaxHonor == 0 then
			MaxHonor = 1
		end

		local PercentHonor = (CurrentHonor / MaxHonor) * 100

		self:SetMinMaxValues(0, MaxHonor)
		self:SetValue(CurrentHonor)
		self:SetStatusBarColor(0.94, 0.45, 0.25)
		self:Show()
		self.text:SetText(string_format("%s - %d%% - [%s]", K.ShortValue(CurrentHonor), PercentHonor, CurrentLevel))
		self.text:Show()
	elseif IsAzeriteAvailable() then
		if event == "UNIT_INVENTORY_CHANGED" and unit ~= "player" then
			return
		end
		local item = C_AzeriteItem_FindActiveAzeriteItem()
		local cur, max = C_AzeriteItem_GetAzeriteItemXPInfo(item)
		local currentLevel = C_AzeriteItem_GetPowerLevel(item)
		self:SetStatusBarColor(0.901, 0.8, 0.601, 1)
		self:SetMinMaxValues(0, max)
		self:SetValue(cur)
		self:Show()
		self.text:SetFormattedText("%s - %s%% [%s]", K.ShortValue(cur), math_floor(cur / max * 100), currentLevel)
		self.text:Show()
	else
		self:Hide()
		self.text:Hide()
	end
end

function Module:ExpBar_UpdateTooltip()
	if GameTooltip:IsForbidden() then
		return
	end
	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")

	if not IsPlayerAtEffectiveMaxLevel() then
		CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		if XPToLevel <= 0 then
			XPToLevel = 1
		end

		local remainXP = XPToLevel - CurrentXP
		local remainPercent = remainXP / XPToLevel
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, K.ShortValue(remainXP)

		GameTooltip:AddLine("Experience", 0, 0.4, 1)
		GameTooltip:AddDoubleLine(LEVEL, K.Level, 1, 1, 1)
		GameTooltip:AddDoubleLine("XP:", string_format(" %d / %d (%.2f%%)", CurrentXP, XPToLevel, PercentXP), 1, 1, 1)
		GameTooltip:AddDoubleLine("Remaining:", string_format(" %s (%.2f%% - %d " .. L["Bars"] .. ")", RemainXP, RemainTotal, RemainBars), 1, 1, 1)

		if RestedXP and RestedXP > 0 then
			GameTooltip:AddDoubleLine("Rested:", string_format("%d (%.2f%%)", RestedXP, PercentRested), 1, 1, 1)
		end
	end

	if GetWatchedFactionInfo() then
		local name, reaction, minValue, maxValue, curValue, factionID = GetWatchedFactionInfo()
		local standing = _G["FACTION_STANDING_LABEL" .. reaction] or UNKNOWN
		local isParagon = C_Reputation_IsFactionParagon(factionID)

		if factionID and isParagon then
			local current, threshold = C_Reputation_GetFactionParagonInfo(factionID)
			if current and threshold then
				standing, minValue, maxValue, curValue = L["Paragon"], 0, threshold, current % threshold
			end
		end

		if name then
			if not IsPlayerAtEffectiveMaxLevel() then
				GameTooltip:AddLine(" ")
			end
			GameTooltip:AddLine(name, K.RGBToHex(0, 0.74, 0.95))

			local friendID, friendTextLevel, _
			if factionID then
				friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
				if friendID and friendID.friendshipFactionID > 0 then
					standing = friendID.reaction
				end
			end

			local isMajorFaction = factionID and C_Reputation_IsMajorFaction(factionID)
			if not isMajorFaction then
				GameTooltip:AddDoubleLine(STANDING .. ":", (friendID and friendTextLevel) or standing, 1, 1, 1)
			end

			if isMajorFaction then
				local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
				curValue = C_MajorFactions_HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
				maxValue = majorFactionData.renownLevelThreshold
				GameTooltip:AddDoubleLine(RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel, format("%d / %d (%d%%)", GetValues(curValue, 0, maxValue)), BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b)
			elseif isParagon or (reaction ~= _G.MAX_REPUTATION_REACTION) then
				local current, maximum, percent = GetValues(curValue, minValue, maxValue)
				GameTooltip:AddDoubleLine(REPUTATION .. ":", format("%d / %d (%d%%)", current, maximum, percent), 1, 1, 1)
			end
		end
	end

	if IsWatchingHonorAsXP() then
		local CurrentHonor, MaxHonor, CurrentLevel = UnitHonor("player"), UnitHonorMax("player"), UnitHonorLevel("player")
		local PercentHonor, RemainingHonor = (CurrentHonor / MaxHonor) * 100, MaxHonor - CurrentHonor
		GameTooltip:AddLine(" ")
		_G.GameTooltip:AddLine(HONOR, 0.94, 0.45, 0.25)
		_G.GameTooltip:AddDoubleLine("Level:", CurrentLevel, 1, 1, 1)
		_G.GameTooltip:AddDoubleLine("XP:", string_format(" %d / %d (%d%%)", CurrentHonor, MaxHonor, PercentHonor), 1, 1, 1)
		_G.GameTooltip:AddDoubleLine("Remaining:", string_format(" %d (%d%% - %d " .. L["Bars"] .. ")", RemainingHonor, RemainingHonor / MaxHonor * 100, 20 * RemainingHonor / MaxHonor), 1, 1, 1)
	end

	if IsAzeriteAvailable() then
		local azeriteItem, currentLevel, curXP, maxXP
		local function dataLoadedCancelFunc()
			_G.GameTooltip:AddLine(" ")
			_G.GameTooltip:AddLine(ARTIFACT_POWER, 0.90, 0.80, 0.50)
			_G.GameTooltip:AddDoubleLine("Level:", currentLevel, 1, 1, 1)
			_G.GameTooltip:AddDoubleLine("AP:", string_format(" %d / %d (%d%%)", curXP, maxXP, curXP / maxXP * 100), 1, 1, 1)
			_G.GameTooltip:AddDoubleLine("Remaining:", string_format(" %d (%d%% - %d " .. L["Bars"] .. ")", maxXP - curXP, (maxXP - curXP) / maxXP * 100, 10 * (maxXP - curXP) / maxXP), 1, 1, 1)
		end

		local item = C_AzeriteItem_FindActiveAzeriteItem()
		if item then
			curXP, maxXP = C_AzeriteItem_GetAzeriteItemXPInfo(item)
			currentLevel = C_AzeriteItem_GetPowerLevel(item)
			azeriteItem = Item:CreateFromItemLocation(item)
			azeriteItem:ContinueWithCancelOnItemLoad(dataLoadedCancelFunc)
		end
	end

	GameTooltip:Show()
end

function Module:SetupExpRepScript(bar)
	bar.eventList = {
		"PLAYER_XP_UPDATE",
		"PLAYER_LEVEL_UP",
		"UPDATE_EXHAUSTION",
		"PLAYER_ENTERING_WORLD",
		"UPDATE_FACTION",
		"ARTIFACT_XP_UPDATE",
		"PLAYER_EQUIPMENT_CHANGED",
		"ENABLE_XP_GAIN",
		"DISABLE_XP_GAIN",
		"AZERITE_ITEM_EXPERIENCE_CHANGED",
		"HONOR_XP_UPDATE",
	}

	for _, event in pairs(bar.eventList) do
		bar:RegisterEvent(event)
	end

	bar:SetScript("OnEvent", Module.ExpBar_Update)
	bar:SetScript("OnEnter", Module.ExpBar_UpdateTooltip)
	bar:SetScript("OnLeave", K.HideTooltip)

	hooksecurefunc(StatusTrackingBarManager, "UpdateBarsShown", function()
		Module.ExpBar_Update(bar)
	end)
end

function Module:CreateExpbar()
	if not C["Misc"].ExpRep then
		return
	end

	local bar = CreateFrame("StatusBar", "KKUI_ExpRepBar", MinimapCluster)
	bar:SetPoint("TOP", Minimap, "BOTTOM", 0, -6)
	bar:SetSize(Minimap:GetWidth() or 190, 16)
	bar:SetHitRectInsets(0, 0, 0, -10)
	bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

	local spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Textures.Spark16Texture)
	spark:SetHeight(bar:GetHeight() - 2)
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
	spark:SetAlpha(0.6)

	local border = CreateFrame("Frame", nil, bar)
	border:SetAllPoints(bar)
	border:SetFrameLevel(bar:GetFrameLevel())
	border:CreateBorder()

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints()
	rest:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	rest:SetStatusBarColor(1, 0, 1, 0.4)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar.restBar = rest

	local reward = bar:CreateTexture(nil, "OVERLAY")
	reward:SetAtlas("ParagonReputation_Bag")
	reward:SetSize(12, 14)
	bar.reward = reward

	local text = bar:CreateFontString(nil, "OVERLAY")
	text:SetFontObject(K.UIFont)
	text:SetFont(select(1, text:GetFont()), 11, select(3, text:GetFont()))
	text:SetWidth(bar:GetWidth() - 6)
	text:SetWordWrap(false)
	text:SetPoint("LEFT", bar, "RIGHT", -3, 0)
	text:SetPoint("RIGHT", bar, "LEFT", 3, 0)
	text:SetAlpha(0.8) -- Fade this a bit?
	bar.text = text

	Module:SetupExpRepScript(bar)

	if not bar.mover then
		bar.mover = K.Mover(bar, "bar", "bar", { "TOP", Minimap, "BOTTOM", 0, -6 })
	else
		bar.mover:SetSize(Minimap:GetWidth() or 190, 14)
	end
end
Module:RegisterMisc("ExpRep", Module.CreateExpbar)

function Module:CreateParagonReputation()
	if not C["Misc"].ParagonEnable then
		return
	end

	hooksecurefunc("ReputationFrame_InitReputationRow", function(factionRow)
		local factionID = factionRow.factionID
		local factionContainer = factionRow.Container
		local factionBar = factionContainer.ReputationBar
		local factionStanding = factionBar.FactionStanding

		if factionContainer.Paragon:IsShown() then
			local currentValue, threshold = C_Reputation_GetFactionParagonInfo(factionID)
			if currentValue then
				local barValue = mod(currentValue, threshold)
				local factionStandingtext = L["Paragon"] .. floor(currentValue / threshold)

				factionBar:SetMinMaxValues(0, threshold)
				factionBar:SetValue(barValue)
				factionStanding:SetText(factionStandingtext)
				factionRow.standingText = factionStandingtext
				factionRow.rolloverText = format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(barValue), BreakUpLargeNumbers(threshold))
			end
		end
	end)
end
Module:RegisterMisc("ParagonRep", Module.CreateParagonReputation)
