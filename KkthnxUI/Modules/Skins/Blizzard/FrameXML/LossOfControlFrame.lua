local K, C = KkthnxUI[1], KkthnxUI[2]
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local table_insert = table.insert

-- Function to skin the LossOfControl frame
table.insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local frame = LossOfControlFrame
	frame:StripTextures()

	local iconBorder = CreateFrame("Frame", nil, frame)
	iconBorder:SetAllPoints(frame.Icon)
	iconBorder:CreateBorder()
	iconBorder.KKUI_Border:SetVertexColor(1, 0, 0)

	frame.Icon:SetTexCoord(unpack(K.TexCoords))

	frame.AbilityName:ClearAllPoints()
	frame.AbilityName:SetPoint("BOTTOM", frame, 0, -8)
	frame.AbilityName.scrollTime = nil
	frame.AbilityName:SetFontObject(K.UIFont)
	frame.AbilityName:SetFont(select(1, frame.AbilityName:GetFont()), 20, select(3, frame.AbilityName:GetFont()))

	frame.TimeLeft.NumberText:Hide()
	frame.TimeLeft.SecondsText:Hide()

	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		local icon = self.Icon
		local abilityName = self.AbilityName
		local animation = self.Anim

		icon:ClearAllPoints()
		icon:SetPoint("CENTER", self)

		abilityName:ClearAllPoints()
		abilityName:SetPoint("BOTTOM", self, 0, -8)

		if animation and animation:IsPlaying() then
			animation:Stop()
		end
	end)

	local frameSize = frame.Icon:GetWidth() + 50
	frame:SetSize(frameSize, frameSize)
	K.Mover(frame, "LossOfControl", "LossOfControlFrame", { "CENTER", UIParent, "CENTER", 0, 250 }, frame:GetSize())
end)
