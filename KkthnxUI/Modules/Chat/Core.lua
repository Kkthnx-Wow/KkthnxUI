--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Main entry point for chat system modifications and enhancements.
-- - Design: Hooks Blizzard's chat frame logic to apply skinning, custom anchoring, and utility features.
-- - Events: PLAYER_ENTERING_WORLD, UI_SCALE_CHANGED, CHAT_MSG_WHISPER, etc.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Chat")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local Ambiguate = Ambiguate
local BNFeaturesEnabledAndConnected = BNFeaturesEnabledAndConnected
local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local C_GuildInfo_IsGuildOfficer = C_GuildInfo.IsGuildOfficer
local ChatEdit_ChooseBoxForSend = ChatEdit_ChooseBoxForSend
local ChatEdit_ParseText = ChatEdit_ParseText
local ChatFrame_SendTell = ChatFrame_SendTell
local ConsoleExec = ConsoleExec
local CreateFrame = CreateFrame
local FCF_SavePositionAndDimensions = FCF_SavePositionAndDimensions
local GeneralDockManager = _G.GeneralDockManager
local GetCVar = GetCVar
local GetChannelName = GetChannelName
local GetInstanceInfo = GetInstanceInfo
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsInGroup = IsInGroup
local IsInGuild = IsInGuild
local IsInRaid = IsInRaid
local IsPartyLFG = IsPartyLFG
local IsShiftKeyDown = IsShiftKeyDown
local PlaySound = PlaySound
local SetCVar = SetCVar
local UnitName = UnitName
local hooksecurefunc = hooksecurefunc
local ipairs = ipairs
local pcall = pcall
local select = select
local string_find = string.find
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_len = string.len
local string_lower = string.lower
local string_sub = string.sub
local table_unpack = unpack
local tostring = tostring
local type = type

-- ---------------------------------------------------------------------------
-- Constants & State
-- ---------------------------------------------------------------------------
local CHAT_FRAMES = _G.CHAT_FRAMES
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local UIParent = _G.UIParent

local messageSoundID = _G.SOUNDKIT.TELL_MESSAGE
local maxLines = 2048
local charCount = 0
local repeatedText
local MIN_REPEAT_CHARACTERS = 5

Module.MuteCache = {}

local whisperEvents = {
	["CHAT_MSG_WHISPER"] = true,
	["CHAT_MSG_BN_WHISPER"] = true,
}

-- ---------------------------------------------------------------------------
-- Utility Functions
-- ---------------------------------------------------------------------------
local function getGroupDistribution()
	-- REASON: Determines the appropriate chat prefix (/bg, /ra, /p, /s) based on group/instance status.
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

local function countLinkCharacters(text)
	-- REASON: Helper for correct character counting when hyperlinks are present in the text.
	charCount = charCount + (string_len(text) + 4)
end

-- ---------------------------------------------------------------------------
-- EditBox Logic
-- ---------------------------------------------------------------------------
local function editBoxOnTextChanged(self)
	-- REASON: Main handler for chat edit box changes; handles spam prevention, shortcuts, and character counting.
	local text = self:GetText()
	local textLen = string_len(text)

	-- WARNING: Protect against repeating character spam by hiding the edit box if a limit is reached.
	if (not repeatedText or not string_find(text, repeatedText, 1, true)) and InCombatLockdown() then
		if textLen > MIN_REPEAT_CHARACTERS then
			local repeatChar = true
			for i = 1, MIN_REPEAT_CHARACTERS do
				local charIndex = -1 - i
				if string_sub(text, -i, -i) ~= string_sub(text, charIndex, charIndex) then
					repeatChar = false
					break
				end
			end

			if repeatChar then
				repeatedText = text
				self:Hide()
				return
			end
		end
	end

	-- REASON: Custom chat commands (/tt for target whisper, /gr for group distribution).
	if textLen == 4 then
		if text == "/tt " then
			local name, realm = UnitName("target")
			if name then
				name = string_gsub(name, "%s", "")
				if realm and realm ~= "" then
					name = name .. "-" .. string_gsub(realm, "[%s%-]", "")
				end
			end

			if name then
				ChatFrame_SendTell(name, self.chatFrame)
			else
				_G.UIErrorsFrame:AddMessage(K.InfoColor .. L["Invalid Target"])
			end
		elseif text == "/gr " then
			self:SetText(getGroupDistribution() .. string_sub(text, 5))
			_G.ChatEdit_ParseText(self, 0)
		end
	end

	-- REASON: Detailed character count logic that excludes hyperlink overhead.
	charCount = 0
	for link in string_gmatch(text, "(|c%x-|H.-|h).-|h|r") do
		countLinkCharacters(link)
	end
	if charCount ~= 0 then
		textLen = textLen - charCount
	end

	local remainingCount = 255 - textLen
	if remainingCount >= 50 then
		self.characterCount:SetTextColor(0.74, 0.74, 0.74, 0.5)
	elseif remainingCount >= 20 then
		self.characterCount:SetTextColor(1, 0.6, 0, 0.5)
	else
		self.characterCount:SetTextColor(1, 0, 0, 0.5)
	end

	self.characterCount:SetText(textLen > 0 and (255 - textLen) or "")

	if repeatedText then
		repeatedText = nil
	end
end

-- ---------------------------------------------------------------------------
-- Anchoring and Scaling
-- ---------------------------------------------------------------------------
function Module:TabSetAlpha(alpha)
	-- REASON: Ensures chat tabs stay visible if they are glowing or if the user is interacting with them.
	if self.glow:IsShown() and alpha ~= 1 then
		self:SetAlpha(1)
	elseif alpha < 0 then
		self:SetAlpha(0)
	end
end

local function updateChatAnchor(self, _, _, _, x, y)
	-- REASON: Forces the chat frame to stay at its locked position to prevent drift or accidental movement.
	if not C["Chat"].Lock then
		return
	end

	if not (x == 7 and y == 11) then
		self:ClearAllPoints()
		self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 7, 11)
		self:SetSize(C["Chat"].Width, C["Chat"].Height)
	end
end

local isScaling = false
function Module:UpdateChatSize()
	-- REASON: Resizes the chat frame according to the user's config, ensuring consistent layout across UI scales.
	if not C["Chat"].Lock then
		return
	end

	if isScaling then
		return
	end
	isScaling = true

	local chatFrame1 = _G.ChatFrame1
	if chatFrame1:IsMovable() then
		chatFrame1:SetUserPlaced(true)
	end

	if chatFrame1.FontStringContainer then
		chatFrame1.FontStringContainer:SetPoint("TOPLEFT", chatFrame1, "TOPLEFT", -2, 2)
		chatFrame1.FontStringContainer:SetPoint("BOTTOMRIGHT", chatFrame1, "BOTTOMRIGHT", 2, -6)
	end

	chatFrame1:ClearAllPoints()
	chatFrame1:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 7, 11)
	chatFrame1:SetWidth(C["Chat"].Width)
	chatFrame1:SetHeight(C["Chat"].Height)

	isScaling = false
end

-- ---------------------------------------------------------------------------
-- Skinning Logic
-- ---------------------------------------------------------------------------
local function createBackground(self)
	-- REASON: Creates the border and optional background for each chat frame.
	local frame = CreateFrame("Frame", nil, self, "BackdropTemplate")
	frame:SetPoint("TOPLEFT", self.Background, "TOPLEFT", -1, 1)
	frame:SetPoint("BOTTOMRIGHT", self.Background, "BOTTOMRIGHT", 10, -1)
	frame:SetFrameLevel(self:GetFrameLevel())
	frame:CreateBorder()
	frame:SetShown(C["Chat"].Background)

	return frame
end

local function updateEditboxFont(editbox)
	editbox:SetFontObject(K.UIFont)
	editbox.header:SetFontObject(K.UIFont)
end

function Module:SkinChat()
	-- REASON: Entry point for chat frame skinning; cleans up Blizzard's default assets and applies KkthnxUI styles.
	if not self or self.styled then
		return
	end

	local name = self:GetName()
	local font, fontSize, fontStyle = self:GetFont()

	self:SetFont(font, fontSize, fontStyle)
	self:SetClampRectInsets(0, 0, 0, 0)
	self:SetClampedToScreen(false)
	self:SetFading(C["Chat"].Fading)
	self:SetTimeVisible(C["Chat"].FadingTimeVisible)

	if self:GetMaxLines() < maxLines then
		self:SetMaxLines(maxLines)
	end

	self.__background = createBackground(self)

	local eb = _G[name .. "EditBox"]
	eb:SetAltArrowKeyMode(false)
	eb:SetClampedToScreen(true)
	eb:ClearAllPoints()
	eb:SetPoint("BOTTOMLEFT", self.__background, "TOPLEFT", 0, 20)
	eb:SetPoint("TOPRIGHT", self.__background, "TOPRIGHT", 0, 46)
	eb:StripTextures(2)
	eb:CreateBorder()
	updateEditboxFont(eb)
	eb:Hide()
	eb:HookScript("OnTextChanged", editBoxOnTextChanged)

	local lang = _G[name .. "EditBoxLanguage"]
	lang:GetRegions():SetAlpha(0)
	lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", 5, 0)
	lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 29, 0)
	lang:CreateBorder()

	local tab = _G[name .. "Tab"]
	tab:SetAlpha(1)
	tab.Text:SetFont(font, select(2, _G.KkthnxUIFont:GetFont()) + 1, fontStyle)
	tab:StripTextures(7)
	hooksecurefunc(tab, "SetAlpha", Module.TabSetAlpha)

	local characterText = eb:CreateFontString(nil, "ARTWORK")
	characterText:SetFontObject(K.UIFont)
	characterText:SetPoint("TOPRIGHT", eb, "TOPRIGHT", 4, 0)
	characterText:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 4, 0)
	characterText:SetJustifyH("CENTER")
	characterText:SetWidth(40)
	eb.characterCount = characterText

	self.buttonFrame:Kill()
	self.ScrollBar:Kill()
	self.ScrollToBottomButton:Kill()
	Module:ToggleChatFrameTextures(self)

	self.oldAlpha = self.oldAlpha or 0 -- REASON: Suppress occasional Blizzard UI scaling errors.

	self:HookScript("OnMouseWheel", Module.QuickMouseScroll)

	self.styled = true
end

function Module:ToggleChatFrameTextures(frame)
	if C["Chat"].Background then
		frame:DisableDrawLayer("BORDER")
		frame:DisableDrawLayer("BACKGROUND")
	else
		frame:EnableDrawLayer("BORDER")
		frame:EnableDrawLayer("BACKGROUND")
	end
end

function Module:ToggleChatBackground()
	for _, chatFrameName in ipairs(CHAT_FRAMES) do
		local frame = _G[chatFrameName]
		if frame.__background then
			frame.__background:SetShown(C["Chat"].Background)
		end
		Module:ToggleChatFrameTextures(frame)
	end
end

-- ---------------------------------------------------------------------------
-- Channel Rotation
-- ---------------------------------------------------------------------------
local cycles = {
	{
		chatType = "SAY",
		IsActive = function()
			return true
		end,
	},
	{
		chatType = "PARTY",
		IsActive = function()
			return IsInGroup()
		end,
	},
	{
		chatType = "RAID",
		IsActive = function()
			return IsInRaid()
		end,
	},
	{
		chatType = "INSTANCE_CHAT",
		IsActive = function()
			return IsPartyLFG()
		end,
	},
	{
		chatType = "GUILD",
		IsActive = function()
			return IsInGuild()
		end,
	},
	{
		chatType = "OFFICER",
		IsActive = function()
			return C_GuildInfo_IsGuildOfficer()
		end,
	},
	{
		chatType = "CHANNEL",
		IsActive = function(_, editbox)
			if Module.InWorldChannel and Module.WorldChannelID then
				editbox:SetAttribute("channelTarget", Module.WorldChannelID)
				return true
			end
		end,
	},
	{
		chatType = "SAY",
		IsActive = function()
			return true
		end,
	},
}

function Module:UpdateEditBoxColor()
	-- REASON: Dynamically updates the editbox border color to match the current chat type (e.g., green for guild).
	if not C["Chat"].Enable then
		return
	end

	if C_AddOns_IsAddOnLoaded("Prat-3.0") or C_AddOns_IsAddOnLoaded("Chatter") or C_AddOns_IsAddOnLoaded("BasicChatMods") or C_AddOns_IsAddOnLoaded("Glass") then
		return
	end

	local editBox = ChatEdit_ChooseBoxForSend()
	local chatType = editBox:GetAttribute("chatType")
	local editBoxBorder = editBox.KKUI_Border

	if not chatType then
		return
	end

	local insetLeft, insetRight, insetTop, insetBottom = editBox:GetTextInsets()
	editBox:SetTextInsets(insetLeft, insetRight + 18, insetTop, insetBottom)

	if editBoxBorder then
		if chatType == "CHANNEL" then
			local channelID = GetChannelName(editBox:GetAttribute("channelTarget"))

			if channelID == 0 then
				local r, g, b
				if C["General"].ColorTextures then
					r, g, b = table_unpack(C["General"].TexturesColor)
				else
					r, g, b = 1, 1, 1
				end
				editBoxBorder:SetVertexColor(r, g, b)
			else
				local color = _G.ChatTypeInfo[chatType .. channelID]
				if color then
					editBoxBorder:SetVertexColor(color.r, color.g, color.b)
				end
			end
		else
			local color = _G.ChatTypeInfo[chatType]
			if color then
				editBoxBorder:SetVertexColor(color.r, color.g, color.b)
			end
		end
	end
end
hooksecurefunc("ChatEdit_UpdateHeader", Module.UpdateEditBoxColor)

function Module:SwitchToChannel(chatType)
	self:SetAttribute("chatType", chatType)
	_G.ChatEdit_UpdateHeader(self)
end

function Module:UpdateTabChannelSwitch()
	-- REASON: Allows rotating through active chat channels by pressing Tab while the edit box is active.
	if not C["Chat"].Enable then
		return
	end

	if C_AddOns_IsAddOnLoaded("Prat-3.0") or C_AddOns_IsAddOnLoaded("Chatter") or C_AddOns_IsAddOnLoaded("BasicChatMods") or C_AddOns_IsAddOnLoaded("Glass") then
		return
	end

	if string_sub(self:GetText(), 1, 1) == "/" then
		return
	end

	local isShift = IsShiftKeyDown()
	local currentType = self:GetAttribute("chatType")
	if isShift and (currentType == "WHISPER" or currentType == "BN_WHISPER") then
		Module.SwitchToChannel(self, "SAY")
		return
	end

	local numCycles = #cycles
	for i = 1, numCycles do
		local cycle = cycles[i]
		if currentType == cycle.chatType then
			local from, to, step = i + 1, numCycles, 1
			if isShift then
				from, to, step = i - 1, 1, -1
			end

			for j = from, to, step do
				local nextCycle = cycles[j]
				if nextCycle:IsActive(nil, self) then
					Module.SwitchToChannel(self, nextCycle.chatType)
					return
				end
			end
		end
	end
end
hooksecurefunc("ChatEdit_CustomTabPressed", Module.UpdateTabChannelSwitch)

-- ---------------------------------------------------------------------------
-- Mouse Interaction
-- ---------------------------------------------------------------------------
function Module:QuickMouseScroll(dir)
	-- REASON: Accelerates chat scrolling when holding Shift (top/bottom) or Control (faster scroll).
	if not C["Chat"].Enable then
		return
	end

	if C_AddOns_IsAddOnLoaded("Prat-3.0") or C_AddOns_IsAddOnLoaded("Chatter") or C_AddOns_IsAddOnLoaded("BasicChatMods") or C_AddOns_IsAddOnLoaded("Glass") then
		return
	end

	if dir > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			self:ScrollUp()
			self:ScrollUp()
		end
	else
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			self:ScrollDown()
			self:ScrollDown()
		end
	end
end

-- ---------------------------------------------------------------------------
-- Tab Interaction & Sound
-- ---------------------------------------------------------------------------
function Module:ChatWhisperSticky()
	-- REASON: Configures whether or not whispers stay active in the editbox after sending.
	local stickyValue = C["Chat"].Sticky and 1 or 0
	_G.ChatTypeInfo["WHISPER"].sticky = stickyValue
	_G.ChatTypeInfo["BN_WHISPER"].sticky = stickyValue
end

function Module:UpdateTabColors(selected)
	-- REASON: Skins the chat tabs with custom colors for selection and active whispers.
	if selected then
		self.Text:SetTextColor(1, 0.8, 0)
		self.whisperIndex = 0
	else
		self.Text:SetTextColor(0.5, 0.5, 0.5)
	end

	if self.whisperIndex == 1 then
		self.glow:SetVertexColor(1, 0.5, 1)
	elseif self.whisperIndex == 2 then
		self.glow:SetVertexColor(0, 1, 0.96)
	else
		self.glow:SetVertexColor(1, 0.8, 0)
	end
end

function Module:UpdateTabEventColors(event)
	local tab = _G[self:GetName() .. "Tab"]
	local selected = GeneralDockManager.selected:GetID() == tab:GetID()

	if event == "CHAT_MSG_WHISPER" then
		tab.whisperIndex = 1
		Module.UpdateTabColors(tab, selected)
	elseif event == "CHAT_MSG_BN_WHISPER" then
		tab.whisperIndex = 2
		Module.UpdateTabColors(tab, selected)
	end
end

function Module:PlayWhisperSound(event, _, author)
	-- REASON: Plays a notification sound for whispers, respecting a cooldown to avoid spam.
	if whisperEvents[event] then
		local name = Ambiguate(author, "none")
		local currentTime = GetTime()

		if Module.MuteCache[name] == currentTime then
			return
		end

		if not self.soundTimer or currentTime > self.soundTimer then
			PlaySound(messageSoundID, "master")
		end

		self.soundTimer = currentTime + 5
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:OnEnable()
	-- REASON: Centralized initialization for the Chat module; applies skins, mounts elements, and sets CVars.
	if not C["Chat"].Enable then
		return
	end

	-- REASON: Hide the default Quick Join button if the Friends DataText is active to prevent redundancy.
	local quickJoinToastButton = _G.QuickJoinToastButton
	if C["DataText"].Friends and quickJoinToastButton then
		quickJoinToastButton:SetAlpha(0)
		quickJoinToastButton:EnableMouse(false)
		quickJoinToastButton:UnregisterAllEvents()
	end

	-- COMPAT: Skip custom skinning if total-replacement chat addons are loaded.
	if C_AddOns_IsAddOnLoaded("Prat-3.0") or C_AddOns_IsAddOnLoaded("Chatter") or C_AddOns_IsAddOnLoaded("BasicChatMods") or C_AddOns_IsAddOnLoaded("Glass") then
		return
	end

	for i = 1, NUM_CHAT_WINDOWS do
		Module.SkinChat(_G["ChatFrame" .. i])
	end

	hooksecurefunc("FCF_OpenTemporaryWindow", function()
		for _, chatFrameName in ipairs(CHAT_FRAMES) do
			local frame = _G[chatFrameName]
			if frame.isTemporary then
				Module.SkinChat(frame)
			end
		end
	end)

	hooksecurefunc("FCFTab_UpdateColors", Module.UpdateTabColors)
	hooksecurefunc("FloatingChatFrameManager_OnEvent", Module.UpdateTabEventColors)
	hooksecurefunc(ChatFrameUtil, "ProcessMessageEventFilters", Module.PlayWhisperSound)
	-- hooksecurefunc("FCF_MinimizeFrame", Module.HandleMinimizedFrame)
	hooksecurefunc("ChatEdit_CustomTabPressed", Module.UpdateTabChannelSwitch)

	if _G.CHAT_OPTIONS then
		_G.CHAT_OPTIONS.HIDE_FRAME_ALERTS = true
	end
	SetCVar("chatStyle", "classic")
	SetCVar("chatMouseScroll", 1)
	if _G.CombatLogQuickButtonFrame_CustomTexture then
		_G.CombatLogQuickButtonFrame_CustomTexture:SetTexture(nil)
	end

	-- -----------------------------------------------------------------------
	-- Load Sub-Modules
	-- -----------------------------------------------------------------------
	local loadChatModulesList = {
		"ChatWhisperSticky",
		"CreateChatHistory",
		"CreateChatItemLevels",
		"CreateChatRename",
		"CreateChatRoleIcon",
		"CreateCopyChat",
		"CreateCopyURL",
		"CreateEmojis",
		"CreateVoiceActivity",
	}

	for _, funcName in ipairs(loadChatModulesList) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end

	-- -----------------------------------------------------------------------
	-- Chat Locking
	-- -----------------------------------------------------------------------
	if C["Chat"].Lock then
		Module:UpdateChatSize()
		K:RegisterEvent("UI_SCALE_CHANGED", Module.UpdateChatSize)
		local chatFrame1 = _G.ChatFrame1
		hooksecurefunc(chatFrame1, "SetPoint", updateChatAnchor)
		hooksecurefunc("FCF_SavePositionAndDimensions", Module.UpdateChatSize)
		FCF_SavePositionAndDimensions(chatFrame1)
	end

	-- -----------------------------------------------------------------------
	-- Language Filter
	-- -----------------------------------------------------------------------
	if not BNFeaturesEnabledAndConnected() then
		return
	end

	if C["Chat"].Freedom then
		if GetCVar("portal") == "CN" then
			ConsoleExec("portal TW")
		end
		SetCVar("profanityFilter", 0)
	else
		SetCVar("profanityFilter", 1)
	end
end
