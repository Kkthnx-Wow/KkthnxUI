local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

-- Sourced: ElvUI (Elvz)
-- Edited: KkthnxUI (Kkthnx)
local _G = _G
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc

local function SkinLossOfControl()
	local IconBackdrop = CreateFrame("Frame", nil, LossOfControlFrame)
	IconBackdrop:SetTemplate()
	IconBackdrop:SetAllPoints(LossOfControlFrame.Icon)
	IconBackdrop:SetFrameLevel(LossOfControlFrame:GetFrameLevel())
	IconBackdrop:SetBackdropBorderColor(1, 0, 0, 1)

	LossOfControlFrame.Icon:SetTexCoord(.1, .9, .1, .9)
	LossOfControlFrame:StripTextures()
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame:SetSize(LossOfControlFrame.Icon:GetWidth() + 50, LossOfControlFrame.Icon:GetWidth() + 50)

	hooksecurefunc(
		"LossOfControlFrame_SetUpDisplay",
		function(self)
			self.Icon:ClearAllPoints()
			self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0)

			self.AbilityName:ClearAllPoints()
			self.AbilityName:SetPoint("BOTTOM", self, 0, -4)
			self.AbilityName.scrollTime = nil
			self.AbilityName:FontTemplate(C.Media.Font, 20, "OUTLINE")

			self.TimeLeft.NumberText:ClearAllPoints()
			self.TimeLeft.NumberText:SetPoint("BOTTOM", self, 0, -26)
			self.TimeLeft.NumberText.scrollTime = nil
			self.TimeLeft.NumberText:FontTemplate(C.Media.Font, 20, "OUTLINE")

			self.TimeLeft.SecondsText:ClearAllPoints()
			self.TimeLeft.SecondsText:SetPoint("BOTTOM", self, 0, -48)
			self.TimeLeft.SecondsText.scrollTime = nil
			self.TimeLeft.SecondsText:FontTemplate(C.Media.Font, 20, "OUTLINE")

			-- always stop shake animation on start
			if self.Anim:IsPlaying() then
				self.Anim:Stop()
			end
		end
	)
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinLossOfControl)
