local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- Cache WoW API functions
local C_SummonInfo_ConfirmSummon = C_SummonInfo.ConfirmSummon
local C_SummonInfo_GetSummonConfirmAreaName = C_SummonInfo.GetSummonConfirmAreaName
local C_SummonInfo_GetSummonConfirmSummoner = C_SummonInfo.GetSummonConfirmSummoner
local StaticPopup_Hide = StaticPopup_Hide
local UnitAffectingCombat = UnitAffectingCombat
local UnitClass = UnitClass
local UnitName = UnitName
local IsInRaid = IsInRaid
local IsInGroup = IsInGroup
local GetNumGroupMembers = GetNumGroupMembers
local Ambiguate = Ambiguate
local format = string.format

-- Config
local SUMMON_ACCEPT_DELAY = 10

-- Returns true if the given unit's name matches the provided target name
local function IsUnitMatchingName(unit, targetName, targetShort)
	local name, realm = UnitName(unit)
	if not name then
		return false
	end
	if name == targetShort then
		return true
	end
	if realm and realm ~= "" and (name .. "-" .. realm) == targetName then
		return true
	end
	return false
end

-- Returns the class token (e.g., "WARLOCK") for a given player name by scanning group units
local function GetClassTokenByName(targetName)
	if not targetName then
		return
	end

	local targetShort = Ambiguate(targetName, "short") or targetName

	-- Search raid first, then party, then player
	if IsInRaid() then
		local num = GetNumGroupMembers() or 0
		for i = 1, num do
			local unit = "raid" .. i
			if IsUnitMatchingName(unit, targetName, targetShort) then
				local _, classToken = UnitClass(unit)
				return classToken
			end
		end
	elseif IsInGroup() then
		local num = (GetNumGroupMembers() or 1) - 1 -- exclude player index
		for i = 1, num do
			local unit = "party" .. i
			if IsUnitMatchingName(unit, targetName, targetShort) then
				local _, classToken = UnitClass(unit)
				return classToken
			end
		end
	end

	-- Fallback: check player
	if IsUnitMatchingName("player", targetName, targetShort) then
		local _, classToken = UnitClass("player")
		return classToken
	end

	-- Not found
	return
end

-- Handle summon confirmation and auto-accept after delay
local function HandleConfirmSummon(event)
	-- Defer processing until after combat if needed
	if UnitAffectingCombat("player") then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", HandleConfirmSummon)
		return
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", HandleConfirmSummon)
	end

	-- Retrieve the summoner's name and location
	local summonerName = C_SummonInfo_GetSummonConfirmSummoner()
	local summonerLocation = C_SummonInfo_GetSummonConfirmAreaName()

	-- Guard against missing info
	if not summonerName or not summonerLocation then
		return
	end

	-- Resolve class and colorize the summoner's name
	local classToken = GetClassTokenByName(summonerName)
	local coloredName
	if classToken and K.ClassColors and K.ClassColors[classToken] then
		local colorStr = K.ClassColors[classToken].colorStr
		coloredName = (colorStr and ("|c" .. colorStr .. summonerName .. "|r")) or summonerName
	else
		coloredName = summonerName
	end

	-- Print message
	K.Print(format("%s %s (%s) %s", L["Summon From"], coloredName, summonerLocation, L["Summon Warning"]))

	-- Delay acceptance and re-validate
	K.Delay(SUMMON_ACCEPT_DELAY, function()
		local currentSummoner = C_SummonInfo_GetSummonConfirmSummoner()
		local currentLocation = C_SummonInfo_GetSummonConfirmAreaName()
		if currentSummoner and currentLocation and currentSummoner == summonerName and currentLocation == summonerLocation then
			C_SummonInfo_ConfirmSummon() -- Accept the summon
			StaticPopup_Hide("CONFIRM_SUMMON") -- Hide the confirmation dialog
		end
	end)
end

-- Enable or disable the automatic summon acceptance feature
function Module:CreateAutoAcceptSummon()
	if C["Automation"].AutoSummon then
		K:RegisterEvent("CONFIRM_SUMMON", HandleConfirmSummon)
	else
		K:UnregisterEvent("CONFIRM_SUMMON", HandleConfirmSummon)
	end
end
