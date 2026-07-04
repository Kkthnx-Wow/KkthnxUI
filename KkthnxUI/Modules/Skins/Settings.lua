--[[-----------------------------------------------------------------------------
-- Live GUI refresh for skin / font tweak settings.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

local _G = _G
local pairs = pairs

local function UpdateChatBubbleAlpha()
	if not C_ChatBubbles or not C_ChatBubbles.GetAllChatBubbles then
		return
	end

	local backdrop = C["Media"].Backdrops.ColorBackdrop
	local alpha = C["Skins"].ChatBubbleAlpha

	for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
		if chatBubble.KKUI_Background then
			chatBubble.KKUI_Background:SetVertexColor(backdrop[1], backdrop[2], backdrop[3], alpha)
		end
	end
end

local function OnSkinsSetting(configPath)
	if configPath == "Skins.ChatBubbleAlpha" then
		UpdateChatBubbleAlpha()
	elseif configPath == "Skins.QuestFontSize" then
		Module:UpdateQuestFonts()
	elseif configPath == "Skins.ObjectiveFontSize" then
		Module:UpdateObjectiveFonts()
	elseif configPath == "Skins.BigDebuffs" then
		Module:SetBigDebuffsEnabled(C["Skins"].BigDebuffs)
	end
end

K:RegisterSettingPrefixCallback("Skins.", OnSkinsSetting)
