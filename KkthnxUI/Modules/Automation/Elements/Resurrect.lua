--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically accepts resurrection requests from other players.
-- - Design: Hooks RESURRECT_REQUEST and checks if the player is in combat and if the source is on a blacklist.
-- - Events: RESURRECT_REQUEST
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local AcceptResurrect = AcceptResurrect
local DoEmote = DoEmote
local StaticPopup_Hide = StaticPopup_Hide
local UnitAffectingCombat = UnitAffectingCombat
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------
-- REASON: Blacklist for specific utility items that should not trigger auto-acceptance.
local PYLON_NAMES = {
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

local BRAZIER_NAMES = {
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

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function handleAutoResurrect(_, inviterName)
	local clientLocale = K.Client

	-- REASON: Ignore requests from automated pylon/brazier items to allow for strategic resurrection.
	if PYLON_NAMES[clientLocale] == inviterName or BRAZIER_NAMES[clientLocale] == inviterName then
		return
	end

	-- REASON: Only auto-accept if not in combat to prevent taking a 'death' during active boss encounters.
	if not UnitAffectingCombat("player") then
		AcceptResurrect()
		StaticPopup_Hide("RESURRECT_NO_TIMER")

		-- REASON: Automated social interaction if configured by the user.
		if C["Automation"].AutoResurrectThank then
			K.Delay(3, function()
				if not UnitIsDeadOrGhost("player") then
					DoEmote("thank", inviterName)
				end
			end)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoResurrect()
	-- REASON: Feature entry point; registers for resurrection request events.
	if C["Automation"].AutoResurrect then
		K:RegisterEvent("RESURRECT_REQUEST", handleAutoResurrect)
	else
		K:UnregisterEvent("RESURRECT_REQUEST", handleAutoResurrect)
	end
end
