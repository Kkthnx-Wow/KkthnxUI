local K, C = unpack(select(2, ...))

-- Sourced: ElvUI (Elvz)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	local LossOfControlFrame = _G.LossOfControlFrame
	local LossOfControlFont = K.GetFont(C["UIFonts"].SkinFonts)

	local IconBackdrop = CreateFrame("Frame", nil, LossOfControlFrame)
	IconBackdrop:SetAllPoints(LossOfControlFrame.Icon)
	IconBackdrop:SetFrameLevel(LossOfControlFrame:GetFrameLevel())
	IconBackdrop:CreateBorder()
	IconBackdrop.KKUI_Border:SetVertexColor(1, 0, 0)

	LossOfControlFrame.Icon:SetTexCoord(unpack(K.TexCoords))
	LossOfControlFrame:StripTextures()
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame:SetSize(LossOfControlFrame.Icon:GetWidth() + 50, LossOfControlFrame.Icon:GetWidth() + 50)

	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		self.Icon:ClearAllPoints()
		self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0)

		self.AbilityName:ClearAllPoints()
		self.AbilityName:SetPoint("BOTTOM", self, 0, -8)
		self.AbilityName.scrollTime = nil
		self.AbilityName:SetFontObject(LossOfControlFont)
		self.AbilityName:SetFont(select(1, self.AbilityName:GetFont()), 20, select(3, self.AbilityName:GetFont()))

		self.TimeLeft.NumberText:ClearAllPoints()
		self.TimeLeft.NumberText:SetPoint("BOTTOM", self, 4, -38)
		self.TimeLeft.NumberText.scrollTime = nil
		self.TimeLeft.NumberText:SetFontObject(LossOfControlFont)
		self.TimeLeft.NumberText:SetFont(select(1, self.AbilityName:GetFont()), 20, select(3, self.AbilityName:GetFont()))

		self.TimeLeft.SecondsText:ClearAllPoints()
		self.TimeLeft.SecondsText:SetPoint("BOTTOM", self, 0, -60)
		self.TimeLeft.SecondsText.scrollTime = nil
		self.TimeLeft.SecondsText:SetFontObject(LossOfControlFont)
		self.TimeLeft.SecondsText:SetFont(select(1, self.AbilityName:GetFont()), 20, select(3, self.AbilityName:GetFont()))

		-- always stop shake animation on start
		if self.Anim:IsPlaying() then
			self.Anim:Stop()
		end
	end)
end)