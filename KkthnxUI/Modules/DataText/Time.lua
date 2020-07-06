local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local date = _G.date
local ipairs = _G.ipairs
local math_floor = _G.math.floor
local mod = _G.mod
local pairs = _G.pairs
local string_find = _G.string.find
local string_format = _G.string.format
local table_insert = _G.table.insert
local time = _G.time
local tonumber = _G.tonumber

local C_AreaPoiInfo_GetAreaPOISecondsLeft = _G.C_AreaPoiInfo.GetAreaPOISecondsLeft
local C_Calendar_GetDate = _G.C_Calendar.GetDate
local C_Calendar_GetDayEvent = _G.C_Calendar.GetDayEvent
local C_Calendar_GetNumDayEvents = _G.C_Calendar.GetNumDayEvents
local C_Calendar_GetNumPendingInvites = _G.C_Calendar.GetNumPendingInvites
local C_Calendar_OpenCalendar = _G.C_Calendar.OpenCalendar
local C_Calendar_SetAbsMonth = _G.C_Calendar.SetAbsMonth
local C_Map_GetMapInfo = _G.C_Map.GetMapInfo
local CALENDAR_FULLDATE_MONTH_NAMES = _G.CALENDAR_FULLDATE_MONTH_NAMES
local CALENDAR_WEEKDAY_NAMES = _G.CALENDAR_WEEKDAY_NAMES
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local FULLDATE = _G.FULLDATE
local GameTime_GetGameTime = _G.GameTime_GetGameTime
local GameTime_GetLocalTime = _G.GameTime_GetLocalTime
local GameTooltip = _G.GameTooltip
local GetCurrencyInfo = _G.GetCurrencyInfo
local GetCurrentRegion = _G.GetCurrentRegion
local GetCVar = _G.GetCVar
local GetCVarBool = _G.GetCVarBool
local GetGameTime = _G.GetGameTime
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetNumSavedWorldBosses = _G.GetNumSavedWorldBosses
local GetQuestObjectiveInfo = _G.GetQuestObjectiveInfo
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local GetSavedWorldBossInfo = _G.GetSavedWorldBossInfo
local InCombatLockdown = _G.InCombatLockdown
local ISLANDS_HEADER = _G.ISLANDS_HEADER
local IsQuestFlaggedCompleted = _G.IsQuestFlaggedCompleted
local LFG_LIST_LOADING = _G.LFG_LIST_LOADING
local PLAYER_DIFFICULTY_TIMEWALKER = _G.PLAYER_DIFFICULTY_TIMEWALKER
local QUEST_COMPLETE = _G.QUEST_COMPLETE
local QUESTS_LABEL = _G.QUESTS_LABEL
local QUEUE_TIME_UNAVAILABLE = _G.QUEUE_TIME_UNAVAILABLE
local RequestRaidInfo = _G.RequestRaidInfo
local SecondsToTime = _G.SecondsToTime
local TIMEMANAGER_TICKER_12HOUR = _G.TIMEMANAGER_TICKER_12HOUR
local TIMEMANAGER_TICKER_24HOUR = _G.TIMEMANAGER_TICKER_24HOUR
local WORLD_BOSSES_TEXT = _G.WORLD_BOSSES_TEXT

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
if not region or #region ~= 2 then
	local regionID = GetCurrentRegion()
	region = regionID and ({ "US", "KR", "EU", "TW", "CN" })[regionID]
end

-- Sourced: NDui (siwei)
-- Modified: InvasionTimer (Rhythm)
-- Check Invasion Status
local invIndex = {
	{
		title = L["BFA Invasion"],
		interval = 68400,
		duration = 25200,
		maps = {862, 863, 864, 896, 942, 895},
		timeTable = {4, 1, 6, 2, 5, 3},
		-- Drustvar Beginning
		baseTime = {
			US = 1548032400, -- 01/20/2019 17:00 UTC-8
			EU = 1548000000, -- 01/20/2019 16:00 UTC+0
			CN = 1546743600, -- 01/06/2019 11:00 UTC+8
		},
	},
	{
		title = L["Legion Invasion"],
		interval = 66600,
		duration = 21600,
		maps = {630, 641, 650, 634},
		-- timeTable = {4, 3, 2, 1, 4, 2, 3, 1, 2, 4, 1, 3},
		-- Stormheim Beginning then Highmountain
		baseTime = {
			US = 1547614800, -- 01/15/2019 21:00 UTC-8
			EU = 1547586000, -- 01/15/2019 21:00 UTC+0
			CN = 1546844400, -- 01/07/2019 15:00 UTC+8
		},
	}
}

-- Fallback
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

local function updateTimerFormat(color, hour, minute)
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
		Module.TimeFont:SetText(updateTimerFormat(color, hour, minute))

		Module.timer = 0
	end
end

local bonusName = GetCurrencyInfo(1580)
local isTimeWalker, walkerTexture
local function checkTimeWalker(event)
	local date = C_Calendar_GetDate()
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

local function GetCurrentInvasion(index)
	local inv = invIndex[index]
	local currentTime = time()
	local baseTime = inv.baseTime[region]
	local duration = inv.duration
	local interval = inv.interval
	local elapsed = mod(currentTime - baseTime, interval)
	if elapsed < duration then
		if inv.timeTable then
			local count = #inv.timeTable
			local round = mod(math_floor((currentTime - baseTime) / interval) + 1, count)
			if round == 0 then
				round = count
			end

			return duration - elapsed, C_Map_GetMapInfo(inv.maps[inv.timeTable[round]]).name
		else
			-- unknown order
			local timeLeft, name = CheckInvasion(index)
			if timeLeft then
				-- found POI on map
				return timeLeft, name
			else
				-- fallback
				return duration - elapsed, UNKNOWN
			end
		end
	end
end

local function GetFutureInvasion(index, length)
	if not length then
		length = 1
	end

	local tbl = {}
	local inv = invIndex[index]
	local currentTime = time()
	local baseTime = inv.baseTime[region]
	local interval = inv.interval
	local elapsed = mod(currentTime - baseTime, interval)
	local nextTime = interval - elapsed + currentTime

	if not inv.timeTable then
		for _ = 1, length do
			table_insert(tbl, {nextTime, ""})
			nextTime = nextTime + interval
		end
	else
		local count = #inv.timeTable
		local round = mod(math_floor((nextTime - baseTime) / interval) + 1, count)
		for _ = 1, length do
			if round == 0 then
				round = count
			end

			table_insert(tbl, {nextTime, C_Map_GetMapInfo(inv.maps[inv.timeTable[round]]).name})
			nextTime = nextTime + interval
			round = mod(round + 1, count)
		end
	end

	return tbl
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

	local today = C_Calendar_GetDate()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	GameTooltip:AddLine(string_format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0, 0.6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Local Time", GameTime_GetLocalTime(true), nil, nil, nil, 192/255, 192/255, 192/255)
	GameTooltip:AddDoubleLine("Realm Time", GameTime_GetGameTime(true), nil, nil, nil, 192/255, 192/255, 192/255)

	-- World bosses
	title = false
	for i = 1, GetNumSavedWorldBosses() do
		local name, id, reset = GetSavedWorldBossInfo(i)
		if not (id == 11 or id == 12 or id == 13) then
			addTitle(WORLD_BOSSES_TEXT)
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
		if IsQuestFlaggedCompleted(id) then
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

		GameTooltip:AddDoubleLine(bonusName, count.."/"..maxCoins, 1,1,1, r, g, b)
	end

	local iwqID = C_IslandsQueue.GetIslandsWeeklyQuestID()
	if iwqID and K.Level == 120 then
		addTitle(QUESTS_LABEL)
		if IsQuestFlaggedCompleted(iwqID) then
			GameTooltip:AddDoubleLine(ISLANDS_HEADER, QUEST_COMPLETE, 1,1,1, 1,0,0)
		else
			local cur, max = select(4, GetQuestObjectiveInfo(iwqID, 1, false))
			local stautsText = cur.."/"..max
			if not cur or not max then
				stautsText = LFG_LIST_LOADING
			end
			GameTooltip:AddDoubleLine(ISLANDS_HEADER, stautsText, 1,1,1, 0,1,0)
		end
	end

	for _, v in pairs(timeQuestList) do
		if v.name and IsQuestFlaggedCompleted(v.id) then
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
		if value.baseTime[region] then
			-- baseTime provided
			local timeLeft, zoneName = GetCurrentInvasion(index)
			if timeLeft then
				timeLeft = timeLeft / 60
				GameTooltip:AddDoubleLine(L["Current Invasion"]..zoneName, string_format("%dh %.2dm", timeLeft / 60, timeLeft % 60), 1, 1, 1, r, g, b)
			end

			local futureTable, i = GetFutureInvasion(index, 2)
			for i = 1, #futureTable do
				local nextTime, zoneName = unpack(futureTable[i])
				GameTooltip:AddDoubleLine(L["Next Invasion"]..zoneName, date("%m/%d %H:%M", nextTime), 1, 1, 1, 192/255, 192/255, 192/255)
			end
		else
			local timeLeft, zoneName = CheckInvasion(index)
			if timeLeft then
				timeLeft = timeLeft / 60
				GameTooltip:AddDoubleLine(L["Current Invasion"]..zoneName, string_format("%dh %.2dm", timeLeft / 60, timeLeft % 60), 1, 1, 1, r, g, b)
			else
				GameTooltip:AddLine("Missing invasion info on your realm.")
			end
		end
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