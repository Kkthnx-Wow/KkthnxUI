local K, C = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = _G.string.format

local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local GetInstanceInfo = _G.GetInstanceInfo
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena
local IsArenaSkirmish = _G.IsArenaSkirmish
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local IsPartyLFG = _G.IsPartyLFG
local UnitGUID = _G.UnitGUID
local SendChatMessage = _G.SendChatMessage

local DISPEL_MSG = "Dispelled %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!"
function Module:COMBAT_LOG_EVENT_UNFILTERED()
	local inGroup = IsInGroup()
	if not inGroup then
		return
	end

	local _, event, _, sourceGUID, _, _, _, destGUID, destName, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
	local announce = event == "SPELL_DISPEL" and (sourceGUID == K.GUID or sourceGUID == UnitGUID("pet")) and destGUID ~= K.GUID
	if not announce then -- No announce-able interrupt from player or pet, exit.
		return
	end

	local inRaid, inPartyLFG = IsInRaid(), IsPartyLFG()
	local _, instanceType = GetInstanceInfo() -- Skirmish/non-rated arenas need to use INSTANCE_CHAT but IsPartyLFG() returns "false"
	if instanceType == "arena" then
		local skirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		if skirmish or not isRegistered then
			inPartyLFG = true
		end
		inRaid = false -- IsInRaid() returns true for arenas and they should not be considered a raid
	end

	local channel, msg = C["Announcements"].Dispell.Value, string_format(DISPEL_MSG, destName, spellID, spellName)
	if channel == "PARTY" then
		SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "PARTY")
	elseif channel == "RAID" then
		SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or (inRaid and "RAID" or "PARTY"))
	elseif channel == "RAID_ONLY" and inRaid then
		SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "RAID")
	elseif channel == "SAY" and instanceType ~= "none" then
		SendChatMessage(msg, "SAY")
	elseif channel == "YELL" and instanceType ~= "none" then
		SendChatMessage(msg, "YELL")
	elseif channel == "EMOTE" then
		SendChatMessage(msg, "EMOTE")
	end
end

function Module:CreateDispellAnnounce()
	if C["Announcements"].Dispell.Value == "NONE" then
		return
	end

	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.COMBAT_LOG_EVENT_UNFILTERED)
end