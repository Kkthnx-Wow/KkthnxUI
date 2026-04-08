--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically takes a screenshot when the player earns a new achievement.
-- - Design: Hooks ACHIEVEMENT_EARNED and uses a hidden frame's OnUpdate to introduce a slight delay.
-- - Events: ACHIEVEMENT_EARNED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local CreateFrame = CreateFrame
local Screenshot = Screenshot

-- ---------------------------------------------------------------------------
-- State
-- ---------------------------------------------------------------------------
local screenShotFrame

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function onUpdate(self, elapsed)
	-- REASON: Introduces a 1-second delay to allow the achievement toast to fully display before capturing.
	self.delay = self.delay - elapsed
	if self.delay < 0 then
		Screenshot()
		self:Hide()
	end
end

local function screenshotOnEvent(_, alreadyEarned)
	-- REASON: Only take screenshots for achievements earned for the first time by the character/account.
	if alreadyEarned then
		return
	end

	if not screenShotFrame then
		screenShotFrame = CreateFrame("Frame")
		screenShotFrame:Hide()
		screenShotFrame:SetScript("OnUpdate", onUpdate)
	end

	screenShotFrame.delay = 1
	screenShotFrame:Show()
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoScreenshot()
	-- REASON: Feature entry point; registers for achievement events based on user configuration.
	if C["Automation"].AutoScreenshot then
		K:RegisterEvent("ACHIEVEMENT_EARNED", screenshotOnEvent)
	else
		if screenShotFrame then
			screenShotFrame:Hide()
		end
		K:UnregisterEvent("ACHIEVEMENT_EARNED", screenshotOnEvent)
	end
end
