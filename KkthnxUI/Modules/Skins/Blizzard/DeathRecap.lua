--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Death Recap frame.
-- - Design: Applies custom borders and skins buttons/events within the Death Recap UI.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local select = _G.select
local unpack = _G.unpack

local DeathRecapFrame = _G.DeathRecapFrame
local NUM_DEATH_RECAP_EVENTS = _G.NUM_DEATH_RECAP_EVENTS

local function SkinDeathRecapFrame()
	local DeathRecapFrame = DeathRecapFrame

	-- Disable the border draw layer and hide unwanted elements
	DeathRecapFrame:DisableDrawLayer("BORDER")
	DeathRecapFrame.Background:Hide()
	DeathRecapFrame.BackgroundInnerGlow:Hide()
	DeathRecapFrame.Divider:Hide()

	-- Create a new border for the frame
	DeathRecapFrame:CreateBorder()

	-- Skin the bottom close button (without a parent key)
	local closeButton = select(8, DeathRecapFrame:GetChildren())
	if closeButton then
		closeButton:SkinButton()
	end

	-- Skin the close button at the top right corner
	DeathRecapFrame.CloseXButton:SkinCloseButton()
end

local function SkinRecapEvents()
	for i = 1, NUM_DEATH_RECAP_EVENTS do
		local recap = DeathRecapFrame["Recap" .. i].SpellInfo
		recap.IconBorder:Hide()
		recap.Icon:SetTexCoord(unpack(K.TexCoords))
		recap:CreateBorder()
	end
end

-- REASON: Main entry point for Blizzard Death Recap skinning.
C.themes["Blizzard_DeathRecap"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	SkinDeathRecapFrame()
	SkinRecapEvents()
end
