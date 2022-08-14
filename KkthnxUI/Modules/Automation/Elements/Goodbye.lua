local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local _G = _G
local math_random = _G.math.random

local C_Timer_After = _G.C_Timer.After
local SendChatMessage = _G.SendChatMessage

local AutoThanksList = {
	"GG! Thanks for the run.",
	"GLHF! Thanks everyone.",
	"Good run everyone.",
	"Much appreciated.",
	"Thanks everyone!",
	"Thanks for the group.",
	"Thanks for the run.",
	"Thanks! Take care everyone.",
}

function Module:SetupAutoGoodbye()
	C_Timer_After(6, function() -- Give this more time to say thanks.
		SendChatMessage(AutoThanksList[math_random(1, #AutoThanksList)], IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID")
	end)
end

function Module:CreateAutoGoodbye()
	if not C["Automation"].AutoGoodbye then
		return
	end

	K:RegisterEvent("LFG_COMPLETION_REWARD", Module.SetupAutoGoodbye)
	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", Module.SetupAutoGoodbye)
end
