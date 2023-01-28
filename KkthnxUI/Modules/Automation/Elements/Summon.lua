local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local C_SummonInfo_ConfirmSummon = C_SummonInfo.ConfirmSummon
local C_SummonInfo_GetSummonConfirmAreaName = C_SummonInfo.GetSummonConfirmAreaName
local C_SummonInfo_GetSummonConfirmSummoner = C_SummonInfo.GetSummonConfirmSummoner
local C_Timer_After = C_Timer.After
local StaticPopup_Hide = StaticPopup_Hide
local UnitAffectingCombat = UnitAffectingCombat

local function SetupAutoAcceptSummon()
	if not UnitAffectingCombat("player") then
		local sName = C_SummonInfo_GetSummonConfirmSummoner()
		local sLocation = C_SummonInfo_GetSummonConfirmAreaName()
		K.Print(L["Summon From"] .. " " .. sName .. " (" .. sLocation .. ") " .. L["Summon Warning"])
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
end

function Module:CreateAutoAcceptSummon()
	if C["Automation"].AutoSummon then
		K:RegisterEvent("CONFIRM_SUMMON", SetupAutoAcceptSummon)
	else
		K:UnregisterEvent("CONFIRM_SUMMON", SetupAutoAcceptSummon)
	end
end
