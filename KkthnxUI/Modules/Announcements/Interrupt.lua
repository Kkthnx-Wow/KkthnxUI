local K, C = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = string.format

local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local InterruptMessage = _G.INTERRUPTED.." %s's \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!"
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena
local IsArenaSkirmish = _G.IsArenaSkirmish
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local IsPartyLFG = _G.IsPartyLFG
local SendChatMessage = _G.SendChatMessage
local UnitGUID = _G.UnitGUID

function Module:SetupInterruptAnnounce()
	local inGroup, inRaid, inPartyLFG = IsInGroup(), IsInRaid(), IsPartyLFG()
	if not inGroup then -- Not In Group, Exit.
		return
	end

	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
	if not (event == "SPELL_INTERRUPT" and (sourceGUID == K.GUID or sourceGUID == UnitGUID("pet"))) then -- No Announce-able Interrupt From Player Or Pet, Exit.
		return
	end

	-- Skirmish/non-rated arenas need to use INSTANCE_CHAT but IsPartyLFG() returns "false"
	local _, instanceType = IsInInstance()
	if instanceType and instanceType == "arena" then
		local skirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		if skirmish or not isRegistered then
			inPartyLFG = true
		end
		inRaid = false -- IsInRaid() returns true for arenas and they should not be considered a raid
	end

	local interruptAnnounce, msg = C["Announcements"].Interrupt.Value, string_format(InterruptMessage, destName, spellID, spellName)
	if interruptAnnounce == "PARTY" then
		SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "PARTY")
	elseif interruptAnnounce == "RAID" then
		SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or (inRaid and "RAID" or "PARTY"))
	elseif interruptAnnounce == "RAID_ONLY" and inRaid then
		SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "RAID")
	elseif interruptAnnounce == "SAY" then
		SendChatMessage(msg, "SAY")
	elseif interruptAnnounce == "EMOTE" then
		SendChatMessage(msg, "EMOTE")
	end
end

function Module:CreateInterruptAnnounce()
	if C["Announcements"].Interrupt.Value ~= "NONE" then
		self:SetupInterruptAnnounce()
	end
end