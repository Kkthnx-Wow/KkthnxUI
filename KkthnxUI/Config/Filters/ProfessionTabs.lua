local K = unpack(select(2, ...))

K.ProfessionTabs_Whitelist = {
	[171] = true, -- Alchemy
	[164] = true, -- Blacksmithing
	[185] = true, -- Cooking
	[333] = true, -- Enchanting
	[202] = true, -- Engineering
	[129] = true, -- First Aid
	[773] = true, -- Inscription
	[755] = true, -- Jewelcrafting
	[165] = true, -- Leatherworking
	[186] = true, -- Mining
	[197] = true, -- Tailoring
	[182] = true, -- Herbalism
	[393] = true, -- Skinning
	[356] = true, -- Fishing
}

K.ProfessionTabs_OnlyPrimary = {
	[171] = true, -- Alchemy
	[202] = true, -- Engineering
	[182] = true, -- Herbalism
	[393] = true, -- Skinning
	[356] = true, -- Fishing
}

K.ProfessionTabs_RUNEFORGING = 53428 -- Runeforging Spellid
K.ProfessionTabs_CHEF_HAT = 134020