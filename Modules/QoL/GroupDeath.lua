--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/GroupDeath.lua
	Purpose:
		Show "name DIED" in the middle of the screen when someone in the party or
		raid dies, with the name in their class colour.

		There is no event for another player's death outside the combat log, which
		addons no longer receive, so deaths are found by looking at the group a
		couple of times a second. That timer only exists while grouped, and it is
		cancelled the moment the group disbands. A member who is already dead when
		the group forms, or who joins dead, is not announced. Feigning death and
		disconnecting are not deaths.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local IsSecret = K.IsSecret
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local GetNumGroupMembers = GetNumGroupMembers
local UnitExists, UnitName, UnitClass = UnitExists, UnitName, UnitClass
local UnitIsDeadOrGhost, UnitIsFeignDeath, UnitIsConnected = UnitIsDeadOrGhost, UnitIsFeignDeath, UnitIsConnected
local format = string.format
local wipe = wipe

local INTERVAL = 0.5
local SKULL = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:0|t"

-- Unit tokens built once, so scanning never concatenates strings.
local PARTY_UNITS, RAID_UNITS = {}, {}
for index = 1, 4 do
	PARTY_UNITS[index] = "party" .. index
end
for index = 1, 40 do
	RAID_UNITS[index] = "raid" .. index
end

local alert
local ticker
local wasDead = {} -- unit token -> true while that unit is dead

local function IsDown(unit)
	return UnitIsConnected(unit) and UnitIsDeadOrGhost(unit) and not UnitIsFeignDeath(unit)
end

local function Announce(unit)
	local name = UnitName(unit)
	if not name or IsSecret(name) then
		return
	end
	local _, class = UnitClass(unit)
	local color = class and not IsSecret(class) and RAID_CLASS_COLORS[class]
	if color then
		name = format("|c%s%s|r", color.colorStr, name)
	end
	alert:Flash(format("%s %s |cffff2020%s|r", SKULL, name, L["DIED!"]), 1, 1, 1)
end

-- Look at one member. With announce set, a unit that has just gone down is
-- announced, otherwise the state is only recorded.
local function Check(unit, announce)
	if not UnitExists(unit) then
		wasDead[unit] = nil
		return
	end
	local down = IsDown(unit)
	if announce and down and not wasDead[unit] then
		Announce(unit)
	end
	wasDead[unit] = down or nil
end

-- Walk every other member of the group. Written as a loop over precomputed unit
-- names so the half second timer allocates nothing.
local function Walk(announce)
	if IsInRaid() then
		for index = 1, GetNumGroupMembers() do
			local unit = RAID_UNITS[index]
			if not UnitIsUnit(unit, "player") then
				Check(unit, announce)
			end
		end
	else
		for index = 1, 4 do
			Check(PARTY_UNITS[index], announce)
		end
	end
end

local function Scan()
	Walk(true)
end

local function Sync()
	wipe(wasDead)
	Walk(false)
	if IsInGroup() then
		if not ticker then
			ticker = C_Timer.NewTicker(INTERVAL, Scan)
		end
	elseif ticker then
		ticker:Cancel()
		ticker = nil
	end
end

function Module:SetupGroupDeath()
	alert = self:RegisterAlert("GroupDeathAlert", L["Group Death Alert"], "CENTER", 210)
	self:RegisterEvent("GROUP_ROSTER_UPDATE", Sync)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", Sync)
	Sync()
end
