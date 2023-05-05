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
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
