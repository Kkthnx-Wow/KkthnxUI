local K, C = unpack(select(2, ...))

local _G = _G

C.themes["Blizzard_TradeSkillUI"] = function()
	local tradeSkillTexture = K.GetTexture(C["UITextures"].SkinTextures)

	local rankFrame = _G.TradeSkillFrame.RankFrame
	rankFrame:SetStatusBarTexture(tradeSkillTexture)
	rankFrame.SetStatusBarColor = K.Noop
	rankFrame:GetStatusBarTexture():SetGradient("VERTICAL", 0.1, 0.3, 0.9, 0.2, 0.4, 1)
	rankFrame.BorderMid:Hide()
	rankFrame.BorderLeft:Hide()
	rankFrame.BorderRight:Hide()
	rankFrame:CreateBorder()
	rankFrame.RankText:FontTemplate()
end