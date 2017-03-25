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
-- "Whitelist"
-- Boss (debuff): 0 = Whitelisted
-- "Whitelist" 1 = Only show own

-- Credits to Phanx for this aura filter. (Phanx <addons@phanx.net>)
-- Default Aura Filter
local BaseAuras = {
	-- Useless
	[113942] = 3, -- Demonic: Gateway
	[114216] = 3, -- Angelic Bulwark
	[117870] = 3, -- Touch of The Titans
	[123981] = 3, -- Perdition
	[124273] = 3, -- Stagger
	[124274] = 3, -- Stagger
	[124275] = 3, -- Stagger
	[126434] = 3, -- Tushui Champion
	[126436] = 3, -- Huojin Champion
	[143625] = 3, -- Brawling Champion
	[15007] = 3, -- Ress Sickness
	[170616] = 3, -- Pet Deserter
	[182957] = 3, -- Treasures of Stormheim
	[182958] = 3, -- Treasures of Azsuna
	[185719] = 3, -- Treasures of Val'sharah
	[186401] = 3, -- Sign of the Skirmisher
	[186403] = 3, -- Sign of Battle
	[186404] = 3, -- Sign of the Emissary
	[186406] = 3, -- Sign of the Critter
	[188741] = 3, -- Treasures of Highmountain
	[199416] = 3, -- Treasures of Suramar
	[225787] = 3, -- Sign of the Warrior
	[225788] = 3, -- Sign of the Emissary
	[227723] = 3, -- Mana Divining Stone
	[231115] = 3, -- Treasures of Broken Shore
	[23445] = 3, -- Evil Twin
	[24755] = 3, -- Tricked or Treated
	[25163] = 3, -- Oozeling's Disgusting Aura
	[25771] = 3, -- Forbearance
	[26013] = 3, -- Deserter
	[36032] = 3, -- Arcane Charge
	[36893] = 3, -- Transporter Malfunction
	[36900] = 3, -- Soul Split: Evil!
	[36901] = 3, -- Soul Split: Good
	[39953] = 3, -- A'dal's Song of Battle
	[41425] = 3, -- Hypothermia
	[55711] = 3, -- Weakened Heart
	[57723] = 3, -- Exhaustion
	[57724] = 3, -- Sated
	[57819] = 3, -- Argent Champion
	[57820] = 3, -- Ebon Champion
	[57821] = 3, -- Champion of the Kirin Tor
	[58539] = 3, -- Watcher's Corpse
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
	[71041] = 3, -- Dungeon Deserter
	[72968] = 3, -- Precious's Ribbon
	[80354] = 3, -- Timewarp
	[8326] = 3, -- Ghost
	[85612] = 3, -- Fiona's Lucky Charm
	[85613] = 3, -- Gidwin's Weapon Oil
	[85614] = 3, -- Tarenar's Talisman
	[85615] = 3, -- Pamela's Doll
	[85616] = 3, -- Vex'tul's Armbands
	[85617] = 3, -- Argus' Journal
	[85618] = 3, -- Rimblat's Stone
	[85619] = 3, -- Beezil's Cog
	[8733] = 3, -- Blessing of Blackfathom
	[89140] = 3, -- Demonic Rebirth: Cooldown
	[93337] = 3, -- Champion of Ramkahen
	[93339] = 3, -- Champion of the Earthen Ring
	[93341] = 3, -- Champion of the Guardians of Hyjal
	[93347] = 3, -- Champion of Therazane
	[93368] = 3, -- Champion of the Wildhammer Clan
	[93795] = 3, -- Stormwind Champion
	[93805] = 3, -- Ironforge Champion
	[93806] = 3, -- Darnassus Champion
	[93811] = 3, -- Exodar Champion
	[93816] = 3, -- Gilneas Champion
	[93821] = 3, -- Gnomeregan Champion
	[93825] = 3, -- Orgrimmar Champion
	[93827] = 3, -- Darkspear Champion
	[93828] = 3, -- Silvermoon Champion
	[93830] = 3, -- Bilgewater Champion
	[94158] = 3, -- Champion of the Dragonmaw Clan
	[94462] = 3, -- Undercity Champion
	[94463] = 3, -- Thunder Bluff Champion
	[95223] = 3, -- group res debuff
	[95809] = 3, -- Insanity debuff (Hunter Pet heroism)
	[97340] = 3, -- Guild Champion
	[97341] = 3, -- Guild Champion
	[97821] = 3, -- Void-Touched
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

function oUFKkthnx:UpdateAuraLists()
	-- print("UpdateAuraList")
	for _,list in ipairs(auraFilters) do
		wipe(list)
	end

	for _, obj in pairs(oUF.objects) do
		if obj.Auras then
			obj.Auras:ForceUpdate()
		end
		if obj.Buffs then
			obj.Buffs:ForceUpdate()
		end
		if obj.Debuffs then
			obj.Debuffs:ForceUpdate()
		end
	end
end

local isPlayer = {
	player = true,
	pet = true,
	vehicle = true
}

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
			-- Always show Buffs, Show boss debuffs, aura cast by the unit, or auras cast by the player's vehicle.
			return (iconFrame.filter == "HELPFUL") or (isBossDebuff) or nameplateShowAll or (isPlayer[caster]) or (caster == unit)
		end
	end,

	party = function(self, unit, iconFrame, name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, unknown, nameplateShowAll, timeMod, value1, value2, value3)
		local v = genFilter[spellID]
		if v and filters[v] then
			return filters[v](self, unit, caster)
		elseif (iconFrame.filter == "HELPFUL") then -- Buffs
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