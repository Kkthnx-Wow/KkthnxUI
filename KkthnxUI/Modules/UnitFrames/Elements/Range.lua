--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Manages unit opacity based on range from the player.
-- - Design: Modified oUF_Range element supporting multiple unit types (friendly, enemy, pet).
-- - Events: OnUpdate (throttled)
-----------------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF
local K, C = unpack(KkthnxUI)

local _FRAMES = {}
local rangeTimer

-- REASON: Localize C-functions (Snake Case)
local string_find = _G.string.find
-- REASON: table_remove removed; Disable() uses O(1) swap-remove, making this import unnecessary.
local table_insert = _G.table.insert
local tonumber = _G.tonumber
local next = _G.next
local select = _G.select

-- REASON: Localize Globals
local C_Spell = _G.C_Spell
local C_Timer = _G.C_Timer
local CheckInteractDistance = _G.CheckInteractDistance
local GetNumGroupMembers = _G.GetNumGroupMembers
local InCombatLockdown = _G.InCombatLockdown
local IsInRaid = _G.IsInRaid
local IsSpellKnownOrOverridesKnown = _G.IsSpellKnownOrOverridesKnown
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitInRange = _G.UnitInRange
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitPhaseReason = _G.UnitPhaseReason

local IsSpellInRange = C_Spell.IsSpellInRange
local myClass = select(2, UnitClass("player"))

local IsSecret = K.IsSecret

local function ReadableBool(value)
	if IsSecret(value) then
		return nil
	end

	return value and true or false
end

-- PERF: Pre-cache group unit tokens to avoid high-frequency string concatenations on every update frame.
-- REASON: This completely eliminates string allocations and subsequent GC overhead during group scanning.
local groupUnits = {
	party = {},
	raid = {},
}
for i = 1, 4 do
	groupUnits.party[i] = "party" .. i
end
for i = 1, 40 do
	groupUnits.raid[i] = "raid" .. i
end

-- REASON: Returns the unit token (partyN/raidN) for a given unit GUID/name if they are in your group.
local function GetGroupUnit(unit)
	local isPlayer = ReadableBool(UnitIsUnit(unit, "player"))
	if isPlayer then
		return
	end

	if string_find(unit, "party") or string_find(unit, "raid") then
		return unit
	end

	-- REASON: Only scan group if unit isn't already a token.
	local inParty = ReadableBool(UnitInParty(unit))
	local inRaid = ReadableBool(UnitInRaid(unit))
	if inParty or inRaid then
		local isInRaid = IsInRaid()
		local prefix = isInRaid and "raid" or "party"
		local tokens = groupUnits[prefix]
		for i = 1, GetNumGroupMembers() do
			local groupUnit = tokens[i]
			if groupUnit and ReadableBool(UnitIsUnit(unit, groupUnit)) then
				return groupUnit
			end
		end
	end
end

local CHECK_SPELLS = {
	FRIENDLY = {
		DEATHKNIGHT = {
			[47541] = "Death Coil",
		},
		DEMONHUNTER = {},
		DRUID = {
			[8936] = "Regrowth",
		},
		EVOKER = {
			[355913] = "Emerald Blossom",
		},
		HUNTER = {},
		MAGE = {
			[1459] = "Arcane Intellect",
		},
		MONK = {
			[116670] = "Vivify",
		},
		PALADIN = {
			[85673] = "Word of Glory",
		},
		PRIEST = {
			[17] = "Power Word: Shield",
		},
		ROGUE = {
			[36554] = "Shadowstep",
			[921] = "Pick Pocket",
		},
		SHAMAN = {
			[8004] = "Healing Surge",
		},
		WARLOCK = {
			[5697] = "Unending Breath",
		},
		WARRIOR = {},
	},

	ENEMY = {
		DEATHKNIGHT = {
			[49576] = "Death Grip",
		},
		DEMONHUNTER = {
			[278326] = "Consume Magic",
		},
		DRUID = {
			[8921] = "Moonfire",
		},
		EVOKER = {
			[362969] = "Azure Strike",
		},
		HUNTER = {
			[75] = "Auto Shot",
		},
		MAGE = {
			[2139] = "Counterspell",
		},
		MONK = {
			[115546] = "Provoke",
		},
		PALADIN = {
			[20473] = "Holy Shock",
			[20271] = "Judgement",
		},
		PRIEST = {
			[589] = "Shadow Word: Pain",
		},
		ROGUE = {
			[36554] = "Shadowstep",
		},
		SHAMAN = {
			[8042] = "Earth Shock",
			[188196] = "Lightning Bolt",
		},
		WARLOCK = {
			[234153] = "Drain Life",
		},
		WARRIOR = {
			[355] = "Taunt",
		},
	},

	RESURRECT = {
		DEATHKNIGHT = {
			[61999] = "Raise Ally",
		},
		DEMONHUNTER = {},
		DRUID = {
			[50769] = "Revive",
		},
		EVOKER = {
			[361227] = "Return",
		},
		HUNTER = {},
		MAGE = {},
		MONK = {
			[115178] = "Resuscitate",
		},
		PALADIN = {
			[7328] = "Redemption",
		},
		PRIEST = {
			[2006] = "Resurrection",
		},
		ROGUE = {},
		SHAMAN = {
			[2008] = "Ancestral Spirit",
		},
		WARLOCK = {
			[20707] = "Soulstone",
		},
		WARRIOR = {},
	},

	PET = {
		DEATHKNIGHT = {
			[47541] = "Death Coil",
		},
		DEMONHUNTER = {},
		DRUID = {},
		EVOKER = {},
		HUNTER = {
			[136] = "Mend Pet",
		},
		MAGE = {},
		MONK = {},
		PALADIN = {},
		PRIEST = {},
		ROGUE = {},
		SHAMAN = {},
		WARLOCK = {
			[755] = "Health Funnel",
		},
		WARRIOR = {},
	},
}

local list = {}

local function UpdateRangeList(db)
	local spells = {}
	for spell, value in next, db do
		if value then
			local id = tonumber(spell)
			if not id then -- support spells by name
				local spellInfo = C_Spell.GetSpellInfo(spell)
				if spellInfo then
					id = spellInfo.spellID
				end
			end

			if id and IsSpellKnownOrOverridesKnown(id) then
				spells[id] = true
			end
		end
	end

	return spells
end

local function UpdateRangeSpells()
	list[1] = UpdateRangeList(CHECK_SPELLS.ENEMY[myClass])
	list[2] = UpdateRangeList(CHECK_SPELLS.FRIENDLY[myClass])
	list[3] = UpdateRangeList(CHECK_SPELLS.RESURRECT[myClass])
	list[4] = UpdateRangeList(CHECK_SPELLS.PET[myClass])
end

local function UnitSpellRange(unit, spells)
	local failed
	for spell in next, spells do
		local range = IsSpellInRange(spell, unit)
		if IsSecret(range) then
			-- SECRET (12.0): Blizzard can hide range booleans in combat/instances.
			-- Treat that as unknown instead of testing it and throwing.
			return
		end

		if range then
			return true
		elseif range ~= nil then
			failed = true -- keep looking for other spells
		end
	end
	if failed then
		return false
	end
end

-- REASON: Checks if a unit is within range of any spell in the 'which' category list.
local function UnitInSpellsRange(unit, which)
	local spells = list[which]
	-- REASON: If list is empty, default to range=1 (true-ish) to fallback to interaction check.
	local range = (not next(spells) and 1) or UnitSpellRange(unit, spells)
	if IsSecret(range) then
		return 1
	end

	-- REASON: Fallback to InteractDistance(4) for follow range if spell check fails or is N/A, and not in combat.
	if (not range or range == 1) and not InCombatLockdown() then
		local interactRange = CheckInteractDistance(unit, 4)
		if IsSecret(interactRange) then
			return 1
		end

		return interactRange
	else
		return (range == nil and 1) or range -- REASON: nil implies cant check, so assume in range to avoid ghosting.
	end
end

-- REASON: Specific check for friendly units using PhaseReason and UnitInRange API.
local function FriendlyInRange(realUnit)
	local unit = GetGroupUnit(realUnit) or realUnit

	local isPlayer = ReadableBool(UnitIsPlayer(unit))
	if isPlayer then
		local phaseReason = UnitPhaseReason and UnitPhaseReason(unit)
		if not IsSecret(phaseReason) and phaseReason then
			return false
		end
	end

	local range, checked = UnitInRange(unit)
	if IsSecret(range) or IsSecret(checked) then
		-- SECRET (12.0): UnitInRange can return secret booleans. Fall back to
		-- spell/interaction checks, and if those are also unavailable they assume
		-- in-range rather than fading on unreadable data.
		return UnitInSpellsRange(unit, 2)
	end

	if checked and not range then
		return false -- REASON: Blizzard API confirms unit is out of range.
	end

	return UnitInSpellsRange(unit, 2)
end

-- REASON: Main update function to determine alpha based on range status.
local function Update(self, event)
	local element = self.RangeFader
	local unit = self.unit

	-- REASON: Respect globally disabled range setting.
	if C and C["Unitframe"] and C["Unitframe"].Range == false then
		element.RangeAlpha = element.MaxAlpha or element.insideAlpha
		self:SetAlpha(element.RangeAlpha)
		if element.PostUpdate then
			return element:PostUpdate(self, true)
		end
		return
	end

	-- PERF: Cache alpha fallback values locally to reduce hash lookups and logic evaluation.
	local maxAlpha = element.MaxAlpha or element.insideAlpha
	local minAlpha = element.MinAlpha or element.outsideAlpha

	local forceInRange = ReadableBool(self.forceInRange)
	local forceNotInRange = ReadableBool(self.forceNotInRange)

	if forceInRange or unit == "player" then
		element.RangeAlpha = maxAlpha
	elseif forceNotInRange then
		element.RangeAlpha = minAlpha
	elseif unit then
		local isDead = ReadableBool(UnitIsDeadOrGhost(unit))
		local canAttack = ReadableBool(UnitCanAttack("player", unit))
		local isPet = ReadableBool(UnitIsUnit("pet", unit))
		local isConnected = ReadableBool(UnitIsConnected(unit))

		if isDead then
			element.RangeAlpha = UnitInSpellsRange(unit, 3) == true and maxAlpha or minAlpha
		elseif canAttack then
			element.RangeAlpha = UnitInSpellsRange(unit, 1) and maxAlpha or minAlpha
		elseif isPet then
			element.RangeAlpha = UnitInSpellsRange(unit, 4) and maxAlpha or minAlpha
		elseif isConnected then
			element.RangeAlpha = FriendlyInRange(unit) and maxAlpha or minAlpha
		elseif isDead == nil or canAttack == nil or isPet == nil or isConnected == nil then
			-- SECRET (12.0): If classification booleans are unreadable, keep the
			-- frame visible rather than testing a secret value or fading on unknowns.
			element.RangeAlpha = maxAlpha
		else
			element.RangeAlpha = minAlpha
		end
	else
		element.RangeAlpha = maxAlpha
	end

	self:SetAlpha(element.RangeAlpha)

	if element.PostUpdate then
		return element:PostUpdate(self, element.RangeAlpha == maxAlpha)
	end
end

-- REASON: Overridable path for custom range checking logic.
local function Path(self, ...)
	return (self.RangeFader.Override or Update)(self, ...)
end

-- REASON: Internal throttled update loop (0.2s).
-- PERF: Use numerical loop iteration over sequential _FRAMES table instead of next pairs.
-- PERF: Use C_Timer.NewTicker instead of OnUpdate to avoid per-frame execution overhead.
local function OnRangeUpdate()
	for i = 1, #_FRAMES do
		local object = _FRAMES[i]
		if object and object:IsShown() then
			Path(object, "OnUpdate")
		end
	end
end

local function Enable(self)
	local element = self.RangeFader
	if element then
		-- Respect user setting to disable range fading on unitframes
		if C and C["Unitframe"] and C["Unitframe"].Range == false then
			return false
		end
		element.__owner = self
		element.insideAlpha = element.insideAlpha or 1
		element.outsideAlpha = element.outsideAlpha or 0.55

		-- Initialize spell list if not done yet
		if not list[1] then
			UpdateRangeSpells()
		end

		if not rangeTimer then
			rangeTimer = C_Timer.NewTicker(0.2, OnRangeUpdate)
		end

		table_insert(_FRAMES, self)

		return true
	end
end

local function Disable(self)
	local element = self.RangeFader
	if element then
		-- PERF: O(1) swap-remove replaces the O(n) table_remove that shifted the entire array on disable.
		-- Iteration order does not matter for _FRAMES, so swapping with the last element is safe.
		for i = 1, #_FRAMES do
			if _FRAMES[i] == self then
				_FRAMES[i] = _FRAMES[#_FRAMES]
				_FRAMES[#_FRAMES] = nil
				break
			end
		end
		self:SetAlpha(element.MaxAlpha or element.insideAlpha)

		if #_FRAMES == 0 and rangeTimer then
			rangeTimer:Cancel()
			rangeTimer = nil
		end
	end
end

oUF:AddElement("RangeFader", nil, Enable, Disable)
