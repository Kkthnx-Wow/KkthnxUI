local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Miscellaneous")

local math_min = _G.math.min
local mod = _G.mod
local string_format = _G.string.format
local pairs = _G.pairs
local select = _G.select
local math_floor = _G.math.floor

local ARTIFACT_POWER = _G.ARTIFACT_POWER
local C_AzeriteItem_FindActiveAzeriteItem = _G.C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = _G.C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = _G.C_AzeriteItem.GetPowerLevel
local C_AzeriteItem_IsAzeriteItemAtMaxLevel = _G.C_AzeriteItem.IsAzeriteItemAtMaxLevel
local C_Reputation_GetFactionParagonInfo = _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = _G.C_Reputation.IsFactionParagon
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GetFactionInfo = _G.GetFactionInfo
local GetFriendshipReputation = _G.GetFriendshipReputation
local GetNumFactions = _G.GetNumFactions
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetXPExhaustion = _G.GetXPExhaustion
local HONOR = _G.HONOR
local IsLevelAtEffectiveMaxLevel = _G.IsLevelAtEffectiveMaxLevel
local IsPlayerAtEffectiveMaxLevel = _G.IsPlayerAtEffectiveMaxLevel
local IsTrialAccount = _G.IsTrialAccount
local IsVeteranTrialAccount = _G.IsVeteranTrialAccount
local IsWatchingHonorAsXP = _G.IsWatchingHonorAsXP
local IsXPUserDisabled = _G.IsXPUserDisabled
local LEVEL = _G.LEVEL
local NUM_FACTIONS_DISPLAYED = _G.NUM_FACTIONS_DISPLAYED
local REPUTATION_PROGRESS_FORMAT = _G.REPUTATION_PROGRESS_FORMAT
local UnitHonor = _G.UnitHonor
local UnitHonorLevel = _G.UnitHonorLevel
local UnitHonorMax = _G.UnitHonorMax
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

local CurrentXP, XPToLevel, RestedXP, PercentRested
local PercentXP, RemainXP, RemainTotal, RemainBars
local QuestLogXP = 0

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
		CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
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
		local friendshipID, standingText, nextThreshold, _
		friendshipID, _, _, _, _, _, standingText, _, nextThreshold = GetFriendshipReputation(factionID)

		if friendshipID then
			reaction, label = 5, standingText

			if not nextThreshold then
				minValue, maxValue, curValue = 0, 1, 1
			end
		elseif C_Reputation_IsFactionParagon(factionID) then
			local current, threshold
			current, threshold, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)

			if current and threshold then
				label, minValue, maxValue, curValue, reaction = L["Paragon"], 0, threshold, current % threshold, 9
			end

			self.reward:SetPoint("CENTER", self, "LEFT")
		end

		if not label then
			label = _G["FACTION_STANDING_LABEL" .. reaction] or UNKNOWN
		end

		local color = (reaction == 9 and { r = 0, g = 0.5, b = 0.9 }) or _G.FACTION_BAR_COLORS[reaction] -- reaction 9 is Paragon
		self:SetStatusBarColor(color.r, color.g, color.b)
		self:SetMinMaxValues(minValue, maxValue)
		self:SetValue(curValue)
		self:Show()
		self.reward:SetShown(rewardPending)

		local current, _, percent, capped = GetValues(curValue, minValue, maxValue)
		if capped then -- show only name and standing on exalted
			self.text:SetText(string_format("%s: [%s]", name, label))
		else
			self.text:SetText(string_format("%s: %s - %d%% [%s]", name, K.ShortValue(current), percent, K.ShortenString(label, 1, false)))
		end
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

	GameTooltip:AddLine(K.MyClassColor .. K.Name)
	local specIndex = GetSpecialization()
	if specIndex or specIndex == 5 then
		local _, specName = GetSpecializationInfo(specIndex)
		GameTooltip:AddDoubleLine("Specialization:", specName, 1, 1, 1)
	else
		GameTooltip:AddDoubleLine("Specialization:", UNKNOWN, 1, 1, 1)
	end

	if not IsPlayerAtEffectiveMaxLevel() then
		CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
		if XPToLevel <= 0 then
			XPToLevel = 1
		end

		local remainXP = XPToLevel - CurrentXP
		local remainPercent = remainXP / XPToLevel
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, K.ShortValue(remainXP)

		GameTooltip:AddLine(" ")
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
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(name, FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)

			local friendID, friendTextLevel, _
			if factionID then
				friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
			end

			GameTooltip:AddDoubleLine(STANDING .. ":", (friendID and friendTextLevel) or standing, 1, 1, 1)

			if reaction ~= _G.MAX_REPUTATION_REACTION or isParagon then
				local current, maximum, percent = GetValues(curValue, minValue, maxValue)
				GameTooltip:AddDoubleLine(REPUTATION .. ":", string_format("%d / %d (%d%%)", current, maximum, percent), 1, 1, 1)
			end
		end

		-- if factionID == 2465 then -- Hunting
		-- 	local _, rep, _, name, _, _, reaction, threshold, nextThreshold = GetFriendshipReputation(2463) -- 玛拉斯缪斯
		-- 	if nextThreshold and rep > 0 then
		-- 		local current = rep - threshold
		-- 		local currentMax = nextThreshold - threshold
		-- 		GameTooltip:AddLine(" ")
		-- 		GameTooltip:AddLine(name, 0.4, 0.6, 1)
		-- 		GameTooltip:AddDoubleLine(reaction, current.." - "..currentMax.." ("..math_floor(current / currentMax * 100).."%)", 0.4, 0.6, 1, 1, 1, 1)
		-- 	end
		-- end
	end

	if IsWatchingHonorAsXP() then
		local CurrentHonor, MaxHonor, CurrentLevel = UnitHonor("player"), UnitHonorMax("player"), UnitHonorLevel("player")
		local PercentHonor, RemainingHonor = (CurrentHonor / MaxHonor) * 100, MaxHonor - CurrentHonor
		GameTooltip:AddLine(" ")
		_G.GameTooltip:AddLine(HONOR, 0.94, 0.45, 0.25)
		_G.GameTooltip:AddDoubleLine("Level:", CurrentLevel, 1, 1, 1)
		_G.GameTooltip:AddDoubleLine("XP:", string_format(" %d / %d (%d%%)", CurrentHonor, MaxHonor, PercentHonor), 1, 1, 1)
		_G.GameTooltip:AddDoubleLine(
			"Remaining:",
			string_format(" %d (%d%% - %d " .. L["Bars"] .. ")", RemainingHonor, RemainingHonor / MaxHonor * 100, 20 * RemainingHonor / MaxHonor),
			1,
			1,
			1
		)
	end

	if IsAzeriteAvailable() then
		local azeriteItem, currentLevel, curXP, maxXP
		local function dataLoadedCancelFunc()
			_G.GameTooltip:AddLine(" ")
			_G.GameTooltip:AddLine(ARTIFACT_POWER, 0.90, 0.80, 0.50)
			_G.GameTooltip:AddDoubleLine("Level:", currentLevel, 1, 1, 1)
			_G.GameTooltip:AddDoubleLine("AP:", string_format(" %d / %d (%d%%)", curXP, maxXP, curXP / maxXP * 100), 1, 1, 1)
			_G.GameTooltip:AddDoubleLine(
				"Remaining:",
				string_format(" %d (%d%% - %d " .. L["Bars"] .. ")", maxXP - curXP, (maxXP - curXP) / maxXP * 100, 10 * (maxXP - curXP) / maxXP),
				1,
				1,
				1
			)
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
	-- bar:SetScript("OnMouseUp", function(_, btn)
	-- 	if not HasArtifactEquipped() or btn ~= "LeftButton" then
	-- 		return
	-- 	end

	-- 	if not ArtifactFrame or not ArtifactFrame:IsShown() then
	-- 		SocketInventoryItem(16)
	-- 	else
	-- 		K:TogglePanel(ArtifactFrame)
	-- 	end
	-- end)

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
	bar:SetSize(Minimap:GetWidth() or 190, 14)
	bar:SetHitRectInsets(0, 0, 0, -10)
	bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].DataBarsTexture))

	local spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Textures.Spark16Texture)
	spark:SetHeight(bar:GetHeight())
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)

	local border = CreateFrame("Frame", nil, bar)
	border:SetAllPoints(bar)
	border:SetFrameLevel(bar:GetFrameLevel())
	border:CreateBorder()

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints()
	rest:SetStatusBarTexture(K.GetTexture(C["UITextures"].DataBarsTexture))
	rest:SetStatusBarColor(1, 0, 1, 0.4)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar.restBar = rest

	local reward = bar:CreateTexture(nil, "OVERLAY")
	reward:SetAtlas("ParagonReputation_Bag")
	reward:SetSize(12, 14)
	bar.reward = reward

	local text = bar:CreateFontString(nil, "OVERLAY")
	text:SetFontObject(KkthnxUIFont)
	text:SetFont(select(1, text:GetFont()), 11, select(3, text:GetFont()))
	text:SetWidth(bar:GetWidth() - 6)
	text:SetWordWrap(false)
	text:SetPoint("LEFT", bar, "RIGHT", -3, 0)
	text:SetPoint("RIGHT", bar, "LEFT", 3, 0)
	bar.text = text

	Module:SetupExpRepScript(bar)

	if not bar.mover then
		bar.mover = K.Mover(bar, "bar", "bar", { "TOP", Minimap, "BOTTOM", 0, -6 })
	else
		bar.mover:SetSize(Minimap:GetWidth() or 190, 14)
	end
end
Module:RegisterMisc("ExpRep", Module.CreateExpbar)

-- Paragon reputation info
function Module:SetupParagonRepHook()
	local numFactions = GetNumFactions()
	local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
	for i = 1, NUM_FACTIONS_DISPLAYED, 1 do
		local factionIndex = factionOffset + i
		local factionRow = _G["ReputationBar" .. i]
		local factionBar = _G["ReputationBar" .. i .. "ReputationBar"]
		local factionStanding = _G["ReputationBar" .. i .. "ReputationBarFactionStanding"]

		if factionIndex <= numFactions then
			local factionID = select(14, GetFactionInfo(factionIndex))
			if factionID and C_Reputation_IsFactionParagon(factionID) then
				local currentValue, threshold = C_Reputation_GetFactionParagonInfo(factionID)
				if currentValue then
					local barValue = mod(currentValue, threshold)
					local factionStandingtext = L["Paragon"] .. math_floor(currentValue / threshold)

					factionBar:SetMinMaxValues(0, threshold)
					factionBar:SetValue(barValue)
					factionBar:SetStatusBarColor(0, 0.5, 0.9)
					factionStanding:SetText(factionStandingtext)
					factionRow.standingText = factionStandingtext
					factionRow.rolloverText = string_format(REPUTATION_PROGRESS_FORMAT, K.ShortValue(barValue), K.ShortValue(threshold))
				end
			end
		end
	end
end

function Module:CreateParagonReputation()
	if not C["Misc"].ParagonEnable then
		return
	end

	hooksecurefunc("ReputationFrame_Update", Module.SetupParagonRepHook)
end
Module:RegisterMisc("ParagonRep", Module.CreateParagonReputation)
