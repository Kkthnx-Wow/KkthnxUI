local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

local C_SummonInfo_ConfirmSummon, C_SummonInfo_GetSummonConfirmAreaName, C_SummonInfo_GetSummonConfirmSummoner = C_SummonInfo.ConfirmSummon, C_SummonInfo.GetSummonConfirmAreaName, C_SummonInfo.GetSummonConfirmSummoner
local C_Timer_After, StaticPopup_Hide = C_Timer.After, StaticPopup_Hide
local UnitAffectingCombat = UnitAffectingCombat

-- Helper function to automatically accept a summon after a 10 second delay
local function AutoAcceptSummon()
	-- Check if the player is in combat and return if so
	if UnitAffectingCombat("player") then
		return
	end

	-- Get the summoner name and location
	local summonerName, summonerLocation = C_SummonInfo_GetSummonConfirmSummoner(), C_SummonInfo_GetSummonConfirmAreaName()

	-- Print a warning message with the summoner name and location
	K.Print(format(L["Summon From"] .. " %s (%s) %s", summonerName, summonerLocation, L["Summon Warning"]))

	-- Wait for 10 seconds and check if the summoner name and location are still the same
	C_Timer_After(10, function()
		if C_SummonInfo_GetSummonConfirmSummoner() == summonerName and C_SummonInfo_GetSummonConfirmAreaName() == summonerLocation then
			-- Confirm the summon and hide the confirmation popup
			C_SummonInfo_ConfirmSummon()
			StaticPopup_Hide("CONFIRM_SUMMON")
		end
	end)
end

-- Function to enable or disable the automatic summon acceptance feature
function Module:CreateAutoAcceptSummon()
	if C["Automation"].AutoSummon then
		K:RegisterEvent("CONFIRM_SUMMON", AutoAcceptSummon)
	else
		K:UnregisterEvent("CONFIRM_SUMMON", AutoAcceptSummon)
	end
end
