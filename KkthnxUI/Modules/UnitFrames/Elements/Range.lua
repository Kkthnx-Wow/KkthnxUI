local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local string_find = string.find

local GetNumGroupMembers = GetNumGroupMembers
local IsInRaid = IsInRaid
local UnitCanAttack = UnitCanAttack
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitInRange = UnitInRange
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPhaseReason = UnitPhaseReason

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
	local minRange, maxRange = K.LibRangeCheck:GetRange(unit, true, true)
	return (not minRange) or maxRange
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

	local alpha = self.Range.insideAlpha
	local unit = self.unit

	if not unit then
		self.Range.RangeAlpha = alpha
		self:SetAlpha(self.Range.RangeAlpha)
		return
	end

	if not self.forceInRange and not self.forceNotInRange then
		local canAttack = UnitCanAttack("player", unit) or UnitIsUnit(unit, "pet")
		local inRange = (canAttack and getMaxRange(unit)) or (UnitIsConnected(unit) and friendlyIsInRange(unit))
		alpha = inRange and self.Range.insideAlpha or self.Range.outsideAlpha
	elseif self.forceInRange or unit == "player" then
		alpha = self.Range.insideAlpha
	else
		alpha = self.Range.outsideAlpha
	end

	self.Range.RangeAlpha = alpha
	self:SetAlpha(self.Range.RangeAlpha)
end
