local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.Enable ~= true or IsAddOnLoaded("Quartz") then return end

local unpack = unpack
local format = string.format
local max = math.max
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local UIPARENT_MANAGED_FRAME_POSITIONS = UIPARENT_MANAGED_FRAME_POSITIONS

-- Anchors
local PlayerCastbarAnchor = CreateFrame("Frame", "PlayerCastbarAnchor", UIParent)
if not InCombatLockdown() then
	PlayerCastbarAnchor:SetSize(CastingBarFrame:GetWidth() * C.Unitframe.CastBarScale, CastingBarFrame:GetHeight() * 2)
	PlayerCastbarAnchor:SetPoint(unpack(C.Position.UnitFrames.PlayerCastBar))
end

local TargetCastbarAnchor = CreateFrame("Frame", "TargetCastbarAnchor", UIParent)
if not InCombatLockdown() then
	TargetCastbarAnchor:SetSize(TargetFrameSpellBar:GetWidth() * C.Unitframe.CastBarScale, TargetFrameSpellBar:GetHeight() * 2)
	TargetCastbarAnchor:SetPoint(unpack(C.Position.UnitFrames.TargetCastBar))
end

local CastBars = CreateFrame("Frame", nil, UIParent)

CastBars:RegisterEvent("ADDON_LOADED")
CastBars:SetScript("OnEvent", function(self, event, addon)
	if (addon ~= "KkthnxUI") then return end
	if not InCombatLockdown() then

		UIPARENT_MANAGED_FRAME_POSITIONS["CastingBarFrame"] = nil

		-- Move Cast Bar
		CastingBarFrame:SetMovable(true)
		CastingBarFrame:ClearAllPoints()
		CastingBarFrame:SetScale(C.Unitframe.CastBarScale)
		CastingBarFrame:SetPoint("CENTER", PlayerCastbarAnchor, "CENTER", 0, -3)
		CastingBarFrame:SetUserPlaced(true)
		CastingBarFrame:SetMovable(false)

		-- Style CastingBarFrame
		CastingBarFrame.Border:SetTexture("Interface\\CastingBar\\UI-CastingBar-Border-Small")
		CastingBarFrame.Flash:SetTexture("Interface\\CastingBar\\UI-CastingBar-Flash-Small")

		CastingBarFrame.Text:ClearAllPoints()
		CastingBarFrame.Text:SetPoint("CENTER", 0, 1)
		CastingBarFrame.Border:SetWidth(CastingBarFrame.Border:GetWidth() + 4)
		CastingBarFrame.Flash:SetWidth(CastingBarFrame.Flash:GetWidth() + 4)
		CastingBarFrame.BorderShield:SetWidth(CastingBarFrame.BorderShield:GetWidth() + 4)
		CastingBarFrame.Border:SetPoint("TOP", 0, 26)
		CastingBarFrame.Flash:SetPoint("TOP", 0, 26)
		CastingBarFrame.BorderShield:SetPoint("TOP", 0, 26)

		-- CastingBarFrame Icon
		CastingBarFrame.Icon:Show()
		CastingBarFrame.Icon:ClearAllPoints()
		CastingBarFrame.Icon:SetSize(20, 20)
		CastingBarFrame.Icon:SetPoint("LEFT", CastingBarFrame, "RIGHT", 8, 0)

		-- Target Castbar
		TargetFrameSpellBar:ClearAllPoints()
		TargetFrameSpellBar:SetScale(C.Unitframe.CastBarScale)
		TargetFrameSpellBar:SetPoint("CENTER", TargetCastbarAnchor, "CENTER", 0, 0)
		TargetFrameSpellBar.SetPoint = K.Noop

		-- Castbar Timer
		CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
		if C.Unitframe.Outline then
			CastingBarFrame.timer:SetFont(C.Media.Font, C.Media.Font_Size + 2, C.Media.Font_Style)
			CastingBarFrame.timer:SetShadowOffset(0, -0)
		else
			CastingBarFrame.timer:SetFont(C.Media.Font, C.Media.Font_Size + 2)
			CastingBarFrame.timer:SetShadowOffset(K.Mult, -K.Mult)
		end
		CastingBarFrame.timer:SetPoint("RIGHT", CastingBarFrame, "LEFT", -12, 1)
		CastingBarFrame.update = 0.1

		TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
		if C.Unitframe.Outline then
			TargetFrameSpellBar.timer:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
			TargetFrameSpellBar.timer:SetShadowOffset(0, -0)
		else
			TargetFrameSpellBar.timer:SetFont(C.Media.Font, C.Media.Font_Size)
			TargetFrameSpellBar.timer:SetShadowOffset(K.Mult, -K.Mult)
		end
		TargetFrameSpellBar.timer:SetPoint("LEFT", TargetFrameSpellBar, "RIGHT", 8, 2)
		TargetFrameSpellBar.update = 0.1

		self:UnregisterEvent("ADDON_LOADED")
	end
end)

-- Displays the Casting Bar timer
local function CastingBarFrame_OnUpdate_Hook(self, elapsed)
	if(not self.timer) then
		return
	end
	if(self.update) and (self.update < elapsed) then
		if(self.casting) then
			self.timer:SetText(format("%2.1f / %1.1f", max(self.maxValue - self.value, 0), self.maxValue))
		elseif(self.channeling) then
			self.timer:SetText(format("%.1f", max(self.value, 0)))
		else
			self.timer:SetText("")
		end
		self.update = 0.1
	else
		self.update = self.update - elapsed
	end
end

CastingBarFrame:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)
TargetFrameSpellBar:HookScript("OnUpdate", CastingBarFrame_OnUpdate_Hook)