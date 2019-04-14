local K, C, L = unpack(select(2, ...))
local CopyChat = K:NewModule("CopyChat", "AceHook-3.0")

-- Sourced: ElvUI (Elvz)

local _G = _G
local string_format = string.format
local string_gsub = string.gsub
local string_lower = string.lower
local table_concat = table.concat
local table_insert = table.insert

local CreateFrame, UIParent = _G.CreateFrame, _G.UIParent
local FCF_GetChatWindowInfo = _G.FCF_GetChatWindowInfo
local FCF_SetChatWindowFontSize = _G.FCF_SetChatWindowFontSize
local GameTooltip = _G.GameTooltip
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local RandomRoll = _G.RandomRoll
local ReloadUI = _G.ReloadUI
local RELOADUI = _G.RELOADUI
local ScrollFrameTemplate_OnMouseWheel = _G.ScrollFrameTemplate_OnMouseWheel
local STATUS = _G.STATUS
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
			K.ShowStatusReport()
	end},

	{text = L["ConfigButton"].Install, notCheckable = true, func = function()
			K.Install:Launch()
	end},

	{text = L["ConfigButton"].MoveUI, notCheckable = true, func = function()
			K.MoveUI()
	end},

	{text = L["ConfigButton"].ActionbarLock, notCheckable = true, func = function()
			if InCombatLockdown() then
				return
			end

			if KkthnxUIData[K.Realm][K.Name].BarsLocked == true then
				KkthnxUIData[K.Realm][K.Name].BarsLocked = false
				K.Print(L["Actionbars"].Unlocked)
			elseif KkthnxUIData[K.Realm][K.Name].BarsLocked == false then
				KkthnxUIData[K.Realm][K.Name].BarsLocked = true
				K.Print(L["Actionbars"].Locked)
			end
	end},

	{text = L["ConfigButton"].ToggleConfig, notCheckable = true, func = function()
			K.ConfigUI()
	end},

	{text = L["ConfigButton"].ProfileList, notCheckable = true, func = function()
			K.UIProfiles("list")
	end},

	{text = L["ConfigButton"].UIHelp, notCheckable = true, func = function()
			K.UICommandsHelp()
	end},

	{text = L["ConfigButton"].Changelog, notCheckable = true, func = function()
			K:GetModule("Changelog"):ToggleChangeLog()
	end},

	{text = KEY_BINDINGS, notCheckable = true, func = function()
			K.BindingUI()
	end},

	{text = RELOADUI, notCheckable = true, func = function()
			ReloadUI()
	end},

	{text = "|cff7289daDiscord|r", notCheckable = true, func = function()
			K.StaticPopup_Show("DISCORD_EDITBOX", nil, nil, "https://discord.gg/YUmxqQm")
	end},

	{text = "Damage Meters", hasArrow = true, notCheckable = true,
		menuList = {
			{text = "Skada", notCheckable = true, func = function()
					if IsAddOnLoaded("Skada") then
						Skada:ToggleWindow()
					end
			end},

			{text = "Details", notCheckable = true, func = function()
					if IsAddOnLoaded("Details") then
						_detalhes:ToggleWindows()
					end
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
	if not CopyChatFrame:IsShown() then
		local _, fontSize = FCF_GetChatWindowInfo(frame:GetID());
		if fontSize < 12 then
			fontSize = 12
		end

		FCF_SetChatWindowFontSize(frame, frame, 0.01)
		CopyChatFrame:Show()

		local lineCt = self:GetLines(frame)
		local text = table_concat(copyLines, " \n", 1, lineCt)
		FCF_SetChatWindowFontSize(frame, frame, fontSize)
		CopyChatFrameEditBox:SetText(text)
	else
		CopyChatFrame:Hide()
	end
end

function CopyChat:OnEnable()
	CopyFrame = CreateFrame("Frame", "CopyChatFrame", UIParent)
	table_insert(UISpecialFrames, "CopyChatFrame")

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
	CopyChatScrollFrameScrollBar:SetAlpha(0) -- We dont skin these nor do we show their ugly asses either.

	ScrollArea:SetScript("OnSizeChanged", function(self)
		CopyChatFrameEditBox:SetWidth(self:GetWidth())
		CopyChatFrameEditBox:SetHeight(self:GetHeight())
	end)

	ScrollArea:HookScript("OnVerticalScroll", function(self, offset)
		CopyChatFrameEditBox:SetHitRectInsets(0, 0, offset, (CopyChatFrameEditBox:GetHeight() - offset - self:GetHeight()))
	end)

	local EditBox = CreateFrame("EditBox", "CopyChatFrameEditBox", CopyFrame)
	EditBox:SetMultiLine(true)
	EditBox:SetMaxLetters(99999)
	EditBox:EnableMouse(true)
	EditBox:SetAutoFocus(false)
	EditBox:SetFontObject(ChatFontNormal)
	EditBox:SetWidth(ScrollArea:GetWidth())
	EditBox:SetHeight(200)
	EditBox:SetScript("OnEscapePressed", function()
		CopyFrame:Hide()
	end)
	ScrollArea:SetScrollChild(EditBox)
	CopyChatFrameEditBox:SetScript("OnTextChanged", function(_, userInput)
		if userInput then
			return
		end

		local _, max = CopyChatScrollFrameScrollBar:GetMinMaxValues()
		for i = 1, max do
			ScrollFrameTemplate_OnMouseWheel(CopyChatScrollFrame, -1)
		end
	end)

	local Close = CreateFrame("Button", "CopyChatFrameCloseButton", CopyFrame, "UIPanelCloseButton")
	Close:SetPoint("TOPRIGHT")
	Close:SetFrameLevel(Close:GetFrameLevel() + 1)
	Close:SkinCloseButton()
	Close:SetScript("OnClick", function()
		CopyFrame:Hide()
	end)

	-- Create copy/config button
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		local id = frame:GetID()

		local CopyButton = CreateFrame("Button", string_format("CopyChatButton%d", id), frame)
		CopyButton:EnableMouse(true)
		CopyButton:SetSize(22, 24)
		CopyButton:SetHitRectInsets(5, 5, 4, 4)
		CopyButton:SetPoint("TOPRIGHT", 23, 0)
		CopyButton:SetNormalTexture(C["Media"].Copy)
		CopyButton:SetAlpha(0.25)
		CopyButton:SetFrameLevel(frame:GetFrameLevel() + 5)

		CopyButton:SetScript("OnMouseUp", function(self, button)
			if button == "RightButton" and id == 1 and not InCombatLockdown() then
				ToggleFrame(ChatMenu)
			elseif button == "MiddleButton" then
				RandomRoll(1, 100)
			else
				CopyChat:CopyText(self.ChatFrame)
			end
		end)

		CopyButton:SetScript("OnEnter", function(self)
			K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
			local anchor, _, xoff, yoff = "ANCHOR_TOPLEFT", self:GetParent(), 10, 5
			GameTooltip:SetOwner(self, anchor, xoff, yoff)
			GameTooltip:ClearLines()
			GameTooltip:AddLine(L["ConfigButton"].Functions)
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(leftButtonString..L["ConfigButton"].LeftClick, L["ConfigButton"].CopyChat, 1, 1, 1)
			GameTooltip:AddDoubleLine(rightButtonString..L["ConfigButton"].Right_Click, L["ConfigButton"].Emotions, 1, 1, 1)
			GameTooltip:AddDoubleLine(middleButtonString..L["ConfigButton"].MiddleClick, L["ConfigButton"].Roll, 1, 1, 1)
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
		ConfigButton:EnableMouse(true)
		ConfigButton:SetSize(26, 26)
		ConfigButton:SetHitRectInsets(6, 6, 7, 7)
		ConfigButton:SetPoint("TOP", CopyButton, "BOTTOM", 0, 6)
		ConfigButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Chat\\Config")
		ConfigButton:SetAlpha(0.25)
		ConfigButton:SetFrameLevel(frame:GetFrameLevel() + 5)

		ConfigButton:SetScript("OnMouseUp", function(_, btn)
			if btn == "LeftButton" or btn == "RightButton" then
				EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
			end
		end)

		ConfigButton:SetScript("OnEnter", function(self)
			K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
		end)

		ConfigButton:SetScript("OnLeave", function(self)
			K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
		end)

		ConfigButton.ChatFrame = frame
		CopyButton.ChatFrame = frame
	end
end