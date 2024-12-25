local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- Cache WoW API functions
local C_SummonInfo_ConfirmSummon = C_SummonInfo.ConfirmSummon
local C_SummonInfo_GetSummonConfirmAreaName = C_SummonInfo.GetSummonConfirmAreaName
local C_SummonInfo_GetSummonConfirmSummoner = C_SummonInfo.GetSummonConfirmSummoner
local StaticPopup_Hide = StaticPopup_Hide
local UnitAffectingCombat = UnitAffectingCombat
local format = string.format

-- Automatically accept a summon after a 10 second delay
local function AutoAcceptSummon(event)
	-- If the player is in combat, register for PLAYER_REGEN_ENABLED to retry after combat ends
	if UnitAffectingCombat("player") then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", AutoAcceptSummon)
		return
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", AutoAcceptSummon)
	end

	-- Retrieve the summoner's name and location
	local summonerName = C_SummonInfo_GetSummonConfirmSummoner()
	local summonerLocation = C_SummonInfo_GetSummonConfirmAreaName()

	-- Print a message warning the player of the summon
	K.Print(format(L["Summon From"] .. " %s (%s) %s", summonerName, summonerLocation, L["Summon Warning"]))

	-- Wait for 10 seconds before automatically accepting the summon
	K.Delay(10, function()
		-- Verify that the summon request is still valid before accepting
		if C_SummonInfo_GetSummonConfirmSummoner() == summonerName and C_SummonInfo_GetSummonConfirmAreaName() == summonerLocation then
			C_SummonInfo_ConfirmSummon() -- Accept the summon
			StaticPopup_Hide("CONFIRM_SUMMON") -- Hide the confirmation dialog
		end
	end)
end

-- Enable or disable the automatic summon acceptance feature
function Module:CreateAutoAcceptSummon()
	if C["Automation"].AutoSummon then
		K:RegisterEvent("CONFIRM_SUMMON", AutoAcceptSummon)
	else
		K:UnregisterEvent("CONFIRM_SUMMON", AutoAcceptSummon)
	end
end
