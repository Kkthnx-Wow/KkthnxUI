local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.Enable ~= true or K.IsAddOnEnabled("Quartz") then return end

-- Lua API
local unpack = unpack
local format = string.format
local max = math.max

-- Wow API
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local Movers = K.Movers

local CastBars = CreateFrame("Frame", nil, UIParent)

-- Anchors
local PlayerCastbarAnchor = CreateFrame("Frame", "PlayerCastbarAnchor", UIParent)
PlayerCastbarAnchor:SetSize(CastingBarFrame:GetWidth() * C.Unitframe.CastBarScale, CastingBarFrame:GetHeight() * 2)
PlayerCastbarAnchor:SetPoint(unpack(C.Position.UnitFrames.PlayerCastBar))
Movers:RegisterFrame(PlayerCastbarAnchor)

local TargetCastbarAnchor = CreateFrame("Frame", "TargetCastbarAnchor", UIParent)
TargetCastbarAnchor:SetSize(TargetFrameSpellBar:GetWidth() * C.Unitframe.CastBarScale, TargetFrameSpellBar:GetHeight() * 2)
TargetCastbarAnchor:SetPoint(unpack(C.Position.UnitFrames.TargetCastBar))
Movers:RegisterFrame(TargetCastbarAnchor)

function CastBars:Setup()
	UIPARENT_MANAGED_FRAME_POSITIONS["CastingBarFrame"] = nil

	if not InCombatLockdown() then
		K.ModifyFrame(CastingBarFrame, "CENTER", PlayerCastbarAnchor, 0, -3, C.Unitframe.CastBarScale)

		-- STYLE CASTINGBARFRAME
		CastingBarFrame.Border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small")
		CastingBarFrame.Flash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small")

		CastingBarFrame.Border:SetWidth(CastingBarFrame.Border:GetWidth() + 4)
		CastingBarFrame.Flash:SetWidth(CastingBarFrame.Flash:GetWidth() + 4)
		CastingBarFrame.BorderShield:SetWidth(CastingBarFrame.BorderShield:GetWidth() + 4)
		CastingBarFrame.Border:SetPoint("TOP", 0, 26)
		CastingBarFrame.Flash:SetPoint("TOP", 0, 26)
		CastingBarFrame.BorderShield:SetPoint("TOP", 0, 26)

		CastingBarFrame.Text:ClearAllPoints()
		CastingBarFrame.Text:SetPoint("CENTER", 0, 1)
	end

	-- Icon
	CastingBarFrame.Icon:Show()
	CastingBarFrame.Icon:ClearAllPoints()
	CastingBarFrame.Icon:SetPoint("LEFT", CastingBarFrame, "RIGHT", 8, 0)
	CastingBarFrame.Icon:SetSize(20, 20)

	-- Target
	if not InCombatLockdown() then
		Target_Spellbar_AdjustPosition = K.Noop
		TargetFrameSpellBar:SetParent(UIParent)
		TargetFrameSpellBar:ClearAllPoints()
		K.ModifyBasicFrame(TargetFrameSpellBar, "CENTER", TargetCastbarAnchor, 0, 0, C.Unitframe.CastBarScale * 1.3)
		TargetFrameSpellBar:SetScript("OnShow", nil)
	end

	-- Castbar text
	if C.Unitframe.Outline then
		CastingBarFrame.Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		CastingBarFrame.Text:SetShadowOffset(0, -0)

		TargetFrameSpellBar.Text:SetFont(C.Media.Font, C.Media.Font_Size - 2, C.Media.Font_Style)
		TargetFrameSpellBar.Text:SetShadowOffset(0, -0)
	else
		CastingBarFrame.Text:SetFont(C.Media.Font, C.Media.Font_Size)
		CastingBarFrame.Text:SetShadowOffset(K.Mult, -K.Mult)

		TargetFrameSpellBar.Text:SetFont(C.Media.Font, C.Media.Font_Size - 2)
		TargetFrameSpellBar.Text:SetShadowOffset(K.Mult, -K.Mult)
	end
end

function CastBars:SetupTimers()
	CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
	CastingBarFrame.timer:SetPoint("RIGHT", CastingBarFrame, "LEFT", -10, 0)
	CastingBarFrame.update = .1
	CastingBarFrame:HookScript("OnUpdate", function(self, elapsed)
		if self.update and self.update < elapsed then
			if self.casting then
				CastingBarFrame.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
			elseif self.channeling then
				CastingBarFrame.timer:SetText(format("%.1f", max(self.value, 0)))
			end
			self.update = .1
		else
			self.update = self.update - elapsed
		end
	end)

	if C.Unitframe.Outline then
		CastingBarFrame.timer:SetFont(C.Media.Font, C.Media.Font_Size + 2, C.Media.Font_Style)
		CastingBarFrame.timer:SetShadowOffset(0, -0)
	else
		CastingBarFrame.timer:SetFont(C.Media.Font, C.Media.Font_Size + 2)
		CastingBarFrame.timer:SetShadowOffset(K.Mult, -K.Mult)
	end

	TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
	TargetFrameSpellBar.timer:SetPoint("LEFT", TargetFrameSpellBar, "RIGHT", 8, 0)
	TargetFrameSpellBar.update = .1
	TargetFrameSpellBar:HookScript("OnUpdate", function(self, elapsed)
		if self.update and self.update < elapsed then
			if self.casting then
				TargetFrameSpellBar.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
			elseif self.channeling then
				TargetFrameSpellBar.timer:SetText(format("%.1f", max(self.value, 0)))
			end
			self.update = .1
		else
			self.update = self.update - elapsed
		end
	end)

	if C.Unitframe.Outline then
		TargetFrameSpellBar.timer:SetFont(C.Media.Font, C.Media.Font_Size - 1, C.Media.Font_Style)
		TargetFrameSpellBar.timer:SetShadowOffset(0, -0)
	else
		TargetFrameSpellBar.timer:SetFont(C.Media.Font, C.Media.Font_Size)
		TargetFrameSpellBar.timer:SetShadowOffset(K.Mult, -K.Mult)
	end
end

CastBars:RegisterEvent("PLAYER_LOGIN")
CastBars:SetScript("OnEvent", function(self, event, ...)
	if (event == "PLAYER_LOGIN") then
		CastBars:Setup()
		CastBars:SetupTimers()
	end
end)