local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local AcceptResurrect = AcceptResurrect
local DoEmote = DoEmote
local StaticPopup_Hide = StaticPopup_Hide
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

-- Localized names for specific items
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

local function HandleAutoResurrect(event, arg1)
	local clientLocale = K.Client
	-- Ignore resurrection requests from specific items
	if localizedPylonNames[clientLocale] == arg1 or localizedBrazierNames[clientLocale] == arg1 then
		return
	end

	-- Accept resurrection if not in combat
	if not UnitAffectingCombat("player") then
		AcceptResurrect()
		StaticPopup_Hide("RESURRECT_NO_TIMER")

		-- Optionally thank the resurrector
		if C["Automation"].AutoResurrectThank then
			K.Delay(3, function()
				if not UnitIsDeadOrGhost("player") then
					DoEmote("thank", arg1)
				end
			end)
		end
	end
end

function Module:CreateAutoResurrect()
	if C["Automation"].AutoResurrect then
		K:RegisterEvent("RESURRECT_REQUEST", HandleAutoResurrect)
	else
		K:UnregisterEvent("RESURRECT_REQUEST", HandleAutoResurrect)
	end
end
