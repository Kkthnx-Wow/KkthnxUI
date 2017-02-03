local K, C, L = unpack(select(2, ...))
if C.Chat.Enable ~= true then return end

-- Lua API
local _G = _G
local pairs = pairs
local select = select
local string_find = string.find
local string_match = string.match
local string_format = string.format
local string_gsub = string.gsub
local string_len = string.len
local string_sub = string.sub
local string_lower = string.lower
local unpack = unpack

-- Wow API
local FCF_Close = _G.FCF_Close
local FCF_GetChatWindowInfo = _G.FCF_GetChatWindowInfo
local FCF_GetCurrentChatFrame = _G.FCF_GetCurrentChatFrame
local FCF_SetChatWindowFontSize = _G.FCF_SetChatWindowFontSize
local GetChannelName = _G.GetChannelName
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PET_BATTLE_COMBAT_LOG = _G.PET_BATTLE_COMBAT_LOG
local UnitName = _G.UnitName
local UnitRealmRelationship = _G.UnitRealmRelationship

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ChatFrame_SendTell, ChatEdit_ParseText, FCF_SavePositionAndDimensions
-- GLOBALS: CombatLogQuickButtonFrame_Custom, ChatTypeInfo, SLASH_BIGCHAT1, AFK, DND
-- GLOBALS: HELP_TEXT_SIMPLE, ChatEdit_AddHistory, LE_REALM_RELATION_SAME
-- GLOBALS: RAID_WARNING, ChatFrame1, CHAT_FRAME_TEXTURES, CreateFrame, BNetMover

local hooks = {}
local Movers = K.Movers

local STRING_STYLE = "%s|| "
local CHANNEL_STYLE = "%d"
local CHANNEL_PATTERN = "|Hchannel:(.-)|h%[(%d+)%.%s?([^:%-%]]+)%s?[:%-]?%s?[^|%]]*%]|h%s?"
local CHANNEL_PATTERN_PLUS = CHANNEL_PATTERN .. ".+"
local CHANNEL_HEADER = string_format(STRING_STYLE, CHANNEL_STYLE) .. "%s"
local CHANNEL_HEADER_PATTERN = "%[(%d+)%. ?([^%s:%-%]]+)[^%]]*%](.*)"
local CHANNEL_LINK = "|Hchannel:%1$s|h" .. format(STRING_STYLE, CHANNEL_STYLE) .. "|h"

local CUSTOM_CHANNELS = {
	-- Not case-sensitive. Must be in the format:
	-- ["mychannel"] = "MC",
}

local ChannelStrings = {
	CHAT_BN_WHISPER_GET = string_format(STRING_STYLE, L.Chat.WhisperIncoming) .. "%s:\32",
	CHAT_BN_WHISPER_INFORM_GET = string_format(STRING_STYLE, L.Chat.WhisperOutgoing) .. "%s:\32",
	CHAT_GUILD_GET = "|Hchannel:guild|h" .. string_format(STRING_STYLE, L.Chat.Guild) .. "|h%s:\32",
	CHAT_INSTANCE_CHAT_GET = "|Hchannel:battleground|h" .. string_format(STRING_STYLE, L.Chat.InstanceChat) .. "|h%s:\32",
	CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:battleground|h" .. string_format(STRING_STYLE, L.Chat.InstanceChatLeader) .. "|h%s:\32",
	CHAT_OFFICER_GET = "|Hchannel:o|h" .. string_format(STRING_STYLE, L.Chat.Officer) .. "|h%s:\32",
	CHAT_PARTY_GET = "|Hchannel:party|h" .. string_format(STRING_STYLE, L.Chat.Party) .. "|h%s:\32",
	CHAT_PARTY_GUIDE_GET = "|Hchannel:party|h" .. string_format(STRING_STYLE, L.Chat.PartyGuide) .. "|h%s:\32",
	CHAT_PARTY_LEADER_GET = "|Hchannel:party|h" .. string_format(STRING_STYLE, L.Chat.PartyLeader) .. "|h%s:\32",
	CHAT_RAID_GET = "|Hchannel:raid|h" .. string_format(STRING_STYLE, L.Chat.Raid) .. "|h%s:\32",
	CHAT_RAID_LEADER_GET = "|Hchannel:raid|h" .. string_format(STRING_STYLE, L.Chat.RaidLeader) .. "|h%s:\32",
	CHAT_RAID_WARNING_GET = string_format(STRING_STYLE, L.Chat.RaidWarning) .. "%s:\32",
	CHAT_SAY_GET = string_format(STRING_STYLE, L.Chat.Say) .. "%s:\32",
	CHAT_WHISPER_GET = string_format(STRING_STYLE, L.Chat.WhisperIncoming) .. "%s:\32",
	CHAT_WHISPER_INFORM_GET = string_format(STRING_STYLE, L.Chat.WhisperOutgoing) .. "%s:\32",
	CHAT_YELL_GET = string_format(STRING_STYLE, L.Chat.Yell) .. "%s:\32",
}

local ChannelNames = {
	L.Chat.Conversation,
	L.Chat.General,
	L.Chat.LocalDefense,
	L.Chat.LookingForGroup,
	L.Chat.Trade,
	L.Chat.WorldDefense,
}
for name, abbr in pairs(CUSTOM_CHANNELS) do
	ChannelNames[strlower(name)] = abbr
end

local AddMessage = function(frame, message, ...)
	if type(message) == "string" then
		local channelData, channelID, channelName = string_match(message, CHANNEL_PATTERN .. ".+")
		if channelData then
			local shortName = ChannelNames[channelName] or ChannelNames[string_lower(channelName)] or string_sub(channelName, 1, 2)
			message = string_gsub(message, CHANNEL_PATTERN, string_format(CHANNEL_LINK, channelData, channelID, shortName))
		end

		hooks[frame].AddMessage(frame, message, ...)
	end
end

hooksecurefunc("ChatEdit_UpdateHeader", function(editBox)
	local header = editBox.header
	if header and editBox:GetAttribute("chatType") == "CHANNEL" then
		local text = header:GetText()
		local channelID, channelName, headerSuffix = strmatch(text, CHANNEL_HEADER_PATTERN)
		if channelID then
			header:SetWidth(0)

			local shortName = ChannelNames[channelName] or ChannelNames[strlower(channelName)] or strsub(channelName, 1, 2)
			header:SetFormattedText(CHANNEL_HEADER, channelID, shortName, headerSuffix or "")

			local headerSuffix = editBox.headerSuffix
			local headerWidth = (header:GetRight() or 0) - (header:GetLeft() or 0)
			local editBoxWidth = editBox:GetRight() - editBox:GetLeft()
			if headerWidth * 2 > editBoxWidth then
				header:SetWidth(editBoxWidth / 2)
				headerSuffix:Show()
				editBox:SetTextInsets(21 + header:GetWidth() + headerSuffix:GetWidth(), 13, 0, 0)
			else
				headerSuffix:Hide()
				editBox:SetTextInsets(21 + header:GetWidth(), 13, 0, 0)
			end
		end
	end
end)

local function SetChannelNames()
	if not hooks.CHAT_GUILD_GET then
		for k, v in pairs(ChannelStrings) do
			hooks[k] = _G[k]
			_G[k] = v
		end
	end
end

local function GetGroupDistribution()
	local inInstance, kind = IsInInstance()
	if inInstance and (kind == "pvp") then
		return "/bg "
	end
	if IsInRaid() then
		return "/ra "
	end
	if IsInGroup() then
		return "/p "
	end
	return "/s "
end

ChatConfigFrameDefaultButton:Kill()
QuickJoinToastButton:Kill()
ChatFrameMenuButton:Kill()

-- Set chat style
local function SetChatStyle(frame)
	local frame = frame
	local id = frame:GetID()
	local framename = frame:GetName()
	local tab = _G[framename.."Tab"]
	local editbox = _G[framename.."EditBox"]
	local textures = {
		"TabLeft", "TabMiddle", "TabRight",
		"TabSelectedLeft", "TabSelectedMiddle", "TabSelectedRight",
		"TabHighlightLeft", "TabHighlightMiddle", "TabHighlightRight",
		"ButtonFrameUpButton", "ButtonFrameDownButton", "ButtonFrameBottomButton",
		"ButtonFrameMinimizeButton", "ButtonFrame", "EditBoxFocusLeft",
		"EditBoxFocusMid", "EditBoxFocusRight", "EditBoxLeft", "EditBoxMid", "EditBoxRight"
	}

	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetHitRectInsets(0, 0, 0, 0)
	frame:SetClampedToScreen(false)
	frame:SetFading(C.Chat.Fading)
	frame:SetTimeVisible(C.Chat.FadingTimeVisible)
	frame:SetFadeDuration(C.Chat.FadingTimeFading)

	-- Move the chat edit box
	editbox:ClearAllPoints()
	editbox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -10, 23)
	editbox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 11, 23)

	-- Hide textures
	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[framename..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	end

	-- Removes default chatframe tabs texture
	for _, textures in pairs(textures) do
		_G[string_format("ChatFrame%s" .. textures, id)]:Kill()
	end

	-- Kill off editbox artwork
	local a, b, c = select(6, editbox:GetRegions()) a:Kill() b:Kill() c:Kill()

	-- Disable alt key usage
	editbox:SetAltArrowKeyMode(false)

	-- Hide editbox on login
	editbox:Hide()

	-- Script to hide editbox instead of fading editbox to 0.35 alpha via im style
	editbox:HookScript("OnEditFocusLost", function(self) self:Hide() end)

	local function OnTextChanged(self)
		local text = self:GetText()

		if InCombatLockdown() then
			local MIN_REPEAT_CHARACTERS = 5
			if (string_len(text) > MIN_REPEAT_CHARACTERS) then
				local repeatChar = true
				for i = 1, MIN_REPEAT_CHARACTERS, 1 do
					if (string_sub(text,(0 - i), (0 - i)) ~= string_sub(text,(-1 - i),(-1 - i))) then
						repeatChar = false
						break
					end
				end
				if (repeatChar) then
					self:Hide()
					return
				end
			end
		end

		if text:len() < 5 then
			if text:sub(1, 4) == "/tt " then
				local unitname, realm = UnitName("target")
				if unitname then unitname = string_gsub(unitname, " ", "") end
				if unitname and UnitRealmRelationship("target") ~= LE_REALM_RELATION_SAME then
					unitname = string_format("%s-%s", unitname, string_gsub(realm, " ", ""))
				end
				ChatFrame_SendTell((unitname or "Invalid Target"), ChatFrame1)
			end

			if text:sub(1, 4) == "/gr " then
				self:SetText(GetGroupDistribution() .. text:sub(5))
				ChatEdit_ParseText(self, 0)
			end
		end

		local new, found = string_gsub(text, "|Kf(%S+)|k(%S+)%s(%S+)|k", "%2 %3")
		if found > 0 then
			new = new:gsub("|", "")
			self:SetText(new)
		end
	end
	editbox:HookScript("OnTextChanged", OnTextChanged)

	-- Hide edit box every time we click on a tab
	tab:HookScript("OnClick", function() editbox:Hide() end)

	-- CREATE OUR OWN TEXTURE FOR EDIT BOX
	if C.Chat.TabsMouseover ~= true then
		local EditBoxBackground = CreateFrame("Frame", "ChatEditBoxBackground", editbox)
		EditBoxBackground:SetBackdrop(K.Backdrop)
		EditBoxBackground:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
		EditBoxBackground:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
		EditBoxBackground:ClearAllPoints()
		EditBoxBackground:SetPoint("TOPLEFT", editbox, "TOPLEFT", 7, -2)
		EditBoxBackground:SetPoint("BOTTOMRIGHT", editbox, "BOTTOMRIGHT", -7, 2)
		EditBoxBackground:SetFrameStrata("LOW")
		EditBoxBackground:SetFrameLevel(1)

		local function colorize(r, g, b)
			EditBoxBackground:SetBackdropBorderColor(r, g, b)
		end

		-- Update border color according where we talk
		hooksecurefunc("ChatEdit_UpdateHeader", function()
			local type = editbox:GetAttribute("chatType")
			if type == "CHANNEL" then
				local id = GetChannelName(editbox:GetAttribute("channelTarget"))
				if id == 0 then
					colorize(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
				else
					colorize(ChatTypeInfo[type..id].r, ChatTypeInfo[type..id].g, ChatTypeInfo[type..id].b)
				end
			else
				colorize(ChatTypeInfo[type].r, ChatTypeInfo[type].g, ChatTypeInfo[type].b)
			end
		end)
	end

	if frame ~= COMBATLOG then
		if not hooks[frame] then
			hooks[frame] = {}
		end
		if not hooks[frame].AddMessage then
			hooks[frame].AddMessage = frame.AddMessage
			frame.AddMessage = AddMessage
		end
	end

	CombatLogQuickButtonFrame_Custom:StripTextures()
	CombatLogQuickButtonFrame_Custom:SetBackdrop(K.BorderBackdrop)
	CombatLogQuickButtonFrame_Custom:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])

	frame.skinned = true
end

-- Setup chatframes 1 to 10 on login
local function SetupChat(self)
	for i = 1, NUM_CHAT_WINDOWS do
		local ChatFrame = _G[string_format("ChatFrame%s", i)]
		local ChatFrameID = ChatFrame:GetID()
		SetChatStyle(ChatFrame)
		SetChannelNames(ChatFrame)
	end

	-- Remember last channel
	ChatTypeInfo.SAY.sticky = 1
	ChatTypeInfo.PARTY.sticky = 1
	ChatTypeInfo.PARTY_LEADER.sticky = 1
	ChatTypeInfo.GUILD.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.INSTANCE_CHAT.sticky = 1
	ChatTypeInfo.INSTANCE_CHAT_LEADER.sticky = 1
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.BN_WHISPER.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1

	ChatTypeInfo.GUILD.flashTabOnGeneral = true
	ChatTypeInfo.OFFICER.flashTabOnGeneral = true
end

local function SetupChatPosAndFont(self)
	for index = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..index]
		local ID = Frame:GetID()
		local _, FontSize = FCF_GetChatWindowInfo(ID)

		-- Min. size for chat font
		if FontSize < 12 then
			FCF_SetChatWindowFontSize(nil, Frame, 12)
		else
			FCF_SetChatWindowFontSize(nil, Frame, FontSize)
		end

		-- Font and font style for chat
		if C.Chat.Outline == true then
			Frame:SetFont(C.Media.Font, FontSize, C.Media.Font_Style)
			Frame:SetShadowOffset(0, 0)
			Frame:SetShadowColor(0, 0, 0, 0.2)
		else
			Frame:SetFont(C.Media.Font, FontSize)
			Frame:SetShadowOffset(K.Mult, -K.Mult)
			Frame:SetShadowColor(0, 0, 0, 0.9)
		end

		-- Position. Just to be safe here.
		-- if index == 1 then
		-- Frame:ClearAllPoints()
		-- Frame:SetSize(C.Chat.Width, C.Chat.Height)
		-- Frame:SetPoint(C.Position.Chat[1], C.Position.Chat[2], C.Position.Chat[3], C.Position.Chat[4], C.Position.Chat[5])
		-- FCF_SavePositionAndDimensions(Frame)
		-- end
	end
end

local BNetMover = CreateFrame("Frame", "BNetMover", UIParent)
BNetMover:SetSize(BNToastFrame:GetWidth(), BNToastFrame:GetHeight())
BNetMover:SetPoint(unpack(C.Position.BnetPopup))
Movers:RegisterFrame(BNetMover)

BNToastFrame:HookScript("OnShow", function(self)
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", BNetMover, "TOPLEFT", 3, -3)
end)

local UIChat = CreateFrame("Frame")
UIChat:RegisterEvent("ADDON_LOADED")
UIChat:RegisterEvent("PLAYER_ENTERING_WORLD")
UIChat:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon == "Blizzard_CombatLog" then
			self:UnregisterEvent("ADDON_LOADED")
			SetupChat(self)
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		SetupChatPosAndFont(self)
	end
end)

-- Setup temp chat (bn, whisper) when needed
local SetupTempChat = function()
	local Frame = FCF_GetCurrentChatFrame()

	if (_G[Frame:GetName() .. "Tab"]:GetText():match(PET_BATTLE_COMBAT_LOG)) then
		FCF_Close(Frame)
		return
	end

	if (Frame.IsSkinned) then
		return
	end

	Frame.temp = true
	SetChatStyle(Frame)
end
hooksecurefunc("FCF_OpenTemporaryWindow", SetupTempChat)

-- Remove player's realm name
local function RemoveRealmName(self, event, msg, author, ...)
	local realm = string_gsub(K.Realm, " ", "")
	if msg:find("-" .. realm) then
		return false, string_gsub(msg, "%-"..realm, ""), author, ...
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", RemoveRealmName)

-- Save slash command typo
local function TypoHistory_Posthook_AddMessage(chat, text)
	if string_find(text, HELP_TEXT_SIMPLE) then
		ChatEdit_AddHistory(chat.editBox)
	end
end

for i = 1, NUM_CHAT_WINDOWS do
	if i ~= 2 then
		hooksecurefunc(_G["ChatFrame"..i], "AddMessage", TypoHistory_Posthook_AddMessage)
	end
end

-- Reset chat command
_G.SLASH_CHATRESET1 = "/chatreset"
SlashCmdList.CHATRESET = function() SetupChatPosAndFont() K.Print("Chat has been successfully reset!") end

-- Big Trade Chat
local bigchat = false
function SlashCmdList.BIGCHAT(msg)
	if bigchat == false then
		ChatFrame1:SetSize(400, 400)
		bigchat = true
		K.Print(L.Chat.BigChatOn)
	else
		ChatFrame1:SetSize(400, 150)
		bigchat = false
		K.Print(L.Chat.BigChatOff)
	end
end
_G.SLASH_BIGCHAT1 = "/bigchat"