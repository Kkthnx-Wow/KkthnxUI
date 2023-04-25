local K = KkthnxUI[1]
local Module = K:NewModule("DataText")

function Module:OnEnable()
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
	}

	for _, funcName in ipairs(loadDataTextModules) do
		pcall(self[funcName], self)
	end
end
