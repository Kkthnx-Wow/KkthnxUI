local K, C, L = unpack(select(2, ...))
if C.Automation.ScreenShot ~= true then return end

-- Wow API
local C_Timer_After = C_Timer.After
local Screenshot = Screenshot

-- Take screenshots of defined events (Sinaris)
local function OnEvent(self, event, ...)
	C_Timer_After(1, function() Screenshot() end)
end

local AScreenShot = CreateFrame("Frame")
AScreenShot:RegisterEvent("ACHIEVEMENT_EARNED")
AScreenShot:SetScript("OnEvent", OnEvent)