local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.Enable ~= true or IsAddOnLoaded("Quartz") then return end

-- LUA API
local unpack = unpack
local format = string.format
local max = math.max

-- WOW API
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

-- ANCHORS
local PlayerCastbarAnchor = CreateFrame("Frame", "PlayerCastbarAnchor", UIParent)
PlayerCastbarAnchor:SetSize(CastingBarFrame:GetWidth() * C.Unitframe.CastBarScale, CastingBarFrame:GetHeight() * 2)
PlayerCastbarAnchor:SetPoint(unpack(C.Position.UnitFrames.PlayerCastBar))

local TargetCastbarAnchor = CreateFrame("Frame", "TargetCastbarAnchor", UIParent)
TargetCastbarAnchor:SetSize(TargetFrameSpellBar:GetWidth() * C.Unitframe.CastBarScale, TargetFrameSpellBar:GetHeight() * 2)
TargetCastbarAnchor:SetPoint(unpack(C.Position.UnitFrames.TargetCastBar))

local CastBars = CreateFrame("Frame", nil, UIParent)

function CastBars:PlaceBars()
	if InCombatLockdown() then return end

	K.ModifyFrame(CastingBarFrame, "CENTER", PlayerCastbarAnchor, 0, -3, C.Unitframe.CastBarScale)

	-- STYLE CASTINGBARFRAME
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

	-- CASTINGBARFRAME ICON
	CastingBarFrame.Icon:Show()
	CastingBarFrame.Icon:ClearAllPoints()
	CastingBarFrame.Icon:SetPoint("LEFT", CastingBarFrame, "RIGHT", 8, 0)
	CastingBarFrame.Icon:SetSize(20, 20)

	-- TARGET CASTBAR
	hooksecurefunc(TargetFrameSpellBar, "Show", function()
		K.ModifyBasicFrame(TargetFrameSpellBar, "CENTER", TargetCastbarAnchor, 0, 0, C.Unitframe.CastBarScale)
		TargetFrameSpellBar.SetPoint = K.Noop
	end)
end

function CastBars:HandleEvents(event, ...)
	if(event == "PLAYER_ENTERING_WORLD") then
		CastBars:PlaceBars()
	end

	if(event == "UNIT_EXITED_VEHICLE" or event == "UNIT_ENTERED_VEHICLE") then
		if(... == "player") then
			CastBars:PlaceBars()
		end
	end

	if(event == "ADDON_LOADED" and ... == "KkthnxUI") then
		CastingBarFrame.timer = CastingBarFrame:CreateFontString(nil)
		if C.Unitframe.Outline then
			CastingBarFrame.timer:SetFont(C.Media.Font, C.Media.Font_Size + 2, C.Media.Font_Style)
			CastingBarFrame.timer:SetShadowOffset(0, -0)
		else
			CastingBarFrame.timer:SetFont(C.Media.Font, C.Media.Font_Size + 2)
			CastingBarFrame.timer:SetShadowOffset(K.Mult, -K.Mult)
		end
		CastingBarFrame.timer:SetPoint("RIGHT", CastingBarFrame, "LEFT", -10, 0)
		CastingBarFrame.update = 0.1

		TargetFrameSpellBar.timer = TargetFrameSpellBar:CreateFontString(nil)
		if C.Unitframe.Outline then
			TargetFrameSpellBar.timer:SetFont(C.Media.Font, C.Media.Font_Size - 1, C.Media.Font_Style)
			TargetFrameSpellBar.timer:SetShadowOffset(0, -0)
		else
			TargetFrameSpellBar.timer:SetFont(C.Media.Font, C.Media.Font_Size)
			TargetFrameSpellBar.timer:SetShadowOffset(K.Mult, -K.Mult)
		end
		TargetFrameSpellBar.timer:SetPoint("LEFT", TargetFrameSpellBar, "RIGHT", 8, 0)
		TargetFrameSpellBar.update = 0.1
	end
end

function CastBars:Enable()
	CastBars:SetScript("OnEvent", CastBars.HandleEvents)

	CastBars:RegisterEvent("PLAYER_ENTERING_WORLD")
	CastBars:RegisterEvent("UNIT_EXITED_VEHICLE")
	CastBars:RegisterEvent("UNIT_ENTERED_VEHICLE")
	CastBars:RegisterEvent("ADDON_LOADED")
end

-- DISPLAYS THE CASTING BAR TIMER
local function CastBarTimers(self, elapsed)
	if not self.timer then return end

	if (self.update and self.update < elapsed) then
		if (self.casting) then
			self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
		elseif (self.channeling) then
			self.timer:SetText(format("%.1f", max(self.value, 0)))
		else
			self.timer:SetText("")
		end
		self.update = 0.1
	else
		self.update = self.update - elapsed
	end
end

CastingBarFrame:HookScript("OnUpdate", CastBarTimers)
TargetFrameSpellBar:HookScript("OnUpdate", CastBarTimers)

CastBars:Enable()