--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Skins/Battlenet.lua
	Purpose:
		Give the Battle.net friend/broadcast toast our border and gradient, and move
		it to a clean spot at the top of the screen instead of floating over the chat.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("Battlenet")

local _G = _G
local ipairs = ipairs
local hooksecurefunc = hooksecurefunc

-- Border and gradient on a toast frame, with its stock plate art blanked. The
-- social toasts inherit BackdropTemplate (BACKDROP_TOAST_12_12) rather than a
-- NineSlice, so the dark plate is a real backdrop that has to be cleared, and the
-- close button is a child we reskin to match ours.
local function SkinToast(frame)
	if not frame or frame.KKUI_Skinned then
		return
	end
	frame.KKUI_Skinned = true
	if frame.NineSlice then
		frame.NineSlice:SetAlpha(0)
	end
	if frame.Background then
		frame.Background:SetAlpha(0)
	end
	if frame.SetBackdrop then
		frame:SetBackdrop(nil)
	end
	K.CreateGradientBackground(frame, 0.9)
	K.CreateBorder(frame)

	if frame.CloseButton and K.SkinCloseButton then
		K.SkinCloseButton(frame.CloseButton)
	end
end

function Module:OnEnable()
	if not C.Chat.Enable then
		return
	end

	local toast = _G.BNToastFrame
	if toast then
		SkinToast(toast)
		-- Pin it to the top of the screen and hold it there, since the client
		-- re-anchors the toast as it grows and shrinks.
		local function reanchor()
			if toast.__kkuiAnchoring then
				return
			end
			toast.__kkuiAnchoring = true
			toast:ClearAllPoints()
			toast:SetPoint("TOP", UIParent, "TOP", 0, -160)
			toast.__kkuiAnchoring = false
		end
		reanchor()
		hooksecurefunc(toast, "SetPoint", reanchor)
	end

	-- The GM ticket and time-alert toasts share the same plate.
	SkinToast(_G.TimeAlertFrame)

	-- Trim any leftover inner textures the toast leaves behind.
	if toast then
		for _, region in ipairs({ toast:GetRegions() }) do
			if region.GetObjectType and region:GetObjectType() == "Texture" and region:GetDrawLayer() == "BORDER" then
				region:SetAlpha(0)
			end
		end
	end
end
