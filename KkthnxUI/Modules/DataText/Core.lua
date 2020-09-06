local K = unpack(select(2, ...))
local Module = K:NewModule("Infobar")

function Module:OnEnable()
	self:CreateCurrencyDataText()
	self:CreateGuildDataText()
	self:CreateLocationDataText()
	self:CreateSocialDataText()
	self:CreateSystemDataText()
	self:CreateLatencyDataText()
	self:CreateTimeDataText()
end