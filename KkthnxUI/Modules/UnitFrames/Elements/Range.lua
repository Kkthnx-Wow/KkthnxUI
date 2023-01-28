local K, C = _G.unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local string_find = _G.string.find

local GetNumGroupMembers = _G.GetNumGroupMembers
local IsInRaid = _G.IsInRaid
local UnitCanAttack = _G.UnitCanAttack
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitInRange = _G.UnitInRange
local UnitIsConnected = _G.UnitIsConnected
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitPhaseReason = _G.UnitPhaseReason

function Module:CreateRangeIndicator()
	if not C["Unitframe"].Range then
		return
	end

	local Range = {
		insideAlpha = 1,
		outsideAlpha = 0.35,
	}
	Range.Override = Module.UpdateRange

	return Range
end

local function GetGroupUnit(unit)
	if UnitIsUnit(unit, "player") then
		return
	end

	if string_find(unit, "party") or string_find(unit, "raid") then
		return unit
	end

	-- returns the unit as raid# or party# when grouped
	if UnitInParty(unit) or UnitInRaid(unit) then
		local isInRaid = IsInRaid()
		for i = 1, GetNumGroupMembers() do
			local groupUnit = (isInRaid and "raid" or "party") .. i
			if UnitIsUnit(unit, groupUnit) then
				return groupUnit
			end
		end
	end
end

local function getMaxRange(unit)
	local _, maxRange = K.LibRangeCheck:GetRange(unit, true, true)
	return maxRange
end

local function friendlyIsInRange(realUnit)
	local unit = GetGroupUnit(realUnit) or realUnit

	if UnitIsPlayer(unit) and UnitPhaseReason(unit) then
		return false -- is not in same phase
	end

	local inRange, checkedRange = UnitInRange(unit)
	if checkedRange and not inRange then
		return false -- blizz checked and said the unit is out of range
	end

	return getMaxRange(unit)
end

function Module:UpdateRange()
	if not self.Range then
		return
	end

	local alpha
	local unit = self.unit
	if self.forceInRange or unit == "player" then
		alpha = self.Range.insideAlpha
	elseif self.forceNotInRange then
		alpha = self.Range.outsideAlpha
	elseif unit then
		local canAttack = UnitCanAttack("player", unit) or UnitIsUnit(unit, "pet")
		local inRange = (canAttack and getMaxRange(unit)) or (UnitIsConnected(unit) and friendlyIsInRange(unit))
		alpha = inRange and self.Range.insideAlpha or self.Range.outsideAlpha
	else
		alpha = self.Range.insideAlpha
	end

	self.Range.RangeAlpha = alpha
	self:SetAlpha(self.Range.RangeAlpha)
end
