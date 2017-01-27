local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

-- Lua API
local _G = _G
local wipe = wipe
local ipairs = ipairs
local pairs = pairs

-- Wow API
local UnitCanAttack = _G.UnitCanAttack
local UnitPlayerControlled = _G.UnitPlayerControlled

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, CreateFrame

-- Filters:
-- General (both): On Players:Show all
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
--  "Whitelist"
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
	-- Unsure about hiding this right now.
	[108370] = 1, -- Soul Leech
	[113942] = 1, -- Demonic: Gateway
	[114216] = 1, -- Angelic Bulwark
	[114556] = 1, -- Purgatory
	[115767] = 1, -- Deep Wounds
	[115804] = 1, -- Mortal Wounds
	[117870] = 1, -- Touch of The Titans
	[122509] = 1, -- Ultimatum
	[123981] = 1, -- Perdition
	[124273] = 1, -- Stagger
	[124274] = 1, -- Stagger
	[124275] = 1, -- Stagger
	[137596] = 1, -- Capacitance
	[138477] = 1, -- Spirit Heal
	[144624] = 1, -- Unyielding Faith
	[145082] = 1, -- Empowered Grasp
	[145159] = 1, -- Dark Refund
	[15007] = 1, -- Ress Sickness
	[174524] = 1, -- Awesome!
	[174528] = 1, -- Griefer
	[184361] = 1, -- Enrage
	[185576] = 1, -- Beacon's Tribute
	[212036] = 1, -- Recently Mass Resurrected
	[23445] = 1, -- evil twin
	[24755] = 1, -- tricked or treated debuff
	[2479] = 1, -- Honorless Target
	[25163] = 1, -- pet debuff oozeling disgusting aura
	[25771] = 1, -- forbearance
	[26013] = 1, -- deserter
	[36032] = 1, -- Arcane Charge
	[36893] = 1, -- Transporter Malfunction
	[36900] = 1, -- Soul Split: Evil!
	[36901] = 1, -- Soul Split: Good
	[41425] = 1, -- Hypothermia
	[44614] = 1, -- Flurry
	[46953] = 1, -- Sword and Board
	[55711] = 1, -- Weakened Heart
	[57723] = 1, -- Exhaustion
	[57724] = 1, -- Sated
	[58539] = 1, -- watchers corpse
	[6788] = 1, -- Weakened Soul
	[71041] = 1, -- dungeon deserter
	[79561] = 1, -- Blood Craze
	[80354] = 1, -- Temporal Displacement
	[8326] = 1, -- ghost
	[8733] = 1, -- Blessing of Blackfathom
	[89140] = 1, -- Demonic Rebirth: Cooldown
	[95223] = 1, -- group res debuff
	[95809] = 1, -- Insanity debuff (Hunter Pet heroism)
	[97821] = 1, -- Void-Touched
}

for _, list in pairs({
	K.AuraList.Stun,
	K.AuraList.CC,
	K.AuraList.Silence,
	K.AuraList.Taunt
})
do
	for i = 1, #list do
		BaseAuras[list[i]] = 0
	end
end

local genFilter = {}
local arenaFilter = {}
local bossFilter = {}

local auraFilters = {
	genFilter,
	arenaFilter,
	bossFilter
}

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
		if v and filters[v] then
			return filters[v](self, unit, caster)
		elseif UnitPlayerControlled(unit) then
			return true
		else
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