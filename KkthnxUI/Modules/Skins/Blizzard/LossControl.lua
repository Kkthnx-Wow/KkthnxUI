local _, C = unpack(select(2, ...))

-- Sourced: ElvUI (Elvz)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	local LossOfControlFrame = _G.LossOfControlFrame

	local IconBackdrop = CreateFrame("Frame", nil, LossOfControlFrame)
	IconBackdrop:CreateBorder()
	IconBackdrop.KKUI_Border:SetVertexColor(1, 0, 0)
	IconBackdrop:SetAllPoints(LossOfControlFrame.Icon)
	IconBackdrop:SetFrameLevel(LossOfControlFrame:GetFrameLevel())

	LossOfControlFrame.Icon:SetTexCoord(.1, .9, .1, .9)
	LossOfControlFrame:StripTextures()
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame:SetSize(LossOfControlFrame.Icon:GetWidth() + 50, LossOfControlFrame.Icon:GetWidth() + 50)

	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(s)
		s.Icon:ClearAllPoints()
		s.Icon:SetPoint("CENTER", s, "CENTER", 0, 0)

		s.AbilityName:ClearAllPoints()
		s.AbilityName:SetPoint("BOTTOM", s, 0, -8)
		s.AbilityName.scrollTime = nil
		s.AbilityName:FontTemplate(nil, 20, "OUTLINE")

		s.TimeLeft.NumberText:ClearAllPoints()
		s.TimeLeft.NumberText:SetPoint("BOTTOM", s, 4, -38)
		s.TimeLeft.NumberText.scrollTime = nil
		s.TimeLeft.NumberText:FontTemplate(nil, 20, "OUTLINE")

		s.TimeLeft.SecondsText:ClearAllPoints()
		s.TimeLeft.SecondsText:SetPoint("BOTTOM", s, 0, -60)
		s.TimeLeft.SecondsText.scrollTime = nil
		s.TimeLeft.SecondsText:FontTemplate(nil, 20, "OUTLINE")

		-- always stop shake animation on start
		if s.Anim:IsPlaying() then
			s.Anim:Stop()
		end
	end)
end)