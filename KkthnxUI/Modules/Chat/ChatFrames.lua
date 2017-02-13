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
local ChatEdit_ParseText = _G.ChatEdit_ParseText
local ChatFrame_SendTell = _G.ChatFrame_SendTell
local COMBATLOG = _G.COMBATLOG
local FCF_GetChatWindowInfo = _G.FCF_GetChatWindowInfo
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
local UnitName = _G.UnitName
local UnitRealmRelationship = _G.UnitRealmRelationship

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: CombatLogQuickButtonFrame_Custom, ChatTypeInfo, SLASH_BIGCHAT1, AFK, DND
-- GLOBALS: RAID_WARNING, ChatFrame1, CHAT_FRAME_TEXTURES, CreateFrame, BNetMover
-- GLOBALS: HELP_TEXT_SIMPLE, ChatEdit_AddHistory, BNToastFrame

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

local ShortChannels = function(self)
	return format("|Hchannel:%s|h[%s]|h", self, ShortChannelNames[self:upper()] or self:gsub("channel:", ""))
end

local AddMessage = function(frame, string, ...)
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
		if (len(text) > MIN_REPEAT_CHARACTERS) then
			local repeatChar = true
			for i = 1, MIN_REPEAT_CHARACTERS, 1 do
				if (sub(text,(0 - i), (0 - i)) ~= sub(text,(-1 - i),(-1 - i))) then
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
			if unitname then unitname = gsub(unitname, " ", "") end
			if unitname and UnitRealmRelationship("target") ~= LE_REALM_RELATION_SAME then
				unitname = format("%s-%s", unitname, gsub(realm, " ", ""))
			end
			ChatFrame_SendTell((unitname or L.Chat.InvalidTarget), ChatFrame1)
		end

		if text:sub(1, 4) == "/gr " then
			self:SetText(GetGroupDistribution() .. text:sub(5))
			ChatEdit_ParseText(self, 0)
		end
	end

	local new, found = gsub(text, "|Kf(%S+)|k(%S+)%s(%S+)|k", "%2 %3")
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
	frame:SetHitRectInsets(0, 0, 0, 0)
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
	_G[format("ChatFrame%sTabLeft", id)]:Kill()
	_G[format("ChatFrame%sTabMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabRight", id)]:Kill()

	_G[format("ChatFrame%sTabSelectedLeft", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedRight", id)]:Kill()

	_G[format("ChatFrame%sTabHighlightLeft", id)]:Kill()
	_G[format("ChatFrame%sTabHighlightMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabHighlightRight", id)]:Kill()

	_G[format("ChatFrame%sTabSelectedLeft", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedMiddle", id)]:Kill()
	_G[format("ChatFrame%sTabSelectedRight", id)]:Kill()

	_G[format("ChatFrame%sButtonFrameUpButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrameDownButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrameBottomButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrameMinimizeButton", id)]:Kill()
	_G[format("ChatFrame%sButtonFrame", id)]:Kill()

	_G[format("ChatFrame%sEditBoxFocusLeft", id)]:Kill()
	_G[format("ChatFrame%sEditBoxFocusMid", id)]:Kill()
	_G[format("ChatFrame%sEditBoxFocusRight", id)]:Kill()

	_G[format("ChatFrame%sEditBoxLeft", id)]:Kill()
	_G[format("ChatFrame%sEditBoxMid", id)]:Kill()
	_G[format("ChatFrame%sEditBoxRight", id)]:Kill()

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

	if frame ~= COMBATLOG or id ~= 2 then
		if not hooks[frame] then
			hooks[frame] = frame.AddMessage
			frame.AddMessage = AddMessage
		end
	else
		CombatLogQuickButtonFrame_Custom:StripTextures()
		CombatLogQuickButtonFrame_Custom:SetBackdrop(K.BorderBackdrop)
		CombatLogQuickButtonFrame_Custom:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
	end

	frame.IsSkinned = true
end

local function SetupChat()
	for i = 1, NUM_CHAT_WINDOWS do
		local chatframe = _G[format("ChatFrame%s", i)]

		SetChatStyle(chatframe)
	end

	local ChatTypeInfo = getmetatable(ChatTypeInfo).__index
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

	ChatTypeInfo.GUILD.flashTabOnGeneral = true
	ChatTypeInfo.OFFICER.flashTabOnGeneral = true
end

local function SetupChatFont()
	for index = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..index]
		local id = frame:GetID()
		local _, fontsize = FCF_GetChatWindowInfo(id)

		-- Min. size for chat font
		if fontsize < 12 then
			FCF_SetChatWindowFontSize(nil, frame, 12)
		else
			FCF_SetChatWindowFontSize(nil, frame, fontsize)
		end

		-- Font and font style for chat
		if C.Chat.Outline == true then
			frame:SetFont(C.Media.Font, fontsize, C.Media.Font_Style)
			frame:SetShadowOffset(0, 0)
			frame:SetShadowColor(0, 0, 0, 0.2)
		else
			frame:SetFont(C.Media.Font, fontsize)
			frame:SetShadowOffset(K.Mult, -K.Mult)
			frame:SetShadowColor(0, 0, 0, 0.9)
		end
	end
end

--This changes the growth direction of the toast frame depending on position of the mover
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
local function RemoveRealmName(self, event, msg, author, ...)
	local realm = gsub(K.Realm, " ", "")
	if msg:find("-" .. realm) then
		return false, gsub(msg, "%-"..realm, ""), author, ...
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", RemoveRealmName)

-- Big Trade Chat
local bigchat = false
function SlashCmdList.BIGCHAT(msg)
	if bigchat == false then
		ChatFrame1:SetSize(400, 400)
		bigchat = true
		print(L.Chat.BigChatOn)
	else
		ChatFrame1:SetSize(400, 150)
		bigchat = false
		print(L.Chat.BigChatOff)
	end
end
_G.SLASH_BIGCHAT1 = "/bigchat"

-- Reset chat command
local Install = K.Install
_G.SLASH_CHATRESET1 = "/chatreset"
SlashCmdList.CHATRESET = function() Install:ChatSetup() _G.ReloadUI() end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function()
	SetupChat()
	SetupChatFont()
	SetToastFrame()
end)