--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins Simulationcraft (SimC) frame.
-- - Design: Hooks SimC's frame retrieval to apply KkthnxUI border and button styling.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Skins")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local hooksecurefunc = _G.hooksecurefunc
local LibStub = _G.LibStub

local SimcFrame = _G.SimcFrame
local SimcFrameButton = _G.SimcFrameButton
local SimcScrollFrameScrollBar = _G.SimcScrollFrameScrollBar
local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded

-- REASON: Main entry point for Simulationcraft skinning.
function Module:ReskinSimulationcraft()
	if not C_AddOns_IsAddOnLoaded("Simulationcraft") then
		return
	end

	local Simulationcraft = LibStub("AceAddon-3.0"):GetAddon("Simulationcraft")
	hooksecurefunc(Simulationcraft, "GetMainFrame", function()
		if not SimcFrame.isSkinned then
			SimcFrame:StripTextures()
			SimcFrame:CreateBorder()
			SimcFrameButton:SetHeight(22)
			SimcFrameButton:SkinButton()
			SimcScrollFrameScrollBar:SkinScrollBar()
			SimcFrame.isSkinned = true
		end
	end)
end
