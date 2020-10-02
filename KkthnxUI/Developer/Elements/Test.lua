local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Test")

-- Actual functionality
-- 8/2 08:03:29.127 [SERVER] This realm is scheduled for a rolling restart. Thank you for your patience and understanding.
-- 8/2 08:03:35.504 [SERVER] Restart in 10:00
-- 8/2 08:03:35.504 [SERVER] Shutdown in 10:00
-- /script KkthnxUI[1]:GetModule("Test"):RealmRestartReminder("CHAT_MSG_SYSTEM", IDLE_MESSAGE)

local _G = _G

local GetTime = _G.GetTime
local IDLE_MESSAGE = _G.IDLE_MESSAGE
local PlaySoundFile = _G.PlaySoundFile

local realmTimer = 0
function Module:RealmRestartReminder(_, msg)
	if msg == IDLE_MESSAGE then
		PlaySoundFile(543569, "Master") -- Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_Berzerk01.ogg
		return
	end

	if not msg:find("[SERVER]") then
		return
	end

	if GetTime() - realmTimer < 2 then
		return
	end
	realmTimer = GetTime()

	if msg:find("realm") and (msg:find("restart") and not msg:find("Cross") or msg:find("maintenance")) then
		-- Message contains both "realm" and "restart" or "realm" and "maintenance" in same sentence it's probably the right message
		PlaySoundFile(544153, "Master") -- Sound\\Creature\\ArchivumSystem\\UR_Archivum_MimironSDStart01.ogg
	elseif msg:find(" 10:00") then
		PlaySoundFile(544184, "Master") -- Sound\\Creature\\ArchivumSystem\\UR_Archivum_MimironSD10.ogg
	elseif msg:find(" 5:00") then
		PlaySoundFile(544189, "Master") -- Sound\\Creature\\ArchivumSystem\\UR_Archivum_MimironSD05.ogg
	elseif msg:find(" 3:00") then
		PlaySoundFile(544186, "Master") -- Sound\\Creature\\ArchivumSystem\\UR_Archivum_MimironSD03.ogg
	elseif msg:find(" 2:00") then
		PlaySoundFile(544152, "Master") -- Sound\\Creature\\ArchivumSystem\\UR_Archivum_MimironSD02.ogg
	elseif msg:find(" 1:00") then
		PlaySoundFile(544204, "Master") -- Sound\\Creature\\ArchivumSystem\\UR_Archivum_MimironSD01.ogg
	elseif msg:find(" 0:15") then
		PlaySoundFile(544176, "Master") -- Sound\\Creature\\ArchivumSystem\\UR_Archivum_MimironSD00.ogg
	end
end

function Module:OnEnable()
	K:RegisterEvent("CHAT_MSG_SYSTEM", Module.RealmRestartReminder)
end