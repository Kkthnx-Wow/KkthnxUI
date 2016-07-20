local K, C, L, _ = select(2, ...):unpack()
if C.Automation.ScreenShot ~= true then return end

local CreateFrame = CreateFrame

local function OnEvent(self, event, ...)
	K.Delay(1, function() Screenshot() end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ACHIEVEMENT_EARNED")
frame:SetScript("OnEvent", OnEvent)