local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local MuteSoundFile = MuteSoundFile
local UnmuteSoundFile = UnmuteSoundFile

-- Website For Looking Up Sounds
-- https://wow.tools/

-- You Can Test Sounds With This Command In-Game
-- /run PlaySoundFile(2006030)

local muteSounds = {
	-- Annoying Train Choo Choo Crap
	539219,
	539203,
	1313588,
	1306531,
	539516,
	539730,
	539802,
	539881,
	540271,
	540275,
	541769,
	542017,
	540535,
	540734,
	540870,
	540947,
	1316209,
	1304872,
	541157,
	541239,
	636621,
	630296,
	630298,
	542818,
	542896,
	543085,
	543093,
	542526,
	542600,
	542035,
	542206,
	541463,
	541601,
	1902030,
	1902543,
	1730534,
	1730908,
	2531204,
	2491898,
	1731282,
	1731656,
	1951457,
	1951458,
	3107651,
	3107182,
	1732030,
	1732405,
	1732785,
	1733163,
	3106252,
	3106717,
	1903049,
	1903522,

	13923, -- ToyTrain_01

	-- Stupid Turtle (I've collected Many Things Over The Years See If You Can Match Them)
	2015901, -- sound/creature/collector_kojo/vo_801_collector_kojo_28_m.ogg

	-- Stupid Troll (Something has spooked one of the brutosaurs, sending it into a panic)
	1999176, -- sound/creature/wardruid_loti/vo_801_wardruid_loti_02_f.ogg

	-- World Quest Sound When It Popsup
	1489473, -- sound/interface/ui_worldquest_start.ogg

	-- Annoying Motorcycle Sounds
	569854, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclewalkrun.ogg
	569855, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpend3.ogg
	569856, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpstart1.ogg
	569857, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpend2.ogg
	569858, -- sound/vehicles/motorcyclevehicle/motorcyclevehicleattackthrown.ogg
	569859, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclestand.ogg
	569860, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpstart3.ogg
	569861, -- sound/vehicles/motorcyclevehicle/motorcyclevehicleloadthrown.ogg
	569862, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpstart2.ogg
	569863, -- sound/vehicles/motorcyclevehicle/motorcyclevehiclejumpend1.ogg
}

function Module:CreateMuteSounds()
	for soundID in pairs(muteSounds) do
		local shouldMute = not not C["Misc"].MuteSounds -- convert C["Misc"].MuteSounds to a boolean
		if shouldMute then
			MuteSoundFile(soundID)
		else
			UnmuteSoundFile(soundID)
		end
	end
end

Module:RegisterMisc("MuteSounds", Module.CreateMuteSounds)
