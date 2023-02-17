local K = KkthnxUI[1]
local Module = K:NewModule("DataText")

function Module:OnEnable()
	self.CheckLoginTime = GetTime()

	self:CreateDurabilityDataText()
	self:CreateGoldDataText()
	self:CreateGuildDataText()
	self:CreateSystemDataText()
	self:CreateLatencyDataText()
	self:CreateLocationDataText()
	self:CreateSocialDataText()
	self:CreateTimeDataText()
	self:CreateCoordsDataText()
end
