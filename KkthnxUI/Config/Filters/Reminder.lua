local K = unpack(select(2, ...))

-- Reminder Buffs Checklist
K.ReminderBuffs = {
	MAGE = {
		{
			spells = { -- Arcane Fantasy
				[210126] = true,
			},
			Depend = 205022,
			Spec = 1,
			Combat = true,
			Instance = true,
			Pvp = true,
		},
		{
			spells = { -- Arcane Wisdom
				[1459] = true,
			},
			Depend = 1459,
			Instance = true,
		},
	},
	PRIEST = {
		{
			spells = { -- Power Word: Fortitude
				[21562] = true,
			},
			Depend = 21562,
			Instance = true,
			level = 22,
		},
	},
	WARRIOR = {
		{
			spells = { -- Fighting roar
				[6673] = true,
			},
			Depend = 6673,
			Instance = true,
		},
	},
	SHAMAN = {
		{
			spells = { -- Lightning Shield
				[192106] = true,
			},
			Depend = 192106,
			Combat = true,
			Instance = true,
			Pvp = true,
		},
	},
	ROGUE = {
		{
			spells = { -- damage poison
				[2823] = true, -- fatal ointment
				[8679] = true, -- wounding ointment
			},
			Spec = 1,
			Combat = true,
			Instance = true,
			Pvp = true,
		},
		{
			spells = { -- effect poison
				[3408] = true, -- slowing cream
			},
			Spec = 1,
			Pvp = true,
		},
	},
}