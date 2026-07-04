local C = KkthnxUI[2]

-- Core raid-buff / consumable reminders (aligned with NexEnhance ReminderBuffs, 12.x).
-- Each entry: spells = { [spellID] = true }, optional depend/depends, spec, combat, instance, pvp, inGroup, itemID, equip, weaponIndex.
C.SpellReminderBuffs = {
	ITEMS = {
		{
			itemID = 190384, -- 9.0 permanent stat rune
			spells = {
				[393438] = true, -- Draconic Augment Rune (item 201325)
				[367405] = true, -- permanent rune buff
			},
			instance = true,
			disable = true, -- disabled until a new rune exists
		},
	},
	MAGE = {
		{
			spells = { [1459] = true, [432778] = true }, -- Arcane Intellect (+ alternate raid buff id)
			depend = 1459,
			instance = true,
		},
	},
	PRIEST = {
		{
			spells = { [21562] = true }, -- Power Word: Fortitude
			depend = 21562,
			instance = true,
		},
	},
	WARRIOR = {
		{
			spells = { [6673] = true }, -- Battle Shout
			depend = 6673,
			instance = true,
		},
	},
	SHAMAN = {
		{
			spells = { [319773] = true }, -- Windfury Weapon (enchant buff)
			depend = 33757,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 1,
			spec = 2,
		},
		{
			spells = { [319778] = true }, -- Flametongue Weapon (enchant buff)
			depend = 318038,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 2,
			spec = 2,
		},
		{
			spells = { [462854] = true }, -- Skyfury
			depend = 462854,
			instance = true,
		},
	},
	ROGUE = {
		{
			spells = {
				[2823] = true,
				[8679] = true,
				[315584] = true,
				[381664] = true,
			},
			texture = 132273,
			depends = { 2823, 8679, 315584, 381664 },
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = {
				[3408] = true,
				[5761] = true,
				[381637] = true,
			},
			depends = { 3408, 5761, 381637 },
			pvp = true,
		},
	},
	EVOKER = {
		{
			spells = {
				[381732] = true,
				[381741] = true,
				[381746] = true,
				[381748] = true,
				[381749] = true,
				[381750] = true,
				[381751] = true,
				[381752] = true,
				[381753] = true,
				[381754] = true,
				[381756] = true,
				[381757] = true,
				[381758] = true,
			},
			depend = 364342, -- Blessing of the Bronze
			instance = true,
		},
	},
	DRUID = {
		{
			spells = { [1126] = true, [432661] = true }, -- Mark of the Wild (+ alternate raid buff id)
			depend = 1126,
			instance = true,
		},
	},
}
