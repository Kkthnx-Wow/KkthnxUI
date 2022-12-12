local _, C = unpack(KkthnxUI)

C.SpellReminderBuffs = {
	ITEMS = {
		{
			itemID = 178742,
			spells = {
				[345545] = true,
			},
			equip = true,
			instance = true,
			combat = true,
		},
		{
			itemID = 174906,
			spells = {
				[317065] = true,
				[270058] = true,
			},
			instance = true,
			disable = true,
		},
	},
	MAGE = {
		{
			spells = {
				[210126] = true,
			},
			depend = 205022,
			spec = 1,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = {
				[1459] = true,
			},
			depend = 1459,
			instance = true,
		},
	},
	PRIEST = {
		{
			spells = {
				[21562] = true,
			},
			depend = 21562,
			instance = true,
		},
	},
	WARRIOR = {
		{
			spells = {
				[6673] = true,
			},
			depend = 6673,
			instance = true,
		},
	},
	SHAMAN = {
		{
			spells = {
				[192106] = true,
				[974] = true,
				[52127] = true,
			},
			depend = 192106,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = {
				[33757] = true,
			},
			depend = 33757,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 1,
			spec = 2,
		},
		{
			spells = {
				[318038] = true,
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
		{
			spells = {
				[2823] = true,
				[8679] = true,
				[315584] = true,
			},
			texture = 132273,
			depend = 315584,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = {
				[3408] = true,
				[5761] = true,
			},
			depend = 3408,
			pvp = true,
		},
	},
}
