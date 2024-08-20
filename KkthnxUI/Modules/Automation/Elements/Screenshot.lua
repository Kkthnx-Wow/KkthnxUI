local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Function to handle the "ACHIEVEMENT_EARNED" event
local function onAchievementEarned()
	C_Timer.After(1, Screenshot)
end

-- Function to initialize the AutoScreenshot feature
function Module:CreateAutoScreenshot()
	if C["Automation"].AutoScreenshot then
		K:RegisterEvent("ACHIEVEMENT_EARNED", onAchievementEarned)
	else
		K:UnregisterEvent("ACHIEVEMENT_EARNED", onAchievementEarned)
	end
end
