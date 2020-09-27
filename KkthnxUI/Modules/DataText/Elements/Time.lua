local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local date = _G.date
local ipairs = _G.ipairs
local math_floor = _G.math.floor
local mod = _G.mod
local pairs = _G.pairs
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local time = _G.time
local tonumber = _G.tonumber

local CALENDAR_FULLDATE_MONTH_NAMES = _G.CALENDAR_FULLDATE_MONTH_NAMES
local CALENDAR_WEEKDAY_NAMES = _G.CALENDAR_WEEKDAY_NAMES
local C_AreaPoiInfo_GetAreaPOISecondsLeft = _G.C_AreaPoiInfo.GetAreaPOISecondsLeft
local C_Calendar_GetDate = _G.C_Calendar.GetDate
local C_Calendar_GetDayEvent = _G.C_Calendar.GetDayEvent
local C_Calendar_GetNumDayEvents = _G.C_Calendar.GetNumDayEvents
local C_Calendar_GetNumPendingInvites = _G.C_Calendar.GetNumPendingInvites
local C_Calendar_OpenCalendar = _G.C_Calendar.OpenCalendar
local C_Calendar_SetAbsMonth = _G.C_Calendar.SetAbsMonth
local C_CurrencyInfo_GetCurrencyInfo = _G.C_CurrencyInfo.GetCurrencyInfo
local C_DateAndTime_GetCurrentCalendarTime = _G.C_DateAndTime.GetCurrentCalendarTime
local C_IslandsQueue_GetIslandsWeeklyQuestID = _G.C_IslandsQueue.GetIslandsWeeklyQuestID
local C_Map_GetMapInfo = _G.C_Map.GetMapInfo
local C_TaskQuest_GetQuestInfoByQuestID = _G.C_TaskQuest.GetQuestInfoByQuestID
local C_TaskQuest_GetThreatQuests = _G.C_TaskQuest.GetThreatQuests
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local FULLDATE = _G.FULLDATE
local GameTime_GetGameTime = _G.GameTime_GetGameTime
local GameTime_GetLocalTime = _G.GameTime_GetLocalTime
local GameTooltip = _G.GameTooltip
local GetCVar = _G.GetCVar
local GetCVarBool = _G.GetCVarBool
local GetGameTime = _G.GetGameTime
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetNumSavedWorldBosses = _G.GetNumSavedWorldBosses
local GetQuestObjectiveInfo = _G.GetQuestObjectiveInfo
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local GetSavedWorldBossInfo = _G.GetSavedWorldBossInfo
local ISLANDS_HEADER = _G.ISLANDS_HEADER
local InCombatLockdown = _G.InCombatLockdown
local IsPlayerAtEffectiveMaxLevel = _G.IsPlayerAtEffectiveMaxLevel
local IsQuestFlaggedCompleted = _G.IsQuestFlaggedCompleted
local LFG_LIST_LOADING = _G.LFG_LIST_LOADING
local PLAYER_DIFFICULTY_TIMEWALKER = _G.PLAYER_DIFFICULTY_TIMEWALKER
local PVPGetConquestLevelInfo = _G.PVPGetConquestLevelInfo
local PVP_CONQUEST = _G.PVP_CONQUEST
local QUESTS_LABEL = _G.QUESTS_LABEL
local QUEST_COMPLETE = _G.QUEST_COMPLETE
local QUEUE_TIME_UNAVAILABLE = _G.QUEUE_TIME_UNAVAILABLE
local RequestRaidInfo = _G.RequestRaidInfo
local SecondsToTime = _G.SecondsToTime
local TIMEMANAGER_TICKER_12HOUR = _G.TIMEMANAGER_TICKER_12HOUR
local TIMEMANAGER_TICKER_24HOUR = _G.TIMEMANAGER_TICKER_24HOUR

-- Data
local timeBonusList = {
	52834, 52838, -- Gold
	52835, 52839, -- Honor
	52837, 52840, -- Resources
}

local timeQuestList = {
	{name = "Blingtron", id = 34774},
	{name = "Mean One", id = 6983},
	{name = "Timewarped", id = 40168, texture = 1129674}, -- TBC
	{name = "Timewarped", id = 40173, texture = 1129686}, -- WotLK
	{name = "Timewarped", id = 40786, texture = 1304688}, -- Cata
	{name = "Timewarped", id = 45563, texture = 1530590}, -- MoP
	{name = "Timewarped", id = 55499, texture = 1129683}, -- WoD
}

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
	[1] = {title = L["Legion Invasion"], duration = 66600, maps = {630, 641, 650, 634}, timeTable = {}, baseTime = legionZoneTime[region] or legionZoneTime["CN"]},
	[2] = {title = L["BFA Invasion"], duration = 68400, maps = {862, 863, 864, 896, 942, 895}, timeTable = {4, 1, 6, 2, 5, 3}, baseTime = bfaZoneTime[region] or bfaZoneTime["CN"]},
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

local lesserVisions = {58151, 58155, 58156, 58167, 58168}
local horrificVisions = {
	[1] = {id = 57848, desc = "470 (5+5)"},
	[2] = {id = 57844, desc = "465 (5+4)"},
	[3] = {id = 57847, desc = "460 (5+3)"},
	[4] = {id = 57843, desc = "455 (5+2)"},
	[5] = {id = 57846, desc = "450 (5+1)"},
	[6] = {id = 57842, desc = "445 (5+0)"},
	[7] = {id = 57845, desc = "430 (3+0)"},
	[8] = {id = 57841, desc = "420 (1+0)"},
}

function Module:updateTimerFormat(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return string_format(color..TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = K.MyClassColor..(hour < 12 and " AM" or " PM")

		if hour >= 12 then
			if hour > 12 then
				hour = hour - 12
			end
		else
			if hour == 0 then
				hour = 12
			end
		end

		return string_format(color..TIMEMANAGER_TICKER_12HOUR..timerUnit, hour, minute)
	end
end

function Module:TimeOnUpdate(elapsed)
	Module.timer = (Module.timer or 3) + elapsed
	if Module.timer > 5 then
		local color = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""

		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		Module.TimeFont:SetText(Module:updateTimerFormat(color, hour, minute))

		Module.timer = 0
	end
end

local bonusName = C_CurrencyInfo_GetCurrencyInfo(1580).name
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

-- Check Invasion Status
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
	local round = mod(math_floor(elapsed / inv.duration) + 1, count)
	if round == 0 then
		round = count
	end

	return C_Map_GetMapInfo(inv.maps[inv.timeTable[round]]).name
end

local cache, nzothAssaults = {}
local function GetNzothThreatName(questID)
	local name = cache[questID]
	if not name then
		name = C_TaskQuest_GetQuestInfoByQuestID(questID)
		cache[questID] = name
	end
	return name
end

local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text..":")
		title = true
	end
end

function Module:TimeOnEnter()
	RequestRaidInfo()

	local r, g, b
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))
	GameTooltip:ClearLines()

	local today = C_DateAndTime_GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	GameTooltip:AddLine(string_format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0, 0.6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), nil, nil, nil, 192/255, 192/255, 192/255)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), nil, nil, nil, 192/255, 192/255, 192/255)

	-- World bosses
	title = false
	for i = 1, GetNumSavedWorldBosses() do
		local name, id, reset = GetSavedWorldBossInfo(i)
		if not (id == 11 or id == 12 or id == 13) then
			addTitle(RAID_INFO_WORLD_BOSS)
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 192/255, 192/255, 192/255)
		end
	end

	-- Mythic Dungeons
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diff, locked, extended = GetSavedInstanceInfo(i)
		if diff == 23 and (locked or extended) then
			addTitle("Saved Dungeon(s)")
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 192/255, 192/255, 192/255
			end

			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Raids
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, extended, _, isRaid, _, diffName = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) then
			addTitle(L["Saved Raid(s)"])
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 192/255, 192/255, 192/255
			end

			GameTooltip:AddDoubleLine(name.." - "..diffName, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Quests
	title = false
	local count, maxCoins = 0, 2
	for _, id in pairs(timeBonusList) do
		if C_QuestLog.IsQuestFlaggedCompleted(id) then
			count = count + 1
		end
	end

	if count > 0 then
		addTitle(QUESTS_LABEL)
		if count == maxCoins then
			r, g, b = 1, 0, 0
		else
			r, g, b = 0, 1, 0
		end

		GameTooltip:AddDoubleLine(bonusName, count.."/"..maxCoins, 1, 1, 1, r, g, b)
	end

	do
		local currentValue, maxValue, questID = PVPGetConquestLevelInfo()
		local questDone = questID and questID == 0
		if IsPlayerAtEffectiveMaxLevel() then
			if questDone then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(PVP_CONQUEST, QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
			elseif currentValue > 0 then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(PVP_CONQUEST, currentValue.."/"..maxValue, 1, 1, 1, 0, 1, 0)
			end
		end
	end

	for _, v in ipairs(horrificVisions) do
		if C_QuestLog.IsQuestFlaggedCompleted(v.id) then
			addTitle(QUESTS_LABEL)
			GameTooltip:AddDoubleLine(SPLASH_BATTLEFORAZEROTH_8_3_0_FEATURE1_TITLE, v.desc, 1, 1, 1, 0, 1, 0)
			break
		end
	end

	local iwqID = C_IslandsQueue_GetIslandsWeeklyQuestID()
	if iwqID and K.Level == 120 then
		addTitle(QUESTS_LABEL)
		if C_QuestLog.IsQuestFlaggedCompleted(iwqID) then
			GameTooltip:AddDoubleLine(ISLANDS_HEADER, QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
		else
			local cur, max = select(4, GetQuestObjectiveInfo(iwqID, 1, false))
			local stautsText
			if not cur or not max then
				stautsText = LFG_LIST_LOADING
			else
				stautsText = cur.."/"..max
			end
			GameTooltip:AddDoubleLine(ISLANDS_HEADER, stautsText, 1, 1, 1, 0, 1, 0)
		end
	end

	for _, id in pairs(lesserVisions) do
		if C_QuestLog.IsQuestFlaggedCompleted(id) then
			addTitle(QUESTS_LABEL)
			GameTooltip:AddDoubleLine("LesserVision", QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
			break
		end
	end

	if not nzothAssaults then
		nzothAssaults = C_TaskQuest_GetThreatQuests() or {}
	end

	for _, v in pairs(nzothAssaults) do
		if C_QuestLog.IsQuestFlaggedCompleted(v) then
			addTitle(QUESTS_LABEL)
			GameTooltip:AddDoubleLine(GetNzothThreatName(v), QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
		end
	end

	for _, v in pairs(timeQuestList) do
		if v.name and C_QuestLog.IsQuestFlaggedCompleted(v.id) then
			if v.name == "Timewarped" and isTimeWalker and checkTexture(v.texture) or v.name ~= "Timewarped" then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine(v.name, QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
			end
		end
	end

	-- Invasions
	for index, value in ipairs(invIndex) do
		title = false
		addTitle(value.title)
		local timeLeft, zoneName = CheckInvasion(index)
		local nextTime = GetNextTime(value.baseTime, index)
		if timeLeft then
			timeLeft = timeLeft/60
			if timeLeft < 60 then
				r,g,b = 1, 0, 0
			else
				r,g,b = 0, 1, 0
			end
			GameTooltip:AddDoubleLine(L["Current Invasion"]..zoneName, string_format("%.2d:%.2d", timeLeft / 60, timeLeft % 60), 1, 1, 1, r, g, b)
		end

		local nextLocation = GetNextLocation(nextTime, index)
		GameTooltip:AddDoubleLine(L["Next Invasion"]..nextLocation, date("%m/%d %H:%M", nextTime), 1, 1, 1, 192/255, 192/255, 192/255)
	end

	-- Help Info
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t ".."Toggle Calendar")
	GameTooltip:AddLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t ".."Toggle Clock")
	GameTooltip:Show()
end

function Module:TimeOnLeave()
	GameTooltip:Hide()
end

function Module:TimeOnMouseUp(btn)
	if btn == "RightButton" then
		_G.ToggleTimeManager()
	else
		if InCombatLockdown() then
			_G.UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end

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

	Module.TimeFrame = CreateFrame("Frame", "KKUI_TimeDataText", Minimap)

	Module.TimeFont = Module.TimeFrame:CreateFontString("OVERLAY")
	Module.TimeFont:FontTemplate(nil, 13)
	Module.TimeFont:SetPoint("BOTTOM", _G.Minimap, "BOTTOM", 0, 2)

	Module.TimeFrame:SetAllPoints(Module.TimeFont)

	Module.TimeFrame:SetScript("OnUpdate", Module.TimeOnUpdate)
	Module.TimeFrame:SetScript("OnEnter", Module.TimeOnEnter)
	Module.TimeFrame:SetScript("OnLeave", Module.TimeOnLeave)
	Module.TimeFrame:SetScript("OnMouseUp", Module.TimeOnMouseUp)
end