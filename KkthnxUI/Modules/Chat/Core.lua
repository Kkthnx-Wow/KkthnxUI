--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Chat/Core.lua
	Purpose:
		Skin the chat: a bordered edit box, clean tabs, our font, mouse wheel
		scrolling, shortened channel prefixes, and a copy button. Applies to every
		chat window, including ones created after login.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:NewModule("Chat")

local _G = _G
local gsub = string.gsub
local IsSecret = K.IsSecret

local NUM_FRAMES = NUM_CHAT_WINDOWS or 10

-- ---------------------------------------------------------------------------
-- Gradient backdrop
-- ---------------------------------------------------------------------------
-- A soft horizontal fade behind the chat (dark at the left, transparent to the
-- right) with a class-coloured accent line along the top and bottom that fades
-- the same way. Kept on the BACKGROUND layer of a low frame so the messages
-- always draw over it.

local CreateColor = CreateColor

local function CreateGradient(frame)
	if frame.KKUI_Gradient then
		return frame.KKUI_Gradient
	end
	local color = K.ClassColor or { r = 0.4, g = 0.6, b = 1 }

	local holder = CreateFrame("Frame", nil, frame)
	holder:SetFrameLevel(0)
	holder:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 8)
	holder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 8, -4)

	local bg = holder:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(1, 1, 1)
	bg:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0.6), CreateColor(0, 0, 0, 0))

	local top = holder:CreateTexture(nil, "ARTWORK")
	top:SetHeight(1)
	top:SetPoint("TOPLEFT")
	top:SetPoint("TOPRIGHT")
	top:SetColorTexture(1, 1, 1)
	top:SetGradient("HORIZONTAL", CreateColor(color.r, color.g, color.b, 0.7), CreateColor(color.r, color.g, color.b, 0))

	local bottom = holder:CreateTexture(nil, "ARTWORK")
	bottom:SetHeight(1)
	bottom:SetPoint("BOTTOMLEFT")
	bottom:SetPoint("BOTTOMRIGHT")
	bottom:SetColorTexture(1, 1, 1)
	bottom:SetGradient("HORIZONTAL", CreateColor(color.r, color.g, color.b, 0.7), CreateColor(color.r, color.g, color.b, 0))

	frame.KKUI_Gradient = holder
	return holder
end

-- ---------------------------------------------------------------------------
-- Font
-- ---------------------------------------------------------------------------

local function ApplyFont(frame)
	local db = C.Chat
	local font = K.GetFont(db.Font)
	local flag = db.FontOutline and "OUTLINE" or ""
	frame:SetFont(font, db.FontSize, flag)
	frame:SetShadowColor(0, 0, 0, 1)
	frame:SetShadowOffset(1, -1)
end

-- ---------------------------------------------------------------------------
-- Edit box
-- ---------------------------------------------------------------------------

-- Colour the edit box border to the channel you are typing in (whisper pink,
-- say white, guild green, and so on), read from Blizzard's own ChatTypeInfo.
local function ColorEditBox(editBox)
	if not editBox.KKUI_Border then
		return
	end
	local chatType = editBox:GetAttribute("chatType")
	local info = chatType and ChatTypeInfo[chatType]
	if info then
		editBox.KKUI_Border:SetVertexColor(info.r, info.g, info.b)
	else
		K.ResetBorderColor(editBox.KKUI_Border)
	end
end

local function SkinEditBox(editBox)
	if editBox.__skinned then
		return
	end
	editBox.__skinned = true

	local fullName = editBox:GetName()

	-- Kill the stock chrome: the Left/Mid/Right backdrop and, crucially, the
	-- FocusLeft/Mid/Right glow Blizzard lights up when the box activates. That glow
	-- is the faded ghost that used to sit over the tabs on a tab switch.
	for _, suffix in ipairs({ "Left", "Mid", "Right", "FocusLeft", "FocusMid", "FocusRight" }) do
		local tex = _G[fullName .. suffix]
		if tex then
			tex:SetTexture(nil)
			tex:Hide()
		end
	end
	for _, region in ipairs({ editBox:GetRegions() }) do
		if region.GetObjectType and region:GetObjectType() == "Texture" then
			region:SetAlpha(0)
		end
	end

	K.CreateBackground(editBox, 0.05, 0.05, 0.05, 0.85)
	K.CreateBorder(editBox)

	-- Left/right arrows move the cursor instead of cycling chat channels.
	editBox:SetAltArrowKeyMode(false)
	editBox:SetClampedToScreen(true)

	-- Sit above the chat frame, clearing the tab strip. Re-applied on every focus
	-- because a tab switch can re-anchor the box and drift it out of place.
	local parent = _G[fullName:gsub("EditBox", "")]
	local function Reposition(self)
		if not parent then
			return
		end
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, 26)
		self:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, 26)
		self:SetHeight(22)
	end
	Reposition(editBox)

	-- Visibility is driven purely by focus. The tricky part is that Blizzard
	-- re-activates an already-shown box on a tab click by fading its alpha up, with
	-- no OnShow or focus event to hook, which is what left it faded over the tabs.
	-- So we intercept SetAlpha itself: any alpha above zero while the box is not
	-- focused is forced back to zero. Our own focus-in alpha is allowed because the
	-- box holds focus by then.
	editBox:SetAlpha(0)
	editBox:EnableMouse(false)
	hooksecurefunc(editBox, "SetAlpha", function(self, alpha)
		if alpha > 0 and not self:HasFocus() then
			self:SetAlpha(0)
		end
	end)
	editBox:HookScript("OnEditFocusGained", function(self)
		Reposition(self)
		self:EnableMouse(true)
		self:SetAlpha(1)
	end)
	editBox:HookScript("OnEditFocusLost", function(self)
		self:EnableMouse(false)
		self:SetAlpha(0)
	end)
end

-- ---------------------------------------------------------------------------
-- Tabs
-- ---------------------------------------------------------------------------

-- Blizzard re-applies tab textures constantly (FCFTab_UpdateColors, hover), so
-- rather than chase named regions we blank every texture on the tab and keep it
-- blanked. Only the label stays.
local function StripTab(tab)
	for _, region in ipairs({ tab:GetRegions() }) do
		if region.GetObjectType and region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
			region:SetAtlas(nil)
		end
	end
end

local function SkinTab(tab)
	if not tab or tab.__skinned then
		return
	end
	tab.__skinned = true

	StripTab(tab)
	if tab.SetNormalTexture then
		tab:SetNormalTexture(0)
		tab:SetHighlightTexture(0)
		tab:SetPushedTexture(0)
	end

	local text = tab.Text or _G[tab:GetName() .. "Text"]
	if text then
		K.SetFont(text, C.Chat.FontSize, K.FontOutlineStyle())
	end
end

-- ---------------------------------------------------------------------------
-- Mouse wheel
-- ---------------------------------------------------------------------------

local function OnMouseWheel(frame, delta)
	if delta > 0 then
		if IsShiftKeyDown() then
			frame:ScrollToTop()
		else
			frame:ScrollUp()
		end
	else
		if IsShiftKeyDown() then
			frame:ScrollToBottom()
		else
			frame:ScrollDown()
		end
	end
end

-- ---------------------------------------------------------------------------
-- Channel shortening
-- ---------------------------------------------------------------------------
-- Matched on the channel LINK token, which is language independent, so this
-- works on every client without a translation table.

local LINK_SHORT = {
	GUILD = "G",
	PARTY = "P",
	PARTY_LEADER = "PL",
	RAID = "R",
	RAID_LEADER = "RL",
	INSTANCE_CHAT = "I",
	INSTANCE_CHAT_LEADER = "IL",
	OFFICER = "O",
}

local function ShortenLine(text)
	-- Midnight can hand the message filter a secret string, which cannot be indexed
	-- or run through gsub, so leave it untouched.
	if type(text) ~= "string" or IsSecret(text) then
		return text
	end
	-- Numbered custom channels: [5. General] becomes [5].
	text = gsub(text, "(|Hchannel:channel:%d+|h)%[(%d+)%. [^%]]+%]|h", "%1[%2]|h")
	-- Built-in channels by link token: [Guild] becomes [G], etc.
	text = gsub(text, "|Hchannel:(%u[%u_]+)|h%[[^%]]+%]|h", function(token)
		local short = LINK_SHORT[token]
		if short then
			return "|Hchannel:" .. token .. "|h[" .. short .. "]|h"
		end
	end)
	return text
end

local function HookShortening(frame)
	if frame.__shortHooked then
		return
	end
	frame.__shortHooked = true
	local original = frame.AddMessage
	frame.AddMessage = function(self, text, ...)
		return original(self, ShortenLine(text), ...)
	end
end

-- ---------------------------------------------------------------------------
-- Class colored names
-- ---------------------------------------------------------------------------
-- Uses Blizzard's own per-group class colouring so it stays correct and needs
-- no message parsing.

local COLOR_GROUPS = {
	"SAY",
	"YELL",
	"GUILD",
	"OFFICER",
	"WHISPER",
	"BN_WHISPER",
	"PARTY",
	"PARTY_LEADER",
	"RAID",
	"RAID_LEADER",
	"RAID_WARNING",
	"INSTANCE_CHAT",
	"INSTANCE_CHAT_LEADER",
	"CHANNEL",
}

local function EnableClassColors()
	for _, group in ipairs(COLOR_GROUPS) do
		if ToggleChatColorNamesByClassGroup then
			ToggleChatColorNamesByClassGroup(true, group)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Clickable URLs
-- ---------------------------------------------------------------------------
-- Wrap anything that looks like a link in a custom hyperlink, clicking it opens
-- a small box with the URL selected for copying.

local URL_PATTERNS = {
	"(%a[%w+.-]+://%S+)", -- scheme://...
	"(www%.[%w_.%-]+%.%a%a+%S*)", -- www.something.tld
	"(%d+%.%d+%.%d+%.%d+:?%d*)", -- ip[:port]
}

local function LinkURLs(text)
	-- A secret chat string cannot be indexed or searched, so pass it through as is.
	if type(text) ~= "string" or IsSecret(text) or text:find("|H") then
		return text
	end
	for _, pattern in ipairs(URL_PATTERNS) do
		text = text:gsub(pattern, "|cff00ccff|Hkkurl:%1|h[%1]|h|r")
	end
	return text
end

local function HookURLs(frame)
	if frame.__urlHooked then
		return
	end
	frame.__urlHooked = true
	local original = frame.AddMessage
	frame.AddMessage = function(self, text, ...)
		return original(self, LinkURLs(text), ...)
	end
end

-- One shared box for copying a clicked URL.
local urlBox
local function ShowURL(url)
	if not urlBox then
		urlBox = CreateFrame("EditBox", "KKUI_ChatURLBox", UIParent, "InputBoxTemplate")
		urlBox:SetSize(360, 24)
		urlBox:SetPoint("CENTER")
		urlBox:SetFrameStrata("DIALOG")
		urlBox:SetAutoFocus(true)
		urlBox:SetScript("OnEscapePressed", urlBox.ClearFocus)
		urlBox:SetScript("OnEnterPressed", urlBox.ClearFocus)
		K.SkinEditBox(urlBox)
	end
	urlBox:SetText(url)
	urlBox:HighlightText()
	urlBox:Show()
	urlBox:SetFocus()
end

-- ---------------------------------------------------------------------------
-- Copy button
-- ---------------------------------------------------------------------------

function Module:CreateCopyWindow()
	local frame = CreateFrame("Frame", "KKUI_ChatCopy", UIParent)
	frame:SetSize(500, 300)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	K.CreateBackground(frame, 0.05, 0.05, 0.05, 0.95)
	K.CreateBorder(frame)
	frame:Hide()

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	K.SkinCloseButton(close)

	local scroll = CreateFrame("ScrollFrame", "KKUI_ChatCopyScroll", frame, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 10, -10)
	scroll:SetPoint("BOTTOMRIGHT", -30, 10)
	K.SkinScrollBar(scroll.ScrollBar)

	local edit = CreateFrame("EditBox", nil, scroll)
	edit:SetMultiLine(true)
	edit:SetMaxLetters(0)
	edit:SetAutoFocus(false)
	edit:SetFontObject(ChatFontNormal)
	edit:SetWidth(460)
	edit:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)
	scroll:SetScrollChild(edit)

	self.copyFrame = frame
	self.copyEdit = edit
	return frame
end

function Module:CopyChat(chatFrame)
	if not self.copyFrame then
		self:CreateCopyWindow()
	end
	local lines = {}
	for i = 1, chatFrame:GetNumMessages() do
		local text = chatFrame:GetMessageInfo(i)
		if text then
			-- Strip textures and hyperlinks' color codes for clean copying.
			text = gsub(text, "|T.-|t", "")
			lines[#lines + 1] = text
		end
	end
	self.copyEdit:SetText(table.concat(lines, "\n"))
	self.copyFrame:Show()
end

local function AddCopyButton(chatFrame)
	local button = CreateFrame("Button", nil, chatFrame)
	button:SetSize(20, 20)
	button:SetPoint("TOPRIGHT", chatFrame, "TOPRIGHT", -2, 20)
	button:SetAlpha(0)
	K.CreateBackground(button, 0.1, 0.1, 0.1, 0.8)
	K.CreateBorder(button)
	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexture(C.Media.Textures.Copy or "Interface\\BUTTONS\\UI-GuildButton-PublicNote-Up")
	button:SetScript("OnEnter", function(self)
		self:SetAlpha(1)
	end)
	button:SetScript("OnLeave", function(self)
		self:SetAlpha(0)
	end)
	button:SetScript("OnClick", function()
		Module:CopyChat(chatFrame)
	end)
	return button
end

-- ---------------------------------------------------------------------------
-- Social (quick-join) button
-- ---------------------------------------------------------------------------

-- Reskin and reposition the quick-join toast button above the chat. It is kept
-- rather than hidden because hiding it also hides the toasts other features fire.
function Module:SkinSocialButton()
	local button = _G.QuickJoinToastButton
	if not button or button.KKUI_Skinned then
		return
	end
	button.KKUI_Skinned = true

	button:ClearAllPoints()
	button:SetPoint("BOTTOMLEFT", _G.ChatFrame1, "TOPLEFT", 0, 24)
	button:SetSize(22, 22)
	K.CreateGradientBackground(button, 0.85)
	K.CreateBorder(button)

	-- Trim the default plate art so our border reads cleanly, and crop the friend
	-- glyph to sit inside the button.
	for _, region in ipairs({ button:GetRegions() }) do
		if region.GetObjectType and region:GetObjectType() == "Texture" and region ~= button.FriendsButton and region ~= button.QueueButton then
			region:SetAlpha(0)
		end
	end
	if button.FriendsButton then
		button.FriendsButton:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	end
end

-- ---------------------------------------------------------------------------
-- Enable
-- ---------------------------------------------------------------------------

function Module:StyleFrame(index)
	local frame = _G["ChatFrame" .. index]
	if not frame then
		return
	end
	local db = C.Chat

	ApplyFont(frame)

	-- The default backdrop and border are drawn on the chat frame's own
	-- BACKGROUND / BORDER layers, disabling those layers removes them entirely.
	frame:DisableDrawLayer("BACKGROUND")
	frame:DisableDrawLayer("BORDER")
	frame:SetClampRectInsets(0, 0, 0, 0)

	SkinTab(_G["ChatFrame" .. index .. "Tab"])
	SkinEditBox(_G["ChatFrame" .. index .. "EditBox"])

	if db.MouseWheelScroll then
		frame:SetScript("OnMouseWheel", OnMouseWheel)
		frame:EnableMouseWheel(true)
	end

	-- Fade idle windows using the built-in fade timers.
	frame:SetFading(db.Fade)
	if db.Fade then
		frame:SetTimeVisible(db.FadeTime)
	end

	if db.CopyButton and not frame.KKUI_Copy then
		frame.KKUI_Copy = AddCopyButton(frame)
	end

	if db.ShortenChannels then
		HookShortening(frame)
	end

	if db.URLLinks then
		HookURLs(frame)
	end

	if db.GradientBackdrop then
		CreateGradient(frame)
	end
end

-- One-click chat layout: reset to a single window,
-- then dock General, Combat Log, Whispers, Trade, and Loot tabs with sensible
-- message groups, and set a few chat CVars. Run from the installer or /kk.
function Module:InstallChat()
	FCF_ResetChatWindows()
	FCF_SetLocked(_G.ChatFrame1, true)
	FCF_SetWindowName(_G.ChatFrame1, GENERAL or "General")
	_G.ChatFrame1:Show()

	-- General: everything but trade and the recruitment channels.
	ChatFrame_RemoveAllMessageGroups(_G.ChatFrame1)
	for _, channel in ipairs({ TRADE, GENERAL, "LocalDefense", "LookingForGroup", "GuildRecruitment", "Services" }) do
		if channel then
			ChatFrame_RemoveChannel(_G.ChatFrame1, channel)
		end
	end
	local general = {
		"SAY", "EMOTE", "YELL", "GUILD", "OFFICER", "GUILD_ACHIEVEMENT",
		"MONSTER_SAY", "MONSTER_EMOTE", "MONSTER_YELL", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER",
		"PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER",
		"BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "SYSTEM", "ERRORS", "AFK", "DND", "IGNORED", "ACHIEVEMENT",
	}
	for _, group in ipairs(general) do
		ChatFrame_AddMessageGroup(_G.ChatFrame1, group)
	end

	-- Combat log stays docked as the second tab.
	FCF_DockFrame(_G.ChatFrame2)
	FCF_SetLocked(_G.ChatFrame2, true)
	FCF_SetWindowName(_G.ChatFrame2, COMBAT_LOG or "Combat Log")
	_G.ChatFrame2:Show()

	-- Whispers.
	local whispers = FCF_OpenNewWindow(L["Whispers"])
	FCF_SetLocked(whispers, true)
	FCF_DockFrame(whispers)
	ChatFrame_RemoveAllMessageGroups(whispers)
	for _, group in ipairs({ "WHISPER", "BN_WHISPER", "BN_CONVERSATION" }) do
		ChatFrame_AddMessageGroup(whispers, group)
	end

	-- Trade and the general channels.
	local trade = FCF_OpenNewWindow(L["Trade"])
	FCF_SetLocked(trade, true)
	FCF_DockFrame(trade)
	ChatFrame_RemoveAllMessageGroups(trade)
	-- ChatFrame_AddChannel is gone in 12.0, the frame carries the method now.
	if TRADE then
		trade:AddChannel(TRADE)
	end
	if GENERAL then
		trade:AddChannel(GENERAL)
	end

	-- Loot, money, and gains.
	local loot = FCF_OpenNewWindow(L["Loot"])
	FCF_SetLocked(loot, true)
	FCF_DockFrame(loot)
	ChatFrame_RemoveAllMessageGroups(loot)
	for _, group in ipairs({ "COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "LOOT", "CURRENCY", "MONEY", "SKILL" }) do
		ChatFrame_AddMessageGroup(loot, group)
	end

	-- Chat behaviour CVars.
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "im")
	SetCVar("whisperMode", "inline")
	SetCVar("removeChatDelay", 1)
	SetCVar("colorChatNamesByClass", 1)

	_G.ChatFrame1:SetUserPlaced(true)
	K.Print(L["Chat layout applied."])
end
K.InstallChat = function()
	Module:InstallChat()
end

function Module:OnEnable()
	if not C.Chat.Enable then
		return
	end

	-- Timestamps through the built-in CVar (24h HH:MM).
	if C.Chat.Timestamps then
		SetCVar("showTimestamps", "%H:%M ")
	end

	if C.Chat.ClassColorNames then
		EnableClassColors()
	end

	-- A soft sound on an incoming whisper, throttled so a burst is one chime.
	if C.Chat.WhisperSound then
		local lastPlay = 0
		local function OnWhisper()
			local now = GetTime()
			if now - lastPlay > 3 then
				lastPlay = now
				PlaySound(SOUNDKIT.TELL_MESSAGE, "Master")
			end
		end
		self:RegisterEvent("CHAT_MSG_WHISPER", OnWhisper)
		self:RegisterEvent("CHAT_MSG_BN_WHISPER", OnWhisper)
	end

	-- Remove the stock chat clutter around the frames. The quick-join social button
	-- is kept and skinned instead, since hiding it also hides the toasts other
	-- features rely on.
	for _, name in ipairs({
		"ChatFrameMenuButton",
		"ChatFrameChannelButton",
		"ChatFrameToggleVoiceDeafenButton",
		"ChatFrameToggleVoiceMuteButton",
	}) do
		local frame = _G[name]
		if frame then
			frame:Hide()
			frame:HookScript("OnShow", frame.Hide)
		end
	end

	self:SkinSocialButton()

	-- Pin the chat to the bottom-left corner. Edit Mode keeps trying to place it,
	-- so we hook SetPoint and re-apply, guarded against re-entry. The y offset
	-- leaves room for the quick-bar that sits just below the frame.
	local anchoring
	local function AnchorChat()
		if anchoring then
			return
		end
		anchoring = true
		-- 6px from the left edge, 6px from the bottom, or higher to clear the
		-- quick-bar when it is enabled.
		local bottom = C.Chat.ChatBar and 34 or 6
		_G.ChatFrame1:ClearAllPoints()
		_G.ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 6, bottom)
		anchoring = false
	end
	AnchorChat()
	hooksecurefunc(_G.ChatFrame1, "SetPoint", AnchorChat)

	-- Lift the tab dock off the chat frame's top edge so the tabs are not
	-- crammed against the messages. Guarded against the hook re-entering.
	local dock = _G.GeneralDockManager
	if dock then
		local fixing
		local function LiftDock()
			if fixing then
				return
			end
			fixing = true
			dock:ClearAllPoints()
			dock:SetPoint("BOTTOMLEFT", _G.ChatFrame1, "TOPLEFT", 0, 6)
			dock:SetPoint("BOTTOMRIGHT", _G.ChatFrame1, "TOPRIGHT", 0, 6)
			fixing = false
		end
		LiftDock()
		hooksecurefunc(dock, "SetPoint", LiftDock)
	end

	-- Colour the edit box border to the active channel.
	hooksecurefunc("ChatEdit_UpdateHeader", ColorEditBox)

	-- Blizzard re-textures tabs on colour/hover updates, keep them blanked.
	if _G.FCFTab_UpdateColors then
		hooksecurefunc("FCFTab_UpdateColors", StripTab)
	end

	-- Kill the per-frame scroll button clutter and combat-log quick button art.
	for i = 1, NUM_FRAMES do
		local buttonFrame = _G["ChatFrame" .. i .. "ButtonFrame"]
		if buttonFrame then
			buttonFrame:Hide()
			buttonFrame:HookScript("OnShow", buttonFrame.Hide)
		end
	end
	-- The Combat Log tab drags in a quick-filter bar ("My actions", ...) whose
	-- tiled parchment background bleeds across the chat area when that tab is
	-- selected. Blizzard re-applies that art every time the bar is shown, so a
	-- one-off strip is not enough: blank it now and again on every show.
	local quickButtons = _G.CombatLogQuickButtonFrame_Custom
	if quickButtons then
		local function StripQuickButtons()
			for _, region in ipairs({ quickButtons:GetRegions() }) do
				if region.GetObjectType and region:GetObjectType() == "Texture" then
					region:SetTexture(nil)
					region:SetAtlas(nil)
				end
			end
			if _G.CombatLogQuickButtonFrame_CustomTexture then
				_G.CombatLogQuickButtonFrame_CustomTexture:SetTexture(nil)
			end
		end
		StripQuickButtons()
		quickButtons:HookScript("OnShow", StripQuickButtons)
		-- The parchment is re-set through this named texture even without a show, so
		-- keep it blank whenever the client tries to paint it back in.
		if _G.CombatLogQuickButtonFrame_CustomTexture then
			hooksecurefunc(_G.CombatLogQuickButtonFrame_CustomTexture, "SetTexture", function(self, tex)
				if tex then
					self:SetTexture(nil)
				end
			end)
		end
	end

	for i = 1, NUM_FRAMES do
		self:StyleFrame(i)
	end

	-- Style temporary / whisper windows created after login.
	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		local frame = _G.FCF_GetCurrentChatFrame and _G.FCF_GetCurrentChatFrame()
		if frame then
			Module:StyleFrame(frame:GetID())
		end
	end)

	-- Open a copy box when one of our URL links is clicked.
	if C.Chat.URLLinks then
		hooksecurefunc("SetItemRef", function(link)
			local url = link:match("^kkurl:(.+)")
			if url then
				ShowURL(url)
			end
		end)
	end

	if C.Chat.HyperlinkTooltip then
		self:EnableHyperlinkTooltips()
	end
	if C.Chat.ChatBar then
		self:CreateChatBar()
	end
	if C.Chat.SideButtons then
		self:CreateSideButtons()
	end
	if C.Chat.SpamFilter then
		self:EnableFilter()
	end
	if C.Chat.SkinBubbles then
		self:SetupBubbles()
	end

	-- Sticky whispers: keep the edit box on WHISPER after you reply, so a back and
	-- forth does not need re-selecting the channel each line.
	if C.Chat.StickyWhisper and _G.ChatTypeInfo then
		_G.ChatTypeInfo.WHISPER.sticky = 1
		_G.ChatTypeInfo.BN_WHISPER.sticky = 1
	end
end
