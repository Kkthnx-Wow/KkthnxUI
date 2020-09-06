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
	[126459] = true, -- Blingtron 4000
	[161414] = true, -- Blingtron 5000
	[185709] = true, -- Sugar-Crusted Fish Feast
	[199109] = true, -- Auto-Hammer
	[226241] = true, -- Codex of the Tranquil Mind
	[22700] = true,	-- Field Repair Bot 74A
	[256230] = true, -- Codex of the Quiet Mind
	[259409] = true, -- Galley Banquet
	[259410] = true, -- BounPtiful Captain's Feast
	[276972] = true, -- Mystical Cauldron
	[286050] = true, -- Sanguinated Feast
	[44389] = true,	-- Field Repair Bot 110G
	[54710] = true, -- MOLL-E
	[54711] = true,	-- Scrapbot
	[67826] = true,	-- Jeeves
    [265116] = true, -- Unstable Temporal Time Shifter
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
	self:ItemAlert_CheckGroup()
	K:RegisterEvent("GROUP_LEFT", self.ItemAlert_CheckGroup)
	K:RegisterEvent("GROUP_JOINED", self.ItemAlert_CheckGroup)
end

function Module:CreateItemAnnounce()
	if C["Announcements"].ItemAlert ~= true then
		return
	end

    self:PlacedItemAlert()
end