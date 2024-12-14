local K, C = KkthnxUI[1], KkthnxUI[2]

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
C.themes["Blizzard_TradeSkillUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	SkinTradeSkillRankBar()
	AdjustOptionalReagentListPosition()
end
