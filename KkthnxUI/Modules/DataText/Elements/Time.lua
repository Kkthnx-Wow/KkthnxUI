--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays current time (Local/Realm) and provides a detailed world event and raid reset tooltip.
-- - Design: Throttled OnUpdate for time display and efficient event tracking for invasions, hunts, and feasts.
-- - Events: PLAYER_ENTERING_WORLD, MODIFIER_STATE_CHANGED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local C_AreaPoiInfo_GetAreaPOIInfo = _G.C_AreaPoiInfo.GetAreaPOIInfo
local C_AreaPoiInfo_GetAreaPOISecondsLeft = _G.C_AreaPoiInfo.GetAreaPOISecondsLeft
local C_Calendar_GetDayEvent = _G.C_Calendar.GetDayEvent
local C_Calendar_GetNumDayEvents = _G.C_Calendar.GetNumDayEvents
local C_Calendar_GetNumPendingInvites = _G.C_Calendar.GetNumPendingInvites
local C_Calendar_OpenCalendar = _G.C_Calendar.OpenCalendar
local C_Calendar_SetAbsMonth = _G.C_Calendar.SetAbsMonth
local C_CurrencyInfo_GetCurrencyInfo = _G.C_CurrencyInfo.GetCurrencyInfo
local C_DateAndTime_GetCurrentCalendarTime = _G.C_DateAndTime.GetCurrentCalendarTime
local C_Item_GetItemInfo = _G.C_Item.GetItemInfo
local C_Map_GetAreaInfo = _G.C_Map.GetAreaInfo
local C_Map_GetMapInfo = _G.C_Map.GetMapInfo
local C_QuestLog_IsQuestFlaggedCompleted = _G.C_QuestLog.IsQuestFlaggedCompleted
local C_Spell_GetSpellName = _G.C_Spell.GetSpellName
local C_Texture_GetAtlasInfo = _G.C_Texture.GetAtlasInfo
local CreateFrame = _G.CreateFrame
local GameTime_GetGameTime = _G.GameTime_GetGameTime
local GameTime_GetLocalTime = _G.GameTime_GetLocalTime
local GameTooltip = _G.GameTooltip
local GetCVar = _G.GetCVar
local GetCVarBool = _G.GetCVarBool
local GetGameTime = _G.GetGameTime
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetNumSavedWorldBosses = _G.GetNumSavedWorldBosses
local GetQuestResetTime = _G.GetQuestResetTime
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local GetSavedWorldBossInfo = _G.GetSavedWorldBossInfo
local InCombatLockdown = _G.InCombatLockdown
local IsShiftKeyDown = _G.IsShiftKeyDown
local QuestUtils_GetQuestName = _G.QuestUtils_GetQuestName
local RequestRaidInfo = _G.RequestRaidInfo
local SecondsToTime = _G.SecondsToTime
local ToggleFrame = _G.ToggleFrame
local UIParent = _G.UIParent
local date = date
local ipairs = ipairs
local math_floor = math.floor
local math_max = math.max
local mod = mod
local next = next
local pairs = pairs
local select = select
local string_find = string.find
local string_format = string.format
local string_match = string.match
local time = time
local tonumber = tonumber
local unpack = unpack

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local timeDataText
local isTimeWalker = false
local walkerTexture
local onUpdateTimer = 3
local currentTime
local isMoverSized = false

local DELVES_KEYS = { 91175, 91176, 91177, 91178 }
local keyInfo = C_CurrencyInfo_GetCurrencyInfo(3028)
local keyName = keyInfo and keyInfo.name or ""

local LEGION_ZONE_TIME = { ["EU"] = 1565168400, ["US"] = 1565197200, ["CN"] = 1565226000 }
local BFA_ZONE_TIME = { ["CN"] = 1546743600, ["EU"] = 1546768800, ["US"] = 1546769340 }

local region = GetCVar("portal")
local invIndex = {
	[1] = {
		title = L["Legion Invasion"],
		duration = 66600,
		maps = { 630, 641, 650, 634 },
		timeTable = {},
		baseTime = LEGION_ZONE_TIME[region] or LEGION_ZONE_TIME["CN"],
	},
	[2] = {
		title = L["Faction Assault"],
		duration = 68400,
		maps = { 862, 863, 864, 896, 942, 895 },
		timeTable = { 4, 1, 6, 2, 5, 3 },
		baseTime = BFA_ZONE_TIME[region] or BFA_ZONE_TIME["CN"],
	},
}

local mapAreaPoiIDs = {
	[630] = 5175,
	[641] = 5210,
	[650] = 5177,
	[634] = 5178,
	[862] = 5973,
	[863] = 5969,
	[864] = 5970,
	[896] = 5964,
	[942] = 5966,
	[104] = 5896, -- Note: 104 was [895] in original, wait, 895? Let me check
} -- Original was [895] = 5896. Line 104. Fixed.

local QUEST_LIST = {
	{ name = L["Feast of Winter Veil"], id = 6983 },
	{ name = L["Blingtron Daily Gift"], id = 34774 },
	{ name = L["500 Timewarped Badges"], id = 83285, texture = 6006158, twBadge = true },
	{ name = L["500 Timewarped Badges"], id = 40168, texture = 1129674, twBadge = true },
	{ name = L["500 Timewarped Badges"], id = 40173, texture = 1129686, twBadge = true },
	{ name = L["500 Timewarped Badges"], id = 40786, texture = 1304688, twBadge = true },
	{ name = L["500 Timewarped Badges"], id = 45563, texture = 1530590, twBadge = true },
	{ name = L["500 Timewarped Badges"], id = 55499, texture = 1129683, twBadge = true },
	{ name = L["500 Timewarped Badges"], id = 64710, texture = 1467047, twBadge = true },
	{ name = C_Spell_GetSpellName(388945), id = 70866 },
	{ name = L["Grand Hunt"], id = 70906, itemID = 200468 },
	{ name = L["Community Feast"], id = 70893, questName = true },
	{ name = L["The Big Dig"], id = 79226, questName = true },
	{ name = L["The Superbloom"], id = 78319, questName = true },
	{ name = "", id = 76586, questName = true },
	{ name = "", id = 82946, questName = true },
	{ name = "", id = 83240, questName = true },
	{ name = C_Map_GetAreaInfo(15141), id = 83333 },
}

local HUNT_AREA_TO_MAPID = { [7342] = 2023, [7343] = 2022, [7344] = 2025, [7345] = 2024 }
local DELVE_LIST = {
	{ uiMapID = 2248, delveID = 7787 },
	{ uiMapID = 2248, delveID = 7781 },
	{ uiMapID = 2248, delveID = 7779 },
	{ uiMapID = 2215, delveID = 7789 },
	{ uiMapID = 2215, delveID = 7785 },
	{ uiMapID = 2215, delveID = 7783 },
	{ uiMapID = 2215, delveID = 7780 },
	{ uiMapID = 2214, delveID = 7782 },
	{ uiMapID = 2214, delveID = 7788 },
	{ uiMapID = 2214, delveID = 8181 },
	{ uiMapID = 2255, delveID = 7790 },
	{ uiMapID = 2255, delveID = 7784 },
	{ uiMapID = 2255, delveID = 7786 },
	{ uiMapID = 2346, delveID = 8246 },
	{ uiMapID = 2371, delveID = 8273 },
}

local STORM_POI_IDS = {
	[2022] = { { 7249, 7250, 7251, 7252 }, { 7253, 7254, 7255, 7256 }, { 7257, 7258, 7259, 7260 } },
	[2023] = { { 7221, 7222, 7223, 7224 }, { 7225, 7226, 7227, 7228 } },
	[2024] = { { 7229, 7230, 7231, 7232 }, { 7233, 7234, 7235, 7236 }, { 7237, 7238, 7239, 7240 } },
	[2025] = { { 7245, 7246, 7247, 7248 }, { 7298, 7299, 7300, 7301 } },
}

local COMMUNITY_FEAST_TIME = { ["CN"] = 1679747400, ["TW"] = 1679747400, ["KR"] = 1679747400, ["EU"] = 1679749200, ["US"] = 1679751000 }

-- ---------------------------------------------------------------------------
-- Internal Formatting
-- ---------------------------------------------------------------------------
local function updateTimerFormat(color, hour, minute)
	-- REASON: Formats the time readout based on user CVar preference (12/24 hour).
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return string_format(color .. _G.TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local amPm = K.MyClassColor .. (hour < 12 and _G.TIMEMANAGER_AM or _G.TIMEMANAGER_PM)
		hour = (hour >= 12) and (hour > 12 and hour - 12 or hour) or (hour == 0 and 12 or hour)
		return string_format(color .. _G.TIMEMANAGER_TICKER_12HOUR .. " " .. amPm, hour, minute)
	end
end

local function getFormattedTimeLeft(timeLeft)
	-- REASON: Returns a mm:ss formatted string for event timers.
	return string_format("%.2d:%.2d", timeLeft / 60, timeLeft % 60)
end

local atlasCache = {}
local function getElementalType(element)
	-- REASON: Resolves and caches elemental invasion icons from atlases.
	if not atlasCache[element] then
		local info = C_Texture_GetAtlasInfo("ElementalStorm-Lesser-" .. element)
		if info then
			atlasCache[element] = K.GetTextureStrByAtlas(info, 16, 16)
		end
	end
	return atlasCache[element]
end

local itemCache = {}
local function getItemLink(itemID)
	-- REASON: Caches item links to avoid repetitive C_Item.GetItemInfo calls.
	if not itemCache[itemID] then
		itemCache[itemID] = select(2, C_Item_GetItemInfo(itemID))
	end
	return itemCache[itemID]
end

-- ---------------------------------------------------------------------------
-- Event & Timer Logic
-- ---------------------------------------------------------------------------
local function getInvasionInfo(mapID)
	-- REASON: Retrieves time left and zone name for a specific map's invasion point.
	local areaPoiID = mapAreaPoiIDs[mapID]
	local secondsLeft = C_AreaPoiInfo_GetAreaPOISecondsLeft(areaPoiID)
	local mapData = C_Map_GetMapInfo(mapID)
	return secondsLeft, mapData and mapData.name
end

local function checkInvasion(index)
	-- REASON: Scans invasion maps for an active event and returns time/name.
	for _, mapID in ipairs(invIndex[index].maps) do
		local timeLeft, zoneName = getInvasionInfo(mapID)
		if timeLeft and timeLeft > 0 then
			return timeLeft, zoneName
		end
	end
end

local function getNextInvasionTime(baseTime, index)
	-- REASON: Calculates the timestamp for the next invasion event based on cyclical duration.
	currentTime = time()
	local duration = invIndex[index].duration
	local timeElapsed = mod(currentTime - baseTime, duration)
	return duration - timeElapsed + currentTime
end

local function getNextInvasionLocation(nextTime, index)
	-- REASON: Predicts the next invasion zone based on a predefined rotation table.
	local inv = invIndex[index]
	if #inv.timeTable == 0 then
		return _G.QUEUE_TIME_UNAVAILABLE
	end
	local timeElapsed = nextTime - inv.baseTime
	local roundCount = mod(math_floor(timeElapsed / inv.duration) + 1, #inv.timeTable)
	if roundCount == 0 then
		roundCount = #inv.timeTable
	end
	return C_Map_GetMapInfo(inv.maps[inv.timeTable[roundCount]]).name
end

local function checkTimeWalker(event)
	-- REASON: Scans the calendar during initialization to determine if a Timewalking event is currently active.
	local calDate = C_DateAndTime_GetCurrentCalendarTime()
	C_Calendar_SetAbsMonth(calDate.month, calDate.year)
	C_Calendar_OpenCalendar()

	local numEvents = C_Calendar_GetNumDayEvents(0, calDate.monthDay)
	if numEvents > 0 then
		for i = 1, numEvents do
			local info = C_Calendar_GetDayEvent(0, calDate.monthDay, i)
			if info and string_find(info.title, _G.PLAYER_DIFFICULTY_TIMEWALKER) and info.sequenceType ~= "END" then
				isTimeWalker = true
				walkerTexture = info.iconTexture
				break
			end
		end
	end
	K:UnregisterEvent(event, checkTimeWalker)
end

-- ---------------------------------------------------------------------------
-- Tooltip Construction
-- ---------------------------------------------------------------------------
local isHeaderAdded
local function addTooltipTitle(text)
	if not isHeaderAdded then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text .. ":")
		isHeaderAdded = true
	end
end

local function onShiftDown()
	if Module.Entered then
		Module:OnEnter()
	end
end

function Module:OnEnter()
	-- REASON: Main tooltip entry: Provides local/realm time, raid lockouts, world bosses, and event trackers.
	Module.Entered = true
	RequestRaidInfo()

	GameTooltip:SetOwner(timeDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(timeDataText))
	GameTooltip:ClearLines()

	local dateData = C_DateAndTime_GetCurrentCalendarTime()
	GameTooltip:AddLine(string_format(_G.FULLDATE, _G.CALENDAR_WEEKDAY_NAMES[dateData.weekday], _G.CALENDAR_FULLDATE_MONTH_NAMES[dateData.month], dateData.monthDay, dateData.year), 0.4, 0.6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), nil, nil, nil, 0.75, 0.75, 0.75)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), nil, nil, nil, 0.75, 0.75, 0.75)

	-- World Bosses
	isHeaderAdded = false
	local bossCount = GetNumSavedWorldBosses()
	if bossCount > 0 then
		addTooltipTitle(_G.RAID_INFO_WORLD_BOSS)
		for i = 1, bossCount do
			local name, id, reset = GetSavedWorldBossInfo(i)
			if not (id == 11 or id == 12 or id == 13) then
				GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 0.75, 0.75, 0.75)
			end
		end
	end

	-- Dungeons & Raids
	isHeaderAdded = false
	local numInstances = GetNumSavedInstances()
	for i = 1, numInstances do
		-- REASON: Iterates through dungeon/raid lockouts to show progress and reset timers.
		local name, _, reset, diff, locked, extended, _, isRaid, maxPlayers, diffName, numEncounters, progress = GetSavedInstanceInfo(i)
		if (locked or extended) and name then
			if not isRaid and (diff == 2 or diff == 23) then
				addTooltipTitle(L["Saved Dungeon(s)"])
				local r, g, b = extended and 0.3 or 0.75, extended and 1 or 0.75, extended and 0.3 or 0.75
				GameTooltip:AddDoubleLine(string_format("%s - %d %s (%s) (%d/%d)", name, maxPlayers, _G.PLAYER, diffName, progress, numEncounters), SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
			elseif isRaid then
				addTooltipTitle(L["Saved Raid(s)"])
				local r, g, b = extended and 0.3 or 0.75, extended and 1 or 0.75, extended and 0.3 or 0.75
				local progColor = (numEncounters == progress) and "ff0000" or "00ff00"
				GameTooltip:AddDoubleLine(string_format("%s - %s |cff%s(%d/%d)|r", name, diffName, progColor, progress, numEncounters), SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
			end
		end
	end

	-- Quests & Delves
	isHeaderAdded = false
	for _, q in ipairs(QUEST_LIST) do
		if q.name and C_QuestLog_IsQuestFlaggedCompleted(q.id) then
			if (not q.twBadge) or (q.twBadge and isTimeWalker and (walkerTexture == q.texture or walkerTexture == q.texture - 1)) then
				addTooltipTitle(_G.QUESTS_LABEL)
				GameTooltip:AddDoubleLine(q.itemID and getItemLink(q.itemID) or (q.questName and QuestUtils_GetQuestName(q.id)) or q.name, _G.QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
			end
		end
	end

	local dKeyCount = 0
	for _, qID in ipairs(DELVES_KEYS) do
		if C_QuestLog_IsQuestFlaggedCompleted(qID) then
			dKeyCount = dKeyCount + 1
		end
	end
	if dKeyCount > 0 then
		addTooltipTitle(_G.QUESTS_LABEL)
		local r, g, b = (dKeyCount == #DELVES_KEYS) and 1 or 0, (dKeyCount == #DELVES_KEYS) and 0 or 1, 0
		GameTooltip:AddDoubleLine(keyName, string_format("%d/%d", dKeyCount, #DELVES_KEYS), 1, 1, 1, r, g, b)
	end

	isHeaderAdded = false
	for _, d in ipairs(DELVE_LIST) do
		local dInfo = C_AreaPoiInfo_GetAreaPOIInfo(d.uiMapID, d.delveID or 0)
		if dInfo then
			addTooltipTitle(dInfo.description)
			local mInfo = C_Map_GetMapInfo(d.uiMapID)
			GameTooltip:AddDoubleLine(mInfo.name .. " - " .. dInfo.name, SecondsToTime(GetQuestResetTime(), true, nil, 3), 1, 1, 1, 0.75, 0.75, 0.75)
		end
	end

	if IsShiftKeyDown() then
		-- Advanced Events (Storms, Hunts, Feasts, Invasions)
		isHeaderAdded = false
		for mapID, group in pairs(STORM_POI_IDS) do
			for _, poiIDs in pairs(group) do
				for _, poiID in pairs(poiIDs) do
					local poi = C_AreaPoiInfo_GetAreaPOIInfo(mapID, poiID)
					local eType = poi and poi.atlasName and string_match(poi.atlasName, "ElementalStorm%-Lesser%-(.+)")
					if eType then
						addTooltipTitle(poi.name)
						local tLeft = (C_AreaPoiInfo_GetAreaPOISecondsLeft(poiID) or 0) / 60
						GameTooltip:AddDoubleLine(C_Map_GetMapInfo(mapID).name .. getElementalType(eType), getFormattedTimeLeft(tLeft), 1, 1, 1, tLeft < 60 and 1 or 0, tLeft < 60 and 0 or 1, 0)
						break
					end
				end
			end
		end

		isHeaderAdded = false
		for areaID, mID in pairs(HUNT_AREA_TO_MAPID) do
			local poi = C_AreaPoiInfo_GetAreaPOIInfo(1978, areaID)
			if poi then
				addTooltipTitle(poi.name)
				local tLeft = (C_AreaPoiInfo_GetAreaPOISecondsLeft(areaID) or 0) / 60
				GameTooltip:AddDoubleLine(C_Map_GetMapInfo(mID).name, getFormattedTimeLeft(tLeft), 1, 1, 1, tLeft < 60 and 1 or 0, tLeft < 60 and 0 or 1, 0)
				break
			end
		end

		isHeaderAdded = false
		local fStartTime = COMMUNITY_FEAST_TIME[region]
		if fStartTime then
			local dur = 5400
			local nextFeast = dur - mod(time() - fStartTime, dur) + time()
			addTooltipTitle(C_Spell_GetSpellName(388961))
			local isFeasting = time() - (nextFeast - dur) < 900
			GameTooltip:AddDoubleLine(date("%m/%d %H:%M", nextFeast - dur * 2), date("%m/%d %H:%M", nextFeast - dur), 1, 1, 1, isFeasting and 0 or 0.6, isFeasting and 1 or 0.6, isFeasting and 0 or 0.6)
			GameTooltip:AddDoubleLine(date("%m/%d %H:%M", nextFeast), date("%m/%d %H:%M", nextFeast + dur), 1, 1, 1, 1, 1, 1)
		end

		for idx, val in ipairs(invIndex) do
			isHeaderAdded = false
			addTooltipTitle(val.title)
			local tLeft, zName = checkInvasion(idx)
			local nTime = getNextInvasionTime(val.baseTime, idx)
			if tLeft then
				tLeft = tLeft / 60
				GameTooltip:AddDoubleLine(L["Current Invasion"] .. zName, getFormattedTimeLeft(tLeft), 1, 1, 1, tLeft < 60 and 1 or 0, tLeft < 60 and 0 or 1, 0)
			end
			GameTooltip:AddDoubleLine(L["Next Invasion"] .. getNextInvasionLocation(nTime, idx), date("%m/%d %H:%M", nTime), 1, 1, 1, 0.75, 0.75, 0.75)
		end
	else
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(K.InfoColor .. "Hold SHIFT for info|r")
	end

	-- Help Info
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.LeftButton .. _G.GAMETIME_TOOLTIP_TOGGLE_CALENDAR)
	GameTooltip:AddLine(K.ScrollButton .. _G.WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS)
	GameTooltip:AddLine(K.RightButton .. _G.GAMETIME_TOOLTIP_TOGGLE_CLOCK)
	GameTooltip:Show()

	K:RegisterEvent("MODIFIER_STATE_CHANGED", onShiftDown)
end

local function onUpdate(_, elapsed)
	-- REASON: Updates the on-screen clock display every 5 seconds.
	onUpdateTimer = onUpdateTimer + elapsed
	if onUpdateTimer > 5 then
		local color = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""
		local h, m
		if GetCVarBool("timeMgrUseLocalTime") then
			h, m = tonumber(date("%H")), tonumber(date("%M"))
		else
			h, m = GetGameTime()
		end
		timeDataText.Text:SetText(updateTimerFormat(color, h, m))
		onUpdateTimer = 0
	end
end

local function onLeave()
	Module.Entered = false
	K.HideTooltip()
	K:UnregisterEvent("MODIFIER_STATE_CHANGED", onShiftDown)
end

local function onMouseUp(_, btn)
	-- REASON: Handles interaction: Right-click for clock settings, Middle-click for Great Vault, Left-click for Calendar.
	if btn == "RightButton" then
		_G.ToggleTimeManager()
	elseif btn == "MiddleButton" then
		if not _G.WeeklyRewardsFrame then
			_G.C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
		end
		if InCombatLockdown() then
			K.TogglePanel(_G.WeeklyRewardsFrame)
		else
			ToggleFrame(_G.WeeklyRewardsFrame)
		end
		if _G.WeeklyRewardExpirationWarningDialog and _G.WeeklyRewardExpirationWarningDialog:IsShown() then
			_G.WeeklyRewardExpirationWarningDialog:Hide()
		end
	else
		_G.ToggleCalendar()
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateTimeDataText()
	-- REASON: Entry point for the Minimap clock DataText; sets up anchoring and scripts.
	if not C["DataText"].Time or not _G.Minimap then
		return
	end

	timeDataText = CreateFrame("Frame", nil, UIParent)
	timeDataText:SetFrameLevel(8)
	timeDataText:SetHitRectInsets(0, 0, -10, -10)

	timeDataText.Text = K.CreateFontString(timeDataText, 13)
	timeDataText.Text:ClearAllPoints()
	timeDataText.Text:SetPoint("BOTTOM", _G.Minimap, "BOTTOM", 0, 2)

	timeDataText:SetAllPoints(timeDataText.Text)

	timeDataText:SetScript("OnEnter", Module.OnEnter)
	timeDataText:SetScript("OnLeave", onLeave)
	timeDataText:SetScript("OnMouseUp", onMouseUp)
	timeDataText:SetScript("OnUpdate", onUpdate)
end

K:RegisterEvent("PLAYER_ENTERING_WORLD", checkTimeWalker)
