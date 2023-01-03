local _, C = unpack(KkthnxUI)

C.SpellReminderBuffs = {
	ITEMS = {
		{
			itemID = 190384, -- 9.0永久属性符文
			spells = {
				[393438] = true, -- 巨龙强化符文 itemID 201325
				[367405] = true, -- 永久符文buff
			},
			instance = true,
			disable = true, -- 禁用直到出了新符文
		},
		{
			itemID = 194307, -- 巢穴守护者的诺言
			spells = {
				[394457] = true,
			},
			equip = true,
			instance = true,
			inGroup = true,
		},
		--[=[
		{	itemID = 178742, -- 瓶装毒素饰品
			spells = {
				[345545] = true,
			},
			equip = true,
			instance = true,
			combat = true,
		},
		{	itemID = 190958, -- 究极秘术
			spells = {
				[368512] = true,
			},
			equip = true,
			instance = true,
			inGroup = true,
		},
		]=]
	},
	MAGE = {
		{
			spells = { -- 奥术魔宠
				[210126] = true,
			},
			depend = 205022,
			spec = 1,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { -- 奥术智慧
				[1459] = true,
			},
			depend = 1459,
			instance = true,
		},
	},
	PRIEST = {
		{
			spells = { -- 真言术耐
				[21562] = true,
			},
			depend = 21562,
			instance = true,
		},
	},
	WARRIOR = {
		{
			spells = { -- 战斗怒吼
				[6673] = true,
			},
			depend = 6673,
			instance = true,
		},
	},
	SHAMAN = {
		{
			spells = {
				[192106] = true, -- 闪电之盾
				[974] = true, -- 大地之盾
				[52127] = true, -- 水之护盾
			},
			depend = 192106,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = {
				[33757] = true, -- 风怒武器
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
				[318038] = true, -- 火舌武器
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
			spells = { -- 伤害类毒药
				[2823] = true, -- 致命药膏
				[8679] = true, -- 致伤药膏
				[315584] = true, -- 速效药膏
			},
			texture = 132273,
			depend = 315584,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { -- 效果类毒药
				[3408] = true, -- 减速药膏
				[5761] = true, -- 迟钝药膏
			},
			depend = 3408,
			pvp = true,
		},
	},
	EVOKER = {
		{
			spells = { -- 青铜龙的祝福
				[381748] = true,
			},
			depend = 364342,
			instance = true,
		},
	},
	DRUID = {
		{
			spells = { -- 野性印记
				[1126] = true,
			},
			depend = 1126,
			instance = true,
		},
	},
}
