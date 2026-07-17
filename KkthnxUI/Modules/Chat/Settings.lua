--[[-----------------------------------------------------------------------------
-- Live GUI refresh for chat frame settings.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local _G = _G

local FILTER_KEYS = {
	Emojis = "UpdateEmojis",
	ChatItemLevel = "UpdateChatItemLevels",
	LootIcons = "UpdateLootIcons",
	HighlightPlayer = "UpdateChatHighlight",
	HighlightGuild = "UpdateChatHighlight",
}

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
		if Module.UpdateChatHighlight then
			Module:UpdateChatHighlight()
		end
	elseif key == "CopyButton" or key == "ConfigButton" or key == "RollButton" or key == "ChatMenu" then
		if Module.UpdateChatButtons then
			Module:UpdateChatButtons()
		end
		if key == "ChatMenu" then
			local menu = _G.KKUI_ChatMenu
			if menu then
				menu:SetShown(C["Chat"].ChatMenu)
			end
		end
	elseif key == "Sticky" then
		Module:ChatWhisperSticky()
	elseif key == "UrlLinks" then
		if Module.ToggleCopyURL then
			Module:ToggleCopyURL()
		end
	elseif FILTER_KEYS[key] then
		local method = FILTER_KEYS[key]
		if Module[method] then
			Module[method](Module)
		end
	end
end

K:RegisterSettingPrefixCallback("Chat.", OnChatSetting)
