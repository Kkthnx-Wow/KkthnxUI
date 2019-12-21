local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Chat")

local _G = _G
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_len = _G.string.len
local string_sub = _G.string.sub
local unpack = _G.unpack

local ChatEdit_ChooseBoxForSend = _G.ChatEdit_ChooseBoxForSend
local ChatEdit_ParseText = _G.ChatEdit_ParseText
local ChatFrame1 = _G.ChatFrame1
local ChatFrame2 = _G.ChatFrame2
local ChatFrame3 = _G.ChatFrame3
local ChatFrame_AddChannel = _G.ChatFrame_AddChannel
local ChatFrame_AddMessageGroup = _G.ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = _G.ChatFrame_RemoveAllMessageGroups
local ChatFrame_RemoveChannel = _G.ChatFrame_RemoveChannel
local ChatFrame_SendTell = _G.ChatFrame_SendTell
local ChatTypeInfo = _G.ChatTypeInfo
local CreateFrame = _G.CreateFrame
local FCF_Close = _G.FCF_Close
local FCF_DockFrame = _G.FCF_DockFrame
local FCF_GetCurrentChatFrame = _G.FCF_GetCurrentChatFrame
local FCF_OpenNewWindow = _G.FCF_OpenNewWindow
local FCF_ResetChatWindows = _G.FCF_ResetChatWindows
local FCF_SetLocked = _G.FCF_SetLocked
local FCF_SetWindowName = _G.FCF_SetWindowName
local GetChannelName = _G.GetChannelName
local GetRealmName = _G.GetRealmName
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGroup = _G.IsInGroup
local InCombatLockdown = _G.InCombatLockdown
local IsInRaid = _G.IsInRaid
local IsShiftKeyDown = _G.IsShiftKeyDown
local LE_REALM_RELATION_SAME = _G.LE_REALM_RELATION_SAME
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PlaySoundFile = _G.PlaySoundFile
local ToggleFrame = _G.ToggleFrame
local UIParent = _G.UIParent
local GetInstanceInfo = _G.GetInstanceInfo
local UnitName = _G.UnitName
local UnitRealmRelationship = _G.UnitRealmRelationship
local hooksecurefunc = _G.hooksecurefunc

local function GetGroupDistribution()
	local _, instanceType = GetInstanceInfo()
	if instanceType == "pvp" then
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

local function OnTextChanged(editbox)
	local text = editbox:GetText()

	if InCombatLockdown() then
		local MIN_REPEAT_CHARACTERS = 5
		if string_len(text) > MIN_REPEAT_CHARACTERS then
			local repeatChar = true
			for i = 1, MIN_REPEAT_CHARACTERS, 1 do
				if string_sub(text, (0 - i), (0 - i)) ~= string_sub(text,(-1 - i),(-1 - i)) then
					repeatChar = false
					break
				end
			end

			if repeatChar then
				editbox:Hide()
				return
			end
		end
	end

	if string_len(text) < 5 then
		if string_sub(text, 1, 4) == "/tt " then
			local unitname, realm = UnitName("target")
			if unitname then
				unitname = string_gsub(unitname, " ", "")
			end

			if unitname and UnitRealmRelationship("target") ~= LE_REALM_RELATION_SAME then
				unitname = string_format("%s-%s", unitname, string_gsub(realm, " ", ""))
			end

			ChatFrame_SendTell((unitname or "Invalid Target"), ChatFrame1)
		end

		if string_sub(text, 1, 4) == "/gr " then
			editbox:SetText(GetGroupDistribution()..string_sub(text, 5))
			ChatEdit_ParseText(editbox, 0)
		end
	end

	editbox.CharacterCount:SetText((255 - string_len(text)))
end

-- Update editbox border color
function Module:UpdateEditBoxColor()
	local editbox = ChatEdit_ChooseBoxForSend()
	local chatType = editbox:GetAttribute("chatType")

	if not chatType then
		return
	end

	local info = ChatTypeInfo[chatType]
	local chanTarget = editbox:GetAttribute("channelTarget")
	local chanName = chanTarget and GetChannelName(chanTarget)

	-- Increase inset on right side to make room for character count text
	local insetLeft, insetRight, insetTop, insetBottom = editbox:GetTextInsets()
	editbox:SetTextInsets(insetLeft, insetRight + 26, insetTop, insetBottom)

	if chanName and (chatType == "CHANNEL") then
		if chanName == 0 then
			editbox:SetBackdropBorderColor()
		else
			info = ChatTypeInfo[chatType..chanName]
			editbox:SetBackdropBorderColor(info.r, info.g, info.b)
		end
	else
		editbox:SetBackdropBorderColor(info.r, info.g, info.b)
	end
end

function Module:MoveAudioButtons()
	ChatFrameChannelButton:Kill()
	ChatFrameToggleVoiceDeafenButton:Kill()
	ChatFrameToggleVoiceMuteButton:Kill()
end

function Module:NoMouseAlpha()
	local Frame = self:GetName()
	local Tab = _G[Frame.."Tab"]

	if (Tab.noMouseAlpha == 0.4) or (Tab.noMouseAlpha == 0.2) then
		Tab:SetAlpha(0.25)
		Tab.noMouseAlpha = 0.25
	end
end

function Module:UpdateTabColors(selected)
	if selected then
		self:GetFontString():SetTextColor(1, .8, 0)
	else
		self:GetFontString():SetTextColor(.5, .5, .5)
	end
end

function Module:SetChatFont()
	local Font = K.GetFont(C["UIFonts"].ChatFonts)
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
	local Scroll = frame.ScrollBar
	local ScrollBottom = frame.ScrollToBottomButton
	local ScrollTex = _G[FrameName.."ThumbTexture"]
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

	-- Kill Scroll Bars
	if Scroll then
		Scroll:Kill()
		ScrollBottom:Kill()
		ScrollTex:Kill()
	end

	-- Style the tab font
	TabText:SetFont(TabFont, TabFontSize, TabFontFlags)
	TabText.SetFont = K.Noop

	-- Tabs Alpha
	if C["Chat"].TabsMouseover ~= true then
		Tab:SetAlpha(1)
		Tab.SetAlpha = _G.UIFrameFadeRemoveFrame
	end

	Frame:SetClampRectInsets(0, 0, 0, 0)
	Frame:SetClampedToScreen(false)
	Frame:SetFading(C["Chat"].Fading)
	Frame:SetTimeVisible(C["Chat"].FadingTimeVisible)
	Frame:SetFadeDuration(C["Chat"].FadingTimeFading)

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
	EditBox:ClearAllPoints()
	EditBox:SetPoint("BOTTOM", ChatFrame1, "TOP", 10, 24)
	if C["Chat"].Background then
		EditBox:SetSize(C["Chat"].Width + 29, 24)
	else
		EditBox:SetSize(C["Chat"].Width + 18, 24)
	end
	EditBox:CreateBorder()

	-- Character count
	EditBox.CharacterCount = EditBox:CreateFontString()
	EditBox.CharacterCount:FontTemplate()
	EditBox.CharacterCount:SetTextColor(68/255, 136/255, 255/255, 0.5)
	EditBox.CharacterCount:SetPoint("TOPRIGHT", EditBox, "TOPRIGHT", 0, -1)
	EditBox.CharacterCount:SetPoint("BOTTOMRIGHT", EditBox, "BOTTOMRIGHT", 0, -1)
	EditBox.CharacterCount:SetJustifyH("CENTER")
	EditBox.CharacterCount:SetWidth(30)

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

	_G[string_format("ChatFrame%sButtonFrameMinimizeButton", ID)]:Kill()
	_G[string_format("ChatFrame%sButtonFrame", ID)]:Kill()

	_G[string_format("ChatFrame%sEditBoxFocusLeft", ID)]:Kill()
	_G[string_format("ChatFrame%sEditBoxFocusMid", ID)]:Kill()
	_G[string_format("ChatFrame%sEditBoxFocusRight", ID)]:Kill()

	_G[string_format("ChatFrame%sEditBoxLeft", ID)]:Kill()
	_G[string_format("ChatFrame%sEditBoxMid", ID)]:Kill()
	_G[string_format("ChatFrame%sEditBoxRight", ID)]:Kill()

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
	if (_G[Frame:GetName().."Tab"]:GetText():match(_G.PET_BATTLE_COMBAT_LOG)) then
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
	if (not KkthnxUIData[GetRealmName()][UnitName("player")].Chat) then
		KkthnxUIData[GetRealmName()][UnitName("player")].Chat = {}
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local Frame = _G["ChatFrame"..i]
		local ID = Frame:GetID()

		-- Set font size and chat frame size
		Frame:SetSize(C["Chat"].Width, C["Chat"].Height)

		-- Move general bottom left
		if ID == 1 then
			Frame:ClearAllPoints()
			if C["Chat"].Background then
				Frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 8, 7)
			else
				Frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 3, 3)
			end
		end

		if (not Frame.isLocked) then
			FCF_SetLocked(Frame, 1)
		end

		local Anchor1, _, Anchor2, X, Y = Frame:GetPoint()
		KkthnxUIData[GetRealmName()][UnitName("player")].Chat["Frame"..i] = {Anchor1, Anchor2, X, Y, C["Chat"].Width, C["Chat"].Height}
	end
end

function Module:SaveChatFramePositionAndDimensions()
	local Anchor1, _, Anchor2, X, Y = self:GetPoint()
	local Width, Height = self:GetSize()
	local ID = self:GetID()

	if not (KkthnxUIData[GetRealmName()][UnitName("player")].Chat) then
		KkthnxUIData[GetRealmName()][UnitName("player")].Chat = {}
	end

	KkthnxUIData[GetRealmName()][UnitName("player")].Chat["Frame"..ID] = {Anchor1, Anchor2, X, Y, Width, Height}
end

function Module:SetChatFramePosition()
	if (not KkthnxUIData[GetRealmName()][UnitName("player")].Chat) then
		return
	end

	local Frame = self

	if not Frame:IsMovable() then
		return
	end

	local ID = Frame:GetID()
	local Settings = KkthnxUIData[GetRealmName()][UnitName("player")].Chat["Frame"..ID]

	if Settings then
		local Anchor1, Anchor2, X, Y = unpack(Settings)

		Frame:SetUserPlaced(true)
		Frame:ClearAllPoints()
		Frame:SetPoint(Anchor1, UIParent, Anchor2, X, Y)
		Frame:SetSize(C["Chat"].Width, C["Chat"].Height)
	end
end

function Module:Install()
	-- General
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_SetWindowName(ChatFrame1, L["General"])
	ChatFrame1:Show()

	-- Combat Log
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_SetWindowName(ChatFrame2, L["Combat"])
	ChatFrame2:Show()

	-- Whispers
	FCF_OpenNewWindow(L["Whisper"])
	FCF_SetLocked(ChatFrame3, 1)
	FCF_DockFrame(ChatFrame3)
	ChatFrame3:Show()

	-- Trade
	FCF_OpenNewWindow(L["Trade"])
	FCF_SetLocked(ChatFrame4, 1)
	FCF_DockFrame(ChatFrame4)
	ChatFrame4:Show()

	-- Loot
	FCF_OpenNewWindow(L["Loot"])
	FCF_SetLocked(ChatFrame5, 1)
	FCF_DockFrame(ChatFrame5)
	ChatFrame5:Show()

	-- General
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	ChatFrame_RemoveChannel(ChatFrame1, TRADE)
	ChatFrame_RemoveChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, "LocalDefense")
	ChatFrame_RemoveChannel(ChatFrame1, "GuildRecruitment")
	ChatFrame_RemoveChannel(ChatFrame1, "LookingForGroup")

	ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
	ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
	ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
	ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
	ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
	ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
	ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
	ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
	ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
	ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
	ChatFrame_AddMessageGroup(ChatFrame1, "DND")
	ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
	ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")

	-- Whispers
	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	ChatFrame_AddMessageGroup(ChatFrame3, "WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame3, "BN_WHISPER")
	ChatFrame_AddMessageGroup(ChatFrame3, "BN_CONVERSATION")

	-- Trade
	ChatFrame_RemoveAllMessageGroups(ChatFrame4)
	ChatFrame_AddChannel(ChatFrame4, TRADE)
	ChatFrame_AddChannel(ChatFrame4, GENERAL)

	-- Loot
	ChatFrame_RemoveAllMessageGroups(ChatFrame5)
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_XP_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_HONOR_GAIN")
	ChatFrame_AddMessageGroup(ChatFrame5, "COMBAT_FACTION_CHANGE")
	ChatFrame_AddMessageGroup(ChatFrame5, "LOOT")
	ChatFrame_AddMessageGroup(ChatFrame5, "MONEY")
	ChatFrame_AddMessageGroup(ChatFrame5, "SKILL")

	DEFAULT_CHAT_FRAME:SetUserPlaced(true)

	-- MoveChatFrames()
	FCF_SelectDockFrame(ChatFrame1)

	-- Adjust Chat Colors
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255) -- General
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255) -- Trade
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255) -- Local Defense

	self:SetDefaultChatFramesPositions()
end

function Module:OnMouseWheel(delta)
	if (delta < 0) then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			for _ = 1, (C["Chat"].ScrollByX or 3) do
				self:ScrollDown()
			end
		end
	elseif (delta > 0) then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			for _ = 1, (C["Chat"].ScrollByX or 3) do
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

		Tab.noMouseAlpha = 0.25
		Tab:SetAlpha(0.25)
		Tab:HookScript("OnClick", self.SwitchSpokenDialect)

		self:StyleFrame(Frame)

		if i == 2 then
			if CombatLogQuickButtonFrame then
				CombatLogQuickButtonFrame_Custom:Hide()
			end
		else
			if C["Chat"].ShortenChannelNames then
				local am = Frame.AddMessage

				Frame.AddMessage = function(frame, text, ...)
					return am(frame, text:gsub("|h%[(%d+)%. .-%]|h", "|h%1|h"), ...)
				end
			end
		end
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

	QuickJoinToastButton:ClearAllPoints()
	QuickJoinToastButton:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -1, -18)
	QuickJoinToastButton:EnableMouse(false)
	QuickJoinToastButton.ClearAllPoints = K.Noop
	QuickJoinToastButton.SetPoint = K.Noop
	QuickJoinToastButton:SetAlpha(0)

	ChatMenu:ClearAllPoints()
	ChatMenu:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 28, 10)

	VoiceChatPromptActivateChannel:CreateShadow(true)
	VoiceChatPromptActivateChannel.AcceptButton:SkinButton()
	VoiceChatPromptActivateChannel.CloseButton:SkinCloseButton()
	VoiceChatPromptActivateChannel:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 14)
	VoiceChatPromptActivateChannel.ClearAllPoints = K.Noop
	VoiceChatPromptActivateChannel.SetPoint = K.Noop

	if C["Chat"].ShortenChannelNames then
		-- Online/Offline Info
		_G.ERR_FRIEND_ONLINE_SS = string_gsub(_G.ERR_FRIEND_ONLINE_SS, "%]%|h", "]|h|cff00c957")
		_G.ERR_FRIEND_OFFLINE_S = string_gsub(_G.ERR_FRIEND_OFFLINE_S, "%%s", "%%s|cffff7f50")

		-- Guild
		_G.CHAT_GUILD_GET = "|Hchannel:GUILD|hG|h %s "
		_G.CHAT_OFFICER_GET = "|Hchannel:OFFICER|hO|h %s "

		-- Raid
		_G.CHAT_RAID_GET = "|Hchannel:RAID|hR|h %s "
		_G.CHAT_RAID_WARNING_GET = "RW %s "
		_G.CHAT_RAID_LEADER_GET = "|Hchannel:RAID|hRL|h %s "

		-- Party
		_G.CHAT_PARTY_GET = "|Hchannel:PARTY|hP|h %s "
		_G.CHAT_PARTY_LEADER_GET ="|Hchannel:PARTY|hPL|h %s "
		_G.CHAT_PARTY_GUIDE_GET ="|Hchannel:PARTY|hPG|h %s "

		-- Instance
		_G.CHAT_INSTANCE_CHAT_GET = "|Hchannel:INSTANCE|hI|h %s "
		_G.CHAT_INSTANCE_CHAT_LEADER_GET ="|Hchannel:INSTANCE|hIL|h %s "

		-- Battleground
		_G.CHAT_BATTLEGROUND_GET = "|Hchannel:BATTLEGROUND|hB|h %s "
		_G.CHAT_BATTLEGROUND_LEADER_GET = "|Hchannel:BATTLEGROUND|hBL|h %s "

		-- Whisper
		_G.CHAT_WHISPER_INFORM_GET = "to %s "
		_G.CHAT_WHISPER_GET = "from %s "
		_G.CHAT_BN_WHISPER_INFORM_GET = "to %s "
		_G.CHAT_BN_WHISPER_GET = "from %s "

		-- Say/Yell
		_G.CHAT_SAY_GET = "%s "
		_G.CHAT_YELL_GET = "%s "

		-- Flags
		_G.CHAT_FLAG_AFK = "[AFK] "
		_G.CHAT_FLAG_DND = "[DND] "
		_G.CHAT_FLAG_GM = "[GM] "
	end
end

function Module:OnEnable()
	if (not C["Chat"].Enable) then
		return
	end

	self:MoveAudioButtons()
	self:SetupFrame()

	hooksecurefunc("ChatEdit_UpdateHeader", Module.UpdateEditBoxColor)
	hooksecurefunc("FCF_OpenTemporaryWindow", Module.StyleTempFrame)
	hooksecurefunc("FCF_RestorePositionAndDimensions", Module.SetChatFramePosition)
	hooksecurefunc("FCF_SavePositionAndDimensions", Module.SaveChatFramePositionAndDimensions)
	hooksecurefunc("FCFTab_UpdateAlpha", Module.NoMouseAlpha)
	hooksecurefunc("FCFTab_UpdateColors", Module.UpdateTabColors)

	-- Combat Log Skinning (credit: Aftermathh)
	local CombatLogButton = _G.CombatLogQuickButtonFrame_Custom
	if CombatLogButton then
		local CombatLogFontContainer = _G.ChatFrame2 and _G.ChatFrame2.FontStringContainer
		CombatLogButton:StripTextures()
		CombatLogButton:CreateShadow(true)

		if CombatLogFontContainer then
			CombatLogButton:ClearAllPoints()
			CombatLogButton:SetPoint("BOTTOMLEFT", CombatLogFontContainer, "TOPLEFT", -1, 1)
			CombatLogButton:SetPoint("BOTTOMRIGHT", CombatLogFontContainer, "TOPRIGHT", 0, 1)
		end

		for i = 1, 2 do
			local CombatLogQuickButton = _G["CombatLogQuickButtonFrameButton"..i]
			if CombatLogQuickButton then
				local CombatLogText = CombatLogQuickButton:GetFontString()
				CombatLogText:FontTemplate(nil, nil, "OUTLINE")
			end
		end

		local CombatLogProgressBar = _G.CombatLogQuickButtonFrame_CustomProgressBar
		CombatLogProgressBar:SetStatusBarTexture(C.Media.Texture)
		CombatLogProgressBar:SetInside(CombatLogButton)
		_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetSize(20, 22)
		_G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetPoint("TOPRIGHT", CombatLogButton, "TOPRIGHT", 0, -1)
		_G.CombatLogQuickButtonFrame_CustomTexture:Hide()
	end

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
	Whisper:SetScript("OnEvent", function()
		Module:PlayWhisperSound()
	end)

	if C["Chat"].Background then
		local ChatFrameBG = CreateFrame("Frame", "KKUI_ChatFrameBG", UIParent)
		ChatFrameBG:SetSize(C["Chat"].Width + 29, C["Chat"].Height + 8)
		ChatFrameBG:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -4, 5)
		ChatFrameBG:SetFrameStrata("BACKGROUND")
		ChatFrameBG:CreateBorder()
	end

	self:CreateChatFilter()
	self:CreateCopyChat()
	self:CreateCopyURL()
end