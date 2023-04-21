local K = KkthnxUI[1]
local Module = K:NewModule("Automation")

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

function Module:OnEnable()
	for _, funcName in ipairs(loadAutomationModules) do
		if self[funcName] then
			self[funcName](self)
		end
	end
end
