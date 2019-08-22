local _G = _G
local K, C = _G.unpack(_G.select(2, ...))
local Module = K:GetModule("Automation")

local C_Timer_After = C_Timer.After
local Screenshot = Screenshot

-- Take screenshots of defined events (Sinaris)
function Module.TakeScreenshot()
	C_Timer_After(1.2, function()
		Screenshot()
	end)
end

function Module:CreateAutoScreenshot()
	if C["Automation"].ScreenShot ~= true then
		return
	end

	K:RegisterEvent("ACHIEVEMENT_EARNED", self.TakeScreenshot)
	K:RegisterEvent("SHOW_LOOT_TOAST_LEGENDARY_LOOTED", self.TakeScreenshot)
end
