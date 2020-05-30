local K = unpack(select(2, ...))
local Module = K:NewModule("Infobar")

function Module:OnEnable()
	self:CreateCurrencyDataText()
	self:CreateGuildDataText()
	-- self:CreateQuickJoinDataText()
	self:CreateSocialDataText()
	self:CreateSystemDataText()
	self:CreateTimeDataText()
end