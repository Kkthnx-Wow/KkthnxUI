local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

local string_format = string.format

local GetSpellInfo = GetSpellInfo
local GetSpellLink = GetSpellLink
local IsInGroup = IsInGroup
local SendChatMessage = SendChatMessage
local UnitName = UnitName

local groupUnits = { ["player"] = true, ["pet"] = true }
if IsInGroup() then
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do
			groupUnits["raid" .. i] = true
			groupUnits["raidpet" .. i] = true
		end
	else
		for i = 1, GetNumSubgroupMembers() do
			groupUnits["party" .. i] = true
			groupUnits["partypet" .. i] = true
		end
	end
end

local itemList = {
	[54710] = true, -- Portable mailbox
	[67826] = true, -- Kevis
	[226241] = true, -- Tranquility
	[256230] = true, -- Meditation scriptures
	[185709] = true, -- Caramel Fish Feast
	[259409] = true, -- Feast of sails
	[259410] = true, -- Captain's Feast
	[276972] = true, -- Arcane Cauldron
	[286050] = true, -- blood meal
	[265116] = true, -- 8.0 Engineering Battle
	[308458] = true, -- Amazing meal
	[308462] = true, -- Indulge in a gluttonous feast
	[345130] = true, -- 9.0 Engineering Battle
	[307157] = true, -- Eternal Cauldron
	[359336] = true, -- stone soup pot
	[324029] = true, -- Code of Peace of Mind

	[2825] = true, -- bloodthirsty
	[32182] = true, -- heroic
	[80353] = true, -- time warp
	[264667] = true, -- Primal Rage, pet
	[272678] = true, -- Primal Rage, Pet Mastery
	[178207] = true, -- Drums of Fury
	[230935] = true, -- Alpine War Drums
	[256740] = true, -- Vortex Drums
	[292686] = true, -- Thunderskin's Hammer
	[309658] = true, -- Death Brutal War Drum
}

function Module:ItemAlert_Update(unit, castID, spellID)
	if groupUnits[unit] and itemList[spellID] and (itemList[spellID] ~= castID) then
		local message = string_format(L["Spell Item AlertStr"], UnitName(unit), GetSpellLink(spellID) or GetSpellInfo(spellID))
		SendChatMessage(message, K.CheckChat())
		itemList[spellID] = castID
	end
end

function Module:ItemAlert_CheckGroup()
	if IsInGroup() then
		K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	else
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	end
end

function Module:CreateItemAnnounce()
	if C["Announcements"].ItemAlert then
		self:ItemAlert_CheckGroup()
		K:RegisterEvent("GROUP_LEFT", self.ItemAlert_CheckGroup)
		K:RegisterEvent("GROUP_JOINED", self.ItemAlert_CheckGroup)
	else
		K:UnregisterEvent("GROUP_LEFT", self.ItemAlert_CheckGroup)
		K:UnregisterEvent("GROUP_JOINED", self.ItemAlert_CheckGroup)
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	end
end
