local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

-- Lua API
local _G = _G

-- Wow API
local UnitCanAttack = _G.UnitCanAttack
local UnitPlayerControlled = _G.UnitPlayerControlled

-- Global variables that we don't cache, list them here for mikk"s FindGlobals script
-- GLOBALS:

local blackList = {
	-- Useless
	[113942] = true, -- Demonic: Gateway
	[114216] = true, -- Angelic Bulwark
	[117870] = true, -- Touch of The Titans
	[123981] = true, -- Perdition
	[124273] = true, -- Stagger
	[124274] = true, -- Stagger
	[124275] = true, -- Stagger
	[126434] = true, -- Tushui Champion
	[126436] = true, -- Huojin Champion
	[143625] = true, -- Brawling Champion
	[15007] = true, -- Ress Sickness
	[170616] = true, -- Pet Deserter
	[182957] = true, -- Treasures of Stormheim
	[182958] = true, -- Treasures of Azsuna
	[185719] = true, -- Treasures of Val'sharah
	[186401] = true, -- Sign of the Skirmisher
	[186403] = true, -- Sign of Battle
	[186404] = true, -- Sign of the Emissary
	[186406] = true, -- Sign of the Critter
	[188741] = true, -- Treasures of Highmountain
	[199416] = true, -- Treasures of Suramar
	[225787] = true, -- Sign of the Warrior
	[225788] = true, -- Sign of the Emissary
	[227723] = true, -- Mana Divining Stone
	[231115] = true, -- Treasures of Broken Shore
	[23445] = true, -- Evil Twin
	[24755] = true, -- Tricked or Treated
	[25163] = true, -- Oozeling's Disgusting Aura
	[25771] = true, -- Forbearance
	[26013] = true, -- Deserter
	[36032] = true, -- Arcane Charge
	[36893] = true, -- Transporter Malfunction
	[36900] = true, -- Soul Split: Evil!
	[36901] = true, -- Soul Split: Good
	[39953] = true, -- A'dal's Song of Battle
	[41425] = true, -- Hypothermia
	[55711] = true, -- Weakened Heart
	[57723] = true, -- Exhaustion
	[57724] = true, -- Sated
	[57819] = true, -- Argent Champion
	[57820] = true, -- Ebon Champion
	[57821] = true, -- Champion of the Kirin Tor
	[58539] = true, -- Watcher's Corpse
	[60023] = true, -- Scourge Banner Aura (Boneguard Commander in Icecrown)
	[62594] = true, -- Stormwind Champion"s Pennant
	[62596] = true, -- Stormwind Valiant"s Pennant
	[63395] = true, -- Gnomeregan Valiant"s Pennant
	[63396] = true, -- Gnomeregan Champion"s Pennant
	[63398] = true, -- Sen"jin Valiant"s Pennant
	[63399] = true, -- Sen"jin Champion"s Pennant
	[63402] = true, -- Silvermoon Valiant"s Pennant
	[63403] = true, -- Silvermoon Champion"s Pennant
	[63405] = true, -- Darnassus Valiant"s Pennant
	[63406] = true, -- Darnassus Champion"s Pennant
	[63422] = true, -- Exodar Valiant"s Pennant
	[63423] = true, -- Exodar Champion"s Pennant
	[63426] = true, -- Ironforge Valiant"s Pennant
	[63427] = true, -- Ironforge Champion"s Pennant
	[63429] = true, -- Undercity Valiant"s Pennant
	[63430] = true, -- Undercity Champion"s Pennant
	[63432] = true, -- Orgrimmar Valiant"s Pennant
	[63433] = true, -- Orgrimmar Champion"s Pennant
	[63435] = true, -- Thunder Bluff Valiant"s Pennant
	[63436] = true, -- Thunder Bluff Champion"s Pennant
	[63501] = true, -- Argent Crusade Champion"s Pennant
	[71041] = true, -- Dungeon Deserter
	[71909] = true, -- Heartbroken
	[72968] = true, -- Precious's Ribbon
	[80354] = true, -- Timewarp
	[8326] = true, -- Ghost
	[85612] = true, -- Fiona's Lucky Charm
	[85613] = true, -- Gidwin's Weapon Oil
	[85614] = true, -- Tarenar's Talisman
	[85615] = true, -- Pamela's Doll
	[85616] = true, -- Vex'tul's Armbands
	[85617] = true, -- Argus' Journal
	[85618] = true, -- Rimblat's Stone
	[85619] = true, -- Beezil's Cog
	[8733] = true, -- Blessing of Blackfathom
	[89140] = true, -- Demonic Rebirth: Cooldown
	[93337] = true, -- Champion of Ramkahen
	[93339] = true, -- Champion of the Earthen Ring
	[93341] = true, -- Champion of the Guardians of Hyjal
	[93347] = true, -- Champion of Therazane
	[93368] = true, -- Champion of the Wildhammer Clan
	[93795] = true, -- Stormwind Champion
	[93805] = true, -- Ironforge Champion
	[93806] = true, -- Darnassus Champion
	[93811] = true, -- Exodar Champion
	[93816] = true, -- Gilneas Champion
	[93821] = true, -- Gnomeregan Champion
	[93825] = true, -- Orgrimmar Champion
	[93827] = true, -- Darkspear Champion
	[93828] = true, -- Silvermoon Champion
	[93830] = true, -- Bilgewater Champion
	[94158] = true, -- Champion of the Dragonmaw Clan
	[94462] = true, -- Undercity Champion
	[94463] = true, -- Thunder Bluff Champion
	[95223] = true, -- group res debuff
	[95809] = true, -- Insanity debuff (Hunter Pet heroism)
	[97340] = true, -- Guild Champion
	[97341] = true, -- Guild Champion
	[97821] = true, -- Void-Touched
}

local arenaFilter = {}
local bossFilter = {}
local genFilter = {}
local mountFilter = {}

for _, id in next, C_MountJournal.GetMountIDs() do
	local _, spellID = C_MountJournal.GetMountInfoByID(id)

	mountFilter[spellID] = true
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

function K.PetAuraFilter(_, _, _, _, _, _, _, _, _, _, caster, _, _, spellID, _, _, _, _, _, _, _, _)
	-- blackList
	if blackList[spellID] then
		return false
	end

	return (caster and isPlayer[caster]) and (not genFilter[spellID] == 3)
end

function K.TargetAuraFilter(self, unit, iconFrame, _, _, _, _, _, _, _, caster, _, _, spellID, _, isBossDebuff, _, nameplateShowAll, _, _, _, _)
	-- blackList
	if blackList[spellID] then
		return false
	end

	-- Mounts
	if mountFilter[spellID] then
		return false
	end

	local v = genFilter[spellID]
	if v and filters[v] then
		return filters[v](self, unit, caster)
	elseif UnitPlayerControlled(unit) then
		return true
	else
		return (iconFrame.filter == "HELPFUL") or (isBossDebuff) or nameplateShowAll or (isPlayer[caster]) or (caster == unit)
	end
end

function K.PartyAuraFilter(self, unit, iconFrame, _, _, _, _, _, _, _, caster, _, nameplateShowPersonal, spellID, _, isBossDebuff, _, nameplateShowAll, _, _, _, _)
	-- blackList
	if blackList[spellID] then
		return false
	end

	-- Mounts
	if mountFilter[spellID] then
		return false
	end

	local v = genFilter[spellID]
	if v and filters[v] then
		return filters[v](self, unit, caster)
	elseif (iconFrame.filter == "HELPFUL") then -- BUFFS
		return (nameplateShowPersonal and isPlayer[caster]) or isBossDebuff or nameplateShowAll
	else
		return true
	end
end

function K.ArenaAuraFilter(_, _, _, _, _, _, _, _, _, _, _, _, _, spellID, _, _, _, _, _, _, _, _)
	-- blackList
	if blackList[spellID] then
		return false
	end

	-- Mounts
	if mountFilter[spellID] then
		return false
	end

	return arenaFilter[spellID]
end

function K.BossAuraFilter(_, _, _, _, _, _, _, _, _, _, caster, _, _, spellID, _, isBossDebuff, _, _, _, _, _, _)
	-- blackList
	if blackList[spellID] then
		return false
	end

	local v = bossFilter[spellID]
	if v == 1 then
		return isPlayer[caster]
	elseif v == 0 then
		return true
	else
		return isBossDebuff
	end
end