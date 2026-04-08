--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Main entry point for the DataText module, managing initialization and loading of elements.
-- - Design: Dynamically executes registration functions for each DataText component.
-- - Events: N/A (Module enabled during KkthnxUI initialization)
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:NewModule("DataText")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local GetTime = GetTime
local error = error
local ipairs = ipairs
local pcall = pcall
local tostring = tostring
local type = type

function Module:OnEnable()
	-- REASON: Record the login time for session-based calculations (e.g., gold per hour).
	self.CheckLoginTime = GetTime()

	local loadDataTextModules = {
		"CreateDurabilityDataText",
		"CreateGoldDataText",
		"CreateGuildDataText",
		"CreateSystemDataText",
		"CreateLatencyDataText",
		"CreateLocationDataText",
		"CreateSocialDataText",
		"CreateTimeDataText",
		"CreateCoordsDataText",
		"CreateSpecDataText",
	}

	-- REASON: Iterate through and safely execute each element registration function.
	for _, funcName in ipairs(loadDataTextModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			-- WARNING: Ensure that failure in one element does not block the entire module's initialization.
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
