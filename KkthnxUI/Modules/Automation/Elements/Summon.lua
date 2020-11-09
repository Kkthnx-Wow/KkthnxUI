local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local C_SummonInfo_ConfirmSummon = _G.C_SummonInfo.ConfirmSummon
local C_SummonInfo_GetSummonConfirmAreaName = _G.C_SummonInfo.GetSummonConfirmAreaName
local C_SummonInfo_GetSummonConfirmSummoner = _G.C_SummonInfo.GetSummonConfirmSummoner
local C_Timer_After = _G.C_Timer.After
local StaticPopup_Hide = _G.StaticPopup_Hide
local UnitAffectingCombat = _G.UnitAffectingCombat

local function SetupAutoAcceptSummon()
	if not UnitAffectingCombat("player") then
		local sName = C_SummonInfo_GetSummonConfirmSummoner()
		local sLocation = C_SummonInfo_GetSummonConfirmAreaName()
		K.Print(L["Summon From"] .." "..sName.." ("..sLocation..") "..L["Summon Warning"])
		C_Timer_After(10, function()
			local sNameNew = C_SummonInfo_GetSummonConfirmSummoner()
			local sLocationNew = C_SummonInfo_GetSummonConfirmAreaName()
			if sName == sNameNew and sLocation == sLocationNew then
				-- Automatically accept summon after 10 seconds if summoner name and location have not changed
				C_SummonInfo_ConfirmSummon()
				StaticPopup_Hide("CONFIRM_SUMMON")
			end
		end)
	end
	return
end

function Module:CreateAutoAcceptSummon()
	if not C["Automation"].AutoSummon then
		K:UnregisterEvent("CONFIRM_SUMMON", SetupAutoAcceptSummon)
		return
	end

	K:RegisterEvent("CONFIRM_SUMMON", SetupAutoAcceptSummon)
end