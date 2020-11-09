local K, C = unpack(select(2, ...))
local Module = K:NewModule("Infobar")

-- local _G = _G
-- local table_insert = _G.table.insert

-- function Module:RegisterInfobar(name, point, outline)
-- 	if not Module.Modules then
-- 		Module.Modules = {}
-- 	end

-- 	local info = CreateFrame("Frame", nil, UIParent)
-- 	info:SetFrameLevel(point[2]:GetFrameLevel() + 6)
-- 	-- info:SetHitRectInsets(0, 0, -10, -10)
-- 	info.text = K.CreateFontString(info, 12, nil, outline)
-- 	info.text:ClearAllPoints()
-- 	info.text:SetPoint(unpack(point))
-- 	info:SetAllPoints(info.text)
-- 	info.name = name
-- 	info.outline = outline
-- 	table_insert(Module.Modules, info)

-- 	return info
-- end

-- function Module:LoadInfobar(info)
-- 	if info.eventList then
-- 		for _, event in pairs(info.eventList) do
-- 			info:RegisterEvent(event)
-- 		end
-- 		info:SetScript("OnEvent", info.onEvent)
-- 	end

-- 	if info.onEnter then
-- 		info:SetScript("OnEnter", info.onEnter)
-- 	end

-- 	if info.onLeave then
-- 		info:SetScript("OnLeave", info.onLeave)
-- 	end

-- 	if info.onMouseUp then
-- 		info:SetScript("OnMouseUp", info.onMouseUp)
-- 	end

-- 	if info.onUpdate then
-- 		info:SetScript("OnUpdate", info.onUpdate)
-- 	end
-- end

function Module:OnEnable()
	-- if not Module.Modules then
	-- 	return
	-- end

	-- Module.LeftButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "
	-- Module.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:410|t "
	-- Module.ScrollButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "
	-- Module.AFKTex = "|T"..FRIENDS_TEXTURE_AFK..":14:14:0:0:16:16:1:15:1:15|t"
	-- Module.DNDTex = "|T"..FRIENDS_TEXTURE_DND..":14:14:0:0:16:16:1:15:1:15|t"

	-- for _, info in pairs(Module.Modules) do
	-- 	Module:LoadInfobar(info)
	-- end

	-- Module.loginTime = GetTime()

	-- self:CreateGuildDataText()
	self:CreateLocationDataText()
	-- self:CreateSocialDataText()
	self:CreateSystemDataText()
	self:CreateLatencyDataText()
	self:CreateTimeDataText()
end