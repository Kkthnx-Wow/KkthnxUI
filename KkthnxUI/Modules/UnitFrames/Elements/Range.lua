--[[
# Element: RangeFader, modify from oUF_Range

Changes the opacity of a unit frame based on whether the frame's unit is in the player's range.

## Widget

RangeFader - A table containing opacity values.

## Notes

Offline units are handled as if they are in range.
Supports multiple unit types: enemies, friends, pets, and dead units.
Uses class-specific spells for accurate range checking.

## Options

.outsideAlpha - Opacity when the unit is out of range. Defaults to 0.55 (number)[0-1].
.insideAlpha  - Opacity when the unit is within range. Defaults to 1 (number)[0-1].
.MaxAlpha     - Maximum alpha value (in range). Falls back to insideAlpha if not set.
.MinAlpha     - Minimum alpha value (out of range). Falls back to outsideAlpha if not set.

## Examples

	-- Register with oUF
	self.RangeFader = {
		insideAlpha = 1,
		outsideAlpha = 1/2,
		MaxAlpha = 1,
		MinAlpha = 0.3,
	}
--]]

local _, ns = ...
local oUF = ns.oUF

local _FRAMES = {}
local OnRangeFrame

local next = next
local strfind = strfind
local UnitInRange, UnitIsConnected = UnitInRange, UnitIsConnected
local InCombatLockdown, CheckInteractDistance, UnitCanAttack = InCombatLockdown, CheckInteractDistance, UnitCanAttack
local UnitIsDeadOrGhost, UnitIsPlayer, UnitIsUnit, UnitIsFriend = UnitIsDeadOrGhost, UnitIsPlayer, UnitIsUnit, UnitIsFriend
local UnitPhaseReason = UnitPhaseReason
local UnitInParty, UnitInRaid = UnitInParty, UnitInRaid
local GetNumGroupMembers, IsInRaid = GetNumGroupMembers, IsInRaid
local IsSpellKnownOrOverridesKnown = IsSpellKnownOrOverridesKnown
local IsSpellInRange = C_Spell.IsSpellInRange
local myClass = select(2, UnitClass("player"))

local function GetGroupUnit(unit)
	if UnitIsUnit(unit, "player") then
		return
	end
	if strfind(unit, "party") or strfind(unit, "raid") then
		return unit
	end

	-- returns the unit as raid# or party# when grouped
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

local function UnitInSpellsRange(unit, which)
	local spells = list[which]
	local range = (not next(spells) and 1) or UnitSpellRange(unit, spells)

	if (not range or range == 1) and not InCombatLockdown() then
		return CheckInteractDistance(unit, 4) -- check follow interact when not in combat
	else
		return (range == nil and 1) or range -- nil: various reason it cant be checked; ie: cant be cast on the unit
	end
end

local function FriendlyInRange(realUnit)
	local unit = GetGroupUnit(realUnit) or realUnit

	if UnitIsPlayer(unit) then
		if UnitPhaseReason and UnitPhaseReason(unit) then
			return false
		end
	end

	local range, checked = UnitInRange(unit)
	if checked and not range then
		return false -- blizz checked and unit is out of range
	end

	return UnitInSpellsRange(unit, 2)
end

local function Update(self, event)
	local element = self.RangeFader
	local unit = self.unit

	if not unit then
		unit = self.unit
	end

	if self.forceInRange or unit == "player" then
		element.RangeAlpha = element.MaxAlpha or element.insideAlpha
	elseif self.forceNotInRange then
		element.RangeAlpha = element.MinAlpha or element.outsideAlpha
	elseif unit then
		if UnitIsDeadOrGhost(unit) then
			element.RangeAlpha = UnitInSpellsRange(unit, 3) == true and (element.MaxAlpha or element.insideAlpha) or (element.MinAlpha or element.outsideAlpha)
		elseif UnitCanAttack("player", unit) then
			element.RangeAlpha = UnitInSpellsRange(unit, 1) and (element.MaxAlpha or element.insideAlpha) or (element.MinAlpha or element.outsideAlpha)
		elseif UnitIsUnit("pet", unit) then
			element.RangeAlpha = UnitInSpellsRange(unit, 4) and (element.MaxAlpha or element.insideAlpha) or (element.MinAlpha or element.outsideAlpha)
		elseif UnitIsConnected(unit) then
			element.RangeAlpha = FriendlyInRange(unit) and (element.MaxAlpha or element.insideAlpha) or (element.MinAlpha or element.outsideAlpha)
		else
			element.RangeAlpha = element.MinAlpha or element.outsideAlpha
		end
	else
		element.RangeAlpha = element.MaxAlpha or element.insideAlpha
	end

	self:SetAlpha(element.RangeAlpha)

	--[[ Callback: Range:PostUpdate(object, inRange, checkedRange, isConnected)
	Called after the element has been updated.

	* self         - the Range element
	* object       - the parent object
	* inRange      - indicates if the unit was within 40 yards of the player (boolean)
	* checkedRange - indicates if the range check was actually performed (boolean)
	* isConnected  - indicates if the unit is online (boolean)
	--]]
	if element.PostUpdate then
		return element:PostUpdate(self, element.RangeAlpha == (element.MaxAlpha or element.insideAlpha))
	end
end

local function Path(self, ...)
	--[[ Override: Range.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.RangeFader.Override or Update)(self, ...)
end

-- Internal updating method
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
		element.__owner = self
		element.insideAlpha = element.insideAlpha or 1
		element.outsideAlpha = element.outsideAlpha or 0.55

		-- Initialize spell list if not done yet
		if not list[1] then
			UpdateRangeSpells()
		end

		if not OnRangeFrame then
			OnRangeFrame = CreateFrame("Frame")
			OnRangeFrame:SetScript("OnUpdate", OnRangeUpdate)
		end

		table.insert(_FRAMES, self)
		OnRangeFrame:Show()

		return true
	end
end

local function Disable(self)
	local element = self.RangeFader
	if element then
		for index, frame in next, _FRAMES do
			if frame == self then
				table.remove(_FRAMES, index)
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
