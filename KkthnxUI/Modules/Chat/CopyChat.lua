local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Chat")

-- Sourced: NDui (siweia)

local _G = _G
local sring_format = _G.string.format
local string_gsub = _G.string.gsub
local table_concat = _G.table.concat
local tostring = _G.tostring

local CreateFrame = _G.CreateFrame
local FCF_SetChatWindowFontSize = _G.FCF_SetChatWindowFontSize
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local PlaySound = _G.PlaySound
local STATUS = _G.STATUS
local ScrollFrameTemplate_OnMouseWheel = _G.ScrollFrameTemplate_OnMouseWheel
local SlashCmdList = _G.SlashCmdList
local UIParent = _G.UIParent

local lines, menu, frame, editBox = {}
local CopyChatFont = K.GetFont(C["UIFonts"].ChatFonts)
local menuFrame = CreateFrame("Frame", "KKUI_QuickMenu", UIParent, "UIDropDownMenuTemplate")
local leftButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t "
local rightButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t "

local menuList = {
	{text = _G.OPTIONS_MENU, isTitle = true, notCheckable = true},
	{text = "", notClickable = true, notCheckable = true},
	{text = STATUS, notCheckable = true, func = function()
			SlashCmdList["KKUI_STATUSREPORT"]()
	end},

	--{text = L["Install"], notCheckable = true, func = function()
	--		K.Install:Launch()
	--end},

	{text = L["MoveUI"], notCheckable = true, func = function()
			SlashCmdList["KKUI_MOVEUI"]()
	end},

	{text = L["Profiles"], notCheckable = true, func = function()
			SlashCmdList["KKUI_UIPROFILES"]("list")
	end},

	--{text = L["KkthnxUI Help"], notCheckable = true, func = function()
	--		K.Print("Command Not Implemented")
	--end},

	--{text = L["Changelog"], notCheckable = true, func = function()
	--		K:GetModule("Changelog"):ToggleChangeLog()
	--end},

	{text = RELOADUI, notCheckable = true, func = function()
			if InCombatLockdown() then
				_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
				return
			end
			ReloadUI()
	end},

	{text = BINDING_NAME_TOGGLECOMBATLOG, notCheckable = true, func = function()
		if not LoggingCombat() then
			LoggingCombat(true)
			K.Print("|cffffff00"..COMBATLOGENABLED.."|r")
		elseif LoggingCombat() then
			LoggingCombat(false)
			K.Print("|cffffff00"..COMBATLOGDISABLED.."|r")
		end
	end},

	{text = L["Discord"], notCheckable = true, func = function()
			K.StaticPopup_Show("DISCORD_EDITBOX", nil, nil, L["Discord URL"])
	end},
	{text = "", notClickable = true, notCheckable = true},

	{text = TASKS_COLON, hasArrow = true, notCheckable = true,
		menuList = {
			{text = "Delete "..QUESTS_LABEL.." From Tracker", notCheckable = true, func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
						return
					end
					SlashCmdList["KKUI_ABANDONQUESTS"]()
			end},

			{text = "Delete |ccf00ccff"..HEIRLOOMS.."|r From Bags", notCheckable = true, func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
						return
					end
					SlashCmdList["KKUI_DELETEHEIRLOOMS"]()
			end},

			{text = "Delete |cffffd200"..AUCTION_CATEGORY_QUEST_ITEMS.."|r From Bags", notCheckable = true, func = function()
					if InCombatLockdown() then
						_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
						return
					end
					SlashCmdList["KKUI_DELETEQUESTITEMS"]()
			end},
		},
	},

	{text = "", notClickable = true, notCheckable = true},
	{text = CLOSE, notCheckable = true, func = function() end},
}

local function canChangeMessage(arg1, id)
	if id and arg1 == "" then
		return id
	end
end

local function isMessageProtected(msg)
	return msg and (msg ~= string_gsub(msg, "(:?|?)|K(.-)|k", canChangeMessage))
end

local function colorReplace(msg, r, g, b)
	local hexRGB = K.RGBToHex(r, g, b)
	local hexReplace = sring_format("|r%s", hexRGB)
	msg = string_gsub(msg, "|r", hexReplace)
	msg = sring_format("%s%s|r", hexRGB, msg)

	return msg
end

function Module:GetChatLines()
	local index = 1
	for i = 1, self:GetNumMessages() do
		local msg, r, g, b = self:GetMessageInfo(i)
		if msg and not isMessageProtected(msg) then
			r, g, b = r or 1, g or 1, b or 1
			msg = colorReplace(msg, r, g, b)

			lines[index] = tostring(msg)
			index = index + 1
		end
	end

	return index - 1
end

function Module:ChatCopy_OnClick(btn)
	if btn == "LeftButton" then
		if not frame:IsShown() then
			local chatframe = _G.SELECTED_DOCK_FRAME
			local _, fontSize = chatframe:GetFont()
			FCF_SetChatWindowFontSize(chatframe, chatframe, .01)
			PlaySound(21968)
			frame:Show()

			local lineCt = Module.GetChatLines(chatframe)
			local text = table_concat(lines, " \n", 1, lineCt)
			FCF_SetChatWindowFontSize(chatframe, chatframe, fontSize)
			editBox:SetText(text)
		else
			frame:Hide()
		end
	elseif btn == "RightButton" then
		if not ChatMenu:IsShown() then
			if InCombatLockdown() then
				UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
				return
			end

			PlaySound(111)
			K.TogglePanel(_G.ChatMenu)
		else
			ChatMenu:Hide()
		end
	end
end

function Module:ChatCopy_CreateMenu()
	menu = CreateFrame("Frame", "KKUI_ChatMenu", UIParent)
	menu:SetSize(22, 100)
	menu:SetPoint("TOPRIGHT", _G.ChatFrame1, 22, 0)

	-- Create Configbutton
	local kkuiconfig = CreateFrame("Button", nil, UIParent)
	kkuiconfig:SetPoint("TOP", menu)
	kkuiconfig:SetSize(16, 16)
	kkuiconfig:SetAlpha(0.25)
	kkuiconfig.Texture = kkuiconfig:CreateTexture(nil, "ARTWORK")
	kkuiconfig.Texture:SetAllPoints()
	kkuiconfig.Texture:SetTexture("Interface\\Buttons\\UI-OptionsButton")
	kkuiconfig:RegisterForClicks("AnyUp")
	kkuiconfig:SetScript("OnClick", function(_, btn)
		if btn == "LeftButton" then
			PlaySound(111)
			_G.EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
		elseif btn == "RightButton" then
			_G.SlashCmdList["KKUI_CONFIGUI"]()
		end
	end)

	kkuiconfig:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

		local anchor, _, xoff, yoff = "ANCHOR_RIGHT", self:GetParent(), 10, 5
		GameTooltip:SetOwner(self, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(leftButtonString..L["Left Click"], L["Toggle Quick Menu"], 1, 1, 1)
		GameTooltip:AddDoubleLine(rightButtonString..L["Right Click"], L["Toggle KkthnxUI Config"], 1, 1, 1)
		GameTooltip:Show()
	end)

	kkuiconfig:SetScript("OnLeave", function(self)
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)

	-- Create Damagemeter Toggle
	if K.CheckAddOnState("Details") or K.CheckAddOnState("Skada") then
		local damagemeter = CreateFrame("Button", nil, UIParent)
		damagemeter:SetPoint("TOP", kkuiconfig, "BOTTOM", 0, -2)
		damagemeter:SetSize(16, 16)
		damagemeter:SetAlpha(0.25)
		damagemeter.Texture = damagemeter:CreateTexture(nil, "ARTWORK")
		damagemeter.Texture:SetAllPoints()
		damagemeter.Texture:SetTexture("Interface\\Buttons\\UI-GuildButton-MOTD-Up")
		damagemeter:RegisterForClicks("AnyUp")
		damagemeter:SetScript("OnClick", function(_, btn)
			if btn == "LeftButton" then
				if IsAddOnLoaded("Details") then
					PlaySound(21968)
					_G._detalhes:ToggleWindows()
				end

				if IsAddOnLoaded("Skada") then
					PlaySound(21968)
					_G.Skada:ToggleWindow()
				end
			elseif btn == "RightButton" then
				if IsAddOnLoaded("Details") then
					_G.KkthnxUIData["ResetDetails"] = true
					K.StaticPopup_Show("CHANGES_RL")
				end
			end
		end)

		damagemeter:SetScript("OnEnter", function(self)
			K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

			local anchor, _, xoff, yoff = "ANCHOR_RIGHT", self:GetParent(), 10, 5
			GameTooltip:SetOwner(self, anchor, xoff, yoff)
			GameTooltip:ClearLines()
			if IsAddOnLoaded("Details") then
				GameTooltip:AddDoubleLine(leftButtonString..L["Left Click"], L["Show Hide Details"], 1, 1, 1)
				GameTooltip:AddDoubleLine(rightButtonString..L["Right Click"], L["Reset Details"], 1, 1, 1)
			end

			if IsAddOnLoaded("Skada") then
				GameTooltip:AddDoubleLine(leftButtonString..L["Left Click"], L["Show Hide Skada"], 1, 1, 1)
			end

			GameTooltip:Show()
		end)

		damagemeter:SetScript("OnLeave", function(self)
			K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

			if not GameTooltip:IsForbidden() then
				GameTooltip:Hide()
			end
		end)
	end
end

function Module:ChatCopy_Create()
	frame = CreateFrame("Frame", "KKUIChatCopy", UIParent)
	frame:SetPoint("CENTER")
	frame:SetSize(700, 400)
	frame:Hide()
	frame:SetFrameStrata("DIALOG")
	K.CreateMoverFrame(frame)
	frame:CreateBorder()
	frame.close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	frame.close:SetPoint("TOPRIGHT", frame)
	frame.close:SkinCloseButton()

	local scrollArea = CreateFrame("ScrollFrame", "ChatCopyScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", 10, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", -28, 10)
	ChatCopyScrollFrameScrollBar:SkinScrollBar()

	editBox = CreateFrame("EditBox", nil, frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(CopyChatFont)
	editBox:SetFont(select(1, editBox:GetFont()), 12, select(3, editBox:GetFont()))
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

	local copy = CreateFrame("Button", nil, UIParent)
	copy:SetPoint("BOTTOMRIGHT", _G.ChatFrame1, 22, 0)
	copy:SetSize(16, 16)
	copy:SetAlpha(0.25)
	copy.Texture = copy:CreateTexture(nil, "ARTWORK")
	copy.Texture:SetAllPoints()
	copy.Texture:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
	copy:RegisterForClicks("AnyUp")
	copy:SetScript("OnClick", self.ChatCopy_OnClick)

	copy:SetScript("OnEnter", function(self)
		K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

		local anchor, _, xoff, yoff = "ANCHOR_RIGHT", self:GetParent(), 10, 5
		GameTooltip:SetOwner(self, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(leftButtonString..L["Left Click"], "Copy Chat", 1, 1, 1)
		GameTooltip:AddDoubleLine(rightButtonString..L["Right Click"], "Chat Menu", 1, 1, 1)

		GameTooltip:Show()
	end)

	copy:SetScript("OnLeave", function(self)
		K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

		if not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end)
end

function Module:CreateCopyChat()
	self:ChatCopy_CreateMenu()
	self:ChatCopy_Create()
end