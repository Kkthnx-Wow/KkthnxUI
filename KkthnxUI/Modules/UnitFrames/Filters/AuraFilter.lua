local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end


-- Filters:
-- General (both):	On Players:Show all
-- "Blacklist" 0 = Show All (override default)
-- 1 = Show only mine
-- 2 = Hide on friendly
-- 3 = Hide all
-- On NPC's: Show only mine
-- 0 = Show Always ( Even when not Mine )
-- 1 = Show only mine - no effect.
-- 2 = Hide on friendly
-- 3 = Hide Mine
-- Arena (buff): true = whitelisted
-- "Whitelist"
-- Boss (debuff): 0 = Whitelisted
-- "Whitelist" 1 = Only show own

-- Credits to Phanx for this aura filter. (Phanx <addons@phanx.net>)
-- Default Aura Filter
local BaseAuras = {
	-- Useless
	[60023] = 3, -- Scourge Banner Aura (Boneguard Commander in Icecrown)
	[62594] = 3, -- Stormwind Champion"s Pennant
	[62596] = 3, -- Stormwind Valiant"s Pennant
	[63395] = 3, -- Gnomeregan Valiant"s Pennant
	[63396] = 3, -- Gnomeregan Champion"s Pennant
	[63398] = 3, -- Sen"jin Valiant"s Pennant
	[63399] = 3, -- Sen"jin Champion"s Pennant
	[63402] = 3, -- Silvermoon Valiant"s Pennant
	[63403] = 3, -- Silvermoon Champion"s Pennant
	[63405] = 3, -- Darnassus Valiant"s Pennant
	[63406] = 3, -- Darnassus Champion"s Pennant
	[63422] = 3, -- Exodar Valiant"s Pennant
	[63423] = 3, -- Exodar Champion"s Pennant
	[63426] = 3, -- Ironforge Valiant"s Pennant
	[63427] = 3, -- Ironforge Champion"s Pennant
	[63429] = 3, -- Undercity Valiant"s Pennant
	[63430] = 3, -- Undercity Champion"s Pennant
	[63432] = 3, -- Orgrimmar Valiant"s Pennant
	[63433] = 3, -- Orgrimmar Champion"s Pennant
	[63435] = 3, -- Thunder Bluff Valiant"s Pennant
	[63436] = 3, -- Thunder Bluff Champion"s Pennant
	[63501] = 3, -- Argent Crusade Champion"s Pennant
}

for _, list in pairs({K.AuraList.Stun, K.AuraList.CC, K.AuraList.Silence, K.AuraList.Taunt}) do
	for i = 1, #list do
		BaseAuras[list[i]] = 0
	end
end

local genFilter, arenaFilter, bossFilter = {}, {}, {}
local auraFilters = {genFilter, arenaFilter, bossFilter}
local UnitCanAttack, UnitPlayerControlled = UnitCanAttack, UnitPlayerControlled
local isPlayer = {player = true, pet = true, vehicle = true}

local filters = {
	[0] = function(self, unit, caster) return true end,
	[1] = function(self, unit, caster) return isPlayer[caster] end,
	[2] = function(self, unit, caster) return UnitCanAttack("player", unit) end,
	[3] = function(self, unit, caster) return false end,
}

K.CustomAuraFilters = {
	pet = function(self, unit, iconFrame, name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, unknown, nameplateShowAll, timeMod, value1, value2, value3)
		return (caster and isPlayer[caster]) and (not genFilter[spellID] == 3)
	end,

	target = function(self, unit, iconFrame, name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, unknown, nameplateShowAll, timeMod, value1, value2, value3)
		local v = genFilter[spellID]
		if v and filters[v] then -- In Filters
			return filters[v](self, unit, caster)
		elseif UnitPlayerControlled(unit) then -- Player
			return true
		else -- NPC
			-- Always show BUFFS, Show boss debuffs, aura cast by the unit, or auras cast by the player's vehicle.
			return (iconFrame.filter == "HELPFUL") or (isBossDebuff) or nameplateShowAll or (isPlayer[caster]) or (caster == unit)
		end
	end,

	party = function(self, unit, iconFrame, name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, unknown, nameplateShowAll, timeMod, value1, value2, value3)
		local v = genFilter[spellID]
		if v and filters[v] then
			return filters[v](self, unit, caster)
		elseif (iconFrame.filter == "HELPFUL") then -- BUFFS
			return (nameplateShowPersonal and isPlayer[caster]) or isBossDebuff or nameplateShowAll
		else
			return true
		end
	end,

	arena = function(self, unit, iconFrame, name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, unknown, nameplateShowAll, timeMod, value1, value2, value3)
		return arenaFilter[spellID]
	end,

	boss = function(self, unit, iconFrame, name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, unknown, nameplateShowAll, timeMod, value1, value2, value3)
		local v = bossFilter[spellID]
		if v == 1 then
			return isPlayer[caster]
		elseif v == 0 then
			return true
		else
			return isBossDebuff
		end
	end,
}