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
	self._appearanceRefreshers = self._appearanceRefreshers or {}

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

function Module:RegisterAppearanceRefresher(fn)
	if type(fn) ~= "function" then
		return
	end
	self._appearanceRefreshers = self._appearanceRefreshers or {}
	self._appearanceRefreshers[#self._appearanceRefreshers + 1] = fn
end

function Module:RefreshAppearance()
	local list = self._appearanceRefreshers
	if not list then
		return
	end
	for i = 1, #list do
		list[i]()
	end
end

local PANEL_CREATORS = {
	System = "CreateSystemDataText",
	Latency = "CreateLatencyDataText",
	Gold = "CreateGoldDataText",
	Guild = "CreateGuildDataText",
	Friends = "CreateSocialDataText",
	Location = "CreateLocationDataText",
	Time = "CreateTimeDataText",
	Coords = "CreateCoordsDataText",
	Spec = "CreateSpecDataText",
}

function Module:RefreshDataTextPanel(key)
	local createName = PANEL_CREATORS[key]
	if not createName then
		return
	end

	local createFn = self[createName]
	if type(createFn) ~= "function" then
		return
	end

	local success, err = pcall(createFn, self)
	if not success then
		error("Error in function " .. createName .. ": " .. tostring(err), 2)
	end

	if key == "Location" and self.UpdateLocationTextVisibility then
		self:UpdateLocationTextVisibility()
	elseif key == "System" then
		self:RefreshDataTextPanel("Latency")
	end
end
