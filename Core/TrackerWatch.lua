--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/TrackerWatch.lua
	Purpose:
		Find out when the objective tracker first carries our taint, and what ran
		just before.

		The Maw buff error ("GetAuraDataByIndex(): Auras cannot be accessed when
		secret while tainted") comes out of ObjectiveTrackerContainer:Update, which
		Blizzard runs from a dirty callback. Nothing of ours is on that stack, so the
		taint was already on the container or its modules before the update began.
		This records two things around that:

		  1. Which calls reach the container height and the managed frame containers,
		     with the Lua frames that made them. RemoveManagedFrame and UpdateFrame
		     both end in ObjectiveTrackerFrame:UpdateHeight, and any managed frame
		     that gets shown, hidden or reparented from our code runs those under our
		     taint. If a frame from this addon shows up in a trace, that is the path.
		  2. The first moment each key on the container, its modules and the
		     managers turns up as written by KkthnxUI, by asking issecurevariable at
		     login, loading screens, zone changes and scenario events.

		Off until switched on, and it only reads.

			/kkdebug tracker
			(reload, reproduce in the delve)
			/kkdebug dump tracker
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local Debug = K.Debug

local pairs, pcall, type, tostring = pairs, pcall, type, tostring
local issecurevariable = _G.issecurevariable
local GetTime = GetTime
local format = string.format

local ADDON = "KkthnxUI"

local stream = Debug.Register("tracker", "When the objective tracker first carries our taint")

-- Tables whose keys are checked, by global name. The managers and the shared
-- widget table are here because the scenario module reads from all of them.
local TARGETS = {
	"ObjectiveTrackerFrame",
	"ObjectiveTrackerManager",
	"ScenarioObjectiveTracker",
	"UIWidgetObjectiveTracker",
	"QuestObjectiveTracker",
	"CampaignQuestObjectiveTracker",
	"BonusObjectiveTracker",
	"WorldQuestObjectiveTracker",
	"RightManagedFrameContainer",
	"BottomManagedFrameContainer",
	"PlayerBottomManagedFrameContainer",
	"UIWidgetManager",
}

-- Managed frame container methods that end in the tracker's UpdateHeight.
local CONTAINER_METHODS = { "AddManagedFrame", "RemoveManagedFrame", "UpdateFrame" }
local CONTAINERS = { "RightManagedFrameContainer", "BottomManagedFrameContainer", "PlayerBottomManagedFrameContainer" }

-- Keys already reported, so a key is only logged the first time it is seen.
local seen = {}
local lastCheck = 0
local hooked = {}

local function Check(label)
	if not stream.enabled then
		return
	end

	-- Scenario events can arrive in bursts, and one pass per half second is plenty.
	local now = GetTime()
	if now - lastCheck < 0.5 and label:find("^EVENT") then
		return
	end
	lastCheck = now

	local found = 0
	for _, name in ipairs(TARGETS) do
		local target = _G[name]
		if type(target) == "table" then
			local record = seen[name]
			if not record then
				record = {}
				seen[name] = record
			end
			for key in pairs(target) do
				if type(key) == "string" and not record[key] then
					local ok, secure, by = pcall(issecurevariable, target, key)
					if ok and secure == false and by == ADDON then
						record[key] = true
						found = found + 1
						stream:Push(format("[%s] %s.%s written by %s", label, name, key, ADDON))
					end
				end
			end
		end
	end
	if found == 0 and label:find("^milestone") then
		stream:Push(format("[%s] no key on the watched tables is written by %s", label, ADDON))
	end
end

local function InstallHooks()
	for _, name in ipairs(CONTAINERS) do
		local container = _G[name]
		if container and not hooked[name] then
			hooked[name] = true
			for _, method in ipairs(CONTAINER_METHODS) do
				stream:WatchMethod(container, method, name .. ":" .. method)
			end
		end
	end

	local tracker = _G.ObjectiveTrackerFrame
	if tracker and not hooked.tracker then
		hooked.tracker = true
		stream:WatchMethod(tracker, "UpdateHeight", "ObjectiveTrackerFrame:UpdateHeight")
		stream:WatchMethod(tracker, "MarkDirty", "ObjectiveTrackerFrame:MarkDirty")
		stream:WatchMethod(tracker, "Update", "ObjectiveTrackerFrame:Update")
	end
end

local watcher = CreateFrame("Frame")
for _, event in ipairs({
	"ADDON_LOADED",
	"PLAYER_LOGIN",
	"PLAYER_ENTERING_WORLD",
	"LOADING_SCREEN_DISABLED",
	"ZONE_CHANGED_NEW_AREA",
	"SCENARIO_UPDATE",
	"SCENARIO_CRITERIA_UPDATE",
	"PLAYER_REGEN_DISABLED",
	"PLAYER_REGEN_ENABLED",
}) do
	watcher:RegisterEvent(event)
end

watcher:SetScript("OnEvent", function(_, event, addon)
	-- The hooks go on as soon as the frames exist and then gate on the stream flag,
	-- so a switched off stream costs nothing.
	InstallHooks()
	if not stream.enabled then
		return
	end
	if event == "ADDON_LOADED" then
		-- Every load is a chance for something to have been written, but only the
		-- ones that can matter are worth a line.
		if addon == "Blizzard_ObjectiveTracker" or addon == ADDON then
			Check("milestone ADDON_LOADED " .. tostring(addon))
		end
		return
	end
	Check((event:find("^PLAYER_") or event:find("^LOADING") or event:find("^ZONE")) and ("milestone " .. event) or ("EVENT " .. event))
end)

-- A manual pass, for after the problem has happened.
Debug.Command("trackerscan", "Check the objective tracker tables for keys written by this addon", function()
	local was = stream.enabled
	stream.enabled = true
	InstallHooks()
	Check("milestone manual")
	stream.enabled = was
	K.Print("Tracker scan done, /kkdebug dump tracker to read it.")
end)
