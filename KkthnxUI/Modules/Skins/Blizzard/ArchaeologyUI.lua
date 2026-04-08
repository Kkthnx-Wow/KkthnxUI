--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the archaeology digsite progress bar.
-- - Design: Applies custom status bar textures, sparks, and borders for archaeology progress.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local ArcheologyDigsiteProgressBar = _G.ArcheologyDigsiteProgressBar

local function SetupArchaeologyBar(archaeologyBar)
	-- Remove any existing textures from the bar
	archaeologyBar:StripTextures()

	-- Customize the fill bar
	local fillBar = archaeologyBar.FillBar
	fillBar:SetHeight(12)
	fillBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	fillBar:SetStatusBarColor(0.7, 0.3, 0.2)
	fillBar:CreateBorder()

	-- Add a spark texture to the fill bar
	local spark = fillBar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Textures.Spark16Texture)
	spark:SetHeight(archaeologyBar:GetHeight())
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", fillBar:GetStatusBarTexture(), "RIGHT", 0, 0)

	-- Reposition the bar title and set its font
	local barTitle = archaeologyBar.BarTitle
	if barTitle then
		barTitle:ClearAllPoints()
		barTitle:SetPoint("BOTTOM", archaeologyBar, "TOP", 0, -2)
		barTitle:SetFontObject(K.UIFont)
	end
end

-- REASON: Main entry point for Blizzard Archaeology UI skinning.
C.themes["Blizzard_ArchaeologyUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local archaeologyBar = ArcheologyDigsiteProgressBar
	if archaeologyBar then
		SetupArchaeologyBar(archaeologyBar)
	end
end
