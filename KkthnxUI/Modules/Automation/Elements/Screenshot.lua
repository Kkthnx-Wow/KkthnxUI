--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically takes a screenshot when the player earns a new achievement.
-- - Design: Hooks ACHIEVEMENT_EARNED and uses C_Timer.After for a clean 1-second delay.
-- - Events: ACHIEVEMENT_EARNED
-----------------------------------------------------------------------------]]

local K, C = _G["KkthnxUI"][1], _G["KkthnxUI"][2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local C_Timer_After = C_Timer.After

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
-- REASON: Resolve Screenshot() at call time behind a guard. Not every client/server exposes the
-- global Screenshot API; passing the raw global straight to C_Timer.After means a nil callback,
-- which errors with "bad argument #2 to '?' (Usage: C_Timer.After(seconds, callback))".
local function takeScreenshot()
	local screenshot = _G.Screenshot
	if screenshot then
		screenshot()
	end
end

local function screenshotOnEvent(_, _, alreadyEarnedOnAccount)
	-- REASON: Only take screenshots for achievements earned for the first time by the character/account.
	if alreadyEarnedOnAccount then
		return
	end

	-- PERF: C_Timer.After replaces the old OnUpdate-based delay pattern, eliminating a hidden
	-- frame that ran every frame for 1 second just to fire a single Screenshot() call.
	C_Timer_After(1, takeScreenshot)
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoScreenshot()
	-- REASON: Feature entry point; registers for achievement events based on user configuration.
	if C["Automation"].AutoScreenshot then
		K:RegisterEvent("ACHIEVEMENT_EARNED", screenshotOnEvent)
	else
		K:UnregisterEvent("ACHIEVEMENT_EARNED", screenshotOnEvent)
	end
end
