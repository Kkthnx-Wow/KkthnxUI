--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins BugSack frames.
-- - Design: Hooks BugSack's OpenSack function to apply KkthnxUI border and button skinning.
-- - Events: N/A (Handled via RegisterSkin dynamic load / ADDON_LOADED).
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Skins")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local hooksecurefunc = _G.hooksecurefunc
local pairs = _G.pairs

local C_AddOns_IsAddOnLoaded = _G.C_AddOns and _G.C_AddOns.IsAddOnLoaded

-- REASON: Main entry point for BugSack frame skinning.
function Module:ReskinBugSack()
	if not C_AddOns_IsAddOnLoaded or not C_AddOns_IsAddOnLoaded("BugSack") then
		return
	end

	local BugSack = _G.BugSack
	if not BugSack then
		return
	end

	hooksecurefunc(BugSack, "OpenSack", function()
		local BugSackFrame = _G.BugSackFrame
		if not BugSackFrame or BugSackFrame.IsSkinned then
			return
		end

		BugSackFrame:StripTextures()
		BugSackFrame:CreateBorder()

		local BugSackTabAll = _G.BugSackTabAll
		if BugSackTabAll then
			BugSackTabAll:StripTextures()
			BugSackTabAll:CreateBorder(nil, nil, nil, nil, -10, nil, nil, nil, nil, 6)
			BugSackTabAll:SetPoint("TOPLEFT", BugSackFrame, "BOTTOMLEFT", 0, 1)
		end

		local BugSackTabSession = _G.BugSackTabSession
		if BugSackTabSession then
			BugSackTabSession:StripTextures()
			BugSackTabSession:CreateBorder(nil, nil, nil, nil, -10, nil, nil, nil, nil, 6)
		end

		local BugSackTabLast = _G.BugSackTabLast
		if BugSackTabLast then
			BugSackTabLast:StripTextures()
			BugSackTabLast:CreateBorder(nil, nil, nil, nil, -10, nil, nil, nil, nil, 6)
		end

		local BugSackNextButton = _G.BugSackNextButton
		if BugSackNextButton then
			BugSackNextButton:SkinButton()
		end

		local BugSackPrevButton = _G.BugSackPrevButton
		if BugSackPrevButton then
			BugSackPrevButton:SkinButton()
		end

		local BugSackSendButton = _G.BugSackSendButton
		if BugSackSendButton then
			BugSackSendButton:SkinButton()
			if BugSackPrevButton and BugSackNextButton then
				BugSackSendButton:SetPoint("LEFT", BugSackPrevButton, "RIGHT", 6, 0)
				BugSackSendButton:SetPoint("RIGHT", BugSackNextButton, "LEFT", -6, 0)
			end
		end

		local BugSackScrollFrameScrollBar = _G.BugSackScrollFrameScrollBar or _G.BugSackScrollScrollBar
		if BugSackScrollFrameScrollBar then
			BugSackScrollFrameScrollBar:SkinScrollBar()
		end

		for _, child in pairs({ BugSackFrame:GetChildren() }) do
			if child:IsObjectType("Button") and child:GetScript("OnClick") == BugSack.CloseSack then
				child:SkinCloseButton()
			end
		end

		BugSackFrame.IsSkinned = true
	end)
end

Module:RegisterSkin("BugSack", Module.ReskinBugSack)
