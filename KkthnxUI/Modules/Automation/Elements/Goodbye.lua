local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

local C_Timer_After = C_Timer.After

-- Random list of auto-thanks messages
local AutoThanksList = {
	L["Farewell friends, until we meet again."],
	L["Goodbye and may your journey be filled with success."],
	L["Goodbye and safe travels."],
	L["I had a great time, thanks and take care."],
	L["It was a pleasure playing with you all, farewell."],
	L["It's been an honor, goodbye and happy questing."],
	L["It's been real, goodbye and have a great day."],
	L["Thanks for the adventure, farewell."],
	L["Thanks for the good times, farewell and good luck."],
	L["Thanks for the memories, farewell."],
	"Appreciate the dungeon! Great job.",
	"Appreciate the run! Well played.",
	"Big thanks for the adventure. Well done.",
	"Big thanks for the dungeon, team! Solid effort.",
	"Cheers for the run! Thank you.",
	"Shoutout for the teamwork. Much appreciated.",
	"Thank you, everyone! Great run.",
	"Thanks for the run! You all were fantastic.",
	"Thanks! That was awesome.",
	"Thanks! You all rocked it.",
}

local function SendAutoGoodbyeMessage()
	local messageIndex = math.random(#AutoThanksList)
	local message = AutoThanksList[messageIndex]

	if message then
		local channel = IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and "INSTANCE_CHAT" or IsInGroup() and "PARTY" or "SAY"

		SendChatMessage(message, channel)
	end
end

local function SetupAutoGoodbye()
	C_Timer_After(math.random(2, 5), SendAutoGoodbyeMessage)
end

function Module:CreateAutoGoodbye()
	if C["Automation"].AutoGoodbye then
		K:RegisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye)
		K:RegisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye)
	else
		K:UnregisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye)
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye)
	end
end
