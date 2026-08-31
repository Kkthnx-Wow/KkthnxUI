--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Test.lua
	Purpose:
		Config mode. Instead of drawing throwaway mock frames, this forces the real
		frames to show with the player's own data, which is the sturdiest way to
		preview them. Individual frames (player, target, boss, and the rest) are pointed at
		the player and their unit watch is forced on. Group headers (party and raid)
		get a negative starting index so the secure header spawns its full set of
		phantom frames while solo, and each child is forced on the same way. Toggling
		off restores every frame, and nothing here runs in combat.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")

local ipairs = ipairs
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local RegisterUnitWatch = RegisterUnitWatch
local UnregisterUnitWatch = UnregisterUnitWatch

-- The standalone frames, by module key. Boss frames live in a numbered list and
-- are handled alongside these.
local INDIVIDUAL = { "Player", "Target", "TargetOfTarget", "Pet", "Focus", "FocusTarget" }

-- Header show gates cleared during config mode so the header renders phantom frames
-- while solo, then restored on the way out.
local GATES = { "showRaid", "showParty", "showSolo" }

-- ---------------------------------------------------------------------------
-- Force a single frame
-- ---------------------------------------------------------------------------

-- Point a frame at the player, keep it shown through a forced unit watch, and
-- refresh its elements so it fills with live data.
local function ForceFrame(frame)
	if not frame or frame.__kkuiForced then
		return
	end
	frame.__kkuiForced = true
	frame.__realUnit = frame.unit
	frame.unit = "player"
	frame.__unit = "player"
	frame:EnableMouse(false)
	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame, true)
	frame:Show()
	if frame.UpdateAllElements then
		frame:UpdateAllElements("KKUI_ConfigMode")
	end
end

local function UnforceFrame(frame)
	if not frame or not frame.__kkuiForced then
		return
	end
	frame.__kkuiForced = nil
	frame.unit = frame.__realUnit
	frame.__unit = frame.__realUnit
	frame.__realUnit = nil
	frame:EnableMouse(true)
	UnregisterUnitWatch(frame)
	RegisterUnitWatch(frame)
	if frame.UpdateAllElements then
		frame:UpdateAllElements("KKUI_ConfigMode")
	end
end

-- ---------------------------------------------------------------------------
-- Group headers
-- ---------------------------------------------------------------------------

-- The secure header stores its children as child1..childN attributes, which is the
-- reliable way to walk them (GetChildren would also catch non-frames and miss any
-- that spawn on the same frame).
local function ForEachChild(header, func)
	local i = 1
	local child = header:GetAttribute("child" .. i)
	while child do
		func(child)
		i = i + 1
		child = header:GetAttribute("child" .. i)
	end
end

local function ForceHeader(header)
	if not header then
		return
	end
	header.__cfgSaved = {}
	for _, key in ipairs(GATES) do
		header.__cfgSaved[key] = header:GetAttribute(key)
		header:SetAttribute(key, nil)
	end
	header.__cfgStart = header:GetAttribute("startingIndex")

	RegisterStateDriver(header, "visibility", "show")
	header:Show()
	-- Negative index -> the header lays out its full phantom set.
	header:SetAttribute("startingIndex", header.__testStart or -4)
	ForEachChild(header, ForceFrame)
	-- The secure header can finish spawning its children on the next frame, so sweep
	-- once more then. ForceFrame is idempotent, so already-forced children are left
	-- alone, and the guard means a sweep after exit does nothing.
	C_Timer.After(0, function()
		if header.__cfgSaved then
			ForEachChild(header, ForceFrame)
		end
	end)
end

local function UnforceHeader(header, visibility)
	if not header then
		return
	end
	ForEachChild(header, UnforceFrame)
	if header.__cfgSaved then
		for _, key in ipairs(GATES) do
			header:SetAttribute(key, header.__cfgSaved[key])
		end
		header.__cfgSaved = nil
	end
	header:SetAttribute("startingIndex", header.__cfgStart or 1)
	header.__cfgStart = nil
	RegisterStateDriver(header, "visibility", visibility)
end

-- The real visibility drivers, rebuilt so the headers go back to normal on exit.
local function PartyVisibility()
	local visibility = "[group:party,nogroup:raid] show; hide"
	if C.Unitframe.Party.ShowSolo then
		visibility = "[nogroup] show; " .. visibility
	end
	return visibility
end

-- ---------------------------------------------------------------------------
-- Enter / exit
-- ---------------------------------------------------------------------------

function Module:EnterConfigMode()
	if InCombatLockdown() then
		return
	end
	for _, key in ipairs(INDIVIDUAL) do
		ForceFrame(self[key])
	end
	if self.Boss then
		for _, frame in ipairs(self.Boss) do
			ForceFrame(frame)
		end
	end
	ForceHeader(self.Party)
	ForceHeader(self.Raid)
end

function Module:ExitConfigMode()
	if InCombatLockdown() then
		return
	end
	for _, key in ipairs(INDIVIDUAL) do
		UnforceFrame(self[key])
	end
	if self.Boss then
		for _, frame in ipairs(self.Boss) do
			UnforceFrame(frame)
		end
	end
	UnforceHeader(self.Party, PartyVisibility())
	UnforceHeader(self.Raid, "[group:raid] show; hide")
end
