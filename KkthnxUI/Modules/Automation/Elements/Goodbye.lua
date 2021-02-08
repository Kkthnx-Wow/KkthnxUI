local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G
local math_random = _G.math.random

local C_Timer_After = _G.C_Timer.After
local SendChatMessage = _G.SendChatMessage

local AutoThankList = {
	"GG!",
	"GLHF!",
	"Good run!",
	"Job well done!",
	"Thanks all!",
	"Thanks everyone!",
	"Thanks for the group!",
	"That was fun. Take care everyone!",
}

function Module:SetupAutoGoodbye()
	C_Timer_After(4, function()
		SendChatMessage(AutoThankList[math_random(1, #AutoThankList)], "INSTANCE_CHAT")
	end)
end

function Module:CreateAutoGoodbye()
	if not C["Automation"].AutoGoodbye then
		return
	end

	K:RegisterEvent("LFG_COMPLETION_REWARD", Module.SetupAutoGoodbye)
	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", Module.SetupAutoGoodbye)
end