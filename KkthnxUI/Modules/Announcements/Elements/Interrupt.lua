local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = _G.string.format

local AURA_TYPE_BUFF = _G.AURA_TYPE_BUFF
local GetInstanceInfo = _G.GetInstanceInfo
local GetSpellLink = _G.GetSpellLink
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena
local IsArenaSkirmish = _G.IsArenaSkirmish
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local IsPartyLFG = _G.IsPartyLFG
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid

local infoType = {}

local spellBlackList = {
	[102359] = true, -- group entanglement
	[105421] = true, -- Blind Light
	[115191] = true, -- sneak
	[122] = true, -- Frost Nova
	[157997] = true, -- Ice Nova
	[1776] = true, -- gouge
	[1784] = true, -- sneak
	[197214] = true, -- Earthshatter
	[198121] = true, -- Frost Bite
	[207167] = true, -- blinding freezing rain
	[207685] = true, -- Sorrow Charm
	[226943] = true, -- mind bomb
	[228600] = true, -- Glacial Spike
	[31661] = true, -- Dragon Breath
	[331866] = true, -- Chaos Agent
	[33395] = true, -- Freeze
	[5246] = true, -- Intimidating Roar
	[64695] = true, -- sink
	[8122] = true, -- mind scream
	[82691] = true, -- Ring of Frost
	[91807] = true, -- Stagger charge
	[99] = true, -- Reaper Roar
}

local function msgChannel()
	local inRaid, inPartyLFG = IsInRaid(), IsPartyLFG()

	local _, instanceType = GetInstanceInfo()
	if instanceType == "arena" then
		local skirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		if skirmish or not isRegistered then
			inPartyLFG = true
		end
		inRaid = false -- IsInRaid() returns true for arenas and they should not be considered a raid
	end

	local Value = C["Announcements"].AlertChannel.Value
	if Value == 1 then
		return inPartyLFG and "INSTANCE_CHAT" or "PARTY"
	elseif Value == 2 then
		return inPartyLFG and "INSTANCE_CHAT" or (inRaid and "RAID" or "PARTY")
	elseif Value == 3 and inRaid then
		return inPartyLFG and "INSTANCE_CHAT" or "RAID"
	elseif Value == 4 and instanceType ~= "none" then
		return "SAY"
	elseif Value == 5 and instanceType ~= "none" then
		return "YELL"
	elseif Value == 6 then
		return "EMOTE"
	end
end

function Module:InterruptAlert_Toggle()
	infoType["SPELL_STOLEN"] = C["Announcements"].DispellAlert and L["Steal"]
	infoType["SPELL_DISPEL"] = C["Announcements"].DispellAlert and L["Dispel"]
	infoType["SPELL_INTERRUPT"] = C["Announcements"].InterruptAlert and L["Interrupt"]
	infoType["SPELL_AURA_BROKEN_SPELL"] = C["Announcements"].BrokenAlert and L["BrokenSpell"]
end

function Module:InterruptAlert_IsEnabled()
	for _, value in pairs(infoType) do
		if value then
			return true
		end
	end
end

function Module:IsAllyPet(sourceFlags)
	if K.IsMyPet(sourceFlags) or sourceFlags == K.PartyPetFlags or sourceFlags == K.RaidPetFlags then
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
			local sourceSpellID, destSpellID
			if infoText == L["BrokenSpell"] then
				if auraType and auraType == AURA_TYPE_BUFF or spellBlackList[spellID] then
					return
				end
				sourceSpellID, destSpellID = extraskillID, spellID
			elseif infoText == L["Interrupt"] then
				if C["Announcements"].OwnInterrupt and sourceName ~= K.Name and not Module:IsAllyPet(sourceFlags) then
					return
				end
				sourceSpellID, destSpellID = spellID, extraskillID
			else
				if C["Announcements"].OwnDispell and sourceName ~= K.Name and not Module:IsAllyPet(sourceFlags) then
					return
				end
				sourceSpellID, destSpellID = spellID, extraskillID
			end

			if sourceSpellID and destSpellID then
				if infoText == L["BrokenSpell"] then
					SendChatMessage(string_format(infoText, sourceName, GetSpellLink(destSpellID)), msgChannel())
				else
					SendChatMessage(string_format(infoText, GetSpellLink(destSpellID)), msgChannel())
				end
			end
		end
	end
end

function Module:InterruptAlert_CheckGroup()
	if IsInGroup() and (not C["Announcements"].InstAlertOnly or (IsInInstance() and not IsPartyLFG())) then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end

function Module:CreateInterruptAnnounce()
	Module:InterruptAlert_Toggle()

	if Module:InterruptAlert_IsEnabled() then
		self:InterruptAlert_CheckGroup()
		K:RegisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		K:RegisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
		K:RegisterEvent("PLAYER_ENTERING_WORLD", self.InterruptAlert_CheckGroup)
	else
		K:UnregisterEvent("GROUP_LEFT", self.InterruptAlert_CheckGroup)
		K:UnregisterEvent("GROUP_JOINED", self.InterruptAlert_CheckGroup)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", self.InterruptAlert_CheckGroup)
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end
