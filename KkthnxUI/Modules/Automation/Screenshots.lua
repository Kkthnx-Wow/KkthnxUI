local K, C, L = select(2, ...):unpack()
if C.Automation.ScreenShot ~= true then return end

-- Wow API
local CreateFrame = CreateFrame

-- TAKE SCREENSHOTS OF DEFINED EVENTS (SINARIS)
local function OnEvent(self, event, ...)
	C_Timer.After(1, function() Screenshot() end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ACHIEVEMENT_EARNED")
frame:SetScript("OnEvent", OnEvent)