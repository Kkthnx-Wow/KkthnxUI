local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateChatCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local chatIcon = "Interface\\Icons\\Ui_chat"
	local chatCategory = GUI:AddCategory(L["Chat"], chatIcon, "Chat")

	-- General
	local generalChatSection = GUI:AddSection(chatCategory, GENERAL)
	GUI:CreateSwitch(generalChatSection, "Chat.Enable", enableTextColor .. L["Enable Chat"], L["Enable Desc"])
	GUI:CreateSwitch(generalChatSection, "Chat.Lock", L["Lock Chat"], L["Lock Desc"])
	GUI:CreateSwitch(generalChatSection, "Chat.Background", L["Show Chat Background"], L["Background Desc"])
	local channelAbbrOptions = {
		{ text = DISABLE, value = 1 },
		{ text = L["Short Names"], value = 2 },
		{ text = L["Localized Short Names"], value = 3 },
	}
	GUI:CreateDropdown(generalChatSection, "Chat.ChannelAbbr", L["Channel Abbreviations"], channelAbbrOptions, L["ChannelAbbr Desc"])

	-- Appearance
	local appearanceChatSection = GUI:AddSection(chatCategory, L["Appearance"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.Emojis", L["Show Emojis In Chat"] .. " |TInterface\\Addons\\KkthnxUI\\Media\\Chat\\Emojis\\StuckOutTongueClosedEyes:0:0:4|t", L["Emojis Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.LootIcons", L["Show Loot Icons"], L["Chat.LootIcons Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.ChatItemLevel", L["Show ItemLevel on ChatFrames"], L["ChatItemLevel Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.CopyButton", "Show Copy Chat Button |TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:14:14|t", L["Chat.CopyButton Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.ConfigButton", "Show Config Button |TInterface\\Buttons\\UI-OptionsButton:14:14|t", L["Chat.ConfigButton Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.RollButton", "Show Roll Button |A:charactercreate-icon-dice:14:14|a", L["Chat.RollButton Desc"])

	-- Timestamp Format
	local timestampOptions = {
		{ text = "Disable", value = 1 },
		{ text = "03:27 PM", value = 2 },
		{ text = "03:27:32 PM", value = 3 },
		{ text = "15:27", value = 4 },
		{ text = "15:27:32", value = 5 },
	}
	GUI:CreateDropdown(appearanceChatSection, "Chat.TimestampFormat", L["Custom Chat Timestamps"], timestampOptions, L["TimestampFormat Desc"])

	-- Behavior
	local behaviorChatSection = GUI:AddSection(chatCategory, L["Behavior"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.Freedom", L["Disable Chat Language Filter"], L["Freedom Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.ChatMenu", L["Show Chat Menu Buttons"], L["ChatMenu Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.Sticky", L["Stick On Channel If Whispering"], L["Sticky Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.WhisperColor", L["Differ Whisper Colors"], L["Chat.WhisperColor Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.HighlightPlayer", L["Highlight Your Name"], L["Highlight Your Name Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.HighlightGuild", L["Highlight Guild Tags"], L["Highlight Guild Tags Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.UrlLinks", L["Clickable Chat URLs"], L["Chat.UrlLinks Desc"])
	local urlPopupSwitch = GUI:CreateSwitch(behaviorChatSection, "Chat.UrlPopup", L["URL Copy Popup"], L["Chat.UrlPopup Desc"])
	GUI:DependsOn(urlPopupSwitch, "Chat.UrlLinks", true)

	-- Sizes
	local sizesChatSection = GUI:AddSection(chatCategory, L["Sizes"])
	GUI:CreateSlider(sizesChatSection, "Chat.Height", L["Lock Chat Height"], 100, 500, 1, L["Height Desc"])
	GUI:CreateSlider(sizesChatSection, "Chat.Width", L["Lock Chat Width"], 200, 600, 1, L["Width Desc"])

	local historyChatSection = GUI:AddSection(chatCategory, HISTORY)
	local logMaxWidget = GUI:CreateSlider(historyChatSection, "Chat.LogMax", L["Chat History Lines To Save"], 0, 250, 10, L["LogMax Desc"])
	-- Inline Reset Saved Chat History button, anchored near the slider track
	if logMaxWidget and logMaxWidget.Slider then
		local resetHistoryButton = GUI:CreateButton(logMaxWidget, (L and L["Reset Chat History"]) or "Reset Chat History", 130, 18, function()
			StaticPopupDialogs["KKUI_CLEAR_CHAT_HISTORY"] = {
				text = (L and L["Clear all chat history now?"]) or "Clear all chat history now?",
				button1 = YES,
				button2 = NO,
				OnAccept = function()
					local chatModule = K:GetModule("Chat")
					if chatModule and chatModule.ClearChatHistory then
						chatModule:ClearChatHistory()
					end
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopup_Show("KKUI_CLEAR_CHAT_HISTORY")
		end)
		resetHistoryButton:ClearAllPoints()
		resetHistoryButton:SetPoint("RIGHT", logMaxWidget.Slider, "LEFT", -12, 0)
		resetHistoryButton:Show()
	end

	-- Fading
	local fadingChatSection = GUI:AddSection(chatCategory, L["Fading"])
	GUI:CreateSwitch(fadingChatSection, "Chat.Fading", L["Fade Chat Text"], L["Chat.Fading Desc"])
	GUI:CreateSlider(fadingChatSection, "Chat.FadingTimeVisible", L["Fading Chat Visible Time"], 5, 120, 1, L["FadingTimeVisible Desc"])
end
