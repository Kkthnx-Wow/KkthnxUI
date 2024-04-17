local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local AcceptResurrect = AcceptResurrect
local C_Timer_After = C_Timer.After
local DoEmote = DoEmote
local StaticPopup_Hide = StaticPopup_Hide
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local IsActiveBattlefieldArena = IsActiveBattlefieldArena

local localizedPylonNames = {
	enUS = "Failure Detection Pylon",
	zhCN = "故障检测晶塔",
	zhTW = "滅團偵測水晶塔",
	ruRU = "Пилон для обнаружения проблем",
	koKR = "고장 감지 변환기",
	esMX = "Pilón detector de errores",
	ptBR = "Pilar Detector de Falhas",
	deDE = "Fehlschlagdetektorpylon",
	esES = "Pilón detector de errores",
	frFR = "Pylône de détection des échecs",
	itIT = "Pilone d'Individuazione Fallimenti",
}
local localizedBrazierNames = {
	enUS = "Brazier of Awakening",
	zhCN = "觉醒火盆",
	zhTW = "覺醒火盆",
	ruRU = "Жаровня пробуждения",
	koKR = "각성의 화로",
	esMX = "Blandón del Despertar",
	ptBR = "Braseiro do Despertar",
	deDE = "Kohlenbecken des Erwachens",
	esES = "Blandón de Despertar",
	frFR = "Brasero de l'Éveil",
	itIT = "Braciere del Risveglio",
}

local function SetupAutoResurrect(_, arg1)
	-- Check if the arg1 is a Pylon or Brazier by comparing it to the localized names.
	-- If it is, we don't need to do anything and we return
	if localizedPylonNames[K.Client] == arg1 or localizedBrazierNames[K.Client] == arg1 then
		return
	end

	-- Check if the player is in combat
	if not UnitAffectingCombat(arg1) then
		-- If not in combat, accept the resurrect and hide the "RESURRECT_NO_TIMER" popup
		AcceptResurrect()
		StaticPopup_Hide("RESURRECT_NO_TIMER")

		-- Check if the user has AutoResurrectThank enabled in the settings
		if not C["Automation"].AutoResurrectThank then
			return
		end

		-- Wait 3 seconds and then check if the player is alive or not
		C_Timer_After(3, function()
			-- Give this more time to say thanks.
			if not UnitIsDeadOrGhost("player") then
				-- If player is alive, do the "thank" emote to the arg1
				DoEmote("thank", arg1)
			end
		end)
	end
end

function Module:CreateAutoResurrect()
	-- Check if the player is in a battleground or arena and if player is dead or ghost
	if IsActiveBattlefieldArena() and UnitIsDeadOrGhost("player") then
		-- Check the value of AutoResurrect
		if C["Automation"].AutoResurrect then
			-- Register the event
			K:RegisterEvent("RESURRECT_REQUEST", SetupAutoResurrect)
		end
	end
end
