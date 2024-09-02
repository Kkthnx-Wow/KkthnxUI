local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- Localize API functions
local string_format, GetInstanceInfo, C_Spell_GetSpellLink, IsActiveBattlefieldArena, IsArenaSkirmish, IsInGroup, IsInRaid, IsPartyLFG, UnitInParty, UnitInRaid = string.format, GetInstanceInfo, C_Spell.GetSpellLink, IsActiveBattlefieldArena, IsArenaSkirmish, IsInGroup, IsInRaid, IsPartyLFG, UnitInParty, UnitInRaid

local AURA_TYPE_BUFF = AURA_TYPE_BUFF
local infoType = {}

local spellBlackList = {
	[102359] = true,
	[105421] = true,
	[115191] = true,
	[122] = true,
	[157997] = true,
	[1776] = true,
	[1784] = true,
	[197214] = true,
	[198121] = true,
	[207167] = true,
	[207685] = true,
	[226943] = true,
	[228600] = true,
	[285515] = true,
	[31661] = true,
	[331866] = true,
	[33395] = true,
	[354051] = true,
	[355689] = true,
	[386770] = true,
	[5246] = true,
	[64695] = true,
	[8122] = true,
	[82691] = true,
	[91807] = true,
	[99] = true,
}

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

	local alertChannel = C["Announcements"].AlertChannel.Value
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

function Module:InterruptAlert_Toggle()
	infoType["SPELL_STOLEN"] = C["Announcements"].DispellAlert and L["Steal"]
	infoType["SPELL_DISPEL"] = C["Announcements"].DispellAlert and L["Dispel"]
	infoType["SPELL_INTERRUPT"] = C["Announcements"].InterruptAlert and L["Interrupt"]
	infoType["SPELL_AURA_BROKEN_SPELL"] = C["Announcements"].BrokenAlert and L["Broken Spell"]
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

function Module:InterruptAlert_Update(...)
	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, _, destName, _, _, spellID, _, _, extraskillID, _, _, auraType = ...
	if not sourceGUID or sourceName == destName then
		return
	end

	local isPlayerOrAllyPet = sourceName == K.Name or Module:IsAllyPet(sourceFlags)

	if (UnitInRaid(sourceName) or UnitInParty(sourceName) or isPlayerOrAllyPet) and infoType[eventType] then
		local infoText = infoType[eventType]
		local sourceSpellID, destSpellID

		if infoText == L["Broken Spell"] then
			if auraType == AURA_TYPE_BUFF or spellBlackList[spellID] then
				return
			end
			sourceSpellID, destSpellID = extraskillID, spellID
		elseif infoText == L["Interrupt"] then
			if C["Announcements"].OwnInterrupt and not isPlayerOrAllyPet then
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
			local message = infoText == L["Broken Spell"] and string_format(infoText, sourceName, C_Spell_GetSpellLink(destSpellID)) or string_format(infoText, C_Spell_GetSpellLink(destSpellID))
			SendChatMessage(message, getAlertChannel())
		end
	end
end

function Module:InterruptAlert_CheckGroup()
	if IsInGroup() and (not C["Announcements"].InstAlertOnly or (IsInInstance() and not IsRandomGroup())) then
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
