--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/Dialog.lua
	Purpose:
		One shared confirmation dialog wearing our own skin, so a destructive
		action asks in the same window everywhere instead of borrowing Blizzard's
		StaticPopup and its default art.

		The frame is built on first use and reused after that, so a session that
		never confirms anything pays nothing for it.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

local CreateFrame = CreateFrame
local tinsert = table.insert

local dialog

local function Close()
	dialog:Hide()
	dialog.onAccept = nil
end

local function OnAccept()
	local callback = dialog.onAccept
	Close()
	if callback then
		callback()
	end
end

local function Build()
	local frame = CreateFrame("Frame", "KKUI_ConfirmDialog", UIParent)
	frame:SetSize(360, 120)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	frame:EnableMouse(true)
	frame:Hide()
	K.CreateGradientBackground(frame)
	K.CreateBorder(frame)

	-- Escape closes it, the same as any Blizzard dialog.
	tinsert(_G.UISpecialFrames, "KKUI_ConfirmDialog")

	frame.Text = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(frame.Text, 13, "")
	frame.Text:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -20)
	frame.Text:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -18, -20)
	frame.Text:SetJustifyH("CENTER")
	frame.Text:SetSpacing(3)
	frame.Text:SetTextColor(K.Colors.offWhite[1], K.Colors.offWhite[2], K.Colors.offWhite[3])

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

-- Ask before doing something the player cannot undo. The callback runs only when
-- they accept, so a caller needs no state of its own.
function K.Confirm(text, onAccept)
	if not dialog then
		dialog = Build()
	end
	dialog.Text:SetText(text or L["Are you sure?"])
	dialog.onAccept = onAccept
	dialog:Show()
end
