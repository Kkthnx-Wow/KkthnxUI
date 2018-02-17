local K, C, L = unpack(select(2, ...))
local CopyChat = K:NewModule("CopyChat", "AceHook-3.0")

-- Sourced: ElvUI (Elvz)

-- Lua API
local _G = _G
local string_format = string.format
local string_gsub = string.gsub
local string_lower = string.lower
local table_concat = table.concat
local table_insert = table.insert

-- Wow API
local CreateFrame, UIParent = _G.CreateFrame, _G.UIParent
local FCF_GetChatWindowInfo = _G.FCF_GetChatWindowInfo
local FCF_SetChatWindowFontSize = _G.FCF_SetChatWindowFontSize
local InCombatLockdown = _G.InCombatLockdown
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS
local ScrollFrameTemplate_OnMouseWheel = _G.ScrollFrameTemplate_OnMouseWheel
local ToggleFrame = _G.ToggleFrame

local middleButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:118:218|t "
local leftButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t "
local rightButtonString = "|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t "

local Lines = {}
local CopyFrame

local menuFrame = CreateFrame("Frame", "ConfigRightClickMenu", UIParent, "L_UIDropDownMenuTemplate")
local menuList = {
	{text = OPTIONS_MENU, isTitle = true, notCheckable = true},
	{text = "", notClickable = true, notCheckable = true},
	{text = STATUS, notCheckable = true, func = function()
			K.ShowStatusReport()
	end},
	{text = "Toggle".." "..PVP, notCheckable = true, func = function()
			TogglePVP()
	end},
	{text = "Install", notCheckable = true, func = function()
			K.Install:Launch()
	end},
	{text = "Move UI", notCheckable = true, func = function()
			K.MoveUI()
	end},
	{text = "Toggle Config", notCheckable = true, func = function()
			K.ConfigUI()
	end},
	{text = "Profiles", notCheckable = true, func = function()
			K.UIProfiles("list")
	end},
	{text = "UI Help", notCheckable = true, func = function()
			K.UICommandsHelp()
	end},
	{text = RELOADUI, notCheckable = true, func = function()
			ReloadUI()
	end},
	{text = "Toggle Bags", notCheckable = true, func = function()
			if BankFrame:IsShown() then
				CloseBankBagFrames()
				CloseBankFrame()
				CloseAllBags()
			else
				if ContainerFrame1:IsShown() then
					CloseAllBags()
				else
					ToggleAllBags()
				end
			end
	end},
	{text = "Click Me", notCheckable = true, func = function()
			SendChatMessage("I love KkthnxUI! KkhnxUI is life!", "YELL", nil, nil)
	end},
	{text = "No Life", notCheckable = true, func = function()
			RequestTimePlayed()
			print("|cfff0f8ffI just wanted you to see how you are spending your life! |cfffa8072<3|r |cfff0f8ffKkthnx|r")
	end},
	{text = "Damage Meters", hasArrow = true, notCheckable=true,
		menuList = {
			{text = "Skada", notCheckable = true, func = function() if IsAddOnLoaded("Skada") then Skada:ToggleWindow() end end},
			{text = "Recount", notCheckable = true, func = function() if IsAddOnLoaded("Recount") then if Recount_MainWindow:IsShown() then Recount_MainWindow:Hide() else Recount_MainWindow:Show() end end end},
			{text = "Details", notCheckable = true, func = function() if IsAddOnLoaded("Details") then _detalhes:ToggleWindows() end end},
		},
	},
}

local function RemoveIconFromLine(text)
	for i= 1, 8 do
		text = string_gsub(text, "|TInterface\\TargetingFrame\\UI%-RaidTargetingIcon_"..i..":0|t", "{"..string_lower(_G["RAID_TARGET_"..i]).."}")
	end
	text = string_gsub(text, "|TInterface(.-)|t", "")
	return text
end

local function ColorizeLine(text, r, g, b)
	local HexCode = K.RGBToHex(r, g, b)
	local HexReplacement = string_format("|r%s", HexCode)

	text = string_gsub(text, "|r", HexReplacement) -- If the message contains color strings then we need to add message color hex code after every "|r"
	text = string_format("%s%s|r", HexCode, text) -- Add message color

	return text
end

function CopyChat:GetLines(frame)
	local Index = 1

	for i = 1, frame:GetNumMessages() do
		local Message, R, G, B = frame:GetMessageInfo(i)

		--Set fallback color values
		R = R or 1
		G = G or 1
		B = B or 1

		--Remove icons
		Message = RemoveIconFromLine(Message)

		--Add text color
		Message = ColorizeLine(Message, R, G, B)

		Lines[Index] = Message
		Index = Index + 1
	end

	return Index - 1
end

function CopyChat:CopyText(frame)
	if not CopyChatFrame:IsShown() then
		local _, Size = FCF_GetChatWindowInfo(frame:GetID())

		if Size < 10 then
			Size = 12
		end

		FCF_SetChatWindowFontSize(frame, frame, 0.01)

		CopyChatFrame:Show()

		local LineCount = self:GetLines(frame)
		local Text = table_concat(Lines, "\n", 1, LineCount)

		FCF_SetChatWindowFontSize(frame, frame, Size)

		CopyChatFrameEditBox:SetText(Text)
	else
		CopyChatFrame:Hide()
	end
end

local OnEnter = function(self)
	self:SetAlpha(1)
end

local OnLeave = function(self)
	self:SetAlpha(0.25)
end

local OnMouseUp = function(self)
	if InCombatLockdown() then
		return
	end

	CopyChat:CopyText(self.ChatFrame)
end

function CopyChat:OnEnable()
	CopyFrame = CreateFrame("Frame", "CopyChatFrame", UIParent)
	table_insert(UISpecialFrames, "CopyChatFrame")
	CopyFrame:SetTemplate("Transparent")
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
	CopyChatFrameEditBox:SetScript("OnTextChanged", function(self, userInput)
		if userInput then return end
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
		CopyButton:SetPoint("TOPRIGHT")
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
			local anchor, panel, xoff, yoff = "ANCHOR_TOPLEFT", self:GetParent(), 10, 5
			GameTooltip:SetOwner(self, anchor, xoff, yoff)
			GameTooltip:ClearLines()
			GameTooltip:AddLine(L["ConfigButton"].Functions)
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(leftButtonString..L["ConfigButton"].LeftClick, "Copy chat", 1, 1, 1)
			GameTooltip:AddDoubleLine(rightButtonString..L["ConfigButton"].Right_Click, "Emotions", 1, 1, 1)
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
		local ConfigButton = CreateFrame("Button", string.format("ConfigChatButton%d", id), frame)
		ConfigButton:EnableMouse(true)
		ConfigButton:SetSize(26, 26)
		ConfigButton:SetHitRectInsets(6, 6, 7, 7)
		ConfigButton:SetPoint("TOPRIGHT", 2, 23)
		ConfigButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Chat\\Config")
		ConfigButton:SetAlpha(0.25)
		ConfigButton:SetFrameLevel(frame:GetFrameLevel() + 5)

		ConfigButton:SetScript("OnMouseUp", function(self, btn)
			if btn == "LeftButton" or btn == "RightButton" then
				L_EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 2)
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