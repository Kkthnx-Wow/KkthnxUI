local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local _G = _G

local CreateFrame = _G.CreateFrame

-- Achievement screenshot
function Module:ScreenShotOnEvent()
	Module.ScreenShotFrame.delay = 1
	Module.ScreenShotFrame:Show()
end

function Module:CreateAutoScreenShot()
	if not Module.ScreenShotFrame then
		Module.ScreenShotFrame = CreateFrame("Frame")
		Module.ScreenShotFrame:Hide()
		Module.ScreenShotFrame:SetScript("OnUpdate", function(self, elapsed)
			self.delay = self.delay - elapsed
			if self.delay < 0 then
				Screenshot()
				self:Hide()
			end
		end)
	end

	if C["Automation"].AutoScreenshot then
		K:RegisterEvent("ACHIEVEMENT_EARNED", Module.ScreenShotOnEvent)
	else
		Module.ScreenShotFrame:Hide()
		K:UnregisterEvent("ACHIEVEMENT_EARNED", Module.ScreenShotOnEvent)
	end
end