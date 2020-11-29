local K, C = unpack(select(2, ...))
local Module = K:NewModule("Infobar")

function Module:OnEnable()
	Module.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
	Module.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t "
	Module.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "
	Module.AFKTex = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
	Module.DNDTex = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"

	self:CreateGoldDataText()
	self:CreateSystemDataText()
	self:CreateLatencyDataText()
	self:CreateLocationDataText()
	self:CreateTimeDataText()
end