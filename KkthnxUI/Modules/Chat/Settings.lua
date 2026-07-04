--[[-----------------------------------------------------------------------------
-- Live GUI refresh for chat frame settings.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Chat")

local function OnChatSetting(configPath)
	local key = configPath:match("^Chat%.(.+)$")
	if not key then
		return
	end

	if key == "Background" then
		Module:ToggleChatBackground()
	elseif key == "Height" or key == "Width" or key == "Lock" then
		if key == "Lock" then
			Module:UpdateChatLock()
		else
			Module:UpdateChatSize()
		end
	elseif key == "LogMax" then
		Module:onLogMaxChanged()
	elseif key == "Fading" or key == "FadingTimeVisible" then
		Module:UpdateChatFading()
	elseif key == "Freedom" then
		Module:UpdateChatFreedom()
	elseif key == "Enable" then
		Module:SetChatEnabled(C["Chat"].Enable)
	elseif key == "CopyButton" or key == "ConfigButton" or key == "RollButton" then
		if Module.UpdateChatButtons then
			Module:UpdateChatButtons()
		end
	end
end

K:RegisterSettingPrefixCallback("Chat.", OnChatSetting)
