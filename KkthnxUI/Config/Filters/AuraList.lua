local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

local AuraList = {}

AuraList.Immunity = {
	1022,	-- Hand of Protection
	104773, -- Unending Resolve
	18499, -- Berserker Rage
	19263 ,	-- Deterrence
	196555, -- Netherwalk (Talent)
	204018, -- Blessing of Spellwarding (Talented verion of Blessing of Protection)
	33786, -- Cyclone (PvP Talent)
	45438, -- Ice Block
	46924, -- Bladestorm
	47585,	-- Dispersion (Priest)
	51690,	-- Killing Spree
	642,	-- Divine Shield (Paladin)
}

AuraList.CCImmunity = {
	1044, -- Hand of Freedom
	114028,	-- Mass Spell Reflection
	115018,	-- Desecrated Ground
	23920,	-- Spell Reflection (warrior)
	31224, -- Cloak of Shadows
	31821,	-- Aura Mastery
	49039,	-- Lichborne
	51271, -- Pillar of Frost
	53271, -- Masters Call
	8178,	-- Grounding Totem Effect (Grounding Totem)
}

AuraList.Defensive = {
	115176,	-- Zen Meditation
	115203,	-- Fortifying Brew
	115610,	-- Temporal Shield
	116888,	-- Shroud of Purgatory
	122278,	-- Dampen Harm
	122470,	-- Touch of Karma
	122783,	-- Diffuse Magic
	186265, -- Aspect of the Turtle
	192081, -- IronFur
	192083, -- Mark of Ursol
	-- 195181, -- Bone Shield
	198589, -- Blur
	203720, -- Demon Spikes
	212800, -- blur
	218256, -- Empower Wards
	22812, -- Barkskin
	33206, -- Pain Suppression
	45182,	-- Cheating Death
	47585, -- Dispersion
	47788,	-- Guardian Spirit
	48707, -- Anti-Magic Shell
	48792, -- Icebound Fortitude
	498, -- Divine Protection
	5277, -- Evasion
	61336, -- Survival Instincts
	6940,	-- Hand of Sacrifice
	74001,	-- Combat Readiness
	871, -- Shield Wall
}

AuraList.Offensive = {
	102342,	-- Ironbark
	102543,	-- Incarnation: King of the Jungle
	102560,	-- Incarnation: Chosen of Elune
	12472,	-- Icy Veins
	162264, -- Metamorphosis
	1719,	-- Recklessness
	185313,	-- Shadow Dance
	211048, -- Chaos Blades
	31884, -- Avenging Wrath
}

AuraList.Helpful = {
	106898,	-- Stampeding Roar
	108212,	-- Burst of Speed
	108843, -- Blazing Speed
	112833,	-- Spectral Guise
	116841,	-- Tigers Lust
	118922,	-- Posthaste
	1850, -- Dash
	188501, -- Speci
	23920, -- Spell Reflection (warrior)
	2983, -- Sprint
	3411,	-- Intervene
	47788, -- Guardian Spirit
	66,		-- Invisibility
	68992, -- Darkflight (Worgen racial)
	6940, -- Hand of Sacrifice
	740,	-- Tranquility
	77606,	-- Dark Simulacrum
	77761,	-- Stampeding Roar (bear)
	77764,	-- Stampeding Roar (cat)
	85499,	-- Speed of Light
	17,
}

AuraList.Misc = {
	118358,	-- Drinking
}

AuraList.Stun = {
	107570,	-- Storm Bolt
	108194,	-- Asphyxiate
	117526,	-- Binding Shot
	119381,	-- Leg Sweep
	163505,	-- Rake
	1776, -- Gouge
	179057, -- Chaos Nova
	1833, -- Cheap Shot
	199804, -- Between the Eyes
	200166,	-- Metamorphosis stun
	207165, -- Abominations Might
	211794, -- Winter is Coming
	211881, -- Fel Eruption
	221562, -- Asphyxiate
	22570, -- Maim
	24394,	-- Intimidation
	30283, -- Shadowfury
	408, -- Kidney Shot
	46968, -- Shockwave
	47481, -- Gnaw
	5211, -- Mighty Bash
	65929,	-- Charge Stun
	6770, -- Sap
	853, -- Hammer of Justice
	88625, -- Holy Word: Chastise
	89766,	-- Axe Toss
	91797, -- Monstrous Blow (Gnaw with DT)
}

AuraList.CC = {
	102359,	-- Mass Entanglement
	105421,	-- Blinding Light
	107566,	-- Staggering Shout
	114404,	-- Void Tendrils
	115078, -- Paralysis
	116706,	-- Disable (2x)
	118, -- Polymorph
	128405,	-- Narrow Escape
	1776,	-- Gouge
	187650, -- Freezing Trap
	19386,	-- Wyvern Sting
	19387, 	-- Entrapment
	20066, -- Repentance
	205364, -- Dominant Mind (Talented verion of Mind Control)
	207685, -- Sigil of misery
	2094, -- Blind
	217832, -- imprison (demon)
	31661, -- Dragons Breath
	33786,	-- Cyclone
	339, -- Entangling Roots
	45334,	-- Wild Charge
	51514, -- Hex
	5246, -- Intimidating Shout
	5484, -- Howl of Terror
	5782, -- Fear
	605, -- Mind Control
	6358, -- Seduction
	64044,	-- Psychic Horror
	64803,	-- Entrapment
	6789, -- Death Coil
	8122, -- Psychic Scream
	82691, 	-- Ring of Frost
	8377,	-- Earthgrab
	91807, 	-- Shambling Rush (Leap with DT)
	9484, -- Shackle Undead
	99,		-- Disorienting Roar
}

AuraList.Silence = {
	1330, -- Garrote - Silence
	15487, -- Silence (priest)
	183752, -- Consume Magic
	19647, -- Spell Lock
	204490, -- sigil of silence
	28730, -- Arcane Torrent
	47476, -- Strangulate
	81261,	-- Solar Beam
}

AuraList.Taunt = {
	56222,	-- Dark Command
	57604,	-- Death Grip
	20736,	-- Distracting Shot
	6795,	-- Growl
	116189,	-- Provoke
	62124,	-- Reckoning
	355,	-- Taunt
	185245, -- Torment
}

for k, v in pairs(AuraList) do
	for i = 1, #v do
		if not GetSpellInfo(v[i]) then
			print(string.format("Invalid spellID %d in : %s", v[i], k))
		end
	end
end

K.AuraList = AuraList