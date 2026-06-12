--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Announces the placement or use of critical group items and spells (Feasts, Jeeves, Bloodlust, Engi CR).
-- - Design: Monitors UNIT_SPELLCAST_SUCCEEDED for group units against a pre-defined whitelist.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache API references for frequent spellcast event filtering.
local string_format = string.format
local C_Spell_GetSpellLink = C_Spell.GetSpellLink
local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local IsInGroup = IsInGroup
local SendChatMessage = SendChatMessage
local UnitName = UnitName

-- NOTE: Pre-populated table for efficient lookup of group unit IDs.
local groupUnits = { ["player"] = true, ["pet"] = true }
for i = 1, 4 do
	groupUnits["party" .. i] = true
	groupUnits["partypet" .. i] = true
end

for i = 1, 40 do
	groupUnits["raid" .. i] = true
	groupUnits["raidpet" .. i] = true
end

-- ---------------------------------------------------------------------------
-- WHITELISTS
-- ---------------------------------------------------------------------------

-- NOTE: whitelist of critical spells/items to announce.
-- Includes summons, feasts, raid-wide utilities, and Lust effects.
local importantSpells = {
	[698] = true, -- Ritual of Summoning
	[29893] = true, -- Create Soulwell
	[190336] = true, -- Conjure Refreshment Table
	[54710] = true, -- MOLL-E (Portable Mailbox)
	[67826] = true, -- Jeeves
	[226241] = true, -- Tome of the Tranquil Mind
	[256230] = true, -- Codex of the Quiet Mind
	[185709] = true, -- Hearty Feast
	[199109] = true, -- Auto-Hammer
	[259409] = true, -- Feast of the Fishes
	[259410] = true, -- Captain's Feast
	[276972] = true, -- Mystical Cauldron
	[286050] = true, -- Sanguinated Feast
	[265116] = true, -- Battle Resurrection (Engineering 8.0)
	[308458] = true, -- Bountiful Captain's Feast
	[308462] = true, -- Galley Banquet
	[345130] = true, -- Battle Resurrection (Engineering 9.0)
	[307157] = true, -- Eternal Cauldron
	[359336] = true, -- Stew of the Rocks
	[261602] = true, -- Katy's Stampwhistle
	[376664] = true, -- Ohuna Perch

	[2825] = true, -- Bloodlust
	[32182] = true, -- Heroism
	[80353] = true, -- Time Warp
	[90355] = true, -- Ancient Hysteria (Pet)
	[264667] = true, -- Primal Rage (Pet)
	[272678] = true, -- Primal Rage (Hunter Pet Mastery)
	[178207] = true, -- Drums of Fury
	[230935] = true, -- Drums of the Mountain
	[256740] = true, -- Drums of the Maelstrom
	[292686] = true, -- Ripe Tide (Drum)
	[390386] = true, -- Fury of the Aspects
	[309658] = true, -- Drums of Deathly Ferocity
	[444257] = true, -- Thunderous Drums
	[466904] = true, -- Hawk Scream

	[384893] = true, -- Fully Functional Emergency Response Cable (11.0 Engi CR)
	[453949] = true, -- Irresistible Red Button (11.0 Engi CR tool)
	[453942] = true, -- Aggramar Repair Robot 11.0
	[432877] = true, -- Aggramar Phial Cauldron
	[433292] = true, -- Aggramar Potion Cauldron
	[455960] = true, -- All-Flavor Stew
	[457285] = true, -- Midnight Gala Feast
	[457302] = true, -- Signature Sushi
	[457487] = true, -- Hearty All-Flavor Stew (Warband)
	[462211] = true, -- Hearty Signature Sushi (Warband)
	[462213] = true, -- Hearty Midnight Gala Feast (Warband)
}

-- ---------------------------------------------------------------------------
-- EVENT HANDLERS
-- ---------------------------------------------------------------------------

function Module:UpdateItemAlert(unit, castID, spellID)
	-- REASON: Filters by group unit residency and whitelist presence.
	-- Compares spellID to castID to handle potential duplicates or re-triggers.
	if groupUnits[unit] and importantSpells[spellID] and importantSpells[spellID] ~= castID then
		local spellLink = C_Spell_GetSpellLink(spellID) or C_Spell_GetSpellInfo(spellID)
		if spellLink then
			SendChatMessage(string_format(L["%s used %s"] or "%s used %s", UnitName(unit), spellLink), K.CheckChat())
			-- NOTE: Store the castID for this spellID to prevent redundant alerts from the same cast events.
			importantSpells[spellID] = castID
		end
	end
end

-- ---------------------------------------------------------------------------
-- UTILITY & REGISTRATION
-- ---------------------------------------------------------------------------

function Module:CheckGroupStatus()
	-- REASON: Manage event registration based on group state to reduce solo CPU usage.
	if IsInGroup() then
		K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateItemAlert)
	else
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateItemAlert)
	end
end

function Module:CreateItemAnnounce()
	-- NOTE: Pre-set faction-specific lust link for potential future logic usage.
	Module.factionSpell = (K.Faction == "Alliance" and 32182 or 2825)
	Module.factionSpell = C_Spell_GetSpellLink(Module.factionSpell) or C_Spell_GetSpellInfo(Module.factionSpell)

	if C["Announcements"].ItemAlert then
		Module:CheckGroupStatus()
		K:RegisterEvent("GROUP_LEFT", Module.CheckGroupStatus)
		K:RegisterEvent("GROUP_JOINED", Module.CheckGroupStatus)
	else
		K:UnregisterEvent("GROUP_LEFT", Module.CheckGroupStatus)
		K:UnregisterEvent("GROUP_JOINED", Module.CheckGroupStatus)
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateItemAlert)
	end
end
