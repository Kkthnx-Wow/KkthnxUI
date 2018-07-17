local K, C, L = unpack(select(2, ...))
if C["Automation"].AutoResurrect ~= true then 
	return 
end

local Module = K:NewModule("AutoRelease", "AceEvent-3.0")

local _G = _G

local UnitAffectingCombat = _G.UnitAffectingCombat
local AcceptResurrect = _G.AcceptResurrect
local C_Timer_After = _G.C_Timer.After
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local DoEmote = _G.DoEmote

function Module:RESURRECT_REQUEST()
	-- Exclude pylon and brazier requests
	local pylonLoc
	
	-- Exclude Failure Detection Pylon
	pylonLoc = "Failure Detection Pylon"
	if GameLocale == "zhCN" then pylonLoc = "故障检测晶塔"
	elseif GameLocale == "zhTW" then pylonLoc = "滅團偵測水晶塔"
	elseif GameLocale == "ruRU" then pylonLoc = "Пилон для обнаружения проблем"
	elseif GameLocale == "koKR" then pylonLoc = "고장 감지 변환기"
	elseif GameLocale == "esMX" then pylonLoc = "Pilón detector de errores"
	elseif GameLocale == "ptBR" then pylonLoc = "Pilar Detector de Falhas"
	elseif GameLocale == "deDE" then pylonLoc = "Fehlschlagdetektorpylon"
	elseif GameLocale == "esES" then pylonLoc = "Pilón detector de errores"
	elseif GameLocale == "frFR" then pylonLoc = "Pylône de détection des échecs"
	elseif GameLocale == "itIT" then pylonLoc = "Pilone d'Individuazione Fallimenti"
	end
	
	if arg1 == pylonLoc then 
		return	
	end
	
	-- Exclude Brazier of Awakening
	pylonLoc = "Brazier of Awakening"
	if GameLocale == "zhCN" then pylonLoc = "觉醒火盆"
	elseif GameLocale == "zhTW" then pylonLoc = "覺醒火盆"
	elseif GameLocale == "ruRU" then pylonLoc = "Жаровня пробуждения"
	elseif GameLocale == "koKR" then pylonLoc = "각성의 화로"
	elseif GameLocale == "esMX" then pylonLoc = "Blandón del Despertar"
	elseif GameLocale == "ptBR" then pylonLoc = "Braseiro do Despertar"
	elseif GameLocale == "deDE" then pylonLoc = "Kohlenbecken des Erwachens"
	elseif GameLocale == "esES" then pylonLoc = "Blandón de Despertar"
	elseif GameLocale == "frFR" then pylonLoc = "Brasero de l'Éveil"
	elseif GameLocale == "itIT" then pylonLoc = "Braciere del Risveglio"
	end
	
	if arg1 == pylonLoc then 
		return	
	end
	
	-- Manage other resurrection requests
	if not UnitAffectingCombat(arg1) then
		AcceptResurrect()
		StaticPopup_Hide("RESURRECT_NO_TIMER")
		C_Timer_After(1, function()
			if not UnitIsDeadOrGhost("player") then
				DoEmote("thank", arg1)
			end
		end)
	end
	return
end

function Module:OnEnable()
	self:RegisterEvent("RESURRECT_REQUEST")
end