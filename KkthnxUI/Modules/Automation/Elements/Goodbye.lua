local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- Local references for global functions
local math_random = math.random
local IsInGroup = IsInGroup
local SendChatMessage = SendChatMessage
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

-- Random list of auto-thanks messages
local AutoThanksList = {
	"GG, everyone!",
	"Thanks all!",
	"Thanks, everyone :)",
	"Appreciate it, all!",
	"GG and thanks!",
	"Solid run, thanks!",
	"Cheers, everyone!",
	"Thanks, y’all!",
	"Awesome run, thanks!",
	"GG, folks!",
	"Thanks so much, everyone!",
	"Good stuff, all!",
	"Thanks a ton!",
	"GG, that was fun!",
	"Great run, thanks!",
	"Thank you all!",
	"Nice run, everyone!",
	"GG, appreciate it!",
	"Big thanks, all!",
	"Thanks again, everyone!",
}

-- Send a goodbye message
local function SendAutoGoodbyeMessage()
	if not AutoThanksList or #AutoThanksList == 0 then
		return -- Exit if the list is nil or empty
	end

	-- Select a random message
	local message = AutoThanksList[math_random(#AutoThanksList)]

	-- Determine the chat channel
	local channel
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		channel = "INSTANCE_CHAT"
	elseif IsInGroup() then
		channel = "PARTY"
	else
		channel = "SAY"
	end

	-- Send the message
	if message then
		SendChatMessage(message, channel)
	end
end

-- Setup delayed goodbye message
local function SetupAutoGoodbye()
	K.Delay(math_random(2, 5), SendAutoGoodbyeMessage)
end

-- Create or disable Auto Goodbye feature
function Module:CreateAutoGoodbye()
	if C["Automation"].AutoGoodbye then
		-- Register events to trigger the goodbye message
		K:RegisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye)
		K:RegisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye)
	else
		-- Unregister events when the feature is disabled
		K:UnregisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye)
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye)
	end
end
