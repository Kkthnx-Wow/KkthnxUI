local K = KkthnxUI[1]
local Module = K:NewModule("Automation")

function Module:OnEnable()
	local loadAutomationModules = {
		"CreateAutoAcceptSummon",
		"CreateAutoBadBuffs",
		"CreateAutoBestReward",
		"CreateAutoDeclineDuels",
		"CreateAutoGoodbye",
		"CreateAutoInvite",
		"CreateAutoKeystone",
		"CreateAutoOpenItems",
		"CreateAutoPartySyncAccept",
		"CreateAutoRelease",
		"CreateAutoResurrect",
		"CreateAutoScreenshot",
		"CreateAutoSetRole",
		"CreateAutoWhisperInvite",
		"CreateSkipCinematic",
	}

	for _, funcName in ipairs(loadAutomationModules) do
		pcall(self[funcName], self)
	end
end
