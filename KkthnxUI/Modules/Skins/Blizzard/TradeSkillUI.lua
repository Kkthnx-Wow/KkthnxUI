local K, C = KkthnxUI[1], KkthnxUI[2]

local function SkinTradeSkillFrame()
	local rankFrame = TradeSkillFrame.RankFrame
	rankFrame:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	rankFrame:GetStatusBarTexture():SetGradient("VERTICAL", 0.1, 0.3, 0.9, 0.2, 0.4, 1)
	rankFrame.SetStatusBarColor = K.Noop
	rankFrame.BorderMid:Hide()
	rankFrame.BorderLeft:Hide()
	rankFrame.BorderRight:Hide()
	rankFrame:CreateBorder()
	rankFrame.RankText:SetFontObject(K.UIFont)
end

local function AdjustOptionalReagentListPosition()
	local reagentList = TradeSkillFrame.OptionalReagentList
	reagentList:ClearAllPoints()

	local xOffset = C["Misc"].TradeTabs and 42 or 2
	reagentList:SetPoint("LEFT", TradeSkillFrame, "RIGHT", xOffset, 0)
end

C.themes["Blizzard_TradeSkillUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	SkinTradeSkillFrame()
	AdjustOptionalReagentListPosition()
end
