local K, C = unpack(KkthnxUI)

C.themes["Blizzard_TalentUI"] = function()
	for i = 1, MAX_TALENT_TIERS do
		local row = _G["PlayerTalentFrameTalentsTalentRow" .. i]
		row.TopLine:SetDesaturated(true)
		row.TopLine:SetVertexColor(K.r, K.g, K.b)
		row.BottomLine:SetDesaturated(true)
		row.BottomLine:SetVertexColor(K.r, K.g, K.b)

		for j = 1, NUM_TALENT_COLUMNS do
			local bu = _G["PlayerTalentFrameTalentsTalentRow" .. i .. "Talent" .. j]
			local ic = _G["PlayerTalentFrameTalentsTalentRow" .. i .. "Talent" .. j .. "IconTexture"]

			bu.Slot:SetAlpha(0)

			ic:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

			bu.bg = CreateFrame("Frame", nil, bu)
			bu.bg:SetFrameLevel(bu:GetFrameLevel())
			bu.bg:SetAllPoints(ic)
			bu.bg:CreateBorder()
		end
	end

	hooksecurefunc("TalentFrame_Update", function()
		for i = 1, MAX_TALENT_TIERS do
			for j = 1, NUM_TALENT_COLUMNS do
				local _, _, _, selected, _, _, _, _, _, _, known = GetTalentInfo(i, j, 1)
				local bu = _G["PlayerTalentFrameTalentsTalentRow" .. i .. "Talent" .. j]
				if known then
					bu.bg.KKUI_Border:SetVertexColor(K.r, K.g, K.b)
				elseif selected then
					bu.bg.KKUI_Border:SetVertexColor(K.r, K.g, K.b)
				else
					bu.bg.KKUI_Border:SetVertexColor(1, 1, 1)
				end
			end
		end
	end)

	if C["General"].NoTutorialButtons then
		_G.PlayerTalentFrameTalentsTutorialButton:Kill()
		_G.PlayerTalentFrameSpecializationTutorialButton:Kill()
	end
end
