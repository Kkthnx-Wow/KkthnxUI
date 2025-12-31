local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local MuteSoundFile = MuteSoundFile
local UnmuteSoundFile = UnmuteSoundFile

local pairs = pairs
local tonumber = tonumber
local string_gmatch = string.gmatch

-- Website For Looking Up Sounds
-- https://wow.tools/

-- You Can Test Sounds With This Command In-Game
-- /run PlaySoundFile(2006030)

local muteSounds = {
	-- Annoying Train Choo Choo Crap
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

	-- Stupid Turtle (I've collected Many Things Over The Years See If You Can Match Them)
	[2015901] = true, -- sound/creature/collector_kojo/vo_801_collector_kojo_28_m.ogg

	-- Stupid Troll (Something has spooked one of the brutosaurs, sending it into a panic)
	[1999176] = true, -- sound/creature/wardruid_loti/vo_801_wardruid_loti_02_f.ogg

	-- World Quest Sound When It Popsup
	[1489473] = true, -- sound/interface/ui_worldquest_start.ogg

	-- Annoying Motorcycle Sounds
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

	-- Sylvanas' Music Box I hate this darn thing so much!
	[53221] = true, -- sound/music/gluescreenmusic/bccredits_lament_of_the_highborne.mp3
}

local activeMuted = {}

local function GetCombinedMuteSounds()
	local combined = {}
	for soundID in pairs(muteSounds) do
		combined[soundID] = true
	end

	local extra = C["Misc"] and C["Misc"].MuteSoundIDs
	if type(extra) == "number" then
		combined[extra] = true
	elseif type(extra) == "string" and extra ~= "" then
		for w in string_gmatch(extra, "%S+") do
			local id = tonumber(w)
			if id then
				combined[id] = true
			end
		end
	end

	return combined
end

function Module:CreateMuteSounds()
	local shouldMute = C["Misc"].MuteSounds
	local combined = GetCombinedMuteSounds()

	-- Unmute anything that should no longer be muted (or when the feature is disabled)
	for soundID in pairs(activeMuted) do
		if not shouldMute or not combined[soundID] then
			UnmuteSoundFile(soundID)
			activeMuted[soundID] = nil
		end
	end

	-- Mute anything new
	if shouldMute then
		for soundID in pairs(combined) do
			if not activeMuted[soundID] then
				MuteSoundFile(soundID)
				activeMuted[soundID] = true
			end
		end
	end
end

Module:RegisterMisc("MuteSounds", Module.CreateMuteSounds)
