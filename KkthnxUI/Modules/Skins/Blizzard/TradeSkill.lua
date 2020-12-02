local K, C = unpack(select(2, ...))

local _G = _G

local hooksecurefunc = _G.hooksecurefunc

C.themes["Blizzard_TradeSkillUI"] = function()
	local tradeSkillFont = K.GetFont(C["UIFonts"].SkinFonts)
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

	hooksecurefunc(_G.TradeSkillFrame.DetailsFrame, "RefreshDisplay", function()
		local ResultIcon = _G.TradeSkillFrame.DetailsFrame.Contents.ResultIcon

		if ResultIcon:GetNormalTexture() then
			ResultIcon:GetNormalTexture():SetTexCoord(unpack(K.TexCoords))
		end
		ResultIcon:CreateBorder()
		ResultIcon.IconBorder:SetTexture()
		ResultIcon.ResultBorder:SetTexture()
		ResultIcon:StyleButton()

		hooksecurefunc(ResultIcon.IconBorder, "SetVertexColor", function(_, r, g, b)
			ResultIcon.KKUI_Border:SetVertexColor(r, g, b)
			_G.TradeSkillFrame.DetailsFrame.Background:SetVertexColor(r + 50/255, g + 50/255, b + 50/255)
		end)

		for i = 1, #_G.TradeSkillFrame.DetailsFrame.Contents.Reagents do
			local Button = _G.TradeSkillFrame.DetailsFrame.Contents.Reagents[i]
			local Icon = Button.Icon
			local Count = Button.Count
			local _, _, fontFlags = Count:GetFont()

			Icon:SetTexCoord(unpack(K.TexCoords))
			if not Icon.bg then
				Icon.bg = CreateFrame("Frame", nil, Button)
				Icon.bg:SetAllPoints(Icon)
				Icon.bg:SetFrameLevel(Button:GetFrameLevel())
				Icon.bg:CreateBorder()
			end

			Count:SetFontObject(tradeSkillFont)
			Count:SetFont(select(1, Count:GetFont()), 12, fontFlags)
			Count:SetShadowOffset(0, 0)

			Button.NameFrame:SetSize(150, 40)
			Button.NameFrame:SetTexture("Interface\\Spellbook\\Spellbook-Parts")
			Button.NameFrame:SetTexCoord(0.31250000, 0.96484375, 0.37109375, 0.52343750)
			Button.NameFrame:SetVertexColor(0, 0, 0)
		end

		for i = 1, #_G.TradeSkillFrame.DetailsFrame.Contents.OptionalReagents do
			local Button = _G.TradeSkillFrame.DetailsFrame.Contents.OptionalReagents[i]
			local Icon = Button.Icon

			Icon:SetTexCoord(unpack(K.TexCoords))
			if not Icon.bg then
				Icon.bg = CreateFrame("Frame", nil, Button)
				Icon.bg:SetAllPoints(Icon)
				Icon.bg:SetFrameLevel(Button:GetFrameLevel())
				Icon.bg:CreateBorder()
				Icon.bg.KKUI_Border:SetVertexColor(14/255, 201/255, 14/255)
			end

			Button.NameFrame:SetSize(150, 40)
			Button.NameFrame:SetTexture("Interface\\Spellbook\\Spellbook-Parts")
			Button.NameFrame:SetTexCoord(0.31250000, 0.96484375, 0.37109375, 0.52343750)
			Button.NameFrame:SetVertexColor(0, 0, 0)
		end
	end)
end