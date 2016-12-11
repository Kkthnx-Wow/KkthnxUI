local K, C, L = unpack(select(2, ...))
if C.Chat.Enable ~= true then return end

-- Lua API
local _G = _G
local format = string.format
local gsub = string.gsub
local len = string.len
local pairs = pairs
local select = select
local strfind = string.find
local sub = string.sub
local unpack = unpack

-- Wow API
local FCF_Close = FCF_Close
local FCF_GetChatWindowInfo = FCF_GetChatWindowInfo
local FCF_GetCurrentChatFrame = FCF_GetCurrentChatFrame
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local GetChannelName = GetChannelName
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local NUM_CHAT_WINDOWS = NUM_CHAT_WINDOWS
local PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CombatLogQuickButtonFrame_Custom, ChatTypeInfo, SLASH_BIGCHAT1, AFK, DND
-- GLOBALS: RAID_WARNING, ChatFrame1, CHAT_FRAME_TEXTURES, CreateFrame, BNetMover
-- GLOBALS: HELP_TEXT_SIMPLE, ChatEdit_AddHistory

local Movers = K.Movers
local origs = {}

local RenameChannels = {
	INSTANCE_CHAT = L.Chat.Instance,
	GUILD = L.Chat.Guild,
	PARTY = L.Chat.Party,
	RAID = L.Chat.Raid,
	OFFICER = L.Chat.Officer,
	INSTANCE_CHAT_LEADER = L.Chat.InstanceLeader,
	PARTY_LEADER = L.Chat.PartyLeader,
	RAID_LEADER = L.Chat.RaidLeader,
	Guild = L.Chat.Guild,
	raid = L.Chat.Raid,
	Party = L.Chat.Party,
}

local ShortChannels = function(Channel)
	return format("|Hchannel:%s|h[%s]|h", Channel, RenameChannels[Channel] or Channel:gsub("channel:", ""))
end

local AddMessage = function(Frame, String, ...)
	local MessageString

	String = String:gsub("|Hplayer:(.-)|h%[(.-)%]|h", "|Hplayer:%1|h%2|h")
	String = String:gsub("|HBNplayer:(.-)|h%[(.-)%]|h", "|HBNplayer:%1|h%2|h")
	String = String:gsub("|Hchannel:(.-)|h%[(.-)%]|h", ShortChannels)
	String = String:gsub("^To (.-|h)", "|cffad2424@|r%1")
	String = String:gsub("^(.-|h) whispers", "%1")
	String = String:gsub("^(.-|h) says", "%1")
	String = String:gsub("^(.-|h) yells", "%1")
	String = String:gsub("<" .. AFK .. ">", L.Chat.AFK)
	String = String:gsub("<" .. DND .. ">", L.Chat.DND)
	String = String:gsub("^%[" .. RAID_WARNING .. "%]", L.Chat.RaidWarning)

	MessageString = origs[Frame](Frame, String, ...)

	return MessageString
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
	frame:SetClampedToScreen(false)
	frame:SetFading(false)

	-- Move the chat edit box
	editbox:ClearAllPoints()
	editbox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -4, 23)
	editbox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 4, 23)

	-- Hide textures
	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[framename..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	end

	-- Removes default chatframe tabs texture
	for _, textures in pairs(textures) do
		_G[format("ChatFrame%s" .. textures, id)]:Kill()
	end

	-- Kill off editbox artwork
	local a, b, c = select(6, editbox:GetRegions()) a:Kill() b:Kill() c:Kill()

	-- Kill bubble tex/glow
	if tab.conversationIcon then tab.conversationIcon:Kill() end

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
			if (len(text) > MIN_REPEAT_CHARACTERS) then
				local repeatChar = true
				for i = 1, MIN_REPEAT_CHARACTERS, 1 do
					if (sub(text,(0-i), (0-i)) ~= sub(text,(-1-i),(-1-i))) then
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

		local new, found = gsub(text, "|Kf(%S+)|k(%S+)%s(%S+)|k", "%2 %3")
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
		EditBoxBackground:SetBackdropColor(unpack(C.Media.Backdrop_Color))
		EditBoxBackground:SetBackdropBorderColor(unpack(C.Media.Border_Color))
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
					colorize(unpack(C.Media.Border_Color))
				else
					colorize(ChatTypeInfo[type..id].r, ChatTypeInfo[type..id].g, ChatTypeInfo[type..id].b)
				end
			else
				colorize(ChatTypeInfo[type].r, ChatTypeInfo[type].g, ChatTypeInfo[type].b)
			end
		end)
	end

	if frame ~= _G["ChatFrame2"] then
		origs[frame] = frame.AddMessage
		frame.AddMessage = AddMessage
	else
		CombatLogQuickButtonFrame_Custom:StripTextures()
		CombatLogQuickButtonFrame_Custom:SetBackdrop(K.BorderBackdrop)
		CombatLogQuickButtonFrame_Custom:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	end

	frame.skinned = true
end

-- Setup chatframes 1 to 10 on login
local function SetupChat(self)
	for i = 1, NUM_CHAT_WINDOWS do
		local ChatFrame = _G[format("ChatFrame%s", i)]
		local ChatFrameID = ChatFrame:GetID()
		SetChatStyle(ChatFrame)
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
end

local function SetupChatPosAndFont(self)
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
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
	end
end

local BNet = CreateFrame("Frame", "BNetMover", UIParent)
BNet:SetSize(BNToastFrame:GetWidth(), BNToastFrame:GetHeight())
BNet:SetPoint(unpack(C.Position.BnetPopup))
Movers:RegisterFrame(BNet)

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

-- Remove player's realm name
local function RemoveRealmName(self, event, msg, author, ...)
	local realm = gsub(K.Realm, " ", "")
	if msg:find("-" .. realm) then
		return false, gsub(msg, "%-"..realm, ""), author, ...
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", RemoveRealmName)

-- Save slash command typo
local function TypoHistory_Posthook_AddMessage(chat, text)
	if strfind(text, HELP_TEXT_SIMPLE) then
		ChatEdit_AddHistory(chat.editBox)
	end
end

for i = 1, NUM_CHAT_WINDOWS do
	if i ~= 2 then
		hooksecurefunc(_G["ChatFrame"..i], "AddMessage", TypoHistory_Posthook_AddMessage)
	end
end

-- Big Trade Chat
local bigchat = false
function SlashCmdList.BIGCHAT(msg, editbox)
	if bigchat == false then
		ChatFrame1:SetSize(400, 400)
		bigchat = true
		K.Print(L.Chat.BIGCHAT_ON)
	else
		ChatFrame1:SetSize(400, 150)
		bigchat = false
		K.Print(L.Chat.BIGCHAT_OFF)
	end
end
SLASH_BIGCHAT1 = "/bigchat"