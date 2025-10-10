local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Chat")

-- Sourced: NDui (siweia)

local string_gsub = string.gsub
local table_concat = table.concat
local tostring = tostring

local BINDING_NAME_TOGGLECOMBATLOG = BINDING_NAME_TOGGLECOMBATLOG
local CLOSE = CLOSE
local COMBATLOGDISABLED = COMBATLOGDISABLED
local COMBATLOGENABLED = COMBATLOGENABLED
local CreateFrame = CreateFrame
local FCF_SetChatWindowFontSize = FCF_SetChatWindowFontSize
local GameTooltip = GameTooltip
local InCombatLockdown = InCombatLockdown
local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local OPTIONS_MENU = OPTIONS_MENU
local PlaySound = PlaySound
local RELOADUI = RELOADUI
local ReloadUI = ReloadUI
local ScrollFrameTemplate_OnMouseWheel = ScrollFrameTemplate_OnMouseWheel
local SlashCmdList = SlashCmdList
local StaticPopup_Show = StaticPopup_Show
local UIErrorsFrame = UIErrorsFrame
local UIParent = UIParent

local lines = {}
local editBox
local frame
local menu

local leftButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t "
local rightButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t "

local menuList = {
	{ text = K.SystemColor .. OPTIONS_MENU .. "|r", isTitle = true, notCheckable = true },
	{ text = "", notClickable = true, notCheckable = true },
	{
		text = L["Install"],
		notCheckable = true,
		func = function()
			SlashCmdList["KKUI_INSTALLER"]()
		end,
	},

	{
		text = L["MoveUI"],
		notCheckable = true,
		func = function()
			SlashCmdList["KKUI_MOVEUI"]()
		end,
	},

	{
		text = "Changelog",
		notCheckable = true,
		func = function()
			SlashCmdList["KKUI_CHANGELOG"]()
		end,
	},

	{
		text = "Commands List",
		notCheckable = true,
		func = function()
			SlashCmdList["KKUI_COMMANDS"]("help")
		end,
	},

	{
		text = RELOADUI,
		notCheckable = true,
		func = function()
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
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
			elseif LoggingCombat() then
				LoggingCombat(false)
				K.Print("|cffffff00" .. COMBATLOGDISABLED .. "|r")
			end
		end,
	},

	{ text = "", notClickable = true, notCheckable = true },
}

-- Only add the Skada menu if Skada is loaded
if C_AddOns_IsAddOnLoaded("Skada") then
	table.insert(menuList, {
		text = "Skada",
		hasArrow = true,
		notCheckable = true,
		menuList = {
			{
				text = "Toggle Skada",
				notCheckable = true,
				func = function()
					if InCombatLockdown() then
						UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
						return
					end

					PlaySound(21968)
					_G.Skada:ToggleWindow()
				end,
			},
		},
	})

	table.insert(menuList, { text = "", notClickable = true, notCheckable = true })
end

if C_AddOns_IsAddOnLoaded("Details") then
	table.insert(menuList, {
		text = "Details",
		hasArrow = true,
		notCheckable = true,
		menuList = {
			{
				text = "Reset Details",
				notCheckable = true,
				func = function()
					if InCombatLockdown() then
						UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
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
						UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
						return
					end

					PlaySound(21968)
					_G._detalhes:ToggleWindows()
				end,
			},
		},
	})

	table.insert(menuList, { text = "", notClickable = true, notCheckable = true })
end

-- Adding the close option at the end
table.insert(menuList, { text = "|CFFFF3333" .. CLOSE .. "|r", notCheckable = true, func = function() end })

local function canChangeMessage(arg1, id)
	if id and arg1 == "" then
		return id
	end
end

local function isMessageProtected(msg)
	return msg and (msg ~= string_gsub(msg, "(:?|?)|K(.-)|k", canChangeMessage))
end

local function replaceMessage(msg, r, g, b)
	-- Convert the color values to a hex string
	local hexRGB = K.RGBToHex(r, g, b)
	-- Replace the texture path or id with only the path/id
	msg = string.gsub(msg, "|T(.-):.-|t", "%1")
	-- Replace the atlas path or id with only the path/id
	msg = string.gsub(msg, "|A(.-):.-|a", "%1")
	-- Return the modified message with the hex color code added
	return string.format("%s%s|r", hexRGB, msg)
end

function Module:GetChatLines()
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

function Module:ChatCopy_OnClick(btn)
	if btn == "LeftButton" then
		if not frame:IsShown() then
			local chatframe = SELECTED_DOCK_FRAME
			local _, fontSize = chatframe:GetFont()
			FCF_SetChatWindowFontSize(chatframe, chatframe, 0.01)
			PlaySound(21968)
			frame:Show()

			local lineCt = Module.GetChatLines(chatframe)
			local text = table_concat(lines, "\n", 1, lineCt)
			FCF_SetChatWindowFontSize(chatframe, chatframe, fontSize)
			editBox:SetText(text)
		else
			frame:Hide()
		end
	elseif btn == "RightButton" then
		K.TogglePanel(menu)
		C["Chat"].ChatMenu = menu:IsShown()
	end
end

local function ResetChatAlertJustify(frame)
	frame:SetJustification("LEFT")
end

function Module:ChatCopy_CreateMenu()
	menu = CreateFrame("Frame", "KKUI_ChatMenu", UIParent)
	menu:SetSize(18, C["Chat"].Lock and C["Chat"].Height or _G.ChatFrame1:GetHeight())
	menu:SetPoint("TOPRIGHT", _G.ChatFrame1, 20, -2)
	menu:SetShown(C["Chat"].ChatMenu)

	_G.ChatFrameMenuButton:ClearAllPoints()
	_G.ChatFrameMenuButton:SetPoint("TOP", menu)
	_G.ChatFrameMenuButton:SetParent(menu)

	_G.ChatFrameChannelButton:ClearAllPoints()
	_G.ChatFrameChannelButton:SetPoint("TOP", _G.ChatFrameMenuButton, "BOTTOM", 0, -6)
	_G.ChatFrameChannelButton:SetParent(menu)

	if _G.QuickJoinToastButton then
		_G.QuickJoinToastButton:SetParent(menu)
	end

	_G.ChatAlertFrame:ClearAllPoints()
	_G.ChatAlertFrame:SetPoint("BOTTOMLEFT", _G.ChatFrame1Tab, "TOPLEFT", 5, 25)

	ResetChatAlertJustify(_G.ChatAlertFrame)
	hooksecurefunc(_G.ChatAlertFrame, "SetChatButtonSide", ResetChatAlertJustify)
end

function Module:ChatCopy_Create()
	frame = CreateFrame("Frame", "KKUI_CopyChat", UIParent)
	frame:SetPoint("CENTER")
	frame:SetSize(700, 400)
	frame:Hide()
	frame:SetFrameStrata("DIALOG")
	K.CreateMoverFrame(frame)
	frame:CreateBorder()

	frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame)
	frame.close:SkinCloseButton()

	local scrollArea = CreateFrame("ScrollFrame", "KKUI_CopyChatScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 12, -40)
	scrollArea:SetPoint("BOTTOMRIGHT", -30, 20)
	scrollArea.ScrollBar:SkinScrollBar()

	editBox = CreateFrame("EditBox", nil, frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(K.UIFont)
	editBox:SetWidth(scrollArea:GetWidth())
	editBox:SetHeight(400)
	editBox:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)

	editBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			return
		end

		local _, max = scrollArea.ScrollBar:GetMinMaxValues()
		for _ = 1, max do
			ScrollFrameTemplate_OnMouseWheel(scrollArea, -1)
		end
	end)

	scrollArea:SetScrollChild(editBox)
	scrollArea:HookScript("OnVerticalScroll", function(self, offset)
		editBox:SetHitRectInsets(0, 0, offset, (editBox:GetHeight() - offset - self:GetHeight()))
	end)

	local kkuicopy = CreateFrame("Button", "KKUI_ChatCopyButton", UIParent)
	kkuicopy:SetPoint("BOTTOM", menu)
	kkuicopy:CreateBorder()
	kkuicopy:SetSize(16, 16)
	kkuicopy:SetAlpha(0.25)

	kkuicopy.Texture = kkuicopy:CreateTexture(nil, "ARTWORK")
	kkuicopy.Texture:SetAllPoints()
	kkuicopy.Texture:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
	kkuicopy:RegisterForClicks("AnyUp")
	kkuicopy:SetScript("OnClick", self.ChatCopy_OnClick)

	kkuicopy:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

		local anchor, _, xoff, yoff = "ANCHOR_RIGHT", self:GetParent(), 10, 5
		GameTooltip:SetOwner(self, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(CALENDAR_COPY_EVENT .. " " .. CHAT)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(leftButtonString .. L["Left Click"], "Copy Chat", 1, 1, 1)
		GameTooltip:AddDoubleLine(rightButtonString .. L["Right Click"], "Chat Menu", 1, 1, 1)

		GameTooltip:Show()
	end)

	kkuicopy:SetScript("OnLeave", function(self)
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)

	-- Create Config button
	local kkuiconfig = CreateFrame("Button", "KKUI_ChatConfigButton", UIParent)
	kkuiconfig:SkinButton()
	kkuiconfig:SetSize(16, 16)
	kkuiconfig:SetAlpha(0.25)

	kkuiconfig.Texture = kkuiconfig:CreateTexture(nil, "ARTWORK")
	kkuiconfig.Texture:SetAllPoints()
	kkuiconfig.Texture:SetTexture("Interface\\Buttons\\UI-OptionsButton")
	kkuiconfig:RegisterForClicks("AnyUp")
	kkuiconfig:SetScript("OnClick", function(_, btn)
		if btn == "LeftButton" then
			PlaySound(111)
			K.LibEasyMenu.Create(menuList, K.EasyMenu, kkuiconfig, 24, 290, "MENU", 2)
		elseif btn == "RightButton" then
			K.NewGUI:Toggle()
		end
	end)

	kkuiconfig:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

		local anchor, _, xoff, yoff = "ANCHOR_RIGHT", self:GetParent(), 10, 5
		GameTooltip:SetOwner(self, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(OPTIONS_MENU)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(leftButtonString .. L["Left Click"], L["Toggle Quick Menu"], 1, 1, 1)
		GameTooltip:AddDoubleLine(rightButtonString .. L["Right Click"], L["Toggle KkthnxUI Config"], 1, 1, 1)
		GameTooltip:Show()
	end)

	kkuiconfig:SetScript("OnLeave", function(self)
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)

	-- Create Roll button
	local lastClickTime = 0
	local cooldown = 2 -- Cooldown time in seconds

	local kkuiroll = CreateFrame("Button", "KKUI_ChatRollButton", UIParent)
	kkuiroll:SkinButton()
	kkuiroll:SetSize(16, 16)
	kkuiroll:SetAlpha(0.25)

	kkuiroll.Texture = kkuiroll:CreateTexture(nil, "ARTWORK")
	kkuiroll.Texture:SetAllPoints()
	kkuiroll.Texture:SetAtlas("charactercreate-icon-dice")
	kkuiroll:RegisterForClicks("AnyUp")
	kkuiroll:SetScript("OnClick", function(_, btn)
		local currentTime = GetTime()
		if currentTime - lastClickTime < cooldown then
			K.Print("Please wait before rolling again.")
			return
		end

		lastClickTime = currentTime

		if btn == "LeftButton" then
			RandomRoll(1, 100) -- Simulates the /roll command (default 1-100 range)
		elseif btn == "RightButton" then
			-- Perform an emote for a humorous roll
			local roll = -math.random(1, 100)
			SendChatMessage("rolls " .. roll .. " (1-100)", "EMOTE")
		end
	end)

	kkuiroll:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

		local anchor, _, xoff, yoff = "ANCHOR_RIGHT", self:GetParent(), 10, 5
		GameTooltip:SetOwner(self, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(FAST .. " " .. ROLL)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(leftButtonString .. L["Left Click"], "Roll a random number between 1 and 100", 1, 1, 1)
		GameTooltip:AddDoubleLine(rightButtonString .. L["Right Click"], "Guaranteed to roll a perfect 100!", 1, 1, 1)

		GameTooltip:Show()
	end)

	kkuiroll:SetScript("OnLeave", function(self)
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)

	-- Function to update button positions based on enabled settings
	local function UpdateButtonPositions()
		local buttons = {}

		if C["Chat"].CopyButton then
			table.insert(buttons, kkuicopy)
		else
			kkuicopy:Hide()
		end
		if C["Chat"].ConfigButton then
			table.insert(buttons, kkuiconfig)
		else
			kkuiconfig:Hide()
		end
		if C["Chat"].RollButton then
			table.insert(buttons, kkuiroll)
		else
			kkuiroll:Hide()
		end

		for i, button in ipairs(buttons) do
			if i == 1 then
				button:SetPoint("BOTTOM", menu)
			else
				button:SetPoint("BOTTOM", buttons[i - 1], "TOP", 0, 6)
			end
			button:Show()
		end
	end

	-- Initial update of button positions
	UpdateButtonPositions()

	-- Function to live update button positions
	function Module:UpdateChatButtons()
		UpdateButtonPositions()
	end
end

function Module:CreateCopyChat()
	self:ChatCopy_CreateMenu()
	self:ChatCopy_Create()
end
