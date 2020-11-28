local _, C = unpack(select(2, ...))

-- Reminder Buffs Checklist
C.SpellReminderBuffs = {
	ITEMS = {
		{	itemID = 178742, -- Bottled Flayedwing Toxin
			spells = {
				[345545] = true,
			},
			equip = true,
			instance = true,
			combat = true,
		},
		{	itemID = 174906, -- Lightning-Forged Augment Rune
			spells = {
				[317065] = true,
				[270058] = true,
			},
			instance = true,
			disable = true,
		},
	},
	MAGE = {
			{	spells = { -- Arcane Familiar
				[210126] = true,
			},
			depend = 205022,
			spec = 1,
			combat = true,
			instance = true,
			pvp = true,
		},
			{	spells = { -- Arcane Wisdom
				[1459] = true,
			},
			depend = 1459,
			instance = true,
		},
	},
	PRIEST = {
			{	spells = { -- Power word
				[21562] = true,
			},
			depend = 21562,
			instance = true,
		},
	},
	WARRIOR = {
			{	spells = { -- Battle roar
				[6673] = true,
			},
			depend = 6673,
			instance = true,
		},
	},
	SHAMAN = {
			{	spells = {
				[192106] = true, -- Lightning Shield
				[974] = true, -- Earth Shield
				[52127] = true, -- Water shield
			},
			depend = 192106,
			combat = true,
			instance = true,
			pvp = true,
		},
			{	spells = {
				[33757] = true, -- Windfury weapon
			},
			depend = 33757,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 1,
			spec = 2,
		},
			{	spells = {
				[318038] = true, -- Fire tongue weapon
			},
			depend = 318038,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 2,
			spec = 2,
		},
	},
	ROGUE = {
			{	spells = { -- Harmful poison
				[2823] = true, -- Deadly ointment
				[8679] = true, -- Wound ointment
				[315584] = true, -- Quick-acting ointment
			},
			texture = 132273,
			depend = 315584,
			combat = true,
			instance = true,
			pvp = true,
		},
			{	spells = { -- Effect poison
				[3408] = true, -- Slowing ointment
				[5761] = true, -- Sluggish Ointment
			},
			depend = 3408,
			pvp = true,
		},
	},
}