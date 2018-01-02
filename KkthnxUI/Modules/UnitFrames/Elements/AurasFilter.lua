local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local ImportantDebuffs = {
	[6788] = K.Class == "PRIEST", -- Weakened Soul
	[25771] = K.Class == "PALADIN", -- Forbearance
	[212570] = true, -- Surrendered Soul
}

function K.CustomBuffFilter(_, unit, aura, _, _, _, _, _, _, _, caster, _, _, _, _, _, casterIsPlayer)
	if (UnitIsFriend(unit, "player")) then
		return aura.isPlayer or caster == "pet" or not casterIsPlayer
	else
		return true
	end
end

function K.CustomDebuffFilter(_, unit, aura, _, _, _, _, _, _, _, caster, _, _, spellID, _, isBossDebuff, casterIsPlayer)
	if (not UnitIsFriend(unit, "player")) then
		return aura.isPlayer or caster == "pet" or not casterIsPlayer or isBossDebuff or ImportantDebuffs[spellID]
	else
		return true
	end
end