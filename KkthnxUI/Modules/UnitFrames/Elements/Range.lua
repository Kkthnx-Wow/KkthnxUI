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
local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Unitframes")

local _FRAMES = {}
local OnRangeFrame

-- REASON: Localize C-functions (Snake Case)
local strfind = _G.string.find
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local tonumber = _G.tonumber
local next = _G.next
local select = _G.select

-- REASON: Localize Globals
local C_Spell = _G.C_Spell
local CheckInteractDistance = _G.CheckInteractDistance
local CreateFrame = _G.CreateFrame
local GetNumGroupMembers = _G.GetNumGroupMembers
local InCombatLockdown = _G.InCombatLockdown
local IsInRaid = _G.IsInRaid
local IsSpellInSpellBook = C_SpellBook.IsSpellInSpellBook or IsSpellKnownOrOverridesKnown
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitInRange = _G.UnitInRange
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDeadOrGhost = _G.UnitIsDeadOrGhost
local UnitIsFriend = _G.UnitIsFriend
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitPhaseReason = _G.UnitPhaseReason

local IsSpellInRange = C_Spell.IsSpellInRange
local myClass = select(2, UnitClass("player"))

local PhaseReason = Enum.PhaseReason

-- REASON: Returns the unit token (partyN/raidN) for a given unit GUID/name if they are in your group.
local function GetGroupUnit(unit)
	if UnitIsUnit(unit, "player") then
		return
	end

	if strfind(unit, "party") or strfind(unit, "raid") then
		return unit
	end

	-- REASON: Only scan group if unit isn't already a token.
	if UnitInParty(unit) or UnitInRaid(unit) then
		local isInRaid = IsInRaid()
		for i = 1, GetNumGroupMembers() do
			local groupUnit = (isInRaid and "raid" or "party") .. i
			if UnitIsUnit(unit, groupUnit) then
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

			if id and IsSpellInSpellBook(id, nil, true) then
				spells[id] = true
			end
		end
	end

	return spells
end

function Module:UpdateRangeSpells(event, arg1)
	if event == "CHARACTER_POINTS_CHANGED" and (not arg1 or arg1 > 0) then
		return -- Not interested in gained points from leveling
	end

	list[1] = UpdateRangeList(CHECK_SPELLS.ENEMY[myClass])
	list[2] = UpdateRangeList(CHECK_SPELLS.FRIENDLY[myClass])
	list[3] = UpdateRangeList(CHECK_SPELLS.RESURRECT[myClass])
	list[4] = UpdateRangeList(CHECK_SPELLS.PET[myClass])
end

local function UnitSpellRange(unit, spells)
	local failed
	for spell in next, spells do
		local range = IsSpellInRange(spell, unit)
		if range then
			return true
		elseif range ~= nil then
			failed = true -- oh no
		end
	end

	if failed then
		return false
	end
end

-- REASON: Checks if a unit is within range of any spell in the 'which' category list.
local function UnitInSpellsRange(unit, which)
	local spells = list[which]
	local range = (not next(spells) and 1) or UnitSpellRange(unit, spells)

	if (not range or range == 1) and not InCombatLockdown() then
		return CheckInteractDistance(unit, 4) -- check follow interact when not in combat
	else
		return (range == nil and 1) or range -- nil: various reason it cant be checked; ie: cant be cast on the unit
	end
end

-- REASON: Specific check for friendly units using PhaseReason and UnitInRange API.
local function FriendlyInRange(realUnit, element)
	local unit = GetGroupUnit(realUnit) or realUnit

	if UnitIsPlayer(unit) then
		local phaseReason = UnitPhaseReason(unit)
		if phaseReason == PhaseReason.TimerunningHwt then
			if not IsInInstance() then -- phased in open world (hero / nonhero) but not phased in dungeons
				return false
			end
		elseif phaseReason then
			return false
		end
	end

	local inRange, wasChecked = UnitInRange(unit)
	if K.IsSecretValue(wasChecked) then
		if element and (UnitInParty(unit) or UnitInRaid(unit)) then -- if its eligible
			element.isInRange, element.checkedRange = inRange, wasChecked
			return -- will be handled by these values so no need to proceed
		end
	elseif wasChecked and K.NotSecretValue(inRange) and not inRange then
		return false -- blizz checked and unit is out of range
	end

	return UnitInSpellsRange(unit, 2)
end

-- REASON: Main update function to determine alpha based on range status.
local function Update(self, event)
	local element = self.RangeFader
	local unit = self.unit

	if not element then
		return
	end

	-- clear these if we arent checking them (these are secret values on retail)
	element.isInRange, element.checkedRange = nil, nil

	local exists = UnitExists(unit)
	if self.forceInRange or (exists and unit == "player") then
		element.RangeAlpha = element.insideAlpha
	elseif self.forceNotInRange then
		element.RangeAlpha = element.outsideAlpha
	elseif exists then
		if UnitIsDeadOrGhost(unit) then
			element.RangeAlpha = UnitInSpellsRange(unit, 3) == true and element.insideAlpha or element.outsideAlpha
		elseif UnitCanAttack("player", unit) then
			element.RangeAlpha = UnitInSpellsRange(unit, 1) and element.insideAlpha or element.outsideAlpha
		elseif UnitIsUnit("pet", unit) then
			element.RangeAlpha = UnitInSpellsRange(unit, 4) and element.insideAlpha or element.outsideAlpha
		elseif UnitIsConnected(unit) then
			element.RangeAlpha = FriendlyInRange(unit, element) and element.insideAlpha or element.outsideAlpha
		else
			element.RangeAlpha = element.outsideAlpha
		end
	else
		element.RangeAlpha = element.insideAlpha
	end

	self:SetAlpha(element.RangeAlpha)
end

-- REASON: Overridable path for custom range checking logic.
local function Path(self, ...)
	return (self.RangeFader.Override or Update)(self, ...)
end

-- REASON: Internal throttled update loop (0.2s).
local timer = 0
local function OnRangeUpdate(_, elapsed)
	timer = timer + elapsed

	if timer >= 0.20 then
		for _, object in next, _FRAMES do
			if object:IsShown() then
				Path(object, "OnUpdate")
			end
		end

		timer = 0
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
			Module:UpdateRangeSpells()
		end

		if not OnRangeFrame then
			OnRangeFrame = CreateFrame("Frame")
			OnRangeFrame:SetScript("OnUpdate", OnRangeUpdate)
		end

		table_insert(_FRAMES, self)
		OnRangeFrame:Show()

		return true
	end
end

local function Disable(self)
	local element = self.RangeFader
	if element then
		for index, frame in next, _FRAMES do
			if frame == self then
				table_remove(_FRAMES, index)
				break
			end
		end
		self:SetAlpha(element.MaxAlpha or element.insideAlpha)

		if #_FRAMES == 0 then
			OnRangeFrame:Hide()
		end
	end
end

oUF:AddElement("RangeFader", nil, Enable, Disable)
