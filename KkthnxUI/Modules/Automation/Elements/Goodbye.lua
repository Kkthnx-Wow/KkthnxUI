local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

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
	local waitTime = math.random() * (5 - 2) + 2 -- generates a float between 2 and 5
	C_Timer_After(waitTime, function()
		local messageIndex = math.random(#AutoThanksList)
		local message = AutoThanksList[messageIndex]
		table.remove(AutoThanksList, messageIndex)

		if message then
			C_ChatInfo.SendAddonMessage("KkthnxUI", message, "INSTANCE_CHAT")
		end
	end)
end

function Module:CreateAutoGoodbye()
	if not C["Automation"].AutoGoodbye then
		return
	end

	K:RegisterEvent("LFG_COMPLETION_REWARD", Module.SetupAutoGoodbye)
	K:RegisterEvent("CHALLENGE_MODE_COMPLETED", Module.SetupAutoGoodbye)
	K:RegisterEvent("CHAT_MSG_INSTANCE_CHAT", Module.SetupAutoGoodbye)
end
