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
local format = string.format
local IsSecret = K.IsSecret

local NUM_FRAMES = NUM_CHAT_WINDOWS or 10

-- ---------------------------------------------------------------------------
-- Gradient backdrop
-- ---------------------------------------------------------------------------
-- A soft horizontal fade behind the chat (dark at the left, transparent to the
-- right) with a class-coloured accent line along the top and bottom that fades
-- the same way. Kept on the BACKGROUND layer of a low frame so the messages
-- always draw over it.


local function CreateGradient(frame)
	if frame.KKUI_Gradient then
		return frame.KKUI_Gradient
	end
	local color = K.ClassColor or { r = 0.4, g = 0.6, b = 1 }

	-- Anchor to the frame's own background region, not the frame. On the Combat Log
	-- the frame's top is pushed down by the quick-filter bar, but Blizzard sizes the
	-- background region to still cover that bar (its top point carries the quick
	-- button height). Tracking that region keeps our gradient covering the full chat
	-- on every tab, so the Combat Log no longer shows a light gap up top. Falls back
	-- to the frame on any window without a background region.
	local region = frame.Background or _G[frame:GetName() .. "Background"] or frame
	local holder = CreateFrame("Frame", nil, frame)
	holder:SetFrameLevel(0)
	holder:SetPoint("TOPLEFT", region, "TOPLEFT", -2, 3)
	holder:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT", 2, -3)

	local bg = holder:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetColorTexture(1, 1, 1)
	K.ShadeGradient(bg)

	local top = holder:CreateTexture(nil, "ARTWORK")
	top:SetHeight(1)
	top:SetPoint("TOPLEFT")
	top:SetPoint("TOPRIGHT")
	top:SetColorTexture(1, 1, 1)
	K.FadeGradient(top, color.r, color.g, color.b, K.GradientAlpha.line)

	local bottom = holder:CreateTexture(nil, "ARTWORK")
	bottom:SetHeight(1)
	bottom:SetPoint("BOTTOMLEFT")
	bottom:SetPoint("BOTTOMRIGHT")
	bottom:SetColorTexture(1, 1, 1)
	K.FadeGradient(bottom, color.r, color.g, color.b, K.GradientAlpha.line)

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

-- Tint the edit box hairlines to the channel you are typing in (whisper pink, say
-- white, guild green, and so on), read from Blizzard's own ChatTypeInfo, the same
-- way the chat frame carries a class-coloured line. In 12.x the header refreshes
-- through the edit box mixin method UpdateHeader, not the old global, so we read
-- the type and channel off the box the same way it does: GetChatType and, for a
-- numbered channel, its per-channel colour. Falls back to the class colour.
local function ColorEditBox(editBox)
	local lines = editBox.KKUI_Lines
	if not lines then
		return
	end

	local chatType = editBox.GetChatType and editBox:GetChatType() or editBox:GetAttribute("chatType")
	local info = chatType and ChatTypeInfo[chatType]
	if chatType == "CHANNEL" then
		local target = editBox.GetChannelTarget and editBox:GetChannelTarget()
		local localID = target and GetChannelName(target)
		if localID and localID > 0 then
			info = ChatTypeInfo["CHANNEL" .. localID] or info
		end
	end

	local color = info or K.ClassColor
	for _, line in ipairs(lines) do
		K.FadeGradient(line, color.r, color.g, color.b, K.GradientAlpha.line)
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

	-- Same horizontal gradient the chat and channel bar wear, with a hairline along
	-- the top and bottom that ColorEditBox tints to the channel you are typing in.
	local grad = editBox:CreateTexture(nil, "BACKGROUND")
	grad:SetAllPoints()
	grad:SetColorTexture(1, 1, 1)
	K.ShadeGradient(grad)
	editBox.KKUI_Lines = {}
	for _, edge in ipairs({ "TOP", "BOTTOM" }) do
		local line = editBox:CreateTexture(nil, "ARTWORK")
		line:SetHeight(1)
		line:SetPoint(edge .. "LEFT")
		line:SetPoint(edge .. "RIGHT")
		line:SetColorTexture(1, 1, 1)
		editBox.KKUI_Lines[#editBox.KKUI_Lines + 1] = line
	end

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
		-- Nudged 4px left so the box gradient lines up with the chat and bar
		-- gradients, which reach the same amount past the frame edge.
		self:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", -4, 26)
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
	-- Recolour the border to the active channel whenever the box refreshes its
	-- header (channel switch, tab change, reply cycle). Hooked on the instance
	-- method because the old global ChatEdit_UpdateHeader is gone in 12.x.
	if editBox.UpdateHeader then
		hooksecurefunc(editBox, "UpdateHeader", ColorEditBox)
	end
	ColorEditBox(editBox)

	editBox:HookScript("OnEditFocusGained", function(self)
		Reposition(self)
		self:EnableMouse(true)
		self:SetAlpha(1)
		ColorEditBox(self)
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

-- Colour the selected tab in the class colour and dim the rest, so the active
-- tab reads at a glance. Blizzard passes the selected flag to FCFTab_UpdateColors,
-- so we recolour from the same call that repaints the tab.
local function ColorTab(tab, selected)
	local text = tab and (tab.Text or (tab.GetName and _G[tab:GetName() .. "Text"]))
	if not text then
		return
	end
	-- Remember the state so the flash hooks can restore the right colour, and so a
	-- tab still flagged as alerting is not overwritten back to grey.
	tab.KKUI_Selected = selected
	if tab.KKUI_Alerting and not selected then
		text:SetTextColor(1, 0.6, 0.1)
		return
	end
	if selected then
		local color = K.ClassColor
		text:SetTextColor(color.r, color.g, color.b)
	else
		text:SetTextColor(0.55, 0.55, 0.55)
	end
end

-- We blank every tab texture, which also blanks the glow the client flashes when
-- an inactive tab gets a new message. Put that unread cue back by lighting the
-- tab label a warm orange while it is alerting, cleared once the tab is read.
local function TabAlertStart(chatFrame)
	local tab = _G[chatFrame:GetName() .. "Tab"]
	local text = tab and (tab.Text or _G[tab:GetName() .. "Text"])
	if text and not tab.KKUI_Selected then
		tab.KKUI_Alerting = true
		text:SetTextColor(1, 0.6, 0.1)
	end
end

local function TabAlertStop(chatFrame)
	local tab = _G[chatFrame:GetName() .. "Tab"]
	if tab then
		tab.KKUI_Alerting = nil
		ColorTab(tab, tab.KKUI_Selected)
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
	frame:SetSize(700, 400)
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
	scroll:SetPoint("TOPLEFT", 10, -30)
	scroll:SetPoint("BOTTOMRIGHT", -28, 10)
	K.SkinScrollBar(scroll.ScrollBar)

	-- The edit box is a fixed size that fills the scroll viewport (its own name so
	-- the mouse wheel and scroll bar drive it). Multi-line text is laid out inside
	-- it and the visible slice is controlled by the hit-rect insets on scroll, the
	-- way the reference UIs do it, so the whole log shows and scrolls cleanly.
	local edit = CreateFrame("EditBox", nil, frame)
	edit:SetMultiLine(true)
	edit:SetMaxLetters(0)
	edit:SetAutoFocus(false)
	edit:EnableMouse(true)
	edit:SetFontObject(ChatFontNormal)
	edit:SetTextColor(1, 1, 1)
	-- Explicit size, not scroll:GetWidth(). The window is built on first click and
	-- is not laid out yet, so GetWidth would be 0 and the text would have nowhere to
	-- draw (which is why the copy box looked empty). 700 wide frame minus the insets.
	edit:SetWidth(662)
	edit:SetHeight(360)
	edit:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)
	-- Jump to the top when fresh text is set (userInput is nil then).
	edit:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			return
		end
		local _, maxVal = scroll.ScrollBar:GetMinMaxValues()
		for _ = 1, maxVal do
			_G.ScrollFrameTemplate_OnMouseWheel(scroll, -1)
		end
	end)
	scroll:SetScrollChild(edit)
	scroll:HookScript("OnVerticalScroll", function(self, offset)
		edit:SetHitRectInsets(0, 0, offset, (edit:GetHeight() - offset - self:GetHeight()))
	end)

	self.copyFrame = frame
	self.copyEdit = edit
	self.copyScroll = scroll
	return frame
end

-- Drop textures and atlases so the copied text is clean, keeping the colour.
local function CleanMessage(msg, r, g, b)
	msg = gsub(msg, "|T(.-):.-|t", "")
	msg = gsub(msg, "|A(.-):.-|a", "")
	return format("|cff%02x%02x%02x%s|r", (r or 1) * 255, (g or 1) * 255, (b or 1) * 255, msg)
end

function Module:CopyChat(chatFrame)
	if not self.copyFrame then
		self:CreateCopyWindow()
	end
	chatFrame = chatFrame or _G.SELECTED_DOCK_FRAME or _G.SELECTED_CHAT_FRAME or _G.ChatFrame1

	local lines = {}
	for i = 1, chatFrame:GetNumMessages() do
		local msg, r, g, b = chatFrame:GetMessageInfo(i)
		if msg and not IsSecret(msg) then
			lines[#lines + 1] = CleanMessage(msg, r, g, b)
		end
	end

	self.copyFrame:Show()
	self.copyEdit:SetText(table.concat(lines, "\n"))
	self.copyEdit:HighlightText()
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
	button:SetPoint("BOTTOMLEFT", _G.ChatFrame1, "TOPLEFT", 0, 60)
	button:SetSize(24, 24)

	-- The stock friends and queue art fill the whole button, and a friend-online
	-- toast animates the queue art and a fly-out panel to full alpha over it. Rather
	-- than fight those animations, our skin lives on an overlay frame a few levels
	-- above everything on the button, so it always sits on top. The button keeps its
	-- mouse and click behaviour underneath (the overlay takes no mouse input).
	if not button.KKUI_Skin then
		local skin = CreateFrame("Frame", nil, button)
		skin:SetAllPoints(button)
		skin:SetFrameLevel(button:GetFrameLevel() + 5)
		K.CreateGradientBackground(skin, 0.85)
		K.CreateBorder(skin)

		local icon = skin:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("CENTER", skin, "CENTER", 0, 0)
		icon:SetSize(20, 20)
		local preferred = "housefinder_neighborhood-list-friend-icon"
		if C_Texture and C_Texture.GetAtlasInfo and not C_Texture.GetAtlasInfo(preferred) then
			preferred = "friends-icon-friendsAvailable"
		end
		icon:SetAtlas(preferred)

		button.KKUI_Skin = skin
		button.KKUI_Icon = icon

		-- Move the online friend count onto the overlay so it reads over our skin.
		if button.FriendCount then
			button.FriendCount:SetParent(skin)
			button.FriendCount:ClearAllPoints()
			button.FriendCount:SetPoint("BOTTOMRIGHT", skin, "BOTTOMRIGHT", 1, -1)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Combat log (load-on-demand)
-- ---------------------------------------------------------------------------

-- Skin the Combat Log once its addon is present: strip and reskin the quick
-- filter bar, and re-hide the combat-log frame's own background, which the addon
-- re-shows when it loads (this is what washed our gradient out on that tab).
function Module:StyleCombatLog()
	local quickButtons = _G.CombatLogQuickButtonFrame_Custom
	if not quickButtons or quickButtons.KKUI_Skinned then
		return
	end
	quickButtons.KKUI_Skinned = true

	local function StripQuickButtons()
		for _, region in ipairs({ quickButtons:GetRegions() }) do
			if region.GetObjectType and region:GetObjectType() == "Texture" then
				region:SetTexture(nil)
				region:SetAtlas(nil)
			end
		end
		if _G.CombatLogQuickButtonFrame_CustomTexture then
			_G.CombatLogQuickButtonFrame_CustomTexture:SetTexture(nil)
			_G.CombatLogQuickButtonFrame_CustomTexture:Hide()
		end
	end
	StripQuickButtons()
	quickButtons:HookScript("OnShow", StripQuickButtons)
	if _G.CombatLogQuickButtonFrame_CustomTexture then
		hooksecurefunc(_G.CombatLogQuickButtonFrame_CustomTexture, "SetTexture", function(self, tex)
			if tex then
				self:SetTexture(nil)
			end
		end)
	end

	K.CreateBackground(quickButtons, 0.05, 0.05, 0.05, 0.85)
	K.CreateBorder(quickButtons)
	local progress = _G.CombatLogQuickButtonFrame_CustomProgressBar
	if progress then
		progress:SetStatusBarTexture(0)
		progress:SetAlpha(0)
	end

	local filterButton = _G.CombatLogQuickButtonFrame_CustomAdditionalFilterButton
	if filterButton then
		StripTab(filterButton)
	end

	-- Loading the addon calls FCF_SetWindowAlpha on the combat-log frame, which
	-- re-shows the stock backdrop and border behind our gradient. Re-run the skin,
	-- which kills those textures again and keeps them killed through its show hook.
	self:StyleFrame(2)
end

-- Run the combat-log skin now if its addon is already up, otherwise wait for it.
function Module:SetupCombatLog()
	local loaded = C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Blizzard_CombatLog")
	if loaded then
		self:StyleCombatLog()
		return
	end

	local watcher = CreateFrame("Frame")
	watcher:RegisterEvent("ADDON_LOADED")
	watcher:SetScript("OnEvent", function(self2, _, addon)
		if addon == "Blizzard_CombatLog" then
			Module:StyleCombatLog()
			self2:UnregisterEvent("ADDON_LOADED")
		end
	end)
end

-- ---------------------------------------------------------------------------
-- Enable
-- ---------------------------------------------------------------------------

-- Blank the frame's own stock backdrop and border textures. DisableDrawLayer does
-- most of it, but hide the textures directly too so nothing lingers if the Combat
-- Log re-shows them on load.
local function KillFrameTextures(frame)
	for _, region in ipairs({ frame:GetRegions() }) do
		if region.GetObjectType and region:GetObjectType() == "Texture" then
			local layer = region:GetDrawLayer()
			if layer == "BACKGROUND" or layer == "BORDER" then
				region:SetAlpha(0)
				region:Hide()
			end
		end
	end
end

function Module:StyleFrame(index)
	local frame = _G["ChatFrame" .. index]
	if not frame then
		return
	end
	local db = C.Chat

	ApplyFont(frame)

	-- Blizzard's fade helpers read frame.oldAlpha, which is only ever set by
	-- FCF_SetWindowAlpha. A frame that has not had its alpha set yet leaves it nil
	-- and the fade errors, so seed it the way the reference UIs do.
	frame.oldAlpha = frame.oldAlpha or 0

	-- Blank the stock backdrop and border. The Combat Log re-shows its frame
	-- textures when its addon loads, so re-apply this on every show as well.
	frame:DisableDrawLayer("BACKGROUND")
	frame:DisableDrawLayer("BORDER")
	frame:SetClampRectInsets(0, 0, 0, 0)
	KillFrameTextures(frame)

	if not frame.KKUI_BackdropGuard then
		frame.KKUI_BackdropGuard = true
		frame:HookScript("OnShow", function(self)
			self:DisableDrawLayer("BACKGROUND")
			self:DisableDrawLayer("BORDER")
			KillFrameTextures(self)
		end)
	end

	-- Hide the minimal scroll bar and the jump-to-bottom button. Scrolling is on
	-- the mouse wheel and the side strip has its own jump-to-newest button, so
	-- both are just clutter down the right edge of the messages.
	if frame.ScrollBar then
		frame.ScrollBar:SetAlpha(0)
		frame.ScrollBar:EnableMouse(false)
		frame.ScrollBar:HookScript("OnShow", function(self)
			self:SetAlpha(0)
		end)
	end
	if frame.ScrollToBottomButton then
		frame.ScrollToBottomButton:Hide()
		frame.ScrollToBottomButton:HookScript("OnShow", frame.ScrollToBottomButton.Hide)
	end

	SkinTab(_G["ChatFrame" .. index .. "Tab"])
	SkinEditBox(_G["ChatFrame" .. index .. "EditBox"])

	if db.MouseWheelScroll then
		frame:SetScript("OnMouseWheel", OnMouseWheel)
		frame:EnableMouseWheel(true)
	end

	-- Fade idle windows using the built-in fade timers. Skipped when our own idle
	-- fade is on, since that dims the whole frame instead of dropping old lines.
	frame:SetFading(db.Fade and not db.IdleFade)
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
		"SAY",
		"EMOTE",
		"YELL",
		"GUILD",
		"OFFICER",
		"GUILD_ACHIEVEMENT",
		"MONSTER_SAY",
		"MONSTER_EMOTE",
		"MONSTER_YELL",
		"MONSTER_WHISPER",
		"MONSTER_BOSS_EMOTE",
		"MONSTER_BOSS_WHISPER",
		"PARTY",
		"PARTY_LEADER",
		"RAID",
		"RAID_LEADER",
		"RAID_WARNING",
		"INSTANCE_CHAT",
		"INSTANCE_CHAT_LEADER",
		"BG_HORDE",
		"BG_ALLIANCE",
		"BG_NEUTRAL",
		"SYSTEM",
		"ERRORS",
		"AFK",
		"DND",
		"IGNORED",
		"ACHIEVEMENT",
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

	-- A soft sound on an incoming whisper, throttled so a burst is one chime, and a
	-- taskbar flash so a whisper still lands while the game is in the background.
	if C.Chat.WhisperSound then
		local lastPlay = 0
		local function OnWhisper()
			local now = GetTime()
			if now - lastPlay > 3 then
				lastPlay = now
				PlaySound(SOUNDKIT.TELL_MESSAGE, "Master")
			end
			if FlashClientIcon then
				FlashClientIcon()
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
		-- quick-bar when it is enabled. SetUserPlaced stops Edit Mode's managed
		-- layout from dragging the window back off the corner after a reload.
		local bottom = C.Chat.ChatBar and 34 or 6
		_G.ChatFrame1:SetUserPlaced(true)
		_G.ChatFrame1:ClearAllPoints()
		_G.ChatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 6, bottom)
		anchoring = false
	end
	AnchorChat()
	hooksecurefunc(_G.ChatFrame1, "SetPoint", AnchorChat)
	-- Edit Mode re-applies its saved layout on world enter, after our first pin, so
	-- re-assert the corner then.
	self:RegisterEvent("PLAYER_ENTERING_WORLD", AnchorChat)

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

	-- Blizzard re-textures tabs on colour/hover updates, keep them blanked and
	-- recolour the label so the selected tab stands out.
	if _G.FCFTab_UpdateColors then
		hooksecurefunc("FCFTab_UpdateColors", function(tab, selected)
			StripTab(tab)
			ColorTab(tab, selected)
		end)
	end

	-- Restore the unread cue the stripped glow used to give.
	if _G.FCF_StartAlertFlash then
		hooksecurefunc("FCF_StartAlertFlash", TabAlertStart)
	end
	if _G.FCF_StopAlertFlash then
		hooksecurefunc("FCF_StopAlertFlash", TabAlertStop)
	end


	-- Kill the per-frame scroll button clutter and combat-log quick button art.
	for i = 1, NUM_FRAMES do
		local buttonFrame = _G["ChatFrame" .. i .. "ButtonFrame"]
		if buttonFrame then
			buttonFrame:Hide()
			buttonFrame:HookScript("OnShow", buttonFrame.Hide)
		end
	end
	-- The Combat Log lives in a load-on-demand addon (Blizzard_CombatLog) that only
	-- loads the first time its tab is opened, well after we skin the chat. So its
	-- quick-filter bar and the combat-log frame's own washed background do not exist
	-- yet here. Defer that work until the addon loads.
	self:SetupCombatLog()

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

	-- Style permanent windows the user opens themselves, so a new tab is skinned
	-- at once instead of only after the next reload.
	if _G.FCF_OpenNewWindow then
		hooksecurefunc("FCF_OpenNewWindow", function()
			local frame = _G.FCF_GetCurrentChatFrame and _G.FCF_GetCurrentChatFrame()
			if frame then
				Module:StyleFrame(frame:GetID())
			end
		end)
	end

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
	if self.SetupKeywords then
		self:SetupKeywords()
	end
	if self.SetupHistory then
		self:SetupHistory()
	end

	-- Idle fade: dim the whole chat to a resting alpha when the mouse is away and
	-- lift it back on hover or while the edit box is focused. Only our own frames
	-- are faded (the message frame and the channel bar) - the tab dock is left to
	-- Blizzard, since writing tab alpha taints the dock update on 12.1.
	if C.Chat.IdleFade then
		local rest = C.Chat.IdleFadeAlpha or 0.25
		local group = { _G.ChatFrame1 }
		if C.Chat.ChatBar and _G.KKUI_ChatBar then
			group[#group + 1] = _G.KKUI_ChatBar
		end
		local editBox = _G.ChatFrame1EditBox
		local fadeFrame = CreateFrame("Frame")
		local elapsed = 0
		local STEP = 3 -- alpha per second
		fadeFrame:SetScript("OnUpdate", function(_, delta)
			elapsed = elapsed + delta
			if elapsed < 0.1 then
				return
			end
			elapsed = 0
			local over = (editBox and editBox:HasFocus()) or false
			if not over then
				for _, f in ipairs(group) do
					if f and f:IsMouseOver() then
						over = true
						break
					end
				end
			end
			local target = over and 1 or rest
			local current = _G.ChatFrame1:GetAlpha()
			if current ~= target then
				local move = STEP * 0.1
				local a = current < target and math.min(target, current + move) or math.max(target, current - move)
				for _, f in ipairs(group) do
					if f then
						f:SetAlpha(a)
					end
				end
			end
		end)
	end

	-- Sticky whispers: keep the edit box on WHISPER after you reply, so a back and
	-- forth does not need re-selecting the channel each line.
	if C.Chat.StickyWhisper and _G.ChatTypeInfo then
		_G.ChatTypeInfo.WHISPER.sticky = 1
		_G.ChatTypeInfo.BN_WHISPER.sticky = 1
	end
end
