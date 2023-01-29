local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Automation")

local C_SummonInfo_ConfirmSummon = C_SummonInfo.ConfirmSummon
local C_SummonInfo_GetSummonConfirmAreaName = C_SummonInfo.GetSummonConfirmAreaName
local C_SummonInfo_GetSummonConfirmSummoner = C_SummonInfo.GetSummonConfirmSummoner
local C_Timer_After = C_Timer.After
local StaticPopup_Hide = StaticPopup_Hide
local UnitAffectingCombat = UnitAffectingCombat

local function SetupAutoAcceptSummon()
	-- Check if player is in combat, if so, exit the function
	if UnitAffectingCombat("player") then
		return
	end

	-- Get the summoner name and location
	local sName = C_SummonInfo_GetSummonConfirmSummoner()
	local sLocation = C_SummonInfo_GetSummonConfirmAreaName()

	-- Print the summoner name, location, and warning message
	K.Print(L["Summon From"] .. " " .. sName .. " (" .. sLocation .. ") " .. L["Summon Warning"])

	-- Create a timer for 10 seconds
	C_Timer_After(10, function()
		-- Get the summoner name and location again
		local sNameNew = C_SummonInfo_GetSummonConfirmSummoner()
		local sLocationNew = C_SummonInfo_GetSummonConfirmAreaName()

		-- Check if the summoner name and location have not changed
		if sName == sNameNew and sLocation == sLocationNew then
			-- Automatically accept the summon
			C_SummonInfo_ConfirmSummon()

			-- Hide the summon confirmation popup
			StaticPopup_Hide("CONFIRM_SUMMON")
		end
	end)
end

function Module:CreateAutoAcceptSummon()
	if C["Automation"].AutoSummon then
		K:RegisterEvent("CONFIRM_SUMMON", SetupAutoAcceptSummon)
	else
		K:UnregisterEvent("CONFIRM_SUMMON", SetupAutoAcceptSummon)
	end
end
