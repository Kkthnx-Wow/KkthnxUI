local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

local C_Timer_After = C_Timer.After

-- This list is completely random. There is no certain way we have made this list.
-- The idea is to keep things random so we do not repeat the same type of goodbye.
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

	-- WE ARE TESTING THESE TO SEE IF THEY GET FEEDBACK IN GROUPS, WE DO NOT WANNA BE CALLED A BOT :D
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

local function SetupAutoGoodbye()
	local waitTime = math.random() * (5 - 2) + 2 -- generates a float between 2 and 5
	C_Timer_After(waitTime, function()
		if #AutoThanksList > 0 then
			local messageIndex = math.random(#AutoThanksList)
			local message = AutoThanksList[messageIndex]

			if message then
				local channel
				if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
					channel = "INSTANCE_CHAT"
				elseif IsInGroup() then
					channel = "PARTY"
				else
					channel = "SAY"
				end

				SendChatMessage(message, channel)
			end
		else
			print("AutoThanksList is empty? Tell Kkthnx") -- Debugging statement
		end
	end)
end

function Module:CreateAutoGoodbye()
	if C["Automation"].AutoGoodbye then
		-- Register the events when the feature is enabled
		K:RegisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye) -- Using local function
		K:RegisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye) -- Using local function
	else
		-- Unregister the events when the feature is disabled
		K:UnregisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye) -- Using local function
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye) -- Using local function
	end
end
