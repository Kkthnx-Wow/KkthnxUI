--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Developer-focused frame debugging and utility tools.
-- - Design: Provides slash commands for inspecting frames, spells, and game state.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

-- ---------------------------------------------------------------------------
-- LOCALS & GLOBAL CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache frequent APIs and globals to minimize table lookups.
local math_ceil = math.ceil
local math_floor = math.floor
local print = print
local string_format = string.format
local tostring = tostring

local DESCRIPTION = DESCRIPTION
local EJ_GetCurrentTier = EJ_GetCurrentTier
local EJ_GetEncounterInfoByIndex = EJ_GetEncounterInfoByIndex
local EJ_GetInstanceInfo = EJ_GetInstanceInfo
local EJ_SelectInstance = EJ_SelectInstance
local EnumerateFrames = EnumerateFrames
local GetInstanceInfo = GetInstanceInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local GetSpellDescription = C_Spell.GetSpellDescription
local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local MouseIsOver = MouseIsOver
local NAME = NAME
local UNKNOWN = UNKNOWN
local UnitGUID = UnitGUID
local UnitName = UnitName

-- ---------------------------------------------------------------------------
-- SLASH COMMANDS: DEVTOOLS
-- ---------------------------------------------------------------------------

-- NOTE: Command Overview
-- Basics:
--   /getencounter        - Print tier/instance and boss indices (auto-loads EJ)
--   /getinstance         - Print instance name, type, difficulty, InstanceID, group size
--   /getnpc              - Print current target name and NPC ID
--   /getframe            - List visible frames under cursor and copy name to chat
--   /getspell <id|name>  - Print spell icon, name, and description
--   /getfont <Global>    - Print font object path, size, flags
--   /getpatch            - Print build info (aliases: /getbuild, /getinterface)
-- Grid overlay:
--   /grid, /align, /showgrid  - Toggle alignment grid (optionally pass box size)
-- Tooling (Blizzard Debug):
--   /taintlog [0|1|2|11|on|off|get]  - Set or get CVar taintLog
--   /kkfstack [/args]                - Toggle FrameStack (alias: /kkfs)
--   /kkeventtrace [mark <text>]      - Toggle EventTrace or add a mark (alias: /kket)
-- Tooltips:
--   /gettip, /gettooltip   - List tooltip-like frames currently on screen

_G.SlashCmdList["KKUI_ENUMTIP"] = function()
	-- REASON: Iterates all game frames to locate active tooltips for debugging anchored content.
	local enumf = EnumerateFrames()
	while enumf do
		-- NOTE: Case-insensitive match for frames typically used as tooltips.
		if (enumf:GetObjectType() == "GameTooltip" or string.find((enumf:GetName() or ""):lower(), "tip")) and enumf:IsVisible() and enumf:GetPoint() then
			print(enumf:GetName())
		end
		enumf = EnumerateFrames(enumf)
	end
end
_G.SLASH_KKUI_ENUMTIP1 = "/gettip"
_G.SLASH_KKUI_ENUMTIP2 = "/gettooltip"
_G.SLASH_KKUI_ENUMTIP3 = "/kt"

_G.SlashCmdList["KKUI_ENUMFRAME"] = function()
	-- REASON: Identifies all visible frames under the mouse cursor for UI inspection.
	local frame = EnumerateFrames()
	local chatModule = K:GetModule("Chat")
	local shown = 0
	while frame do
		if frame:IsVisible() and MouseIsOver(frame) then
			print(frame:GetName() or string_format(UNKNOWN .. ": [%s]", tostring(frame)))
			shown = shown + 1
			-- NOTE: Trigger chat copy if the module is enabled to easily extract frame names.
			if chatModule and chatModule.ChatCopy_OnClick then
				chatModule:ChatCopy_OnClick("LeftButton")
			end
		end

		frame = EnumerateFrames(frame)
	end
	if shown == 0 then
		print(K.InfoColor .. "No visible frames under cursor.")
	end
end
_G.SLASH_KKUI_ENUMFRAME1 = "/getframe"
_G.SLASH_KKUI_ENUMFRAME2 = "/kf"

_G.SlashCmdList["KKUI_DUMPSPELL"] = function(arg)
	-- REASON: Resolves spell data for debugging icons, metadata, and descriptions.
	local name = C_Spell_GetSpellInfo(arg)
	if not name then
		print("Usage: /getspell <spellID|name>")
		return
	end

	local des = GetSpellDescription(arg)
	print(K.InfoColor .. "------------------------")
	print(" \124T" .. C_Spell_GetSpellTexture(arg) .. ":16:16:::64:64:5:59:5:59\124t", K.InfoColor .. arg)
	print(NAME, K.InfoColor .. (name or "nil"))
	print(DESCRIPTION, K.InfoColor .. (des or "nil"))
	print(K.InfoColor .. "------------------------")
end
_G.SLASH_KKUI_DUMPSPELL1 = "/getspell"
_G.SLASH_KKUI_DUMPSPELL2 = "/ks"

_G.SlashCmdList["INSTANCEID"] = function()
	-- NOTE: Displays verbose instance info including internal IDs and LFG metadata.
	local name, instanceType, difficultyID, difficultyName, maxPlayers, _, _, instanceID, groupSize, lfgID = GetInstanceInfo()
	print(K.InfoColor .. "Instance:", name or "?")
	print("Type:", tostring(instanceType), "Diff:", tostring(difficultyID) .. " (" .. (difficultyName or "?") .. ")")
	print("InstanceID:", tostring(instanceID), "Group:", tostring(groupSize or maxPlayers or "?"), "LFG:", tostring(lfgID or "-"))
end
_G.SLASH_INSTANCEID1 = "/getinstance"

_G.SlashCmdList["KKUI_NPCID"] = function()
	-- REASON: Resolves the numeric NPC ID from the target's GUID; useful for database entry.
	local name = UnitName("target")
	local guid = UnitGUID("target")
	if name and guid then
		local npcID = K.GetNPCID(guid)
		print(name, K.InfoColor .. (npcID or "nil"))
	else
		print("No unit targeted.")
	end
end
_G.SLASH_KKUI_NPCID1 = "/getnpc"
_G.SLASH_KKUI_NPCID2 = "/kknpc"
_G.SLASH_KKUI_NPCID3 = "/npcid"

_G.SlashCmdList["KKUI_GETFONT"] = function(msg)
	-- REASON: Probes global font objects to verify file paths and formatting attributes.
	local font = _G[msg]

	if not font then
		print(msg, "not found.")
		return
	end

	-- WARNING: Ensure the object is actually a FontObject before calling GetFont.
	if not font.GetFont then
		print(msg, "is not a FontObject")
		return
	end

	local a, b, c = font:GetFont()
	print(msg, a or "?", b or "?", c or "?")
end
_G.SLASH_KKUI_GETFONT1 = "/getfont"
_G.SLASH_KKUI_GETFONT2 = "/kkfont"

_G.SlashCmdList["KKUI_GET_ENCOUNTERS"] = function()
	-- REASON: Dumps boss IDs and metadata from the Encounter Journal for dungeon/raid module logic.
	if not _G.EncounterJournal then
		_G.UIParentLoadAddOn("Blizzard_EncounterJournal")
		if not _G.EncounterJournal then
			print("Encounter Journal not available.")
			return
		end
	end

	local tierID = EJ_GetCurrentTier()
	local instID = EncounterJournal.instanceID
	EJ_SelectInstance(instID)
	local instName = EJ_GetInstanceInfo()
	print(" ")
	print("TIER = " .. tierID)
	print("INSTANCE = " .. instID .. " -- " .. instName)
	print("BOSS")
	print(" ")

	local i = 0
	while true do
		i = i + 1
		local name, _, boss = EJ_GetEncounterInfoByIndex(i)
		if not name then
			return
		end

		print("BOSS = " .. boss .. " -- " .. name)
	end
end
_G.SLASH_KKUI_GET_ENCOUNTERS1 = "/getencounter"
_G.SLASH_KKUI_GET_ENCOUNTERS2 = "/getenc"
_G.SLASH_KKUI_GET_ENCOUNTERS3 = "/kkenc"

-- NOTE: Quick reference for current WoW build and Toc definitions.
_G.SlashCmdList["WOWVERSION"] = function()
	print(K.InfoColor .. "------------------------")
	K.Print("Build: ", K.WowBuild)
	K.Print("Released: ", K.WowRelease)
	K.Print("Interface: ", K.TocVersion)
	print(K.InfoColor .. "------------------------")
end
_G.SLASH_WOWVERSION1 = "/getpatch"
_G.SLASH_WOWVERSION2 = "/getbuild"
_G.SLASH_WOWVERSION3 = "/getinterface"
_G.SLASH_WOWVERSION4 = "/kkpatch"
_G.SLASH_WOWVERSION5 = "/kkbuild"
_G.SLASH_WOWVERSION6 = "/kkinterface"

-- ---------------------------------------------------------------------------
-- SLASH COMMANDS: GRID OVERLAY
-- ---------------------------------------------------------------------------

local grid
local boxSize = 32

-- REASON: Creates a visual alignment grid to assist with pixel-perfect UI positioning.
local function Grid_Create()
	grid = CreateFrame("Frame", nil, UIParent)
	grid.boxSize = boxSize
	grid:SetAllPoints(UIParent)

	local size = 2
	local width = GetScreenWidth()
	local ratio = width / GetScreenHeight()
	local height = GetScreenHeight() * ratio

	local wStep = width / boxSize
	local hStep = height / boxSize

	-- NOTE: Vertical lines; central axis is colored red for better orientation.
	for i = 0, boxSize do
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		if i == boxSize / 2 then
			tx:SetColorTexture(1, 0, 0, 0.5)
		else
			tx:SetColorTexture(0, 0, 0, 0.5)
		end
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i * wStep - (size / 2), 0)
		tx:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", i * wStep + (size / 2), 0)
	end
	height = GetScreenHeight()

	-- NOTE: Horizontal central axis.
	do
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetColorTexture(1, 0, 0, 0.5)
		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2) + (size / 2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + size / 2))
	end

	-- NOTE: Horizontal grid lines relative to center.
	for i = 1, math_floor((height / 2) / hStep) do
		local tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetColorTexture(0, 0, 0, 0.5)

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 + i * hStep) + (size / 2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 + i * hStep + size / 2))

		tx = grid:CreateTexture(nil, "BACKGROUND")
		tx:SetColorTexture(0, 0, 0, 0.5)

		tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height / 2 - i * hStep) + (size / 2))
		tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height / 2 - i * hStep + size / 2))
	end
end

local function Grid_Show()
	-- NOTE: Lazy creation; recreates grid if boxSize changes to update texture geometry.
	if not grid then
		Grid_Create()
	elseif grid.boxSize ~= boxSize then
		grid:Hide()
		Grid_Create()
	else
		grid:Show()
	end
end

local isAligning = false
SlashCmdList["KKUI_TOGGLEGRID"] = function(arg)
	if isAligning or arg == "1" then
		if grid then
			grid:Hide()
		end
		isAligning = false
	else
		-- REASON: Snaps box size to multiples of 32 for cleaner grid scaling.
		boxSize = (math_ceil((tonumber(arg) or boxSize) / 32) * 32)
		if boxSize > 256 then
			boxSize = 256
		end
		Grid_Show()
		isAligning = true
	end
end
_G.SLASH_KKUI_TOGGLEGRID1 = "/showgrid"
_G.SLASH_KKUI_TOGGLEGRID2 = "/align"
_G.SLASH_KKUI_TOGGLEGRID3 = "/grid"
_G.SLASH_KKUI_TOGGLEGRID4 = "/kkgrid"

-- ---------------------------------------------------------------------------
-- SLASH COMMANDS: BLIZZARD DEBUG TOOLS
-- ---------------------------------------------------------------------------

-- NOTE: Developer shortcuts; these interact with internal Blizzard debug CVars and frames.

-- REASON: Taint logging is essential for tracing secure UI errors; logs to Logs/taint.log.
SlashCmdList["KKUI_TAINTLOG"] = function(msg)
	local input = (msg or ""):match("^%s*(.-)%s*$"):lower()
	if input == "get" or input == "" then
		local current = tonumber(_G.GetCVar("taintLog")) or 0
		print(K.InfoColor .. "taintLog = " .. tostring(current))
		return
	end

	local map = { off = 0, on = 2, ["0"] = 0, ["1"] = 1, ["2"] = 2, ["11"] = 11 }
	local level = map[input]
	if level == nil then
		print("Usage: /taintlog 0|1|2|11 or /taintlog on|off or /taintlog get")
		return
	end

	_G.SetCVar("taintLog", tostring(level))
	local now = tonumber(_G.GetCVar("taintLog")) or 0
	print(K.InfoColor .. "taintLog set to " .. tostring(now) .. "; log writes to Logs/taint.log (on logout or periodically)")
end
_G.SLASH_KKUI_TAINTLOG1 = "/taintlog"
_G.SLASH_KKUI_TAINTLOG2 = "/taint"
_G.SLASH_KKUI_TAINTLOG3 = "/kktaint"

-- REASON: Wraps Blizzard's FrameStack tool for easier access via multiple aliases.
SlashCmdList["KKUI_FSTACK"] = function(msg)
	if not _G.FrameStackTooltip then
		_G.UIParentLoadAddOn("Blizzard_DebugTools")
	end

	local handler = _G.SlashCmdList and (_G.SlashCmdList.FRAMESTACK or _G.SlashCmdList.FSTACK)
	if handler then
		handler(msg or "")
		print(K.InfoColor .. "FrameStack toggled. Hold SHIFT for texture info. ALT cycles.")
	else
		print("FrameStack not available.")
	end
end
_G.SLASH_KKUI_FSTACK1 = "/kkfstack"
_G.SLASH_KKUI_FSTACK2 = "/kkfs"
_G.SLASH_KKUI_FSTACK3 = "/kkstack"
_G.SLASH_KKUI_FSTACK4 = "/fstack"
_G.SLASH_KKUI_FSTACK5 = "/framestack"

-- REASON: Wraps Blizzard's EventTrace tool for easier access and marker insertion.
SlashCmdList["KKUI_ETRACE"] = function(msg)
	local function ensure()
		-- NOTE: Blizzard moved EventTrace across different modules in recent patches.
		if not (_G.EventTrace or _G.EventTraceFrame) then
			_G.UIParentLoadAddOn("Blizzard_EventTrace")
			if not (_G.EventTrace or _G.EventTraceFrame) then
				_G.UIParentLoadAddOn("Blizzard_DebugTools")
			end
		end
	end

	ensure()

	local txt = (msg or ""):match("^%s*(.-)%s*$")
	local sl = _G.SlashCmdList
	if sl and (sl.EVENTTRACE or sl.ETRACE) then
		local fn = sl.EVENTTRACE or sl.ETRACE
		fn(txt)
	else
		-- NOTE: Support both old (Retail) and newer C-API toggles if possible.
		if _G.EventTrace and _G.EventTrace.Toggle then
			_G.EventTrace:Toggle()
		elseif _G.EventTrace then
			_G.EventTrace:TogglePause()
		else
			print("EventTrace not available.")
			return
		end
	end

	if txt == "" then
		print(K.InfoColor .. "EventTrace toggled. Use '/kkeventtrace mark <text>' to insert a marker.")
	end
end
_G.SLASH_KKUI_ETRACE1 = "/kkeventtrace"
_G.SLASH_KKUI_ETRACE2 = "/kket"
_G.SLASH_KKUI_ETRACE3 = "/eventtrace"
_G.SLASH_KKUI_ETRACE4 = "/etrace"
