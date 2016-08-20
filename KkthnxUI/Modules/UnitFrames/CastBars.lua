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

local function AdjustCastBars()
	if(InCombatLockdown() == false) then
		-- MOVE CAST BAR
		K.ModifyFrame(CastingBarFrame, "CENTER", PlayerCastbarAnchor, 0, -3, C.Unitframe.CastBarScale)
	end
end

-- CASTINGBARFRAME ICON
CastingBarFrame.Icon:Show()
CastingBarFrame.Icon:ClearAllPoints()
CastingBarFrame.Icon:SetPoint("LEFT", CastingBarFrame, "RIGHT", 10, 2)
CastingBarFrame.Icon:SetSize(20, 20)

-- TARGET CASTBAR
K.ModifyBasicFrame(TargetFrameSpellBar, "CENTER", TargetCastbarAnchor, 0, 0, C.Unitframe.CastBarScale)
TargetFrameSpellBar.SetPoint = K.Noop

local function HandleEvents(self, event, ...)
	if(event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED") then
		AdjustCastBars()
	end

	if(event == "UNIT_EXITED_VEHICLE") then
		if(... == "player") then
			AdjustCastBars()
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
		CastingBarFrame.timer:SetPoint("RIGHT", CastingBarFrame, "LEFT", -10, 2)
		CastingBarFrame.update = 0.1
	end
end

local function Init()
	CastBars:SetScript("OnEvent", HandleEvents)

	-- REGISTER ALL EVENTS
	CastBars:RegisterEvent("PLAYER_ENTERING_WORLD")
	CastBars:RegisterEvent("PLAYER_TALENT_UPDATE")
	CastBars:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	CastBars:RegisterEvent("UNIT_EXITED_VEHICLE")
	CastBars:RegisterEvent("ADDON_LOADED")
end

-- REPOSITON STUFF AFTER THE BLIZZARD UI FUCKS WITH THEM
local function MainMenuBar_UpdateExperienceBars_Hook(newLevel)
	AdjustCastBars()
end

-- REPOSITON STUFF AFTER THE BLIZZARD UI FUCKS WITH THEM
local function MainMenuBarVehicleLeaveButton_Update_Hook()
	AdjustCastBars()
end

-- DISPLAYS THE CASTING BAR TIMER
CastingBarFrame:HookScript("OnUpdate", function(self, elapsed)
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
end)

Init()