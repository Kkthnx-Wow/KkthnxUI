local K, C, L = unpack(select(2, ...))
if C["DataText"].Time ~= true then
	return
end

local Module = K:GetModule("Infobar")
local ModuleInfo = Module:RegisterInfobar("KkthnxUITime", {"BOTTOM", Minimap, "BOTTOM", 0, 2})

local _G = _G
local date = _G.date
local string_find = _G.string.find
local string_format = _G.string.format
local time = _G.time
local mod = _G.mod
local math_floor = _G.math.floor

local C_AreaPoiInfo_GetAreaPOISecondsLeft = _G.C_AreaPoiInfo.GetAreaPOISecondsLeft
local C_Calendar_GetDate = _G.C_Calendar.GetDate
local C_Calendar_GetDayEvent = _G.C_Calendar.GetDayEvent
local C_Calendar_GetNumDayEvents = _G.C_Calendar.GetNumDayEvents
local C_Calendar_GetNumPendingInvites = _G.C_Calendar.GetNumPendingInvites
local C_Calendar_OpenCalendar = _G.C_Calendar.OpenCalendar
local C_Calendar_SetAbsMonth = _G.C_Calendar.SetAbsMonth
local C_Map_GetMapInfo = _G.C_Map.GetMapInfo
local GameTime_GetGameTime = _G.GameTime_GetGameTime
local GameTime_GetLocalTime = _G.GameTime_GetLocalTime
local GetCVar = _G.GetCVar
local GetCVarBool = _G.GetCVarBool
local GetCurrencyInfo = _G.GetCurrencyInfo
local GetGameTime = _G.GetGameTime
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetNumSavedWorldBosses = _G.GetNumSavedWorldBosses
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local GetSavedWorldBossInfo = _G.GetSavedWorldBossInfo
local InCombatLockdown = _G.InCombatLockdown
local IsQuestFlaggedCompleted = _G.IsQuestFlaggedCompleted
local SecondsToTime = _G.SecondsToTime

-- Data
local timeBonusList = {
	52834, 52838,	-- Gold
	52835, 52839,	-- Honor
	52837, 52840,	-- Resources
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

-- Check Invasion Status
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
	[1] = {title = "Legion Invasion", duration = 66600, maps = {630, 641, 650, 634}, timeTable = {}, baseTime = legionZoneTime[region] or legionZoneTime["CN"]}, -- need reviewed
	[2] = {title = "BFA Invasion", duration = 68400, maps = {862, 863, 864, 896, 942, 895}, timeTable = {4, 1, 6, 2, 5, 3}, baseTime = bfaZoneTime[region] or bfaZoneTime["CN"]},
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

local function updateTimerFormat(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return string_format(color..TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = K.MyClassColor..(hour < 12 and "am" or "pm")

		if hour > 12 then
			hour = hour - 12
		end

		return string_format(color..TIMEMANAGER_TICKER_12HOUR..timerUnit, hour, minute)
	end
end

ModuleInfo.onUpdate = function(self, elapsed)
	self.timer = (self.timer or 3) + elapsed
	if self.timer > 5 then
		local color = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""

		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		self.text:SetText(updateTimerFormat(color, hour, minute))

		self.timer = 0
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

local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text..":")
		title = true
	end
end

ModuleInfo.onEnter = function(self)
	RequestRaidInfo()

	local r, g, b
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))
	GameTooltip:ClearLines()

	local today = C_Calendar_GetDate()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	GameTooltip:AddLine(string_format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0, 0.6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Local Time", GameTime_GetLocalTime(true), nil, nil, nil, 1, 1, 1)
	GameTooltip:AddDoubleLine("Realm Time", GameTime_GetGameTime(true), nil, nil, nil, 1, 1, 1)


	-- World bosses
	title = false
	for i = 1, GetNumSavedWorldBosses() do
		local name, id, reset = GetSavedWorldBossInfo(i)
		if not (id == 11 or id == 12 or id == 13) then
			addTitle(RAID_INFO_WORLD_BOSS)
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 1, 1, 1)
		end
	end

	-- Mythic Dungeons
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diff, locked, extended = GetSavedInstanceInfo(i)
		if diff == 23 and (locked or extended) then
			addTitle(DUNGEON_DIFFICULTY3..DUNGEONS)
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 1, 1, 1
			end

			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Raids
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, extended, _, isRaid, _, diffName = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) then
			addTitle(RAID_INFO)
			if extended then
				r,g,b = 0.3, 1, 0.3
			else
				r,g,b = 1, 1, 1
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
			r,g,b = 1, 0, 0
		else
			r,g,b = 0, 1, 0
		end

		GameTooltip:AddDoubleLine(bonusName, count.."/"..maxCoins, 1,1,1, r,g,b)
	end

	-- local iwqID = C_IslandsQueue_GetIslandsWeeklyQuestID()
	-- if iwqID and UnitLevel("player") == 120 then
	-- 	addTitle(QUESTS_LABEL)
	-- 	if IsQuestFlaggedCompleted(iwqID) then
	-- 		GameTooltip:AddDoubleLine(ISLANDS_HEADER, QUEST_COMPLETE, 1,1,1, 1,0,0)
	-- 	else
	-- 		local cur, max = select(4, GetQuestObjectiveInfo(iwqID, 1, false))
	-- 		local stautsText = cur.."/"..max
	-- 		if not cur or not max then stautsText = LFG_LIST_LOADING end
	-- 		GameTooltip:AddDoubleLine(ISLANDS_HEADER, stautsText, 1,1,1, 0,1,0)
	-- 	end
	-- end

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
		local timeLeft, zoneName = CheckInvasion(index)
		local nextTime = GetNextTime(value.baseTime, index)
		if timeLeft then
			timeLeft = timeLeft / 60
			if timeLeft < 60 then
				r, g, b = 1, 0, 0
			else
				r, g, b = 0, 1, 0
			end

			GameTooltip:AddDoubleLine("Current Invasion "..zoneName, string_format("%.2d:%.2d", timeLeft / 60, timeLeft % 60), 1, 1, 1, r, g, b)
		end

		local nextLocation = GetNextLocation(nextTime, index)
		GameTooltip:AddDoubleLine("Next Invasion "..nextLocation, date("%m/%d %H:%M", nextTime), 1, 1, 1, 1, 1, 1)
	end

	-- Help Info
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t ".."Toggle Calendar")
	GameTooltip:AddLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t ".."Toggle Clock")
	GameTooltip:Show()
end

ModuleInfo.onLeave = K.HideTooltip

ModuleInfo.onMouseUp = function(_, btn)
	if btn == "RightButton" then
		ToggleTimeManager()
	else
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end
		ToggleCalendar()
	end
end