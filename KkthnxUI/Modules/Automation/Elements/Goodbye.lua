local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- Local references for global functions
local math_random = math.random
local IsInGroup = IsInGroup
local SendChatMessage = SendChatMessage

-- Random list of auto-goodbye messages for different locales
local AutoGoodbyeMessages = {
	enUS = {
		"GG",
		"GG :D",
		"GG, everyone!",
		"Thanks all!",
		"Thanks, everyone :)",
		"GG and thanks!",
		"Cheers, everyone!",
		"GG, folks!",
		"Thank you all!",
		"GG, appreciate it!",
	},
	deDE = {
		"GG",
		"GG :D",
		"GG, alle zusammen!",
		"Danke an alle!",
		"Danke, alle zusammen :)",
		"GG und danke!",
		"Prost, alle zusammen!",
		"GG, Leute!",
		"Vielen Dank an alle!",
		"GG, ich schätze es!",
	},
	esMX = {
		"GG",
		"GG :D",
		"GG, todos!",
		"Gracias a todos!",
		"Gracias, todos :)",
		"GG y gracias!",
		"Salud, todos!",
		"GG, amigos!",
		"Gracias a todos!",
		"GG, lo aprecio!",
	},
	frFR = {
		"GG",
		"GG :D",
		"GG, tout le monde!",
		"Merci à tous!",
		"Merci, tout le monde :)",
		"GG et merci!",
		"À la vôtre, tout le monde!",
		"GG, les amis!",
		"Merci à tous!",
		"GG, je l'apprécie!",
	},
	itIT = {
		"GG",
		"GG :D",
		"GG, tutti!",
		"Grazie a tutti!",
		"Grazie, tutti :)",
		"GG e grazie!",
		"Salute, tutti!",
		"GG, amici!",
		"Grazie a tutti!",
		"GG, lo apprezzo!",
	},
	koKR = {
		"GG",
		"GG :D",
		"GG, 모두!",
		"모두 감사합니다!",
		"감사합니다, 모두 :)",
		"GG와 감사합니다!",
		"건배, 모두!",
		"GG, 여러분!",
		"모두 감사합니다!",
		"GG, 감사합니다!",
	},
	ptBR = {
		"GG",
		"GG :D",
		"GG, pessoal!",
		"Obrigado a todos!",
		"Obrigado, pessoal :)",
		"GG e obrigado!",
		"Saúde, pessoal!",
		"GG, amigos!",
		"Obrigado a todos!",
		"GG, agradeço!",
	},
	ruRU = {
		"GG",
		"GG :D",
		"GG, все!",
		"Спасибо всем!",
		"Спасибо, все :)",
		"GG и спасибо!",
		"За здоровье, все!",
		"GG, ребята!",
		"Спасибо всем!",
		"GG, благодарю!",
	},
	trTR = {
		"GG",
		"GG :D",
		"GG, herkes!",
		"Herkese teşekkürler!",
		"Teşekkürler, herkes :)",
		"GG ve teşekkürler!",
		"Şerefe, herkes!",
		"GG, arkadaşlar!",
		"Herkese teşekkürler!",
		"GG, takdir ediyorum!",
	},
	zhCN = {
		"GG",
		"GG :D",
		"GG, 大家!",
		"谢谢大家!",
		"谢谢, 大家 :)",
		"GG和谢谢!",
		"干杯, 大家!",
		"GG, 朋友们!",
		"谢谢大家!",
		"GG, 感谢!",
	},
	zhTW = {
		"GG",
		"GG :D",
		"GG, 大家!",
		"謝謝大家!",
		"謝謝, 大家 :)",
		"GG和謝謝!",
		"乾杯, 大家!",
		"GG, 朋友們!",
		"謝謝大家!",
		"GG, 感謝!",
	},
}

local locale = GetLocale()
local AutoGoodbyeList = AutoGoodbyeMessages[locale] or AutoGoodbyeMessages["enUS"]
local lastGoodbyeAt = 0

local function SendAutoGoodbyeMessage()
	local _, instanceType = GetInstanceInfo()
	if not instanceType or instanceType == "none" then
		return -- Exit if not in an instance
	end

	local now = GetTime and GetTime() or 0
	if now > 0 and (now - lastGoodbyeAt) < 8 then
		return
	end
	if not AutoGoodbyeList or #AutoGoodbyeList == 0 then
		return -- Exit if the list is nil or empty
	end

	local message = AutoGoodbyeList[math_random(#AutoGoodbyeList)]

	local channel
	local inPartyLFG = IsPartyLFG() and not C_PartyInfo.IsPartyWalkIn()
	if IsInGroup() then
		channel = inPartyLFG and "INSTANCE_CHAT" or "PARTY"
	else
		return -- Exit if not in a party or instance group
	end

	if message then
		SendChatMessage(message, channel)
		lastGoodbyeAt = now
	end
end

-- Setup delayed goodbye message
local function SetupAutoGoodbye()
	local delay = math_random(2, 5)
	C_Timer.After(delay, SendAutoGoodbyeMessage)
end

-- Create or disable Auto Goodbye feature
function Module:CreateAutoGoodbye()
	if C["Automation"].AutoGoodbye then
		K:RegisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye)
		K:RegisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye)
	else
		K:UnregisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye)
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye)
	end
end
