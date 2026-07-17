--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Nudge toward active holiday / Timewalking LFG queues on first open per login.
-- - Design: HelpTip-free print nudge; never calls LFDQueueFrame_SetType (taint-safe).
-- - Events: PLAYER_LOGIN, LFG_UPDATE_RANDOM_INFO, LFDParentFrame OnShow (hooked)
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local C_Timer_After = _G.C_Timer.After
local GetLFGRandomDungeonInfo = _G.GetLFGRandomDungeonInfo
local GetNumRandomDungeons = _G.GetNumRandomDungeons
local IsLFGDungeonJoinable = _G.IsLFGDungeonJoinable
local string_find = string.find
local table_sort = table.sort
local table_wipe = table.wipe

local LFG_TYPE_RANDOM_TIMEWALKER_DUNGEON = _G.LFG_TYPE_RANDOM_TIMEWALKER_DUNGEON

local SPECIAL_RANDOM_DUNGEONS = {
	[288] = true,
	[286] = true,
	[287] = true,
	[285] = true,
	[744] = true,
	[995] = true,
	[1146] = true,
	[1453] = true,
	[1971] = true,
	[2274] = true,
	[2634] = true,
	[2874] = true,
	[3076] = true,
}

local candidates = {}
local eventsRegistered = false
local lfdHooked = false
local doneThisSession = false
local nudgePending = false
local addonLoadRegistered = false

local function isEventRandomDungeon(id, isHoliday, isTimeWalker, name)
	if isHoliday or isTimeWalker or SPECIAL_RANDOM_DUNGEONS[id] then
		return true
	end
	local label = LFG_TYPE_RANDOM_TIMEWALKER_DUNGEON
	return label and name and string_find(name, label, 1, true) ~= nil
end

local function getRandomDungeonName(dungeonID)
	for i = 1, GetNumRandomDungeons() do
		local id, name = GetLFGRandomDungeonInfo(i)
		if id == dungeonID then
			return name
		end
	end
end

local function getBestDungeon()
	table_wipe(candidates)
	local count = 0

	for i = 1, GetNumRandomDungeons() do
		local id, name, _, _, _, _, _, _, _, _, _, _, _, _, _, isHoliday, _, _, isTimeWalker = GetLFGRandomDungeonInfo(i)
		if IsLFGDungeonJoinable(id) and isEventRandomDungeon(id, isHoliday, isTimeWalker, name) then
			count = count + 1
			candidates[count] = id
		end
	end

	if count == 0 then
		return
	end

	table_sort(candidates)
	return candidates[1]
end

local function maybeNudge()
	if doneThisSession or not C["Automation"].HolidayDungeon then
		return
	end

	local queueFrame = _G.LFDQueueFrame
	local dropdown = queueFrame and queueFrame.TypeDropdown
	if not (queueFrame and queueFrame:IsShown() and dropdown) then
		return
	end

	local bestID = getBestDungeon()
	if not bestID then
		doneThisSession = true
		return
	end

	if queueFrame.type == bestID then
		doneThisSession = true
		return
	end

	doneThisSession = true
	nudgePending = false

	local name = getRandomDungeonName(bestID)
	if name then
		K.Print(string.format(L["HolidayDungeon Nudge"], name))
	end
end

local function scheduleNudge()
	if doneThisSession or not C["Automation"].HolidayDungeon then
		return
	end
	if not _G.LFDParentFrame or not _G.LFDParentFrame:IsShown() then
		return
	end

	nudgePending = true
	C_Timer_After(0.5, function()
		if nudgePending then
			maybeNudge()
		end
	end)
end

local function onLfgRandomInfo()
	if not nudgePending then
		return
	end
	maybeNudge()
end

local function onPlayerLogin()
	doneThisSession = false
	nudgePending = false
end

local function hookLfdFrame()
	if lfdHooked then
		return
	end

	local frame = _G.LFDParentFrame
	if not frame then
		return
	end

	lfdHooked = true
	frame:HookScript("OnShow", scheduleNudge)
end

local function trySetupLfdHook()
	if lfdHooked then
		return
	end

	if _G.LFDParentFrame or (C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_GroupFinder")) then
		hookLfdFrame()
		return
	end

	if addonLoadRegistered then
		return
	end

	addonLoadRegistered = true
	K:RegisterEvent("ADDON_LOADED", function(_, addonName)
		if addonName == "Blizzard_GroupFinder" then
			hookLfdFrame()
		end
	end)
end

local function registerEvents()
	if eventsRegistered then
		return
	end
	eventsRegistered = true
	K:RegisterEvent("PLAYER_LOGIN", onPlayerLogin)
	K:RegisterEvent("LFG_UPDATE_RANDOM_INFO", onLfgRandomInfo)
	trySetupLfdHook()
end

local function unregisterEvents()
	if not eventsRegistered then
		return
	end
	eventsRegistered = false
	K:UnregisterEvent("PLAYER_LOGIN", onPlayerLogin)
	K:UnregisterEvent("LFG_UPDATE_RANDOM_INFO", onLfgRandomInfo)
end

function Module:CreateHolidayDungeon()
	if not C["Automation"].HolidayDungeon then
		unregisterEvents()
		return
	end

	registerEvents()
	trySetupLfdHook()
end
