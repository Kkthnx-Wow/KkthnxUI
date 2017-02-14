local K, C, L = unpack(select(2, ...))
if C.Chat.Enable ~= true then return end

-- Lua API
local _G = _G

-- Wow API
local hooksecurefunc = _G.hooksecurefunc
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA, CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA
-- GLOBALS: CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA, CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA
-- GLOBALS: CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA, CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA
-- GLOBALS: SELECTED_CHAT_FRAME

local function UpdateTab(self)
	if (self:GetObjectType() ~= "Button") then
		self = _G[self:GetName() .. "Tab"]
	end

	local tab = self.fontString
	if (tab) then
		if(self:IsMouseOver()) then
			tab:SetTextColor(K.Color.r, K.Color.g, K.Color.b)
		elseif(self.alerting) then
			tab:SetTextColor(1, 0, 0)
		elseif(self:GetID() == SELECTED_CHAT_FRAME:GetID()) then
			tab:SetTextColor(K.Color.r, K.Color.g, K.Color.b)
		else
			tab:SetTextColor(0.8, 0.8, 0.8)
		end
	end
end

local SetupTabs = CreateFrame("Frame")
SetupTabs:RegisterEvent("PLAYER_LOGIN")
SetupTabs:SetScript("OnEvent", function()
	for i = 1, NUM_CHAT_WINDOWS do
		local tab = _G["ChatFrame"..i.."Tab"]

		tab.fontString = tab:GetFontString()
		if C.Chat.TabsOutline == true then
			tab.fontString:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
			tab.fontString:SetShadowOffset(0, -0)
		else
			tab.fontString:SetFont(C.Media.Font, C.Media.Font_Size)
			tab.fontString:SetShadowOffset(K.Mult, -K.Mult)
		end

		tab.leftTexture:SetTexture(nil)
		tab.middleTexture:SetTexture(nil)
		tab.rightTexture:SetTexture(nil)

		tab.leftHighlightTexture:SetTexture(nil)
		tab.middleHighlightTexture:SetTexture(nil)
		tab.rightHighlightTexture:SetTexture(nil)

		tab.leftSelectedTexture:SetTexture(nil)
		tab.middleSelectedTexture:SetTexture(nil)
		tab.rightSelectedTexture:SetTexture(nil)

		if (tab.conversationIcon) then
			tab.conversationIcon:Kill()
		end

		tab:HookScript("OnEnter", UpdateTab)
		tab:HookScript("OnLeave", UpdateTab)
		UpdateTab(tab)
	end

	if C.Chat.TabsMouseover == true then
		CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
		CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
		CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 0.7
	else
		CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 1
		CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0.7
		CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
	end

	hooksecurefunc("FCFTab_UpdateColors", UpdateTab)
	hooksecurefunc("FCF_StartAlertFlash", UpdateTab)
	hooksecurefunc("FCF_FadeOutChatFrame", UpdateTab)
end)