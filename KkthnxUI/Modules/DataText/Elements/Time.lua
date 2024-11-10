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
local C_AreaPoiInfo_GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
local C_AreaPoiInfo_GetAreaPOISecondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft
local C_Calendar_GetDayEvent = C_Calendar.GetDayEvent
local C_Calendar_GetNumDayEvents = C_Calendar.GetNumDayEvents
local C_Calendar_GetNumPendingInvites = C_Calendar.GetNumPendingInvites
local C_Calendar_OpenCalendar = C_Calendar.OpenCalendar
local C_Calendar_SetAbsMonth = C_Calendar.SetAbsMonth
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local C_Map_GetMapInfo = C_Map.GetMapInfo
local C_QuestLog_IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local FULLDATE = FULLDATE
local GameTime_GetGameTime = GameTime_GetGameTime
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
	[1] = {
		title = L["Legion Invasion"],
		duration = 66600,
		maps = { 630, 641, 650, 634 },
		timeTable = {},
		baseTime = legionZoneTime[region] or legionZoneTime["CN"],
	},
	[2] = {
		title = L["Faction Assault"],
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
	{ name = C_Spell.GetSpellName(388945), id = 70866 }, -- SoDK
	{ name = "", id = 70906, itemID = 200468 }, -- Grand hunt
	{ name = "", id = 70893, questName = true }, -- Community feast
	{ name = "", id = 79226, questName = true }, -- The big dig
	{ name = "", id = 78319, questName = true }, -- The superbloom
	{ name = "", id = 76586, questName = true }, -- 散步圣光
	{ name = "", id = 82946, questName = true }, -- 蜡团
	{ name = "", id = 83240, questName = true }, -- 剧场
	{ name = C_Map.GetAreaInfo(15141), id = 83333 }, -- 觉醒主机
}

local currentTime
local function updateTime()
	currentTime = currentTime or time()
	-- print("currentTime updated:", currentTime) -- Debug output
end

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

-- Declare onUpdateTimer as a local variable
local onUpdateTimer = onUpdateTimer or 3

local function OnUpdate(_, elapsed)
	onUpdateTimer = onUpdateTimer + elapsed
	if onUpdateTimer > 5 then
		local color = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""
		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		TimeDataText.Text:SetText(updateTimerFormat(color, hour, minute))

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
	updateTime() -- Ensure currentTime is updated if necessary
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

-- Grant hunts
local huntAreaToMapID = { -- 狩猎区域ID转换为地图ID
	[7342] = 2023, -- 欧恩哈拉平原
	[7343] = 2022, -- 觉醒海岸
	[7344] = 2025, -- 索德拉苏斯
	[7345] = 2024, -- 碧蓝林海
}

local delveList = {
	{ uiMapID = 2248, delveID = 7787 }, -- Earthcrawl Mines
	{ uiMapID = 2248, delveID = 7781 }, -- Kriegval's Rest
	{ uiMapID = 2248, delveID = 7779 }, -- Fungal Folly
	{ uiMapID = 2215, delveID = 7789 }, -- Skittering Breach
	{ uiMapID = 2215, delveID = 7785 }, -- Nightfall Sanctum
	{ uiMapID = 2215, delveID = 7783 }, -- The Sinkhole
	{ uiMapID = 2215, delveID = 7780 }, -- Mycomancer Cavern
	{ uiMapID = 2214, delveID = 7782 }, -- The Waterworks
	{ uiMapID = 2214, delveID = 7788 }, -- The Dread Pit
	{ uiMapID = 2255, delveID = 7790 }, -- The Spiral Weave
	{ uiMapID = 2255, delveID = 7784 }, -- Tak-Rethan Abyss
	{ uiMapID = 2255, delveID = 7786 }, -- TThe Underkeep
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
	["CN"] = 1679747400, -- 20:30
	["TW"] = 1679747400, -- 20:30
	["KR"] = 1679747400, -- 20:30
	["EU"] = 1679749200, -- 21:00
	["US"] = 1679751000, -- 21:30
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
		link = select(2, C_Item.GetItemInfo(itemID))
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

local function OnShiftDown()
	if Module.Entered then
		Module:OnEnter()
	end
end

function Module:OnEnter()
	Module.Entered = true

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
	local numSavedWorldBosses = GetNumSavedWorldBosses()
	if numSavedWorldBosses > 0 then
		addTitle(RAID_INFO_WORLD_BOSS)
		for i = 1, numSavedWorldBosses do
			local name, id, reset = GetSavedWorldBossInfo(i)
			if not (id == 11 or id == 12 or id == 13) then
				GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 192 / 255, 192 / 255, 192 / 255)
			end
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

			local progressColor = (numEncounters == encounterProgress) and "ff0000" or "00ff00"
			local progressStr = format(" |cff%s(%s/%s)|r", progressColor, encounterProgress, numEncounters)
			GameTooltip:AddDoubleLine(name .. " - " .. diffName .. progressStr, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Quests
	title = false
	for _, v in pairs(questlist) do
		if v.name and C_QuestLog_IsQuestFlaggedCompleted(v.id) then
			if v.name == "500 Timewarped Badges" and isTimeWalker and checkTexture(v.texture) or v.name ~= "500 Timewarped Badges" then
				addTitle(QUESTS_LABEL)
				GameTooltip:AddDoubleLine((v.itemID and GetItemLink(v.itemID)) or (v.questName and QuestUtils_GetQuestName(v.id)) or v.name, QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
			end
		end
	end

	-- Delves
	title = false
	for _, v in pairs(delveList) do
		local delveInfo = C_AreaPoiInfo_GetAreaPOIInfo(v.uiMapID, v.delveID)
		if delveInfo then
			addTitle(delveInfo.description)
			local mapInfo = C_Map_GetMapInfo(v.uiMapID)
			GameTooltip:AddDoubleLine(mapInfo.name .. " - " .. delveInfo.name, SecondsToTime(GetQuestResetTime(), true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	if IsShiftKeyDown() then
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

			addTitle(C_Spell.GetSpellName(388961))
			if currentTime - (nextTime - duration) < 900 then
				r, g, b = 0, 1, 0
			else
				r, g, b = 0.6, 0.6, 0.6
			end -- green text if progressing
			GameTooltip:AddDoubleLine(date("%m/%d %H:%M", nextTime - duration * 2), date("%m/%d %H:%M", nextTime - duration), 1, 1, 1, r, g, b)
			GameTooltip:AddDoubleLine(date("%m/%d %H:%M", nextTime), date("%m/%d %H:%M", nextTime + duration), 1, 1, 1, 1, 1, 1)
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

	K:RegisterEvent("MODIFIER_STATE_CHANGED", OnShiftDown)
end

local function OnLeave()
	Module.Entered = true
	K.HideTooltip()
	K:UnregisterEvent("MODIFIER_STATE_CHANGED", OnShiftDown)
end

local function OnMouseUp(_, btn)
	if btn == "RightButton" then
		_G.ToggleTimeManager()
	elseif btn == "MiddleButton" then
		if not WeeklyRewardsFrame then
			C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
		end
		if InCombatLockdown() then
			K.TogglePanel(WeeklyRewardsFrame)
		else
			ToggleFrame(WeeklyRewardsFrame)
		end
		local dialog = WeeklyRewardExpirationWarningDialog
		if dialog and dialog:IsShown() then
			dialog:Hide()
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

	TimeDataText = CreateFrame("Frame", nil, UIParent)
	TimeDataText:SetFrameLevel(8)
	TimeDataText:SetHitRectInsets(0, 0, -10, -10)

	TimeDataText.Text = K.CreateFontString(TimeDataText, 13)
	TimeDataText.Text:ClearAllPoints()
	TimeDataText.Text:SetPoint("BOTTOM", _G.Minimap, "BOTTOM", 0, 2)

	TimeDataText:SetAllPoints(TimeDataText.Text)

	TimeDataText:SetScript("OnEnter", Module.OnEnter)
	TimeDataText:SetScript("OnLeave", OnLeave)
	TimeDataText:SetScript("OnMouseUp", OnMouseUp)
	TimeDataText:SetScript("OnUpdate", OnUpdate)
end
