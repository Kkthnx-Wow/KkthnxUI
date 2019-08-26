local K, _, L = unpack(select(2, ...))
local CopyChat = K:GetModule("Chat")

-- Sourced: ElvUI (Elvz)

local _G = _G
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_lower = _G.string.lower
local table_concat = _G.table.concat
local table_insert = _G.table.insert

local AUCTION_CATEGORY_QUEST_ITEMS = _G.AUCTION_CATEGORY_QUEST_ITEMS
local CLOSE = _G.CLOSE
local CreateFrame, UIParent = _G.CreateFrame, _G.UIParent
local FCF_GetChatWindowInfo = _G.FCF_GetChatWindowInfo
local FCF_SetChatWindowFontSize = _G.FCF_SetChatWindowFontSize
local GameTooltip = _G.GameTooltip
local HEIRLOOMS = _G.HEIRLOOMS
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsShiftKeyDown = _G.IsShiftKeyDown
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local PlaySound = _G.PlaySound
local QUESTS_LABEL = _G.QUESTS_LABEL
local RELOADUI = _G.RELOADUI
local RandomRoll = _G.RandomRoll
local ReloadUI = _G.ReloadUI
local STATUS = _G.STATUS
local ScrollFrameTemplate_OnMouseWheel = _G.ScrollFrameTemplate_OnMouseWheel
local TASKS_COLON = _G.TASKS_COLON
local ToggleFrame = _G.ToggleFrame

local removeIconFromLine
local copyLines = {}
local CopyFrame

local menuFrame = CreateFrame("Frame", "QuickClickMenu", UIParent, "UIDropDownMenuTemplate")
local middleButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:118:218|t "
local leftButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t "
local rightButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t "

local canChangeMessage = function(arg1, id)
	if id and arg1 == "" then
		return id
	end
end

function CopyChat:MessageIsProtected(message)
	return message and (message ~= string_gsub(message, "(:?|?)|K(.-)|k", canChangeMessage))
end

local menuList = {
	{text = _G.OPTIONS_MENU, isTitle = true, notCheckable = true},
	{text = "", notClickable = true, notCheckable = true},
	{text = STATUS, notCheckable = true, func = function()
			SlashCmdList["KKUI_STATUSREPORT"]()
	end},

	{text = L["Install"], notCheckable = true, func = function()
			K.Install:Launch()
	end},

	{text = L["MoveUI"], notCheckable = true, func = function()
			SlashCmdList["KKUI_MOVEUI"]()
	end},

	{text = L["Profiles"], notCheckable = true, func = function()
			SlashCmdList["KKUI_UIPROFILES"]("list")
	end},

	{text = L["KkthnxUI Help"], notCheckable = true, func = function()
			K.Print("This is not implemented yet!!!")
	end},

	{text = L["Changelog"], notCheckable = true, func = function()
			K:GetModule("Changelog"):ToggleChangeLog()
	end},

	{text = RELOADUI, notCheckable = true, func = function()
			if InCombatLockdown() then
				_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
				return
			end
			ReloadUI()
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

do
	local raidIconFunc = function(x)
		x = x ~= "" and _G["RAID_TARGET_"..x]
		return x and ("{"..string_lower(x).."}") or ""
	end

	local stripTextureFunc = function(w, x, y)
		if x == "" then
			return (w ~= "" and w) or (y ~= "" and y) or ""
		end
	end

	local hyperLinkFunc = function(w, _, y)
		if w ~= "" then
			return
		end
	end

	removeIconFromLine = function(text)
		text = string_gsub(text, "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_(%d+):0|t", raidIconFunc) -- converts raid icons into {star} etc, if possible.
		text = string_gsub(text, "(%s?)(|?)|T.-|t(%s?)", stripTextureFunc) -- strip any other texture out but keep a single space from the side(s).
		text = string_gsub(text, "(|?)|H(.-)|h(.-)|h", hyperLinkFunc) -- strip hyperlink data only keeping the actual text.
		return text
	end
end

local function colorizeLine(text, r, g, b)
	local hexCode = K.RGBToHex(r, g, b)
	local hexReplacement = string_format("|r%s", hexCode)

	text = string_gsub(text, "|r", hexReplacement) -- If the message contains color strings then we need to add message color hex code after every "|r"
	text = string_format("%s%s|r", hexCode, text) -- Add message color

	return text
end

function CopyChat:GetLines(frame)
	local index = 1
	for i = 1, frame:GetNumMessages() do
		local message, r, g, b = frame:GetMessageInfo(i)
		if message and not CopyChat:MessageIsProtected(message) then
			-- Set fallback color values
			r, g, b = r or 1, g or 1, b or 1

			-- Remove icons
			message = removeIconFromLine(message)

			-- Add text color
			message = colorizeLine(message, r, g, b)

			copyLines[index] = message
			index = index + 1
		end
	end

	return index - 1
end

function CopyChat:CopyText(frame)
	if not _G.CopyChatFrame:IsShown() then
		local _, fontSize = FCF_GetChatWindowInfo(frame:GetID());
		if fontSize < 12 then
			fontSize = 12
		end

		FCF_SetChatWindowFontSize(frame, frame, 0.01)
		_G.CopyChatFrame:Show()

		local lineCt = self:GetLines(frame)
		local text = table_concat(copyLines, " \n", 1, lineCt)
		FCF_SetChatWindowFontSize(frame, frame, fontSize)
		_G.CopyChatFrameEditBox:SetText(text)
	else
		_G.CopyChatFrame:Hide()
	end
end

function CopyChat:CreateCopyChat()
	CopyFrame = CreateFrame("Frame", "CopyChatFrame", UIParent)
	table_insert(_G.UISpecialFrames, "CopyChatFrame")

	CopyFrame:CreateBorder()
	CopyFrame:SetSize(700, 200)
	CopyFrame:SetPoint("BOTTOM", UIParent, 0, 4)
	CopyFrame:Hide()
	CopyFrame:SetMovable(true)
	CopyFrame:EnableMouse(true)
	CopyFrame:SetResizable(true)
	CopyFrame:SetMinResize(350, 100)
	CopyFrame:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" and not self.isMoving then
			self:StartMoving()
			self.isMoving = true
		elseif button == "RightButton" and not self.isSizing then
			self:StartSizing()
			self.isSizing = true
		end
	end)

	CopyFrame:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" and self.isMoving then
			self:StopMovingOrSizing()
			self.isMoving = false
		elseif button == "RightButton" and self.isSizing then
			self:StopMovingOrSizing()
			self.isSizing = false
		end
	end)

	CopyFrame:SetScript("OnHide", function(self)
		if (self.isMoving or self.isSizing) then
			self:StopMovingOrSizing()
			self.isMoving = false
			self.isSizing = false
		end
	end)

	CopyFrame:SetFrameStrata("DIALOG")
	CopyFrame.Minimized = true

	local ScrollArea = CreateFrame("ScrollFrame", "CopyChatScrollFrame", CopyFrame, "UIPanelScrollFrameTemplate")
	ScrollArea:SetPoint("TOPLEFT", CopyFrame, "TOPLEFT", 8, -30)
	ScrollArea:SetPoint("BOTTOMRIGHT", CopyFrame, "BOTTOMRIGHT", -30, 8)
	_G.CopyChatScrollFrameScrollBar:SetAlpha(0) -- We dont skin these nor do we show their ugly asses either.

	ScrollArea:SetScript("OnSizeChanged", function(self)
		_G.CopyChatFrameEditBox:SetWidth(self:GetWidth())
		_G.CopyChatFrameEditBox:SetHeight(self:GetHeight())
	end)

	ScrollArea:HookScript("OnVerticalScroll", function(self, offset)
		_G.CopyChatFrameEditBox:SetHitRectInsets(0, 0, offset, (_G.CopyChatFrameEditBox:GetHeight() - offset - self:GetHeight()))
	end)

	local EditBox = CreateFrame("EditBox", "CopyChatFrameEditBox", CopyFrame)
	EditBox:SetMultiLine(true)
	EditBox:SetMaxLetters(99999)
	EditBox:EnableMouse(true)
	EditBox:SetAutoFocus(false)
	EditBox:SetFontObject(_G.ChatFontNormal)
	EditBox:SetWidth(ScrollArea:GetWidth())
	EditBox:SetHeight(200)
	EditBox:SetScript("OnEscapePressed", function()
		CopyFrame:Hide()
	end)
	ScrollArea:SetScrollChild(EditBox)
	_G.CopyChatFrameEditBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			return
		end

		local _, max = _G.CopyChatScrollFrameScrollBar:GetMinMaxValues()
		for _ = 1, max do
			ScrollFrameTemplate_OnMouseWheel(_G.CopyChatScrollFrame, -1)
		end
	end)

	local Close = CreateFrame("Button", "CopyChatFrameCloseButton", CopyFrame, "UIPanelCloseButton")
	Close:SetPoint("TOPRIGHT")
	Close:SetFrameLevel(Close:GetFrameLevel() + 1)
	Close:SkinCloseButton()
	Close:SetScript("OnClick", function()
		CopyFrame:Hide()
	end)

	-- Create copy button
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		local id = frame:GetID()

		local menu = CreateFrame("Frame", nil, frame)
		menu:SetSize(25, 100)
		menu:SetPoint("TOPRIGHT", _G.ChatFrame1, 22, 0)

		local CopyButton = CreateFrame("Button", string_format("CopyChatButton%d", id), menu)
		CopyButton:SetSize(16, 16)
		CopyButton:SetPoint("TOP", 4, 0)
		CopyButton.Texture = CopyButton:CreateTexture(nil, "BACKGROUND")
		CopyButton.Texture:SetTexture("Interface\\ICONS\\INV_Misc_Note_04")
		CopyButton.Texture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		CopyButton.Texture:SetAllPoints()
		CopyButton:StyleButton(nil, true)
		CopyButton:SetAlpha(0.25)

		CopyButton:SetScript("OnMouseUp", function(self, button)
			if button == "RightButton" and id == 1 and not InCombatLockdown() then
				PlaySound(111)
				ToggleFrame(_G.ChatMenu)
			elseif button == "MiddleButton" then
				PlaySound(36626)
				RandomRoll(1, 100)
			elseif IsShiftKeyDown() and button == "LeftButton" then
				PlaySound(111)
				_G.ToggleChannelFrame()
			else
				PlaySound(21968)
				CopyChat:CopyText(self.ChatFrame)
			end
		end)

		CopyButton:SetScript("OnEnter", function(self)
			K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

			local anchor, _, xoff, yoff = "ANCHOR_TOPLEFT", self:GetParent(), 10, 5
			GameTooltip:SetOwner(self, anchor, xoff, yoff)
			GameTooltip:ClearLines()
			GameTooltip:AddLine(L["Functions"])
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(leftButtonString..L["Left Click"], L["Copy Chat"], 1, 1, 1)
			GameTooltip:AddDoubleLine(rightButtonString..L["Right Click"], L["Emotes"], 1, 1, 1)
			GameTooltip:AddDoubleLine(middleButtonString..L["Middle Click"], L["Roll"], 1, 1, 1)
			GameTooltip:AddDoubleLine(leftButtonString.. L["Shift Left Click"], L["Open Chat Channels"], 1, 1, 1)
			GameTooltip:Show()
		end)

		CopyButton:SetScript("OnLeave", function(self)
			K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
			if not GameTooltip:IsForbidden() then
				GameTooltip:Hide()
			end
		end)

		-- Create Configbutton
		local ConfigButton = CreateFrame("Button", string_format("ConfigChatButton%d", id), frame)
		ConfigButton:SetSize(16, 16)
		ConfigButton:SetPoint("TOP", CopyButton, "BOTTOM", 0, -5)
		ConfigButton.Texture = ConfigButton:CreateTexture(nil, "BACKGROUND")
		ConfigButton.Texture:SetTexture("Interface\\ICONS\\INV_Eng_GearspringParts")
		ConfigButton.Texture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		ConfigButton.Texture:SetAllPoints()
		ConfigButton:StyleButton(nil, true)
		ConfigButton:SetAlpha(0.25)
		ConfigButton:SetFrameLevel(frame:GetFrameLevel() + 5)

		ConfigButton:SetScript("OnMouseUp", function(_, btn)
			if btn == "LeftButton" then
				PlaySound(111)
				_G.EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
			elseif btn == "RightButton" then
				_G.SlashCmdList["KKUI_CONFIGUI"]()
			end
		end)

		ConfigButton:SetScript("OnEnter", function(self)
			K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

			local anchor, _, xoff, yoff = "ANCHOR_TOPLEFT", self:GetParent(), 10, 5
			GameTooltip:SetOwner(self, anchor, xoff, yoff)
			GameTooltip:ClearLines()
			GameTooltip:AddDoubleLine(leftButtonString..L["Left Click"], L["Toggle Quick Menu"], 1, 1, 1)
			GameTooltip:AddDoubleLine(rightButtonString..L["Right Click"], L["Toggle KkthnxUI Config"], 1, 1, 1)
			GameTooltip:Show()
		end)

		ConfigButton:SetScript("OnLeave", function(self)
			K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

			if not GameTooltip:IsForbidden() then
				GameTooltip:Hide()
			end
		end)

		-- Create Damagemeter Toggle
		if K.CheckAddOnState("Details") or K.CheckAddOnState("Skada") then
			local DamageMeterButton = CreateFrame("Button", string_format("DamageMeterChatButton%d", id), frame)
			DamageMeterButton:EnableMouse(true)
			DamageMeterButton:SetSize(16, 16)
			DamageMeterButton:SetPoint("TOP", ConfigButton, "BOTTOM", 0, -5)
			DamageMeterButton.Texture = DamageMeterButton:CreateTexture(nil, "BACKGROUND")
			DamageMeterButton.Texture:SetTexture("Interface\\Icons\\Spell_Lightning_LightningBolt01")
			DamageMeterButton.Texture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			DamageMeterButton.Texture:SetAllPoints()
			DamageMeterButton:StyleButton(nil, true)
			DamageMeterButton:SetAlpha(0.25)
			DamageMeterButton:SetFrameLevel(frame:GetFrameLevel() + 5)

			DamageMeterButton:SetScript("OnMouseUp", function(_, btn)
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

			DamageMeterButton:SetScript("OnEnter", function(self)
				K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)

				local anchor, _, xoff, yoff = "ANCHOR_TOPLEFT", self:GetParent(), 10, 5
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

			DamageMeterButton:SetScript("OnLeave", function(self)
				K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)

				if not GameTooltip:IsForbidden() then
					GameTooltip:Hide()
				end
			end)

			DamageMeterButton.ChatFrame = frame
		end

		ConfigButton.ChatFrame = frame
		CopyButton.ChatFrame = frame
	end
end