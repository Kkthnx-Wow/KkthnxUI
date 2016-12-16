local K, C, L = unpack(select(2, ...))
if C.Automation.ScreenShot ~= true then return end

-- Wow API
local C_Timer = C_Timer
local Screenshot = Screenshot

-- Take screenshots of defined events (Sinaris)
local function OnEvent(self, event, ...)
	C_Timer.After(1, function() Screenshot() end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ACHIEVEMENT_EARNED")
frame:SetScript("OnEvent", OnEvent)