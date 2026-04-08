--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard TradeSkill UI.
-- - Design: Restyles the rank bar and adjusts optional reagent list positioning.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local TradeSkillFrame = _G.TradeSkillFrame
local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded

-- Function to skin the TradeSkillFrame Rank Bar
local function SkinTradeSkillRankBar()
	local rankBar = TradeSkillFrame.RankFrame

	local texture = K.GetTexture(C["General"].Texture)
	rankBar:SetStatusBarTexture(texture)
	rankBar:GetStatusBarTexture():SetGradient("VERTICAL", 0.1, 0.3, 0.9, 0.2, 0.4, 1)

	rankBar.SetStatusBarColor = K.Noop

	rankBar.BorderMid:Hide()
	rankBar.BorderLeft:Hide()
	rankBar.BorderRight:Hide()

	rankBar:CreateBorder()

	rankBar.RankText:SetFontObject(K.UIFont)
end

-- Function to adjust the position of the optional reagent list
local function AdjustOptionalReagentListPosition()
	local reagentList = TradeSkillFrame.OptionalReagentList
	reagentList:ClearAllPoints()

	local xOffset = C["Misc"].TradeTabs and 42 or 2
	reagentList:SetPoint("LEFT", TradeSkillFrame, "RIGHT", xOffset, 0)
end

-- Main function to apply custom skin for the Blizzard TradeSkill UI
-- REASON: Main entry point for Blizzard TradeSkill UI skinning.
C.themes["Blizzard_TradeSkillUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- REASON: Abort if TradeSkillUI is not loaded.
	if not TradeSkillFrame then
		return
	end

	SkinTradeSkillRankBar()
	AdjustOptionalReagentListPosition()
end
