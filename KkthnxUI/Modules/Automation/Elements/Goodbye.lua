-- Cache globals / tables locally for performance
local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- Lua / WoW API locals
local math_random = math.random
local GetLocale = GetLocale
local GetInstanceInfo = GetInstanceInfo
local GetTime = GetTime
local IsInGroup = IsInGroup
local IsPartyLFG = IsPartyLFG
local C_PartyInfo_IsPartyWalkIn = C_PartyInfo.IsPartyWalkIn
local C_Timer_After = C_Timer.After
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

-- Pre-resolve locale goodbye list once
local locale = GetLocale()
local AutoGoodbyeList = AutoGoodbyeMessages[locale] or AutoGoodbyeMessages["enUS"]

-- Anti-spam timestamp + "are we already waiting to send?"
local lastGoodbyeAt = 0
local pendingGoodbye = false

-- tiny helper: are we in an instance & what channel would we use?
local function GetGroupChannel()
	-- Must still be in an instance and in group when we ACTUALLY speak
	local _, instanceType = GetInstanceInfo()
	if not instanceType or instanceType == "none" then
		return nil
	end

	if not IsInGroup() then
		return nil
	end

	local inPartyLFG = IsPartyLFG() and not C_PartyInfo_IsPartyWalkIn()
	if inPartyLFG then
		return "INSTANCE_CHAT"
	else
		return "PARTY"
	end
end

-- final sender (runs AFTER the delay)
local function SendAutoGoodbyeMessage()
	pendingGoodbye = false -- timer fired, clear guard

	-- rate limit: don't spam multiple in <8s
	local now = GetTime() or 0
	if now > 0 and (now - lastGoodbyeAt) < 8 then
		return
	end

	-- make sure we still have something to say
	if not AutoGoodbyeList or #AutoGoodbyeList == 0 then
		return
	end

	-- make sure it's still appropriate to speak
	local channel = GetGroupChannel()
	if not channel then
		return
	end

	-- pick random line
	local msg = AutoGoodbyeList[math_random(#AutoGoodbyeList)]
	if not msg then
		return
	end

	SendChatMessage(msg, channel)
	lastGoodbyeAt = now
end

-- schedules the goodbye with a random delay (2-5s),
-- but won't stack multiple timers if events fire twice
local function SetupAutoGoodbye()
	-- if one is already enqueued, don't queue another
	if pendingGoodbye then
		return
	end

	-- you COULD early-return if not in group/instance yet,
	-- but I prefer to re-check at send time instead,
	-- in case you're technically still "inside" the runout phase.
	pendingGoodbye = true

	local delay = math_random(2, 5)
	C_Timer_After(delay, SendAutoGoodbyeMessage)
end

-- public API toggle
function Module:CreateAutoGoodbye()
	if C["Automation"].AutoGoodbye then
		K:RegisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye)
		K:RegisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye)
	else
		K:UnregisterEvent("LFG_COMPLETION_REWARD", SetupAutoGoodbye)
		K:UnregisterEvent("CHALLENGE_MODE_COMPLETED", SetupAutoGoodbye)
	end
end
