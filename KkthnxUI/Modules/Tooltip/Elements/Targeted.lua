--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays which group members are currently targeting the unit.
-- - Design: Scans group members and their targets to build a "Targeted By" list.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Tooltip")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local tconcat = _G.table.concat
local tinsert = _G.table.insert
local wipe = _G.table.wipe

local GameTooltip = _G.GameTooltip
local GetNumGroupMembers = _G.GetNumGroupMembers
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local UnitExists = _G.UnitExists
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName

local IsSecret = K.IsSecret
local NotSecret = K.NotSecret

local targetTable = {}

-- REASON: Scans the group to find who is targeting the unit and adds a line to the tooltip.
function Module:ScanTargets(unit)
	if not C["Tooltip"].TargetBy then
		return
	end

	if not IsInGroup() then
		return
	end

	-- SECRET (12.0): a secret unit can't be passed to UnitExists.
	if IsSecret(unit) or not UnitExists(unit) then
		return
	end

	wipe(targetTable)

	local isInRaid = IsInRaid()
	for i = 1, GetNumGroupMembers() do
		local member = (isInRaid and "raid" .. i or "party" .. i)
		-- SECRET (12.0): in instances the target identity is hidden, so
		-- UnitIsUnit returns a secret boolean that must not hit a boolean test.
		-- Skip the member entirely when any of these reads are secret.
		local isTarget = UnitIsUnit(unit, member .. "target")
		if NotSecret(isTarget) and isTarget then
			local isSelf = UnitIsUnit("player", member)
			local isDead = UnitIsDeadOrGhost(member)
			if NotSecret(isSelf) and NotSecret(isDead) and not isSelf and not isDead then
				local color = K.RGBToHex(K.UnitColor(member))
				local name = color .. UnitName(member) .. "|r"
				tinsert(targetTable, name)
			end
		end
	end

	if #targetTable > 0 then
		GameTooltip:AddLine(L["Targeted By"] .. K.InfoColor .. "(" .. #targetTable .. ")|r " .. tconcat(targetTable, ", "), nil, nil, nil, 1)
	end
end
