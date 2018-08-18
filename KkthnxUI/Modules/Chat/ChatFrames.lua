local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Chat", "AceTimer-3.0", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local pairs = pairs
local select = select
local string_format = string.format
local string_gsub = string.gsub
local string_len = string.len
local string_sub = string.sub
local table_insert = table.insert
local table_remove = table.remove
local unpack = unpack

local ChangeChatColor = _G.ChangeChatColor
local ChatEdit_ChooseBoxForSend = _G.ChatEdit_ChooseBoxForSend
local ChatEdit_ParseText = _G.ChatEdit_ParseText
local ChatFrame_AddChannel = _G.ChatFrame_AddChannel
local ChatFrame_AddMessageGroup = _G.ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = _G.ChatFrame_RemoveAllMessageGroups
local ChatFrame_RemoveChannel = _G.ChatFrame_RemoveChannel
local ChatFrame_SendTell = _G.ChatFrame_SendTell
local ChatFrame_SystemEventHandler = _G.ChatFrame_SystemEventHandler
local ChatTypeInfo = _G.ChatTypeInfo
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
local GetGuildRosterMOTD = _G.GetGuildRosterMOTD
local GetRealmName = _G.GetRealmName
local hooksecurefunc = _G.hooksecurefunc
local IsAltKeyDown = _G.IsAltKeyDown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local IsShiftKeyDown = _G.IsShiftKeyDown
local LE_REALM_RELATION_SAME = _G.LE_REALM_RELATION_SAME
local LOOT = _G.LOOT
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PlaySoundFile = _G.PlaySoundFile
local ToggleChatColorNamesByClassGroup = _G.ToggleChatColorNamesByClassGroup
local ToggleFrame = _G.ToggleFrame
local TRADE = TRADE
local UIParent = _G.UIParent
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitName = _G.UnitName
local UnitRealmRelationship = _G.UnitRealmRelationship

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

	local maxRepeats = UnitAffectingCombat("player") and 5 or 10
	if (string_len(text) > maxRepeats) then
		local stuck = true
		for i = 1, maxRepeats, 1 do
			if (string_sub(text, 0 - i, 0 - i) ~= string_sub(text, (-1 - i), (-1 - i))) then
				stuck = false
				break
			end
		end
		if stuck then
			self:SetText("")
			self:Hide()
			return
		end
	end

	if text:len() < 5 then
		if text:sub(1, 4) == "/tt " then
			local unitname, realm = UnitName("target")
			if unitname then
				unitname = string_gsub(unitname, " ", "")
			end
			if unitname and UnitRealmRelationship("target") ~= LE_REALM_RELATION_SAME then
				unitname = string_format("%s-%s", unitname, string_gsub(realm, " ", ""))
			end
			ChatFrame_SendTell((unitname or L["Chat"].Invaild_Target), ChatFrame1)
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

-- Update editbox border color
function Module:UpdateEditBoxColor()
	local EditBox = ChatEdit_ChooseBoxForSend()
	local ChatType = EditBox:GetAttribute("chatType")

	if (ChatType == "CHANNEL") then
		local ID = GetChannelName(EditBox:GetAttribute("channelTarget"))

		if ID == 0 then
			EditBox:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		else
			EditBox:SetBackdropBorderColor(ChatTypeInfo[ChatType .. ID].r, ChatTypeInfo[ChatType .. ID].g, ChatTypeInfo[ChatType .. ID].b)
		end
	else
		EditBox:SetBackdropBorderColor(ChatTypeInfo[ChatType].r, ChatTypeInfo[ChatType].g, ChatTypeInfo[ChatType].b)
	end
end

function Module:MoveAudioButtons()
	ChatFrameChannelButton:Kill()
	ChatFrameToggleVoiceDeafenButton:Kill()
	ChatFrameToggleVoiceMuteButton:Kill()
end

function Module:NoMouseAlpha()
	local Frame = self:GetName()
	local Tab = _G[Frame .. "Tab"]

	if (Tab.noMouseAlpha == 0.4) or (Tab.noMouseAlpha == 0.2) then
		Tab:SetAlpha(0.25)
		Tab.noMouseAlpha = 0.25
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
	local Tab = _G[FrameName .. "Tab"]
	local TabText = _G[FrameName .. "TabText"]
	local Scroll = frame.ScrollBar
	local ScrollBottom = frame.ScrollToBottomButton
	local ScrollTex = _G[FrameName .. "ThumbTexture"]
	local EditBox = _G[FrameName .. "EditBox"]
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
	EditBox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 26)
	EditBox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 23, 26)
	EditBox:SetHeight(22)
	EditBox:CreateBorder()

	-- Hide textures
	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[FrameName .. CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
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

	-- Kill off editbox artwork
	local RegionA, RegionB, RegionC = select(6, EditBox:GetRegions())
	RegionA:Kill()
	RegionB:Kill()
	RegionC:Kill()

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
	if (_G[Frame:GetName() .. "Tab"]:GetText():match(_G.PET_BATTLE_COMBAT_LOG)) then
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
		local Frame = _G["ChatFrame" .. i]
		local ID = Frame:GetID()

		-- Set font size and chat frame size
		Frame:SetSize(C["Chat"].Width, C["Chat"].Height)

		-- move general bottom left
		if ID == 1 then
			Frame:ClearAllPoints()
			Frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 3, 3)
		end

		-- rename windows general because moved to chat #3
		if ID == 1 then
			FCF_SetWindowName(Frame, GENERAL)
		elseif ID == 2 then
			FCF_SetWindowName(Frame, _G.GUILD_EVENT_LOG)
		elseif ID == 3 then
			FCF_SetWindowName(Frame, LOOT .. " / " .. TRADE)
		end

		if (not Frame.isLocked) then
			FCF_SetLocked(Frame, 1)
		end

		local Anchor1, _, Anchor2, X, Y = Frame:GetPoint()
		KkthnxUIData[GetRealmName()][UnitName("player")].Chat["Frame" .. i] = {Anchor1, Anchor2, X, Y, C["Chat"].Width, C["Chat"].Height }
	end
end

function Module:SaveChatFramePositionAndDimensions()
	local Anchor1, _, Anchor2, X, Y = self:GetPoint()
	local Width, Height = self:GetSize()
	local ID = self:GetID()

	if not (KkthnxUIData[GetRealmName()][UnitName("player")].Chat) then
		KkthnxUIData[GetRealmName()][UnitName("player")].Chat = {}
	end

	KkthnxUIData[GetRealmName()][UnitName("player")].Chat["Frame" .. ID] = {Anchor1, Anchor2, X, Y, Width, Height}
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
	local Settings = KkthnxUIData[GetRealmName()][UnitName("player")].Chat["Frame" .. ID]

	if Settings then
		local Anchor1, Anchor2, X, Y = unpack(Settings)

		Frame:SetUserPlaced(true)
		Frame:ClearAllPoints()
		Frame:SetPoint(Anchor1, UIParent, Anchor2, X, Y)
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
	FCF_DockFrame(ChatFrame3)
	FCF_SetLocked(ChatFrame3, 1)
	ChatFrame3:Show()

	-- keys taken from `ChatTypeGroup` but doesnt add: "OPENING", "TRADESKILLS", "PET_INFO", "COMBAT_MISC_INFO", "COMMUNITIES_CHANNEL", "PET_BATTLE_COMBAT_LOG", "PET_BATTLE_INFO", "TARGETICONS"
	local chatGroup = { "SYSTEM", "CHANNEL", "SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "MONSTER_SAY", "MONSTER_YELL", "MONSTER_EMOTE", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "ERRORS", "AFK", "DND", "IGNORED", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "BN_WHISPER", "BN_INLINE_TOAST_ALERT" }
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(ChatFrame1, v)
	end

	-- keys taken from `ChatTypeGroup` which weren't added above to ChatFrame1
	chatGroup = { "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "SKILL", "LOOT", "CURRENCY", "MONEY" }
	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(ChatFrame3, v)
	end

	ChatFrame_AddChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, TRADE)
	ChatFrame_AddChannel(ChatFrame3, TRADE)

	-- set the chat groups names in class color to enabled for all chat groups which players names appear
	chatGroup = { "SAY", "EMOTE", "YELL", "WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "GUILD", "OFFICER", "ACHIEVEMENT", "GUILD_ACHIEVEMENT", "COMMUNITIES_CHANNEL" }
	for i = 1, MAX_WOW_CHAT_CHANNELS do
		tinsert(chatGroup, "CHANNEL"..i)
	end
	for _, v in ipairs(chatGroup) do
		ToggleChatColorNamesByClassGroup(true, v)
	end

	-- Adjust Chat Colors
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255) -- General
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255) -- Trade
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255) -- Local Defense

	if K.Name == "Kkthnx" and K.Realm == "Bleeding Hollow" then
		SetCVar("scriptErrors", 1)
	end

	DEFAULT_CHAT_FRAME:SetUserPlaced(true)
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
		local Frame = _G["ChatFrame" .. i]
		local Tab = _G["ChatFrame" .. i .. "Tab"]

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
	QuickJoinToastButton:SetPoint("BOTTOMLEFT", UIParent, "TOPLEFT", -1, -18)
	QuickJoinToastButton:EnableMouse(false)
	QuickJoinToastButton.ClearAllPoints = K.Noop
	QuickJoinToastButton.SetPoint = K.Noop
	QuickJoinToastButton:SetAlpha(0)

	if C["Chat"].ShortenChannelNames then
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

		-- Say / Yell
		_G.CHAT_SAY_GET = "%s "
		_G.CHAT_YELL_GET = "%s "

		-- Flags
		_G.CHAT_FLAG_AFK = "[AFK] "
		_G.CHAT_FLAG_DND = "[DND] "
		_G.CHAT_FLAG_GM = "[GM] "
	end
end

-- Sourced: ElvUI (Simpy)
table_remove(ChatTypeGroup["GUILD"], 2)
function Module:DelayGuildMOTD()
	local delay, checks, delayFrame, chat = 0, 0, CreateFrame("Frame")
	table_insert(ChatTypeGroup["GUILD"], 2, "GUILD_MOTD")

	delayFrame:SetScript("OnUpdate", function(df, elapsed)
		delay = delay + elapsed
		if delay < 5 then
			return
		end

		local msg = GetGuildRosterMOTD()
		if msg and string_len(msg) > 0 then
			for _, frame in pairs(_G.CHAT_FRAMES) do
				chat = _G[frame]
				if chat and chat:IsEventRegistered("CHAT_MSG_GUILD") then
					ChatFrame_SystemEventHandler(chat, "GUILD_MOTD", msg)
					chat:RegisterEvent("GUILD_MOTD")
				end
			end

			df:SetScript("OnUpdate", nil)
		else -- 5 seconds can be too fast for the API response. let's try once every 5 seconds (max 5 checks).
			delay, checks = 0, checks + 1
			if checks >= 5 then
				df:SetScript("OnUpdate", nil)
			end
		end
	end)
end

function Module:OnEnable()
	self:DelayGuildMOTD() -- Keep this before `C["Chat"].Enable` check

	if (not C["Chat"].Enable) then
		return
	end

	self:SetupFrame()
	self:MoveAudioButtons()
	self:SecureHook("ChatEdit_UpdateHeader", Module.UpdateEditBoxColor)
	self:SecureHook("FCF_OpenTemporaryWindow", Module.StyleTempFrame)
	self:SecureHook("FCF_RestorePositionAndDimensions", Module.SetChatFramePosition)
	self:SecureHook("FCF_SavePositionAndDimensions", Module.SaveChatFramePositionAndDimensions)
	self:SecureHook("FCFTab_UpdateAlpha", Module.NoMouseAlpha)

	for i = 1, 10 do
		local ChatFrame = _G["ChatFrame" .. i]

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
end