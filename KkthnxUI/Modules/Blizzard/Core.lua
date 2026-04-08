--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Main entry point for Blizzard UI enhancements and modifications.
-- - Design: Dynamically loads Blizzard-related element modules.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:NewModule("Blizzard")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local error = error
local ipairs = ipairs
local pcall = pcall
local tostring = tostring
local type = type

-- ---------------------------------------------------------------------------
-- Module Loading
-- ---------------------------------------------------------------------------
function Module:OnEnable()
	local loadBlizzardModules = {
		"CreateAlertFrames",
		"CreateAltPowerbar",
		"CreateColorPicker",
		"CreateMirrorBars",
		-- "CreateObjectiveFrame", -- REASON: Currently disabled or handled elsewhere.
		"CreateOrderHallIcon",
		"CreateTimerTracker",
		"CreateTutorialDisabling",
		"CreateUIWidgets",
	}

	for _, funcName in ipairs(loadBlizzardModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
