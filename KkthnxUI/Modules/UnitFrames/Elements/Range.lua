local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- Global caching
local string_find, UnitIsUnit, UnitInParty, UnitInRaid, GetNumGroupMembers, IsInRaid, UnitIsPlayer, UnitPhaseReason, UnitInRange, UnitCanAttack, UnitIsConnected = string.find, UnitIsUnit, UnitInParty, UnitInRaid, GetNumGroupMembers, IsInRaid, UnitIsPlayer, UnitPhaseReason, UnitInRange, UnitCanAttack, UnitIsConnected

local function GetGroupUnit(unit)
	if UnitIsUnit(unit, "player") then
		return nil
	end

	if string_find(unit, "party") or string_find(unit, "raid") then
		return unit
	end

	-- Check if the unit is in the player's group
	local isInRaid = IsInRaid()
	local groupPrefix = isInRaid and "raid" or "party"
	local numGroupMembers = GetNumGroupMembers()

	for i = 1, numGroupMembers do
		local groupUnit = groupPrefix .. i
		if UnitIsUnit(unit, groupUnit) then
			return groupUnit
		end
	end
end

local function getMaxRange(unit)
	local minRange, maxRange = K.LibRangeCheck:GetRange(unit, true, true)
	return maxRange
end

local function friendlyIsInRange(realUnit)
	local unit = GetGroupUnit(realUnit) or realUnit

	if UnitIsPlayer(unit) and UnitPhaseReason(unit) then
		return false -- not in the same phase
	end

	local inRange, checkedRange = UnitInRange(unit)
	if checkedRange and not inRange then
		return false -- Blizzard API indicates out of range
	end

	return getMaxRange(unit)
end

function Module:UpdateRange()
	if not self.Range then
		return
	end

	local unit = self.unit
	local alpha = self.Range.insideAlpha

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
