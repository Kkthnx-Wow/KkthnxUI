local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Chat")

local _G = _G
local string_find = _G.string.find
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_len = _G.string.len
local string_sub = _G.string.sub

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
local FCF_DockFrame = _G.FCF_DockFrame
local FCF_GetCurrentChatFrame = _G.FCF_GetCurrentChatFrame
local FCF_OpenNewWindow = _G.FCF_OpenNewWindow
local FCF_ResetChatWindows = _G.FCF_ResetChatWindows
local FCF_SetLocked = _G.FCF_SetLocked
local FCF_SetWindowName = _G.FCF_SetWindowName
local GetChannelName = _G.GetChannelName
local GetInstanceInfo = _G.GetInstanceInfo
local GetItemIcon = _G.GetItemIcon
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local IsShiftKeyDown = _G.IsShiftKeyDown
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PlaySoundFile = _G.PlaySoundFile
local UIParent = _G.UIParent
local UnitName = _G.UnitName
local hooksecurefunc = _G.hooksecurefunc

local repeatedText
local isBattleNet

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

local function OnTextChanged(EditBox)
	local text = EditBox:GetText()
	local len = string_len(text)

	if (not repeatedText or not string_find(text, repeatedText, 1, true)) and InCombatLockdown() then
		local MIN_REPEAT_CHARACTERS = 5
		if len > MIN_REPEAT_CHARACTERS then
			local repeatChar = true
			for i = 1, MIN_REPEAT_CHARACTERS, 1 do
				local first = -1 - i
				if string_sub(text, -i, -i) ~= string_sub(text, first, first) then
					repeatChar = false
					break
				end
			end

			if repeatChar then
				repeatedText = text
				EditBox:Hide()
				return
			end
		end
	end

	if len == 4 then
		if text == "/tt " then
			local Name, Realm = UnitName("target")
			if Name then
				Name = string_gsub(Name,"%s", "")

				if Realm and Realm ~= "" then
					Name = string_format("%s-%s", Name, string_gsub(Realm,"[%s%-]", ""))
				end
			end

			ChatFrame_SendTell(Name or "Invalid Target", _G.ChatFrame1)
		elseif text == "/gr " then
			EditBox:SetText(GetGroupDistribution()..string_sub(text, 5))
			ChatEdit_ParseText(EditBox, 0)
		end
	end

	EditBox.CharacterCount:SetText(len > 0 and (255 - len) or "")

	if repeatedText then
		repeatedText = nil
	end
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
			editbox.KKUI_Border:SetVertexColor(1, 1, 1)
		else
			info = ChatTypeInfo[chatType..chanName]
			editbox.KKUI_Border:SetVertexColor(info.r, info.g, info.b)
		end
	else
		editbox.KKUI_Border:SetVertexColor(info.r, info.g, info.b)
	end
end

function Module:LockChat()
	K.Print("Please use "..K.SystemColor.."/moveui or /mm|r to move ChatFrames")
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
	if self.glow:IsShown() then
		if isBattleNet then
			self:GetFontString():SetTextColor(0, 1, 0.96)
		else
			self:GetFontString():SetTextColor(1, 0.5, 1)
		end
	elseif selected then
		self:GetFontString():SetTextColor(1, 0.8, 0)
	else
		self:GetFontString():SetTextColor(0.5, 0.5, 0.5)
	end
end

function Module:UpdateTabEventColors(event)
	local Frame = self:GetName()
	local Tab = _G[Frame.."Tab"]

	if event == "CHAT_MSG_WHISPER" then
		isBattleNet = nil
		FCFTab_UpdateColors(Tab, GeneralDockManager.selected:GetID() == Tab:GetID())
	elseif event == "CHAT_MSG_BN_WHISPER" then
		isBattleNet = true
		FCFTab_UpdateColors(Tab, GeneralDockManager.selected:GetID() == Tab:GetID())
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
	-- Frame:CreateBorder()

	-- Move the edit box
	EditBox:ClearAllPoints()
	if C["Chat"].Background then
		EditBox:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", -4, 36)
	else
		EditBox:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 1, 36)
	end
	EditBox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 22, 62)

	-- Disable alt key usage
	EditBox:SetAltArrowKeyMode(false)

	EditBox:HookScript("OnTextChanged", OnTextChanged)

	-- Hide editbox on login
	EditBox:Hide()

	-- Hide editbox instead of fading
	EditBox:HookScript("OnEditFocusLost", function(self)
		self:Hide()
	end)

	-- Create our own texture for edit box
	EditBox:CreateBorder()

	-- Character count
	EditBox.CharacterCount = EditBox:CreateFontString()
	EditBox.CharacterCount:FontTemplate()
	EditBox.CharacterCount:SetTextColor(123/255, 132/255, 137/255, 0.7)
	EditBox.CharacterCount:SetPoint("TOPRIGHT", EditBox, "TOPRIGHT", 0, 0)
	EditBox.CharacterCount:SetPoint("BOTTOMRIGHT", EditBox, "BOTTOMRIGHT", 0, 0)
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

function Module:StyleTempFrame()
	local Frame = FCF_GetCurrentChatFrame()

	-- Make sure it"s not skinned already
	if Frame.IsSkinned then
		return
	end

	-- Pass it on
	Module:StyleFrame(Frame)
end

function Module:SaveChatFramePositionAndDimensions()
	local Anchor1, _, Anchor2, X, Y = self:GetPoint()
	local Width, Height = self:GetSize()
	local ID = self:GetID()

	KkthnxUIData[K.Realm][K.Name].Chat["Frame"..ID] = {Anchor1, Anchor2, X, Y, Width, Height}
end

function Module:SetChatFramePosition()
	local Frame = self
	local ID = Frame:GetID()
	local Settings = KkthnxUIData[K.Realm][K.Name].Chat["Frame"..ID]

	if Settings then
		if ID == 1 then
			Frame:SetUserPlaced(true)
			Frame:ClearAllPoints()
			Frame:SetSize(C["Chat"].Width, C["Chat"].Height)
			Frame:ClearAllPoints()
			if C["Chat"].Background then
				Frame.Position = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 8, 8}
			else
				Frame.Position = {"BOTTOMLEFT", UIParent, "BOTTOMLEFT", 3, 3}
			end

			Frame.mover = K.Mover(Frame, "ChatFrame", "ChatFrame", Frame.Position, C["Chat"].Width, C["Chat"].Height)
		end
	end
end

function Module:Install()
	local IsPublicChannelFound = EnumerateServerChannels()
	if not IsPublicChannelFound then
		-- Restart this function until we are able to query public channels
		C_Timer.After(1, Module.Install)
		return
	end

	-- Create our custom chatframes
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_OpenNewWindow(TRADE)
	FCF_SetLocked(ChatFrame3, 1)
	FCF_DockFrame(ChatFrame3)
	FCF_OpenNewWindow(LOOT)
	FCF_SetLocked(ChatFrame4, 1)
	FCF_DockFrame(ChatFrame4)
	FCF_SetChatWindowFontSize(nil, ChatFrame1, 12)
	FCF_SetChatWindowFontSize(nil, ChatFrame2, 12)
	FCF_SetChatWindowFontSize(nil, ChatFrame3, 12)
	FCF_SetChatWindowFontSize(nil, ChatFrame4, 12)
	FCF_SetWindowName(ChatFrame1, GENERAL)
	FCF_SetWindowName(ChatFrame2, GUILD_EVENT_LOG)

	DEFAULT_CHAT_FRAME:SetUserPlaced(true)

	local ChatGroups = {"SYSTEM", "CHANNEL", "SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "ERRORS", "AFK", "DND", "IGNORED", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "BN_WHISPER", "BN_INLINE_TOAST_ALERT"}
	ChatFrame_RemoveAllMessageGroups(_G.ChatFrame1)
	for _, v in ipairs(ChatGroups) do
		ChatFrame_AddMessageGroup(_G.ChatFrame1, v)
	end

	ChatFrame_RemoveAllMessageGroups(_G.ChatFrame3)

	ChatGroups = {"COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "CURRENCY", "MONEY"}
	ChatFrame_RemoveAllMessageGroups(_G.ChatFrame4)
	for _, v in ipairs(ChatGroups) do
		ChatFrame_AddMessageGroup(_G.ChatFrame4, v)
	end

	ChatFrame_AddChannel(_G.ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(_G.ChatFrame1, TRADE)
	ChatFrame_AddChannel(_G.ChatFrame3, TRADE)

	ChatGroups = {"SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "COMMUNITIES_CHANNEL"}
	for i = 1, _G.MAX_WOW_CHAT_CHANNELS do
		table.insert(ChatGroups, "CHANNEL"..i)
	end

	for _, v in ipairs(ChatGroups) do
		ToggleChatColorNamesByClassGroup(true, v)
	end

	-- Adjust Chat Colors
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255) -- General
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255) -- Trade
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255) -- Local Defense

	FCF_SelectDockFrame(ChatFrame1)
end

function Module:OnMouseWheel(delta)
	if (delta < 0) then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			self:ScrollDown()
		end
	elseif (delta > 0) then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			self:ScrollUp()
		end
	end
end

function Module:PlayWhisperSound()
	PlaySoundFile(C["Media"].WhisperSound)
end

function Module:SwitchSpokenDialect(button)
	if (IsAltKeyDown() and button == "LeftButton") then
		K.TogglePanel(ChatMenu)
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
			CombatLogQuickButtonFrame_Custom:StripTextures()
		end
	end

	-- Remember last channel
	ChatTypeInfo.WHISPER.sticky = 1
	ChatTypeInfo.BN_WHISPER.sticky = 1
	ChatTypeInfo.OFFICER.sticky = 1
	ChatTypeInfo.RAID_WARNING.sticky = 1
	ChatTypeInfo.CHANNEL.sticky = 1
end

function Module:CreateChatLootIcons(_, message, ...)
	if not C["Chat"].LootIcons then
		return
	end

	if IsAddOnLoaded("ChatLinkIcons") then
		return
	end

	local function Icon(link)
		local texture = GetItemIcon(link)
		return "\124T"..texture..":12:12:0:0:64:64:5:59:5:59\124t"..link
	end

	message = message:gsub("(\124c%x+\124Hitem:.-\124h\124r)", Icon)

	return false, message, ...
end

function Module:OnEnable()
	if not C["Chat"].Enable then
		return
	end

	Module:SetupFrame()

	hooksecurefunc("ChatEdit_UpdateHeader", Module.UpdateEditBoxColor)
	hooksecurefunc("FCF_OpenTemporaryWindow", Module.StyleTempFrame)
	hooksecurefunc("FCF_RestorePositionAndDimensions", Module.SetChatFramePosition)
	hooksecurefunc("FCF_SavePositionAndDimensions", Module.SaveChatFramePositionAndDimensions)
	hooksecurefunc("FCFTab_UpdateAlpha", Module.NoMouseAlpha)
	hooksecurefunc("FCFTab_UpdateColors", Module.UpdateTabColors)
	hooksecurefunc("FloatingChatFrame_OnEvent", Module.UpdateTabEventColors)

	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", Module.CreateChatLootIcons)

	for i = 1, 10 do
		local ChatFrame = _G["ChatFrame"..i]

		Module.SetChatFramePosition(ChatFrame)
		Module.SetChatFont(ChatFrame)
	end

	FCF_ToggleLock = Module.LockChat
	FCF_ToggleLockOnDockedFrame = Module.LockChat

	if C["Chat"].WhisperSound then
		K:RegisterEvent("CHAT_MSG_WHISPER", Module.PlayWhisperSound)
		K:RegisterEvent("CHAT_MSG_BN_WHISPER", Module.PlayWhisperSound)
	else
		K:UnregisterEvent("CHAT_MSG_WHISPER", Module.PlayWhisperSound)
		K:UnregisterEvent("CHAT_MSG_BN_WHISPER", Module.PlayWhisperSound)
	end

	if C["Chat"].Background then
		local ChatFrameBG = CreateFrame("Frame", "KKUI_ChatFrameBG", UIParent)
		ChatFrameBG:SetSize(C["Chat"].Width + 26, C["Chat"].Height + 34)
		ChatFrameBG:SetPoint("TOPLEFT", ChatFrame1, "TOPLEFT", -4, 30)
		ChatFrameBG:SetFrameStrata("BACKGROUND")
		ChatFrameBG:CreateBorder()

		local ChatTabsBG = CreateFrame("Frame", nil, ChatFrameBG)
		ChatTabsBG:CreateBorder()
		ChatTabsBG:SetSize(C["Chat"].Width + 16, 24)
		ChatTabsBG:SetPoint("TOP", ChatFrameBG, "TOP", 0, -5)
		ChatTabsBG:SetFrameLevel(2)
	end

	self:CreateChatFilter()
	self:CreateChatItemLevels()
	self:CreateChatRename()
	self:CreateCopyChat()
	self:CreateCopyURL()
	self:CreateVoiceActivity()
end