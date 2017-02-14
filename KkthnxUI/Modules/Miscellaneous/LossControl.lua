local K, C, L = unpack(select(2, ...))

-- Wow Lua
local _G = _G

-- Wow API
local hooksecurefunc = _G.hooksecurefunc

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LossOfControlFrame

local function LossControl_Update(self)
	self.Icon:ClearAllPoints()
	self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0)

	self.AbilityName:ClearAllPoints()
	self.AbilityName:SetPoint("BOTTOM", self, 0, -28)
	self.AbilityName.scrollTime = nil
	self.AbilityName:SetFont(C.Media.Font, 18, "OUTLINE")
	self.AbilityName:SetShadowOffset(0, 0)

	self.TimeLeft.NumberText:ClearAllPoints()
	self.TimeLeft.NumberText:SetPoint("BOTTOM", self, 4, -58)
	self.TimeLeft.NumberText.scrollTime = nil
	self.TimeLeft.NumberText:SetFont(C.Media.Font, 18, "OUTLINE")
	self.TimeLeft.NumberText:SetShadowOffset(0, 0)

	self.TimeLeft.SecondsText:ClearAllPoints()
	self.TimeLeft.SecondsText:SetPoint("BOTTOM", self, 0, -80)
	self.TimeLeft.SecondsText.scrollTime = nil
	self.TimeLeft.SecondsText:SetFont(C.Media.Font, 18, "OUTLINE")
	self.TimeLeft.SecondsText:SetShadowOffset(0, 0)

	if self.Anim:IsPlaying() then
		self.Anim:Stop()
	end
end

local function LossControl_Enable()
	LossOfControlFrame:StripTextures()
	LossOfControlFrame:CreateBackdrop()
	LossOfControlFrame.Icon:SetTexCoord(.1, .9, .1, .9)
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame.backdrop:SetOutside(LossOfControlFrame.Icon, 4, 4)

	hooksecurefunc("LossOfControlFrame_SetUpDisplay", LossControl_Update)
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function()
	LossControl_Enable()
end)