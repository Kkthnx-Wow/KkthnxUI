local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

local date = date
local ipairs = ipairs
local mod = mod
local pairs = pairs
local string_find = string.find
local string_format = string.format
local time = time
local tonumber = tonumber

local CALENDAR_FULLDATE_MONTH_NAMES = CALENDAR_FULLDATE_MONTH_NAMES
local CALENDAR_WEEKDAY_NAMES = CALENDAR_WEEKDAY_NAMES
local C_AreaPoiInfo_GetAreaPOISecondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft
local C_Calendar_GetDayEvent = C_Calendar.GetDayEvent
local C_Calendar_GetNumDayEvents = C_Calendar.GetNumDayEvents
local C_Calendar_GetNumPendingInvites = C_Calendar.GetNumPendingInvites
local C_Calendar_OpenCalendar = C_Calendar.OpenCalendar
local C_Calendar_SetAbsMonth = C_Calendar.SetAbsMonth
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local C_Map_GetMapInfo = C_Map.GetMapInfo
local C_QuestLog_IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local C_TaskQuest_GetQuestInfoByQuestID = C_TaskQuest.GetQuestInfoByQuestID
local C_TaskQuest_GetThreatQuests = C_TaskQuest.GetThreatQuests
local FULLDATE = FULLDATE
local GameTime_GetGameTime = GameTime_GetGameTime
local C_AreaPoiInfo_GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
local GameTime_GetLocalTime = GameTime_GetLocalTime
local GameTooltip = GameTooltip
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local GetGameTime = GetGameTime
local GetNumSavedInstances = GetNumSavedInstances
local GetNumSavedWorldBosses = GetNumSavedWorldBosses
local GetSavedInstanceInfo = GetSavedInstanceInfo
local GetSavedWorldBossInfo = GetSavedWorldBossInfo
local PLAYER_DIFFICULTY_TIMEWALKER = PLAYER_DIFFICULTY_TIMEWALKER
local QUESTS_LABEL = QUESTS_LABEL
local QUEST_COMPLETE = QUEST_COMPLETE
local QUEUE_TIME_UNAVAILABLE = QUEUE_TIME_UNAVAILABLE
local RequestRaidInfo = RequestRaidInfo
local SecondsToTime = SecondsToTime
local TIMEMANAGER_TICKER_12HOUR = TIMEMANAGER_TICKER_12HOUR
local TIMEMANAGER_TICKER_24HOUR = TIMEMANAGER_TICKER_24HOUR

local TimeDataText
local TimeDataTextEntered

-- Data
local region = GetCVar("portal")
local legionZoneTime = {
	["EU"] = 1565168400, -- CN-16
	["US"] = 1565197200, -- CN-8
	["CN"] = 1565226000, -- CN time 8/8/2019 09:00 [1]
}
local bfaZoneTime = {
	["CN"] = 1546743600, -- CN time 1/6/2019 11:00 [1]
	["EU"] = 1546768800, -- CN+7
	["US"] = 1546769340, -- CN+16
}

local invIndex = {
	[1] = { title = L["Legion Invasion"], duration = 66600, maps = { 630, 641, 650, 634 }, timeTable = {}, baseTime = legionZoneTime[region] or legionZoneTime["CN"] },
	[2] = {
		title = L["BFA Invasion"],
		duration = 68400,
		maps = { 862, 863, 864, 896, 942, 895 },
		timeTable = { 4, 1, 6, 2, 5, 3 },
		baseTime = bfaZoneTime[region] or bfaZoneTime["CN"],
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
	[895] = 5896,
}

local questlist = {
	{ name = "Feast of Winter Veil", id = 6983 },
	{ name = "Blingtron Daily Gift", id = 34774 },
	{ name = "500 Timewarped Badges", id = 40168, texture = 1129674 }, -- TBC
	{ name = "500 Timewarped Badges", id = 40173, texture = 1129686 }, -- WotLK
	{ name = "500 Timewarped Badges", id = 40786, texture = 1304688 }, -- Cata
	{ name = "500 Timewarped Badges", id = 45563, texture = 1530590 }, -- MoP
	{ name = "500 Timewarped Badges", id = 55499, texture = 1129683 }, -- WoD
	{ name = "500 Timewarped Badges", id = 64710, texture = 1467047 }, -- Legion
}

local lesserVisions = { 58151, 58155, 58156, 58167, 58168 }
local horrificVisions = {
	[1] = { id = 57848, desc = "470 (5+5)" },
	[2] = { id = 57844, desc = "465 (5+4)" },
	[3] = { id = 57847, desc = "460 (5+3)" },
	[4] = { id = 57843, desc = "455 (5+2)" },
	[5] = { id = 57846, desc = "450 (5+1)" },
	[6] = { id = 57842, desc = "445 (5+0)" },
	[7] = { id = 57845, desc = "430 (3+0)" },
	[8] = { id = 57841, desc = "420 (1+0)" },
}

local function updateTimerFormat(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return string_format(color .. TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = K.MyClassColor .. (hour < 12 and TIMEMANAGER_AM or TIMEMANAGER_PM)

		if hour >= 12 then
			if hour > 12 then
				hour = hour - 12
			end
		else
			if hour == 0 then
				hour = 12
			end
		end

		return string_format(color .. TIMEMANAGER_TICKER_12HOUR .. timerUnit, hour, minute)
	end
end

-- initialize self.timer outside of the function
local onUpdateTimer = onUpdateTimer or 3

function Module:TimeOnUpdate(elapsed)
	onUpdateTimer = onUpdateTimer + elapsed
	if onUpdateTimer > 5 then
		local color = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""
		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		TimeDataText.Font:SetText(updateTimerFormat(color, hour, minute))

		onUpdateTimer = 0
	end
end

local isTimeWalker, walkerTexture
local function checkTimeWalker(event)
	local date = C_DateAndTime_GetCurrentCalendarTime()
	C_Calendar_SetAbsMonth(date.month, date.year)
	C_Calendar_OpenCalendar()

	local today = date.monthDay
	local numEvents = C_Calendar_GetNumDayEvents(0, today)
	if numEvents <= 0 then
		return
	end

	for i = 1, numEvents do
		local info = C_Calendar_GetDayEvent(0, today, i)
		if info and string_find(info.title, PLAYER_DIFFICULTY_TIMEWALKER) and info.sequenceType ~= "END" then
			isTimeWalker = true
			walkerTexture = info.iconTexture
			break
		end
	end
	K:UnregisterEvent(event, checkTimeWalker)
end
K:RegisterEvent("PLAYER_ENTERING_WORLD", checkTimeWalker)

local function checkTexture(texture)
	if not walkerTexture then
		return
	end
	if walkerTexture == texture or walkerTexture == texture - 1 then
		return true
	end
end

local function getInvasionInfo(mapID)
	local areaPoiID = mapAreaPoiIDs[mapID]
	local seconds = C_AreaPoiInfo_GetAreaPOISecondsLeft(areaPoiID)
	local mapInfo = C_Map_GetMapInfo(mapID)
	return seconds, mapInfo.name
end

local function CheckInvasion(index)
	for _, mapID in pairs(invIndex[index].maps) do
		local timeLeft, name = getInvasionInfo(mapID)
		if timeLeft and timeLeft > 0 then
			return timeLeft, name
		end
	end
end

local function GetNextTime(baseTime, index)
	local currentTime = time()
	local duration = invIndex[index].duration
	local elapsed = mod(currentTime - baseTime, duration)
	return duration - elapsed + currentTime
end

local function GetNextLocation(nextTime, index)
	local inv = invIndex[index]
	local count = #inv.timeTable
	if count == 0 then
		return QUEUE_TIME_UNAVAILABLE
	end

	local elapsed = nextTime - inv.baseTime
	local round = mod(floor(elapsed / inv.duration) + 1, count)
	if round == 0 then
		round = count
	end
	return C_Map_GetMapInfo(inv.maps[inv.timeTable[round]]).name
end

local cache = {}
local nzothAssaults
local function GetNzothThreatName(questID)
	local name = cache[questID]
	if not name then
		name = C_TaskQuest_GetQuestInfoByQuestID(questID)
		cache[questID] = name
	end
	return name
end

-- Grant hunts
local huntAreaToMapID = { -- 狩猎区域ID转换为地图ID
	[7342] = 2023, -- 欧恩哈拉平原
	[7343] = 2022, -- 觉醒海岸
	[7344] = 2025, -- 索德拉苏斯
	[7345] = 2024, -- 碧蓝林海
}

-- Elemental invasion
local stormPoiIDs = {
	[2022] = {
		{ 7249, 7250, 7251, 7252 },
		{ 7253, 7254, 7255, 7256 },
		{ 7257, 7258, 7259, 7260 },
	},
	[2023] = {
		{ 7221, 7222, 7223, 7224 },
		{ 7225, 7226, 7227, 7228 },
	},
	[2024] = {
		{ 7229, 7230, 7231, 7232 },
		{ 7233, 7234, 7235, 7236 },
		{ 7237, 7238, 7239, 7240 },
	},
	[2025] = {
		{ 7245, 7246, 7247, 7248 },
		{ 7298, 7299, 7300, 7301 },
	},
	--[2085] = {
	--	{7241, 7242, 7243, 7244},
	--},
}

local communityFeastTime = {
	["TW"] = 1679747400, -- 20:30
	["KR"] = 1679747400, -- 20:30
	["EU"] = 1679749200, -- 21:00
	["US"] = 1679751000, -- 21:30
	["CN"] = 1679751000, -- 21:30
}

local atlasCache = {}
local function GetElementalType(element) -- 获取入侵类型图标
	local str = atlasCache[element]
	if not str then
		local info = C_Texture.GetAtlasInfo("ElementalStorm-Lesser-" .. element)
		if info then
			str = K.GetTextureStrByAtlas(info, 16, 16)
			atlasCache[element] = str
		end
	end
	return str
end

local function GetFormattedTimeLeft(timeLeft)
	return format("%.2d:%.2d", timeLeft / 60, timeLeft % 60)
end

local itemCache = {}
local function GetItemLink(itemID)
	local link = itemCache[itemID]
	if not link then
		link = select(2, GetItemInfo(itemID))
		itemCache[itemID] = link
	end
	return link
end

local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text .. ":")
		title = true
	end
end

function Module:TimeOnShiftDown()
	if TimeDataTextEntered then
		Module:TimeOnEnter()
	end
end

function Module:TimeOnEnter()
	TimeDataTextEntered = true

	RequestRaidInfo()

	local r, g, b
	GameTooltip:SetOwner(TimeDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(TimeDataText))
	GameTooltip:ClearLines()

	local today = C_DateAndTime_GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	GameTooltip:AddLine(string_format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0.4, 0.6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), nil, nil, nil, 192 / 255, 192 / 255, 192 / 255)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), nil, nil, nil, 192 / 255, 192 / 255, 192 / 255)

	-- World bosses
	title = false
	for i = 1, GetNumSavedWorldBosses() do
		local name, id, reset = GetSavedWorldBossInfo(i)
		if not (id == 11 or id == 12 or id == 13) then
			addTitle(RAID_INFO_WORLD_BOSS)
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 192 / 255, 192 / 255, 192 / 255)
		end
	end

	-- Herioc/Mythic Dungeons
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diff, locked, extended, _, _, maxPlayers, diffName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if (diff == 2 or diff == 23) and (locked or extended) and name then
			addTitle("Saved Dungeon(s)")
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 192 / 255, 192 / 255, 192 / 255
			end

			GameTooltip:AddDoubleLine(name .. " - " .. maxPlayers .. " " .. PLAYER .. " (" .. diffName .. ") (" .. encounterProgress .. "/" .. numEncounters .. ")", SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Raids
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, extended, _, isRaid, _, diffName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) and name then
			addTitle(L["Saved Raid(s)"])
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 192 / 255, 192 / 255, 192 / 255
			end

			GameTooltip:AddDoubleLine(name .. " - " .. diffName .. " (" .. encounterProgress .. "/" .. numEncounters .. ")", SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Quests
	title = false
	for _, v in pairs(questlist) do
		if v.name and C_QuestLog_IsQuestFlaggedCompleted(v.id) then
			if v.name == "500 Timewarped Badges" and isTimeWalker and checkTexture(v.texture) or v.name ~= "500 Timewarped Badges" then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(v.itemID and GetItemLink(v.itemID) or v.name, QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
			end
		end
	end

	-- Elemental threats
	title = false
	for mapID, stormGroup in next, stormPoiIDs do
		for _, areaPoiIDs in next, stormGroup do
			for _, areaPoiID in next, areaPoiIDs do
				local poiInfo = C_AreaPoiInfo_GetAreaPOIInfo(mapID, areaPoiID)
				local elementType = poiInfo and poiInfo.atlasName and strmatch(poiInfo.atlasName, "ElementalStorm%-Lesser%-(.+)")
				if elementType then
					addTitle(poiInfo.name)
					local mapInfo = C_Map_GetMapInfo(mapID)
					local timeLeft = C_AreaPoiInfo_GetAreaPOISecondsLeft(areaPoiID) or 0
					timeLeft = timeLeft / 60
					if timeLeft < 60 then
						r, g, b = 1, 0, 0
					else
						r, g, b = 0, 1, 0
					end
					GameTooltip:AddDoubleLine(mapInfo.name .. GetElementalType(elementType), GetFormattedTimeLeft(timeLeft), 1, 1, 1, r, g, b)
					break
				end
			end
		end
	end

	-- Grand hunts
	title = false
	for areaPoiID, mapID in pairs(huntAreaToMapID) do
		local poiInfo = C_AreaPoiInfo_GetAreaPOIInfo(1978, areaPoiID) -- Dragon isles
		if poiInfo then
			addTitle(poiInfo.name)
			local mapInfo = C_Map_GetMapInfo(mapID)
			local timeLeft = C_AreaPoiInfo_GetAreaPOISecondsLeft(areaPoiID) or 0
			timeLeft = timeLeft / 60
			if timeLeft < 60 then
				r, g, b = 1, 0, 0
			else
				r, g, b = 0, 1, 0
			end
			GameTooltip:AddDoubleLine(mapInfo.name, GetFormattedTimeLeft(timeLeft), 1, 1, 1, r, g, b)
			break
		end
	end

	-- Community feast
	title = false
	local feastTime = communityFeastTime[region]
	if feastTime then
		local currentTime = time()
		local duration = 5400 -- 1.5hrs
		local elapsed = mod(currentTime - feastTime, duration)
		local nextTime = duration - elapsed + currentTime

		addTitle(GetSpellInfo(388961))
		if currentTime - (nextTime - duration) < 900 then
			r, g, b = 0, 1, 0
		else
			r, g, b = 0.6, 0.6, 0.6
		end -- green text if progressing
		GameTooltip:AddDoubleLine(date("%m/%d %H:%M", nextTime - duration * 2), date("%m/%d %H:%M", nextTime - duration), 1, 1, 1, r, g, b)
		GameTooltip:AddDoubleLine(date("%m/%d %H:%M", nextTime), date("%m/%d %H:%M", nextTime + duration), 1, 1, 1, 1, 1, 1)
	end

	if IsShiftKeyDown() then
		-- Nzoth relavants
		for _, v in ipairs(horrificVisions) do
			if C_QuestLog_IsQuestFlaggedCompleted(v.id) then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(SPLASH_BATTLEFORAZEROTH_8_3_0_FEATURE1_TITLE, v.desc, 1, 1, 1, 0, 1, 0)
				break
			end
		end

		for _, id in pairs(lesserVisions) do
			if C_QuestLog_IsQuestFlaggedCompleted(id) then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine("Lesser Vision of N'Zoth", QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
				break
			end
		end

		if not nzothAssaults then
			nzothAssaults = C_TaskQuest_GetThreatQuests() or {}
		end
		for _, v in pairs(nzothAssaults) do
			if C_QuestLog_IsQuestFlaggedCompleted(v) then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(GetNzothThreatName(v), QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
			end
		end

		-- Invasions
		for index, value in ipairs(invIndex) do
			title = false
			addTitle(value.title)
			local timeLeft, zoneName = CheckInvasion(index)
			local nextTime = GetNextTime(value.baseTime, index)
			if timeLeft then
				timeLeft = timeLeft / 60
				if timeLeft < 60 then
					r, g, b = 1, 0, 0
				else
					r, g, b = 0, 1, 0
				end
				GameTooltip:AddDoubleLine(L["Current Invasion"] .. zoneName, string_format("%.2d:%.2d", timeLeft / 60, timeLeft % 60), 1, 1, 1, r, g, b)
			end
			local nextLocation = GetNextLocation(nextTime, index)
			GameTooltip:AddDoubleLine(L["Next Invasion"] .. nextLocation, date("%m/%d %H:%M", nextTime), 1, 1, 1, 192 / 255, 192 / 255, 192 / 255)
		end
	else
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(K.InfoColor .. "Hold SHIFT for info|r")
	end

	-- Help Info
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.LeftButton .. GAMETIME_TOOLTIP_TOGGLE_CALENDAR)
	GameTooltip:AddLine(K.ScrollButton .. WEEKLY_REWARDS_CLICK_TO_PREVIEW_INSTRUCTIONS)
	GameTooltip:AddLine(K.RightButton .. GAMETIME_TOOLTIP_TOGGLE_CLOCK)
	GameTooltip:Show()

	K:RegisterEvent("MODIFIER_STATE_CHANGED", Module.TimeOnShiftDown)
end

function Module:TimeOnLeave()
	TimeDataTextEntered = false
	K.HideTooltip()
	K:UnregisterEvent("MODIFIER_STATE_CHANGED", Module.TimeOnShiftDown)
end

function Module:TimeOnMouseUp(btn)
	if btn == "RightButton" then
		_G.ToggleTimeManager()
	elseif btn == "MiddleButton" then
		if not WeeklyRewardsFrame then
			LoadAddOn("Blizzard_WeeklyRewards")
		end
		if InCombatLockdown() then
			K.TogglePanel(WeeklyRewardsFrame)
		else
			ToggleFrame(WeeklyRewardsFrame)
		end
	else
		_G.ToggleCalendar()
	end
end

function Module:CreateTimeDataText()
	if not C["DataText"].Time then
		return
	end

	if not Minimap then
		return
	end

	TimeDataText = TimeDataText or CreateFrame("Frame", "KKUI_TimeDataText", Minimap)
	TimeDataText:SetFrameLevel(8)

	TimeDataText.Font = TimeDataText.Font or TimeDataText:CreateFontString("OVERLAY")
	TimeDataText.Font:SetFontObject(K.UIFont)
	TimeDataText.Font:SetFont(select(1, TimeDataText.Font:GetFont()), 13, select(3, TimeDataText.Font:GetFont()))
	TimeDataText.Font:SetPoint("BOTTOM", _G.Minimap, "BOTTOM", 0, 2)

	TimeDataText:SetAllPoints(TimeDataText.Font)

	TimeDataText:SetScript("OnUpdate", Module.TimeOnUpdate)
	TimeDataText:SetScript("OnEnter", Module.TimeOnEnter)
	TimeDataText:SetScript("OnLeave", Module.TimeOnLeave)
	TimeDataText:SetScript("OnMouseUp", Module.TimeOnMouseUp)
end
