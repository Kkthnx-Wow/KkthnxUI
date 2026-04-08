--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins Nekometer frame.
-- - Design: Applies border styling and enforces a default position for Nekometer.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Skins")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

local NekometerMainFrame = _G.NekometerMainFrame
local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded

-- REASON: Main entry point for Nekometer skinning.
function Module:ReskinNekometer()
	if not C_AddOns_IsAddOnLoaded("nekometer") or not NekometerMainFrame then
		return
	end

	NekometerMainFrame:SetBackdrop(nil)

	if not _G["NekometerOverlayFrame"] then
		local NekometerOverlayFrame = CreateFrame("Frame", "NekometerOverlayFrame", NekometerMainFrame)
		NekometerOverlayFrame:SetAllPoints(NekometerMainFrame)

		if not NekometerOverlayFrame.KKUI_Border then
			NekometerOverlayFrame:CreateBorder()
			NekometerOverlayFrame.KKUI_Border = true
		end
	end

	-- REASON: Enforce a standardized position for the Nekometer frame.
	local point, relativeTo, relativePoint, xOfs, yOfs = NekometerMainFrame:GetPoint()
	if not (point == "BOTTOMRIGHT" and relativeTo == UIParent and relativePoint == "BOTTOMRIGHT" and xOfs == -500 and yOfs == 4) then
		NekometerMainFrame:ClearAllPoints()
		NekometerMainFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -500, 4)
	end
end

Module:RegisterSkin("nekometer", Module.ReskinNekometer)
