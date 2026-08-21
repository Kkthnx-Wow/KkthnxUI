--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/ButtonPreview.lua
	Purpose:
		A quick throwaway preview of the custom button art in Media/Buttons, each
		framed with our border so the look can be checked at a glance. Toggle it with
		/kk buttons. The slice coordinates are estimates from the source art; adjust
		BAR_ROWS / ICON_GRID if a cell is off.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

local CreateFrame = CreateFrame
local tinsert = table.insert

local BAR_TEX = "Interface\\AddOns\\KkthnxUI\\Media\\Buttons\\Buttons"
local ICON_TEX = "Interface\\AddOns\\KkthnxUI\\Media\\Buttons\\Buttons_2"

-- Buttons.blp: three stacked horizontal bar states. { left, right, top, bottom }.
local BAR_ROWS = {
	{ "Dark", 0.02, 0.977, 0.027, 0.227 },
	{ "Dark Red", 0.02, 0.977, 0.285, 0.484 },
	{ "Red", 0.02, 0.977, 0.543, 0.742 },
}

-- Buttons_2.blp: a grid of icon buttons. Rather than an even split (which caught
-- the gaps between cells), use a cell pitch plus the icon's own extent so each
-- icon is inset from its neighbours. Values are fractions of the 512px sheet.
local ICON_COLS = 5
local ICON_ROWS = 3
local ICON_LEFT = 0.015 -- left edge of the first column
local ICON_TOP = 0.015 -- top edge of the first row
local ICON_PITCH_X = 0.195 -- column to column
local ICON_PITCH_Y = 0.254 -- row to row
local ICON_SIZE = 0.172 -- icon extent within a cell

local preview

local function BuildBarSample(parent, row, y)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(240, 34)
	button:SetPoint("TOP", parent, "TOP", -30, y)

	local tex = button:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	tex:SetTexture(BAR_TEX)
	tex:SetTexCoord(row[2], row[3], row[4], row[5])

	K.CreateBorder(button)

	local label = button:CreateFontString(nil, "OVERLAY")
	K.SetFont(label, 12)
	label:SetPoint("LEFT", button, "RIGHT", 10, 0)
	label:SetText(row[1])
	return button
end

local function BuildIconGrid(parent, startY)
	local size = 40
	local gap = 8
	local ox = 16
	for r = 1, ICON_ROWS do
		for c = 1, ICON_COLS do
			local button = CreateFrame("Button", nil, parent)
			button:SetSize(size, size)
			button:SetPoint("TOPLEFT", parent, "TOPLEFT", ox + (c - 1) * (size + gap), startY - (r - 1) * (size + gap))

			local tex = button:CreateTexture(nil, "ARTWORK")
			tex:SetAllPoints()
			tex:SetTexture(ICON_TEX)
			local l = ICON_LEFT + (c - 1) * ICON_PITCH_X
			local t = ICON_TOP + (r - 1) * ICON_PITCH_Y
			tex:SetTexCoord(l, l + ICON_SIZE, t, t + ICON_SIZE)

			K.CreateBorder(button)
		end
	end
end

local function BuildPreview()
	local frame = CreateFrame("Frame", "KKUI_ButtonPreview", UIParent)
	frame:SetSize(360, 430)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("HIGH")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	K.CreateBackground(frame, 0.05, 0.05, 0.05, 0.95)
	K.CreateBorder(frame)
	tinsert(UISpecialFrames, "KKUI_ButtonPreview")

	local title = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 16, "OUTLINE")
	title:SetTextColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3])
	title:SetPoint("TOP", 0, -12)
	title:SetText(L["Button Preview"])

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -6, -6)
	K.SkinCloseButton(close)

	local barHeader = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(barHeader, 13, "OUTLINE")
	barHeader:SetTextColor(0.9, 0.8, 0.5)
	barHeader:SetPoint("TOPLEFT", 16, -42)
	barHeader:SetText(L["Bar Buttons"])

	local y = -64
	for _, row in ipairs(BAR_ROWS) do
		BuildBarSample(frame, row, y)
		y = y - 42
	end

	local iconHeader = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(iconHeader, 13, "OUTLINE")
	iconHeader:SetTextColor(0.9, 0.8, 0.5)
	iconHeader:SetPoint("TOPLEFT", 16, y - 8)
	iconHeader:SetText(L["Icon Buttons"])

	BuildIconGrid(frame, y - 28)

	preview = frame
	return frame
end

function K.ToggleButtonPreview()
	if not preview then
		BuildPreview()
	end
	preview:SetShown(not preview:IsShown())
end
