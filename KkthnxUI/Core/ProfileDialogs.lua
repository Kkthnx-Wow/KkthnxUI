local K, C = KkthnxUI[1], KkthnxUI[2]

--[[-----------------------------------------------------------------------------
-- ProfileDialogs
--
-- Reusable modal helpers for ProfileGUI.
--
-- REASON: ProfileGUI should compose UI flows, not carry every generic input /
-- confirm / text dialog implementation inline. Import/export stay in ProfileGUI
-- for now because they are stateful profile workflows; these helpers are generic.
-----------------------------------------------------------------------------]]

local CreateFrame = CreateFrame
local UIParent = UIParent

local layout = K.GUILayout
local HEADER_HEIGHT = layout.HeaderHeight
local BUTTON_HEIGHT = layout.RowHeight

local theme = K.GUITheme
local ACCENT_COLOR = theme.AccentDim
local TEXT_COLOR = theme.Text

local CreateColoredBackground = K.WidgetFactory.CreateBackdrop
local CreateButton = K.WidgetFactory.CreateButton

local ProfileDialogs = {}
K.ProfileDialogs = ProfileDialogs

local function CreateEditBox(parent, width, height, multiline)
	local editBox = CreateFrame("EditBox", nil, parent)
	editBox:SetSize(width or 200, height or 32)
	editBox:SetFontObject(K.UIFont)
	editBox:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	editBox:SetAutoFocus(false)
	editBox:SetTextInsets(8, 8, 4, 4)

	if multiline then
		editBox:SetMultiLine(true)
		editBox:SetMaxLetters(0)
	end

	local inputBg = editBox:CreateTexture(nil, "BACKGROUND")
	inputBg:SetAllPoints()
	inputBg:SetTexture(C["Media"].Textures.White8x8Texture)
	inputBg:SetVertexColor(0.1, 0.1, 0.1, 1)

	editBox:SetScript("OnEditFocusGained", function()
		inputBg:SetVertexColor(0.15, 0.15, 0.15, 1)
	end)

	editBox:SetScript("OnEditFocusLost", function()
		inputBg:SetVertexColor(0.1, 0.1, 0.1, 1)
	end)

	editBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)

	return editBox
end

local function AddShadow(dialog)
	local shadow = CreateFrame("Frame", nil, dialog)
	shadow:SetPoint("TOPLEFT", -8, 8)
	shadow:SetPoint("BOTTOMRIGHT", 8, -8)
	shadow:SetFrameLevel(dialog:GetFrameLevel() - 1)

	local shadowTexture = shadow:CreateTexture(nil, "BACKGROUND")
	shadowTexture:SetAllPoints()
	shadowTexture:SetTexture(C["Media"].Textures.White8x8Texture)
	shadowTexture:SetVertexColor(0, 0, 0, 0.4)
end

local function CloseDialog(dialog)
	dialog:Hide()
	dialog:SetParent(nil)
end

local function AddCloseButton(dialog, titleBar)
	local closeButton = CreateFrame("Button", nil, titleBar)
	closeButton:SetSize(32, 32)
	closeButton:SetPoint("RIGHT", -4, 0)

	local closeBg = closeButton:CreateTexture(nil, "BACKGROUND")
	closeBg:SetAllPoints()
	closeBg:SetTexture(C["Media"].Textures.White8x8Texture)
	closeBg:SetVertexColor(0, 0, 0, 0)

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetSize(16, 16)
	closeButton.Icon:SetPoint("CENTER")
	closeButton.Icon:SetAtlas("uitools-icon-close")
	closeButton.Icon:SetVertexColor(1, 1, 1, 0.8)

	closeButton:SetScript("OnClick", function()
		CloseDialog(dialog)
	end)

	closeButton:SetScript("OnEnter", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 1)
		closeBg:SetVertexColor(1, 0.2, 0.2, 0.3)
	end)

	closeButton:SetScript("OnLeave", function(self)
		self.Icon:SetVertexColor(1, 1, 1, 0.8)
		closeBg:SetVertexColor(0, 0, 0, 0)
	end)
end

local function CreateBaseDialog(width, height)
	local dialog = CreateFrame("Frame", nil, UIParent)
	dialog:SetSize(width, height)
	dialog:SetPoint("CENTER")
	dialog:SetFrameStrata("TOOLTIP")
	dialog:SetFrameLevel(120)
	dialog:EnableMouse(true)
	CreateColoredBackground(dialog, 0.08, 0.08, 0.08, 0.95)
	AddShadow(dialog)
	return dialog
end

function ProfileDialogs:CreateSimpleDialog(title, message, content)
	local dialog = CreateBaseDialog(400, 250)

	local titleText = dialog:CreateFontString(nil, "OVERLAY")
	titleText:SetFontObject(K.UIFont)
	titleText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	titleText:SetText(title)
	titleText:SetPoint("TOP", 0, -15)

	local messageText = dialog:CreateFontString(nil, "OVERLAY")
	messageText:SetFontObject(K.UIFont)
	messageText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	messageText:SetText(message)
	messageText:SetPoint("TOP", titleText, "BOTTOM", 0, -15)

	local contentBox = CreateEditBox(dialog, 360, 120, true)
	contentBox:SetPoint("TOP", messageText, "BOTTOM", 0, -15)
	contentBox:SetText(content or "")

	local closeButton = CreateButton(dialog, "Close", 100, BUTTON_HEIGHT, function()
		CloseDialog(dialog)
	end)
	closeButton:SetPoint("BOTTOM", 0, 15)

	return dialog
end

function ProfileDialogs:CreateInputDialog(title, message, defaultText, onConfirm)
	local dialog = CreateBaseDialog(350, 190)

	local titleBar = CreateFrame("Frame", nil, dialog)
	titleBar:SetPoint("TOPLEFT", 0, 0)
	titleBar:SetPoint("TOPRIGHT", 0, 0)
	titleBar:SetHeight(HEADER_HEIGHT)
	CreateColoredBackground(titleBar, ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3])

	local titleText = titleBar:CreateFontString(nil, "OVERLAY")
	titleText:SetFontObject(K.UIFont)
	titleText:SetTextColor(1, 1, 1, 1)
	titleText:SetText(title)
	titleText:SetPoint("TOP", 0, -15)

	local messageText = dialog:CreateFontString(nil, "OVERLAY")
	messageText:SetFontObject(K.UIFont)
	messageText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	messageText:SetText(message)
	messageText:SetPoint("TOP", titleText, "BOTTOM", 0, -30)

	local inputBox = CreateEditBox(dialog, 250, 28)
	inputBox:SetPoint("TOP", messageText, "BOTTOM", 0, -25)
	inputBox:SetText(defaultText or "")
	inputBox:SetFocus()

	AddCloseButton(dialog, titleBar)

	local confirmButton = CreateButton(dialog, "OK", 80, BUTTON_HEIGHT, function()
		if onConfirm then
			onConfirm(inputBox:GetText())
		end
		CloseDialog(dialog)
	end)
	confirmButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -10, 15)

	local cancelButton = CreateButton(dialog, "Cancel", 80, BUTTON_HEIGHT, function()
		CloseDialog(dialog)
	end)
	cancelButton:SetPoint("BOTTOMLEFT", dialog, "BOTTOM", 10, 15)

	inputBox:SetScript("OnEnterPressed", function()
		confirmButton:Click()
	end)

	inputBox:SetScript("OnEscapePressed", function()
		cancelButton:Click()
	end)

	return dialog
end

function ProfileDialogs:CreateConfirmDialog(title, message, onConfirm, onCancel)
	local dialog = CreateBaseDialog(350, 150)

	local titleText = dialog:CreateFontString(nil, "OVERLAY")
	titleText:SetFontObject(K.UIFont)
	titleText:SetTextColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
	titleText:SetText(title)
	titleText:SetPoint("TOP", 0, -15)

	local messageText = dialog:CreateFontString(nil, "OVERLAY")
	messageText:SetFontObject(K.UIFont)
	messageText:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	messageText:SetText(message)
	messageText:SetPoint("TOP", titleText, "BOTTOM", 0, -20)
	messageText:SetWidth(300)
	messageText:SetJustifyH("CENTER")

	local confirmButton = CreateButton(dialog, "Yes", 80, BUTTON_HEIGHT, function()
		if onConfirm then
			onConfirm()
		end
		CloseDialog(dialog)
	end)
	confirmButton:SetPoint("BOTTOMRIGHT", dialog, "BOTTOM", -10, 15)

	local cancelButton = CreateButton(dialog, "No", 80, BUTTON_HEIGHT, function()
		if onCancel then
			onCancel()
		end
		CloseDialog(dialog)
	end)
	cancelButton:SetPoint("BOTTOMLEFT", dialog, "BOTTOM", 10, 15)

	return dialog
end
