local K = KkthnxUI[1]
local Module = K:NewModule("DataText")

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

function Module:OnEnable()
	self.CheckLoginTime = GetTime()

	for _, funcName in ipairs(loadDataTextModules) do
		if self[funcName] then
			self[funcName](self)
		end
	end
end
