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

-- ---------------------------------------------------------------------------
-- Copy window
-- ---------------------------------------------------------------------------
-- A scrollable box of selectable text, for anything the player needs to get out
-- of the game and into a bug report or a paste. Built on first use like the
-- dialog above.

local copyFrame

local function BuildCopy()
	local frame = CreateFrame("Frame", "KKUI_CopyWindow", UIParent)
	frame:SetSize(640, 420)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:Hide()
	K.CreateGradientBackground(frame, 0.96)
	K.CreateBorder(frame)
	tinsert(_G.UISpecialFrames, "KKUI_CopyWindow")

	frame.Title = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(frame.Title, 15, "OUTLINE")
	frame.Title:SetPoint("TOP", 0, -12)
	frame.Title:SetTextColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3])

	local hint = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(hint, 11, "")
	hint:SetPoint("TOP", frame.Title, "BOTTOM", 0, -2)
	hint:SetTextColor(K.Colors.muted[1], K.Colors.muted[2], K.Colors.muted[3])
	hint:SetText(L["Ctrl+A then Ctrl+C to copy it all."])

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	K.SkinCloseButton(close)

	local scroll = CreateFrame("ScrollFrame", "KKUI_CopyWindowScroll", frame, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 14, -48)
	scroll:SetPoint("BOTTOMRIGHT", -32, 14)
	K.SkinScrollBar(scroll.ScrollBar)

	local edit = CreateFrame("EditBox", nil, scroll)
	edit:SetMultiLine(true)
	edit:SetAutoFocus(false)
	edit:SetFontObject(_G.ChatFontNormal)
	edit:SetTextColor(K.Colors.offWhite[1], K.Colors.offWhite[2], K.Colors.offWhite[3])
	edit:SetWidth(580)
	edit:SetScript("OnEscapePressed", function()
		frame:Hide()
	end)
	scroll:SetScrollChild(edit)
	frame.Edit = edit

	return frame
end

-- Show `text` in a selectable box titled `title`.
function K.ShowCopyText(title, text)
	if not copyFrame then
		copyFrame = BuildCopy()
	end
	copyFrame.Title:SetText(title or "")
	copyFrame.Edit:SetText(text or "")
	copyFrame.Edit:SetCursorPosition(0)
	copyFrame:Show()
	copyFrame.Edit:SetFocus()
	copyFrame.Edit:HighlightText()
end
