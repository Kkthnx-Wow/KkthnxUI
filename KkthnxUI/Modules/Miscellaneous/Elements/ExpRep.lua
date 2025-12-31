local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- Lua
local math_min = math.min
local math_floor = math.floor
local math_huge = math.huge
local tonumber = tonumber
local type = type
local ipairs = ipairs
local string_format = string.format
local string_find = string.find

-- WoW API
local CreateFrame = CreateFrame
local GetTime = GetTime
local GetXPExhaustion = GetXPExhaustion
local IsAltKeyDown = IsAltKeyDown
local IsInGroup = IsInGroup
local IsLevelAtEffectiveMaxLevel = IsLevelAtEffectiveMaxLevel
local IsRestrictedAccount = IsRestrictedAccount
local IsTrialAccount = IsTrialAccount
local IsVeteranTrialAccount = IsVeteranTrialAccount
local IsWatchingHonorAsXP = IsWatchingHonorAsXP
local IsXPUserDisabled = IsXPUserDisabled
local SendChatMessage = SendChatMessage
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local UnitHonor = UnitHonor
local UnitHonorLevel = UnitHonorLevel
local UnitHonorMax = UnitHonorMax

local GameTooltip = GameTooltip
local Minimap = Minimap
local MinimapCluster = MinimapCluster

-- C_ APIs
local C_GossipInfo_GetFriendshipReputation = C_GossipInfo and C_GossipInfo.GetFriendshipReputation
local C_MajorFactions_GetMajorFactionData = C_MajorFactions and C_MajorFactions.GetMajorFactionData
local C_MajorFactions_HasMaximumRenown = C_MajorFactions and C_MajorFactions.HasMaximumRenown
local C_Reputation_GetWatchedFactionData = C_Reputation and C_Reputation.GetWatchedFactionData
local C_Reputation_GetFactionParagonInfo = C_Reputation and C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation and C_Reputation.IsFactionParagon
local C_Reputation_IsMajorFaction = C_Reputation and C_Reputation.IsMajorFaction

-- Azerite (legacy; guard for modern clients)
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem and C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem and C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem and C_AzeriteItem.GetPowerLevel

-- Constants
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local UNKNOWN = _G.UNKNOWN

-- Tooltip/chat state
local CurrentXP, XPToLevel, PercentRested, PercentXP, RemainXP, RemainTotal, RemainBars
local RestedXP = 0

local CurrentHonor, MaxHonor, CurrentLevel, PercentHonor, RemainingHonor
local CurrentAzerite, MaxAzerite, AzeriteLevel, PercentAzerite

local barDisplayString = ""
local currentMode = "none" -- "xp" | "rep" | "honor" | "azerite"

local altKeyText = K.InfoColor .. ALT_KEY_TEXT .. " "
local lastMessageTime = 0
local COOLDOWN_DURATION = 10

local function XPIsTrialMax()
	return (IsRestrictedAccount() or IsTrialAccount() or IsVeteranTrialAccount()) and (K.Level == 20)
end

local function XPIsLevelMax()
	return IsLevelAtEffectiveMaxLevel(K.Level) or IsXPUserDisabled() or XPIsTrialMax()
end

local function ClampRange(minVal, maxVal)
	if maxVal <= minVal then
		maxVal = minVal + 1
	end
	return minVal, maxVal
end

local function SetBar(bar, minVal, maxVal, value)
	minVal, maxVal = ClampRange(minVal, maxVal)
	bar:SetMinMaxValues(minVal, maxVal)
	bar:SetValue(value)
end

local function IsAzeriteAvailable()
	if not C_AzeriteItem_FindActiveAzeriteItem then
		return false
	end

	local itemLoc = C_AzeriteItem_FindActiveAzeriteItem()
	return itemLoc and itemLoc.IsEquipmentSlot and itemLoc:IsEquipmentSlot()
end

local function PickFactionColor(reaction)
	local kk = K.Colors and K.Colors.faction and K.Colors.faction[reaction]
	if kk then
		return kk.r, kk.g, kk.b
	end

	local bl = FACTION_BAR_COLORS and FACTION_BAR_COLORS[reaction]
	if bl then
		return bl.r, bl.g, bl.b
	end

	return 1, 1, 1
end

-- RENOWN_LEVEL_LABEL is usually a format string (contains %d).
local function FormatRenownLabel(level)
	level = tonumber(level) or 0

	local lbl = _G.RENOWN_LEVEL_LABEL
	if type(lbl) == "string" then
		-- pattern mode: "%%d" matches literal "%d" in the format string
		if string_find(lbl, "%%d") then
			return string_format(lbl, level)
		end
		return lbl .. " " .. level
	end

	return "Renown " .. level
end

-- Returns: current, maximum, percent, capped, remaining
local function GetProgress(cur, maxV, val)
	if not maxV or maxV <= 0 then
		return 0, 1, 0, true, 0
	end

	local current = (val or 0) - (cur or 0)
	local maximum = maxV - (cur or 0)
	if maximum <= 0 then
		maximum = 1
	end

	if current < 0 then
		current = 0
	elseif current > maximum then
		current = maximum
	end

	local percent = (current / maximum) * 100
	local remaining = maximum - current
	local capped = (current >= maximum)

	return current, maximum, percent, capped, remaining
end

-- Bar Handlers
local function HandleXP(bar)
	currentMode = "xp"

	CurrentXP = UnitXP("player") or 0
	XPToLevel = UnitXPMax("player") or 1
	if XPToLevel <= 0 then
		XPToLevel = 1
	end

	RestedXP = GetXPExhaustion() or 0

	local remainXP = XPToLevel - CurrentXP
	local remainFrac = (XPToLevel > 0) and (remainXP / XPToLevel) or 0

	RemainTotal = remainFrac * 100
	RemainBars = remainFrac * 20
	PercentXP = (CurrentXP / XPToLevel) * 100
	RemainXP = K.ShortValue(remainXP)

	bar:SetStatusBarColor(0, 0.4, 1, 0.8)
	bar.restBar:SetStatusBarColor(1, 0, 1, 0.4)

	SetBar(bar, 0, XPToLevel, CurrentXP)

	barDisplayString = string_format("%s - %s (%.1f%%)", K.ShortValue(CurrentXP), K.ShortValue(XPToLevel), PercentXP)

	local isRested = RestedXP > 0
	if isRested then
		SetBar(bar.restBar, 0, XPToLevel, math_min(CurrentXP + RestedXP, XPToLevel))
	end

	bar:Show()
	bar.restBar:SetShown(isRested)
	bar.text:SetText(barDisplayString)
end

local function HandleRep(bar)
	currentMode = "rep"

	local data = C_Reputation_GetWatchedFactionData and C_Reputation_GetWatchedFactionData()
	if not data then
		bar:Hide()
		bar.text:SetText("")
		return
	end

	local name = data.name
	local reaction = data.reaction or 1
	local curThreshold = data.currentReactionThreshold or 0
	local nextThreshold = data.nextReactionThreshold or 1
	local standingValue = data.currentStanding or 0
	local factionID = data.factionID

	local standingLabel
	local rewardPending
	local repLevel

	-- Friendship rep
	if factionID and C_GossipInfo_GetFriendshipReputation then
		local f = C_GossipInfo_GetFriendshipReputation(factionID)
		if f and f.friendshipFactionID and f.friendshipFactionID > 0 then
			standingLabel = f.reaction
			curThreshold = f.reactionThreshold or 0
			nextThreshold = f.nextThreshold or math_huge
			standingValue = f.standing or standingValue
			repLevel = f.friendshipFactionLevel
		end
	end

	-- Paragon
	if not standingLabel and factionID and C_Reputation_IsFactionParagon and C_Reputation_IsFactionParagon(factionID) then
		local cur, thresh
		cur, thresh, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)
		if cur and thresh and thresh > 0 then
			standingLabel = L["Paragon"] or "Paragon"
			curThreshold = 0
			nextThreshold = thresh
			standingValue = cur % thresh
			reaction = 9
		end
	end

	-- Major faction (Renown)
	if not standingLabel and factionID and C_Reputation_IsMajorFaction and C_Reputation_IsMajorFaction(factionID) and C_MajorFactions_GetMajorFactionData then
		local major = C_MajorFactions_GetMajorFactionData(factionID)
		if major then
			reaction = 10
			curThreshold = 0
			nextThreshold = major.renownLevelThreshold or 1

			if C_MajorFactions_HasMaximumRenown and C_MajorFactions_HasMaximumRenown(factionID) then
				standingValue = nextThreshold
			else
				standingValue = major.renownReputationEarned or 0
			end

			repLevel = major.renownLevel
			local renownHex = K.RGBToHex(0, 0.74, 0.95)
			standingLabel = string_format("%s%s|r", renownHex, FormatRenownLabel(repLevel))
		end
	end

	if not standingLabel then
		standingLabel = _G["FACTION_STANDING_LABEL" .. reaction] or UNKNOWN
	end

	-- Bar values
	local r, g, b = PickFactionColor(reaction)
	bar:SetStatusBarColor(r, g, b, 1)

	local minV = (nextThreshold == math_huge or curThreshold == nextThreshold) and 0 or curThreshold
	local maxV = (nextThreshold == math_huge) and 1 or nextThreshold
	SetBar(bar, minV, maxV, standingValue)

	-- Paragon bag icon
	bar.reward:ClearAllPoints()
	bar.reward:SetPoint("CENTER", bar, "LEFT")
	bar.reward:SetShown(not not rewardPending)

	-- Text
	if nextThreshold == math_huge then
		barDisplayString = string_format("%s: [%s]", name or "", standingLabel)
	else
		local cur, maxP, pct = GetProgress(curThreshold, nextThreshold, standingValue)
		barDisplayString = string_format("%s: %s - %s (%.1f%%) [%s]", name or "", K.ShortValue(cur), K.ShortValue(maxP), pct, standingLabel)
	end

	bar:Show()
	bar.restBar:Hide()
	bar.text:SetText(barDisplayString)
end

local function HandleHonor(bar, event, unit)
	if event == "PLAYER_FLAGS_CHANGED" and unit and unit ~= "player" then
		return
	end

	currentMode = "honor"

	CurrentHonor = UnitHonor("player") or 0
	MaxHonor = UnitHonorMax("player") or 1
	CurrentLevel = UnitHonorLevel("player") or 0
	if MaxHonor <= 0 then
		MaxHonor = 1
	end

	PercentHonor = (CurrentHonor / MaxHonor) * 100
	RemainingHonor = MaxHonor - CurrentHonor
	if RemainingHonor < 0 then
		RemainingHonor = 0
	end

	bar:SetStatusBarColor(0.94, 0.45, 0.25, 1)
	SetBar(bar, 0, MaxHonor, CurrentHonor)

	barDisplayString = string_format("%s - %s (%.1f%%) [%s]", K.ShortValue(CurrentHonor), K.ShortValue(MaxHonor), PercentHonor, CurrentLevel)

	bar:Show()
	bar.restBar:Hide()
	bar.text:SetText(barDisplayString)
end

local function HandleAzerite(bar)
	currentMode = "azerite"

	CurrentAzerite, MaxAzerite, AzeriteLevel, PercentAzerite = nil, nil, nil, nil

	if not IsAzeriteAvailable() then
		return
	end

	local itemLoc = C_AzeriteItem_FindActiveAzeriteItem()
	if not itemLoc then
		return
	end

	local cur, maxV = C_AzeriteItem_GetAzeriteItemXPInfo(itemLoc)
	local lvl = C_AzeriteItem_GetPowerLevel(itemLoc)
	if not maxV or maxV <= 0 then
		return
	end

	CurrentAzerite = cur or 0
	MaxAzerite = maxV
	AzeriteLevel = lvl or 0
	PercentAzerite = (MaxAzerite > 0) and ((CurrentAzerite / MaxAzerite) * 100) or 0

	bar:SetStatusBarColor(0.901, 0.8, 0.601, 1)
	SetBar(bar, 0, MaxAzerite, CurrentAzerite)

	bar:Show()
	bar.restBar:Hide()
	bar.text:SetText(string_format("%s - %s (%.1f%%) [%s]", K.ShortValue(CurrentAzerite), K.ShortValue(MaxAzerite), PercentAzerite, AzeriteLevel))
end

-- Tooltip Sections (consistent formatting)
local function AddXPTooltip()
	GameTooltip:AddDoubleLine("|cff0070ff" .. COMBAT_XP_GAIN .. "|r", string_format("%s %d", LEVEL, K.Level))
	GameTooltip:AddLine(" ")

	if CurrentXP and XPToLevel then
		GameTooltip:AddDoubleLine(L["XP"], string_format(" %s - %s (%.2f%%)", K.ShortValue(CurrentXP), K.ShortValue(XPToLevel), PercentXP or 0), 1, 1, 1)
	end

	if RemainXP then
		GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %.2f %s)", RemainXP, RemainTotal or 0, RemainBars or 0, L["Bars"]), 1, 1, 1)
	end

	if RestedXP and RestedXP > 0 then
		local restedPct = (XPToLevel and XPToLevel > 0) and ((RestedXP / XPToLevel) * 100) or 0
		GameTooltip:AddDoubleLine(L["Rested"], string_format(" +%s (%.2f%%)", K.ShortValue(RestedXP), restedPct), 1, 1, 1)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(altKeyText .. KEY_PLUS .. K.RightButton, "Send to party chat|r")
end

local function AddWatchedRepTooltip(addSpacingBefore)
	if not (C_Reputation_GetWatchedFactionData and C_Reputation_GetWatchedFactionData()) then
		return false
	end

	local data = C_Reputation_GetWatchedFactionData()
	if not data or not data.name then
		return false
	end

	if addSpacingBefore then
		GameTooltip:AddLine(" ")
	end

	local name = data.name
	local reaction = data.reaction or 1
	local curThreshold = data.currentReactionThreshold or 0
	local nextThreshold = data.nextReactionThreshold or 1
	local standingValue = data.currentStanding or 0
	local factionID = data.factionID

	local standingLabel
	local rewardPending
	local repLevel

	-- Friendship rep
	if factionID and C_GossipInfo_GetFriendshipReputation then
		local f = C_GossipInfo_GetFriendshipReputation(factionID)
		if f and f.friendshipFactionID and f.friendshipFactionID > 0 then
			standingLabel = f.reaction
			curThreshold = f.reactionThreshold or 0
			nextThreshold = f.nextThreshold or math_huge
			standingValue = f.standing or standingValue
			repLevel = f.friendshipFactionLevel
		end
	end

	-- Paragon
	if not standingLabel and factionID and C_Reputation_IsFactionParagon and C_Reputation_IsFactionParagon(factionID) then
		local cur, thresh
		cur, thresh, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)
		if cur and thresh and thresh > 0 then
			standingLabel = L["Paragon"] or "Paragon"
			curThreshold = 0
			nextThreshold = thresh
			standingValue = cur % thresh
			reaction = 9
		end
	end

	-- Major faction (Renown)
	if not standingLabel and factionID and C_Reputation_IsMajorFaction and C_Reputation_IsMajorFaction(factionID) and C_MajorFactions_GetMajorFactionData then
		local major = C_MajorFactions_GetMajorFactionData(factionID)
		if major then
			reaction = 10
			curThreshold = 0
			nextThreshold = major.renownLevelThreshold or 1

			if C_MajorFactions_HasMaximumRenown and C_MajorFactions_HasMaximumRenown(factionID) then
				standingValue = nextThreshold
			else
				standingValue = major.renownReputationEarned or 0
			end

			repLevel = major.renownLevel
			standingLabel = FormatRenownLabel(repLevel)
		end
	end

	if not standingLabel then
		standingLabel = _G["FACTION_STANDING_LABEL" .. reaction] or UNKNOWN
	end

	-- Header: NAME -> STANDING (same style as XP: Experience -> Level)
	GameTooltip:AddDoubleLine("|cff00bdfc" .. name .. "|r", standingLabel, 1, 1, 1)
	GameTooltip:AddLine(" ")

	if nextThreshold ~= math_huge then
		local cur, maxP, pct, _, remaining = GetProgress(curThreshold, nextThreshold, standingValue)
		GameTooltip:AddDoubleLine("Reputation:", string_format(" %s - %s (%.1f%%)", K.ShortValue(cur), K.ShortValue(maxP), pct), 1, 1, 1)

		local remainFrac = (maxP > 0) and (remaining / maxP) or 0
		local remainPct = remainFrac * 100
		local remainBars = remainFrac * 20
		GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %.2f %s)", K.ShortValue(remaining), remainPct, remainBars, L["Bars"]), 1, 1, 1)
	end

	if rewardPending then
		GameTooltip:AddLine("Paragon Reward Available", 0, 1, 0)
	end

	return true
end

local function AddHonorTooltip(addSpacingBefore)
	if addSpacingBefore then
		GameTooltip:AddLine(" ")
	end

	GameTooltip:AddDoubleLine("|cff00bdfc" .. HONOR .. "|r", LEVEL .. " " .. (CurrentLevel or 0))
	GameTooltip:AddLine(" ")

	local cur = CurrentHonor or 0
	local maxV = MaxHonor or 1
	local pct = PercentHonor or 0
	local remaining = RemainingHonor or 0

	GameTooltip:AddDoubleLine(L["Honor XP"], string_format(" %s - %s (%.1f%%)", K.ShortValue(cur), K.ShortValue(maxV), pct), 1, 1, 1)

	local remainFrac = (maxV > 0) and (remaining / maxV) or 0
	local remainPct = remainFrac * 100
	local remainBars = remainFrac * 20
	GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %.2f %s)", K.ShortValue(remaining), remainPct, remainBars, L["Bars"]), 1, 1, 1)
end

local function AddAzeriteTooltip(addSpacingBefore)
	if addSpacingBefore then
		GameTooltip:AddLine(" ")
	end

	GameTooltip:AddDoubleLine("|cff00bdfc" .. (AZERITE_POWER or "Azerite") .. "|r", LEVEL .. " " .. (AzeriteLevel or 0))
	GameTooltip:AddLine(" ")

	local cur = CurrentAzerite or 0
	local maxV = MaxAzerite or 1
	local pct = PercentAzerite or 0
	local remaining = (maxV - cur)
	if remaining < 0 then
		remaining = 0
	end

	GameTooltip:AddDoubleLine(AZERITE_POWER or "Azerite", string_format(" %s - %s (%.1f%%)", K.ShortValue(cur), K.ShortValue(maxV), pct), 1, 1, 1)

	local remainFrac = (maxV > 0) and (remaining / maxV) or 0
	local remainPct = remainFrac * 100
	local remainBars = remainFrac * 20
	GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %.2f %s)", K.ShortValue(remaining), remainPct, remainBars, L["Bars"]), 1, 1, 1)
end

-- Frame Scripts
local function UpdateBarSize(bar)
	local w = (Minimap and Minimap:GetWidth()) or 190
	bar:SetWidth(w)
	if bar.text then
		bar.text:SetWidth(w - 6)
	end
	if bar.mover then
		bar.mover:SetSize(w, bar:GetHeight())
	end
end

local function OnExpBarEvent(self, event, unit)
	-- keep width in sync
	if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
		UpdateBarSize(self)
	end

	-- fast reject: unit events not for player
	if unit and unit ~= "player" and (event == "PLAYER_XP_UPDATE" or event == "PLAYER_FLAGS_CHANGED") then
		return
	end

	if not XPIsLevelMax() then
		HandleXP(self)
		return
	end

	if C_Reputation_GetWatchedFactionData and C_Reputation_GetWatchedFactionData() then
		HandleRep(self)
		return
	end

	if IsWatchingHonorAsXP() then
		HandleHonor(self, event, unit)
		return
	end

	if IsAzeriteAvailable() then
		HandleAzerite(self)
		return
	end

	currentMode = "none"
	self:Hide()
	self.text:SetText("")
end

local function OnExpBarEnter(self)
	if GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")

	local addedXP = false
	if not XPIsLevelMax() then
		AddXPTooltip()
		addedXP = true
	end

	-- Rep shows even while leveling if watched; spacing depends on whether XP block exists
	local addedRep = AddWatchedRepTooltip(addedXP)

	if IsWatchingHonorAsXP() then
		AddHonorTooltip(addedXP or addedRep)
	end

	if IsAzeriteAvailable() then
		AddAzeriteTooltip(addedXP or addedRep or IsWatchingHonorAsXP())
	end

	GameTooltip:Show()
end

local function OnExpBarLeave()
	K.HideTooltip()
end

local function BuildPartyMessage()
	if currentMode == "xp" and CurrentXP and XPToLevel then
		local msg = string_format("XP: %s/%s (%.2f%%) Remaining: %s (%.2f%% - %.2f bars)", K.ShortValue(CurrentXP), K.ShortValue(XPToLevel), PercentXP or 0, RemainXP or "?", RemainTotal or 0, RemainBars or 0)
		if RestedXP and RestedXP > 0 then
			msg = msg .. string_format(" Rested: %s", K.ShortValue(RestedXP))
		end
		return msg
	end

	if currentMode == "rep" and barDisplayString ~= "" then
		return "Reputation: " .. barDisplayString
	end

	if currentMode == "honor" and CurrentHonor and MaxHonor then
		local remaining = RemainingHonor or 0
		local remainFrac = (MaxHonor > 0) and (remaining / MaxHonor) or 0
		return string_format("Honor: %s-%s (%.1f%%) Remaining: %s (%.2f%% - %.2f bars) Level: %d", K.ShortValue(CurrentHonor), K.ShortValue(MaxHonor), PercentHonor or 0, K.ShortValue(remaining), remainFrac * 100, remainFrac * 20, CurrentLevel or 0)
	end

	if currentMode == "azerite" and CurrentAzerite and MaxAzerite then
		local remaining = MaxAzerite - CurrentAzerite
		if remaining < 0 then
			remaining = 0
		end
		local remainFrac = (MaxAzerite > 0) and (remaining / MaxAzerite) or 0
		return string_format("Azerite: %s-%s (%.1f%%) Remaining: %s (%.2f%% - %.2f bars) Level: %d", K.ShortValue(CurrentAzerite), K.ShortValue(MaxAzerite), PercentAzerite or 0, K.ShortValue(remaining), remainFrac * 100, remainFrac * 20, AzeriteLevel or 0)
	end

	return nil
end

local function OnExpRepMouseUp(_, button)
	if not (IsAltKeyDown() and button == "RightButton") then
		return
	end

	local now = GetTime()
	if (now - lastMessageTime) < COOLDOWN_DURATION then
		K.Print(SPELL_FAILED_CUSTOM_ERROR_808 or ERR_GENERIC_NO_TARGET or "On cooldown.")
		return
	end
	lastMessageTime = now

	if not IsInGroup() then
		K.Print(ERR_QUEST_PUSH_NOT_IN_PARTY_S)
		return
	end

	local msg = BuildPartyMessage()
	if msg and msg ~= "" then
		SendChatMessage(msg, "PARTY")
	end
end

local ExpRep_EventList = {
	"PLAYER_LEVEL_UP",
	"UPDATE_EXHAUSTION",
	"PLAYER_XP_UPDATE",
	"ENABLE_XP_GAIN",
	"DISABLE_XP_GAIN",
	"UPDATE_FACTION",
	"QUEST_FINISHED",
	"COMBAT_TEXT_UPDATE",
	"MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
	"MAJOR_FACTION_UNLOCKED",
	"HONOR_XP_UPDATE",
	"PLAYER_FLAGS_CHANGED",
	"PLAYER_EQUIPMENT_CHANGED",
	"UI_SCALE_CHANGED",
	"DISPLAY_SIZE_CHANGED",
}

local function SetupExpRepScript(bar)
	for _, event in ipairs(ExpRep_EventList) do
		bar:RegisterEvent(event)
	end

	bar:SetScript("OnEvent", OnExpBarEvent)
	bar:SetScript("OnEnter", OnExpBarEnter)
	bar:SetScript("OnLeave", OnExpBarLeave)
	bar:SetScript("OnMouseUp", OnExpRepMouseUp)

	UpdateBarSize(bar)
	OnExpBarEvent(bar) -- initial
end

function Module:CreateExpbar()
	if not C["Misc"].ExpRep then
		return
	end

	local bar = CreateFrame("StatusBar", "KKUI_ExpRepBar", MinimapCluster)
	bar:SetPoint("TOP", Minimap, "BOTTOM", 0, -6)
	bar:SetHeight(16)
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
	text:SetFont(string_format("%s", select(1, text:GetFont())), 11, select(3, text:GetFont()))
	text:SetJustifyH("CENTER")
	text:SetWordWrap(false)
	text:SetPoint("CENTER", bar, "CENTER", 0, 0)
	text:SetAlpha(0.8)
	bar.text = text

	SetupExpRepScript(bar)

	if not bar.mover then
		bar.mover = K.Mover(bar, "ExpRepBar", "Exp/Rep Bar", { "TOP", Minimap, "BOTTOM", 0, -6 })
	end

	UpdateBarSize(bar)
end

Module:RegisterMisc("ExpRep", Module.CreateExpbar)
