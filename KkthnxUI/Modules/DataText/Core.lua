local K = unpack(select(2, ...))
local Module = K:NewModule("Infobar")

function Module:OnEnable()
	self:CreateGoldDataText()
	self:CreateGuildDataText()
	self:CreateSystemDataText()
	self:CreateLatencyDataText()
	self:CreateLocationDataText()
	self:CreateSocialDataText()
	self:CreateTimeDataText()
	self:CreateCoordsDataText()
end