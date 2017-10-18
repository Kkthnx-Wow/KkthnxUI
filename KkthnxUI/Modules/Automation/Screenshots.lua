local K, C, L = unpack(select(2, ...))
if C["Automation"].ScreenShot ~= true then return end

-- Wow API
local C_Timer_After = C_Timer.After
local Screenshot = Screenshot

-- Take screenshots of defined events (Sinaris)
local function TakeScreenshot(self, event, ...)
	C_Timer_After(1.2, function() Screenshot() end)
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("ACHIEVEMENT_EARNED")
Loading:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED")
Loading:SetScript("OnEvent", TakeScreenshot)