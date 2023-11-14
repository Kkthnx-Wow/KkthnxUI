local K = KkthnxUI[1]
local Module = K:NewModule("Blizzard")

function Module:OnEnable()
	local loadBlizzardModules = {
		"CreateAlertFrames",
		"CreateAltPowerbar",
		"CreateColorPicker",
		"CreateMirrorBars",
		"CreateObjectiveFrame",
		"CreateOrderHallIcon",
		"CreateTimerTracker",
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
