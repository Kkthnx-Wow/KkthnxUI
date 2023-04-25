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
		pcall(self[funcName], self)
	end
end
