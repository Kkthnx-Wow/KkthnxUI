local K, C = unpack(KkthnxUI)

-- Sourced: ElvUI (Elvz)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc

local LossOfControlFrame = _G.LossOfControlFrame

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

	K.Mover(LossOfControlFrame, "LossOfControl", "LossOfControlFrame", { "CENTER", UIParent, "CENTER", 0, 250 }, 60, 60)

	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		local LOCFFont = "KkthnxUIFont"
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
		AbilityName:SetFontObject(LOCFFont)
		AbilityName:SetFont(select(1, AbilityName:GetFont()), 20, select(3, AbilityName:GetFont()))

		TimeLeftNumberText:Kill()
		TimeLeftSecondsText:Kill()

		-- Always stop shake animation on start
		if Anim and Anim:IsPlaying() then
			Anim:Stop()
		end
	end)
end)
