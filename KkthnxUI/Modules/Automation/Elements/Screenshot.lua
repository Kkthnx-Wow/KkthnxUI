local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Variables to store the screenshot frame and its state
local screenshotFrame

-- Function to handle the "ACHIEVEMENT_EARNED" event
local function onAchievementEarned()
	-- Set the delay for taking the screenshot to 1 second
	screenshotFrame.delay = 1
	-- Show the screenshot frame
	screenshotFrame:Show()
end

-- Function to handle the OnUpdate event of the screenshot frame
local function onUpdate(self, elapsed)
	-- Check if self.delay is not nil
	if self.delay then
		-- Decrement the delay by the elapsed time
		self.delay = self.delay - elapsed
		-- If the delay has elapsed
		if self.delay < 0 then
			-- Take a screenshot
			Screenshot()
			-- Hide the screenshot frame
			self:Hide()
		end
	end
end

-- Function to create the screenshot frame and handle its visibility
function Module:CreateAutoScreenshot()
	-- If the screenshot frame does not exist, create it
	if not screenshotFrame then
		screenshotFrame = CreateFrame("Frame")
		screenshotFrame:Hide()
		screenshotFrame:SetScript("OnUpdate", onUpdate)
	end

	-- If the AutoScreenshot option is enabled in the C table
	if C["Automation"].AutoScreenshot then
		-- Register the "ACHIEVEMENT_EARNED" event to take a screenshot
		K:RegisterEvent("ACHIEVEMENT_EARNED", onAchievementEarned)
		-- Show the screenshot frame
		screenshotFrame:Show()
	else
		-- Unregister the "ACHIEVEMENT_EARNED" event
		K:UnregisterEvent("ACHIEVEMENT_EARNED", onAchievementEarned)
		-- Hide the screenshot frame
		screenshotFrame:Hide()
	end
end
