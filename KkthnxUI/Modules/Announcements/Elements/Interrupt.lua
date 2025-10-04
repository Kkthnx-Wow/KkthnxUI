local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- Localize API functions
local string_format, GetInstanceInfo, C_Spell_GetSpellLink, IsActiveBattlefieldArena, IsArenaSkirmish, IsInGroup, IsInRaid, IsPartyLFG, UnitInParty, UnitInRaid = string.format, GetInstanceInfo, C_Spell.GetSpellLink, IsActiveBattlefieldArena, IsArenaSkirmish, IsInGroup, IsInRaid, IsPartyLFG, UnitInParty, UnitInRaid
local band, bor = bit.band, bit.bor

local AURA_TYPE_BUFF = AURA_TYPE_BUFF
local infoType = {}

-- Spells to ignore for "Broken Spell" announcements (commonly break on damage or are non-actionable)
local brokenBlackList = {
	[102359] = true, -- Mass Entanglement (Druid)
	[105421] = true, -- Blinding Light (Paladin)
	[115191] = true, -- Stealth (Subterfuge) (Rogue)
	[122] = true, -- Frost Nova (Mage)
	[157997] = true, -- Ice Nova (Mage)
	[1776] = true, -- Gouge (Rogue)
	[1784] = true, -- Stealth (Rogue)
	[197214] = true, -- Sundering (Shaman)
	[198121] = true, -- Frostbite (Mage) — verify
	[207167] = true, -- Blinding Sleet (Death Knight)
	[207685] = true, -- Sigil of Misery (Demon Hunter)
	[226943] = true, -- Mind Bomb (Priest)
	[228600] = true, -- Glacial Spike (Mage)
	[285515] = true, -- Verify spell name
	[31661] = true, -- Dragon's Breath (Mage)
	[331866] = true, -- Verify spell name
	[33395] = true, -- Freeze (Water Elemental)
	[354051] = true, -- Verify spell name
	[355689] = true, -- Verify spell name
	[378760] = true, -- Verify spell name
	[386770] = true, -- Verify spell name
	[5246] = true, -- Intimidating Shout (Warrior)
	[64695] = true, -- Earthgrab (Totem Root)
	[8122] = true, -- Psychic Scream (Priest)
	[82691] = true, -- Ring of Frost (Mage)
	[91807] = true, -- Shambling Rush — verify
	[99] = true, -- Incapacitating Roar (Druid)
}

-- Spells to ignore for interrupt announcements (edge cases or non-standard interrupts)
local interruptBlackList = {
	[31935] = true, -- Avenger's Shield (Paladin)
}

-- Returns a user-facing spell reference (link if available, else localized name, else fallback id)
local function GetSpellLinkSafe(spellID)
	local link = C_Spell_GetSpellLink(spellID)
	if link then
		return link
	end
	local info = C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellID)
	if info and info.name then
		return info.name
	end
	return "SpellID:" .. tostring(spellID)
end

-- Resolves the chat channel used for announcements based on instance and settings
local function getAlertChannel()
	local _, instanceType = GetInstanceInfo()
	local inPartyLFG = IsPartyLFG() or C_PartyInfo.IsPartyWalkIn()
	local inRaid = IsInRaid()

	if instanceType == "arena" then
		local isSkirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		inPartyLFG = isSkirmish or not isRegistered
		inRaid = false -- Arenas should not be considered raids
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

-- Enables/disables per-event announcement templates based on user settings
function Module:InterruptAlert_Toggle()
	infoType["SPELL_STOLEN"] = C["Announcements"].DispellAlert and L["Steal"] or nil
	infoType["SPELL_DISPEL"] = C["Announcements"].DispellAlert and L["Dispel"] or nil
	infoType["SPELL_INTERRUPT"] = C["Announcements"].InterruptAlert and L["Interrupt"] or nil
	infoType["SPELL_AURA_BROKEN_SPELL"] = C["Announcements"].BrokenAlert and L["Broken Spell"] or nil
end

-- Returns true if any of the announcement types are enabled
function Module:InterruptAlert_IsEnabled()
	for _, value in pairs(infoType) do
		if value then
			return true
		end
	end
	return false
end

-- Checks whether combat log flags indicate the source is our pet or an ally pet
function Module:IsAllyPet(sourceFlags)
	return K.IsMyPet(sourceFlags) or sourceFlags == K.PartyPetFlags or sourceFlags == K.RaidPetFlags
end

-- Handles CLEU events and emits formatted announcements when conditions are met
function Module:InterruptAlert_Update(...)
	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, extraskillID, _, _, auraType = ...
	if not sourceGUID or sourceName == destName then
		return
	end

	local isPlayerOrAllyPet = sourceName == K.Name or Module:IsAllyPet(sourceFlags)
	local isFromGroup = band(sourceFlags or 0, bor(COMBATLOG_OBJECT_AFFILIATION_MINE, COMBATLOG_OBJECT_AFFILIATION_PARTY, COMBATLOG_OBJECT_AFFILIATION_RAID)) ~= 0

	if isFromGroup and infoType[eventType] then
		local infoText = infoType[eventType]
		local sourceSpellID, destSpellID

		if eventType == "SPELL_AURA_BROKEN_SPELL" then
			if auraType == AURA_TYPE_BUFF or brokenBlackList[spellID] then
				return
			end
			sourceSpellID, destSpellID = extraskillID, spellID
		elseif eventType == "SPELL_INTERRUPT" then
			if (C["Announcements"].OwnInterrupt and not isPlayerOrAllyPet) or interruptBlackList[spellID] then
				return
			end
			sourceSpellID, destSpellID = spellID, extraskillID
		else
			if C["Announcements"].OwnDispell and not isPlayerOrAllyPet then
				return
			end
			sourceSpellID, destSpellID = spellID, extraskillID
		end

		if sourceSpellID and destSpellID then
			local message = (eventType == "SPELL_AURA_BROKEN_SPELL") and string_format(infoText, sourceName, GetSpellLinkSafe(destSpellID)) or string_format(infoText, GetSpellLinkSafe(destSpellID))
			SendChatMessage(message, getAlertChannel())
		end
	end
end

-- Registers/unregisters CLEU handler based on group and instance constraints
function Module:InterruptAlert_CheckGroup()
	if IsInGroup() and (not C["Announcements"].InstAlertOnly or (IsInInstance() and not IsPartyLFG() or C_PartyInfo.IsPartyWalkIn())) then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end

-- Initializes the interrupt/dispell/broken announcements and manages lifecycle
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
