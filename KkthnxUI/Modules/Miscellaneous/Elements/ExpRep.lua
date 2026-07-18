--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: One movable Exp/Rep bar under the minimap (XP, housing, rep, honor, Azerite).
-- - Priority: levelling XP → tracked house XP → watched rep → honor-as-XP → Azerite.
-- - Tooltip lists every applicable section; Alt+Right-Click reports the visible bar to party.
-- - Placement stays KKUI: under Minimap; trough + CreateBorder edge above the fill.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

local format = string.format
local sfind = string.find
local tonumber = tonumber
local type = type
local math_huge = math.huge
local math_min = math.min

local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitLevel = UnitLevel
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local GetXPExhaustion = GetXPExhaustion
local IsLevelAtEffectiveMaxLevel = IsLevelAtEffectiveMaxLevel
local IsXPUserDisabled = IsXPUserDisabled
local IsRestrictedAccount = IsRestrictedAccount
local IsTrialAccount = IsTrialAccount
local IsVeteranTrialAccount = IsVeteranTrialAccount
local IsWatchingHonorAsXP = IsWatchingHonorAsXP
local IsAltKeyDown = IsAltKeyDown
local IsInGroup = IsInGroup
local SendChatMessage = C_ChatInfo and C_ChatInfo.SendChatMessage or _G.SendChatMessage
local UnitHonor = UnitHonor
local UnitHonorMax = UnitHonorMax
local UnitHonorLevel = UnitHonorLevel
local UnitExists = UnitExists
local InCombatLockdown = InCombatLockdown
local C_Timer = C_Timer
local UIFrameFadeIn = UIFrameFadeIn
local UIFrameFadeOut = UIFrameFadeOut
local UIFrameFadeRemoveFrame = UIFrameFadeRemoveFrame
local hooksecurefunc = hooksecurefunc
local ipairs = ipairs
local pcall = pcall

local C_Reputation_GetWatchedFactionData = C_Reputation and C_Reputation.GetWatchedFactionData
local C_Reputation_IsFactionParagon = C_Reputation and C_Reputation.IsFactionParagon
local C_Reputation_GetFactionParagonInfo = C_Reputation and C_Reputation.GetFactionParagonInfo
local C_Reputation_IsMajorFaction = C_Reputation and C_Reputation.IsMajorFaction
local C_GossipInfo_GetFriendshipReputation = C_GossipInfo and C_GossipInfo.GetFriendshipReputation
local C_MajorFactions_GetMajorFactionData = C_MajorFactions and C_MajorFactions.GetMajorFactionData
local C_MajorFactions_HasMaximumRenown = C_MajorFactions and C_MajorFactions.HasMaximumRenown
local C_AzeriteItem_FindActiveAzeriteItem = C_AzeriteItem and C_AzeriteItem.FindActiveAzeriteItem
local C_AzeriteItem_GetAzeriteItemXPInfo = C_AzeriteItem and C_AzeriteItem.GetAzeriteItemXPInfo
local C_AzeriteItem_GetPowerLevel = C_AzeriteItem and C_AzeriteItem.GetPowerLevel

-- Housing: GetCurrentHouseLevelFavor is a request; HOUSE_LEVEL_FAVOR_UPDATED carries the payload.
local C_Housing = _G.C_Housing
local C_Housing_GetTrackedHouseGuid = C_Housing and C_Housing.GetTrackedHouseGuid
local C_Housing_GetCurrentHouseLevelFavor = C_Housing and C_Housing.GetCurrentHouseLevelFavor
local C_Housing_GetHouseLevelFavorForLevel = C_Housing and C_Housing.GetHouseLevelFavorForLevel
local C_Housing_GetMaxHouseLevel = C_Housing and C_Housing.GetMaxHouseLevel
local C_NeighborhoodInitiative = _G.C_NeighborhoodInitiative

local REPORT_COOLDOWN = 10
local FADE_DURATION = 0.25
local FADE_OUT_DELAY = 0.75
local DIVIDER_TEXTURE = "Interface\\Common\\UI-TooltipDivider-Transparent"

local REACTION_COLOR = {
	[9] = { r = 0.00, g = 0.60, b = 0.10 }, -- Paragon
	[10] = { r = 0.00, g = 0.74, b = 0.95 }, -- Renown
}

local bar
local displayText = ""
local reportLabel = ""
local lastReport = 0
local housingData
local eventsRegistered = false

local xpState, repState, honorState, azeriteState, housingState = {}, {}, {}, {}, {}

-- ---------------------------------------------------------------------------
-- Tooltip divider pool
-- ---------------------------------------------------------------------------
local dividerPool, dividerUsed = {}, 0

local function ReleaseDividers()
	for i = 1, dividerUsed do
		dividerPool[i]:Hide()
	end
	dividerUsed = 0
end

local function AcquireDivider()
	dividerUsed = dividerUsed + 1
	local tex = dividerPool[dividerUsed]
	if not tex then
		tex = _G.GameTooltip:CreateTexture(nil, "OVERLAY")
		tex:SetTexture(DIVIDER_TEXTURE)
		tex:SetHeight(8)
		dividerPool[dividerUsed] = tex
	end
	return tex
end

local function AddTooltipDivider()
	local tt = _G.GameTooltip
	tt:AddLine(" ")
	local line = _G["GameTooltipTextLeft" .. tt:NumLines()]
	if not line then
		return
	end
	local tex = AcquireDivider()
	tex:ClearAllPoints()
	tex:SetPoint("LEFT", tt, "LEFT", 10, 0)
	tex:SetPoint("RIGHT", tt, "RIGHT", -10, 0)
	tex:SetPoint("TOP", line, "TOP", 0, 0)
	tex:Show()
end

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------
local function IsMaxLevel()
	local level = UnitLevel("player")
	if IsLevelAtEffectiveMaxLevel and IsLevelAtEffectiveMaxLevel(level) then
		return true
	end
	if IsXPUserDisabled and IsXPUserDisabled() then
		return true
	end
	if (IsRestrictedAccount() or IsTrialAccount() or IsVeteranTrialAccount()) and level == 20 then
		return true
	end
	return false
end

local function SetBarValues(statusbar, minValue, maxValue, value)
	if maxValue <= minValue then
		maxValue = minValue + 1
	end
	statusbar:SetMinMaxValues(minValue, maxValue)
	statusbar:SetValue(value)
end

local function Progress(minValue, maxValue, value)
	if not maxValue or maxValue <= 0 then
		return 0, 1, 0, true, 0
	end

	local current = (value or 0) - (minValue or 0)
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
	return current, maximum, percent, (current >= maximum), (maximum - current)
end

local function AddRemainingLine(state)
	local cur, maxV, remaining = state.cur, state.max, state.remaining
	remaining = remaining or ((maxV or 0) - (cur or 0))
	if remaining < 0 then
		remaining = 0
	end
	local percent = maxV and maxV > 0 and (remaining / maxV * 100) or 0
	local bars = maxV and maxV > 0 and (remaining / maxV * 20) or 0
	_G.GameTooltip:AddDoubleLine(L["Remaining"], format("%s (%.1f%% - %.1f %s)", K.ShortValue(remaining), percent, bars, L["Bars"]), 1, 1, 1)
end

local function ReactionColor(reaction)
	local kkthnx = K.Colors and K.Colors.faction and K.Colors.faction[reaction]
	if kkthnx then
		return kkthnx.r, kkthnx.g, kkthnx.b
	end
	local color = REACTION_COLOR[reaction] or (_G.FACTION_BAR_COLORS and _G.FACTION_BAR_COLORS[reaction])
	if color then
		return color.r, color.g, color.b
	end
	return 1, 1, 1
end

local function RenownLabel(level)
	level = tonumber(level) or 0
	local label = _G.RENOWN_LEVEL_LABEL
	if type(label) == "string" then
		if sfind(label, "%%d") then
			return format(label, level)
		end
		return label .. " " .. level
	end
	return "Renown " .. level
end

local function AzeriteItem()
	if not C_AzeriteItem_FindActiveAzeriteItem then
		return
	end
	local loc = C_AzeriteItem_FindActiveAzeriteItem()
	if loc and loc.IsEquipmentSlot and loc:IsEquipmentSlot() then
		return loc
	end
end

local function HideVisibleBar()
	displayText = ""
	reportLabel = ""
	if not bar then
		return
	end
	bar.text:SetText("")
	bar.rest:Hide()
	bar.reward:Hide()
	bar:Hide()
end

local function BarTexture()
	return K.GetTexture(C["General"].Texture)
end

-- ---------------------------------------------------------------------------
-- Fade (optional)
-- ---------------------------------------------------------------------------
local fadeEventFrame
local hideTimer
local isMouseOver = false

local function FadeForced()
	if C["Misc"].ExpRepFadeCombat and InCombatLockdown() then
		return true
	end
	if C["Misc"].ExpRepFadeTarget and (UnitExists("target") or UnitExists("focus")) then
		return true
	end
	return false
end

local function FadeBarIn()
	if hideTimer then
		hideTimer:Cancel()
	end
	hideTimer = nil
	if bar then
		UIFrameFadeIn(bar, FADE_DURATION, bar:GetAlpha(), 1)
	end
end

local function FadeBarOut()
	hideTimer = nil
	if bar then
		UIFrameFadeOut(bar, FADE_DURATION, bar:GetAlpha(), (C["Misc"].ExpRepFadeOpacity or 0) / 100)
	end
end

local function ApplyFadeState()
	if not bar then
		return
	end
	if hideTimer then
		hideTimer:Cancel()
	end
	hideTimer = nil

	if not C["Misc"].ExpRepFade then
		if UIFrameFadeRemoveFrame then
			UIFrameFadeRemoveFrame(bar)
		end
		bar:SetAlpha(1)
		return
	end

	if isMouseOver or FadeForced() then
		FadeBarIn()
	else
		FadeBarOut()
	end
end

local function RefreshFade()
	if not fadeEventFrame then
		fadeEventFrame = CreateFrame("Frame")
		fadeEventFrame:SetScript("OnEvent", ApplyFadeState)
	end
	fadeEventFrame:UnregisterAllEvents()

	if C["Misc"].ExpRepFade then
		if C["Misc"].ExpRepFadeCombat then
			fadeEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
			fadeEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
		if C["Misc"].ExpRepFadeTarget then
			fadeEventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
			fadeEventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
		end
	end

	ApplyFadeState()
end

-- ---------------------------------------------------------------------------
-- Data builders
-- ---------------------------------------------------------------------------
local function BuildExperienceState()
	if IsMaxLevel() then
		xpState.available = nil
		return false
	end

	local cur = UnitXP("player") or 0
	local maxXP = UnitXPMax("player") or 1
	local rested = GetXPExhaustion() or 0
	if maxXP <= 0 then
		maxXP = 1
	end
	local percent = (cur / maxXP) * 100

	xpState.available = true
	xpState.cur, xpState.max, xpState.percent = cur, maxXP, percent
	xpState.rested, xpState.remaining = rested, maxXP - cur
	xpState.display = format("%s - %s (%.1f%%)", K.ShortValue(cur), K.ShortValue(maxXP), percent)
	return true
end

local function BuildReputationState(data)
	data = data or (C_Reputation_GetWatchedFactionData and C_Reputation_GetWatchedFactionData())
	if not data or not data.name then
		repState.available = nil
		return false
	end

	local name = data.name
	local reaction = data.reaction or 1
	local curThreshold = data.currentReactionThreshold or 0
	local nextThreshold = data.nextReactionThreshold or 1
	local standing = data.currentStanding or 0
	local factionID = data.factionID
	local label, rewardPending

	if factionID and C_GossipInfo_GetFriendshipReputation then
		local friend = C_GossipInfo_GetFriendshipReputation(factionID)
		if friend and friend.friendshipFactionID and friend.friendshipFactionID > 0 then
			label = friend.reaction
			curThreshold = friend.reactionThreshold or 0
			nextThreshold = friend.nextThreshold or math_huge
			standing = friend.standing or standing
		end
	end

	-- IsFactionParagon is true for any faction that *supports* paragon — only use it when
	-- not a major faction, or when that major faction has already maxed renown.
	local isMajor = factionID and C_Reputation_IsMajorFaction and C_Reputation_IsMajorFaction(factionID)
	local majorMaxed = isMajor and C_MajorFactions_HasMaximumRenown and C_MajorFactions_HasMaximumRenown(factionID)

	if not label and factionID and C_Reputation_IsFactionParagon and C_Reputation_GetFactionParagonInfo and (not isMajor or majorMaxed) and C_Reputation_IsFactionParagon(factionID) then
		local cur, thresh, _, pending = C_Reputation_GetFactionParagonInfo(factionID)
		if cur and thresh and thresh > 0 then
			label = L["Paragon"]
			curThreshold, nextThreshold = 0, thresh
			standing = cur % thresh
			reaction = 9
			rewardPending = pending
		end
	end

	if not label and isMajor and C_MajorFactions_GetMajorFactionData then
		local major = C_MajorFactions_GetMajorFactionData(factionID)
		if major then
			reaction = 10
			curThreshold = 0
			nextThreshold = major.renownLevelThreshold or 1
			if C_MajorFactions_HasMaximumRenown and C_MajorFactions_HasMaximumRenown(factionID) then
				standing = nextThreshold
			else
				standing = major.renownReputationEarned or 0
			end
			label = format("%s%s|r", K.RGBToHex(0, 0.74, 0.95), RenownLabel(major.renownLevel))
		end
	end

	if not label then
		label = _G["FACTION_STANDING_LABEL" .. reaction] or _G.UNKNOWN
	end

	repState.available = true
	repState.name, repState.label = name, label
	repState.reaction, repState.rewardPending = reaction, rewardPending
	repState.minValue = (nextThreshold == math_huge or curThreshold == nextThreshold) and 0 or curThreshold
	repState.maxValue = (nextThreshold == math_huge) and 1 or nextThreshold
	repState.value = standing

	if nextThreshold == math_huge then
		repState.cur, repState.max, repState.percent, repState.remaining, repState.capped = 0, 1, 100, 0, true
		repState.display = format("%s: [%s]", name, label)
	else
		local cur, maxP, pct, capped, remaining = Progress(curThreshold, nextThreshold, standing)
		repState.cur, repState.max, repState.percent, repState.remaining, repState.capped = cur, maxP, pct, remaining, capped
		repState.display = format("%s: %s - %s (%.1f%%) [%s]", name, K.ShortValue(cur), K.ShortValue(maxP), pct, label)
	end
	return true
end

local function BuildHonorState()
	if not (IsWatchingHonorAsXP and IsWatchingHonorAsXP()) then
		honorState.available = nil
		return false
	end

	local cur = UnitHonor("player") or 0
	local maxHonor = UnitHonorMax("player") or 1
	local level = UnitHonorLevel("player") or 0
	if maxHonor <= 0 then
		maxHonor = 1
	end
	local percent = (cur / maxHonor) * 100

	honorState.available = true
	honorState.cur, honorState.max, honorState.percent = cur, maxHonor, percent
	honorState.level, honorState.remaining = level, maxHonor - cur
	honorState.display = format("%s - %s (%.1f%%) [%s]", K.ShortValue(cur), K.ShortValue(maxHonor), percent, level)
	return true
end

local function BuildAzeriteState()
	if not (C_AzeriteItem_GetAzeriteItemXPInfo and C_AzeriteItem_GetPowerLevel) then
		azeriteState.available = nil
		return false
	end

	local loc = AzeriteItem()
	if not loc then
		azeriteState.available = nil
		return false
	end

	local cur, maxAz = C_AzeriteItem_GetAzeriteItemXPInfo(loc)
	local level = C_AzeriteItem_GetPowerLevel(loc)
	if not maxAz or maxAz <= 0 then
		azeriteState.available = nil
		return false
	end

	cur = cur or 0
	local percent = (cur / maxAz) * 100

	azeriteState.available = true
	azeriteState.cur, azeriteState.max, azeriteState.percent = cur, maxAz, percent
	azeriteState.level, azeriteState.remaining = level or 0, maxAz - cur
	azeriteState.display = format("%s - %s (%.1f%%) [%s]", K.ShortValue(cur), K.ShortValue(maxAz), percent, level or 0)
	return true
end

local function RequestHousingFavor()
	if not (C_Housing_GetTrackedHouseGuid and C_Housing_GetCurrentHouseLevelFavor) then
		return
	end
	local guid = C_Housing_GetTrackedHouseGuid()
	if guid then
		C_Housing_GetCurrentHouseLevelFavor(guid)
	end
end

local function RequestEndeavorInfo()
	if C_NeighborhoodInitiative and C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo then
		C_NeighborhoodInitiative.RequestNeighborhoodInitiativeInfo()
	end
end

local function GetEndeavorProgress()
	if not (C_NeighborhoodInitiative and C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo) then
		return nil
	end
	local info = C_NeighborhoodInitiative.GetNeighborhoodInitiativeInfo()
	if not info or not info.isLoaded or info.initiativeID == 0 then
		return nil
	end
	local milestones = info.milestones
	local maxProgress = milestones and #milestones > 0 and milestones[#milestones].requiredContributionAmount or info.progressRequired
	if not maxProgress or maxProgress <= 0 then
		return nil
	end
	local pct = (info.currentProgress or 0) / maxProgress * 100
	return pct > 100 and 100 or pct
end

local function BuildHousingState()
	if not (C_Housing_GetTrackedHouseGuid and C_Housing_GetHouseLevelFavorForLevel) then
		housingState.available = nil
		return false
	end

	local guid = C_Housing_GetTrackedHouseGuid()
	if not guid or not housingData or housingData.houseGUID ~= guid then
		housingState.available = nil
		return false
	end

	local level = housingData.houseLevel or 1
	local favor = housingData.houseFavor or 0
	local minBar = C_Housing_GetHouseLevelFavorForLevel(level) or 0
	local nextBar = C_Housing_GetHouseLevelFavorForLevel(level + 1) or minBar
	local maxLevel = C_Housing_GetMaxHouseLevel and C_Housing_GetMaxHouseLevel()
	local atMax = (maxLevel and level >= maxLevel) or nextBar <= minBar

	housingState.available = true
	housingState.level = level
	housingState.capped = atMax

	if atMax then
		housingState.cur, housingState.max, housingState.percent, housingState.remaining = 1, 1, 100, 0
		housingState.display = format("%s [%s %d]", _G.MAXIMUM or "Maximum", _G.LEVEL or "Level", level)
	else
		local cur, maxP, pct, capped, remaining = Progress(0, nextBar, favor)
		housingState.cur, housingState.max, housingState.percent = cur, maxP, pct
		housingState.remaining, housingState.capped = remaining, capped
		housingState.display = format("%s - %s (%.1f%%)", K.ShortValue(cur), K.ShortValue(maxP), pct)
	end
	return true
end

-- ---------------------------------------------------------------------------
-- Visible bar modes
-- ---------------------------------------------------------------------------
local function ShowExperience()
	reportLabel = _G.COMBAT_XP_GAIN or "Experience"
	displayText = xpState.display or ""

	bar.fill:SetStatusBarColor(0, 0.4, 1, 0.8)
	SetBarValues(bar.fill, 0, xpState.max, xpState.cur)

	local showRested = C["Misc"].ExpRepShowRested ~= false and xpState.rested and xpState.rested > 0
	if showRested then
		bar.rest:SetStatusBarColor(1, 0, 1, 0.4)
		SetBarValues(bar.rest, 0, xpState.max, math_min(xpState.cur + xpState.rested, xpState.max))
	end

	bar.rest:SetShown(showRested)
	bar.reward:Hide()
	bar.text:SetText(displayText)
	bar:Show()
end

local function ShowReputation()
	reportLabel = _G.REPUTATION or "Reputation"
	displayText = repState.display

	local r, g, b = ReactionColor(repState.reaction)
	bar.fill:SetStatusBarColor(r, g, b, 1)
	SetBarValues(bar.fill, repState.minValue, repState.maxValue, repState.value)

	bar.rest:Hide()
	bar.reward:SetShown(not not repState.rewardPending)
	bar.text:SetText(displayText)
	bar:Show()
end

local function ShowHonor()
	reportLabel = _G.HONOR or "Honor"
	displayText = honorState.display or ""

	bar.fill:SetStatusBarColor(0.94, 0.45, 0.25, 1)
	SetBarValues(bar.fill, 0, honorState.max, honorState.cur)

	bar.rest:Hide()
	bar.reward:Hide()
	bar.text:SetText(displayText)
	bar:Show()
end

local function ShowAzerite()
	reportLabel = _G.AZERITE_POWER or "Azerite"
	displayText = azeriteState.display or ""

	bar.fill:SetStatusBarColor(0.901, 0.8, 0.601, 1)
	SetBarValues(bar.fill, 0, azeriteState.max, azeriteState.cur)

	bar.rest:Hide()
	bar.reward:Hide()
	bar.text:SetText(displayText)
	bar:Show()
end

local function ShowHousing()
	reportLabel = L["Housing Experience"]
	displayText = housingState.display

	bar.fill:SetStatusBarColor(1.0, 0.82, 0.0, 1)
	SetBarValues(bar.fill, 0, housingState.max, housingState.cur)

	bar.rest:Hide()
	bar.reward:Hide()
	bar.text:SetText(displayText)
	bar:Show()
end

-- ---------------------------------------------------------------------------
-- Tooltip / scripts
-- ---------------------------------------------------------------------------
local function AddExperienceTooltip()
	if not xpState.available then
		return false
	end
	_G.GameTooltip:AddDoubleLine("|cff0070ff" .. (_G.COMBAT_XP_GAIN or "Experience") .. "|r", format("%s %d", _G.LEVEL or "Level", UnitLevel("player")))
	_G.GameTooltip:AddLine(" ")
	_G.GameTooltip:AddDoubleLine(L["XP"], format("%s - %s (%.1f%%)", K.ShortValue(xpState.cur), K.ShortValue(xpState.max), xpState.percent or 0), 1, 1, 1)
	AddRemainingLine(xpState)
	if xpState.rested and xpState.rested > 0 then
		local pct = xpState.max and xpState.max > 0 and (xpState.rested / xpState.max * 100) or 0
		_G.GameTooltip:AddDoubleLine(L["Rested"], format("+%s (%.1f%%)", K.ShortValue(xpState.rested), pct), 1, 1, 1)
	end
	return true
end

local function AddReputationTooltip(addSpacing)
	if not repState.available then
		return false
	end
	if addSpacing then
		AddTooltipDivider()
	end
	_G.GameTooltip:AddDoubleLine("|cff00bdfc" .. (repState.name or "") .. "|r", repState.label or "", 1, 1, 1)
	_G.GameTooltip:AddLine(" ")
	if repState.capped then
		_G.GameTooltip:AddLine(repState.display, 1, 1, 1, true)
	else
		_G.GameTooltip:AddDoubleLine(_G.REPUTATION or "Reputation", format("%s - %s (%.1f%%)", K.ShortValue(repState.cur), K.ShortValue(repState.max), repState.percent or 0), 1, 1, 1)
		AddRemainingLine(repState)
	end
	if repState.rewardPending then
		_G.GameTooltip:AddLine(_G.REWARD_AVAILABLE or "Reward available", 0, 1, 0)
	end
	return true
end

local function AddHonorTooltip(addSpacing)
	if not honorState.available then
		return false
	end
	if addSpacing then
		AddTooltipDivider()
	end
	_G.GameTooltip:AddDoubleLine("|cff00bdfc" .. (_G.HONOR or "Honor") .. "|r", (_G.LEVEL or "Level") .. " " .. (honorState.level or 0))
	_G.GameTooltip:AddLine(" ")
	_G.GameTooltip:AddDoubleLine(L["Honor XP"], format("%s - %s (%.1f%%)", K.ShortValue(honorState.cur), K.ShortValue(honorState.max), honorState.percent or 0), 1, 1, 1)
	AddRemainingLine(honorState)
	return true
end

local function AddAzeriteTooltip(addSpacing)
	if not azeriteState.available then
		return false
	end
	if addSpacing then
		AddTooltipDivider()
	end
	_G.GameTooltip:AddDoubleLine("|cff00bdfc" .. (_G.AZERITE_POWER or "Azerite") .. "|r", (_G.LEVEL or "Level") .. " " .. (azeriteState.level or 0))
	_G.GameTooltip:AddLine(" ")
	_G.GameTooltip:AddDoubleLine(L["XP"], format("%s - %s (%.1f%%)", K.ShortValue(azeriteState.cur), K.ShortValue(azeriteState.max), azeriteState.percent or 0), 1, 1, 1)
	AddRemainingLine(azeriteState)
	return true
end

local function AddHousingTooltip(addSpacing)
	if not housingState.available then
		return false
	end
	if addSpacing then
		AddTooltipDivider()
	end
	_G.GameTooltip:AddDoubleLine("|cff00bdfc" .. L["Housing Experience"] .. "|r", format("%s %d", _G.LEVEL or "Level", housingState.level or 1))
	_G.GameTooltip:AddLine(" ")
	if housingState.capped then
		_G.GameTooltip:AddLine(housingState.display, 1, 1, 1, true)
	else
		_G.GameTooltip:AddDoubleLine(L["XP"], format("%s - %s (%.1f%%)", K.ShortValue(housingState.cur), K.ShortValue(housingState.max), housingState.percent or 0), 1, 1, 1)
		AddRemainingLine(housingState)
	end
	local endeavorPct = GetEndeavorProgress()
	if endeavorPct then
		_G.GameTooltip:AddDoubleLine(L["Endeavor Progress"], format("%.2f%%", endeavorPct), 1, 1, 1)
	end
	return true
end

local function OnEnter()
	isMouseOver = true
	if C["Misc"].ExpRepFade then
		FadeBarIn()
	end
	if _G.GameTooltip:IsForbidden() then
		return
	end
	_G.GameTooltip:ClearLines()
	ReleaseDividers()
	_G.GameTooltip:SetOwner(bar, "ANCHOR_CURSOR")

	local any = AddExperienceTooltip()
	any = AddHousingTooltip(any) or any
	any = AddReputationTooltip(any) or any
	any = AddHonorTooltip(any) or any
	any = AddAzeriteTooltip(any) or any

	if any then
		_G.GameTooltip:AddLine(" ")
	end
	_G.GameTooltip:AddDoubleLine(K.InfoColor .. _G.ALT_KEY_TEXT .. " " .. _G.KEY_PLUS .. K.RightButton, L["Send to party chat"])
	_G.GameTooltip:Show()
end

local function OnLeave()
	isMouseOver = false
	if C["Misc"].ExpRepFade and not FadeForced() then
		if hideTimer then
			hideTimer:Cancel()
		end
		hideTimer = C_Timer.NewTimer(FADE_OUT_DELAY, FadeBarOut)
	end
	ReleaseDividers()
	K.HideTooltip()
end

local function OnMouseUp(_, button)
	if not (IsAltKeyDown() and button == "RightButton") then
		return
	end
	if displayText == "" then
		return
	end
	if (GetTime() - lastReport) < REPORT_COOLDOWN then
		K.Print(_G.SPELL_FAILED_CUSTOM_ERROR_808 or "On cooldown.")
		return
	end
	if not IsInGroup() then
		K.Print(_G.ERR_QUEST_PUSH_NOT_IN_PARTY_S)
		return
	end

	lastReport = GetTime()
	SendChatMessage(reportLabel .. ": " .. displayText, "PARTY")
end

-- ---------------------------------------------------------------------------
-- Update / size
-- ---------------------------------------------------------------------------
local function UpdateBarSize()
	if not bar then
		return
	end
	local barWidth = (_G.Minimap and _G.Minimap:GetWidth()) or 190
	local barHeight = 16
	bar:SetSize(barWidth, barHeight)
	if bar.spark then
		bar.spark:SetHeight(barHeight - 2)
	end
	if bar.text then
		bar.text:SetWidth(barWidth - 6)
	end
	if bar.mover then
		bar.mover:SetSize(barWidth, barHeight)
	end
end

local function UpdateBar(_, _, unit)
	if not C["Misc"].ExpRep or not bar then
		return
	end
	if unit and unit ~= "player" then
		return
	end

	BuildExperienceState()
	BuildHousingState()
	BuildReputationState()
	BuildHonorState()
	BuildAzeriteState()

	if xpState.available then
		ShowExperience()
	elseif housingState.available then
		ShowHousing()
	elseif repState.available then
		ShowReputation()
	elseif honorState.available then
		ShowHonor()
	elseif azeriteState.available then
		ShowAzerite()
	else
		HideVisibleBar()
	end

	if C["Misc"].ExpRepFade and bar:IsShown() then
		ApplyFadeState()
	end
end

local QueueBarUpdate = K.Debounce(0, UpdateBar)

local function OnBarEvent(_, event, arg1)
	if event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
		UpdateBarSize()
	elseif event == "HOUSE_LEVEL_FAVOR_UPDATED" then
		if arg1 and C_Housing_GetTrackedHouseGuid and arg1.houseGUID == C_Housing_GetTrackedHouseGuid() then
			housingData = arg1
		end
	elseif event == "TRACKED_HOUSE_CHANGED" then
		housingData = nil
		RequestHousingFavor()
	elseif event == "PLAYER_ENTERING_WORLD" then
		RequestHousingFavor()
		RequestEndeavorInfo()
	end
	QueueBarUpdate()
end

local EVENTS = {
	"PLAYER_ENTERING_WORLD",
	"PLAYER_LEVEL_UP",
	"UPDATE_EXHAUSTION",
	"PLAYER_XP_UPDATE",
	"ENABLE_XP_GAIN",
	"DISABLE_XP_GAIN",
	"UPDATE_FACTION",
	"QUEST_FINISHED",
	"MAJOR_FACTION_RENOWN_LEVEL_CHANGED",
	"MAJOR_FACTION_UNLOCKED",
	"HONOR_XP_UPDATE",
	"PLAYER_FLAGS_CHANGED",
	"PLAYER_EQUIPMENT_CHANGED",
	"AZERITE_ITEM_EXPERIENCE_CHANGED",
	"HOUSE_LEVEL_FAVOR_UPDATED",
	"TRACKED_HOUSE_CHANGED",
	"UI_SCALE_CHANGED",
	"DISPLAY_SIZE_CHANGED",
}

local function RegisterBarEvents()
	if not bar or eventsRegistered then
		return
	end
	for _, event in ipairs(EVENTS) do
		pcall(bar.RegisterEvent, bar, event)
	end
	eventsRegistered = true
end

local function UnregisterBarEvents()
	if not bar or not eventsRegistered then
		return
	end
	bar:UnregisterAllEvents()
	eventsRegistered = false
end

local function HideBlizzardStatusBars()
	local mgr = _G.StatusTrackingBarManager
	if not mgr or mgr.kkuiExpRepHidden then
		return
	end
	mgr.kkuiExpRepHidden = true
	mgr:UnregisterAllEvents()
	mgr:Hide()
	hooksecurefunc(mgr, "Show", function(self)
		if self.kkuiExpRepHidden and C["Misc"].ExpRep then
			self:Hide()
		end
	end)
end

local function ApplyAppearance()
	if not bar then
		return
	end
	local tex = BarTexture()
	bar.fill:SetStatusBarTexture(tex)
	bar.rest:SetStatusBarTexture(tex)
	bar.text:SetShown(true)
	UpdateBarSize()
	RefreshFade()
end

-- ---------------------------------------------------------------------------
-- Construction (KKUI placement under minimap)
-- ---------------------------------------------------------------------------
local function BuildBar()
	if bar then
		return bar
	end

	local f = CreateFrame("Frame", "KKUI_ExpRepBar", _G.MinimapCluster)
	f:SetPoint("TOP", _G.Minimap, "BOTTOM", 0, -6)
	f:SetHeight(16)
	f:SetHitRectInsets(0, 0, 0, -10)
	f:SetFrameStrata("LOW")
	f:EnableMouse(true)

	local base = f:GetFrameLevel()

	-- Trough only on the container. Border chrome goes on a higher frame so the
	-- StatusBar fill never covers the edge (CreateBorder on the parent sits under children).
	local trough = f:CreateTexture(nil, "BACKGROUND")
	trough:SetAllPoints()
	trough:SetTexture(C["Media"].Textures.White8x8Texture)
	local bg = C["Media"].Backdrops.ColorBackdrop
	trough:SetVertexColor(bg[1], bg[2], bg[3], bg[4] or 1)
	f.trough = trough

	local rest = CreateFrame("StatusBar", nil, f)
	rest:SetAllPoints()
	rest:SetFrameLevel(base + 1)
	rest:SetStatusBarTexture(BarTexture())
	rest:SetStatusBarColor(1, 0, 1, 0.4)
	rest:Hide()
	f.rest = rest

	local fill = CreateFrame("StatusBar", nil, f)
	fill:SetAllPoints()
	fill:SetFrameLevel(base + 2)
	fill:SetStatusBarTexture(BarTexture())
	f.fill = fill

	local spark = fill:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Textures.Spark16Texture)
	spark:SetBlendMode("ADD")
	spark:SetAlpha(0.6)
	spark:SetHeight(14)
	spark:SetPoint("CENTER", fill:GetStatusBarTexture(), "RIGHT", 0, 0)
	f.spark = spark

	local reward = fill:CreateTexture(nil, "OVERLAY")
	reward:SetAtlas("ParagonReputation_Bag")
	reward:SetSize(12, 14)
	reward:SetPoint("CENTER", f, "LEFT", 0, 0)
	reward:Hide()
	f.reward = reward

	-- Edge only: 7th CreateBorder arg "" skips KKUI_Background so we don't black out the fill.
	local border = CreateFrame("Frame", nil, f)
	border:SetAllPoints(f)
	border:SetFrameLevel(base + 4)
	border:CreateBorder(nil, nil, nil, nil, nil, nil, "")
	f.border = border

	local labelAnchor = CreateFrame("Frame", nil, f)
	labelAnchor:SetAllPoints(f)
	labelAnchor:SetFrameLevel(base + 5)
	labelAnchor:EnableMouse(false)
	f.labelAnchor = labelAnchor

	local text = K.CreateFontString(labelAnchor, 11, "", "")
	text:ClearAllPoints()
	text:SetPoint("CENTER")
	text:SetJustifyH("CENTER")
	text:SetWordWrap(false)
	text:SetTextColor(1, 1, 1, 0.9)
	f.text = text

	f:SetScript("OnEvent", OnBarEvent)
	f:SetScript("OnEnter", OnEnter)
	f:SetScript("OnLeave", OnLeave)
	f:SetScript("OnMouseUp", OnMouseUp)

	bar = f
	return f
end

function Module:CreateExpbar()
	if not C["Misc"].ExpRep then
		return
	end

	if _G.KKUI_ExpRepBar then
		bar = _G.KKUI_ExpRepBar
		bar:Show()
		RegisterBarEvents()
		ApplyAppearance()
		UpdateBar(bar)
		return
	end

	BuildBar()
	HideBlizzardStatusBars()

	if not bar.mover then
		bar.mover = K.Mover(bar, "ExpRepBar", "Exp/Rep Bar", { "TOP", _G.Minimap, "BOTTOM", 0, -6 })
	end

	ApplyAppearance()
	RequestHousingFavor()
	RequestEndeavorInfo()
	UpdateBar(bar)
	RegisterBarEvents()
end

function Module:UpdateExpRepBar()
	if C["Misc"].ExpRep then
		if bar or _G.KKUI_ExpRepBar then
			bar = bar or _G.KKUI_ExpRepBar
			bar:Show()
			RegisterBarEvents()
			ApplyAppearance()
			UpdateBar(bar)
		else
			Module:CreateExpbar()
		end
	elseif bar or _G.KKUI_ExpRepBar then
		bar = bar or _G.KKUI_ExpRepBar
		UnregisterBarEvents()
		if fadeEventFrame then
			fadeEventFrame:UnregisterAllEvents()
		end
		bar:Hide()
	end
end

Module:RegisterMisc("ExpRep", Module.CreateExpbar)
