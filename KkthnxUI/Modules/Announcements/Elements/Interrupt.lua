--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Announces interrupts, dispels, and broken crowd control to chat.
-- - Design: Monitors COMBAT_LOG_EVENT_UNFILTERED (CLEU) and filters based on group affiliation.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache frequent string and global references to minimize CLEU overhead.
local pairs = pairs
local tostring = tostring
local string_format = string.format

local GetInstanceInfo = GetInstanceInfo
local IsActiveBattlefieldArena = IsActiveBattlefieldArena
local IsArenaSkirmish = IsArenaSkirmish
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsPartyLFG = IsPartyLFG
local IsInInstance = IsInInstance
local SendChatMessage = SendChatMessage
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

local C_Spell_GetSpellLink = C_Spell.GetSpellLink
local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo
local C_PartyInfo_IsPartyWalkIn = C_PartyInfo and C_PartyInfo.IsPartyWalkIn

local band, bor = bit.band, bit.bor

local AURA_TYPE_BUFF = AURA_TYPE_BUFF
-- REASON: Filters CLEU events to only those originating from the player's immediate group.
local AFFILIATION_MASK = bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_AFFILIATION_RAID)

local infoType = {}

-- ---------------------------------------------------------------------------
-- BLACKLISTS
-- ---------------------------------------------------------------------------

-- NOTE: Spells that break on damage or are non-actionable; suppressed to reduce spam.
local brokenBlackList = {
	[99] = true, -- Incapacitating Roar (Druid)
	[122] = true, -- Frost Nova (Mage)
	[1776] = true, -- Gouge (Rogue)
	[1784] = true, -- Stealth (Rogue)
	[5246] = true, -- Intimidating Shout (Warrior)
	[8122] = true, -- Psychic Scream (Priest)
	[102359] = true, -- Mass Entanglement (Druid)
	[105421] = true, -- Blinding Light (Paladin)
	[115191] = true, -- Stealth (Subterfuge) (Rogue)
	[157997] = true, -- Ice Nova (Mage)
	[197214] = true, -- Sundering (Shaman)
	[198121] = true, -- Frostbite (Mage)
	[207167] = true, -- Blinding Sleet (Death Knight)
	[207685] = true, -- Sigil of Misery (Demon Hunter)
	[226943] = true, -- Mind Bomb (Priest)
	[228600] = true, -- Glacial Spike (Mage)
	[31661] = true, -- Dragon's Breath (Mage)
	[33395] = true, -- Freeze (Water Elemental)
	[64695] = true, -- Earthgrab (Totem Root)
	[82691] = true, -- Ring of Frost (Mage)
	[91807] = true, -- Shambling Rush
}

-- NOTE: Suppress specific interrupts that might be considered redundant or non-standard.
local interruptBlackList = {
	[31935] = true, -- Avenger's Shield (Paladin)
}

-- ---------------------------------------------------------------------------
-- UTILITIES
-- ---------------------------------------------------------------------------

-- COMPAT: Safely attempt to retrieve a spell link, falling back to name/ID to prevent script errors.
local function GetSpellLinkSafe(spellID)
	if not spellID then
		return "SpellID:0"
	end

	local link = C_Spell_GetSpellLink(spellID)
	if link then
		return link
	end

	if C_Spell_GetSpellInfo then
		local info = C_Spell_GetSpellInfo(spellID)
		if info and info.name then
			return info.name
		end
	end

	return "SpellID:" .. tostring(spellID)
end

-- REASON: Determines the appropriate chat channel based on the player's current instance and group type.
local function getAlertChannel()
	local _, instanceType = GetInstanceInfo()
	local inPartyLFG = IsPartyLFG() or (C_PartyInfo_IsPartyWalkIn and C_PartyInfo_IsPartyWalkIn())
	local inRaid = IsInRaid()

	if instanceType == "arena" then
		local isSkirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		inPartyLFG = isSkirmish or not isRegistered
		inRaid = false
	end

	local alertChannel = C["Announcements"].AlertChannel
	if alertChannel == 1 then
		return inPartyLFG and "INSTANCE_CHAT" or "PARTY"
	elseif alertChannel == 2 then
		return inPartyLFG and "INSTANCE_CHAT" or (inRaid and "RAID" or "PARTY")
	elseif alertChannel == 3 and inRaid then
		return inPartyLFG and "INSTANCE_CHAT" or "RAID"
	elseif alertChannel == 4 and instanceType ~= "none" then
		return "SAY"
	elseif alertChannel == 5 and instanceType ~= "none" then
		return "YELL"
	end

	return "EMOTE"
end

-- ---------------------------------------------------------------------------
-- EVENT LOGIC
-- ---------------------------------------------------------------------------

function Module:InterruptAlert_Toggle()
	infoType["SPELL_STOLEN"] = C["Announcements"].DispellAlert and L["Steal"] or nil
	infoType["SPELL_DISPEL"] = C["Announcements"].DispellAlert and L["Dispel"] or nil
	infoType["SPELL_INTERRUPT"] = C["Announcements"].InterruptAlert and L["Interrupt"] or nil
	infoType["SPELL_AURA_BROKEN_SPELL"] = C["Announcements"].BrokenAlert and L["Broken Spell"] or nil
end

function Module:InterruptAlert_IsEnabled()
	for _, value in pairs(infoType) do
		if value then
			return true
		end
	end
	return false
end

function Module:IsAllyPet(sourceFlags)
	return K.IsMyPet(sourceFlags) or sourceFlags == K.PartyPetFlags or sourceFlags == K.RaidPetFlags
end

-- WARNING: This function is called frequently during CLEU bursts. Logic must remain lightweight.
function Module:InterruptAlert_Update(...)
	local eventType, sourceGUID, sourceName, sourceFlags, destName, spellID, extraSpellID, auraType
	if CombatLogGetCurrentEventInfo then
		_, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, extraSpellID, _, _, auraType = CombatLogGetCurrentEventInfo()
	else
		_, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, extraSpellID, _, _, auraType = ...
	end

	local infoText = eventType and infoType[eventType]
	if not infoText or not sourceGUID or not sourceName or not destName or sourceName == destName then
		return
	end

	-- PERF: Early exit if the source is not an ally or the player.
	sourceFlags = sourceFlags or 0
	if band(sourceFlags, AFFILIATION_MASK) == 0 then
		return
	end

	local isPlayerOrAllyPet = sourceName == K.Name or Module:IsAllyPet(sourceFlags)

	local sourceSpellID, destSpellID
	if eventType == "SPELL_AURA_BROKEN_SPELL" then
		-- REASON: CC breaks on buffs (like shields) are usually not actionable/helpful to announce.
		if auraType == AURA_TYPE_BUFF or (spellID and brokenBlackList[spellID]) then
			return
		end
		sourceSpellID, destSpellID = extraSpellID, spellID
	elseif eventType == "SPELL_INTERRUPT" then
		-- NOTE: Filtering to own interrupts if configured to reduce clutter.
		if (C["Announcements"].OwnInterrupt and not isPlayerOrAllyPet) or (spellID and interruptBlackList[spellID]) then
			return
		end
		sourceSpellID, destSpellID = spellID, extraSpellID
	else
		if C["Announcements"].OwnDispell and not isPlayerOrAllyPet then
			return
		end
		sourceSpellID, destSpellID = spellID, extraSpellID
	end

	if not sourceSpellID or not destSpellID then
		return
	end

	local message
	if eventType == "SPELL_AURA_BROKEN_SPELL" then
		message = string_format(infoText, sourceName, GetSpellLinkSafe(destSpellID))
	else
		message = string_format(infoText, GetSpellLinkSafe(destSpellID))
	end

	SendChatMessage(message, getAlertChannel())
end

-- ---------------------------------------------------------------------------
-- REGISTRATION & LIFECYCLE
-- ---------------------------------------------------------------------------

function Module:InterruptAlert_CheckGroup()
	-- REASON: Manage CLEU registration to avoid unnecessary processing when solo or in world.
	local allowInstance = (IsInInstance() and (not IsPartyLFG())) or (C_PartyInfo_IsPartyWalkIn and C_PartyInfo_IsPartyWalkIn())
	if IsInGroup() and (not C["Announcements"].InstAlertOnly or allowInstance) then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end

function Module:CreateInterruptAnnounce()
	Module:InterruptAlert_Toggle()

	if Module:InterruptAlert_IsEnabled() then
		Module:InterruptAlert_CheckGroup()
		K:RegisterEvent("GROUP_LEFT", Module.InterruptAlert_CheckGroup)
		K:RegisterEvent("GROUP_JOINED", Module.InterruptAlert_CheckGroup)
		K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.InterruptAlert_CheckGroup)
	else
		K:UnregisterEvent("GROUP_LEFT", Module.InterruptAlert_CheckGroup)
		K:UnregisterEvent("GROUP_JOINED", Module.InterruptAlert_CheckGroup)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.InterruptAlert_CheckGroup)
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end
