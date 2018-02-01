local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Chat", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local pairs = pairs
local select = select
local string_format = string.format
local string_gsub = string.gsub
local string_len = string.len
local string_sub = string.sub
local type = type
local unpack = unpack

local BNGetFriendInfoByID = _G.BNGetFriendInfoByID
local BNGetGameAccountInfo = _G.BNGetGameAccountInfo
local ChatEdit_ChooseBoxForSend = _G.ChatEdit_ChooseBoxForSend
local ChatEdit_ParseText = _G.ChatEdit_ParseText
local ChatFrame_SendTell = _G.ChatFrame_SendTell
local ChatFrame_SystemEventHandler = _G.ChatFrame_SystemEventHandler
local CreateFrame = _G.CreateFrame
local FCF_Close = _G.FCF_Close
local FCF_DockFrame = _G.FCF_DockFrame
local FCF_GetCurrentChatFrame = _G.FCF_GetCurrentChatFrame
local FCF_OpenNewWindow = _G.FCF_OpenNewWindow
local FCF_ResetChatWindows = _G.FCF_ResetChatWindows
local FCF_SetLocked = _G.FCF_SetLocked
local FCF_SetWindowName = _G.FCF_SetWindowName
local GENERAL = _G.GENERAL
local GetChannelName = _G.GetChannelName
local GetRealmName = _G.GetRealmName
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local INTERFACE_ACTION_BLOCKED = _G.INTERFACE_ACTION_BLOCKED
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local IsShiftKeyDown = _G.IsShiftKeyDown
local LE_REALM_RELATION_SAME = _G.LE_REALM_RELATION_SAME
local LOCALIZED_CLASS_NAMES_FEMALE = _G.LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = _G.LOCALIZED_CLASS_NAMES_MALE
local LOOT = _G.LOOT
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PlaySoundFile = _G.PlaySoundFile
local ToggleFrame = _G.ToggleFrame
local TRADE = _G.TRADE
local UIParent = _G.UIParent
local UnitName = _G.UnitName
local UnitRealmRelationship = _G.UnitRealmRelationship

-- GLOBALS: ChangeChatColor, DEFAULT_CHAT_FRAME, ChatMenu, ChatConfigFrameDefaultButton, ChatFrameMenuButton, QuickJoinToastButton
-- GLOBALS: ChatFrame_RemoveAllMessageGroups, ChatFrame_AddMessageGroup, ChatFrame_AddChannel, ChatFrame_RemoveChannel, ToggleChatColorNamesByClassGroup
-- GLOBALS: ChatFrame1, ChatFrame2, ChatFrame3, ChatFrame4, ChatTypeInfo, KkthnxUIFont, CreateAnimationGroup, CHAT_FRAME_TEXTURES, KkthnxUIData

local hooks = {}

local CUSTOM_CHANNELS = {
	-- Not case-sensitive. Must be in the format:
	-- ["mychannel"] = "MC",
}

local ChannelNames = {
	[L["Chat"].Conversation] = L["Chat"].S_Conversation,
	[L["Chat"].General] = L["Chat"].SCN_General,
	[L["Chat"].LocalDefense] = L["Chat"].S_LocalDefense,
	[L["Chat"].LookingForGroup] = L["Chat"].S_LookingForGroup,
	[L["Chat"].Trade] = L["Chat"].S_Trade,
	[L["Chat"].WorldDefense] = L["Chat"].S_WorldDefense,
}

local ChannelStrings = {
	CHAT_BN_WHISPER_GET	= format("%s|| ", L["Chat"].S_WhisperIncoming).."%s:\32",
	CHAT_BN_WHISPER_INFORM_GET	= format("%s|| ", L["Chat"].S_WhisperOutgoing).."%s:\32",
	CHAT_GUILD_GET = "|Hchannel:guild|h"..format("%s|| ", L["Chat"].S_Guild).."|h%s:\32",
	CHAT_INSTANCE_CHAT_GET = "|Hchannel:battleground|h"..format("%s|| ", L["Chat"].S_InstanceChat).."|h%s:\32",
	CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:battleground|h"..format("%s|| ", L["Chat"].S_InstanceChatLeader).."|h%s:\32",
	CHAT_OFFICER_GET = "|Hchannel:o|h"..format("%s|| ", L["Chat"].S_Officer).."|h%s:\32",
	CHAT_PARTY_GET = "|Hchannel:party|h"..format("%s|| ", L["Chat"].S_Party).."|h%s:\32",
	CHAT_PARTY_GUIDE_GET = "|Hchannel:party|h"..format("%s|| ", L["Chat"].S_PartyGuide).."|h%s:\32",
	CHAT_PARTY_LEADER_GET = "|Hchannel:party|h"..format("%s|| ", L["Chat"].S_PartyLeader).."|h%s:\32",
	CHAT_RAID_GET = "|Hchannel:raid|h"..format("%s|| ", L["Chat"].S_Raid).."|h%s:\32",
	CHAT_RAID_LEADER_GET = "|Hchannel:raid|h"..format("%s|| ", L["Chat"].S_RaidLeader).."|h%s:\32",
	CHAT_RAID_WARNING_GET = format("%s|| ", L["Chat"].S_RaidWarning).."%s:\32",
	CHAT_SAY_GET = format("%s|| ", L["Chat"].S_Say).."%s:\32",
	CHAT_WHISPER_GET = format("%s|| ", L["Chat"].S_WhisperIncoming).."%s:\32",
	CHAT_WHISPER_INFORM_GET = format("%s|| ", L["Chat"].S_WhisperOutgoing).."%s:\32",
	CHAT_YELL_GET = format("%s|| ", L["Chat"].S_Yell).."%s:\32",
}

for name, abbr in pairs(CUSTOM_CHANNELS) do
	ChannelNames[string.lower(name)] = abbr
end

local function escape(str)
	return gsub(str, "([%%%+%-%.%[%]%*%?])", "%%%1")
end

local function AddMessage(frame, message, ...)
	if type(message) == "string" then
		local channelData, channelID, channelName = strmatch(message, "|Hchannel:(.-)|h%[(%d+)%.%s?([^:%-%]]+)%s?[:%-]?%s?[^|%]]*%]|h%s?"..".+")
		if channelData and C["Chat"].ShortenChannelNames then
			local shortName = ChannelNames[channelName] or ChannelNames[strlower(channelName)] or strsub(channelName, 1, 2)
			message = gsub(message, "|Hchannel:(.-)|h%[(%d+)%.%s?([^:%-%]]+)%s?[:%-]?%s?[^|%]]*%]|h%s?", format("|Hchannel:%1$s|h"..string.format("%s|| ", "%d").."|h", channelData, channelID, shortName))
		end

		local playerData, playerName = strmatch(message, "|Hplayer:(.-)|h%[(.-)%]|h")
		if playerData then
			if C["Chat"].RemoveRealmNames then
				if strmatch(playerName, "|cff") then
					playerName = gsub(playerName, "%-[^|]+", "")
				else
					playerName = strmatch(playerName, "[^%-]+")
				end
			end
			message = gsub(message, "|Hplayer:(.-)|h%[(.-)%]|h", format("|Hplayer:%s|h".."%s".."|h", playerData, playerName))
		elseif channelID then
			-- WorldDefense messages don't have a sender; remove the extra colon and space.
			message = gsub(message, "(|Hchannel:.-|h): ", "%1", 1)
		end
	end
	hooks[frame].AddMessage(frame, message, ...)
end

function Module:SetShortenChannelNames()
	if C["Chat"].ShortenChannelNames then
		if not hooks.CHAT_GUILD_GET then
			for k, v in pairs(ChannelStrings) do
				hooks[k] = _G[k]
				_G[k] = v
			end
		end
	else
		if hooks.CHAT_GUILD_GET then
			for k, v in pairs(hooks) do
				_G[k] = v
				hooks[k] = nil
			end
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
			ChatFrame_SendTell((unitname or L.Chat.Invaild_Target), ChatFrame1)
		end

		if text:sub(1, 4) == "/gr " then
			self:SetText(GetGroupDistribution()..text:sub(5))
			ChatEdit_ParseText(self, 0)
		end
	end

	local new, found = string_gsub(text, "|Kf(%S+)|k(%S+)%s(%S+)|k", "%2 %3")
	if found > 0 then
		new = new:gsub("|", "")
		self:SetText(new)
	end
end

-- Update editbox border color
function Module:UpdateEditBoxColor()
	local EditBox = ChatEdit_ChooseBoxForSend()
	local ChatType = EditBox:GetAttribute("chatType")

	if (ChatType == "CHANNEL") then
		local ID = GetChannelName(EditBox:GetAttribute("channelTarget"))

		if ID == 0 then
			EditBox:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		else
			EditBox:SetBackdropBorderColor(ChatTypeInfo[ChatType..ID].r, ChatTypeInfo[ChatType..ID].g, ChatTypeInfo[ChatType..ID].b)
		end
	else
		EditBox:SetBackdropBorderColor(ChatTypeInfo[ChatType].r, ChatTypeInfo[ChatType].g, ChatTypeInfo[ChatType].b)
	end
end

function Module:NoMouseAlpha()
	local Frame = self:GetName()
	local Tab = _G[Frame.."Tab"]

	if (Tab.noMouseAlpha == 0.4) or (Tab.noMouseAlpha == 0.2) then
		Tab:SetAlpha(0)
		Tab.noMouseAlpha = 0
	end
end

function Module:SetChatFont()
	local Font = K.GetFont(C["Chat"].Font)
	local Path, _, Flag = _G[Font]:GetFont()
	local CurrentFont, CurrentSize, CurrentFlag = self:GetFont()

	if (CurrentFont == Path and CurrentFlag == Flag) then
		return
	end

	self:SetFont(Path, CurrentSize, Flag)
end

function Module:StyleFrame(frame)
	if frame.IsSkinned then
		return
	end

	local Frame = frame
	local ID = frame:GetID()
	local FrameName = frame:GetName()
	local Tab = _G[FrameName.."Tab"]
	local TabText = _G[FrameName.."TabText"]
	local EditBox = _G[FrameName.."EditBox"]
	local GetTabFont = K.GetFont(C["Chat"].Font)
	local TabFont, TabFontSize, TabFontFlags = _G[GetTabFont]:GetFont()

	if Tab.conversationIcon then
		Tab.conversationIcon:Kill()
	end

	-- Hide editbox every time we click on a tab
	Tab:HookScript("OnClick", function()
		EditBox:Hide()
	end)

	-- Style the tab font
	TabText:SetFont(TabFont, TabFontSize + 1, TabFontFlags)
	TabText.SetFont = K.Noop

	if C["Chat"].TabsMouseover ~= true then
		-- Tabs Alpha
		Tab:SetAlpha(1)
		Tab.SetAlpha = UIFrameFadeRemoveFrame
	end

	Frame:SetClampRectInsets(0, 0, 0, 0)
	Frame:SetClampedToScreen(false)
	Frame:SetFading(C["Chat"].Fading)
	Frame:SetTimeVisible(C["Chat"].FadingTimeVisible)
	Frame:SetFadeDuration(C["Chat"].FadingTimeFading)

	-- Move the edit box
	EditBox:ClearAllPoints()
	EditBox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 2, 26)
	EditBox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", -2, 26)

	-- Disable alt key usage
	EditBox:SetAltArrowKeyMode(false)

	-- Hide editbox on login
	EditBox:Hide()

	-- Hide editbox instead of fading
	EditBox:HookScript("OnEditFocusLost", function(self)
		self:Hide()
	end)

	EditBox:HookScript("OnTextChanged", OnTextChanged)

	-- Create our own texture for edit box
	EditBox:SetTemplate("Transparent", false)
	EditBox:SetHeight(22)

	-- Hide textures
	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[FrameName..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	end

	-- Remove default chatframe tab textures
	_G[string_format("ChatFrame%sTabLeft", ID)]:Kill()
	_G[string_format("ChatFrame%sTabMiddle", ID)]:Kill()
	_G[string_format("ChatFrame%sTabRight", ID)]:Kill()

	_G[string_format("ChatFrame%sTabSelectedLeft", ID)]:Kill()
	_G[string_format("ChatFrame%sTabSelectedMiddle", ID)]:Kill()
	_G[string_format("ChatFrame%sTabSelectedRight", ID)]:Kill()

	_G[string_format("ChatFrame%sTabHighlightLeft", ID)]:Kill()
	_G[string_format("ChatFrame%sTabHighlightMiddle", ID)]:Kill()
	_G[string_format("ChatFrame%sTabHighlightRight", ID)]:Kill()

	_G[string_format("ChatFrame%sTabSelectedLeft", ID)]:Kill()
	_G[string_format("ChatFrame%sTabSelectedMiddle", ID)]:Kill()
	_G[string_format("ChatFrame%sTabSelectedRight", ID)]:Kill()

	_G[string_format("ChatFrame%sButtonFrameUpButton", ID)]:Kill()
	_G[string_format("ChatFrame%sButtonFrameDownButton", ID)]:Kill()
	_G[string_format("ChatFrame%sButtonFrameBottomButton", ID)]:Kill()
	_G[string_format("ChatFrame%sButtonFrameMinimizeButton", ID)]:Kill()
	_G[string_format("ChatFrame%sButtonFrame", ID)]:Kill()

	_G[string_format("ChatFrame%sEditBoxFocusLeft", ID)]:Kill()
	_G[string_format("ChatFrame%sEditBoxFocusMid", ID)]:Kill()
	_G[string_format("ChatFrame%sEditBoxFocusRight", ID)]:Kill()

	_G[string_format("ChatFrame%sEditBoxLeft", ID)]:Kill()
	_G[string_format("ChatFrame%sEditBoxMid", ID)]:Kill()
	_G[string_format("ChatFrame%sEditBoxRight", ID)]:Kill()

	-- Kill off editbox artwork
	local A, B, C = select(6, EditBox:GetRegions())
	A:Kill()
	B:Kill()
	C:Kill()

	if ID ~= 2 then
		if not hooks[frame] then
			hooks[frame] = {}
		end
		if not hooks[frame].AddMessage then
			hooks[frame].AddMessage = frame.AddMessage
			frame.AddMessage = AddMessage
		end
	end

	-- Mouse Wheel
	Frame:SetScript("OnMouseWheel", Module.OnMouseWheel)

	-- Temp Chats
	if (ID > 10) then
		self.SetChatFont(Frame)
	end

	-- Security for font, in case if revert back to WoW default we restore instantly the font.
	hooksecurefunc(Frame, "SetFont", Module.SetChatFont)

	Frame.IsSkinned = true
end

function Module:KillPetBattleCombatLog(Frame)
	if (_G[Frame:GetName().."Tab"]:GetText():match(PET_BATTLE_COMBAT_LOG)) then
		return FCF_Close(Frame)
	end
end

function Module:StyleTempFrame()
	local Frame = FCF_GetCurrentChatFrame()

	Module:KillPetBattleCombatLog(Frame)

	-- Make sure it"s not skinned already
	if Frame.IsSkinned then
		return
	end

	-- Pass it on
	Module:StyleFrame(Frame)
end

function Module:SetDefaultChatFramesPositions()
	if (not KkthnxUIData[GetRealmName()][UnitName("Player")].Chat) then
		KkthnxUIData[GetRealmName()][UnitName("Player")].Chat = {}
	end

	local Width = C["Chat"].Width
	local Height = C["Chat"].Height

	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		local ID = Frame:GetID()

		-- Set font size and chat frame size
		Frame:SetSize(Width, Height)

		-- move general bottom left
		if ID == 1 then
			Frame:ClearAllPoints()
			Frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 3, 3)
		end

		-- rename windows general because moved to chat #3
		if ID == 1 then
			FCF_SetWindowName(Frame, GENERAL)
		elseif ID == 2 then
			FCF_SetWindowName(Frame, GUILD_EVENT_LOG)
		elseif ID == 3 then
			FCF_SetWindowName(Frame, LOOT.." / "..TRADE)
		end

		if (not Frame.isLocked) then
			FCF_SetLocked(Frame, 1)
		end

		local Anchor1, Parent, Anchor2, X, Y = Frame:GetPoint()
		KkthnxUIData[GetRealmName()][UnitName("Player")].Chat["Frame"..i] = {Anchor1, Anchor2, X, Y, Width, Height}
	end
end

function Module:SaveChatFramePositionAndDimensions()
	local Anchor1, _, Anchor2, X, Y = self:GetPoint()
	local Width, Height = self:GetSize()
	local ID = self:GetID()

	if not (KkthnxUIData[GetRealmName()][UnitName("Player")].Chat) then
		KkthnxUIData[GetRealmName()][UnitName("Player")].Chat = {}
	end

	KkthnxUIData[GetRealmName()][UnitName("Player")].Chat["Frame"..ID] = {Anchor1, Anchor2, X, Y, Width, Height}
end

function Module:SetChatFramePosition()
	if (not KkthnxUIData[GetRealmName()][UnitName("Player")].Chat) then
		return
	end

	local Frame = self

	if not Frame:IsMovable() then
		return
	end

	local ID = Frame:GetID()
	local Settings = KkthnxUIData[GetRealmName()][UnitName("Player")].Chat["Frame"..ID]

	if Settings then
		local Anchor1, Anchor2, X, Y, Width, Height = unpack(Settings)

		Frame:SetUserPlaced(true)
		Frame:ClearAllPoints()
		Frame:SetPoint(Anchor1, UIParent, Anchor2, X, Y)
		-- Frame:SetSize(Width, Height)
		Frame:SetSize(C["Chat"].Width, C["Chat"].Height)
	end
end

function Module:Install()
	-- Create our custom chatframes
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)

	FCF_OpenNewWindow(LOOT)
	FCF_SetLocked(ChatFrame3, 1)
	FCF_DockFrame(ChatFrame3)

	-- Enable Classcolor
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND")
	ChatFrame_AddMessageGroup(ChatFrame1, "BATTLEGROUND_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")
	ChatFrame_AddMessageGroup(ChatFrame1, "BN_INLINE_TOAST_ALERT")


	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame3, "SKILL")
	ChatFrame_AddMessageGroup(ChatFrame3, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame3, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "COMBAT_GUILD_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame3, "CURRENCY")
	ChatFrame_AddChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, L.Chat.Trade)
	ChatFrame_AddChannel(ChatFrame3, L.Chat.Trade)


	if K.Name == "Kkthnx" and K.Realm == "Felsong" then
		SetCVar("scriptErrors", 1)
	end

	-- enable classcolor automatically on login and on each character without doing /configure each time.
	ToggleChatColorNamesByClassGroup(true, "SAY")
	ToggleChatColorNamesByClassGroup(true, "EMOTE")
	ToggleChatColorNamesByClassGroup(true, "YELL")
	ToggleChatColorNamesByClassGroup(true, "GUILD")
	ToggleChatColorNamesByClassGroup(true, "OFFICER")
	ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
	ToggleChatColorNamesByClassGroup(true, "WHISPER")
	ToggleChatColorNamesByClassGroup(true, "PARTY")
	ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID")
	ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
	ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
	ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
	ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL6")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL7")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL8")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL9")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL10")
	ToggleChatColorNamesByClassGroup(true, "CHANNEL11")

	-- Adjust Chat Colors
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255)
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255)
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255)

	DEFAULT_CHAT_FRAME:SetUserPlaced(true)

	self:SetDefaultChatFramesPositions()
end

function Module:OnMouseWheel(delta)
	if (delta < 0) then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			for i = 1, (C["Chat"].ScrollByX or 3) do
				self:ScrollDown()
			end
		end
	elseif (delta > 0) then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			for i = 1, (C["Chat"].ScrollByX or 3) do
				self:ScrollUp()
			end
		end
	end
end

function Module:PlayWhisperSound()
	PlaySoundFile(C["Media"].WhisperSound)
end

function Module:SwitchSpokenDialect(button)
	if (IsAltKeyDown() and button == "LeftButton") then
		ToggleFrame(ChatMenu)
	end
end

function Module:SetupFrame()
	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		local Tab = _G["ChatFrame"..i.."Tab"]

		Tab.noMouseAlpha = 0
		Tab:SetAlpha(0)
		Tab:HookScript("OnClick", self.SwitchSpokenDialect)

		self:StyleFrame(Frame)
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

	ChatConfigFrameDefaultButton:Kill()
	ChatFrameMenuButton:Kill()
	QuickJoinToastButton:Kill()
end

function Module:OnEnable()
	if (not C["Chat"].Enable) then
		return
	end

	self:SetShortenChannelNames()
	self:SetupFrame()
	self:SecureHook("ChatEdit_UpdateHeader", Module.UpdateEditBoxColor)
	self:SecureHook("FCF_OpenTemporaryWindow", Module.StyleTempFrame)
	self:SecureHook("FCF_RestorePositionAndDimensions", Module.SetChatFramePosition)
	self:SecureHook("FCF_SavePositionAndDimensions", Module.SaveChatFramePositionAndDimensions)
	self:SecureHook("FCFTab_UpdateAlpha", Module.NoMouseAlpha)

	for i = 1, 10 do
		local ChatFrame = _G["ChatFrame"..i]

		self.SetChatFramePosition(ChatFrame)
		self.SetChatFont(ChatFrame)
	end

	if (not C["Chat"].WhisperSound) then
		return
	end

	local Whisper = CreateFrame("Frame")
	Whisper:RegisterEvent("CHAT_MSG_WHISPER")
	Whisper:RegisterEvent("CHAT_MSG_BN_WHISPER")
	Whisper:SetScript("OnEvent", function(self, event)
		Module:PlayWhisperSound()
	end)
end