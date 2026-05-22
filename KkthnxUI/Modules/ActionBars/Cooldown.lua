--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: High-performance cooldown timer replacement using Blizzard's native
--   numeric formatter API (C_StringUtil.CreateNumericRuleFormatter).
-- - Design: Hooks the cooldown frame metatable to attach a shared formatter with
--   configurable breakpoints and color modes, chosen from four presets plus a
--   Disabled option. The old manual OnUpdate timer loop has been removed in
--   favour of SetCountdownFormatter, which offloads rendering to the engine.
-- - Requires: C["ActionBar"]["CDFormat"] (1-5); 5 = Disabled.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache commonly used globals to avoid repeated table lookups.
local pairs = pairs
local SetCVar = _G.SetCVar

-- NOTE: Index 5 is the sentinel value that disables the custom formatter entirely.
local DISABLE_INDEX = 5

-- Shared numeric formatter instance – one per session, reused for all cooldowns.
local numberFormatter = C_StringUtil.CreateNumericRuleFormatter()

-- Registry of every cooldown frame we have injected the formatter into.
-- Keyed by the cooldown frame object so we only touch each frame once.
local hookedCooldownFrames = {}

-- ---------------------------------------------------------------------------
-- BREAKPOINT CONSTANTS
-- ---------------------------------------------------------------------------

local ROUNDING_UP      = Enum.NumericRuleFormatRounding.Up
local ROUNDING_NEAREST = Enum.NumericRuleFormatRounding.Nearest

-- Color objects used for urgent / warning / stable second ranges.
local COLOR_RED    = CreateColor(1,   0,   0,   1)  -- < 3 s
local COLOR_YELLOW = CreateColor(1,   1,   0,   1)  -- < 10 s
local COLOR_DARK   = CreateColor(0.8, 0.8, 0.2, 1)  -- < 60 s

-- ---------------------------------------------------------------------------
-- BREAKPOINT TABLE
-- Helper: K.MyClassColor is a "|cffRRGGBB" prefix for the player's class color.
-- It is set during PLAYER_LOGIN by Init.lua and is safe to read at module load time
-- only if the module enables on PLAYER_LOGIN. We use a builder function so the
-- string is resolved after K.MyClassColor is populated.
-- ---------------------------------------------------------------------------

-- NOTE: Build breakpoints lazily so K.MyClassColor is fully resolved at call time.
local function BuildBreakPoints()
	local myColor = K.MyClassColor  -- resolved |cffRRGGBB prefix, e.g. "|cff00ccff"

	return {
		-- Mode 1 – Colored with tenths: shows %.1f below 3 s, whole seconds up to
		-- 10 s, then mm:ss, then compact labeled units in class color.
		[1] = {
			{ threshold = 0,       format = COLOR_RED:WrapTextInColorCode("%.1f"),  components = { { step = 0.1, rounding = ROUNDING_UP } } },
			{ threshold = 3,       format = COLOR_YELLOW:WrapTextInColorCode("%d"), components = { { div = 1, step = 1, rounding = ROUNDING_UP } } },
			{ threshold = 10,      format = COLOR_DARK:WrapTextInColorCode("%d"),   components = { { div = 1, step = 1, rounding = ROUNDING_UP } } },
			{ threshold = 60,      format = "%d:%02d",                              components = { { div = 60 }, { mod = 60 } } },
			{ threshold = 60 * 10, format = "%d" .. myColor .. "m|r",              components = { { div = 60,   step = 1, rounding = ROUNDING_NEAREST } } }, -- 10 min
			{ threshold = 3600 * 2,format = "%d" .. myColor .. "h|r",              components = { { div = 3600, step = 1, rounding = ROUNDING_NEAREST } } }, -- 2 hr
			{ threshold = 86400,   format = "%d" .. myColor .. "d|r",              components = { { div = 86400,step = 1, rounding = ROUNDING_NEAREST } } }, -- 1 day
		},

		-- Mode 2 – Colored without tenths: same ranges as mode 1 but uses whole
		-- seconds even below 3 s (less visual noise for some players).
		[2] = {
			{ threshold = 0,       format = COLOR_RED:WrapTextInColorCode("%d"),    components = { { div = 1, step = 1, rounding = ROUNDING_UP } } },
			{ threshold = 3,       format = COLOR_YELLOW:WrapTextInColorCode("%d"), components = { { div = 1, step = 1, rounding = ROUNDING_UP } } },
			{ threshold = 10,      format = COLOR_DARK:WrapTextInColorCode("%d"),   components = { { div = 1, step = 1, rounding = ROUNDING_UP } } },
			{ threshold = 60,      format = "%d:%02d",                              components = { { div = 60 }, { mod = 60 } } },
			{ threshold = 60 * 10, format = "%d" .. myColor .. "m|r",              components = { { div = 60,   step = 1, rounding = ROUNDING_NEAREST } } },
			{ threshold = 3600 * 2,format = "%d" .. myColor .. "h|r",              components = { { div = 3600, step = 1, rounding = ROUNDING_NEAREST } } },
			{ threshold = 86400,   format = "%d" .. myColor .. "d|r",              components = { { div = 86400,step = 1, rounding = ROUNDING_NEAREST } } },
		},

		-- Mode 3 – Plain with tenths: no color, tenths below 3 s, plain labels.
		[3] = {
			{ threshold = 0,       format = "%.1f",    components = { { step = 0.1, rounding = ROUNDING_UP } } },
			{ threshold = 3,       format = "%d",      components = { { div = 1, step = 1, rounding = ROUNDING_UP } } },
			{ threshold = 60,      format = "%d:%02d", components = { { div = 60 }, { mod = 60 } } },
			{ threshold = 60 * 10, format = "%dm",     components = { { div = 60,   step = 1, rounding = ROUNDING_NEAREST } } },
			{ threshold = 3600 * 2,format = "%dh",     components = { { div = 3600, step = 1, rounding = ROUNDING_NEAREST } } },
			{ threshold = 86400,   format = "%dd",     components = { { div = 86400,step = 1, rounding = ROUNDING_NEAREST } } },
		},

		-- Mode 4 – Plain whole-seconds only: simplest preset, no color or tenths.
		[4] = {
			{ threshold = 0,       format = "%d",      components = { { div = 1, step = 1, rounding = ROUNDING_UP } } },
			{ threshold = 60,      format = "%d:%02d", components = { { div = 60 }, { mod = 60 } } },
			{ threshold = 60 * 10, format = "%dm",     components = { { div = 60,   step = 1, rounding = ROUNDING_NEAREST } } },
			{ threshold = 3600 * 2,format = "%dh",     components = { { div = 3600, step = 1, rounding = ROUNDING_NEAREST } } },
			{ threshold = 86400,   format = "%dd",     components = { { div = 86400,step = 1, rounding = ROUNDING_NEAREST } } },
		},
	}
end

-- ---------------------------------------------------------------------------
-- INTERNAL HELPERS
-- ---------------------------------------------------------------------------

-- REASON: Called once per cooldown frame to attach (or remove) our formatter.
-- The hookedCooldownFrames guard ensures we only call SetCountdownFormatter once
-- per frame – subsequent hook fires for the same frame are skipped.
local function ApplyFormatterToCooldown(cooldown)
	if not cooldown or hookedCooldownFrames[cooldown] then
		return
	end

	local isEnabled = C["ActionBar"]["CDFormat"] ~= DISABLE_INDEX
	cooldown:SetCountdownFormatter(isEnabled and numberFormatter or nil)
	hookedCooldownFrames[cooldown] = true
end

-- ---------------------------------------------------------------------------
-- MODULE PUBLIC API
-- ---------------------------------------------------------------------------

-- REASON: Re-applies the breakpoints to the shared formatter without touching
-- the hooked frames. Called when only the mode changes but the formatter is
-- already injected everywhere.
function Module:UpdateCooldownBreakPoints()
	local mode = C["ActionBar"]["CDFormat"]
	if mode == DISABLE_INDEX then
		return
	end

	local breakPoints = BuildBreakPoints()
	numberFormatter:SetBreakpoints(breakPoints[mode])
end

-- REASON: Full refresh – updates the CVar, rebuilds breakpoints, and propagates
-- the formatter (or nil) to every previously hooked cooldown frame.
-- Triggered by the GUI config dropdown callback.
function Module:UpdateCooldownFormat()
	local mode = C["ActionBar"]["CDFormat"]

	if mode == DISABLE_INDEX then
		-- User disabled custom cooldowns; turn off Blizzard's native numbers too.
		SetCVar("countdownForCooldowns", 0)
		for cooldown in pairs(hookedCooldownFrames) do
			cooldown:SetCountdownFormatter(nil)
		end
		return
	end

	-- Ensure Blizzard renders countdown numbers (required for SetCountdownFormatter).
	SetCVar("countdownForCooldowns", 1)

	local breakPoints = BuildBreakPoints()
	numberFormatter:SetBreakpoints(breakPoints[mode])

	-- Propagate updated formatter to all already-hooked frames.
	for cooldown in pairs(hookedCooldownFrames) do
		cooldown:SetCountdownFormatter(numberFormatter)
	end
end

-- ---------------------------------------------------------------------------
-- INITIALIZATION
-- ---------------------------------------------------------------------------

function Module:OnEnableCooldown()
	-- REASON: Build and apply initial breakpoints before any hooks fire so the
	-- first frame that gets hooked already has the correct formatter state.
	Module:UpdateCooldownBreakPoints()

	-- REASON: Hook the cooldown frame metatable so every cooldown frame (current
	-- and future) receives our formatter when any of these methods are called.
	-- Using the metatable means we catch frames created by any AddOn, not just
	-- Blizzard action buttons.
	local cooldownMeta = getmetatable(ActionButton1Cooldown).__index
	local methods = {
		"SetCooldown",
		"SetCooldownDuration",
		"SetHideCountdownNumbers",
		"SetCooldownFromDurationObject",
	}
	for _, method in pairs(methods) do
		hooksecurefunc(cooldownMeta, method, ApplyFormatterToCooldown)
	end

	-- NOTE: Also hook the percentage-display helper so bars that switch to
	-- percentage mode are cleanly removed from our formatter.
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", ApplyFormatterToCooldown)

	-- Apply the CVar state based on the current config value.
	local isEnabled = C["ActionBar"]["CDFormat"] ~= DISABLE_INDEX
	SetCVar("countdownForCooldowns", isEnabled and 1 or 0)
end
