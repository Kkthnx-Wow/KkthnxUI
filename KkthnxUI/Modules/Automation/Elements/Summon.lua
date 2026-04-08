--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically accepts warlock summons after a safety delay.
-- - Design: Hooks CONFIRM_SUMMON, notifies the user, and uses a delayed check to accept if the summon is still valid.
-- - Events: CONFIRM_SUMMON, PLAYER_REGEN_ENABLED (deferred)
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

-- PERF: Localize WoW API functions to minimize lookup overhead.
local Ambiguate = Ambiguate
local C_SummonInfo_ConfirmSummon = C_SummonInfo.ConfirmSummon
local C_SummonInfo_GetSummonConfirmAreaName = C_SummonInfo.GetSummonConfirmAreaName
local C_SummonInfo_GetSummonConfirmSummoner = C_SummonInfo.GetSummonConfirmSummoner
local GetNumGroupMembers = GetNumGroupMembers
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local StaticPopup_Hide = StaticPopup_Hide
local UnitAffectingCombat = UnitAffectingCombat
local UnitClass = UnitClass
local UnitName = UnitName
local string_format = string.format

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------
local SUMMON_ACCEPT_DELAY = 10

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function isUnitMatchingName(unit, targetName, targetShort)
	-- REASON: Comparison logic to matching a unit with both short and full name (including realm).
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

local function getClassTokenByName(targetName)
	-- REASON: Extracts the class token for coloring the summoner's name.
	if not targetName then
		return
	end

	local targetShort = Ambiguate(targetName, "short") or targetName

	-- PERF: Optimized search order: Raid -> Party -> Player.
	if IsInRaid() then
		local num = GetNumGroupMembers() or 0
		for i = 1, num do
			local unit = "raid" .. i
			if isUnitMatchingName(unit, targetName, targetShort) then
				local _, classToken = UnitClass(unit)
				return classToken
			end
		end
	elseif IsInGroup() then
		local num = (GetNumGroupMembers() or 1) - 1
		for i = 1, num do
			local unit = "party" .. i
			if isUnitMatchingName(unit, targetName, targetShort) then
				local _, classToken = UnitClass(unit)
				return classToken
			end
		end
	end

	if isUnitMatchingName("player", targetName, targetShort) then
		local _, classToken = UnitClass("player")
		return classToken
	end
end

local function handleConfirmSummon(event)
	-- REASON: Automatic summon handling deferred until after combat to avoid interface errors.
	if UnitAffectingCombat("player") then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", handleConfirmSummon)
		return
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", handleConfirmSummon)
	end

	local summonerName = C_SummonInfo_GetSummonConfirmSummoner()
	local summonerLocation = C_SummonInfo_GetSummonConfirmAreaName()

	if not summonerName or not summonerLocation then
		return
	end

	local classToken = getClassTokenByName(summonerName)
	local coloredName
	if classToken and K.ClassColors and K.ClassColors[classToken] then
		local colorStr = K.ClassColors[classToken].colorStr
		coloredName = (colorStr and ("|c" .. colorStr .. summonerName .. "|r")) or summonerName
	else
		coloredName = summonerName
	end

	K.Print(string_format("%s %s (%s) %s", L["Summon From"], coloredName, summonerLocation, L["Summon Warning"]))

	-- REASON: Delay acceptance to give the player time to manually cancel if they see a dangerous location.
	K.Delay(SUMMON_ACCEPT_DELAY, function()
		local currentSummoner = C_SummonInfo_GetSummonConfirmSummoner()
		local currentLocation = C_SummonInfo_GetSummonConfirmAreaName()
		if currentSummoner and currentLocation and currentSummoner == summonerName and currentLocation == summonerLocation then
			C_SummonInfo_ConfirmSummon()
			StaticPopup_Hide("CONFIRM_SUMMON")
		end
	end)
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateAutoAcceptSummon()
	-- REASON: Feature entry point; registers for confirmation events based on user configuration.
	if C["Automation"].AutoSummon then
		K:RegisterEvent("CONFIRM_SUMMON", handleConfirmSummon)
	else
		K:UnregisterEvent("CONFIRM_SUMMON", handleConfirmSummon)
	end
end
