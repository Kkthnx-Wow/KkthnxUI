local _G = _G

local K = _G.unpack(_G.select(2, ...))
local Module = K:GetModule("Unitframes")
local SpellRange = _G.LibStub("SpellRange-1.0")

local pairs, ipairs = _G.pairs, _G.ipairs

local CheckInteractDistance = _G.CheckInteractDistance
local UnitCanAttack = _G.UnitCanAttack
local UnitInParty = _G.UnitInParty
local UnitInPhase = _G.UnitInPhase
local UnitInRaid = _G.UnitInRaid
local UnitInRange = _G.UnitInRange
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsWarModePhased = _G.UnitIsWarModePhased
local UnitIsUnit = _G.UnitIsUnit

local SR = {}

function Module:CreateRangeIndicator()
	local Range = {
		insideAlpha = 1,
		outsideAlpha = 0.35
	}
	Range.Override = Module.UpdateRange

	return Range
end

local function AddTable(tbl)
	SR[K.Class][tbl] = {}
end

local function AddSpell(tbl, spellID)
	SR[K.Class][tbl][#SR[K.Class][tbl] + 1] = spellID
end

function Module:UpdateRangeCheckSpells()
	if not SR[K.Class] then
		SR[K.Class] = {}
	end

	for tbl, spells in pairs(K["spellRangeCheck"][K.Class]) do
		AddTable(tbl) -- Create the table holding spells, even if it ends up being an empty table
		for spellID in pairs(spells) do
			local enabled = spells[spellID]
			if enabled then -- We will allow value to be false to disable this spell from being used
				AddSpell(tbl, spellID, enabled)
			end
		end
	end
end

local function getUnit(unit)
	if not unit:find("party") or not unit:find("raid") then
		for i = 1, 4 do
			if UnitIsUnit(unit, "party"..i) then
				return "party"..i
			end
		end

		for i = 1, 40 do
			if UnitIsUnit(unit, "raid"..i) then
				return "raid"..i
			end
		end
	else
		return unit
	end
end

local function friendlyIsInRange(unit)
	if (not UnitIsUnit(unit, "player")) and (UnitInParty(unit) or UnitInRaid(unit)) then
		unit = getUnit(unit) -- swap the unit with `raid#` or `party#` when its NOT `player`, UnitIsUnit is true, and its not using `raid#` or `party#` already
	end

	if UnitPhaseReason(unit) then
		return false -- is not in same phase
	end

	local inRange, checkedRange = UnitInRange(unit)
	if checkedRange and not inRange then
		return false -- blizz checked and said the unit is out of range
	end

	if CheckInteractDistance(unit, 1) then
		return true -- within 28 yards (arg2 as 1 is Compare Achievements distance)
	end

	local object = SR[K.Class]
	if object then
		if object.resSpells and (#object.resSpells > 0) and UnitIsDeadOrGhost(unit) then -- dead with rez spells
			for _, spellID in ipairs(object.resSpells) do
				if SpellRange.IsSpellInRange(spellID, unit) == 1 then
					return true -- within rez range
				end
			end

			return false -- dead but no spells are in range
		end

		if object.friendlySpells and (#object.friendlySpells > 0) then -- you have some healy spell
			for _, spellID in ipairs(object.friendlySpells) do
				if SpellRange.IsSpellInRange(spellID, unit) == 1 then
					return true -- within healy spell range
				end
			end
		end
	end

	return false -- not within 28 yards and no spells in range
end

local function petIsInRange(unit)
	if CheckInteractDistance(unit, 2) then
		return true -- within 8 yards (arg2 as 2 is Trade distance)
	end

	local object = SR[K.Class]
	if object then
		if object.friendlySpells and (#object.friendlySpells > 0) then -- you have some healy spell
			for _, spellID in ipairs(object.friendlySpells) do
				if SpellRange.IsSpellInRange(spellID, unit) == 1 then
					return true
				end
			end
		end

		if object.petSpells and (#object.petSpells > 0) then -- you have some pet spell
			for _, spellID in ipairs(object.petSpells) do
				if SpellRange.IsSpellInRange(spellID, unit) == 1 then
					return true
				end
			end
		end
	end

	return false -- not within 8 yards and no spells in range
end

local function enemyIsInRange(unit)
	if CheckInteractDistance(unit, 2) then
		return true -- within 8 yards (arg2 as 2 is Trade distance)
	end

	local object = SR[K.Class]
	if object and object.enemySpells and (#object.enemySpells > 0) then -- you have some damage spell
		for _, spellID in ipairs(object.enemySpells) do
			if SpellRange.IsSpellInRange(spellID, unit) == 1 then
				return true
			end
		end
	end

	return false -- not within 8 yards and no spells in range
end

local function enemyIsInLongRange(unit)
	local object = SR[K.Class]
	if object and object.longEnemySpells and (#object.longEnemySpells > 0) then -- you have some 30+ range damage spell
		for _, spellID in ipairs(object.longEnemySpells) do
			if SpellRange.IsSpellInRange(spellID, unit) == 1 then
				return true
			end
		end
	end

	return false
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
		if UnitCanAttack("player", unit) then
			alpha = ((enemyIsInRange(unit) or enemyIsInLongRange(unit)) and self.Range.insideAlpha) or self.Range.outsideAlpha
		elseif UnitIsUnit(unit, "pet") then
			alpha = (petIsInRange(unit) and self.Range.insideAlpha) or self.Range.outsideAlpha
		else
			alpha = (UnitIsConnected(unit) and friendlyIsInRange(unit) and self.Range.insideAlpha) or self.Range.outsideAlpha
		end
	else
		alpha = self.Range.insideAlpha
	end

	self:SetAlpha(alpha)
end