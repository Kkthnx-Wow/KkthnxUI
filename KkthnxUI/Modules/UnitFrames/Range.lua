local K, C = _G.unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local UnitCanAttack = UnitCanAttack
local UnitInRange = UnitInRange
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPhaseReason = UnitPhaseReason

function Module:CreateRangeIndicator()
	local Range = {
		insideAlpha = 1,
		outsideAlpha = 0.35
	}
	Range.Override = Module.UpdateRange

	return Range
end

local function friendlyIsInRange(realUnit)
	local unit = K.GetGroupUnit(realUnit) or realUnit

	if UnitIsPlayer(unit) and UnitPhaseReason(unit) then
		return false -- is not in same phase
	end

	local inRange, checkedRange = UnitInRange(unit)
	if checkedRange and not inRange then
		return false -- blizz checked and said the unit is out of range
	end

	local _, maxRange = K.RangeCheck:GetRange(unit, true, true)
	return maxRange
end

function Module:UpdateRange()
	if not self.Range then return end
	local alpha

	local unit = self.unit

	if self.forceInRange or unit == 'player' then
		alpha = self.Range.insideAlpha
	elseif self.forceNotInRange then
		alpha = self.Range.outsideAlpha
	elseif unit then
		if UnitCanAttack('player', unit) or UnitIsUnit(unit, 'pet') then
			local _, maxRange = K.RangeCheck:GetRange(unit, true, true)
			alpha = (maxRange and self.Range.insideAlpha) or self.Range.outsideAlpha
		else
			alpha = (UnitIsConnected(unit) and friendlyIsInRange(unit) and self.Range.insideAlpha) or self.Range.outsideAlpha
		end
	else
		alpha = self.Range.insideAlpha
	end

	self.Range.RangeAlpha = alpha
	self:SetAlpha(self.Range.RangeAlpha)
end
