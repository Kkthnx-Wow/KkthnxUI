local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

local _G = _G

local GetSpellInfo = _G.GetSpellInfo

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id)
	if not name then
		print("|cff3c9bedKkthnxUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to KkthnxUI author.")
		return "Impale"
	else
		return name
	end
end

local AuraList = {}

AuraList.Immunity = {
	[SpellName(47476)] = true,
	[SpellName(1022)] = true,	-- Hand of Protection
	[SpellName(104773)] = true, -- Unending Resolve
	[SpellName(18499)] = true, -- Berserker Rage
	[SpellName(19263)] = true,	-- Deterrence
	[SpellName(196555)] = true, -- Netherwalk (Talent)
	[SpellName(204018)] = true, -- Blessing of Spellwarding (Talented verion of Blessing of Protection)
	[SpellName(33786)] = true, -- Cyclone (PvP Talent)
	[SpellName(45438)] = true, -- Ice Block
	[SpellName(46924)] = true, -- Bladestorm
	[SpellName(47585)] = true,	-- Dispersion (Priest)
	[SpellName(51690)] = true,	-- Killing Spree
	[SpellName(642)] = true,	-- Divine Shield (Paladin)
}

AuraList.CCImmunity = {
	[SpellName(1044)] = true, -- Hand of Freedom
	[SpellName(114028)] = true,	-- Mass Spell Reflection
	[SpellName(115018)] = true,	-- Desecrated Ground
	[SpellName(23920)] = true,	-- Spell Reflection (warrior)
	[SpellName(31224)] = true, -- Cloak of Shadows
	[SpellName(31821)] = true,	-- Aura Mastery
	[SpellName(49039)] = true,	-- Lichborne
	[SpellName(51271)] = true, -- Pillar of Frost
	[SpellName(53271)] = true, -- Masters Call
	[SpellName(8178)] = true,	-- Grounding Totem Effect (Grounding Totem)
}

AuraList.Defensive = {
	[SpellName(115176)] = true,	-- Zen Meditation
	[SpellName(115203)] = true,	-- Fortifying Brew
	[SpellName(116888)] = true,	-- Shroud of Purgatory
	[SpellName(122278)] = true,	-- Dampen Harm
	[SpellName(122470)] = true,	-- Touch of Karma
	[SpellName(122783)] = true,	-- Diffuse Magic
	[SpellName(186265)] = true, -- Aspect of the Turtle
	[SpellName(192081)] = true, -- IronFur
	[SpellName(192083)] = true, -- Mark of Ursol
	[SpellName(198589)] = true, -- Blur
	[SpellName(203720)] = true, -- Demon Spikes
	[SpellName(212800)] = true, -- blur
	[SpellName(218256)] = true, -- Empower Wards
	[SpellName(22812)] = true, -- Barkskin
	[SpellName(33206)] = true, -- Pain Suppression
	[SpellName(45182)] = true,	-- Cheating Death
	[SpellName(47585)] = true, -- Dispersion
	[SpellName(47788)] = true,	-- Guardian Spirit
	[SpellName(48707)] = true, -- Anti-Magic Shell
	[SpellName(48792)] = true, -- Icebound Fortitude
	[SpellName(498)] = true, -- Divine Protection
	[SpellName(5277)] = true, -- Evasion
	[SpellName(61336)] = true, -- Survival Instincts
	[SpellName(6940)] = true,	-- Hand of Sacrifice
	[SpellName(74001)] = true,	-- Combat Readiness
	[SpellName(871)] = true, -- Shield Wall
}

AuraList.Offensive = {
	[SpellName(102342)] = true,	-- Ironbark
	[SpellName(102543)] = true,	-- Incarnation: King of the Jungle
	[SpellName(102560)] = true,	-- Incarnation: Chosen of Elune
	[SpellName(12472)] = true,	-- Icy Veins
	[SpellName(162264)] = true, -- Metamorphosis
	[SpellName(1719)] = true,	-- Recklessness
	[SpellName(185313)] = true,	-- Shadow Dance
	[SpellName(211048)] = true, -- Chaos Blades
	[SpellName(31884)] = true, -- Avenging Wrath
}

AuraList.Helpful = {
	[SpellName(106898)] = true,	-- Stampeding Roar
	[SpellName(108212)] = true,	-- Burst of Speed
	[SpellName(108843)] = true, -- Blazing Speed
	[SpellName(112833)] = true,	-- Spectral Guise
	[SpellName(116841)] = true,	-- Tigers Lust
	[SpellName(118922)] = true,	-- Posthaste
	[SpellName(1850)] = true, -- Dash
	[SpellName(188501)] = true, -- Speci
	[SpellName(23920)] = true, -- Spell Reflection (warrior)
	[SpellName(2983)] = true, -- Sprint
	[SpellName(3411)] = true,	-- Intervene
	[SpellName(47788)] = true, -- Guardian Spirit
	[SpellName(66)] = true,		-- Invisibility
	[SpellName(68992)] = true, -- Darkflight (Worgen racial)
	[SpellName(6940)] = true, -- Hand of Sacrifice
	[SpellName(740)] = true,	-- Tranquility
	[SpellName(77606)] = true,	-- Dark Simulacrum
	[SpellName(77761)] = true,	-- Stampeding Roar (bear)
	[SpellName(77764)] = true,	-- Stampeding Roar (cat)
	[SpellName(85499)] = true,	-- Speed of Light
	[SpellName(17)] = true,
}

AuraList.Misc = {
	[SpellName(118358)] = true,	-- Drinking
}

AuraList.Stun = {
	[SpellName(107570)] = true,	-- Storm Bolt
	[SpellName(108194)] = true,	-- Asphyxiate
	[SpellName(117526)] = true,	-- Binding Shot
	[SpellName(119381)] = true,	-- Leg Sweep
	[SpellName(163505)] = true,	-- Rake
	[SpellName(1776)] = true, -- Gouge
	[SpellName(179057)] = true, -- Chaos Nova
	[SpellName(1833)] = true, -- Cheap Shot
	[SpellName(199804)] = true, -- Between the Eyes
	[SpellName(200166)] = true,	-- Metamorphosis stun
	[SpellName(207165)] = true, -- Abominations Might
	[SpellName(211794)] = true, -- Winter is Coming
	[SpellName(211881)] = true, -- Fel Eruption
	[SpellName(221562)] = true, -- Asphyxiate
	[SpellName(22570)] = true, -- Maim
	[SpellName(24394)] = true,	-- Intimidation
	[SpellName(30283)] = true, -- Shadowfury
	[SpellName(408)] = true, -- Kidney Shot
	[SpellName(46968)] = true, -- Shockwave
	[SpellName(47481)] = true, -- Gnaw
	[SpellName(5211)] = true, -- Mighty Bash
	[SpellName(65929)] = true,	-- Charge Stun
	[SpellName(6770)] = true, -- Sap
	[SpellName(853)] = true, -- Hammer of Justice
	[SpellName(88625)] = true, -- Holy Word: Chastise
	[SpellName(89766)] = true,	-- Axe Toss
	[SpellName(91797)] = true, -- Monstrous Blow (Gnaw with DT)
}

AuraList.CC = {
	[SpellName(102359)] = true,	-- Mass Entanglement
	[SpellName(105421)] = true,	-- Blinding Light
	[SpellName(107566)] = true,	-- Staggering Shout
	[SpellName(114404)] = true,	-- Void Tendrils
	[SpellName(115078)] = true, -- Paralysis
	[SpellName(116706)] = true,	-- Disable (2x)
	[SpellName(118)] = true, -- Polymorph
	[SpellName(128405)] = true,	-- Narrow Escape
	[SpellName(1776)] = true,	-- Gouge
	[SpellName(187650)] = true, -- Freezing Trap
	[SpellName(19386)] = true,	-- Wyvern Sting
	[SpellName(19387)] = true, 	-- Entrapment
	[SpellName(20066)] = true, -- Repentance
	[SpellName(205364)] = true, -- Dominant Mind (Talented verion of Mind Control)
	[SpellName(207685)] = true, -- Sigil of misery
	[SpellName(2094)] = true, -- Blind
	[SpellName(217832)] = true, -- imprison (demon)
	[SpellName(31661)] = true, -- Dragons Breath
	[SpellName(33786)] = true,	-- Cyclone
	[SpellName(339)] = true, -- Entangling Roots
	[SpellName(45334)] = true,	-- Wild Charge
	[SpellName(51514)] = true, -- Hex
	[SpellName(5246)] = true, -- Intimidating Shout
	[SpellName(5484)] = true, -- Howl of Terror
	[SpellName(5782)] = true, -- Fear
	[SpellName(605)] = true, -- Mind Control
	[SpellName(6358)] = true, -- Seduction
	[SpellName(64044)] = true,	-- Psychic Horror
	[SpellName(64803)] = true,	-- Entrapment
	[SpellName(6789)] = true, -- Death Coil
	[SpellName(8122)] = true, -- Psychic Scream
	[SpellName(82691)] = true, 	-- Ring of Frost
	[SpellName(8377)] = true,	-- Earthgrab
	[SpellName(91807)] = true, 	-- Shambling Rush (Leap with DT)
	[SpellName(9484)] = true, -- Shackle Undead
	[SpellName(99)] = true,		-- Disorienting Roar
}

AuraList.Silence = {
	[SpellName(1330)] = true, -- Garrote - Silence
	[SpellName(15487)] = true, -- Silence (priest)
	[SpellName(183752)] = true, -- Consume Magic
	[SpellName(19647)] = true, -- Spell Lock
	[SpellName(204490)] = true, -- sigil of silence
	[SpellName(28730)] = true, -- Arcane Torrent
	[SpellName(47476)] = true, -- Strangulate
	[SpellName(81261)] = true,	-- Solar Beam
}

AuraList.Taunt = {
	[SpellName(116189)] = true,	-- Provoke
	[SpellName(185245)] = true, -- Torment
	[SpellName(20736)] = true, -- Distracting Shot
	[SpellName(355)] = true, -- Taunt
	[SpellName(56222)] = true, -- Dark Command
	[SpellName(57604)] = true, -- Death Grip
	[SpellName(62124)] = true, -- Reckoning
	[SpellName(6795)] = true,	-- Growl
}

K.AuraList = AuraList