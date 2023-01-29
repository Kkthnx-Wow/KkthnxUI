local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local math_random = math.random

local C_Timer_After = C_Timer.After
local SendChatMessage = SendChatMessage

-- This list is completely random. There is no certin way we have made this list.
-- The idea is to keep things random so we do not repeat the same type of goodbye.
local AutoThanksList = {
	L["Goodbye and safe travels."],
	L["It was a pleasure playing with you all, farewell."],
	L["I had a great time, thanks and take care."],
	L["Farewell friends, until we meet again."],
	L["Thanks for the adventure, farewell."],
	L["It's been real, goodbye and have a great day."],
	L["Thanks for the memories, farewell."],
	L["Goodbye and may your journey be filled with success."],
	L["Thanks for the good times, farewell and good luck."],
	L["It's been an honor, goodbye and happy questing."],
}

function Module.SetupAutoGoodbye()
	local randomWaitTime = math.random(2, 5) -- Random the amount of time to wait to say thanks
	C_Timer_After(randomWaitTime, function()
		local randomThanksMessage = AutoThanksList[math_random(1, #AutoThanksList)] -- Choose a random message from the list of messages
		SendChatMessage(randomThanksMessage, "INSTANCE_CHAT") -- Always INSTANCE_CHAT
	end)
end

function Module:CreateAutoGoodbye()
	if not C["Automation"].AutoGoodbye then
		return
	end

	K:RegisterEvent("LFG_COMPLETION_REWARD", Module.SetupAutoGoodbye)
	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", Module.SetupAutoGoodbye)
end
