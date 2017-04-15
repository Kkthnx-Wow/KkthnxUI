local K, C, L = unpack(select(2, ...))
if C.Chat.Enable ~= true then return end

-- Lua API
local _G = _G
local string_format = string.format
local string_gsub = string.gsub
local string_len = string.len
local string_find = string.find
local string_sub = string.sub

-- Wow API
local CHAT_FRAMES = _G.CHAT_FRAMES
local ChatEdit_ParseText = _G.ChatEdit_ParseText
local ChatFrame_SendTell = _G.ChatFrame_SendTell
local COMBATLOG = _G.COMBATLOG
local FCF_Close = _G.FCF_Close
local FCF_GetChatWindowInfo = _G.FCF_GetChatWindowInfo
local FCF_SavePositionAndDimensions = _G.FCF_SavePositionAndDimensions
local FCF_SetChatWindowFontSize = _G.FCF_SetChatWindowFontSize
local GetChannelName = _G.GetChannelName
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local LE_REALM_RELATION_SAME = _G.LE_REALM_RELATION_SAME
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PET_BATTLE_COMBAT_LOG = _G.PET_BATTLE_COMBAT_LOG
local TIMESTAMP_FORMAT_HHMM = _G.TIMESTAMP_FORMAT_HHMM
local TIMESTAMP_FORMAT_HHMM_24HR = _G.TIMESTAMP_FORMAT_HHMM_24HR
local TIMESTAMP_FORMAT_HHMM_AMPM = _G.TIMESTAMP_FORMAT_HHMM_AMPM
local TIMESTAMP_FORMAT_HHMMSS = _G.TIMESTAMP_FORMAT_HHMMSS
local TIMESTAMP_FORMAT_HHMMSS_24HR = _G.TIMESTAMP_FORMAT_HHMMSS_24HR
local TIMESTAMP_FORMAT_HHMMSS_AMPM = _G.TIMESTAMP_FORMAT_HHMMSS_AMPM
local UIParent = _G.UIParent
local UnitName = _G.UnitName
local UnitRealmRelationship = _G.UnitRealmRelationship

-- Global variables that we don't cache, list them here for mikk"s FindGlobals script
-- GLOBALS: CombatLogQuickButtonFrame_Custom, ChatTypeInfo, SLASH_BIGCHAT1, AFK, DND
-- GLOBALS: RAID_WARNING, ChatFrame1, CHAT_FRAME_TEXTURES, CreateFrame, BNetMover
-- GLOBALS: HELP_TEXT_SIMPLE, ChatEdit_AddHistory, BNToastFrame, BNToastFrameCloseButton

local hooks = {}
local Movers = K.Movers

local Var = {
	["AFK"] = AFK,
	["DND"] = DND,
	["RAID_WARNING"] = RAID_WARNING,
	["PET_BATTLE_COMBAT_LOG"] = PET_BATTLE_COMBAT_LOG,
}

local ShortChannelNames = {
	GUILD = L.Chat.Guild,
	GUILD = L.Chat.Guild,
	INSTANCE_CHAT = L.Chat.Instance,
	INSTANCE_CHAT_LEADER = L.Chat.InstanceLeader,
	OFFICER = L.Chat.Officer,
	PARTY = L.Chat.Party,
	PARTY = L.Chat.Party,
	PARTY_LEADER = L.Chat.PartyLeader,
	PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG,
	RAID = L.Chat.Raid,
	RAID = L.Chat.Raid,
	RAID_LEADER = L.Chat.RaidLeader
}

local function ShortChannels(self)
	return string_format("|Hchannel:%s|h[%s]|h", self, ShortChannelNames[self:upper()] or self:gsub("channel:", ""))
end

local function AddMessage(frame, string, ...)
	local messagestring

	if type ~= "EMOTE" and type ~= "TEXT_EMOTE" then
		string = string:gsub("|Hchannel:(.-)|h%[(.-)%]|h", ShortChannels)
		string = string:gsub("CHANNEL:", "")
		string = string:gsub("^(.-|h) "..L.Chat.Whispers, "%1")
		string = string:gsub("^(.-|h) "..L.Chat.Says, "%1")
		string = string:gsub("^(.-|h) "..L.Chat.Yells, "%1")
		string = string:gsub("<"..Var.AFK..">", "[|cffFF0000"..L.Chat.AFK.."|r] ")
		string = string:gsub("<"..Var.DND..">", "[|cffE7E716"..L.Chat.DND.."|r] ")
		string = string:gsub("%[BN_CONVERSATION:", "%[1".."")
		string = string:gsub("^%["..Var.RAID_WARNING.."%]", "["..L.Chat.RaidWarning.."]")
	end

	messagestring = hooks[frame](frame, string, ...)
	return messagestring
end

ChatConfigFrameDefaultButton:Kill()
QuickJoinToastButton:Kill()
ChatFrameMenuButton:Kill()

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
			ChatFrame_SendTell((unitname or L.Chat.InvalidTarget), ChatFrame1)
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

-- Set chat style
local function SetChatStyle(frame)
	if frame.IsSkinned then
		return
	end

	local Frame = frame
	local id = frame:GetID()
	local framename = frame:GetName()
	local tab = _G[framename.."Tab"]
	local editbox = _G[framename.."EditBox"]

	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetClampedToScreen(false)
	frame:SetFading(C.Chat.Fading)
	frame:SetTimeVisible(C.Chat.FadingTimeVisible)
	frame:SetFadeDuration(C.Chat.FadingTimeFading)

	-- Move the chat edit box
	editbox:ClearAllPoints()
	editbox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -10, 23)
	editbox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 11, 23)

	-- Kill off editbox artwork
	local a, b, c = select(6, editbox:GetRegions())
	a:Kill()
	b:Kill()
	c:Kill()

	-- Disable alt key usage
	editbox:SetAltArrowKeyMode(false)

	-- Hide editbox on login
	editbox:Hide()

	-- Hide editbox instead of fading
	editbox:HookScript("OnEditFocusLost", function(self)
		self:Hide()
	end)

	editbox:HookScript("OnTextChanged", OnTextChanged)

	-- Hide textures
	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[framename..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	end

	-- Remove default chatframe tab textures
	_G[string_format("ChatFrame%sTabLeft", id)]:Kill()
	_G[string_format("ChatFrame%sTabMiddle", id)]:Kill()
	_G[string_format("ChatFrame%sTabRight", id)]:Kill()

	_G[string_format("ChatFrame%sTabSelectedLeft", id)]:Kill()
	_G[string_format("ChatFrame%sTabSelectedMiddle", id)]:Kill()
	_G[string_format("ChatFrame%sTabSelectedRight", id)]:Kill()

	_G[string_format("ChatFrame%sTabHighlightLeft", id)]:Kill()
	_G[string_format("ChatFrame%sTabHighlightMiddle", id)]:Kill()
	_G[string_format("ChatFrame%sTabHighlightRight", id)]:Kill()

	_G[string_format("ChatFrame%sTabSelectedLeft", id)]:Kill()
	_G[string_format("ChatFrame%sTabSelectedMiddle", id)]:Kill()
	_G[string_format("ChatFrame%sTabSelectedRight", id)]:Kill()

	_G[string_format("ChatFrame%sButtonFrameUpButton", id)]:Kill()
	_G[string_format("ChatFrame%sButtonFrameDownButton", id)]:Kill()
	_G[string_format("ChatFrame%sButtonFrameBottomButton", id)]:Kill()
	_G[string_format("ChatFrame%sButtonFrameMinimizeButton", id)]:Kill()
	_G[string_format("ChatFrame%sButtonFrame", id)]:Kill()

	_G[string_format("ChatFrame%sEditBoxFocusLeft", id)]:Kill()
	_G[string_format("ChatFrame%sEditBoxFocusMid", id)]:Kill()
	_G[string_format("ChatFrame%sEditBoxFocusRight", id)]:Kill()

	_G[string_format("ChatFrame%sEditBoxLeft", id)]:Kill()
	_G[string_format("ChatFrame%sEditBoxMid", id)]:Kill()
	_G[string_format("ChatFrame%sEditBoxRight", id)]:Kill()

	-- Hide edit box every time we click on a tab
	tab:HookScript("OnClick", function() editbox:Hide() end)

	-- Temp Chats
	if (id > 10) then
		frame:SetFont(C.Media.Font, 12)
	end

	-- Create our own texture for edit box
	if C.Chat.TabsMouseover ~= true then
		local editboxbg = CreateFrame("Frame", "ChatEditBoxBackground", editbox)
		editboxbg:SetBackdrop(K.Backdrop)
		editboxbg:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
		editboxbg:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
		editboxbg:ClearAllPoints()
		editboxbg:SetPoint("TOPLEFT", editbox, "TOPLEFT", 7, -2)
		editboxbg:SetPoint("BOTTOMRIGHT", editbox, "BOTTOMRIGHT", -7, 2)
		editboxbg:SetFrameStrata("LOW")
		editboxbg:SetFrameLevel(1)

		local function colorize(r, g, b)
			editboxbg:SetBackdropBorderColor(r, g, b)
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

	if frame ~= COMBATLOG and id ~= 2 then
		TIMESTAMP_FORMAT_HHMM = K.RGBToHex(1, 1, 0).."[%I:%M]|r "
		TIMESTAMP_FORMAT_HHMMSS = K.RGBToHex(1, 1, 0).."[%I:%M:%S]|r "
		TIMESTAMP_FORMAT_HHMMSS_24HR = K.RGBToHex(1, 1, 0).."[%H:%M:%S]|r "
		TIMESTAMP_FORMAT_HHMMSS_AMPM = K.RGBToHex(1, 1, 0).."[%I:%M:%S %p]|r "
		TIMESTAMP_FORMAT_HHMM_24HR = K.RGBToHex(1, 1, 0).."[%H:%M]|r "
		TIMESTAMP_FORMAT_HHMM_AMPM = K.RGBToHex(1, 1, 0).."[%I:%M %p]|r "

		hooks[frame] = frame.AddMessage
		frame.AddMessage = AddMessage
	else
		CombatLogQuickButtonFrame_Custom:StripTextures()
		CombatLogQuickButtonFrame_Custom:SetBackdrop(K.BorderBackdrop)
		CombatLogQuickButtonFrame_Custom:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
	end

	frame.IsSkinned = true
end

local function SetupChat()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[string_format("ChatFrame%s", i)]
		SetChatStyle(frame)
	end

	-- Remember last channel
	ChatTypeInfo.BN_WHISPER.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1
	ChatTypeInfo.EMOTE.sticky = 0
	ChatTypeInfo.GUILD.sticky = 1
	ChatTypeInfo.INSTANCE_CHAT.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.PARTY.sticky = 1
	ChatTypeInfo.RAID.sticky = 1
	ChatTypeInfo.SAY.sticky = 1
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.YELL.sticky = 0
end

local function SetupChatPosAndFont()
	if InCombatLockdown() then return end

	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[string_format("ChatFrame%s", i)]
		local id = frame:GetID()
		local _, fontSize = FCF_GetChatWindowInfo(id)

		-- Min. size for chat font
		if fontSize < 12 then
			FCF_SetChatWindowFontSize(nil, frame, 12)
		else
			FCF_SetChatWindowFontSize(nil, frame, fontSize)
		end

		-- Font and font style for chat
		frame:SetFont(C.Media.Font, fontSize, C.Chat.Outline and "OUTLINE" or "")
		frame:SetShadowOffset(C.Chat.Outline and 0 or K.Mult, C.Chat.Outline and -0 or -K.Mult)

		-- Force chat position
		if i == 1 then
			frame:ClearAllPoints()
			frame:SetSize(C.Chat.Width, C.Chat.Height)
			frame:SetPoint(C.Position.Chat[1], C.Position.Chat[2], C.Position.Chat[3], C.Position.Chat[4], C.Position.Chat[5])
			FCF_SavePositionAndDimensions(frame) -- Important
		end
	end
end

-- This changes the growth direction of the toast frame depending on position of the mover
local BNetMover = CreateFrame("Frame", "BNetMover", UIParent)
BNetMover:SetSize(BNToastFrame:GetWidth(), BNToastFrame:GetHeight())
BNetMover:SetPoint(unpack(C.Position.BnetPopup))

local function PostBNToastMove()
	local x, y = BNetMover:GetCenter()
	local screenHeight = UIParent:GetTop()
	local screenWidth = UIParent:GetRight()

	local anchorPoint
	if (y > (screenHeight / 2)) then
		anchorPoint = (x > (screenWidth/2)) and "TOPRIGHT" or "TOPLEFT"
	else
		anchorPoint = (x > (screenWidth/2)) and "BOTTOMRIGHT" or "BOTTOMLEFT"
	end
	BNetMover.anchorPoint = anchorPoint

	BNToastFrame:ClearAllPoints()
	BNToastFrame:SetPoint(anchorPoint, BNetMover)
end

local function SetToastFrame()
	BNToastFrame:SetTemplate()
	BNToastFrameCloseButton:SetAlpha(0)
	BNToastFrame:SetFrameStrata("Medium")
	BNToastFrame:SetFrameLevel(20)
	BNToastFrame:SetPoint("TOPRIGHT", BNetMover, "BOTTOMRIGHT", 0, -10)
	Movers:RegisterFrame(BNToastFrame)
	BNToastFrame:HookScript("OnShow", PostBNToastMove)
end

-- Remove player"s realm name
local function RemoveRealmName(event, msg, author, ...)
	local realm = string_gsub(K.Realm, " ", "")
	if msg:find("-" .. realm) then
		return false, string_gsub(msg, "%-"..realm, ""), author, ...
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", RemoveRealmName)

-- Close Pet COMBATLOG
local ClosePetLog = CreateFrame("Frame")
ClosePetLog:RegisterEvent("PET_BATTLE_CLOSE")
ClosePetLog:SetScript("OnEvent", function(event)
	for _, frameName in pairs(CHAT_FRAMES) do
		local frame = _G[frameName]
		if frame and _G[frameName.."Tab"]:GetText():match(PET_BATTLE_COMBAT_LOG) then
			FCF_Close(frame)
		end
	end
end)

-- Big Trade Chat
local bigChat = false
function SlashCmdList.BIGCHAT(msg)
	if bigChat == false then
		ChatFrame1:SetSize(400, 400)
		bigChat = true
		print(L.Chat.BigChatOn)
	else
		ChatFrame1:SetSize(400, 150)
		bigChat = false
		print(L.Chat.BigChatOff)
	end
end
_G.SLASH_BIGCHAT1 = "/bigchat"

-- Reset chat command
local Install = K.Install
_G.SLASH_CHATRESET1 = "/chatreset"
SlashCmdList.CHATRESET = function() Install:ChatSetup() _G.ReloadUI() end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("ADDON_LOADED")
Loading:RegisterEvent("PLAYER_ENTERING_WORLD")
Loading:RegisterEvent("UPDATE_CHAT_WINDOWS", "SetupChatPosAndFont")
Loading:RegisterEvent("UPDATE_FLOATING_CHAT_WINDOWS", "SetupChatPosAndFont")
Loading:SetScript("OnEvent", function(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon == "Blizzard_CombatLog" then
			self:UnregisterEvent("ADDON_LOADED")
			SetupChat()
		end
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		SetToastFrame()
		SetupChatPosAndFont() -- Fire it here too?
	end
end)