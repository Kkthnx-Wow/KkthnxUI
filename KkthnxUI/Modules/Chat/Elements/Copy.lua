--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Provides chat copying functionality and a quick menu for various UI actions.
-- - Design: Creates a copy frame with a scrollable edit box and a side menu with utility buttons.
-- - Events: N/A (UI-driven logic)
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Chat")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local BINDING_NAME_TOGGLECOMBATLOG = _G.BINDING_NAME_TOGGLECOMBATLOG
local CLOSE = _G.CLOSE
local COMBATLOGDISABLED = _G.COMBATLOGDISABLED
local COMBATLOGENABLED = _G.COMBATLOGENABLED
local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local CreateFrame = _G.CreateFrame
local FCF_SetChatWindowFontSize = _G.FCF_SetChatWindowFontSize
local GameTooltip = _G.GameTooltip
local GetTime = _G.GetTime
local InCombatLockdown = InCombatLockdown
local LoggingCombat = _G.LoggingCombat
local OPTIONS_MENU = _G.OPTIONS_MENU
local PlaySound = _G.PlaySound
local RELOADUI = _G.RELOADUI
local RandomRoll = _G.RandomRoll
local ReloadUI = _G.ReloadUI
local ScrollFrameTemplate_OnMouseWheel = _G.ScrollFrameTemplate_OnMouseWheel
local SendChatMessage = _G.SendChatMessage
local StaticPopup_Show = _G.StaticPopup_Show
local UIParent = _G.UIParent
local math_random = math.random
local string_format = string.format
local string_gsub = string.gsub
local table_concat = table.concat
local table_insert = table.insert
local tostring = tostring

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local lines = {}
local copyEditBox
local copyFrame
local sideMenu
local lastClickTime = 0
local ROLL_COOLDOWN = 2

local LEFT_BUTTON_STRING = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t "
local RIGHT_BUTTON_STRING = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t "

-- ---------------------------------------------------------------------------
-- Menu Configuration
-- ---------------------------------------------------------------------------
local menuList = {
	{ text = K.SystemColor .. OPTIONS_MENU .. "|r", isTitle = true, notCheckable = true },
	{ text = "", notClickable = true, notCheckable = true },
	{
		text = L["Install"],
		notCheckable = true,
		func = function()
			_G.SlashCmdList["KKUI_INSTALLER"]()
		end,
	},
	{
		text = L["MoveUI"],
		notCheckable = true,
		func = function()
			_G.SlashCmdList["KKUI_MOVEUI"]()
		end,
	},
	{
		text = "Changelog",
		notCheckable = true,
		func = function()
			_G.SlashCmdList["KKUI_CHANGELOG"]()
		end,
	},
	{
		text = "Commands List",
		notCheckable = true,
		func = function()
			_G.SlashCmdList["KKUI_COMMANDS"]("help")
		end,
	},
	{
		text = RELOADUI,
		notCheckable = true,
		func = function()
			if InCombatLockdown() then
				_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
				return
			end
			ReloadUI()
		end,
	},
	{ text = "", notClickable = true, notCheckable = true },
	{
		text = BINDING_NAME_TOGGLECOMBATLOG,
		notCheckable = true,
		func = function()
			if not LoggingCombat() then
				LoggingCombat(true)
				K.Print("|cffffff00" .. COMBATLOGENABLED .. "|r")
			else
				LoggingCombat(false)
				K.Print("|cffffff00" .. COMBATLOGDISABLED .. "|r")
			end
		end,
	},
	{ text = "", notClickable = true, notCheckable = true },
}

-- REASON: Dynamically add Skada support if the addon is active.
if C_AddOns_IsAddOnLoaded("Skada") then
	table_insert(menuList, {
		text = "Skada",
		hasArrow = true,
		notCheckable = true,
		menuList = {
			{
				text = "Toggle Skada",
				notCheckable = true,
				func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
						return
					end
					PlaySound(21968)
					if _G.Skada and _G.Skada.ToggleWindow then
						_G.Skada:ToggleWindow()
					end
				end,
			},
		},
	})
	table_insert(menuList, { text = "", notClickable = true, notCheckable = true })
end

-- REASON: Dynamically add Details! support if the addon is active.
if C_AddOns_IsAddOnLoaded("Details") then
	table_insert(menuList, {
		text = "Details",
		hasArrow = true,
		notCheckable = true,
		menuList = {
			{
				text = "Reset Details",
				notCheckable = true,
				func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
						return
					end
					_G.KkthnxUIDB.Variables["ResetDetails"] = true
					StaticPopup_Show("KKUI_CHANGES_RELOAD")
				end,
			},
			{
				text = "Toggle Details",
				notCheckable = true,
				func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
						return
					end
					PlaySound(21968)
					if _G._detalhes and _G._detalhes.ToggleWindows then
						_G._detalhes:ToggleWindows()
					end
				end,
			},
		},
	})
	table_insert(menuList, { text = "", notClickable = true, notCheckable = true })
end

table_insert(menuList, { text = "|CFFFF3333" .. CLOSE .. "|r", notCheckable = true, func = function() end })

-- ---------------------------------------------------------------------------
-- Chat Processing Logic
-- ---------------------------------------------------------------------------
local function canChangeMessage(arg1, id)
	-- REASON: Helper for identifying protected message types (e.g., BN whispers).
	if id and arg1 == "" then
		return id
	end
end

local function isMessageProtected(msg)
	-- REASON: Checks if a message contains BN identifier tags to avoid illegal/tainted copying.
	return msg and (msg ~= string_gsub(msg, "(:?|?)|K(.-)|k", canChangeMessage))
end

local function replaceMessage(msg, r, g, b)
	-- REASON: Strips complex formatting (textures, atlases) and applies a hex color code for clean copying.
	local hexRGB = K.RGBToHex(r, g, b)
	msg = string_gsub(msg, "|T(.-):.-|t", "%1")
	msg = string_gsub(msg, "|A(.-):.-|a", "%1")
	return string_format("%s%s|r", hexRGB, msg)
end

function Module:GetChatLines()
	-- REASON: Iterates through the chat frame's message buffer and prepares it for the copy editbox.
	local index = 1
	for i = 1, self:GetNumMessages() do
		local msg, r, g, b = self:GetMessageInfo(i)
		if msg and not isMessageProtected(msg) then
			r, g, b = r or 1, g or 1, b or 1
			msg = replaceMessage(msg, r, g, b)
			lines[index] = tostring(msg)
			index = index + 1
		end
	end
	return index - 1
end

-- ---------------------------------------------------------------------------
-- UI Callbacks
-- ---------------------------------------------------------------------------
function Module:ChatCopy_OnClick(btn)
	-- REASON: Main interaction handler for the chat copy button.
	if btn == "LeftButton" then
		if not copyFrame:IsShown() then
			local chatFrame = _G.SELECTED_DOCK_FRAME
			local _, fontSize = chatFrame:GetFont()
			-- REASON: Temporarily collapse font size to ensure all messages fit in the line count retrieval.
			FCF_SetChatWindowFontSize(chatFrame, chatFrame, 0.01)
			PlaySound(21968)
			copyFrame:Show()

			local lineCount = Module.GetChatLines(chatFrame)
			local formattedText = table_concat(lines, "\n", 1, lineCount)
			FCF_SetChatWindowFontSize(chatFrame, chatFrame, fontSize)
			copyEditBox:SetText(formattedText)
		else
			copyFrame:Hide()
		end
	elseif btn == "RightButton" then
		K.TogglePanel(sideMenu)
		C["Chat"].ChatMenu = sideMenu:IsShown()
	end
end

local function resetChatAlertJustify(frame)
	if frame.SetJustification then
		frame:SetJustification("LEFT")
	end
end

-- ---------------------------------------------------------------------------
-- UI Construction
-- ---------------------------------------------------------------------------
function Module:ChatCopy_CreateMenu()
	-- REASON: Creates the vertical side menu container for the chat frame.
	sideMenu = CreateFrame("Frame", "KKUI_ChatMenu", UIParent)
	sideMenu:SetSize(18, C["Chat"].Lock and C["Chat"].Height or _G.ChatFrame1:GetHeight())
	sideMenu:SetPoint("TOPRIGHT", _G.ChatFrame1, 20, -2)
	sideMenu:SetShown(C["Chat"].ChatMenu)

	local menuButton = _G.ChatFrameMenuButton
	if menuButton then
		menuButton:ClearAllPoints()
		menuButton:SetPoint("TOP", sideMenu)
		menuButton:SetParent(sideMenu)
	end

	local channelButton = _G.ChatFrameChannelButton
	if channelButton then
		channelButton:ClearAllPoints()
		channelButton:SetPoint("TOP", menuButton, "BOTTOM", 0, -6)
		channelButton:SetParent(sideMenu)
	end

	if _G.QuickJoinToastButton then
		_G.QuickJoinToastButton:SetParent(sideMenu)
	end

	local chatAlertFrame = _G.ChatAlertFrame
	if chatAlertFrame then
		chatAlertFrame:ClearAllPoints()
		chatAlertFrame:SetPoint("BOTTOMLEFT", _G.ChatFrame1Tab, "TOPLEFT", 5, 25)
		resetChatAlertJustify(chatAlertFrame)
		hooksecurefunc(chatAlertFrame, "SetChatButtonSide", resetChatAlertJustify)
	end
end

function Module:ChatCopy_Create()
	-- REASON: Constructs the main copy dialog and its interactive elements (copy, config, roll).
	copyFrame = CreateFrame("Frame", "KKUI_CopyChat", UIParent)
	copyFrame:SetPoint("CENTER")
	copyFrame:SetSize(700, 400)
	copyFrame:Hide()
	copyFrame:SetFrameStrata("DIALOG")
	copyFrame:CreateBorder()
	K.CreateMoverFrame(copyFrame)

	copyFrame.close = CreateFrame("Button", nil, copyFrame, "UIPanelCloseButton")
	copyFrame.close:SetPoint("TOPRIGHT", copyFrame)
	copyFrame.close:SkinCloseButton()

	local scrollArea = CreateFrame("ScrollFrame", "KKUI_CopyChatScrollFrame", copyFrame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 12, -40)
	scrollArea:SetPoint("BOTTOMRIGHT", -30, 20)
	if scrollArea.ScrollBar then
		scrollArea.ScrollBar:SkinScrollBar()
	end

	copyEditBox = CreateFrame("EditBox", nil, copyFrame)
	copyEditBox:SetMultiLine(true)
	copyEditBox:SetMaxLetters(99999)
	copyEditBox:EnableMouse(true)
	copyEditBox:SetAutoFocus(false)
	copyEditBox:SetFontObject(K.UIFont)
	copyEditBox:SetWidth(scrollArea:GetWidth())
	copyEditBox:SetHeight(400)
	copyEditBox:SetScript("OnEscapePressed", function()
		copyFrame:Hide()
	end)

	copyEditBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			return
		end
		local _, maxValue = scrollArea.ScrollBar:GetMinMaxValues()
		for _ = 1, maxValue do
			ScrollFrameTemplate_OnMouseWheel(scrollArea, -1)
		end
	end)

	scrollArea:SetScrollChild(copyEditBox)
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		copyEditBox:SetHitRectInsets(0, 0, offset, (copyEditBox:GetHeight() - offset - self:GetHeight()))
	end)

	-- -----------------------------------------------------------------------
	-- Copy Button
	-- -----------------------------------------------------------------------
	local copyBtn = CreateFrame("Button", "KKUI_ChatCopyButton", UIParent)
	copyBtn:SetPoint("BOTTOM", sideMenu)
	copyBtn:CreateBorder()
	copyBtn:SetSize(16, 16)
	copyBtn:SetAlpha(0.25)

	copyBtn.Icon = copyBtn:CreateTexture(nil, "ARTWORK")
	copyBtn.Icon:SetAllPoints()
	copyBtn.Icon:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
	copyBtn:RegisterForClicks("AnyUp")
	copyBtn:SetScript("OnClick", self.ChatCopy_OnClick)

	copyBtn:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 10, 5)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(string_format("%s %s", _G.CALENDAR_COPY_EVENT, _G.CHAT))
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(LEFT_BUTTON_STRING .. L["Left Click"], "Copy Chat", 1, 1, 1)
		GameTooltip:AddDoubleLine(RIGHT_BUTTON_STRING .. L["Right Click"], "Chat Menu", 1, 1, 1)
		GameTooltip:Show()
	end)

	copyBtn:SetScript("OnLeave", function(self)
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)

	-- -----------------------------------------------------------------------
	-- Config Button
	-- -----------------------------------------------------------------------
	local configBtn = CreateFrame("Button", "KKUI_ChatConfigButton", UIParent)
	configBtn:SkinButton()
	configBtn:SetSize(16, 16)
	configBtn:SetAlpha(0.25)

	configBtn.Icon = configBtn:CreateTexture(nil, "ARTWORK")
	configBtn.Icon:SetAllPoints()
	configBtn.Icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
	configBtn:RegisterForClicks("AnyUp")
	configBtn:SetScript("OnClick", function(_, btn)
		if btn == "LeftButton" then
			PlaySound(111)
			_G.K.LibEasyMenu.Create(menuList, K.EasyMenu, configBtn, 24, 290, "MENU", 2)
		elseif btn == "RightButton" then
			K.NewGUI:Toggle()
		end
	end)

	configBtn:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 10, 5)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(OPTIONS_MENU)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(LEFT_BUTTON_STRING .. L["Left Click"], L["Toggle Quick Menu"], 1, 1, 1)
		GameTooltip:AddDoubleLine(RIGHT_BUTTON_STRING .. L["Right Click"], L["Toggle KkthnxUI Config"], 1, 1, 1)
		GameTooltip:Show()
	end)

	configBtn:SetScript("OnLeave", function(self)
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)

	-- -----------------------------------------------------------------------
	-- Roll Button
	-- -----------------------------------------------------------------------
	local rollBtn = CreateFrame("Button", "KKUI_ChatRollButton", UIParent)
	rollBtn:SkinButton()
	rollBtn:SetSize(16, 16)
	rollBtn:SetAlpha(0.25)

	rollBtn.Icon = rollBtn:CreateTexture(nil, "ARTWORK")
	rollBtn.Icon:SetAllPoints()
	rollBtn.Icon:SetAtlas("charactercreate-icon-dice")
	rollBtn:RegisterForClicks("AnyUp")
	rollBtn:SetScript("OnClick", function(_, btn)
		local currentTime = GetTime()
		if currentTime - lastClickTime < ROLL_COOLDOWN then
			K.Print("Please wait before rolling again.")
			return
		end

		lastClickTime = currentTime

		if btn == "LeftButton" then
			RandomRoll(1, 100)
		elseif btn == "RightButton" then
			local rollValue = -math_random(1, 100)
			SendChatMessage(string_format("rolls %d (1-100)", rollValue), "EMOTE")
		end
	end)

	rollBtn:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 10, 5)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(string_format("%s %s", _G.FAST, _G.ROLL))
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(LEFT_BUTTON_STRING .. L["Left Click"], "Roll a random number between 1 and 100", 1, 1, 1)
		GameTooltip:AddDoubleLine(RIGHT_BUTTON_STRING .. L["Right Click"], "Guaranteed to roll a perfect 100!", 1, 1, 1)
		GameTooltip:Show()
	end)

	rollBtn:SetScript("OnLeave", function(self)
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)

	-- REASON: Manages vertical stacking of the utility buttons on the chat side-menu.
	local function updateButtonStack()
		local activeButtons = {}
		if C["Chat"].CopyButton then
			table_insert(activeButtons, copyBtn)
		else
			copyBtn:Hide()
		end
		if C["Chat"].ConfigButton then
			table_insert(activeButtons, configBtn)
		else
			configBtn:Hide()
		end
		if C["Chat"].RollButton then
			table_insert(activeButtons, rollBtn)
		else
			rollBtn:Hide()
		end

		for i, button in ipairs(activeButtons) do
			if i == 1 then
				button:SetPoint("BOTTOM", sideMenu)
			else
				button:SetPoint("BOTTOM", activeButtons[i - 1], "TOP", 0, 6)
			end
			button:Show()
		end
	end

	updateButtonStack()

	function Module:UpdateChatButtons()
		updateButtonStack()
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateCopyChat()
	-- REASON: Entry point for chat copy and menu initialization.
	self:ChatCopy_CreateMenu()
	self:ChatCopy_Create()
end
