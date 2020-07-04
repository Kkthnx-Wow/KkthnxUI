local K = unpack(select(2, ...))
local Module = K:NewModule("Infobar")

function Module:OnEnable()
	-- self:CreateQuickJoinDataText()
	self:CreateCurrencyDataText()
	self:CreateGuildDataText()
	self:CreateLocationDataText()
	self:CreateSocialDataText()
	self:CreateSystemDataText()
	self:CreateTimeDataText()
end