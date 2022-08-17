local _, C, L = unpack(KkthnxUI)

local _G = _G

local SPELL_SCHOOL0_NAME = _G.SPELL_SCHOOL0_NAME
local SPELL_SCHOOL1_NAME = _G.SPELL_SCHOOL1_NAME
local SPELL_SCHOOL2_NAME = _G.SPELL_SCHOOL2_NAME
local SPELL_SCHOOL3_NAME = _G.SPELL_SCHOOL3_NAME
local SPELL_SCHOOL4_NAME = _G.SPELL_SCHOOL4_NAME
local SPELL_SCHOOL5_NAME = _G.SPELL_SCHOOL5_NAME
local SPELL_SCHOOL6_NAME = _G.SPELL_SCHOOL6_NAME

-- Auras for old expansions
C.DeprecatedAuras = {
	["Enchant Aura"] = { -- enchantment and trinket set
		-- 8.0
		{ AuraID = 229206, UnitID = "player" }, -- Delay Power
		{ AuraID = 251231, UnitID = "player" }, -- Steelskin Potion
		{ AuraID = 279151, UnitID = "player" }, -- intelligence potion
		{ AuraID = 279152, UnitID = "player" }, -- Potion of Agility
		{ AuraID = 279153, UnitID = "player" }, -- potion of strength
		{ AuraID = 279154, UnitID = "player" }, -- Stamina Potion
		{ AuraID = 298155, UnitID = "player" }, -- Super Steelskin Potion
		{ AuraID = 298152, UnitID = "player" }, -- Greater Intelligence Potion
		{ AuraID = 298146, UnitID = "player" }, -- Super Agility Potion
		{ AuraID = 298154, UnitID = "player" }, -- Potion of Super Strength
		{ AuraID = 298153, UnitID = "player" }, -- Super Stamina Potion
		{ AuraID = 298225, UnitID = "player" }, -- Proximity Enhancement Potion
		{ AuraID = 298317, UnitID = "player" }, -- Potion of Focused Resolve
		{ AuraID = 300714, UnitID = "player" }, -- Potion of Unbound Rage
		{ AuraID = 300741, UnitID = "player" }, -- Potion of Wild Healing
		{ AuraID = 188024, UnitID = "player" }, -- Skyline Potion
		{ AuraID = 250878, UnitID = "player" }, -- Lightfoot Potion
		{ AuraID = 290365, UnitID = "player" }, -- Brilliant Sapphire
		{ AuraID = 277179, UnitID = "player" }, -- Gladiator Medal
		{ AuraID = 277181, UnitID = "player" }, -- Gladiator's Emblem
		{ AuraID = 277187, UnitID = "player" }, -- Gladiator's Crest
		{ AuraID = 277185, UnitID = "player" }, -- Gladiator badge
		{ AuraID = 286342, UnitID = "player", Value = true }, -- Gladiator's Shield
		{ AuraID = 275765, UnitID = "player" }, -- Azerite Augment
		{ AuraID = 271194, UnitID = "player" }, -- artillery
		{ AuraID = 273992, UnitID = "player" }, -- Speed ​​of Soul
		{ AuraID = 273955, UnitID = "player" }, -- telescope field of view
		{ AuraID = 267612, UnitID = "player" }, -- Swiftstrike
		{ AuraID = 268887, UnitID = "player" }, -- Swift Voyage
		{ AuraID = 268893, UnitID = "player" }, -- Swift Voyage
		{ AuraID = 268854, UnitID = "player" }, -- Almighty Voyage
		{ AuraID = 268856, UnitID = "player" }, -- Almighty Voyage
		{ AuraID = 268904, UnitID = "player" }, -- Fatal Voyage
		{ AuraID = 268905, UnitID = "player" }, -- Fatal Voyage
		{ AuraID = 268898, UnitID = "player" }, -- Superb Voyage
		{ AuraID = 268899, UnitID = "player" }, -- Exquisite Voyage
		{ AuraID = 264957, UnitID = "player" }, -- rapid sight
		{ AuraID = 264878, UnitID = "player" }, -- critical sight
		{ AuraID = 267685, UnitID = "player" }, -- element torrent
		{ AuraID = 274472, UnitID = "player" }, -- Berserker's Wrath
		{ AuraID = 268769, UnitID = "player" }, -- mark dead spot
		{ AuraID = 267179, UnitID = "player" }, -- the charge in the bottle
		{ AuraID = 278070, UnitID = "player" }, -- Titan overload
		{ AuraID = 271103, UnitID = "player" }, -- Rezan's Shimmering Eye
		{ AuraID = 273942, UnitID = "player" }, -- boost spirit
		{ AuraID = 268518, UnitID = "player" }, -- Wind Chime
		{ AuraID = 265946, UnitID = "player", Value = true }, -- Ritual Handwraps
		{ AuraID = 278143, UnitID = "player" }, -- Blood Rage
		{ AuraID = 278381, UnitID = "player" }, -- sea storm
		{ AuraID = 273974, UnitID = "player" }, -- Loa Will
		{ AuraID = 271105, UnitID = "player" }, -- Butcher's Eye
		{ AuraID = 271107, UnitID = "player" }, -- golden luster
		{ AuraID = 278231, UnitID = "player" }, -- Fury of the Forest King
		{ AuraID = 278267, UnitID = "player" }, -- Wisdom of the Forest King
		{ AuraID = 268311, UnitID = "player", Flash = true }, -- Windcaller's Gift
		{ AuraID = 285489, UnitID = "player" }, -- Power of Blackmaw
		{ AuraID = 278317, UnitID = "player" }, -- aftermath
		{ AuraID = 278806, UnitID = "player" }, -- lion strategy
		{ AuraID = 278249, UnitID = "player" }, -- Bladestorm
		{ AuraID = 287916, UnitID = "player", Stack = 6, Flash = true, Combat = true }, -- Reactor
		{ AuraID = 287917, UnitID = "player" }, -- Oscillation overload
		{ AuraID = 265954, UnitID = "player" }, -- Golden Touch
		{ AuraID = 268439, UnitID = "player" }, -- Heart of Resonance
		{ AuraID = 278225, UnitID = "player" }, -- Soulbound Voodoo Tumor Festival
		{ AuraID = 278388, UnitID = "player" }, -- Heart of Permafrost Shell
		{ AuraID = 274430, UnitID = "player", Text = L["Haste"] }, -- perpetual clock, fast
		{ AuraID = 274431, UnitID = "player", Text = L["Mastery"] }, -- Mastery
		--{AuraID = 267325, UnitID = "player", Text = L["Mastery"]}, -- Lead dice, mastery
		--{AuraID = 267326, UnitID = "player", Text = L["Mastery"]}, -- Mastery
		--{AuraID = 267327, UnitID = "player", Text = L["Haste"]}, -- Haste
		--{AuraID = 267329, UnitID = "player", Text = L["Haste"]}, -- Haste
		--{AuraID = 267330, UnitID = "player", Text = L["Crit"]}, -- critical strike
		--{AuraID = 267331, UnitID = "player", Text = L["Crit"]}, -- critical strike
		{ AuraID = 280573, UnitID = "player", Combat = true }, -- reorganize the array
		{ AuraID = 289523, UnitID = "player", Combat = true }, -- Radiant Light
		{ AuraID = 295408, UnitID = "player" }, -- sinister blessing
		{ AuraID = 273988, UnitID = "player" }, -- Primal Instinct
		{ AuraID = 285475, UnitID = "player" }, -- Kaya mine current
		{ AuraID = 306242, UnitID = "player" }, -- red card reset
		{ AuraID = 285482, UnitID = "player" }, -- the ferocity of the sea giant
		{ AuraID = 303570, UnitID = "player", Flash = true }, -- sharp coral
		{ AuraID = 303568, UnitID = "target", Caster = "player" }, -- sharp coral
		{ AuraID = 301624, UnitID = "target", Caster = "player" }, -- shudder toxin
		{ AuraID = 302565, UnitID = "target", Caster = "player" }, -- conductive ink
		{ AuraID = 296962, UnitID = "player" }, -- Azshara accessory
		{ AuraID = 315787, UnitID = "player", Caster = "player" }, -- life charge
		-- Azerite Traits
		{ AuraID = 274598, UnitID = "player" }, -- impact master
		{ AuraID = 277960, UnitID = "player" }, -- nerve stimulation
		{ AuraID = 280852, UnitID = "player" }, -- Power of the Liberator
		{ AuraID = 266047, UnitID = "player" }, -- motivational growl
		{ AuraID = 280409, UnitID = "player" }, -- blood sacrifice power
		{ AuraID = 279902, UnitID = "player" }, -- Unstable Flame
		{ AuraID = 281843, UnitID = "player" }, -- Huifan
		{ AuraID = 280204, UnitID = "player" }, -- the wandering soul
		{ AuraID = 273685, UnitID = "player" }, -- scheming
		{ AuraID = 273714, UnitID = "player" }, -- race against time
		{ AuraID = 274443, UnitID = "player" }, -- Dance of Death
		{ AuraID = 280433, UnitID = "player" }, -- howling sand
		{ AuraID = 271711, UnitID = "player" }, -- Overwhelming energy
		{ AuraID = 272733, UnitID = "player" }, -- rhythm of strings
		{ AuraID = 280780, UnitID = "player" }, -- battle glory
		{ AuraID = 280787, UnitID = "player" }, -- Retaliation Fury
		{ AuraID = 280385, UnitID = "player" }, -- increasing pressure
		{ AuraID = 273842, UnitID = "player" }, -- Secret of the Abyss
		{ AuraID = 273843, UnitID = "player" }, -- Secret of the Abyss
		{ AuraID = 280412, UnitID = "player" }, -- Inspire the herd
		{ AuraID = 274596, UnitID = "player" }, -- impact master
		{ AuraID = 277969, UnitID = "player" }, -- Swift Claw
		{ AuraID = 273264, UnitID = "player" }, -- Rage Rise
		{ AuraID = 280653, UnitID = "player" }, -- engineering trait, smaller
		{ AuraID = 280654, UnitID = "player" }, -- Engineering trait, bigger
		{ AuraID = 273525, UnitID = "player" }, -- disaster is coming
		{ AuraID = 274373, UnitID = "player" }, -- Festering Power
		{ AuraID = 280170, UnitID = "player", Value = true }, -- Fake Death Shield
		-- Essence of Azerite
		{ AuraID = 302932, UnitID = "player", Flash = true }, -- Fearless Power
		{ AuraID = 297126, UnitID = "player" }, -- blood of the enemy
		{ AuraID = 297168, UnitID = "player" }, -- blood of the enemy
		{ AuraID = 304056, UnitID = "player" }, -- fight
		{ AuraID = 298343, UnitID = "player" }, -- Lucid dream
		{ AuraID = 295855, UnitID = "player" }, -- Guardian of Azeroth
		{ AuraID = 295248, UnitID = "player" }, -- focus energy
		{ AuraID = 298357, UnitID = "player" }, -- Memory of Lucid Dreams
		{ AuraID = 302731, UnitID = "player", Flash = true }, -- space ripple
		{ AuraID = 302952, UnitID = "player" }, -- Reality flow
		{ AuraID = 295137, UnitID = "player", Flash = true }, -- Primal Blood
		{ AuraID = 311203, UnitID = "player" }, -- glorious moment
		{ AuraID = 311202, UnitID = "player" }, -- harvest flame
		{ AuraID = 312915, UnitID = "player" }, -- Symbiotic pose
		{ AuraID = 295354, UnitID = "player" }, -- Essence Protocol
		-- Corrosion
		{ AuraID = 318378, UnitID = "player", Flash = true }, -- firm determination, orange drape
		{ AuraID = 317859, UnitID = "player" }, -- Dragon Enhancement, Orange Cloak
		-- Titan Road series accessories
		{ AuraID = 256816, UnitID = "player" }, -- Agramar's belief
		{ AuraID = 256831, UnitID = "player" }, -- Agramar's belief
		{ AuraID = 256818, UnitID = "player" }, -- Aman'Thul's Foresight
		{ AuraID = 256832, UnitID = "player" }, -- Aman'Thul's Foresight
		{ AuraID = 256833, UnitID = "player" }, -- Gogoneth's vitality
		{ AuraID = 256834, UnitID = "player" }, -- Eonar's Mercy
		{ AuraID = 256826, UnitID = "player" }, -- Courage of Khaz'gross
		{ AuraID = 256835, UnitID = "player" }, -- Courage of Khaz'gross
		{ AuraID = 256828, UnitID = "player" }, -- Norgannon's power
		{ AuraID = 256836, UnitID = "player" }, -- Norgannon's power
	},
	["Raid Debuff"] = { -- raid debuff group
		-- 8.0 5 people
		{ AuraID = 314478, UnitID = "player" }, -- pour out fear
		{ AuraID = 314483, UnitID = "player" }, -- pour out fear
		{ AuraID = 314411, UnitID = "player" }, -- suspicious
		{ AuraID = 314406, UnitID = "player" }, -- disabling disease
		{ AuraID = 314565, UnitID = "player", Flash = true }, -- desecrate the land
		{ AuraID = 314392, UnitID = "player", Flash = true }, -- evil corruption
		{ AuraID = 314308, UnitID = "player", Flash = true }, -- soul destroy
		{ AuraID = 314531, UnitID = "player" }, -- tear flesh
		{ AuraID = 302420, UnitID = "player" }, -- Queen's Decree: Hidden

		{ AuraID = 260954, UnitID = "player" }, -- Iron Gaze, Siege
		{ AuraID = 272421, UnitID = "player" }, -- Aim artillery, siege
		{ AuraID = 265773, UnitID = "player" }, -- spit gold, kings
		{ AuraID = 271564, UnitID = "player", Flash = true }, -- embalming fluid, kings
		{ AuraID = 271640, UnitID = "player" }, -- Dark Apocalypse, Kings
		{ AuraID = 274507, UnitID = "player" }, -- Slippery Soap, Liberty
		{ AuraID = 266923, UnitID = "player" }, -- charge, temple
		{ AuraID = 273563, UnitID = "player", Text = L["Freeze"] }, -- neurotoxin, temple
		{ AuraID = 269686, UnitID = "player" }, -- plague, temple
		{ AuraID = 257407, UnitID = "player" }, -- Track, Atal'Dasa
		{ AuraID = 250585, UnitID = "player", Flash = true }, -- Poisonous Pool, Atal'Dazar
		{ AuraID = 258723, UnitID = "player", Flash = true }, -- Pool of Weirdness, Atal'Dazar
		{ AuraID = 258058, UnitID = "player" }, -- squeeze, toldago
		{ AuraID = 260067, UnitID = "player" }, -- Vicious Maul, Tol Dagor
		{ AuraID = 273226, UnitID = "player" }, -- decaying spores, spore forest
		{ AuraID = 269838, UnitID = "player", Flash = true }, -- evil contamination, spore forest
		{ AuraID = 259718, UnitID = "player" }, -- subversion
		{ AuraID = 276297, UnitID = "player" }, -- Void Seed, Temple of the Storm
		{ AuraID = 274438, UnitID = "player", Flash = true }, -- storm
		{ AuraID = 276286, UnitID = "player" }, -- cutting whirlwind
		{ AuraID = 267818, UnitID = "player" }, -- cut impact
		{ AuraID = 268086, UnitID = "player", Text = L["Move"] }, -- Horror Aura, Manor
		{ AuraID = 298602, UnitID = "player" }, -- Smoke Cloud, Mechagon
		{ AuraID = 293724, UnitID = "player" }, -- shield generator
		{ AuraID = 297257, UnitID = "player" }, -- charge charge
		{ AuraID = 303885, UnitID = "player" }, -- burst eruption
		{ AuraID = 291928, UnitID = "player" }, -- supercharged railgun
		{ AuraID = 292267, UnitID = "player" }, -- supercharged railgun
		{ AuraID = 305699, UnitID = "player" }, -- lock
		{ AuraID = 302274, UnitID = "player" }, -- burst impact
		{ AuraID = 298669, UnitID = "player" }, -- Trip
		{ AuraID = 294929, UnitID = "player" }, -- Flaming Bite
		{ AuraID = 291937, UnitID = "player", Flash = true }, -- garbage cover
		{ AuraID = 259533, UnitID = "player", Flash = true }, -- Azerite catalyst, get rich
		-- Nyorosa
		-- Wrathion, Emperor of the Black Dragon
		{ AuraID = 306015, UnitID = "player" }, -- Searing Armor
		{ AuraID = 306163, UnitID = "player" }, -- all things burn
		{ AuraID = 313959, UnitID = "player", Flash = true }, -- searing bubbles
		{ AuraID = 307053, UnitID = "player", Flash = true }, -- magma pool
		{ AuraID = 314347, UnitID = "player" }, -- Poison
		-- Maut
		{ AuraID = 307399, UnitID = "player" }, -- Shadow Wounds
		{ AuraID = 307806, UnitID = "player" }, -- devour magic
		{ AuraID = 307586, UnitID = "player" }, -- Devouring Abyss
		{ AuraID = 306301, UnitID = "player" }, -- forbidden mana
		{ AuraID = 315025, UnitID = "player" }, -- Ancient Curse
		{ AuraID = 314993, UnitID = "player", Flash = true }, -- Drain Essence
		-- Prophet Skitra
		{ AuraID = 308059, UnitID = "player" }, -- Shadow Shock
		{ AuraID = 307950, UnitID = "player", Flash = true }, -- mind stripping
		-- Dark Inquisitor Xanesh
		{ AuraID = 311551, UnitID = "player" }, -- Abyss Strike
		{ AuraID = 312406, UnitID = "player" }, -- Void Awakening
		{ AuraID = 314298, UnitID = "player", Flash = true }, -- the end is near
		{ AuraID = 316211, UnitID = "player" }, -- wave of fear
		-- mastermind
		{ AuraID = 313461, UnitID = "player" }, -- Corrosion
		{ AuraID = 315311, UnitID = "player" }, -- destroy
		{ AuraID = 313672, UnitID = "player", Flash = true }, -- acid pool
		{ AuraID = 314593, UnitID = "player" }, -- Paralyzing Venom
		-- Shadhar the Insatiable
		{ AuraID = 307471, UnitID = "player" }, -- crush
		{ AuraID = 307472, UnitID = "player" }, -- melt
		{ AuraID = 306928, UnitID = "player" }, -- Shadow Breath
		{ AuraID = 306930, UnitID = "player" }, -- Entropy Aura
		{ AuraID = 314736, UnitID = "player", Flash = true }, -- Bubble overflow
		{ AuraID = 318078, UnitID = "player", Flash = true, Text = L["Get Out"] }, -- lock
		-- Dreajas
		{ AuraID = 310277, UnitID = "player" }, -- Seed of Turmoil
		{ AuraID = 310309, UnitID = "player" }, -- volatile and vulnerable
		{ AuraID = 310361, UnitID = "player" }, -- unruly frenzy
		{ AuraID = 308377, UnitID = "player" }, -- Void Ichor
		{ AuraID = 317001, UnitID = "player" }, -- shadow rejection
		{ AuraID = 310563, UnitID = "player" }, -- Whispers of Betrayal
		{ AuraID = 310567, UnitID = "player" }, -- betrayer
		-- Il'gynoth, Eclipse of Rebirth
		{ AuraID = 309961, UnitID = "player" }, -- Eye of N'Zoth
		{ AuraID = 311367, UnitID = "player" }, -- Touch of the Corruptor
		{ AuraID = 310322, UnitID = "player", Flash = true }, -- Nightmare Corruption
		{ AuraID = 313759, UnitID = "player" }, -- Cursed Blood
		-- Victory
		{ AuraID = 307359, UnitID = "player" }, -- despair
		{ AuraID = 307020, UnitID = "player" }, -- Twilight's Breath
		{ AuraID = 307019, UnitID = "player" }, -- Void Corruption
		{ AuraID = 306981, UnitID = "player" }, -- Gift of the Void
		{ AuraID = 310224, UnitID = "player" }, -- destroy
		{ AuraID = 307314, UnitID = "player" }, -- Infiltrate Shadow
		{ AuraID = 307343, UnitID = "player" }, -- shadow residue
		{ AuraID = 307645, UnitID = "player" }, -- Heart of Darkness
		{ AuraID = 315932, UnitID = "player" }, -- brute force bash
		-- Raiden the Void
		{ AuraID = 313977, UnitID = "player" }, -- Curse of the Void, mobs
		{ AuraID = 306184, UnitID = "player", Value = true }, -- released void
		{ AuraID = 306819, UnitID = "player" }, -- Aether Bash
		{ AuraID = 306279, UnitID = "player" }, -- Unrest exposure
		{ AuraID = 306637, UnitID = "player" }, -- Unstable Void Burst
		{ AuraID = 309777, UnitID = "player" }, -- Void Filth
		{ AuraID = 313227, UnitID = "player" }, -- Rot Wound
		{ AuraID = 310019, UnitID = "player" }, -- Charge Chain
		{ AuraID = 310022, UnitID = "player" }, -- charge chain
		{ AuraID = 315252, UnitID = "player" }, -- Horror Purgatory
		{ AuraID = 316065, UnitID = "player" }, -- Corruption persists
		-- En'Zoth's Shell
		{ AuraID = 307832, UnitID = "player" }, -- Servant of N'Zoth
		{ AuraID = 313334, UnitID = "player" }, -- Gift of N'Zoth
		{ AuraID = 315954, UnitID = "player" }, -- dark scar
		{ AuraID = 307044, UnitID = "player" }, -- Nightmare Antigen
		{ AuraID = 307011, UnitID = "player" }, -- multiply wildly
		{ AuraID = 307061, UnitID = "player" }, -- mycelial growth
		{ AuraID = 306973, UnitID = "player" }, -- crazy bomb
		{ AuraID = 306984, UnitID = "player" }, -- frenzy bomb
		-- N'Zoth the Corruptor
		{ AuraID = 308996, UnitID = "player" }, -- Servant of N'Zoth
		{ AuraID = 313609, UnitID = "player" }, -- Gift of N'Zoth
		{ AuraID = 309991, UnitID = "player" }, -- pain
		{ AuraID = 316711, UnitID = "player" }, -- will destroy
		{ AuraID = 313400, UnitID = "player" }, -- Fallen Mind
		{ AuraID = 316542, UnitID = "player" }, -- paranoia
		{ AuraID = 316541, UnitID = "player" }, -- paranoia
		{ AuraID = 310042, UnitID = "player" }, -- Chaos erupts
		{ AuraID = 313793, UnitID = "player" }, -- Fire of Madness
		{ AuraID = 313610, UnitID = "player" }, -- mental decay
		{ AuraID = 311392, UnitID = "player" }, -- Mind Grip
		{ AuraID = 310073, UnitID = "player" }, -- Mind Grip
		{ AuraID = 317112, UnitID = "player" }, -- agitation
		-- Eternal Palace
		-- Abyss Commander Sivara
		{ AuraID = 295795, UnitID = "player", Flash = true, Text = L["Move"] }, -- frozen blood
		{ AuraID = 295796, UnitID = "player", Flash = true, Text = L["Freeze"] }, -- Blood of Poison
		{ AuraID = 295807, UnitID = "player" }, -- Frozen Blood
		{ AuraID = 295850, UnitID = "player" }, -- madness
		{ AuraID = 294847, UnitID = "player" }, -- unstable mixture
		{ AuraID = 300883, UnitID = "player" }, -- Inversion Disease
		{ AuraID = 300701, UnitID = "player" }, -- Hoarfrost
		{ AuraID = 300705, UnitID = "player" }, -- Sepsis Contamination
		{ AuraID = 295348, UnitID = "player" }, -- Overflow Frost
		{ AuraID = 295421, UnitID = "player" }, -- Overflow Venom
		{ AuraID = 300961, UnitID = "player", Flash = true }, -- Frostland
		{ AuraID = 300962, UnitID = "player", Flash = true }, -- Bloody Land
		-- Blackwater Giant Eel
		{ AuraID = 298428, UnitID = "player" }, -- gluttony
		{ AuraID = 292127, UnitID = "player", Flash = true }, -- Jet Black Abyss
		{ AuraID = 292138, UnitID = "player" }, -- radiant biomass
		{ AuraID = 292133, UnitID = "player" }, -- bioluminescence
		{ AuraID = 301968, UnitID = "player" }, -- bioluminescence, mobs
		{ AuraID = 292167, UnitID = "player" }, -- Venomous Spine
		{ AuraID = 301180, UnitID = "player" }, -- stream
		{ AuraID = 298595, UnitID = "player" }, -- glowing spikes
		{ AuraID = 292307, UnitID = "player", Flash = true }, -- Abyss Gaze
		-- Radiance of Azshara
		{ AuraID = 296566, UnitID = "player" }, -- Fist of the Tide
		{ AuraID = 296737, UnitID = "player", Flash = true }, -- Arcane Bomb
		{ AuraID = 296746, UnitID = "player" }, -- Arcane Bomb
		{ AuraID = 299152, UnitID = "player" }, -- tumbling water
		-- Lady Ashvane
		{ AuraID = 303630, UnitID = "player" }, -- Bursting Darkness, mobs
		{ AuraID = 296725, UnitID = "player" }, -- vine slam
		{ AuraID = 296693, UnitID = "player" }, -- immersion
		{ AuraID = 296752, UnitID = "player" }, -- sharp coral
		{ AuraID = 296938, UnitID = "player" }, -- Azerite arc
		{ AuraID = 296941, UnitID = "player" },
		{ AuraID = 296942, UnitID = "player" },
		{ AuraID = 296939, UnitID = "player" },
		{ AuraID = 296940, UnitID = "player" },
		{ AuraID = 296943, UnitID = "player" },
		-- Ogozoa
		{ AuraID = 298156, UnitID = "player" }, -- paralyze spike
		{ AuraID = 298459, UnitID = "player" }, -- amniotic fluid eruption
		{ AuraID = 295779, UnitID = "player", Flash = true }, -- Water Spear
		{ AuraID = 300244, UnitID = "player", Flash = true }, -- Furious Rapids
		-- Queen's Court
		{ AuraID = 297585, UnitID = "player" }, -- obey or suffer
		{ AuraID = 301830, UnitID = "player" }, -- Touch of Pashma
		{ AuraID = 301832, UnitID = "player" }, -- crazy enthusiasm
		{ AuraID = 296851, UnitID = "player", Flash = true, Text = L["Get Out"] }, -- Fanatical Verdict
		{ AuraID = 299914, UnitID = "player" }, -- Frenzy Charge
		{ AuraID = 300545, UnitID = "player" }, -- Power Break
		{ AuraID = 304409, UnitID = "player", Flash = true }, -- repeat action
		{ AuraID = 304410, UnitID = "player", Flash = true }, -- repeat action
		{ AuraID = 304128, UnitID = "player", Text = L["Move"] }, -- probation
		{ AuraID = 297586, UnitID = "player", Flash = true }, -- suffer torture
		-- Zakul, Herald of Ny'alotha
		{ AuraID = 298192, UnitID = "player", Flash = true }, -- dark void
		{ AuraID = 295480, UnitID = "player" }, -- Mind Chain
		{ AuraID = 295495, UnitID = "player" },
		{ AuraID = 300133, UnitID = "player", Flash = true }, -- break
		{ AuraID = 292963, UnitID = "player" }, -- panic
		{ AuraID = 293509, UnitID = "player", Flash = true }, -- panic
		{ AuraID = 295327, UnitID = "player", Flash = true }, -- Shattered Mind
		{ AuraID = 296018, UnitID = "player", Flash = true }, -- insane panic
		{ AuraID = 296015, UnitID = "player" }, -- Corrosive Delirium
		-- Queen Azshara
		{ AuraID = 297907, UnitID = "player", Flash = true }, -- Cursed Heart
		{ AuraID = 299251, UnitID = "player" }, -- Obey!
		{ AuraID = 299249, UnitID = "player" }, -- Suffer!
		{ AuraID = 299255, UnitID = "player" }, -- Dequeue!
		{ AuraID = 299254, UnitID = "player" }, -- Collection!
		{ AuraID = 299252, UnitID = "player" }, -- Forward!
		{ AuraID = 299253, UnitID = "player" }, -- stop!
		{ AuraID = 298569, UnitID = "player" }, -- dry soul
		{ AuraID = 298014, UnitID = "player" }, -- ice burst
		{ AuraID = 298018, UnitID = "player", Flash = true }, -- Freeze
		{ AuraID = 298756, UnitID = "player" }, -- Jagged Edge
		{ AuraID = 298781, UnitID = "player" }, -- Arcane Orb
		{ AuraID = 303825, UnitID = "player", Flash = true }, -- drowning
		{ AuraID = 302999, UnitID = "player" }, -- Arcane Vulnerability
		{ AuraID = 303657, UnitID = "player", Flash = true }, -- Arcane Blast
		-- Storm Furnace
		{ AuraID = 282384, UnitID = "player" }, -- mentally split, no sleepless party
		{ AuraID = 282566, UnitID = "player" }, -- promise of power
		{ AuraID = 282561, UnitID = "player" }, -- Darkbringer
		{ AuraID = 282432, UnitID = "player", Text = L["Get Out"] }, -- Shattered Doubt
		{ AuraID = 282621, UnitID = "player" }, -- Witness of the End
		{ AuraID = 282743, UnitID = "player" }, -- storm annihilation
		{ AuraID = 282738, UnitID = "player" }, -- Embrace of the Void
		{ AuraID = 282589, UnitID = "player" }, -- Brain Invasion
		{ AuraID = 287876, UnitID = "player" }, -- Devour of Darkness
		{ AuraID = 282540, UnitID = "player" }, -- Death Avatar
		{ AuraID = 284851, UnitID = "player" }, -- Touch of Doom, Unat
		{ AuraID = 285652, UnitID = "player" }, -- gluttony torture
		{ AuraID = 285685, UnitID = "player" }, -- Gift of N'Zoth: Madness
		{ AuraID = 284804, UnitID = "player" }, -- Aegis of the Abyss
		{ AuraID = 285477, UnitID = "player" }, -- Abyss
		{ AuraID = 285367, UnitID = "player" }, -- Piercing Gaze of N'Zoth
		{ AuraID = 284733, UnitID = "player", Flash = true }, -- Embrace of the Void
		-- Battle of Dazar'alor
		{ AuraID = 283573, UnitID = "player" }, -- Holy Blade, Warrior of Light
		{ AuraID = 285671, UnitID = "player" }, -- Crush, Grong, King of the Jungle
		{ AuraID = 285998, UnitID = "player" }, -- fierce growl
		{ AuraID = 285875, UnitID = "player" }, -- Rip and Bite
		{ AuraID = 283069, UnitID = "player", Flash = true }, -- Atomic Flame
		{ AuraID = 286434, UnitID = "player", Flash = true }, -- Necrotic Core
		{ AuraID = 289406, UnitID = "player" }, -- brute force throw
		{ AuraID = 286988, UnitID = "player" }, -- Fiery Embers, Master of Jade Fire
		{ AuraID = 284374, UnitID = "player" }, -- lava trap
		{ AuraID = 282037, UnitID = "player" }, -- Rising Flame
		{ AuraID = 286379, UnitID = "player" }, -- Pyroblast
		{ AuraID = 285632, UnitID = "player" }, -- tracking
		{ AuraID = 288151, UnitID = "player" }, -- Aftermath of the test
		{ AuraID = 284089, UnitID = "player" }, -- successfully defended
		{ AuraID = 287424, UnitID = "player" }, -- Thief's Retribution, Fengling
		{ AuraID = 284527, UnitID = "player" }, -- Gem of Fortitude
		{ AuraID = 284556, UnitID = "player" }, -- Shadow Touch
		{ AuraID = 284573, UnitID = "player" }, -- Tailwind Power
		{ AuraID = 284664, UnitID = "player" }, -- fiery
		{ AuraID = 284798, UnitID = "player" }, -- extremely hot
		{ AuraID = 284802, UnitID = "player", Flash = true }, -- shine aura
		{ AuraID = 284817, UnitID = "player" }, -- Earth Roots
		{ AuraID = 284881, UnitID = "player" }, -- release anger
		{ AuraID = 283507, UnitID = "player", Text = L["Get Out"], Flash = true }, -- burst charge
		{ AuraID = 287648, UnitID = "player", Text = L["Get Out"], Flash = true }, -- burst charge
		{ AuraID = 287072, UnitID = "player", Text = L["Get Out"], Flash = true }, -- liquid gold
		{ AuraID = 284424, UnitID = "player", Flash = true }, -- The Burning Ground
		{ AuraID = 285014, UnitID = "player", Flash = true }, -- rain of gold coins
		{ AuraID = 285479, UnitID = "player", Flash = true }, -- flamethrower
		{ AuraID = 283947, UnitID = "player", Flash = true }, -- flamethrower
		{ AuraID = 289383, UnitID = "player", Flash = true }, -- Chaos displacement
		{ AuraID = 291146, UnitID = "player", Text = L["Freeze"], Flash = true }, -- Chaos displacement
		{ AuraID = 284470, UnitID = "player", Text = L["Freeze"], Flash = true }, -- Sleeping Hex
		{ AuraID = 282444, UnitID = "player" }, -- Crack Claw Slam, Order of the Chosen
		{ AuraID = 286838, UnitID = "player" }, -- static ball
		{ AuraID = 285879, UnitID = "player" }, -- amnestic
		{ AuraID = 282135, UnitID = "player" }, -- Malicious Hex
		{ AuraID = 282209, UnitID = "player", Flash = true }, -- Mark of Predator
		{ AuraID = 286821, UnitID = "player", Text = L["Get Out"], Flash = true }, -- Akunda's Wrath
		{ AuraID = 284831, UnitID = "player", Text = L["Get Out"], Flash = true }, -- Flaming Explosion, King Rastakhan
		{ AuraID = 284662, UnitID = "player", Text = L["Get Out"], Flash = true }, -- Seal of Purification
		{ AuraID = 290450, UnitID = "player", Text = L["Get Out"], Flash = true }, -- Seal of Purification
		{ AuraID = 289858, UnitID = "player" }, -- crush
		{ AuraID = 284740, UnitID = "player" }, -- heavy axe throw
		{ AuraID = 284781, UnitID = "player" }, -- heavy axe throw
		{ AuraID = 285195, UnitID = "player" }, -- death and decay
		{ AuraID = 288449, UnitID = "player" }, -- Death's Gate
		{ AuraID = 284376, UnitID = "player" }, -- the presence of death
		{ AuraID = 285349, UnitID = "player" }, -- Crimson Plague
		{ AuraID = 287147, UnitID = "player", Flash = true }, -- Fear Harvest
		{ AuraID = 284168, UnitID = "player" }, -- Zoom out, High Tinker Mekkatorque
		{ AuraID = 282182, UnitID = "player" }, -- Destruction Cannon
		{ AuraID = 286516, UnitID = "player" }, -- anti-interference shock
		{ AuraID = 286480, UnitID = "player" }, -- anti-interference shock
		{ AuraID = 287167, UnitID = "player" }, -- Gene unmarshalling
		{ AuraID = 286105, UnitID = "player" }, -- Interference
		{ AuraID = 286646, UnitID = "player", Text = L["Get Out"], Flash = true }, -- Gigavolt charge
		{ AuraID = 285075, UnitID = "player", Flash = true }, -- Frozen Tide Pools, Storm Wall Blockade
		{ AuraID = 284121, UnitID = "player", Flash = true }, -- thunder roar
		{ AuraID = 285000, UnitID = "player" }, -- seaweed wrap
		{ AuraID = 285350, UnitID = "player", Flash = true }, -- howl of the storm
		{ AuraID = 285426, UnitID = "player", Flash = true }, -- howl of the storm
		{ AuraID = 287490, UnitID = "player" }, -- Freeze, Jaina
		{ AuraID = 287993, UnitID = "player" }, -- Touch of Ice
		{ AuraID = 285253, UnitID = "player" }, -- Ice Shard
		{ AuraID = 288394, UnitID = "player" }, -- heat
		{ AuraID = 288212, UnitID = "player" }, -- broadside attack
		{ AuraID = 288374, UnitID = "player" }, -- Citybreaker shelling
		-- Uldir
		{ AuraID = 271224, UnitID = "player", Text = L["Get Out"], Flash = true }, -- Crimson Burst, Tarot
		{ AuraID = 271225, UnitID = "player", Text = L["Get Out"], Flash = true },
		{ AuraID = 278888, UnitID = "player", Text = L["Get Out"], Flash = true },
		{ AuraID = 278889, UnitID = "player", Text = L["Get Out"], Flash = true },
		{ AuraID = 267787, UnitID = "player" }, -- Sanitizing Strike, Our Lady of Purity
		{ AuraID = 262313, UnitID = "player" }, -- fetid methane, putrid eater
		{ AuraID = 265237, UnitID = "player" }, -- smash, Zekworth
		{ AuraID = 265264, UnitID = "player" }, -- Void Flay, Zekworth
		{ AuraID = 265360, UnitID = "player", Text = L["Get Out"], Flash = true }, -- Tumbling Fraud, Zekworth
		{ AuraID = 265662, UnitID = "player" }, -- Pact of the Corruptor, Zekworth
		{ AuraID = 265127, UnitID = "player" }, -- persistent infection, Viktis
		{ AuraID = 265129, UnitID = "player" }, -- the ultimate cell, Viktes
		{ AuraID = 267160, UnitID = "player" },
		{ AuraID = 267161, UnitID = "player" },
		{ AuraID = 274990, UnitID = "player", Flash = true }, -- Rupture damage, Viktes
		{ AuraID = 273434, UnitID = "player" }, -- Abyss of Despair, Zul
		{ AuraID = 274271, UnitID = "player" }, -- Death Wish, Zul
		{ AuraID = 273365, UnitID = "player", Text = L["Get Out"], Flash = true }, -- Dark Apocalypse, Zul
		{ AuraID = 272146, UnitID = "player" }, -- destroyer, dismantler
		{ AuraID = 272536, UnitID = "player", Text = L["Get Out"], Flash = true }, -- Destruction is imminent, Demolitionist
		{ AuraID = 274262, UnitID = "player", Text = L["Get Out"], Flash = true }, -- Explosive Corruption, G'huun
		{ AuraID = 267409, UnitID = "player" }, -- Dark Deal, G'huun
		{ AuraID = 263227, UnitID = "player" }, -- Corrupted Blood, G'huun
		{ AuraID = 267700, UnitID = "player" }, -- G'huun's gaze, G'huun
		{ AuraID = 273405, UnitID = "player" }, -- Dark Deal, G'huun
		-- Emerald Nightmare
		-- Nisandra
		{ AuraID = 221028, UnitID = "player" }, -- unstable rot, mobs
		{ AuraID = 204504, UnitID = "player" }, -- infection
		{ AuraID = 205043, UnitID = "player" }, -- Infect Will
		{ AuraID = 203096, UnitID = "player" }, -- fester
		{ AuraID = 204463, UnitID = "player" }, -- burst and fester
		{ AuraID = 203646, UnitID = "player" }, -- Corrosive Burst
		-- Il'gynoth, Heart of Corruption
		{ AuraID = 210099, UnitID = "player" }, -- lock
		{ AuraID = 209469, UnitID = "player" }, -- Touch of Corruption
		{ AuraID = 210984, UnitID = "player" }, -- Eye of Fate
		{ AuraID = 208929, UnitID = "player" }, -- Corrupt Breath
		{ AuraID = 215128, UnitID = "player" }, -- Cursed Blood
		{ AuraID = 209471, UnitID = "player" }, -- Nightmare Blast
		-- Ellery Thérèvral
		{ AuraID = 210228, UnitID = "player" }, -- Venomous Fang
		{ AuraID = 215300, UnitID = "player" }, -- Web of Pain
		{ AuraID = 215307, UnitID = "player" }, -- Web of Pain
		{ AuraID = 215460, UnitID = "player" }, -- Necro Venom
		{ AuraID = 210850, UnitID = "player" }, -- Twisted Shadow
		{ AuraID = 215582, UnitID = "player" }, -- Fel Raven Claws
		{ AuraID = 218519, UnitID = "player" }, -- raging wind
		-- Ursoc
		{ AuraID = 197943, UnitID = "player" }, -- vulnerable
		{ AuraID = 204859, UnitID = "player" }, -- tear flesh
		{ AuraID = 198006, UnitID = "player" }, -- focus gaze
		{ AuraID = 198108, UnitID = "player" }, -- the momentum
		-- Nightmare Dragon
		{ AuraID = 204731, UnitID = "player" }, -- spread fear
		{ AuraID = 205341, UnitID = "player" }, -- Infiltrating Mist
		{ AuraID = 203770, UnitID = "player" }, -- Desecrated Vineman
		{ AuraID = 204078, UnitID = "player" }, -- growl
		{ AuraID = 203110, UnitID = "player" }, -- Sleepy Nightmare
		{ AuraID = 203787, UnitID = "player" }, -- rapid infection
		{ AuraID = 214543, UnitID = "player" }, -- Collapse Nightmare
		-- Cenarius
		{ AuraID = 210315, UnitID = "player" }, -- Nightmare Thorns
		{ AuraID = 211989, UnitID = "player" }, -- Rampage Touch
		{ AuraID = 216516, UnitID = "player" }, -- Ancient Dream
		{ AuraID = 213162, UnitID = "player" }, -- Nightmare Blast
		{ AuraID = 208431, UnitID = "player" }, -- fall into madness
		-- Xavius
		{ AuraID = 206651, UnitID = "player" }, -- Dark Soul
		{ AuraID = 209158, UnitID = "player" }, -- blackened soul
		{ AuraID = 210451, UnitID = "player" }, -- fear connection
		{ AuraID = 209034, UnitID = "player" }, -- fear connection
		{ AuraID = 211802, UnitID = "player" }, -- Nightmare Blade
		{ AuraID = 205771, UnitID = "player" }, -- Torment Lock
		-- Test of Courage
		-- Odin
		{ AuraID = 228932, UnitID = "player" }, -- Stormforged Spear
		{ AuraID = 227807, UnitID = "player" }, -- Righteous Storm
		-- Gorm
		{ AuraID = 228228, UnitID = "player" }, -- fire tongue lick
		{ AuraID = 228248, UnitID = "player" }, -- ice tongue licking
		{ AuraID = 228253, UnitID = "player", Value = true }, -- Shadow tongue licking
		-- HELLA
		{ AuraID = 227982, UnitID = "player" }, -- poisonous water oxidation
		{ AuraID = 228054, UnitID = "player" }, -- ocean pollution
		{ AuraID = 193367, UnitID = "player" }, -- fetid fester
		{ AuraID = 228519, UnitID = "player" }, -- Anchor Slam
		{ AuraID = 232488, UnitID = "player" }, -- dark hatred
		{ AuraID = 232450, UnitID = "player", Value = true }, -- Corrupted Spinal Corruption
		-- Night Fortress
		-- Scorpion
		{ AuraID = 204531, UnitID = "player" }, -- Arcane Shackles
		{ AuraID = 211659, UnitID = "player" }, -- Arcane Shackles
		{ AuraID = 204483, UnitID = "player" }, -- focus impact
		-- Temporal Anomaly
		{ AuraID = 212099, UnitID = "player" }, -- time charge
		{ AuraID = 206617, UnitID = "player", Text = L["Get Out"] }, -- time bomb
		{ AuraID = 219964, UnitID = "player" }, -- time release
		{ AuraID = 219965, UnitID = "player" }, -- time release
		{ AuraID = 219966, UnitID = "player" }, -- time release
		-- Trilliax
		{ AuraID = 206641, UnitID = "player" }, -- Arcane Dream Strike
		{ AuraID = 206838, UnitID = "player" }, -- Juicy Feast
		{ AuraID = 214573, UnitID = "player" }, -- eat a meal
		{ AuraID = 208499, UnitID = "player" }, -- drain vitality
		{ AuraID = 211615, UnitID = "player" }, -- drain vitality
		{ AuraID = 208910, UnitID = "player" }, -- arc connection
		{ AuraID = 208915, UnitID = "player" }, -- arc connection
		-- Magic Swordsman Aluriel
		{ AuraID = 212531, UnitID = "player" }, -- Mark of Frost
		{ AuraID = 212587, UnitID = "player" }, -- Mark of Frost
		{ AuraID = 212647, UnitID = "player" }, -- Mark of Frost
		{ AuraID = 213148, UnitID = "player" }, -- Searing Brand
		{ AuraID = 213504, UnitID = "player" }, -- Arcane Mist
		-- Tichondrius
		{ AuraID = 206480, UnitID = "player" }, -- Carrion Plague
		{ AuraID = 208230, UnitID = "player" }, -- Feast of Blood
		{ AuraID = 206311, UnitID = "player" }, -- Illusion Night
		{ AuraID = 212794, UnitID = "player" }, -- Brand of Argus
		{ AuraID = 215988, UnitID = "player" }, -- Carrion Nightmare
		{ AuraID = 206466, UnitID = "player" }, -- Essence of Night
		{ AuraID = 216024, UnitID = "player" }, -- burst wound
		{ AuraID = 216040, UnitID = "player" }, -- Burning Soul
		-- Crosus
		{ AuraID = 206677, UnitID = "player" }, -- Burning Brand
		{ AuraID = 205344, UnitID = "player" }, -- Orb of Destruction
		-- Senior Botanist Tel'arn
		{ AuraID = 218342, UnitID = "player" }, -- parasitic gaze
		{ AuraID = 218503, UnitID = "player" }, -- return strike
		{ AuraID = 218304, UnitID = "player" }, -- Parasitic Shackles
		{ AuraID = 218809, UnitID = "player" }, -- Call of the Night
		{ AuraID = 218780, UnitID = "player" }, -- ion explosion
		-- Astrologer Etraus
		{ AuraID = 206464, UnitID = "player" }, -- coronal jet
		{ AuraID = 205649, UnitID = "player" }, -- Fel Jet
		{ AuraID = 206398, UnitID = "player" }, -- Felflame
		{ AuraID = 206936, UnitID = "player" }, -- ice blast
		{ AuraID = 207720, UnitID = "player" }, -- Witness the Void
		{ AuraID = 206589, UnitID = "player" }, -- frozen
		{ AuraID = 207831, UnitID = "player" }, -- astrological triangle
		{ AuraID = 205445, UnitID = "player" }, -- constellation pairing
		{ AuraID = 205429, UnitID = "player" }, -- constellation pairing
		{ AuraID = 216345, UnitID = "player" }, -- constellation pairing
		{ AuraID = 216344, UnitID = "player" }, -- constellation pairing
		-- Grand Magister Elisande
		{ AuraID = 209166, UnitID = "player" }, -- time acceleration
		{ AuraID = 209165, UnitID = "player" }, -- slow down time
		{ AuraID = 209244, UnitID = "player" }, -- mysterious ray
		{ AuraID = 209598, UnitID = "player" }, -- aggregate blast
		{ AuraID = 209615, UnitID = "player" }, -- ablation
		{ AuraID = 209973, UnitID = "player" }, -- ablation blast
		{ AuraID = 211885, UnitID = "player" }, -- giant hook
		-- Gul'dan
		{ AuraID = 210339, UnitID = "player" }, -- time extension
		{ AuraID = 206985, UnitID = "player" }, -- dissipate field
		-- Tomb of Sargeras
		-- Gross
		{ AuraID = 233272, UnitID = "player" }, -- Shattered Stars
		{ AuraID = 231363, UnitID = "player" }, -- Burning Armor
		{ AuraID = 234264, UnitID = "player" }, -- melt armor
		{ AuraID = 230345, UnitID = "player" }, -- comet collision
		-- Demon Inquisition
		{ AuraID = 248741, UnitID = "player" }, -- bone saw
		{ AuraID = 233983, UnitID = "player" }, -- Echoing Pain
		{ AuraID = 233430, UnitID = "player" }, -- unbearable torture
		{ AuraID = 233901, UnitID = "player" }, -- Choking Darkness
		{ AuraID = 248713, UnitID = "player" }, -- Soul Corruption
		-- Hayatan
		{ AuraID = 248713, UnitID = "player" }, -- Soul Corruption
		{ AuraID = 234016, UnitID = "player" }, -- Force raid
		{ AuraID = 241573, UnitID = "player" }, -- drip
		{ AuraID = 231998, UnitID = "player" }, -- sawtooth trauma
		{ AuraID = 231770, UnitID = "player" }, -- soak
		{ AuraID = 231729, UnitID = "player" }, -- Water Burst
		{ AuraID = 241600, UnitID = "player" }, -- pathological locking
		-- Sisters of the Moon
		{ AuraID = 236596, UnitID = "player" }, -- rapid fire
		{ AuraID = 236712, UnitID = "player" }, -- Moonlight Beacon
		{ AuraID = 239264, UnitID = "player" }, -- Moonfire
		{ AuraID = 236519, UnitID = "player" }, -- Moonburn
		{ AuraID = 236550, UnitID = "player" }, -- invisible
		{ AuraID = 236305, UnitID = "player" }, -- Spirit Shot
		{ AuraID = 236330, UnitID = "player" }, -- Astral Vulnerability
		{ AuraID = 233263, UnitID = "player", Value = true }, -- Embrace of the Eclipse
		-- Mistress Sasslyn
		{ AuraID = 230362, UnitID = "player" }, -- Thunder Shock
		{ AuraID = 230201, UnitID = "player" }, -- burden of pain
		{ AuraID = 230959, UnitID = "player" }, -- dark stealth
		{ AuraID = 232754, UnitID = "player" }, -- Hydra acid
		{ AuraID = 232913, UnitID = "player" }, -- tainted ink
		{ AuraID = 230384, UnitID = "player" }, -- Devouring Hunger
		{ AuraID = 230920, UnitID = "player" }, -- Devouring Hunger
		{ AuraID = 234661, UnitID = "player" }, -- Devouring Hunger
		{ AuraID = 239375, UnitID = "player" }, -- delicious buff fish
		{ AuraID = 239362, UnitID = "player" }, -- delicious buff fish
		-- Desperate Aggregate
		{ AuraID = 236361, UnitID = "player" }, -- Soul Chain
		{ AuraID = 236340, UnitID = "player" }, -- Shatter Will
		{ AuraID = 236515, UnitID = "player" }, -- Broken Scream
		{ AuraID = 238418, UnitID = "player" }, -- Shattering Scream
		{ AuraID = 236459, UnitID = "player" }, -- Soulbound
		{ AuraID = 236138, UnitID = "player" }, -- wither
		{ AuraID = 236131, UnitID = "player" }, -- wither
		{ AuraID = 236011, UnitID = "player" }, -- Tormented Wailing
		{ AuraID = 238018, UnitID = "player" }, -- Tormented Wailing
		{ AuraID = 235924, UnitID = "player" }, -- Spear of Pain
		{ AuraID = 238442, UnitID = "player", Value = true }, -- Spear of Pain
		-- Guard Maid
		{ AuraID = 243276, UnitID = "player" }, -- Turbulent Soul
		{ AuraID = 235117, UnitID = "player" }, -- Turbulent Soul
		{ AuraID = 235538, UnitID = "player" }, -- Demon Vigor
		{ AuraID = 235534, UnitID = "player" }, -- Gift of the Creator
		{ AuraID = 241593, UnitID = "player" }, -- Aegwynn's Ward
		{ AuraID = 238408, UnitID = "player" }, -- Fel Residue
		{ AuraID = 238028, UnitID = "player" }, -- Remnants of Light
		{ AuraID = 248812, UnitID = "player" }, -- recoil
		{ AuraID = 248801, UnitID = "player" }, -- shard burst
		{ AuraID = 241729, UnitID = "player" }, -- vengeful spirit
		{ AuraID = 235213, UnitID = "player" }, -- Infusion of Light
		{ AuraID = 235240, UnitID = "player" }, -- Fel Infusion
		-- Fallen Avatar
		{ AuraID = 234059, UnitID = "player" }, -- Unleash Chaos
		{ AuraID = 236494, UnitID = "player" }, -- wind erosion
		{ AuraID = 239739, UnitID = "player" }, -- Dark Mark
		{ AuraID = 242017, UnitID = "player" }, -- Dark Wind
		{ AuraID = 240746, UnitID = "player" }, -- tainted matrix
		{ AuraID = 240728, UnitID = "player" }, -- Tainted Essence
		-- Kil'jaeden
		{ AuraID = 234310, UnitID = "player" }, -- Doomsday
		{ AuraID = 245509, UnitID = "player" }, -- Evil Claw
		{ AuraID = 236710, UnitID = "player" }, -- Shadow Image: Outbreak
		{ AuraID = 236378, UnitID = "player" }, -- Shadow Reflection: Wailing
		{ AuraID = 240916, UnitID = "player" }, -- Hail of Doom
		{ AuraID = 236555, UnitID = "player" }, -- Fraudster's mask
		{ AuraID = 241721, UnitID = "player" }, -- Illidan's Eyeless Gaze
		{ AuraID = 240262, UnitID = "player" }, -- burn
		{ AuraID = 237590, UnitID = "player" }, -- Shadow Reflection: Despair
		{ AuraID = 243621, UnitID = "player" }, -- haunting hope
		{ AuraID = 243624, UnitID = "player" }, -- haunting wailing
		{ AuraID = 241822, UnitID = "player", Value = true }, -- Choking Shadow
		-- Burning Throne
		-- Garothy Worldbreaker
		{ AuraID = 244410, UnitID = "player" }, -- slaughter
		{ AuraID = 245294, UnitID = "player" }, -- enhanced slaughter
		{ AuraID = 246920, UnitID = "player" }, -- slaughter
		-- The Hound of Sargeras
		{ AuraID = 244091, UnitID = "player" }, -- burnt
		{ AuraID = 248815, UnitID = "player" }, -- ignite
		{ AuraID = 244768, UnitID = "player" }, -- Desolate Gaze
		{ AuraID = 244055, UnitID = "player" }, -- Shadow Touch
		{ AuraID = 244054, UnitID = "player" }, -- Flaming Scar
		-- Antoran Commander's Council
		{ AuraID = 253290, UnitID = "player" }, -- entropy burst
		{ AuraID = 244737, UnitID = "player" }, -- Concussion Grenade
		{ AuraID = 244748, UnitID = "player" }, -- stun
		-- Portal Keeper Hasabel
		{ AuraID = 245118, UnitID = "player" }, -- Shadow of Satisfaction
		{ AuraID = 244709, UnitID = "player" }, -- flame detonation
		{ AuraID = 246208, UnitID = "player" }, -- Acid Web
		{ AuraID = 245099, UnitID = "player" }, -- fog of consciousness
		-- Eonar the Life-Binder
		{ AuraID = 248332, UnitID = "player" }, -- Rain of Fel
		{ AuraID = 249017, UnitID = "player" }, -- Feedback - Arcane Singularity
		{ AuraID = 249014, UnitID = "player" }, -- Feedback - Foul Footprint
		{ AuraID = 249015, UnitID = "player" }, -- Feedback - Burning Embers
		{ AuraID = 249016, UnitID = "player" }, -- feedback-target lock
		-- Immonar the Soulhunter
		{ AuraID = 247367, UnitID = "player" }, -- Shock Gun
		{ AuraID = 247687, UnitID = "player" }, -- tear
		{ AuraID = 247565, UnitID = "player" }, -- hypnotic gas
		{ AuraID = 250224, UnitID = "player" }, -- stun
		{ AuraID = 255029, UnitID = "player", Text = L["Get Out"] }, -- Hypnotic Air Tank
		-- Kingaroth
		{ AuraID = 254919, UnitID = "player" }, -- Forged Strike
		{ AuraID = 253384, UnitID = "player" }, -- massacre
		{ AuraID = 249535, UnitID = "player" }, -- Destruction
		-- Varimathras
		{ AuraID = 244042, UnitID = "player" }, -- marked prey
		{ AuraID = 248732, UnitID = "player" }, -- Echo of Destruction
		{ AuraID = 244094, UnitID = "player", Text = L["Get Out"] }, -- Wraith's Embrace
		-- Destroy the Witch Guild
		{ AuraID = 244899, UnitID = "player" }, -- Fire Strike
		{ AuraID = 245518, UnitID = "player" }, -- quick freeze
		{ AuraID = 245634, UnitID = "player" }, -- Spinning Sabre
		{ AuraID = 253020, UnitID = "player" }, -- Dark Storm
		{ AuraID = 253520, UnitID = "player" }, -- burst pulse
		{ AuraID = 245586, UnitID = "player", Value = true }, -- Condensed Blood
		-- Aggramar
		{ AuraID = 245990, UnitID = "player" }, -- Touch of Taeshalak
		{ AuraID = 244291, UnitID = "player" }, -- Breaker
		{ AuraID = 245994, UnitID = "player" }, -- Searing Flame
		{ AuraID = 247079, UnitID = "player" }, -- Enhanced Flame Rend
		{ AuraID = 254452, UnitID = "player" }, -- gluttonous flames
		-- Argus the Unmaker
		{ AuraID = 248499, UnitID = "player" }, -- Scythe Scythe
		{ AuraID = 253903, UnitID = "player" }, -- Sky Force
		{ AuraID = 258646, UnitID = "player" }, -- gift from the sky
		{ AuraID = 253901, UnitID = "player" }, -- Ocean Power
		{ AuraID = 258647, UnitID = "player" }, -- Gift of the Sea
		{ AuraID = 255199, UnitID = "player" }, -- Avatar of Aggramar
		{ AuraID = 252729, UnitID = "player" }, -- cosmic rays
		{ AuraID = 248396, UnitID = "player", Text = L["Get Out"] }, -- soul wither
		{ AuraID = 250669, UnitID = "player", Text = L["Get Out"] }, -- Soul Burst
	},
	["Warning"] = { -- target important aura group
		-- 8.0 copy
		{ AuraID = 300011, UnitID = "target" }, -- force shield, Mechagon
		{ AuraID = 257458, UnitID = "target" }, -- Freehold Tail King Vulnerable
		{ AuraID = 260512, UnitID = "target" }, -- Soul Harvest, Temple
		{ AuraID = 277965, UnitID = "target" }, -- heavy ordnance, siege 1
		{ AuraID = 273721, UnitID = "target" },
		{ AuraID = 256493, UnitID = "target" }, -- Blazing Azerite, mine 1
		{ AuraID = 271867, UnitID = "target" }, -- Krypton Gold wins, mine 1
		-- Nyorosa
		{ AuraID = 313175, UnitID = "target" }, -- Hardened Core, Wrathion
		{ AuraID = 306005, UnitID = "target" }, -- Obsidian skin, Maut
		{ AuraID = 313208, UnitID = "target" }, -- Invisible Vision, Prophet Skitra
		{ AuraID = 312329, UnitID = "target" }, -- Gobble, Shadhar the Insatiable
		{ AuraID = 312595, UnitID = "target" }, -- Explosive Corrosion, Dre'agath
		{ AuraID = 312750, UnitID = "target" }, -- Summons the Nightmare, Ra-den the Void
		{ AuraID = 306990, UnitID = "target", Value = true }, -- Adaptive outer membrane, En'Zoth shell
		{ AuraID = 310126, UnitID = "target" }, -- Mind Shell, N'Zoth
		{ AuraID = 312155, UnitID = "target" }, -- shatter self
		{ AuraID = 313184, UnitID = "target" }, -- synaptic shock
		-- Eternal Palace
		{ AuraID = 296389, UnitID = "target" }, -- Top cyclone, the radiance of Azshara
		{ AuraID = 304951, UnitID = "target" }, -- focus energy
		{ AuraID = 295916, UnitID = "target" }, -- Ancient Storm
		{ AuraID = 296650, UnitID = "target", Value = true }, -- Hardened Carapace, Lady Ashvane
		{ AuraID = 299575, UnitID = "target" }, -- Commander's Wrath, Court of the Queen
		{ AuraID = 296716, UnitID = "target", Flash = true }, -- Checks of Power, Queen's Court
		{ AuraID = 295099, UnitID = "target" }, -- Penetrate the Darkness, Za'qul
		-- Storm Furnace
		{ AuraID = 282741, UnitID = "target", Value = true }, -- Shadow Shell, The Sleepless Party
		{ AuraID = 284722, UnitID = "target", Value = true }, -- Shadow Shell, Unat
		{ AuraID = 287693, UnitID = "target", Flash = true }, -- implicit link
		{ AuraID = 286310, UnitID = "target" }, -- Void Shield
		{ AuraID = 285333, UnitID = "target" }, -- unnatural regeneration
		{ AuraID = 285642, UnitID = "target" }, -- Gift of N'Zoth: Hysteria
		-- Battle of Dazar'alor
		{ AuraID = 284459, UnitID = "target" }, -- Zealot, Champion of the Light
		{ AuraID = 284436, UnitID = "target" }, -- Seal of Reckoning
		{ AuraID = 282113, UnitID = "target" }, -- Wrath of Vengeance
		{ AuraID = 281936, UnitID = "target" }, -- Enraged, Grong, King of the Jungle
		{ AuraID = 286425, UnitID = "target", Value = true }, -- Fire Shield, Master Jade Fire
		{ AuraID = 286436, UnitID = "target" }, -- Emerald Storm
		{ AuraID = 284614, UnitID = "target" }, -- focus on hostility, Fengling
		{ AuraID = 284943, UnitID = "target" }, -- greedy
		{ AuraID = 285945, UnitID = "target", Flash = true }, -- Rapid Wind, Order of the Chosen
		{ AuraID = 285893, UnitID = "target" }, -- Feral Maul
		{ AuraID = 282079, UnitID = "target" }, -- contract of the gods
		{ AuraID = 284377, UnitID = "target" }, -- Breathless, King Rastakhan
		{ AuraID = 284446, UnitID = "target" }, -- Bwonsamdi's favor
		{ AuraID = 289169, UnitID = "target" }, -- Bwonsamdi's favor
		{ AuraID = 284613, UnitID = "target" }, -- Realm of the Natural Dead
		{ AuraID = 286051, UnitID = "target" }, -- FTL, Master Craftsman
		{ AuraID = 289699, UnitID = "target", Flash = true }, -- power boost
		{ AuraID = 286558, UnitID = "target", Value = true }, -- tidal mask, storm wall
		{ AuraID = 287995, UnitID = "target", Value = true }, -- current shield
		{ AuraID = 287322, UnitID = "target" }, -- Ice Barrier, Jaina
		-- Uldir
		{ AuraID = 271965, UnitID = "target" }, -- power off, taroc
		{ AuraID = 277548, UnitID = "target" }, -- smash the darkness, mobs
		{ AuraID = 278218, UnitID = "target" }, -- Voidcall, Zekwarz
		{ AuraID = 278220, UnitID = "target" }, -- Void detachment, Zekworth
		{ AuraID = 265264, UnitID = "target" }, -- Void Flay, Zekworth
		{ AuraID = 273432, UnitID = "target" }, -- Shadowbound, Zul
		{ AuraID = 273288, UnitID = "target" }, -- pulsating, Zul
		{ AuraID = 274230, UnitID = "target" }, -- Veil of Oblivion, Mythrax the Unraveler
		{ AuraID = 276900, UnitID = "target" }, -- Critical Blaze, Mythrax the Deconstructor
		{ AuraID = 279013, UnitID = "target" }, -- Essence Shatter, Mythrax the Dismantler
		{ AuraID = 263504, UnitID = "target" }, -- Restructuring Blast, G'huun
		{ AuraID = 273251, UnitID = "target" }, -- Restructuring Blast, G'huun
		{ AuraID = 263372, UnitID = "target" }, -- energy matrix, G'huun
		{ AuraID = 270447, UnitID = "target" }, -- Corruption grows, G'huun
		{ AuraID = 263217, UnitID = "target" }, -- Blood Shield, G'huun
		{ AuraID = 275129, UnitID = "target" }, -- bloated, G'huun
		-- 7.0 copy
		{ AuraID = 244621, UnitID = "target" }, -- Void Fissure, Tail King of the Triumvirate
		{ AuraID = 192132, UnitID = "target" }, -- Valhalla Heya
		{ AuraID = 192133, UnitID = "target" }, -- Valhalla Hya
		{ AuraID = 194333, UnitID = "target" }, -- Vault Eye is vulnerable
		{ AuraID = 254020, UnitID = "target" }, -- Darkness looms, Triumvirate Lula
		{ AuraID = 229495, UnitID = "target" }, -- King Karazhan is vulnerable
		{ AuraID = 227817, UnitID = "target", Value = true }, -- Shield of Karazhan
		-- Emerald Nightmare
		{ AuraID = 215234, UnitID = "target" }, -- Nightmare Fury
		{ AuraID = 211137, UnitID = "target" }, -- Wind of Corruption
		{ AuraID = 212707, UnitID = "target" }, -- Summons Cloud to Gather Qi
		{ AuraID = 210346, UnitID = "target" }, -- Dread Thorns Aura
		{ AuraID = 210340, UnitID = "target" }, -- Dread Thorns Aura
		-- Test of Courage
		{ AuraID = 229256, UnitID = "target" }, -- Odin, Arcstorm
		{ AuraID = 228174, UnitID = "target" }, -- Gorm, Spitting Fury
		{ AuraID = 228803, UnitID = "target" }, -- Hela, brewing a storm
		{ AuraID = 203816, UnitID = "target" }, -- mobs, energy
		{ AuraID = 228611, UnitID = "target" }, -- mobs, ghost rage
		-- Night Fortress
		{ AuraID = 204697, UnitID = "target" }, -- Scorpion Swarm
		{ AuraID = 204448, UnitID = "target" }, -- chitin shell
		{ AuraID = 206947, UnitID = "target" }, -- chitin shell
		{ AuraID = 205947, UnitID = "target" }, -- Energized Shell
		{ AuraID = 204459, UnitID = "target" }, -- vulnerable shell
		{ AuraID = 205289, UnitID = "target" }, -- Gift of the Scorpion
		{ AuraID = 219823, UnitID = "target" }, -- unstoppable
		{ AuraID = 215066, UnitID = "target" }, -- Personality overlap
		{ AuraID = 216028, UnitID = "target" }, -- rapid pursuit
		{ AuraID = 219248, UnitID = "target" }, -- fast growth
		{ AuraID = 219270, UnitID = "target" }, -- overgrowth
		{ AuraID = 219009, UnitID = "target" }, -- nature's bounty
		{ AuraID = 209568, UnitID = "target" }, -- heat release
		{ AuraID = 221863, UnitID = "target" }, -- shield
		{ AuraID = 221524, UnitID = "target" }, -- protection, former mobs
		-- Tomb of Sargeras
		{ AuraID = 233441, UnitID = "target" }, -- bone saw
		{ AuraID = 239135, UnitID = "target" }, -- Torment Eruption
		{ AuraID = 235230, UnitID = "target" }, -- Fel Wind
		{ AuraID = 241521, UnitID = "target" }, -- Painful Reshape
		{ AuraID = 234128, UnitID = "target" }, -- Force raid
		{ AuraID = 233429, UnitID = "target" }, -- Frigid Strike
		{ AuraID = 240315, UnitID = "target" }, -- Hardened Shell
		{ AuraID = 247781, UnitID = "target" }, -- enrage
		{ AuraID = 241590, UnitID = "target" }, -- lose your temper
		{ AuraID = 241594, UnitID = "target" }, -- anger
		{ AuraID = 233264, UnitID = "target", Value = true }, -- Embrace of the Eclipse
		{ AuraID = 236697, UnitID = "target" }, -- fatal scream
		{ AuraID = 236513, UnitID = "target" }, -- Bone Prison Armor
		{ AuraID = 236351, UnitID = "target" }, -- Binding Essence
		{ AuraID = 234891, UnitID = "target" }, -- Creator's Wrath
		{ AuraID = 235028, UnitID = "target", Value = true }, -- Titan's Wall
		{ AuraID = 241008, UnitID = "target", Value = true }, -- Purification Protocol
		{ AuraID = 233739, UnitID = "target" }, -- failure
		{ AuraID = 233961, UnitID = "target" }, -- matrix hardening
		{ AuraID = 236684, UnitID = "target" }, -- Fel Infusion
		{ AuraID = 244834, UnitID = "target" }, -- Void Wind
		{ AuraID = 235974, UnitID = "target" }, -- burst
		{ AuraID = 241564, UnitID = "target" }, -- Howl of Sorrow
		{ AuraID = 241606, UnitID = "target" }, -- waves
		-- Burning Throne
		{ AuraID = 244106, UnitID = "target" }, -- kill
		{ AuraID = 253306, UnitID = "target" }, -- psionic trauma
		{ AuraID = 255805, UnitID = "target" }, -- unstable portal
		{ AuraID = 244383, UnitID = "target" }, -- Shield of Flame
		{ AuraID = 248424, UnitID = "target" }, -- Aggregate Power
		{ AuraID = 246516, UnitID = "target" }, -- Apocalypse Protocol
		{ AuraID = 246504, UnitID = "target" }, -- program start
		{ AuraID = 253203, UnitID = "target" }, -- break the magic contract
		{ AuraID = 249863, UnitID = "target" }, -- the face of the titan
		{ AuraID = 244713, UnitID = "target" }, -- Burning Fury
		{ AuraID = 244894, UnitID = "target" }, -- Corrosive shield
		{ AuraID = 247091, UnitID = "target" }, -- catalysis
		{ AuraID = 253021, UnitID = "target" }, -- destiny
		{ AuraID = 255478, UnitID = "target" }, -- Eternal Blade
		{ AuraID = 255496, UnitID = "target" }, -- Sword of the Universe
		-- Protoss Vulnerable
		{ AuraID = 255418, UnitID = "target", Text = SPELL_SCHOOL0_NAME }, -- Physics
		{ AuraID = 255419, UnitID = "target", Text = SPELL_SCHOOL1_NAME }, -- holy
		{ AuraID = 255429, UnitID = "target", Text = SPELL_SCHOOL2_NAME }, -- fire
		{ AuraID = 255422, UnitID = "target", Text = SPELL_SCHOOL3_NAME }, -- natural
		{ AuraID = 255425, UnitID = "target", Text = SPELL_SCHOOL4_NAME }, -- Frost
		{ AuraID = 255430, UnitID = "target", Text = SPELL_SCHOOL5_NAME }, -- shadow
		{ AuraID = 255433, UnitID = "target", Text = SPELL_SCHOOL6_NAME }, -- Arcane
	},
}
