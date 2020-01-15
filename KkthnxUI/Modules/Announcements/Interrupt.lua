local K, C = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local bit_band = _G.bit.band
local string_format = _G.string.format

local COMBATLOG_OBJECT_AFFILIATION_MINE = _G.COMBATLOG_OBJECT_AFFILIATION_MINE
local GetSpellLink = _G.GetSpellLink
local IsInGroup = _G.IsInGroup
local SendChatMessage = _G.SendChatMessage
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid

local infoType = {
	["SPELL_AURA_BROKEN_SPELL"] = "Break - %s > %s",
	["SPELL_INTERRUPT"] = "Interrupt - %s > %s",
}

local InterruptAlert_BlackList = {
	[102359] = true, -- Mass Entanglement
	[105421] = true, -- Blinding Light
	[115191] = true, -- Stealth
	[122] = true, -- Frost Nova
	[157997] = true, -- Ice Nova
	[1776] = true, -- Gouge
	[1784] = true, -- Stealth
	[197214] = true, -- Sundering
	[198121] = true, -- Frostbite
	[207167] = true, -- Blinding Sleet
	[207685] = true, -- Sigil of Misery
	[226943] = true, -- Mind Bomb
	[228600] = true, -- Glacial Spike
	[31661] = true, -- Dragon's Breath
	[33395] = true, -- Freeze
	[5246] = true, -- Intimidating Shout
	[64695] = true, -- Earthgrab
	[8122] = true, -- Psychic Scream
	[82691] = true, -- Ring of Frost
	[91807] = true, -- Shambling Rush
	[99] = true, -- Incapacitating Roar
}

local function IsMyPet(flags)
	return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end

function Module:IsAllyPet(sourceFlags)
	if IsMyPet(sourceFlags) then
		return true
	end
end

function Module:InterruptAlert_Update(...)
	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, extraskillID, _, _, auraType = ...
	if not sourceGUID or sourceName == destName then
		return
	end

	if UnitInRaid(sourceName) or UnitInParty(sourceName) or Module:IsAllyPet(sourceFlags) then
		local infoText = infoType[eventType]
		if infoText then
			if infoText == "Break - %s > %s" then
				if not C["Announcements"].BrokenSpell then
					return
				end

				if auraType and auraType == AURA_TYPE_BUFF or InterruptAlert_BlackList[spellID] then
					return
				end

				SendChatMessage(string_format(infoText, sourceName..GetSpellLink(extraskillID), destName..GetSpellLink(spellID)), K.CheckChat())
			else
				if sourceName ~= K.Name and not Module:IsAllyPet(sourceFlags) then
					return
				end

				SendChatMessage(string_format(infoText, sourceName..GetSpellLink(spellID), destName..GetSpellLink(extraskillID)), K.CheckChat())
			end
		end
	end
end

function Module:InterruptAlert_CheckGroup()
	if IsInGroup() then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end

function Module:CreateInterruptAnnounce()
	if C["Announcements"].Interrupt then
		self:InterruptAlert_CheckGroup()
		K:RegisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		K:RegisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
	else
		K:UnregisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		K:UnregisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end