local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local AuraList = {}

AuraList.Immunity = {
	1022,	-- Hand of Protection
	642,	-- Divine Shield (Paladin)
	47585,	-- Dispersion (Priest)
	45438,	-- Ice Block
	46924,	-- Bladestorm
	19263 ,	-- Deterrence
	51690,	-- Killing Spree
}

AuraList.CCImmunity = {
	1044,	-- Hand of Freedom
	115018,	-- Desecrated Ground
	31224,	-- Cloak of Shadows
	31821,	-- Aura Mastery
	49039,	-- Lichborne
	51271,	-- Pillar of Frost
	53271,	-- Masters Call
	8178,	-- Grounding Totem Effect (Grounding Totem)
	114028,	-- Mass Spell Reflection
	23920,	-- Spell Reflection (warrior)
}

AuraList.Defensive = {
	122470,	--Touch of Karma
	115176,	-- Zen Meditation
	115203,	-- Fortifying Brew
	115610,	-- Temporal Shield
	116888,	-- Shroud of Purgatory
	122278,	-- Dampen Harm
	122783,	-- Diffuse Magic
	22812,	-- Barskin
	33206,	-- Pain Suppression
	47788,	-- Guardian Spirit
	48707,	-- Anti-Magic Shell
	48792,	-- Icebound Fortitude
	498,	-- Divine Protection
	5277,	-- Evasion
	61336,	-- Survival Instincts
	74001,	-- Combat Readiness
	871,	-- Shield Wall
	45182,	-- Cheating Death
	6940,	-- Hand of Sacrifice
	195181, -- Bone Shield
	192081, -- IronFur
	192083, -- Mark of Ursol
	212800, -- blur
}

AuraList.Offensive = {
	31884,	-- Avenging Wrath
	185313,	-- Shadow Dance
	1719,	-- Recklessness
	12472,	-- Icy Veins
	102342,	-- Ironbark

	102543,	-- Incarnation: King of the Jungle
	102560,	-- Incarnation: Chosen of Elune
	162264, -- Metamorphosis
}

AuraList.Helpful = {
	77606,	-- Dark Simulacrum
	106898,	-- Stampeding Roar
	108212,	-- Burst of Speed
	108843, -- Blazing Speed
	112833,	-- Spectral Guise
	116841,	-- Tigers Lust
	118922,	-- Posthaste
	1850, 	-- Dash
	2983,	-- Sprint
	3411,	-- Intervene
	66,		-- Invisibility
	68992,	-- Darkflight (Worgen racial)
	740,	-- Tranquility
	77761,	-- Stampeding Roar (bear)
	77764,	-- Stampeding Roar (cat)
	85499,	-- Speed of Light
	--96268 removed,	-- Deaths Advance
	188501, -- Speci
}

AuraList.Misc = {
	118358,	-- Drinking
}

AuraList.Stun = {
	--105593 removed,	-- Fist of Justice
	107570,	-- Storm Bolt
	108194,	-- Asphyxiate
	117526,	-- Binding Shot
	119381,	-- Leg Sweep
	--119392 removed,	-- Charging Ox Wave
	1833,	-- Cheap Shot
	24394,	-- Intimidation
	30283,	-- Shadowfury
	408,	-- Kidney Shot
	--44572 removed,	-- Deep Freeze
	46968,	-- Shockwave
	47481,	-- Gnaw
	5211,	-- Bash
	65929,	-- Charge Stun
	6770,	-- Sap
	853,	-- Hammer of Justice
	--87195 removed,	-- Paralysis
	88625,	-- Holy Word: Chastise
	89766,	-- Axe Toss
	91797,	-- Monstrous Blow (Gnaw with DT)
	163505,	-- Rake
	22570,	-- Maim
	--115001 removed,	-- Remorseless Winter
	200166,	-- Metamorphosis stun
	211881,	-- Fel Eruption
	179057,	-- Chaos Nova
}

AuraList.CC = {
	33786,	-- Cyclone
	--102051 removed,	-- Frostjaw
	102359,	-- Mass Entanglement
	--10326 removed,	-- Turn Evil
	105421,	-- Blinding Light
	107566,	-- Staggering Shout
	114404,	-- Void Tendrils
	115078,	-- Paralysis
	116706,	-- Disable (2x)
	118, 	-- Polymorph
	128405,	-- Narrow Escape
	--1499 removed,	-- Freezing Trap
	19386,	-- Wyvern Sting
	19387, 	-- Entrapment
	20066,	-- Repentance
	2094, 	-- Blind
	31661,	-- Dragons Breath
	339,	-- Entangling Roots
	45334,	-- Wild Charge
	51514, 	-- Hex
	5246,	-- Intimidating Shout
	5484, 	-- Howl of Terror
	5782,	-- Fear
	605, 	-- Mind Control
	6358,	-- Seduction
	64044,	-- Psychic Horror
	64803,	-- Entrapment
	6789, 	-- Death Coil
	8122,	-- Psychic Scream
	82691, 	-- Ring of Frost
	8377,	-- Earthgrab
	91807, 	-- Shambling Rush (Leap with DT)
	99,		-- Disorienting Roar
	1776,	-- Gouge
	217832, -- imprison (demon)
	207685, -- Sigil of misery
}

AuraList.Silence = {
	1330,	-- Garrote - Silence
	15487,	-- Silence (priest)
	19647,	-- Spell Lock
	28730,	-- Arcane Torrent
	47476,	-- Strangulate
	81261,	-- Solar Beam
	204490, -- sigil of silence
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
			print(string.format("Invalid spellID %d in : %s", v[i], s))
		end
	end
end

K.AuraList = AuraList