local K, C = KkthnxUI[1], KkthnxUI[2]

-- Cache API functions
local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local C_Timer_After = C_Timer.After

-- Constants
local SPELL_IDS = {
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
}

-- Optimized spell name extraction
local function ExtractSpellName(spellInfo)
	if spellInfo and type(spellInfo) == "table" then
		return spellInfo.name
	elseif spellInfo and type(spellInfo) == "string" then
		return spellInfo
	end
	return nil
end

-- Efficient spell name validation
local function IsValidSpellName(name)
	return name and name ~= "" and name ~= "Empty"
end

-- Initialize the bad buffs table
C.CheckBadBuffs = {}

-- Optimized table population with caching
local spellNameCache = {}
local function PopulateBadBuffs()
	-- Clear existing data
	wipe(C.CheckBadBuffs)
	wipe(spellNameCache)

	-- Populate table efficiently
	for _, spellId in ipairs(SPELL_IDS) do
		-- Check cache first
		local spellName = spellNameCache[spellId]
		if not spellName then
			local spellInfo = C_Spell_GetSpellInfo(spellId)
			spellName = ExtractSpellName(spellInfo)
			spellNameCache[spellId] = spellName
		end

		if IsValidSpellName(spellName) then
			C.CheckBadBuffs[spellName] = true
		end
	end
end

-- Initial population
PopulateBadBuffs()

-- Register for spell updates with debouncing
local spellUpdatePending = false
local function HandleSpellsChanged()
	if spellUpdatePending then
		return
	end

	spellUpdatePending = true
	C_Timer_After(0.1, function()
		spellUpdatePending = false
		PopulateBadBuffs()
	end)
end

K:RegisterEvent("SPELLS_CHANGED", HandleSpellsChanged)
