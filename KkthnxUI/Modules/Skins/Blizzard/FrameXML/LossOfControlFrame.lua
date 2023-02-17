local K, C = KkthnxUI[1], KkthnxUI[2]

-- Sourced: ElvUI (Elvz)
-- Edited: KkthnxUI (Kkthnx)

local table_insert = table.insert

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

local LossOfControlFrame = LossOfControlFrame

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local IconBorder = CreateFrame("Frame", nil, LossOfControlFrame)
	IconBorder:SetAllPoints(LossOfControlFrame.Icon)
	IconBorder:SetFrameLevel(LossOfControlFrame:GetFrameLevel())
	IconBorder:CreateBorder(nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and 32 or nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and -10 or nil)
	IconBorder.KKUI_Border:SetVertexColor(1, 0, 0)

	LossOfControlFrame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	LossOfControlFrame:StripTextures()
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame:SetSize(LossOfControlFrame.Icon:GetWidth() + 50, LossOfControlFrame.Icon:GetWidth() + 50)

	K.Mover(LossOfControlFrame, "LossOfControl", "LossOfControlFrame", { "CENTER", UIParent, "CENTER", 0, 250 }, LossOfControlFrame:GetSize())

	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		local Icon = self.Icon
		local AbilityName = self.AbilityName
		local TimeLeftNumberText = self.TimeLeft.NumberText
		local TimeLeftSecondsText = self.TimeLeft.SecondsText
		local Anim = self.Anim

		Icon:ClearAllPoints()
		Icon:SetPoint("CENTER", self, "CENTER", 0, 0)

		AbilityName:ClearAllPoints()
		AbilityName:SetPoint("BOTTOM", self, 0, -8)
		AbilityName.scrollTime = nil
		AbilityName:SetFontObject(K.UIFont)
		AbilityName:SetFont(select(1, AbilityName:GetFont()), 20, select(3, AbilityName:GetFont()))

		TimeLeftNumberText:Kill()
		TimeLeftSecondsText:Kill()

		-- Always stop shake animation on start
		if Anim and Anim:IsPlaying() then
			Anim:Stop()
		end
	end)
end)
