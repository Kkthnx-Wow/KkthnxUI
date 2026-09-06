--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/Dialog.lua
	Purpose:
		One shared dialog wearing our own skin, so a destructive action or a name
		entry asks in the same window everywhere instead of borrowing Blizzard's
		StaticPopup and its default art.

		Two entry points over one frame:
			K.Confirm(text, onAccept)          yes or no
			K.Prompt(text, default, onAccept)  yes or no with a text field

		The frame is built on first use and reused after that, so a session that
		never opens a dialog pays nothing for it.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

local CreateFrame = CreateFrame
local tinsert = table.insert

local BASE_HEIGHT = 116
local INPUT_HEIGHT = 150

local dialog

local function Close()
	dialog:Hide()
	dialog.onAccept = nil
end

local function OnAccept()
	local callback = dialog.onAccept
	-- Read the field before Close clears the callback, since Close also drops
	-- focus and a focus change can commit a pending edit.
	local text = dialog.Input:IsShown() and dialog.Input:GetText() or nil
	Close()
	if callback then
		callback(text)
	end
end

local function Build()
	local frame = CreateFrame("Frame", "KKUI_Dialog", UIParent)
	frame:SetSize(360, BASE_HEIGHT)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:EnableMouse(true)
	frame:Hide()
	K.CreateGradientBackground(frame)
	K.CreateBorder(frame)

	-- Escape closes it, the same as any Blizzard dialog.
	tinsert(_G.UISpecialFrames, "KKUI_Dialog")

	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(frame.Text, 13, "")
	frame.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -20)
	frame.Text:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -20)
	frame.Text:SetJustifyH("CENTER")
	frame.Text:SetSpacing(3)
	frame.Text:SetTextColor(K.Colors.offWhite[1], K.Colors.offWhite[2], K.Colors.offWhite[3])

	local input = CreateFrame("EditBox", nil, frame)
	input:SetSize(280, 22)
	input:SetPoint("BOTTOM", frame, "BOTTOM", 0, 48)
	input:SetAutoFocus(false)
	input:SetMaxLetters(64)
	K.SetFont(input, 12, "")
	K.SkinEditBox(input)
	input:SetScript("OnEnterPressed", OnAccept)
	input:SetScript("OnEscapePressed", Close)
	input:Hide()
	frame.Input = input

	local accept = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	accept:SetSize(120, 24)
	accept:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -6, 16)
	accept:SetText(_G.ACCEPT)
	K.SkinButton(accept, true)
	K.SetFont(accept:GetFontString(), 12, "")
	accept:SetScript("OnClick", OnAccept)

	local cancel = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	cancel:SetSize(120, 24)
	cancel:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 6, 16)
	cancel:SetText(_G.CANCEL)
	K.SkinButton(cancel)
	K.SetFont(cancel:GetFontString(), 12, "")
	cancel:SetScript("OnClick", Close)

	return frame
end

local function Open(text, default, onAccept)
	if not dialog then
		dialog = Build()
	end
	dialog.Text:SetText(text or L["Are you sure?"])
	dialog.onAccept = onAccept

	local input = dialog.Input
	if default then
		dialog:SetHeight(INPUT_HEIGHT)
		input:SetText(default)
		input:Show()
		input:SetFocus()
		input:HighlightText()
	else
		dialog:SetHeight(BASE_HEIGHT)
		input:ClearFocus()
		input:Hide()
	end

	dialog:Show()
end

-- Ask before doing something the player cannot undo. The callback runs only when
-- they accept, so a caller needs no state of its own.
function K.Confirm(text, onAccept)
	Open(text, nil, onAccept)
end

-- Same, with a text field. Pass "" for an empty field, since nil is what marks a
-- plain confirmation. The callback receives the typed text.
function K.Prompt(text, default, onAccept)
	Open(text, default or "", onAccept)
end
