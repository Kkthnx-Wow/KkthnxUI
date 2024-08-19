local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

-- Localize WoW API functions
local string_format = string.format
local C_Spell_GetSpellLink = C_Spell.GetSpellLink
local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
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

-- Define important spells with IDs
local importantSpells = {
	[54710] = true,
	[67826] = true,
	[226241] = true,
	[256230] = true,
	[185709] = true,
	[199109] = true,
	[259409] = true,
	[259410] = true,
	[276972] = true,
	[286050] = true,
	[265116] = true,
	[308458] = true,
	[308462] = true,
	[345130] = true,
	[307157] = true,
	[359336] = true,
	[324029] = true,
	[2825] = true,
	[32182] = true,
	[80353] = true,
	[264667] = true,
	[272678] = true,
	[178207] = true,
	[230935] = true,
	[256740] = true,
	[292686] = true,
	[309658] = true,
	[390386] = true,
}

-- Function to handle spell cast alerts
function Module:UpdateItemAlert(unit, castID, spellID)
	if groupUnits[unit] and importantSpells[spellID] and importantSpells[spellID] ~= castID then
		local spellLink = C_Spell_GetSpellLink(spellID) or C_Spell_GetSpellInfo(spellID)
		if spellLink then
			SendChatMessage(string_format("%s used %s", UnitName(unit), spellLink), K.CheckChat())
			importantSpells[spellID] = castID
		end
	end
end

-- Function to check if the player is in a group and register/unregister events accordingly
function Module:CheckGroupStatus()
	if IsInGroup() then
		K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateItemAlert)
	else
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.UpdateItemAlert)
	end
end

-- Main function to handle spell and item alerts
function Module:CreateItemAnnounce()
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
