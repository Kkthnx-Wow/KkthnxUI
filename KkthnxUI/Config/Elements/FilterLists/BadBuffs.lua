local K, C = KkthnxUI[1], KkthnxUI[2]

local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local type = type
local tostring = tostring

local function GetSpellName(id)
	local spellInfo = C_Spell_GetSpellInfo(id)
	if not spellInfo then
		return nil
	end

	if type(spellInfo) == "table" then
		return spellInfo.name
	end

	return spellInfo
end

local badIds = {
	172003,
	172008,
	172010,
	172015,
	172020,
	24709,
	24710,
	24712,
	24723,
	24732,
	24735,
	24740,
	279509,
	44212,
	58493,
	61716,
	61734,
	61781,
	261477,
	354550,
	354481,
	279997, -- DEBUG
}

C.CheckBadBuffs = {}

for i = 1, #badIds do
	local id = badIds[i]
	C.CheckBadBuffs[id] = true

	local name = GetSpellName(id)
	if name then
		C.CheckBadBuffs[name] = true
	else
		K.Print("|cffff0000WARNING: [BadBuffsFilter] - spell ID [" .. tostring(id) .. "] not found (uncached/invalid).|r")
	end
end
