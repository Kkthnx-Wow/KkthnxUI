local K = unpack(select(2, ...))

-- Reminder Buffs Checklist
K.ReminderBuffs = {
	MAGE = {
			{	spells = {	-- Arcane Familiar
				[210126] = true,
			},
			depend = 205022,
			spec = 1,
			combat = true,
			instance = true,
			pvp = true,
		},
			{	spells = {	-- Arcane Intellect
				[1459] = true,
			},
			depend = 1459,
			instance = true,
		},
	},
	PRIEST = {
			{	spells = {	-- Power Word: Fortitude
				[21562] = true,
			},
			depend = 21562,
			instance = true,
		},
	},
	WARRIOR = {
			{	spells = {	-- Battle Shout
				[6673] = true,
			},
			depend = 6673,
			instance = true,
		},
	},
	SHAMAN = {
			{	spells = {	-- Lightning Shield
				[192106] = true,
			},
			depend = 192106,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	ROGUE = {
			{	spells = {
				[2823] = true, -- Deadly Poison
				[8679] = true, -- Wound Poison
			},
			spec = 1,
			combat = true,
			instance = true,
			pvp = true,
		},
			{	spells = {
				[3408] = true, -- Crippling Poison
			},
			spec = 1,
			pvp = true,
		},
	},
}