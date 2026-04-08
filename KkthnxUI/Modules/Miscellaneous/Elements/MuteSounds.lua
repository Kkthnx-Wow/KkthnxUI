--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Silences specific annoying or repetitive game sounds (e.g., trains, turtles, motorcycles).
-- - Design: Manages a list of sound IDs and uses MuteSoundFile/UnmuteSoundFile to toggle their state.
-- - Events: None (Static initialization and config updates)
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local pairs = _G.pairs
local string_gmatch = _G.string.gmatch
local tonumber = _G.tonumber
local type = _G.type

local _G = _G
local MuteSoundFile = _G.MuteSoundFile
local UnmuteSoundFile = _G.UnmuteSoundFile

-- SG: Sound ID Lists
-- Website for looking up sounds: https://wow.tools/
-- Test sounds in-game: /run PlaySoundFile(2006030)
local MUTE_SOUNDS_LIST = {
	-- SG: Annoying Train Sounds
	[539219] = true,
	[539203] = true,
	[1313588] = true,
	[1306531] = true,
	[539516] = true,
	[539730] = true,
	[539802] = true,
	[539881] = true,
	[540271] = true,
	[540275] = true,
	[541769] = true,
	[542017] = true,
	[540535] = true,
	[540734] = true,
	[540870] = true,
	[540947] = true,
	[1316209] = true,
	[1304872] = true,
	[541157] = true,
	[541239] = true,
	[636621] = true,
	[630296] = true,
	[630298] = true,
	[542818] = true,
	[542896] = true,
	[543085] = true,
	[543093] = true,
	[542526] = true,
	[542600] = true,
	[542035] = true,
	[542206] = true,
	[541463] = true,
	[541601] = true,
	[1902030] = true,
	[1902543] = true,
	[1730534] = true,
	[1730908] = true,
	[2531204] = true,
	[2491898] = true,
	[1731282] = true,
	[1731656] = true,
	[1951457] = true,
	[1951458] = true,
	[3107651] = true,
	[3107182] = true,
	[1732030] = true,
	[1732405] = true,
	[1732785] = true,
	[1733163] = true,
	[3106252] = true,
	[3106717] = true,
	[1903049] = true,
	[1903522] = true,
	[13923] = true, -- ToyTrain_01

	-- SG: Turtle Collector Kojo
	[2015901] = true, -- sound/creature/collector_kojo/vo_801_collector_kojo_28_m.ogg

	-- SG: Wardruid Loti (Brutosaur panic)
	[1999176] = true, -- sound/creature/wardruid_loti/vo_801_wardruid_loti_02_f.ogg

	-- SG: World Quest Popup
	[1489473] = true, -- sound/interface/ui_worldquest_start.ogg

	-- SG: Motorcycle Sounds
	[569854] = true, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclewalkrun.ogg
	[569855] = true, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpend3.ogg
	[569856] = true, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpstart1.ogg
	[569857] = true, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpend2.ogg
	[569858] = true, -- sound/vehicles/motorcyclevehicle/motorcyclevehicleattackthrown.ogg
	[569859] = true, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclestand.ogg
	[569860] = true, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpstart3.ogg
	[569861] = true, -- sound/vehicles/motorcyclevehicle/motorcyclevehicleloadthrown.ogg
	[569862] = true, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpstart2.ogg
	[569863] = true, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpend1.ogg

	-- SG: Sylvanas' Music Box
	[53221] = true, -- sound/music/gluescreenmusic/bccredits_lament_of_the_highborne.mp3
}

local currentlyMutedSounds = {}

-- REASON: Merges internal hardcoded sound IDs with user-defined IDs from the configuration to create a unified mute list.
local function getCombinedMuteSounds()
	local combinedList = {}
	for soundID in pairs(MUTE_SOUNDS_LIST) do
		combinedList[soundID] = true
	end

	local extraIDs = C["Misc"] and C["Misc"].MuteSoundIDs
	if type(extraIDs) == "number" then
		combinedList[extraIDs] = true
	elseif type(extraIDs) == "string" and extraIDs ~= "" then
		for word in string_gmatch(extraIDs, "%S+") do
			local id = tonumber(word)
			if id then
				combinedList[id] = true
			end
		end
	end

	return combinedList
end

function Module:updateMutedSounds()
	local isMuteEnabled = C["Misc"].MuteSounds
	local combinedMuteList = getCombinedMuteSounds()

	-- REASON: Unmutes sounds that are no longer in the combined list or if the feature has been disabled.
	for soundID in pairs(currentlyMutedSounds) do
		if not isMuteEnabled or not combinedMuteList[soundID] then
			UnmuteSoundFile(soundID)
			currentlyMutedSounds[soundID] = nil
		end
	end

	-- REASON: Applies muting to any newly added sound IDs if the feature is active.
	if isMuteEnabled then
		for soundID in pairs(combinedMuteList) do
			if not currentlyMutedSounds[soundID] then
				MuteSoundFile(soundID)
				currentlyMutedSounds[soundID] = true
			end
		end
	end
end

Module:RegisterMisc("MuteSounds", Module.updateMutedSounds)
