local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = _G.string.format

local GetSpellInfo = _G.GetSpellInfo
local GetSpellLink = _G.GetSpellLink
local GetTime = _G.GetTime
local IsInGroup = _G.IsInGroup
local SendChatMessage = _G.SendChatMessage
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitName = _G.UnitName

local lastTime = 0
local itemList = {
	[226241] = true, -- Codex of the Tranquil Mind
	[256230] = true, -- Codex of the Quiet Mind
	[185709] = true, -- Sugar-Crusted Fish Feast
	[259409] = true, -- Galley Banquet
	[259410] = true, -- Bountiful Captain's Feast
	[276972] = true, -- Mystical Cauldron
	[286050] = true, -- Sanguinated Feast
	[265116] = true, -- 8.0 Unstable Temporal Time Shifter

	[308458] = true, -- Surprisingly Palatable Feast
	[308462] = true, -- Feast of Gluttonous Hedonism
	[345130] = true, -- 9.0 Disposable Spectrophasic Reanimator
	[307157] = true, -- Eternal Cauldron
	[324029] = true, -- Codex of the Still Mind
}

function Module:ItemAlert_Update(unit, _, spellID)
	if (UnitInRaid(unit) or UnitInParty(unit)) and spellID and itemList[spellID] and lastTime ~= GetTime() then
		local who = UnitName(unit)
		local link = GetSpellLink(spellID)
		local name = GetSpellInfo(spellID)
		SendChatMessage(string_format(L["Item Placed"], who, link or name), K.CheckChat())

		lastTime = GetTime()
	end
end

function Module:ItemAlert_CheckGroup()
	if IsInGroup() then
		K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	else
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	end
end

function Module:PlacedItemAlert()
	Module:ItemAlert_CheckGroup()
	K:RegisterEvent("GROUP_LEFT", Module.ItemAlert_CheckGroup)
	K:RegisterEvent("GROUP_JOINED", Module.ItemAlert_CheckGroup)
end

function Module:CreateItemAnnounce()
	if not C["Announcements"].ItemAlert then
		return
	end

	Module:PlacedItemAlert()
end