local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local MuteSoundFile = _G.MuteSoundFile
local UnmuteSoundFile = _G.UnmuteSoundFile

-- Website For Looking Up Sounds
-- https://wow.tools/

-- You Can Test Sounds With This Command In-Game
-- /run PlaySoundFile(2006030)

local muteSounds = {
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

	-- Notifaction Sound When Someone Comes Online?
	567518, -- sound/interface/friendjoin.ogg

	-- Annoying Toy Sylvanas's Music Box
	53221, -- sound/music/gluescreenmusic/bccredits_lament_of_the_highborne.mp3

	-- Annoying NPC When You Kill They Spam (The cycle... continues...)
	1978290, -- sound/creature/kthir/vo_801_kthir_11_m.ogg

	-- Princess Talanji Spamming (Your Horde's scouts have reported a formidable enemy nearby. I agree with their proposal on how to deal with it: a swift killing)
	2061210, -- sound/creature/princess_talanji/vo_801_princess_talanji_300_f.ogg
}

function Module:CreateMuteSounds()
	for _, soundIDs in ipairs(muteSounds) do
		if C["Misc"].MuteSounds then
			MuteSoundFile(soundIDs)
		else
			UnmuteSoundFile(soundIDs)
		end
	end
end

Module:RegisterMisc("MuteSounds", Module.CreateMuteSounds)
