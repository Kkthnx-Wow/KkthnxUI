local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Cache global references locally
local CreateFrame = CreateFrame
local Screenshot = Screenshot

-- Achievement screenshot
local ScreenShotFrame

local function ScreenShotOnEvent(_, _, alreadyEarned)
	if alreadyEarned then
		return
	end

	ScreenShotFrame.delay = 1
	ScreenShotFrame:Show()
end

local function OnUpdate(self, elapsed)
	self.delay = self.delay - elapsed
	if self.delay < 0 then
		Screenshot()
		self:Hide()
	end
end

function Module:CreateAutoScreenshot()
	if not ScreenShotFrame then
		ScreenShotFrame = CreateFrame("Frame")
		ScreenShotFrame:Hide()
		ScreenShotFrame:SetScript("OnUpdate", OnUpdate)
	end

	if C["Automation"].AutoScreenshot then
		K:RegisterEvent("ACHIEVEMENT_EARNED", ScreenShotOnEvent)
	else
		ScreenShotFrame:Hide()
		K:UnregisterEvent("ACHIEVEMENT_EARNED", ScreenShotOnEvent)
	end
end
