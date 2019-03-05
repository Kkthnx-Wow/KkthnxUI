local K, C, L = unpack(select(2, ...))
if C["Automation"].ScreenShot ~= true then 
	return 
end

local Module = K:NewModule("AutoScreenShot", "AceEvent-3.0")

local C_Timer_After = C_Timer.After
local Screenshot = Screenshot

-- Take screenshots of defined events (Sinaris)
function Module:TakeScreenshot(event, ...)
	C_Timer_After(1.2, function() 
		Screenshot() 
	end)
end

function Module:OnEnable()
	self:RegisterEvent("ACHIEVEMENT_EARNED", "TakeScreenshot")
	self:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED", "TakeScreenshot")
end
