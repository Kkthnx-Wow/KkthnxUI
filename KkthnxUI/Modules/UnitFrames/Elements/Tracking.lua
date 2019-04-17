local K = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G
local string_lower = string.lower

local GetSpellInfo = _G.GetSpellInfo
local IsPlayerSpell = _G.IsPlayerSpell
local UnitClass = _G.UnitClass

Module.DebuffsTracking = {}

local function Defaults(priorityOverride)
	return {["enable"] = true, ["priority"] = priorityOverride or 0, ["stackThreshold"] = 0}
end

local function SpellName(id)
	local name = GetSpellInfo(id)
	if not name then
		print("|cff3c9bedKkthnxUI:|r SpellID is not valid: " .. id .. ". Please check for an updated version, if none exists report to KkthnxUI in Discord.")
		return "Impale"
	else
		return name
	end
end

Module.DebuffsTracking["RaidDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
		-- Mythic+ Dungeons
		[209858] = Defaults(), -- Necrotic
		[226512] = Defaults(), -- Sanguine
		[240559] = Defaults(), -- Grievous
		[240443] = Defaults(), -- Bursting
		[196376] = Defaults(), -- Grievous Tear
		[288388] = Defaults(), -- Reap Soul
		[288694] = Defaults(), -- Shadow Smash
		--BFA Dungeons
		--Freehold
		[258323] = Defaults(), -- Infected Wound
		[257775] = Defaults(), -- Plague Step
		[257908] = Defaults(), -- Oiled Blade
		[257436] = Defaults(), -- Poisoning Strike
		[274389] = Defaults(), -- Rat Traps
		[274555] = Defaults(), -- Scabrous Bites
		[258875] = Defaults(), -- Blackout Barrel
		[256363] = Defaults(), -- Ripper Punch
		--Shrine of the Storm
		[264560] = Defaults(), -- Choking Brine
		[268233] = Defaults(), -- Electrifying Shock
		[268322] = Defaults(), -- Touch of the Drowned
		[268896] = Defaults(), -- Mind Rend
		[268104] = Defaults(), -- Explosive Void
		[267034] = Defaults(), -- Whispers of Power
		[276268] = Defaults(), -- Heaving Blow
		[264166] = Defaults(), -- Undertow
		[264526] = Defaults(), -- Grasp of the Depths
		[274633] = Defaults(), -- Sundering Blow
		[268214] = Defaults(), -- Carving Flesh
		[267818] = Defaults(), -- Slicing Blast
		[268309] = Defaults(), -- Unending Darkness
		[268317] = Defaults(), -- Rip Mind
		[268391] = Defaults(), -- Mental Assault
		[274720] = Defaults(), -- Abyssal Strike
		--Siege of Boralus
		[257168] = Defaults(), -- Cursed Slash
		[272588] = Defaults(), -- Rotting Wounds
		[272571] = Defaults(), -- Choking Waters
		[274991] = Defaults(), -- Putrid Waters
		[275835] = Defaults(), -- Stinging Venom Coating
		[273930] = Defaults(), -- Hindering Cut
		[257292] = Defaults(), -- Heavy Slash
		[261428] = Defaults(), -- Hangman's Noose
		[256897] = Defaults(), -- Clamping Jaws
		[272874] = Defaults(), -- Trample
		[273470] = Defaults(), -- Gut Shot
		[272834] = Defaults(), -- Viscous Slobber
		[257169] = Defaults(), -- Terrifying Roar
		[272713] = Defaults(), -- Crushing Slam
		-- Tol Dagor
		[258128] = Defaults(), -- Debilitating Shout
		[265889] = Defaults(), -- Torch Strike
		[257791] = Defaults(), -- Howling Fear
		[258864] = Defaults(), -- Suppression Fire
		[257028] = Defaults(), -- Fuselighter
		[258917] = Defaults(), -- Righteous Flames
		[257777] = Defaults(), -- Crippling Shiv
		[258079] = Defaults(), -- Massive Chomp
		[258058] = Defaults(), -- Squeeze
		[260016] = Defaults(), -- Itchy Bite
		[257119] = Defaults(), -- Sand Trap
		[260067] = Defaults(), -- Vicious Mauling
		[258313] = Defaults(), -- Handcuff
		[259711] = Defaults(), -- Lockdown
		[256198] = Defaults(), -- Azerite Rounds: Incendiary
		[256101] = Defaults(), -- Explosive Burst (mythic)
		[256105] = Defaults(), -- Explosive Burst (mythic+)
		[256044] = Defaults(), -- Deadeye
		[256474] = Defaults(), -- Heartstopper Venom
		--Waycrest Manor
		[260703] = Defaults(), -- Unstable Runic Mark
		[263905] = Defaults(), -- Marking Cleave
		[265880] = Defaults(), -- Dread Mark
		[265882] = Defaults(), -- Lingering Dread
		[264105] = Defaults(), -- Runic Mark
		[264050] = Defaults(), -- Infected Thorn
		[261440] = Defaults(), -- Virulent Pathogen
		[263891] = Defaults(), -- Grasping Thorns
		[264378] = Defaults(), -- Fragment Soul
		[266035] = Defaults(), -- Bone Splinter
		[266036] = Defaults(), -- Drain Essence
		[260907] = Defaults(), -- Soul Manipulation
		[260741] = Defaults(), -- Jagged Nettles
		[264556] = Defaults(), -- Tearing Strike
		[265760] = Defaults(), -- Thorned Barrage
		[260551] = Defaults(), -- Soul Thorns
		[263943] = Defaults(), -- Etch
		[265881] = Defaults(), -- Decaying Touch
		[261438] = Defaults(), -- Wasting Strike
		[268202] = Defaults(), -- Death Lens
		[278456] = Defaults(), -- Infest
		-- Atal'Dazar
		[252781] = Defaults(), -- Unstable Hex
		[250096] = Defaults(), -- Wracking Pain
		[250371] = Defaults(), -- Lingering Nausea
		[253562] = Defaults(), -- Wildfire
		[255582] = Defaults(), -- Molten Gold
		[255041] = Defaults(), -- Terrifying Screech
		[255371] = Defaults(), -- Terrifying Visage
		[252687] = Defaults(), -- Venomfang Strike
		[254959] = Defaults(), -- Soulburn
		[255814] = Defaults(), -- Rending Maul
		[255421] = Defaults(), -- Devour
		[255434] = Defaults(), -- Serrated Teeth
		[256577] = Defaults(), -- Soulfeast
		--King's Rest
		[270492] = Defaults(), -- Hex
		[267763] = Defaults(), -- Wretched Discharge
		[276031] = Defaults(), -- Pit of Despair
		[265773] = Defaults(), -- Spit Gold
		[270920] = Defaults(), -- Seduction
		[270865] = Defaults(), -- Hidden Blade
		[271564] = Defaults(), -- Embalming Fluid
		[270507] = Defaults(), -- Poison Barrage
		[267273] = Defaults(), -- Poison Nova
		[270003] = Defaults(), -- Suppression Slam
		[270084] = Defaults(), -- Axe Barrage
		[267618] = Defaults(), -- Drain Fluids
		[267626] = Defaults(), -- Dessication
		[270487] = Defaults(), -- Severing Blade
		[266238] = Defaults(), -- Shattered Defenses
		[266231] = Defaults(), -- Severing Axe
		[266191] = Defaults(), -- Whirling Axes
		[272388] = Defaults(), -- Shadow Barrage
		[271640] = Defaults(), -- Dark Revelation
		[268796] = Defaults(), -- Impaling Spear
		--Motherlode
		[263074] = Defaults(), -- Festering Bite
		[280605] = Defaults(), -- Brain Freeze
		[257337] = Defaults(), -- Shocking Claw
		[270882] = Defaults(), -- Blazing Azerite
		[268797] = Defaults(), -- Transmute: Enemy to Goo
		[259856] = Defaults(), -- Chemical Burn
		[269302] = Defaults(), -- Toxic Blades
		[280604] = Defaults(), -- Iced Spritzer
		[257371] = Defaults(), -- Tear Gas
		[257544] = Defaults(), -- Jagged Cut
		[268846] = Defaults(), -- Echo Blade
		[262794] = Defaults(), -- Energy Lash
		[262513] = Defaults(), -- Azerite Heartseeker
		[260829] = Defaults(), -- Homing Missle (travelling)
		[260838] = Defaults(), -- Homing Missle (exploded)
		[263637] = Defaults(), -- Clothesline
		--Temple of Sethraliss
		[269686] = Defaults(), -- Plague
		[268013] = Defaults(), -- Flame Shock
		[268008] = Defaults(), -- Snake Charm
		[273563] = Defaults(), -- Neurotoxin
		[272657] = Defaults(), -- Noxious Breath
		[267027] = Defaults(), -- Cytotoxin
		[272699] = Defaults(), -- Venomous Spit
		[263371] = Defaults(), -- Conduction
		[272655] = Defaults(), -- Scouring Sand
		[263914] = Defaults(), -- Blinding Sand
		[263958] = Defaults(), -- A Knot of Snakes
		[266923] = Defaults(), -- Galvanize
		[268007] = Defaults(), -- Heart Attack
		--Underrot
		[265468] = Defaults(), -- Withering Curse
		[278961] = Defaults(), -- Decaying Mind
		[259714] = Defaults(), -- Decaying Spores
		[272180] = Defaults(), -- Death Bolt
		[272609] = Defaults(), -- Maddening Gaze
		[269301] = Defaults(), -- Putrid Blood
		[265533] = Defaults(), -- Blood Maw
		[265019] = Defaults(), -- Savage Cleave
		[265377] = Defaults(), -- Hooked Snare
		[265625] = Defaults(), -- Dark Omen
		[260685] = Defaults(), -- Taint of G'huun
		[266107] = Defaults(), -- Thirst for Blood
		[260455] = Defaults(), -- Serrated Fangs
		-- Uldir
		-- MOTHER
		[268277] = Defaults(), -- Purifying Flame
		[268253] = Defaults(), -- Surgical Beam
		[268095] = Defaults(), -- Cleansing Purge
		[267787] = Defaults(), -- Sundering Scalpel
		[268198] = Defaults(), -- Clinging Corruption
		[267821] = Defaults(), -- Defense Grid
		-- Vectis
		[265127] = Defaults(), -- Lingering Infection
		[265178] = Defaults(), -- Mutagenic Pathogen
		[265206] = Defaults(), -- Immunosuppression
		[265212] = Defaults(), -- Gestate
		[265129] = Defaults(), -- Omega Vector
		[267160] = Defaults(), -- Omega Vector
		[267161] = Defaults(), -- Omega Vector
		[267162] = Defaults(), -- Omega Vector
		[267163] = Defaults(), -- Omega Vector
		[267164] = Defaults(), -- Omega Vector
		-- Mythrax
		--[272146] = Defaults(), -- Annihilation
		[272536] = Defaults(), -- Imminent Ruin
		[274693] = Defaults(), -- Essence Shear
		[272407] = Defaults(), -- Oblivion Sphere
		-- Fetid Devourer
		[262313] = Defaults(), -- Malodorous Miasma
		[262292] = Defaults(), -- Rotting Regurgitation
		[262314] = Defaults(), -- Deadly Disease
		-- Taloc
		[270290] = Defaults(), -- Blood Storm
		[275270] = Defaults(), -- Fixate
		[271224] = Defaults(), -- Plasma Discharge
		[271225] = Defaults(), -- Plasma Discharge
		-- Zul
		[273365] = Defaults(), -- Dark Revelation
		[273434] = Defaults(), -- Pit of Despair
		--[274195] = Defaults(), -- Corrupted Blood
		[272018] = Defaults(), -- Absorbed in Darkness
		[274358] = Defaults(), -- Rupturing Blood
		-- Zek'voz, Herald of N'zoth
		[265237] = Defaults(), -- Shatter
		[265264] = Defaults(), -- Void Lash
		[265360] = Defaults(), -- Roiling Deceit
		[265662] = Defaults(), -- Corruptor's Pact
		[265646] = Defaults(), -- Will of the Corruptor
		-- G'huun
		[263436] = Defaults(), -- Imperfect Physiology
		[263227] = Defaults(), -- Putrid Blood
		[263372] = Defaults(), -- Power Matrix
		[272506] = Defaults(), -- Explosive Corruption
		[267409] = Defaults(), -- Dark Bargain
		[267430] = Defaults(), -- Torment
		[263235] = Defaults(), -- Blood Feast
		[270287] = Defaults(), -- Blighted Ground
		-- Siege of Zuldazar
		-- Ra'wani Kanae/Frida Ironbellows
		[283573] = Defaults(), -- Sacred Blade
		[283617] = Defaults(), -- Wave of Light
		[283651] = Defaults(), -- Blinding Faith
		[284595] = Defaults(), -- Penance
		[283582] = Defaults(), -- Consecration
		-- Grong
		[285998] = Defaults(), -- Ferocious Roar
		[283069] = Defaults(), -- Megatomic Fire
		[285671] = Defaults(), -- Crushed
		[285875] = Defaults(), -- Rending Bite
		--[282010] = Defaults(), -- Shaken

		-- Jaina
		[285253] = Defaults(), -- Ice Shard
		[287993] = Defaults(), -- Chilling Touch
		[287365] = Defaults(), -- Searing Pitch
		[288038] = Defaults(), -- Marked Target
		[285254] = Defaults(), -- Avalanche
		[287626] = Defaults(), -- Grasp of Frost
		[287490] = Defaults(), -- Frozen Solid
		[287199] = Defaults(), -- Ring of Ice
		[288392] = Defaults(), -- Vengeful Seas
		-- Stormwall Blockade
		[284369] = Defaults(), -- Sea Storm
		[284410] = Defaults(), -- Tempting Song
		[284405] = Defaults(), -- Tempting Song
		[284121] = Defaults(), -- Thunderous Boom
		[286680] = Defaults(), -- Roiling Tides
		-- Opulence
		[286501] = Defaults(), -- Creeping Blaze
		[283610] = Defaults(), -- Crush
		[289383] = Defaults(), -- Chaotic Displacement
		[285479] = Defaults(), -- Flame Jet
		[283063] = Defaults(), -- Flames of Punishment
		[283507] = Defaults(), -- Volatile Charge
		-- King Rastakhan
		[284995] = Defaults(), -- Zombie Dust
		[285349] = Defaults(), -- Plague of Fire
		[285044] = Defaults(), -- Toad Toxin
		[284831] = Defaults(), -- Scorching Detonation
		[289858] = Defaults(), -- Crushed
		[284662] = Defaults(), -- Seal of Purification
		[284676] = Defaults(), -- Seal of Purification
		[285178] = Defaults(), -- Serpent's Breath
		[285010] = Defaults(), -- Poison Toad Slime
		-- Jadefire Masters
		[282037] = Defaults(), -- Rising Flames
		[284374] = Defaults(), -- Magma Trap
		[285632] = Defaults(), -- Stalking
		[288151] = Defaults(), -- Tested
		[284089] = Defaults(), -- Successful Defense
		[286988] = Defaults(), -- Searing Embers
		-- Mekkatorque
		[288806] = Defaults(), -- Gigavolt Blast
		[289023] = Defaults(), -- Enormous
		[286646] = Defaults(), -- Gigavolt Charge
		[288939] = Defaults(), -- Gigavolt Radiation
		[284168] = Defaults(), -- Shrunk
		[286516] = Defaults(), -- Anti-Tampering Shock
		[286480] = Defaults(), -- Anti-Tampering Shock
		[284214] = Defaults(), -- Trample
		-- Conclave of the Chosen
		[284663] = Defaults(), -- Bwonsamdi's Wrath
		[282444] = Defaults(), -- Lacerating Claws
		[282592] = Defaults(), -- Bleeding Wounds
		[282209] = Defaults(), -- Mark of Prey
		[285879] = Defaults(), -- Mind Wipe
		[282135] = Defaults(), -- Crawling Hex
		[286060] = Defaults(), -- Cry of the Fallen
		[282447] = Defaults(), -- Kimbul's Wrath
		[282834] = Defaults(), -- Kimbul's Wrath
		[286811] = Defaults(), -- Akunda's Wrath
		[286838] = Defaults(), -- Static Orb
		-- Crucible of Storms
		-- The Restless Cabal
		[282386] = Defaults(), -- Aphotic Blast
		[282384] = Defaults(), -- Shear Mind
		[282566] = Defaults(), -- Promises of Power
		[282561] = Defaults(), -- Dark Herald
		[282432] = Defaults(), -- Crushing Doubt
		[282589] = Defaults(), -- Mind Scramble
		[292826] = Defaults(), -- Mind Scramble
		-- Fa'thuul the Feared
		[284851] = Defaults(), -- Touch of the End
		[286459] = Defaults(), -- Feedback: Void
		[286457] = Defaults(), -- Feedback: Ocean
		[286458] = Defaults(), -- Feedback: Storm
		[285367] = Defaults(), -- Piercing Gaze of N'Zoth
		[284733] = Defaults(), -- Embrace of the Void
		[284722] = Defaults(), -- Umbral Shell
		[285345] = Defaults(), -- Maddening Eyes of N'Zoth
		[285477] = Defaults()  -- Obscurity
	}
}

-- CC DEBUFFS (TRACKING LIST)
Module.DebuffsTracking["CCDebuffs"] = {
	["type"] = "Whitelist",
	["spells"] = {
		--Death Knight
		[47476] = Defaults(2), -- Strangulate
		[108194] = Defaults(4), -- Asphyxiate UH
		[221562] = Defaults(4), -- Asphyxiate Blood
		[207171] = Defaults(4), -- Winter is Coming
		[206961] = Defaults(3), -- Tremble Before Me
		[207167] = Defaults(4), -- Blinding Sleet
		[212540] = Defaults(1), -- Flesh Hook (Pet)
		[91807] = Defaults(1), -- Shambling Rush (Pet)
		[204085] = Defaults(1), -- Deathchill
		[233395] = Defaults(1), -- Frozen Center
		[212332] = Defaults(4), -- Smash (Pet)
		[212337] = Defaults(4), -- Powerful Smash (Pet)
		[91800] = Defaults(4), -- Gnaw (Pet)
		[91797] = Defaults(4), -- Monstrous Blow (Pet)
		--	[?????] = Defaults(), -- Reanimation (missing data)
		[210141] = Defaults(3), -- Zombie Explosion
		--Demon Hunter
		[207685] = Defaults(4), -- Sigil of Misery
		[217832] = Defaults(3), -- Imprison
		[221527] = Defaults(5), -- Imprison (Banished version)
		[204490] = Defaults(2), -- Sigil of Silence
		[179057] = Defaults(3), -- Chaos Nova
		[211881] = Defaults(4), -- Fel Eruption
		[205630] = Defaults(3), -- Illidan's Grasp
		[208618] = Defaults(3), -- Illidan's Grasp (Afterward)
		[213491] = Defaults(4), -- Demonic Trample (it's this one or the other)
		[208645] = Defaults(4), -- Demonic Trample
		--Druid
		[81261] = Defaults(2), -- Solar Beam
		[5211] = Defaults(4), -- Mighty Bash
		[163505] = Defaults(4), -- Rake
		[203123] = Defaults(4), -- Maim
		[202244] = Defaults(4), -- Overrun
		[99] = Defaults(4), -- Incapacitating Roar
		[33786] = Defaults(5), -- Cyclone
		[209753] = Defaults(5), -- Cyclone Balance
		[45334] = Defaults(1), -- Immobilized
		[102359] = Defaults(1), -- Mass Entanglement
		[339] = Defaults(1), -- Entangling Roots
		[2637] = Defaults(1), -- Hibernate
		--Hunter
		[202933] = Defaults(2), -- Spider Sting (it's this one or the other)
		[233022] = Defaults(2), -- Spider Sting
		[213691] = Defaults(4), -- Scatter Shot
		[19386] = Defaults(3), -- Wyvern Sting
		[3355] = Defaults(3), -- Freezing Trap
		[203337] = Defaults(5), -- Freezing Trap (Survival PvPT)
		[209790] = Defaults(3), -- Freezing Arrow
		[24394] = Defaults(4), -- Intimidation
		[117526] = Defaults(4), -- Binding Shot
		[190927] = Defaults(1), -- Harpoon
		[201158] = Defaults(1), -- Super Sticky Tar
		[162480] = Defaults(1), -- Steel Trap
		[212638] = Defaults(1), -- Tracker's Net
		[200108] = Defaults(1), -- Ranger's Net
		--Mage
		[61721] = Defaults(3), -- Rabbit (Poly)
		[61305] = Defaults(3), -- Black Cat (Poly)
		[28272] = Defaults(3), -- Pig (Poly)
		[28271] = Defaults(3), -- Turtle (Poly)
		[126819] = Defaults(3), -- Porcupine (Poly)
		[161354] = Defaults(3), -- Monkey (Poly)
		[161353] = Defaults(3), -- Polar bear (Poly)
		[61780] = Defaults(3), -- Turkey (Poly)
		[161355] = Defaults(3), -- Penguin (Poly)
		[161372] = Defaults(3), -- Peacock (Poly)
		[277787] = Defaults(3), -- Direhorn (Poly)
		[277792] = Defaults(3), -- Bumblebee (Poly)
		[118] = Defaults(3), -- Polymorph
		[82691] = Defaults(3), -- Ring of Frost
		[31661] = Defaults(3), -- Dragon's Breath
		[122] = Defaults(1), -- Frost Nova
		[33395] = Defaults(1), -- Freeze
		[157997] = Defaults(1), -- Ice Nova
		[228600] = Defaults(1), -- Glacial Spike
		[198121] = Defaults(1), -- Forstbite
		--Monk
		[119381] = Defaults(4), -- Leg Sweep
		[202346] = Defaults(4), -- Double Barrel
		[115078] = Defaults(4), -- Paralysis
		[198909] = Defaults(3), -- Song of Chi-Ji
		[202274] = Defaults(3), -- Incendiary Brew
		[233759] = Defaults(2), -- Grapple Weapon
		[123407] = Defaults(1), -- Spinning Fire Blossom
		[116706] = Defaults(1), -- Disable
		[232055] = Defaults(4), -- Fists of Fury (it's this one or the other)
		--Paladin
		[853] = Defaults(3), -- Hammer of Justice
		[20066] = Defaults(3), -- Repentance
		[105421] = Defaults(3), -- Blinding Light
		[31935] = Defaults(2), -- Avenger's Shield
		[217824] = Defaults(2), -- Shield of Virtue
		[205290] = Defaults(3), -- Wake of Ashes
		--Priest
		[9484] = Defaults(3), -- Shackle Undead
		[200196] = Defaults(4), -- Holy Word: Chastise
		[200200] = Defaults(4), -- Holy Word: Chastise
		[226943] = Defaults(3), -- Mind Bomb
		[605] = Defaults(5), -- Mind Control
		[8122] = Defaults(3), -- Psychic Scream
		[15487] = Defaults(2), -- Silence
		[64044] = Defaults(1), -- Psychic Horror
		--Rogue
		[2094] = Defaults(4), -- Blind
		[6770] = Defaults(4), -- Sap
		[1776] = Defaults(4), -- Gouge
		[1330] = Defaults(2), -- Garrote - Silence
		[207777] = Defaults(2), -- Dismantle
		[199804] = Defaults(4), -- Between the Eyes
		[408] = Defaults(4), -- Kidney Shot
		[1833] = Defaults(4), -- Cheap Shot
		[207736] = Defaults(5), -- Shadowy Duel (Smoke effect)
		[212182] = Defaults(5), -- Smoke Bomb
		--Shaman
		[51514] = Defaults(3), -- Hex
		[211015] = Defaults(3), -- Hex (Cockroach)
		[211010] = Defaults(3), -- Hex (Snake)
		[211004] = Defaults(3), -- Hex (Spider)
		[210873] = Defaults(3), -- Hex (Compy)
		[196942] = Defaults(3), -- Hex (Voodoo Totem)
		[269352] = Defaults(3), -- Hex (Skeletal Hatchling)
		[277778] = Defaults(3), -- Hex (Zandalari Tendonripper)
		[277784] = Defaults(3), -- Hex (Wicker Mongrel)
		[118905] = Defaults(3), -- Static Charge
		[77505] = Defaults(4), -- Earthquake (Knocking down)
		[118345] = Defaults(4), -- Pulverize (Pet)
		[204399] = Defaults(3), -- Earthfury
		[204437] = Defaults(3), -- Lightning Lasso
		[157375] = Defaults(4), -- Gale Force
		[64695] = Defaults(1), -- Earthgrab
		--Warlock
		[710] = Defaults(5), -- Banish
		[6789] = Defaults(3), -- Mortal Coil
		[118699] = Defaults(3), -- Fear
		[6358] = Defaults(3), -- Seduction (Succub)
		[171017] = Defaults(4), -- Meteor Strike (Infernal)
		[22703] = Defaults(4), -- Infernal Awakening (Infernal CD)
		[30283] = Defaults(3), -- Shadowfury
		[89766] = Defaults(4), -- Axe Toss
		[233582] = Defaults(1), -- Entrenched in Flame
		--Warrior
		[5246] = Defaults(4), -- Intimidating Shout
		[7922] = Defaults(4), -- Warbringer
		[132169] = Defaults(4), -- Storm Bolt
		[132168] = Defaults(4), -- Shockwave
		[199085] = Defaults(4), -- Warpath
		[105771] = Defaults(1), -- Charge
		[199042] = Defaults(1), -- Thunderstruck
		[236077] = Defaults(2), -- Disarm
		--Racial
		[20549] = Defaults(4), -- War Stomp
		[107079] = Defaults(4) -- Quaking Palm
	}
}

-- RAID BUFFS (SQUARED AURA TRACKING LIST)
Module.RaidBuffsTracking = {
	PRIEST = {
		{194384, "TOPRIGHT", {1, 0, 0.75}}, -- Atonement
		{214206, "TOPRIGHT", {1, 0, 0.75}}, -- Atonement PvP
		{41635, "BOTTOMRIGHT", {0.2, 0.7, 0.2}}, -- Prayer of Mending
		{193065, "BOTTOMRIGHT", {0.54, 0.21, 0.78}}, -- Masochism
		{139, "BOTTOMLEFT", {0.4, 0.7, 0.2}}, -- Renew
		{6788, "BOTTOMLEFT", {0.89, 0.1, 0.1}}, -- Weakened Soul
		{17, "TOPLEFT", {0.81, 0.85, 0.1}, true}, -- Power Word: Shield
		{47788, "LEFT", {221 / 255, 117 / 255, 0}, true}, -- Guardian Spirit
		{33206, "LEFT", {227 / 255, 23 / 255, 13 / 255}, true} -- Pain Suppression
	},

	DRUID = {
		{774, "TOPRIGHT", {0.8, 0.4, 0.8}}, -- Rejuvenation
		{155777, "RIGHT", {0.8, 0.4, 0.8}}, -- Germination
		{8936, "BOTTOMLEFT", {0.2, 0.8, 0.2}}, -- Regrowth
		{33763, "TOPLEFT", {0.4, 0.8, 0.2}}, -- Lifebloom
		{48438, "BOTTOMRIGHT", {0.8, 0.4, 0}}, -- Wild Growth
		{207386, "TOP", {0.4, 0.2, 0.8}}, -- Spring Blossoms
		{102351, "LEFT", {0.2, 0.8, 0.8}}, -- Cenarion Ward (Initial Buff)
		{102352, "LEFT", {0.2, 0.8, 0.8}}, -- Cenarion Ward (HoT)
		{200389, "BOTTOM", {1, 1, 0.4}} -- Cultivation
	},

	PALADIN = {
		{53563, "TOPRIGHT", {0.7, 0.3, 0.7}}, -- Beacon of Light
		{156910, "TOPRIGHT", {0.7, 0.3, 0.7}}, -- Beacon of Faith
		{200025, "TOPRIGHT", {0.7, 0.3, 0.7}}, -- Beacon of Virtue
		{1022, "BOTTOMRIGHT", {0.2, 0.2, 1}, true}, -- Hand of Protection
		{1044, "BOTTOMRIGHT", {0.89, 0.45, 0}, true}, -- Hand of Freedom
		{6940, "BOTTOMRIGHT", {0.89, 0.1, 0.1}, true}, -- Hand of Sacrifice
		{223306, "BOTTOMLEFT", {0.7, 0.7, 0.3}, true} -- Bestow Faith
	},

	SHAMAN = {
		{61295, "TOPRIGHT", {0.7, 0.3, 0.7}}, -- Riptide
		{974, "BOTTOMRIGHT", {0.2, 0.2, 1}} -- Earth Shield
	},

	MONK = {
		{119611, "TOPLEFT", {0.8, 0.4, 0.8}}, --Renewing Mist
		{116849, "TOPRIGHT", {0.2, 0.8, 0.2}}, -- Life Cocoon
		{124682, "BOTTOMLEFT", {0.4, 0.8, 0.2}}, -- Enveloping Mist
		{124081, "BOTTOMRIGHT", {0.7, 0.4, 0}} -- Zen Sphere
	},

	ROGUE = {
		{57934, "TOPRIGHT", {227 / 255, 23 / 255, 13 / 255}} -- Tricks of the Trade
	},

	WARRIOR = {
		{114030, "TOPLEFT", {0.2, 0.2, 1}}, -- Vigilance
		{147833, "TOPRIGHT", {227 / 255, 23 / 255, 13 / 255}} -- Intervene
	},

	PET = {
		-- Warlock Pets
		{193396, "TOPRIGHT", {0.6, 0.2, 0.8}, true}, -- Demonic Empowerment
		-- Hunter Pets
		{19615, "TOPLEFT", {227 / 255, 23 / 255, 13 / 255}, true}, -- Frenzy
		{136, "TOPRIGHT", {0.2, 0.8, 0.2}, true} -- Mend Pet
	},

	HUNTER = {}, -- Keep even if it's an empty table, so a reference to G.unitframe.buffwatch[E.myclass][SomeValue] doesn't trigger error
	DEMONHUNTER = {},
	WARLOCK = {},
	MAGE = {},
	DEATHKNIGHT = {}
}

-- Stuff we need to see.
Module.ImportantDebuffs = {
	[SpellName(212570)] = true, -- Surrendered Soul
	[SpellName(25771)] = K.Class == "PALADIN", -- Forbearance
	[SpellName(6788)] = K.Class == "PRIEST" -- Weakened Soul
}

-- Filter this. Pointless to see.
Module.UnImportantBuffs = {
	[SpellName(113942)] = true, -- Demonic: Gateway
	[SpellName(117870)] = true, -- Touch of The Titans
	[SpellName(123981)] = true, -- Perdition
	[SpellName(124273)] = true, -- Stagger
	[SpellName(124274)] = true, -- Stagger
	[SpellName(124275)] = true, -- Stagger
	[SpellName(126434)] = true, -- Tushui Champion
	[SpellName(126436)] = true, -- Huojin Champion
	[SpellName(131493)] = true, -- B.F.F. Friends forever!
	[SpellName(143625)] = true, -- Brawling Champion
	[SpellName(15007)] = true, -- Ress Sickness
	[SpellName(170616)] = true, -- Pet Deserter
	[SpellName(182957)] = true, -- Treasures of Stormheim
	[SpellName(182958)] = true, -- Treasures of Azsuna
	[SpellName(185719)] = true, -- Treasures of Val"sharah
	[SpellName(186401)] = true, -- Sign of the Skirmisher
	[SpellName(186403)] = true, -- Sign of Battle
	[SpellName(186404)] = true, -- Sign of the Emissary
	[SpellName(186406)] = true, -- Sign of the Critter
	[SpellName(188741)] = true, -- Treasures of Highmountain
	[SpellName(199416)] = true, -- Treasures of Suramar
	[SpellName(225787)] = true, -- Sign of the Warrior
	[SpellName(225788)] = true, -- Sign of the Emissary
	[SpellName(227723)] = true, -- Mana Divining Stone
	[SpellName(231115)] = true, -- Treasures of Broken Shore
	[SpellName(233641)] = true, -- Legionfall Commander
	[SpellName(23445)] = true, -- Evil Twin
	[SpellName(237137)] = true, -- Knowledgeable
	[SpellName(237139)] = true, -- Power Overwhelming
	[SpellName(239645)] = true, -- Fel Treasures
	[SpellName(239647)] = true, -- Epic Hunter
	[SpellName(239648)] = true, -- Forces of the Order
	[SpellName(239966)] = true, -- War Effort
	[SpellName(239967)] = true, -- Seal Your Fate
	[SpellName(239968)] = true, -- Fate Smiles Upon You
	[SpellName(239969)] = true, -- Netherstorm
	[SpellName(240979)] = true, -- Reputable
	[SpellName(240980)] = true, -- Light As a Feather
	[SpellName(240985)] = true, -- Reinforced Reins
	[SpellName(240986)] = true, -- Worthy Champions
	[SpellName(240987)] = true, -- Well Prepared
	[SpellName(240989)] = true, -- Heavily Augmented
	[SpellName(24755)] = true, -- Tricked or Treated
	[SpellName(25163)] = true, -- Oozeling"s Disgusting Aura
	[SpellName(26013)] = true, -- Deserter
	[SpellName(36032)] = true, -- Arcane Charge
	[SpellName(36893)] = true, -- Transporter Malfunction
	[SpellName(36900)] = true, -- Soul Split: Evil!
	[SpellName(36901)] = true, -- Soul Split: Good
	[SpellName(39953)] = true, -- A"dal"s Song of Battle
	[SpellName(41425)] = true, -- Hypothermia
	[SpellName(44212)] = true, -- Jack-o"-Lanterned!
	[SpellName(55711)] = true, -- Weakened Heart
	[SpellName(57723)] = true, -- Exhaustion (heroism debuff)
	[SpellName(57724)] = true, -- Sated (lust debuff)
	[SpellName(57819)] = true, -- Argent Champion
	[SpellName(57820)] = true, -- Ebon Champion
	[SpellName(57821)] = true, -- Champion of the Kirin Tor
	[SpellName(58539)] = true, -- Watcher"s Corpse
	[SpellName(71041)] = true, -- Dungeon Deserter
	[SpellName(72968)] = true, -- Precious"s Ribbon
	[SpellName(80354)] = true, -- Temporal Displacement (timewarp debuff)
	[SpellName(8326)] = true, -- Ghost
	[SpellName(85612)] = true, -- Fiona"s Lucky Charm
	[SpellName(85613)] = true, -- Gidwin"s Weapon Oil
	[SpellName(85614)] = true, -- Tarenar"s Talisman
	[SpellName(85615)] = true, -- Pamela"s Doll
	[SpellName(85616)] = true, -- Vex"tul"s Armbands
	[SpellName(85617)] = true, -- Argus" Journal
	[SpellName(85618)] = true, -- Rimblat"s Stone
	[SpellName(85619)] = true, -- Beezil"s Cog
	[SpellName(8733)] = true, -- Blessing of Blackfathom
	[SpellName(89140)] = true, -- Demonic Rebirth: Cooldown
	[SpellName(93337)] = true, -- Champion of Ramkahen
	[SpellName(93339)] = true, -- Champion of the Earthen Ring
	[SpellName(93341)] = true, -- Champion of the Guardians of Hyjal
	[SpellName(93347)] = true, -- Champion of Therazane
	[SpellName(93368)] = true, -- Champion of the Wildhammer Clan
	[SpellName(93795)] = true, -- Stormwind Champion
	[SpellName(93805)] = true, -- Ironforge Champion
	[SpellName(93806)] = true, -- Darnassus Champion
	[SpellName(93811)] = true, -- Exodar Champion
	[SpellName(93816)] = true, -- Gilneas Champion
	[SpellName(93821)] = true, -- Gnomeregan Champion
	[SpellName(93825)] = true, -- Orgrimmar Champion
	[SpellName(93827)] = true, -- Darkspear Champion
	[SpellName(93828)] = true, -- Silvermoon Champion
	[SpellName(93830)] = true, -- Bilgewater Champion
	[SpellName(94158)] = true, -- Champion of the Dragonmaw Clan
	[SpellName(94462)] = true, -- Undercity Champion
	[SpellName(94463)] = true, -- Thunder Bluff Champion
	[SpellName(95809)] = true, -- Insanity debuff (hunter pet heroism: ancient hysteria)
	[SpellName(97340)] = true, -- Guild Champion
	[SpellName(97341)] = true, -- Guild Champion
	[SpellName(97821)] = true -- Void-Touched
}

-- List of spells to display ticks
Module.ChannelTicks = {
	-- Warlock
	[198590] = 6, -- Drain Soul
	[755] = 6, -- Health Funnel
	-- Priest
	[64843] = 4, -- Divine Hymn
	[15407] = 4, -- Mind Flay
	[48045] = 5, -- Mind Flay
	-- Mage
	[5143] = 5, -- Arcane Missiles
	[12051] = 3, -- Evocation
	[205021] = 10, -- Ray of Frost
	--Druid
	[740] = 4 -- Tranquility
}

local CastTickCheck = _G.CreateFrame("Frame")
CastTickCheck:RegisterEvent("PLAYER_ENTERING_WORLD")
CastTickCheck:RegisterEvent("PLAYER_TALENT_UPDATE")
CastTickCheck:SetScript("OnEvent", function()
	local class = select(2, UnitClass("player"))
	if string_lower(class) ~= "priest" then
		return
	end

	local penanceTicks = IsPlayerSpell(193134) and 4 or 3
	Module.ChannelTicks[47540] = penanceTicks -- Penance
end)

Module.ChannelTicksSize = {
	-- Warlock
	[198590] = 1 -- Drain Soul
}

-- Spells Effected By Haste
Module.HastedChannelTicks = {
	[205021] = true -- Ray of Frost
}