local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

local string_format = string.format

local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local C_Spell_GetSpellLink = C_Spell and C_Spell.GetSpellLink
local IsInGroup = IsInGroup
local SendChatMessage = SendChatMessage
local UnitName = UnitName

-- Define player GUID and group units
local groupUnits = { ["player"] = true, ["pet"] = true }
for i = 1, 4 do
	groupUnits["party" .. i] = true
	groupUnits["partypet" .. i] = true
end
for i = 1, 40 do
	groupUnits["raid" .. i] = true
	groupUnits["raidpet" .. i] = true
end

-- Define important spells with IDs and descriptions
local importantSpells = {
	[54710] = true, -- Portable Mailbox
	[67826] = true, -- Jeeves
	[226241] = true, -- Tome of Tranquil Mind
	[256230] = true, -- Codex of the Quiet Mind
	[185709] = true, -- Sugar-Crusted Fish Feast
	[199109] = true, -- Auto-Hammer
	[259409] = true, -- Feast of the Fishes
	[259410] = true, -- Captain's Feast
	[276972] = true, -- Arcane Cauldron
	[286050] = true, -- Blood Feast
	[265116] = true, -- Engineering Battle Rez (BfA)
	[308458] = true, -- Grand Feast
	[308462] = true, -- Lavish Feast
	[345130] = true, -- Engineering Battle Rez (Shadowlands)
	[307157] = true, -- Eternal Cauldron
	[359336] = true, -- Stone Soup
	[324029] = true, -- Tome of Tranquil Mind (Shadowlands)
	[2825] = true, -- Bloodlust
	[32182] = true, -- Heroism
	[80353] = true, -- Time Warp
	[264667] = true, -- Primal Rage (Pet)
	[272678] = true, -- Primal Rage (Hunter Pet)
	[178207] = true, -- Drums of Fury
	[230935] = true, -- Drums of the Mountain
	[256740] = true, -- Drums of the Maelstrom
	[292686] = true, -- Drums of the Raging Tempest
	[309658] = true, -- Drums of Deathly Ferocity
	[390386] = true, -- Fury of the Aspects
}

-- Function to handle spell cast alerts
function Module:UpdateItemAlert(unit, castID, spellID)
	if groupUnits[unit] and importantSpells[spellID] and (importantSpells[spellID] ~= castID) then
		SendChatMessage(string_format("%s used %s", UnitName(unit), C_Spell_GetSpellLink(spellID) or C_Spell_GetSpellInfo(spellID)), K.CheckChat())
		importantSpells[spellID] = castID
	end
end

-- Function to check if the player is in a group and register events accordingly
function Module:CheckGroupStatus()
	if IsInGroup() then
		K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateItemAlert)
	else
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateItemAlert)
	end
end

-- Main function to handle spell and item alerts
function Module:CreateItemAnnounce()
	Module.factionSpell = K.Faction == "Alliance" and 32182 or 2825
	Module.factionSpell = C_Spell_GetSpellLink(Module.factionSpell)

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
