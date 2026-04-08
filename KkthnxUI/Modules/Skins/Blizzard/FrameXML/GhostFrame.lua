--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Ghost frame (appears when dead).
-- - Design: Skins the ghost icon and applies KkthnxUI button styling to the frame.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = unpack(KkthnxUI)

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local select = _G.select
local table_insert = _G.table.insert
local unpack = _G.unpack

local GhostFrame = _G.GhostFrame
local GhostFrameContentsFrameIcon = _G.GhostFrameContentsFrameIcon

-- REASON: Main entry point for Blizzard Ghost Frame skinning.
table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	for i = 1, 6 do
		select(i, GhostFrame:GetRegions()):Hide()
	end

	GhostFrameContentsFrameIcon:SetTexCoord(unpack(K.TexCoords))

	GhostFrame:SkinButton()
end)
