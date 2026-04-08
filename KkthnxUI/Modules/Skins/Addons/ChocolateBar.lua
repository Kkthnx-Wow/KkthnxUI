--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins ChocolateBar frames.
-- - Design: Iterates through ChocolateBar frames and applies KkthnxUI border styling.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local RaidUtility_ShowButton = _G.RaidUtility_ShowButton

-- REASON: Main entry point for ChocolateBar skinning.
function Module:ReskinChocolateBar()
	if not C["Skins"].ChocolateBar then
		return
	end

	if not (K.CheckAddOnState("ChocolateBar")) then
		return
	end

	for i = 1, 20 do
		local chocolateFrame = _G["ChocolateBar" .. i]
		if chocolateFrame then
			chocolateFrame:StripTextures()
			chocolateFrame:CreateBorder()
		end
	end

	if RaidUtility_ShowButton then
		RaidUtility_ShowButton:SetFrameStrata("TOOLTIP")
	end
end
