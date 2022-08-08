local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local _G = _G

local AcceptResurrect = _G.AcceptResurrect
local C_Timer_After = _G.C_Timer.After
local DoEmote = _G.DoEmote
local StaticPopup_Hide = _G.StaticPopup_Hide
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost

function Module.SetupAutoResurrect(_, arg1)
	-- Exclude pylon and brazier requests
	local pylonLoc

	-- Exclude Failure Detection Pylon
	pylonLoc = "Failure Detection Pylon"
	if K.Client == "zhCN" then
		pylonLoc = "故障检测晶塔"
	elseif K.Client == "zhTW" then
		pylonLoc = "滅團偵測水晶塔"
	elseif K.Client == "ruRU" then
		pylonLoc = "Пилон для обнаружения проблем"
	elseif K.Client == "koKR" then
		pylonLoc = "고장 감지 변환기"
	elseif K.Client == "esMX" then
		pylonLoc = "Pilón detector de errores"
	elseif K.Client == "ptBR" then
		pylonLoc = "Pilar Detector de Falhas"
	elseif K.Client == "deDE" then
		pylonLoc = "Fehlschlagdetektorpylon"
	elseif K.Client == "esES" then
		pylonLoc = "Pilón detector de errores"
	elseif K.Client == "frFR" then
		pylonLoc = "Pylône de détection des échecs"
	elseif K.Client == "itIT" then
		pylonLoc = "Pilone d'Individuazione Fallimenti"
	end
	if arg1 == pylonLoc then
		return
	end

	-- Exclude Brazier of Awakening
	pylonLoc = "Brazier of Awakening"
	if K.Client == "zhCN" then
		pylonLoc = "觉醒火盆"
	elseif K.Client == "zhTW" then
		pylonLoc = "覺醒火盆"
	elseif K.Client == "ruRU" then
		pylonLoc = "Жаровня пробуждения"
	elseif K.Client == "koKR" then
		pylonLoc = "각성의 화로"
	elseif K.Client == "esMX" then
		pylonLoc = "Blandón del Despertar"
	elseif K.Client == "ptBR" then
		pylonLoc = "Braseiro do Despertar"
	elseif K.Client == "deDE" then
		pylonLoc = "Kohlenbecken des Erwachens"
	elseif K.Client == "esES" then
		pylonLoc = "Blandón de Despertar"
	elseif K.Client == "frFR" then
		pylonLoc = "Brasero de l'Éveil"
	elseif K.Client == "itIT" then
		pylonLoc = "Braciere del Risveglio"
	end
	if arg1 == pylonLoc then
		return
	end

	-- Manage other resurrection requests
	if not UnitAffectingCombat(arg1) then
		AcceptResurrect()
		StaticPopup_Hide("RESURRECT_NO_TIMER")

		if not C["Automation"].AutoResurrectThank then
			return
		end

		C_Timer_After(3, function() -- Give this more time to say thanks.
			if not UnitIsDeadOrGhost("player") then
				DoEmote("thank", arg1)
			end
		end)
	end
end

function Module:CreateAutoResurrect()
	if not C["Automation"].AutoResurrect then
		return
	end

	K:RegisterEvent("RESURRECT_REQUEST", Module.SetupAutoResurrect)
end
