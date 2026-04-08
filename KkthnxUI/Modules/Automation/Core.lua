--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Main entry point for the Automation module, handles loading of various sub-features.
-- - Design: Dispatches Create calls for all registered automation elements.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:NewModule("Automation")

-- PERF: Localize globals to reduce lookup overhead.
local error = error
local ipairs = ipairs
local pcall = pcall
local tostring = tostring
local type = type

-- REASON: Dynamically invokes initialization functions for sub-modules to keep Core light.
function Module:OnEnable()
	local loadAutomationModules = {
		"CreateAutoAcceptSummon",
		"CreateAutoBadBuffs",
		"CreateAutoBestReward",
		"CreateAutoDeclineDuels",
		"CreateAutoDelves",
		"CreateAutoGoodbye",
		"CreateAutoInvite",
		"CreateAutoKeystone",
		"CreateAutoPartySyncAccept",
		"CreateAutoRelease",
		"CreateAutoResurrect",
		"CreateAutoHideTracker",
		"CreateAutoScreenshot",
		"CreateAutoSetRole",
		"CreateAutoWhisperInvite",
		"CreateSkipCinematic",
	}

	for _, funcName in ipairs(loadAutomationModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
