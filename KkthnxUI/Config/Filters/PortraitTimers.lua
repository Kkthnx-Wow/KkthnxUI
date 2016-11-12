local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

K.PortraitTimerDB = {

	-- Immunitys
	"45438", -- Ice Block
	"33786", -- Cyclone (PvP Talent)
	"642", -- Divine Shield
	"1022", -- Hand of Protection
	"204018", -- Blessing of Spellwarding (Talented verion of Blessing of Protection)
	"46924", -- Bladestorm
	"104773", -- Unending Resolve
	"18499", -- Berserker Rage
	"47585", -- Dispersion
	"196555", -- Netherwalk (Talent)

	-- Stuns
	"408", -- Kidney Shot
	"1833", -- Cheap Shot
	"46968", -- Shockwave
	"853", -- Hammer of Justice
	"5211", -- Mighty Bash
	"30283", -- Shadowfury
	"89766", -- Axe Toss
	"22570", -- Maim
	"47481", -- Gnaw
	"1776", -- Gouge
	"6770", -- Sap
	"88625", -- Holy Word: Chastise
	"91797", -- Monstrous Blow (Gnaw with DT)
	"179057", -- Chaos Nova
	"221562", -- Asphyxiate
	"199804", -- Between the Eyes
	"207165", -- Abomination"s Might
	"211794", -- Winter is Coming
	"211881", -- Fel Eruption

	-- CC
	"605", -- Mind Control
	"205364", -- Dominant Mind (Talented verion of Mind Control)
	"2094", -- Blind
	"118", -- Polymorph
	"51514", -- Hex
	"6789", -- Death Coil
	"5246", -- Intimidating Shout
	"8122", -- Psychic Scream
	"5484", -- Howl of Terror
	"5782", -- Fear
	"6358", -- Seduction
	"187650", -- Freezing Trap
	"20066", -- Repentance
	"339", -- Entangling Roots
	"31661", -- Dragon"s Breath
	"217832", -- Imprison
	"9484", -- Shackle Undead
	"115078", -- Paralysis

	-- CC immune
	"53271", -- Master"s Call
	"1044", -- Hand of Freedom
	"31224", -- Cloak of Shadows
	"51271", -- Pillar of Frost

	-- Dmg reductions
	"48707", -- Anti-Magic Shell
	"33206", -- Pain Suppression
	"47585", -- Dispersion
	"871", -- Shield Wall
	"48792", -- Icebound Fortitude
	"498", -- Divine Protection
	"22812", -- Barkskin
	"61336", -- Survival Instincts
	"5277", -- Evasion
	"186265", -- Aspect of the Turtle
	"198589", -- Blur
	"203720", -- Demon Spikes
	"218256", -- Empower Wards

	-- Silences
	"47476", -- Strangulate
	"1330", -- Garrote - Silence
	"15487", -- Silence (priest)
	"19647", -- Spell Lock
	"28730", -- Arcane Torrent
	"183752", -- Consume Magic
	"202137", -- Sigil of Silence

	-- Dmg buffs
	"31884", -- Avenging Wrath
	"211048", -- Chaos Blades

	-- Helpful buffs
	"6940", -- Hand of Sacrifice
	"23920", -- Spell Reflection (warrior)
	"68992", -- Darkflight (Worgen racial)
	"2983", -- Sprint
	"47788", -- Guardian Spirit
	"1850", -- Dash
}
