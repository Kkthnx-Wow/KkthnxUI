local K, C, L = unpack(select(2, ...))
if C["Automation"].AutoResurrect ~= true then return end

-- Lua API
local _G = _G

-- Wow API
local UnitAffectingCombat = _G.UnitAffectingCombat
local AcceptResurrect = _G.AcceptResurrect
local C_Timer_After = _G.C_Timer.After
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local DoEmote = _G.DoEmote

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: StaticPopup_Hide

local AutoResurrect = CreateFrame("Frame")
AutoResurrect:RegisterEvent("RESURRECT_REQUEST")
AutoResurrect:SetScript("OnEvent", function(self, event, who, ...)
	if event == "RESURRECT_REQUEST" then
		if ((UnitAffectingCombat(who)) and C["Automation"].AutoResurrectCombat == false) or not (UnitAffectingCombat(who)) then
			AcceptResurrect()
			StaticPopup_Hide("RESURRECT_NO_TIMER")
			if C["Automation"].AutoResurrectThank then
				C_Timer_After(1, function()
					if not UnitIsDeadOrGhost("player") then
						DoEmote("thank", who)
					end
				end)
			end
		end
		return
	end
end)