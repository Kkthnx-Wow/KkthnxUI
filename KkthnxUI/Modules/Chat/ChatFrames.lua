local K, C, L, _ = select(2, ...):unpack()
if C.Chat.Enable ~= true then return end

local _G = _G
local gsub = string.gsub
local upper = string.upper
local type = type
local format = string.format
local select = select
local print = print
local find = string.find
local len = string.len
local sub = string.sub
local GetID, GetName = GetID, GetName
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local origs = {}

local strings = {
	GUILD = L_CHAT_GUILD,
	PARTY = L_CHAT_PARTY,
	RAID = L_CHAT_RAID,
	OFFICER = L_CHAT_OFFICER,
	PARTY_LEADER = L_CHAT_PARTY_LEADER,
	RAID_LEADER = L_CHAT_RAID_LEADER,
	INSTANCE_CHAT = L_CHAT_INSTANCE,
	INSTANCE_CHAT_LEADER = L_CHAT_INSTANCE_LEADER,
	PET_BATTLE_COMBAT_LOG = PET_BATTLE_COMBAT_LOG,
}

local function ShortChannel(channel)
	return format("|Hchannel:%s|h[%s]|h", channel, strings[channel:upper()] or channel:gsub("channel:", ""))
end

local function AddMessage(frame, str, ...)
	--if type ~= "EMOTE" and type ~= "TEXT_EMOTE" then
		str = str:gsub("|Hchannel:(.-)|h%[(.-)%]|h", ShortChannel)
		str = str:gsub("CHANNEL:", "")
		str = str:gsub("^(.-|h) "..L_CHAT_WHISPERS, "%1")
		str = str:gsub("^(.-|h) "..L_CHAT_SAYS, "%1")
		str = str:gsub("^(.-|h) "..L_CHAT_YELLS, "%1")
		str = str:gsub("<"..AFK..">", "[|cffFF0000"..L_CHAT_AFK.."|r] ")
		str = str:gsub("<"..DND..">", "[|cffE7E716"..L_CHAT_DND.."|r] ")
		str = str:gsub("%[BN_CONVERSATION:", "%[1".."")
		str = str:gsub("^%["..RAID_WARNING.."%]", "["..L_CHAT_RAID_WARNING.."]")

		return origs[frame](frame, str, ...)
	--end
end

FriendsMicroButton:Kill()
ChatFrameMenuButton:Kill()

-- Set chat style
local function SetChatStyle(frame)
	local frame = frame
	local id = frame:GetID()
	local framename = frame:GetName()
	local tab = _G[framename.."Tab"]
	local editbox = _G[framename.."EditBox"]

	frame:SetFrameLevel(4)

	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetClampedToScreen(false)
	frame:SetTimeVisible(C.Chat.FadeTime)
	frame:SetFading(true)

	-- MOVE THE CHAT EDIT BOX
	editbox:ClearAllPoints()
	editbox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -4, 23)
	editbox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 4, 23)

	-- HIDE TEXTURES
	for i = 1, #CHAT_FRAME_TEXTURES do
		_G[framename..CHAT_FRAME_TEXTURES[i]]:SetTexture(nil)
	end

	-- REMOVES DEFAULT CHATFRAME TABS TEXTURE
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

	_G[format("ChatFrame%sEditBoxLeft", id)]:Kill()
	_G[format("ChatFrame%sEditBoxMid", id)]:Kill()
	_G[format("ChatFrame%sEditBoxRight", id)]:Kill()

	_G[format("ChatFrame%sTabGlow", id)]:Kill()

	-- KILL OFF EDITBOX ARTWORK
	local a, b, c = select(6, editbox:GetRegions()) a:Kill() b:Kill() c:Kill()

	-- KILL BUBBLE TEX/GLOW
	if tab.conversationIcon then tab.conversationIcon:Kill() end

	-- DISABLE ALT KEY USAGE
	editbox:SetAltArrowKeyMode(false)

	-- HIDE EDITBOX ON LOGIN
	editbox:Hide()

	-- SCRIPT TO HIDE EDITBOX INSTEAD OF FADING EDITBOX TO 0.35 ALPHA VIA IM STYLE
	editbox:HookScript("OnEditFocusGained", function(self) self:Show() end)
	editbox:HookScript("OnEditFocusLost", function(self) self:Hide() end)

	local function OnTextChanged(self)
		local text = self:GetText()

		if InCombatLockdown() then
			local MIN_REPEAT_CHARACTERS = 5
			if (len(text) > MIN_REPEAT_CHARACTERS) then
				local repeatChar = true
				for i=1, MIN_REPEAT_CHARACTERS, 1 do
					if (sub(text,(0-i), (0-i)) ~= sub(text,(-1-i),(-1-i)) ) then
						repeatChar = false
						break
					end
				end
				if ( repeatChar ) then
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

	-- HIDE EDIT BOX EVERY TIME WE CLICK ON A TAB
	tab:HookScript("OnClick", function() editbox:Hide() end)

	-- CREATE OUR OWN TEXTURE FOR EDIT BOX
	if C.Chat.TabsMouseover ~= true then
		local EditBoxBackground = CreateFrame("Frame", "ChatEditBoxBackground", editbox)
		EditBoxBackground:SetBackdrop(K.Backdrop)
		EditBoxBackground:SetBackdropColor(unpack(C.Media.Backdrop_Color))
		EditBoxBackground:SetBackdropBorderColor(unpack(C.Media.Border_Color))
		EditBoxBackground:ClearAllPoints()
		EditBoxBackground:SetPoint("TOPLEFT", editbox, "TOPLEFT", 7, -3)
		EditBoxBackground:SetPoint("BOTTOMRIGHT", editbox, "BOTTOMRIGHT", -7, 2)
		EditBoxBackground:SetFrameStrata("LOW")
		EditBoxBackground:SetFrameLevel(1)

		local function colorize(r, g, b)
			EditBoxBackground:SetBackdropBorderColor(r, g, b)
		end

		-- UPDATE BORDER COLOR ACCORDING WHERE WE TALK
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
		CombatLogQuickButtonFrame_Custom:CreateBackdrop()
		CombatLogQuickButtonFrame_Custom.backdrop:SetPoint("TOPLEFT", -2, -2)
		CombatLogQuickButtonFrame_Custom.backdrop:SetPoint("BOTTOMRIGHT", 2, -2)
		CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetSize(26, 28)
		CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetPoint("TOPRIGHT", CombatLogQuickButtonFrame_Custom, "TOPRIGHT", 4, -1)
		CombatLogQuickButtonFrame_CustomProgressBar:ClearAllPoints()
		CombatLogQuickButtonFrame_CustomProgressBar:SetPoint("TOPLEFT", CombatLogQuickButtonFrame_Custom.backdrop, 4, -4)
		CombatLogQuickButtonFrame_CustomProgressBar:SetPoint("BOTTOMRIGHT", CombatLogQuickButtonFrame_Custom.backdrop, -4, 4)
		CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarTexture(C.Media.Texture)
		CombatLogQuickButtonFrameButton1:SetPoint("BOTTOM", 0, 0)
	end

	frame.skinned = true
end

-- SETUP CHATFRAMES 1 TO 10 ON LOGIN
local function SetupChat(self)
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		SetChatStyle(frame)
	end

	-- REMEMBER LAST CHANNEL
	local var
	if C.Chat.Sticky == true then
		var = 1
	else
		var = 0
	end
	ChatTypeInfo.SAY.sticky = var
	ChatTypeInfo.PARTY.sticky = var
	ChatTypeInfo.PARTY_LEADER.sticky = var
	ChatTypeInfo.GUILD.sticky = var
	ChatTypeInfo.OFFICER.sticky = var
	ChatTypeInfo.RAID.sticky = var
	ChatTypeInfo.RAID_WARNING.sticky = var
	ChatTypeInfo.INSTANCE_CHAT.sticky = var
	ChatTypeInfo.INSTANCE_CHAT_LEADER.sticky = var
	ChatTypeInfo.WHISPER.sticky = var
	ChatTypeInfo.BN_WHISPER.sticky = var
	ChatTypeInfo.CHANNEL.sticky = var
end

local function SetupChatPosAndFont(self)
	for i = 1, NUM_CHAT_WINDOWS do
		local chat = _G[format("ChatFrame%s", i)]
		local id = chat:GetID()
		local _, fontSize = FCF_GetChatWindowInfo(id)

		-- Min. size for chat font
		if fontSize < 12 then
			FCF_SetChatWindowFontSize(nil, chat, 12)
		else
			FCF_SetChatWindowFontSize(nil, chat, fontSize)
		end

		-- Font and font style for chat
		if C.Chat.Outline == true then
			chat:SetFont(C.Media.Font, fontSize, C.Media.Font_Style)
			chat:SetShadowColor(0/255, 0/255, 0/255, 0.2)
		else
			chat:SetFont(C.Media.Font, fontSize)
			chat:SetShadowColor(0/255, 0/255, 0/255, 1)
			chat:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
		end

		-- REPOSITION BATTLE.NET POPUP OVER CHAT #1
		BNToastFrame:HookScript("OnShow", function(self)
			self:ClearAllPoints()
			self:SetPoint(unpack(C.Position.BnetPopup))
		end)

		if not self:IsMovable() then
			return
		end

		-- FORCE CHAT POSITION
		if i == 1 then
			chat:ClearAllPoints()
			chat:SetSize(C.Chat.Width, C.Chat.Height)
			chat:SetPoint(C.Position.Chat[1], C.Position.Chat[2], C.Position.Chat[3], C.Position.Chat[4], C.Position.Chat[5])
			FCF_SavePositionAndDimensions(chat)
		elseif i == 2 then
			if C.Chat.CombatLog ~= true then
				FCF_DockFrame(chat)
				ChatFrame2Tab:EnableMouse(false)
				ChatFrame2Tab:SetText("")
				ChatFrame2Tab.SetText = K.Noop
				ChatFrame2Tab:SetWidth(0.001)
				ChatFrame2Tab.SetWidth = K.Noop
			end
		end
	end
end

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

-- SETUP TEMP CHAT (BN, WHISPER) WHEN NEEDED
local function SetupTempChat()
	local frame = FCF_GetCurrentChatFrame()
	if frame.skinned then return end
	SetChatStyle(frame)
end
hooksecurefunc("FCF_OpenTemporaryWindow", SetupTempChat)

-- DISABLE PET BATTLE TAB
local old = FCFManager_GetNumDedicatedFrames
function FCFManager_GetNumDedicatedFrames(...)
	return select(1, ...) ~= "PET_BATTLE_COMBAT_LOG" and old(...) or 1
end

-- REMOVE PLAYER'S REALM NAME
local function RemoveRealmName(self, event, msg, author, ...)
	local realm = string.gsub(K.Realm, " ", "")
	if msg:find("-" .. realm) then
		return false, gsub(msg, "%-"..realm, ""), author, ...
	end
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", RemoveRealmName)

-- SAVE SLASH COMMAND TYPO
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
		K.Print(L_CHAT_BIGCHAT_ON)
	else
		ChatFrame1:SetSize(400, 150)
		bigchat = false
		K.Print(L_CHAT_BIGCHAT_OFF)
	end
end
SLASH_BIGCHAT1 = "/bigchat"