--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/Crosshair.lua
	Purpose:
		A small crosshair in the middle of the screen for action camera play or
		anyone who wants to see where the character is facing. Four thin bars with
		a gap in the centre, in a colour and size of your choosing, optionally only
		while in combat.

		Built from plain textures, so it costs nothing per frame. Combat only mode
		listens for the two combat events and does nothing else.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown

local THICKNESS = 2
local GAP = 4

local frame

local function Place(bar, point, width, height, x, y)
	bar:ClearAllPoints()
	bar:SetSize(width, height)
	bar:SetPoint(point, frame, "CENTER", x, y)
end

-- Lay the bars out for the current size and colour.
function Module:RestyleCrosshair()
	if not frame then
		return
	end
	local length = C.QoL.CrosshairSize or 12
	local color = C.QoL.CrosshairColor or { 1, 1, 1 }
	local offset = GAP / 2 + length / 2

	frame:SetSize((GAP + length) * 2, (GAP + length) * 2)
	Place(frame.Top, "CENTER", THICKNESS, length, 0, offset)
	Place(frame.Bottom, "CENTER", THICKNESS, length, 0, -offset)
	Place(frame.Left, "CENTER", length, THICKNESS, -offset, 0)
	Place(frame.Right, "CENTER", length, THICKNESS, offset, 0)
	for _, bar in ipairs({ frame.Top, frame.Bottom, frame.Left, frame.Right }) do
		bar:SetColorTexture(color[1], color[2], color[3], 0.9)
	end
end

local function Sync()
	if C.QoL.CrosshairCombatOnly and not InCombatLockdown() then
		frame:Hide()
	else
		frame:Show()
	end
end

function Module:SetupCrosshair()
	frame = CreateFrame("Frame", nil, UIParent)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, C.QoL.CrosshairOffset or 0)
	frame:SetFrameStrata("BACKGROUND")
	frame:EnableMouse(false)
	for _, key in ipairs({ "Top", "Bottom", "Left", "Right" }) do
		frame[key] = frame:CreateTexture(nil, "OVERLAY")
	end
	self:RestyleCrosshair()

	if C.QoL.CrosshairCombatOnly then
		self:RegisterEvent("PLAYER_REGEN_DISABLED", Sync)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Sync)
	end
	Sync()
end
