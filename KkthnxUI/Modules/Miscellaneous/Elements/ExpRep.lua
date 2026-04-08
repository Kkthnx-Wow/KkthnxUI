--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Manages and displays the experience, reputation, honor, and Azerite status bars.
-- - Design: Dynamically switches between bar types based on player state and tracked factions.
-- - Events: PLAYER_LEVEL_UP, UPDATE_EXHAUSTION, PLAYER_XP_UPDATE, UPDATE_FACTION, etc.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local ipairs = _G.ipairs
local math_floor = _G.math.floor
local math_huge = _G.math.huge
local math_min = _G.math.min
local string_find = _G.string.find
local string_format = _G.string.format
local tonumber = _G.tonumber
local type = _G.type

local _G = _G
local C_AzeriteItem_FindActiveAzeriteItem = _G.C_AzeriteItem and _G.C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = _G.C_AzeriteItem and _G.C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = _G.C_AzeriteItem and _G.C_AzeriteItem.GetPowerLevel
local C_GossipInfo_GetFriendshipReputation = _G.C_GossipInfo and _G.C_GossipInfo.GetFriendshipReputation
local C_MajorFactions_GetMajorFactionData = _G.C_MajorFactions and _G.C_MajorFactions.GetMajorFactionData
local C_MajorFactions_HasMaximumRenown = _G.C_MajorFactions and _G.C_MajorFactions.HasMaximumRenown
local C_Reputation_GetFactionParagonInfo = _G.C_Reputation and _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_GetWatchedFactionData = _G.C_Reputation and _G.C_Reputation.GetWatchedFactionData
local C_Reputation_IsFactionParagon = _G.C_Reputation and _G.C_Reputation.IsFactionParagon
local C_Reputation_IsMajorFaction = _G.C_Reputation and _G.C_Reputation.IsMajorFaction
local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime
local GetXPExhaustion = _G.GetXPExhaustion
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGroup = _G.IsInGroup
local IsLevelAtEffectiveMaxLevel = _G.IsLevelAtEffectiveMaxLevel
local IsRestrictedAccount = _G.IsRestrictedAccount
local IsTrialAccount = _G.IsTrialAccount
local IsVeteranTrialAccount = _G.IsVeteranTrialAccount
local IsWatchingHonorAsXP = _G.IsWatchingHonorAsXP
local IsXPUserDisabled = _G.IsXPUserDisabled
local SendChatMessage = _G.SendChatMessage
local UnitHonor = _G.UnitHonor
local UnitHonorLevel = _G.UnitHonorLevel
local UnitHonorMax = _G.UnitHonorMax
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

-- SG: State Variables
local currentXP, xpToLevel, restedXP
local percentRested, percentXP, remainXP, remainTotal, remainBars
local currentHonor, maxHonor, currentHonorLevel, percentHonor, remainingHonor
local currentAzerite, maxAzerite, azeriteLevel, percentAzerite
local barDisplayString = ""
local currentBarMode = "none" -- "xp" | "rep" | "honor" | "azerite"
local lastReportTime = 0
local REPORT_COOLDOWN = 10

local function isTrialAccountAtMaxLevel()
	return (IsRestrictedAccount() or IsTrialAccount() or IsVeteranTrialAccount()) and (K.Level == 20)
end

local function isPlayerAtMaxLevel()
	return IsLevelAtEffectiveMaxLevel(K.Level) or IsXPUserDisabled() or isTrialAccountAtMaxLevel()
end

local function clampProgressRange(minValue, maxValue)
	if maxValue <= minValue then
		maxValue = minValue + 1
	end
	return minValue, maxValue
end

local function setProgressBarValues(currentBar, minValue, maxValue, curValue)
	minValue, maxValue = clampProgressRange(minValue, maxValue)
	currentBar:SetMinMaxValues(minValue, maxValue)
	currentBar:SetValue(curValue)
end

local function isAzeritePowerAvailable()
	if not C_AzeriteItem_FindActiveAzeriteItem then
		return false
	end

	local itemLoc = C_AzeriteItem_FindActiveAzeriteItem()
	return itemLoc and itemLoc.IsEquipmentSlot and itemLoc:IsEquipmentSlot()
end

local function getFactionColorByReaction(reaction)
	local kkthnxColor = K.Colors and K.Colors.faction and K.Colors.faction[reaction]
	if kkthnxColor then
		return kkthnxColor.r, kkthnxColor.g, kkthnxColor.b
	end

	local blizzardColor = _G.FACTION_BAR_COLORS and _G.FACTION_BAR_COLORS[reaction]
	if blizzardColor then
		return blizzardColor.r, blizzardColor.g, blizzardColor.b
	end

	return 1, 1, 1
end

local function formatRenownLevelLabel(level)
	level = tonumber(level) or 0
	local label = _G.RENOWN_LEVEL_LABEL
	if type(label) == "string" then
		if string_find(label, "%%d") then
			return string_format(label, level)
		end
		return label .. " " .. level
	end
	return "Renown " .. level
end

-- REASON: Calculates standardized progress statistics for display and reporting.
local function calculateProgressInfo(minValue, maxValue, curValue)
	if not maxValue or maxValue <= 0 then
		return 0, 1, 0, true, 0
	end

	local current = (curValue or 0) - (minValue or 0)
	local maximum = maxValue - (minValue or 0)
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
	local isCapped = (current >= maximum)

	return current, maximum, percent, isCapped, remaining
end

-- REASON: Updates the experience bar state and visuals.
local function handleExperienceBar(currentBar)
	currentBarMode = "xp"
	currentXP = UnitXP("player") or 0
	xpToLevel = UnitXPMax("player") or 1
	if xpToLevel <= 0 then
		xpToLevel = 1
	end

	restedXP = GetXPExhaustion() or 0
	local remainXPVal = xpToLevel - currentXP
	local remainFraction = (xpToLevel > 0) and (remainXPVal / xpToLevel) or 0

	remainTotal = remainFraction * 100
	remainBars = remainFraction * 20
	percentXP = (currentXP / xpToLevel) * 100
	remainXP = K.ShortValue(remainXPVal)

	currentBar:SetStatusBarColor(0, 0.4, 1, 0.8)
	currentBar.restBar:SetStatusBarColor(1, 0, 1, 0.4)

	setProgressBarValues(currentBar, 0, xpToLevel, currentXP)
	barDisplayString = string_format("%s - %s (%.1f%%)", K.ShortValue(currentXP), K.ShortValue(xpToLevel), percentXP)

	local isRested = restedXP > 0
	if isRested then
		setProgressBarValues(currentBar.restBar, 0, xpToLevel, math_min(currentXP + restedXP, xpToLevel))
	end

	currentBar:Show()
	currentBar.restBar:SetShown(isRested)
	currentBar.text:SetText(barDisplayString)
end

-- REASON: Updates the reputation bar state and visuals, handling friendship, paragon, and renown systems.
local function handleReputationBar(currentBar)
	currentBarMode = "rep"
	local factionData = C_Reputation_GetWatchedFactionData and C_Reputation_GetWatchedFactionData()
	if not factionData then
		currentBar:Hide()
		currentBar.text:SetText("")
		return
	end

	local name = factionData.name
	local reaction = factionData.reaction or 1
	local curThreshold = factionData.currentReactionThreshold or 0
	local nextThreshold = factionData.nextReactionThreshold or 1
	local standingValue = factionData.currentStanding or 0
	local factionID = factionData.factionID
	local standingLabel, rewardPending, renownLevel

	if factionID and C_GossipInfo_GetFriendshipReputation then
		local friendshipData = C_GossipInfo_GetFriendshipReputation(factionID)
		if friendshipData and friendshipData.friendshipFactionID and friendshipData.friendshipFactionID > 0 then
			standingLabel = friendshipData.reaction
			curThreshold = friendshipData.reactionThreshold or 0
			nextThreshold = friendshipData.nextThreshold or math_huge
			standingValue = friendshipData.standing or standingValue
			renownLevel = friendshipData.friendshipFactionLevel
		end
	end

	if not standingLabel and factionID and C_Reputation_IsFactionParagon and C_Reputation_IsFactionParagon(factionID) then
		local cur, thresh
		cur, thresh, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)
		if cur and thresh and thresh > 0 then
			standingLabel = L["Paragon"]
			curThreshold = 0
			nextThreshold = thresh
			standingValue = cur % thresh
			reaction = 9
		end
	end

	if not standingLabel and factionID and C_Reputation_IsMajorFaction and C_Reputation_IsMajorFaction(factionID) and C_MajorFactions_GetMajorFactionData then
		local majorFactionData = _G.C_MajorFactions.GetMajorFactionData(factionID)
		if majorFactionData then
			reaction = 10
			curThreshold = 0
			nextThreshold = majorFactionData.renownLevelThreshold or 1
			if C_MajorFactions_HasMaximumRenown and C_MajorFactions_HasMaximumRenown(factionID) then
				standingValue = nextThreshold
			else
				standingValue = majorFactionData.renownReputationEarned or 0
			end
			renownLevel = majorFactionData.renownLevel
			local renownHex = K.RGBToHex(0, 0.74, 0.95)
			standingLabel = string_format("%s%s|r", renownHex, formatRenownLevelLabel(renownLevel))
		end
	end

	if not standingLabel then
		standingLabel = _G["FACTION_STANDING_LABEL" .. reaction] or _G.UNKNOWN
	end

	local r, g, b = getFactionColorByReaction(reaction)
	currentBar:SetStatusBarColor(r, g, b, 1)

	local minValue = (nextThreshold == math_huge or curThreshold == nextThreshold) and 0 or curThreshold
	local maxValue = (nextThreshold == math_huge) and 1 or nextThreshold
	setProgressBarValues(currentBar, minValue, maxValue, standingValue)

	currentBar.reward:ClearAllPoints()
	currentBar.reward:SetPoint("CENTER", currentBar, "LEFT")
	currentBar.reward:SetShown(not not rewardPending)

	if nextThreshold == math_huge then
		barDisplayString = string_format("%s: [%s]", name or "", standingLabel)
	else
		local cur, maxP, pct = calculateProgressInfo(curThreshold, nextThreshold, standingValue)
		barDisplayString = string_format("%s: %s - %s (%.1f%%) [%s]", name or "", K.ShortValue(cur), K.ShortValue(maxP), pct, standingLabel)
	end

	currentBar:Show()
	currentBar.restBar:Hide()
	currentBar.text:SetText(barDisplayString)
end

-- REASON: Updates the honor bar state and visuals.
local function handleHonorBar(currentBar, event, unit)
	if event == "PLAYER_FLAGS_CHANGED" and unit and unit ~= "player" then
		return
	end

	currentBarMode = "honor"
	currentHonor = UnitHonor("player") or 0
	maxHonor = UnitHonorMax("player") or 1
	currentHonorLevel = UnitHonorLevel("player") or 0
	if maxHonor <= 0 then
		maxHonor = 1
	end

	percentHonor = (currentHonor / maxHonor) * 100
	remainingHonor = math_min(maxHonor - currentHonor, 0) -- Fixed logic
	remainingHonor = maxHonor - currentHonor
	if remainingHonor < 0 then
		remainingHonor = 0
	end

	currentBar:SetStatusBarColor(0.94, 0.45, 0.25, 1)
	setProgressBarValues(currentBar, 0, maxHonor, currentHonor)
	barDisplayString = string_format("%s - %s (%.1f%%) [%s]", K.ShortValue(currentHonor), K.ShortValue(maxHonor), percentHonor, currentHonorLevel)

	currentBar:Show()
	currentBar.restBar:Hide()
	currentBar.text:SetText(barDisplayString)
end

-- REASON: Updates the Azerite power bar state and visuals.
local function handleAzeriteBar(currentBar)
	currentBarMode = "azerite"
	currentAzerite, maxAzerite, azeriteLevel, percentAzerite = nil, nil, nil, nil

	if not isAzeritePowerAvailable() then
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

	currentAzerite = cur or 0
	maxAzerite = maxV
	azeriteLevel = lvl or 0
	percentAzerite = (maxAzerite > 0) and ((currentAzerite / maxAzerite) * 100) or 0

	currentBar:SetStatusBarColor(0.901, 0.8, 0.601, 1)
	setProgressBarValues(currentBar, 0, maxAzerite, currentAzerite)

	currentBar:Show()
	currentBar.restBar:Hide()
	currentBar.text:SetText(string_format("%s - %s (%.1f%%) [%s]", K.ShortValue(currentAzerite), K.ShortValue(maxAzerite), percentAzerite, azeriteLevel))
end

-- Tooltip Sections (consistent formatting)
-- Tooltip Sections
local function addExperienceTooltip()
	_G.GameTooltip:AddDoubleLine("|cff0070ff" .. _G.COMBAT_XP_GAIN .. "|r", string_format("%s %d", _G.LEVEL, K.Level))
	_G.GameTooltip:AddLine(" ")

	if currentXP and xpToLevel then
		_G.GameTooltip:AddDoubleLine(L["XP"], string_format(" %s - %s (%.2f%%)", K.ShortValue(currentXP), K.ShortValue(xpToLevel), percentXP or 0), 1, 1, 1)
	end

	if remainXP then
		_G.GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %.2f %s)", remainXP, remainTotal or 0, remainBars or 0, L["Bars"]), 1, 1, 1)
	end

	if restedXP and restedXP > 0 then
		local restedPercent = (xpToLevel and xpToLevel > 0) and ((restedXP / xpToLevel) * 100) or 0
		_G.GameTooltip:AddDoubleLine(L["Rested"], string_format(" +%s (%.2f%%)", K.ShortValue(restedXP), restedPercent), 1, 1, 1)
	end

	_G.GameTooltip:AddLine(" ")
	local altKeyText = K.InfoColor .. _G.ALT_KEY_TEXT .. " "
	_G.GameTooltip:AddDoubleLine(altKeyText .. _G.KEY_PLUS .. K.RightButton, "Send to party chat|r")
end

local function addWatchedReputationTooltip(addSpacingBefore)
	if not (C_Reputation_GetWatchedFactionData and C_Reputation_GetWatchedFactionData()) then
		return false
	end

	local factionData = C_Reputation_GetWatchedFactionData()
	if not factionData or not factionData.name then
		return false
	end

	if addSpacingBefore then
		_G.GameTooltip:AddLine(" ")
	end

	local name = factionData.name
	local reaction = factionData.reaction or 1
	local curThreshold = factionData.currentReactionThreshold or 0
	local nextThreshold = factionData.nextReactionThreshold or 1
	local standingValue = factionData.currentStanding or 0
	local factionID = factionData.factionID
	local standingLabel, rewardPending, renownLevel

	if factionID and C_GossipInfo_GetFriendshipReputation then
		local friendshipData = C_GossipInfo_GetFriendshipReputation(factionID)
		if friendshipData and friendshipData.friendshipFactionID and friendshipData.friendshipFactionID > 0 then
			standingLabel = friendshipData.reaction
			curThreshold = friendshipData.reactionThreshold or 0
			nextThreshold = friendshipData.nextThreshold or math_huge
			standingValue = friendshipData.standing or standingValue
			renownLevel = friendshipData.friendshipFactionLevel
		end
	end

	if not standingLabel and factionID and C_Reputation_IsFactionParagon and C_Reputation_IsFactionParagon(factionID) then
		local cur, thresh
		cur, thresh, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)
		if cur and thresh and thresh > 0 then
			standingLabel = L["Paragon"]
			curThreshold = 0
			nextThreshold = thresh
			standingValue = cur % thresh
			reaction = 9
		end
	end

	if not standingLabel and factionID and C_Reputation_IsMajorFaction and C_Reputation_IsMajorFaction(factionID) and C_MajorFactions_GetMajorFactionData then
		local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
		if majorFactionData then
			reaction = 10
			curThreshold = 0
			nextThreshold = majorFactionData.renownLevelThreshold or 1
			if C_MajorFactions_HasMaximumRenown and C_MajorFactions_HasMaximumRenown(factionID) then
				standingValue = nextThreshold
			else
				standingValue = majorFactionData.renownReputationEarned or 0
			end
			renownLevel = majorFactionData.renownLevel
			standingLabel = formatRenownLevelLabel(renownLevel)
		end
	end

	if not standingLabel then
		standingLabel = _G["FACTION_STANDING_LABEL" .. reaction] or _G.UNKNOWN
	end

	_G.GameTooltip:AddDoubleLine("|cff00bdfc" .. name .. "|r", standingLabel, 1, 1, 1)
	_G.GameTooltip:AddLine(" ")

	if nextThreshold ~= math_huge then
		local cur, maxP, pct, _, remaining = calculateProgressInfo(curThreshold, nextThreshold, standingValue)
		_G.GameTooltip:AddDoubleLine("Reputation:", string_format(" %s - %s (%.1f%%)", K.ShortValue(cur), K.ShortValue(maxP), pct), 1, 1, 1)

		local remainFraction = (maxP > 0) and (remaining / maxP) or 0
		local remainPercent = remainFraction * 100
		local remainBarsVal = remainFraction * 20
		_G.GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %.2f %s)", K.ShortValue(remaining), remainPercent, remainBarsVal, L["Bars"]), 1, 1, 1)
	end

	if rewardPending then
		_G.GameTooltip:AddLine("Paragon Reward Available", 0, 1, 0)
	end

	return true
end

local function addHonorTooltip(addSpacingBefore)
	if addSpacingBefore then
		_G.GameTooltip:AddLine(" ")
	end

	_G.GameTooltip:AddDoubleLine("|cff00bdfc" .. _G.HONOR .. "|r", _G.LEVEL .. " " .. (currentHonorLevel or 0))
	_G.GameTooltip:AddLine(" ")

	local cur = currentHonor or 0
	local maxV = maxHonor or 1
	local pct = percentHonor or 0
	local remaining = remainingHonor or 0

	_G.GameTooltip:AddDoubleLine(L["Honor XP"], string_format(" %s - %s (%.1f%%)", K.ShortValue(cur), K.ShortValue(maxV), pct), 1, 1, 1)

	local remainFraction = (maxV > 0) and (remaining / maxV) or 0
	local remainPercent = remainFraction * 100
	local remainBarsVal = remainFraction * 20
	_G.GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %.2f %s)", K.ShortValue(remaining), remainPercent, remainBarsVal, L["Bars"]), 1, 1, 1)
end

local function addAzeriteTooltip(addSpacingBefore)
	if addSpacingBefore then
		_G.GameTooltip:AddLine(" ")
	end

	_G.GameTooltip:AddDoubleLine("|cff00bdfc" .. (_G.AZERITE_POWER or "Azerite") .. "|r", _G.LEVEL .. " " .. (azeriteLevel or 0))
	_G.GameTooltip:AddLine(" ")

	local cur = currentAzerite or 0
	local maxV = maxAzerite or 1
	local pct = percentAzerite or 0
	local remaining = (maxV - cur)
	if remaining < 0 then
		remaining = 0
	end

	_G.GameTooltip:AddDoubleLine(_G.AZERITE_POWER or "Azerite", string_format(" %s - %s (%.1f%%)", K.ShortValue(cur), K.ShortValue(maxV), pct), 1, 1, 1)

	local remainFraction = (maxV > 0) and (remaining / maxV) or 0
	local remainPercent = remainFraction * 100
	local remainBarsVal = remainFraction * 20
	_G.GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %.2f %s)", K.ShortValue(remaining), remainPercent, remainBarsVal, L["Bars"]), 1, 1, 1)
end

-- Frame Scripts
local function updateBarSize(currentBar)
	local barWidth = (_G.Minimap and _G.Minimap:GetWidth()) or 190
	currentBar:SetWidth(barWidth)
	if currentBar.text then
		currentBar.text:SetWidth(barWidth - 6)
	end
	if currentBar.mover then
		currentBar.mover:SetSize(barWidth, currentBar:GetHeight())
	end
end

local function onExpBarEvent(self, event, unit)
	if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
		updateBarSize(self)
	end

	if unit and unit ~= "player" and (event == "PLAYER_XP_UPDATE" or event == "PLAYER_FLAGS_CHANGED") then
		return
	end

	if not isPlayerAtMaxLevel() then
		handleExperienceBar(self)
		return
	end

	if C_Reputation_GetWatchedFactionData and C_Reputation_GetWatchedFactionData() then
		handleReputationBar(self)
		return
	end

	if IsWatchingHonorAsXP() then
		handleHonorBar(self, event, unit)
		return
	end

	if isAzeritePowerAvailable() then
		handleAzeriteBar(self)
		return
	end

	currentBarMode = "none"
	self:Hide()
	self.text:SetText("")
end

local function onExpBarEnter(self)
	if _G.GameTooltip:IsForbidden() then
		return
	end

	_G.GameTooltip:ClearLines()
	_G.GameTooltip:SetOwner(self, "ANCHOR_CURSOR")

	local addedXP = false
	if not isPlayerAtMaxLevel() then
		addExperienceTooltip()
		addedXP = true
	end

	local addedRep = addWatchedReputationTooltip(addedXP)

	if IsWatchingHonorAsXP() then
		addHonorTooltip(addedXP or addedRep)
	end

	if isAzeritePowerAvailable() then
		addAzeriteTooltip(addedXP or addedRep or IsWatchingHonorAsXP())
	end

	_G.GameTooltip:Show()
end

local function onExpBarLeave()
	K.HideTooltip()
end

local function buildPartyReportMessage()
	if currentBarMode == "xp" and currentXP and xpToLevel then
		local reportMessage = string_format("XP: %s/%s (%.2f%%) Remaining: %s (%.2f%% - %.2f bars)", K.ShortValue(currentXP), K.ShortValue(xpToLevel), percentXP or 0, remainXP or "?", remainTotal or 0, remainBars or 0)
		if restedXP and restedXP > 0 then
			reportMessage = reportMessage .. string_format(" Rested: %s", K.ShortValue(restedXP))
		end
		return reportMessage
	end

	if currentBarMode == "rep" and barDisplayString ~= "" then
		return "Reputation: " .. barDisplayString
	end

	if currentBarMode == "honor" and currentHonor and maxHonor then
		local remaining = remainingHonor or 0
		local remainFraction = (maxHonor > 0) and (remaining / maxHonor) or 0
		return string_format("Honor: %s-%s (%.1f%%) Remaining: %s (%.2f%% - %.2f bars) Level: %d", K.ShortValue(currentHonor), K.ShortValue(maxHonor), percentHonor or 0, K.ShortValue(remaining), remainFraction * 100, remainFraction * 20, currentHonorLevel or 0)
	end

	if currentBarMode == "azerite" and currentAzerite and maxAzerite then
		local remaining = (maxAzerite or 0) - (currentAzerite or 0)
		if remaining < 0 then
			remaining = 0
		end
		local remainFraction = (maxAzerite and maxAzerite > 0) and (remaining / maxAzerite) or 0
		return string_format("Azerite: %s-%s (%.1f%%) Remaining: %s (%.2f%% - %.2f bars) Level: %d", K.ShortValue(currentAzerite or 0), K.ShortValue(maxAzerite or 0), percentAzerite or 0, K.ShortValue(remaining), remainFraction * 100, remainFraction * 20, azeriteLevel or 0)
	end

	return nil
end

local function onExpRepMouseUp(_, button)
	if not (IsAltKeyDown() and button == "RightButton") then
		return
	end

	local currentTime = GetTime()
	if (currentTime - lastReportTime) < REPORT_COOLDOWN then
		_G.K.Print(_G.SPELL_FAILED_CUSTOM_ERROR_808 or _G.ERR_GENERIC_NO_TARGET or "On cooldown.")
		return
	end
	lastReportTime = currentTime

	if not IsInGroup() then
		_G.K.Print(_G.ERR_QUEST_PUSH_NOT_IN_PARTY_S)
		return
	end

	local reportMessage = buildPartyReportMessage()
	if reportMessage and reportMessage ~= "" then
		SendChatMessage(reportMessage, "PARTY")
	end
end

local EXPREP_EVENT_LIST = {
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

local function setupExpRepScripts(currentBar)
	for _, event in ipairs(EXPREP_EVENT_LIST) do
		currentBar:RegisterEvent(event)
	end

	currentBar:SetScript("OnEvent", onExpBarEvent)
	currentBar:SetScript("OnEnter", onExpBarEnter)
	currentBar:SetScript("OnLeave", onExpBarLeave)
	currentBar:SetScript("OnMouseUp", onExpRepMouseUp)

	updateBarSize(currentBar)
	onExpBarEvent(currentBar) -- REASON: Initial update to set the bar state correctly on load.
end

function Module:CreateExpbar()
	if not C["Misc"].ExpRep then
		return
	end

	local expRepBar = CreateFrame("StatusBar", "KKUI_ExpRepBar", _G.MinimapCluster)
	expRepBar:SetPoint("TOP", _G.Minimap, "BOTTOM", 0, -6)
	expRepBar:SetHeight(16)
	expRepBar:SetHitRectInsets(0, 0, 0, -10)
	expRepBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

	local sparkTexture = expRepBar:CreateTexture(nil, "OVERLAY")
	sparkTexture:SetTexture(C["Media"].Textures.Spark16Texture)
	sparkTexture:SetHeight(expRepBar:GetHeight() - 2)
	sparkTexture:SetBlendMode("ADD")
	sparkTexture:SetPoint("CENTER", expRepBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	sparkTexture:SetAlpha(0.6)

	local borderFrame = CreateFrame("Frame", nil, expRepBar)
	borderFrame:SetAllPoints(expRepBar)
	borderFrame:SetFrameLevel(expRepBar:GetFrameLevel())
	borderFrame:CreateBorder()

	local restedBar = CreateFrame("StatusBar", nil, expRepBar)
	restedBar:SetAllPoints()
	restedBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	restedBar:SetStatusBarColor(1, 0, 1, 0.4)
	restedBar:SetFrameLevel(expRepBar:GetFrameLevel() - 1)
	expRepBar.restBar = restedBar

	local rewardTexture = expRepBar:CreateTexture(nil, "OVERLAY")
	rewardTexture:SetAtlas("ParagonReputation_Bag")
	rewardTexture:SetSize(12, 14)
	expRepBar.reward = rewardTexture

	local barText = expRepBar:CreateFontString(nil, "OVERLAY")
	barText:SetFontObject(K.UIFont)
	barText:SetFont(string_format("%s", select(1, barText:GetFont())), 11, select(3, barText:GetFont()))
	barText:SetJustifyH("CENTER")
	barText:SetWordWrap(false)
	barText:SetPoint("CENTER", expRepBar, "CENTER", 0, 0)
	barText:SetAlpha(0.8)
	expRepBar.text = barText

	setupExpRepScripts(expRepBar)

	if not expRepBar.mover then
		expRepBar.mover = K.Mover(expRepBar, "ExpRepBar", "Exp/Rep Bar", { "TOP", _G.Minimap, "BOTTOM", 0, -6 })
	end

	updateBarSize(expRepBar)
end

Module:RegisterMisc("ExpRep", Module.CreateExpbar)
