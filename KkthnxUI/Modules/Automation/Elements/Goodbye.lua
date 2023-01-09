local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local _G = _G
local math_random = _G.math.random

local C_Timer_After = _G.C_Timer.After
local SendChatMessage = _G.SendChatMessage

-- This list is completely random. There is no certin way we have made this list.
-- The idea is to keep things random so we do not repeat the same type of goodbye.
local AutoThanksList = {
	"Bye <3",
	"Bye",
	"Catch you on the flip side!",
	"Fare Thee Well",
	"Farewell.",
	"GG!",
	"GG",
	"Goodbye",
	"Have a good one!",
	"Have a nice day!",
	"Take care.",
	"Take it easy",
	"Thanks & warm regards",
	"Thanks :D",
	"Thanks ;)",
	"Thanks <3",
	"Thanks all",
	"Thanks everyone.",
	"Thanks for the group.",
	"Thanks for the run.",
	"Thanks, goodbye.",
	"Thanks, take care everyone.",
	"Until next time!",
	"farewell.",
	"gg!",
	"gg",
	"goodbye",
	"thanks",
}

function Module.SetupAutoGoodbye()
	C_Timer_After(math.random(2, 6), function() -- Random the amount of time to wait to say thanks
		SendChatMessage(AutoThanksList[math_random(1, #AutoThanksList)], "INSTANCE_CHAT") -- Always INSTANCE_CHAT
	end)
end

function Module:CreateAutoGoodbye()
	if not C["Automation"].AutoGoodbye then
		return
	end

	K:RegisterEvent("LFG_COMPLETION_REWARD", Module.SetupAutoGoodbye)
	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", Module.SetupAutoGoodbye)
end
