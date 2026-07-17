--[[-----------------------------------------------------------------------------
-- Live GUI refresh for skin / font tweak settings.
-- Only keys with a real live path register here — addon/Blizzard skin toggles
-- require /reload (CreateSwitch ..., requiresReload = true) so HasSettingLiveUpdate
-- stays honest.
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

K:RegisterSettingCallback("Skins.ChatBubbleAlpha", UpdateChatBubbleAlpha)
K:RegisterSettingCallback("Skins.QuestFontSize", function()
	Module:UpdateQuestFonts()
end)
K:RegisterSettingCallback("Skins.ObjectiveFontSize", function()
	Module:UpdateObjectiveFonts()
end)
K:RegisterSettingCallback("Skins.BigDebuffs", function()
	Module:SetBigDebuffsEnabled(C["Skins"].BigDebuffs)
end)
