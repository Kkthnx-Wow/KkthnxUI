--[[-----------------------------------------------------------------------------
-- Audio Sync — restart sound when Windows output devices change.
-- SetCVar Sound_OutputDriverIndex + RestartSoundSystem; skip during movies/cinematics.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local SetCVar = _G.SetCVar
local Sound_GameSystem_RestartSoundSystem = _G.Sound_GameSystem_RestartSoundSystem
local CinematicFrame = _G.CinematicFrame
local MovieFrame = _G.MovieFrame

local registered

local function SyncAudio()
	if not C["Misc"].AudioSync then
		return
	end
	if SetCVar then
		SetCVar("Sound_OutputDriverIndex", "0")
	end
	local inCinematic = (CinematicFrame and CinematicFrame:IsShown()) or (MovieFrame and MovieFrame:IsShown())
	if Sound_GameSystem_RestartSoundSystem and not inCinematic then
		Sound_GameSystem_RestartSoundSystem()
	end
end

function Module:CreateAudioSync()
	if registered then
		return
	end
	if not C["Misc"].AudioSync then
		return
	end
	registered = true
	K:RegisterEvent("VOICE_CHAT_OUTPUT_DEVICES_UPDATED", SyncAudio)
	SyncAudio()
end

function Module:UpdateAudioSync()
	if C["Misc"].AudioSync then
		if not registered then
			Module:CreateAudioSync()
		else
			SyncAudio()
		end
	elseif registered then
		K:UnregisterEvent("VOICE_CHAT_OUTPUT_DEVICES_UPDATED", SyncAudio)
		registered = false
	end
end
