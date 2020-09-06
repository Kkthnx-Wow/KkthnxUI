local K = unpack(select(2, ...))

local _G = _G

local GetSpellInfo = _G.GetSpellInfo

local function SpellName(id)
	local name = GetSpellInfo(id)
	if name then
		return name
	else
		K.Print("|cffff0000WARNING: [BadBuffsFilter] - spell ID ["..tostring(id).."] no longer exists! Report this to Kkthnx.|r")
		return "Empty"
	end
end

K.CheckBadBuffs = {
	[SpellName(172003)] = true,	-- Slime Costume
	[SpellName(172008)] = true,	-- Ghoul Costume
	[SpellName(172010)] = true,	-- Abomination Costume
	[SpellName(172015)] = true,	-- Geist Costume
	[SpellName(172020)] = true,	-- Spider Costume
	[SpellName(24709)] = true,	-- Pirate Costume
	[SpellName(24710)] = true,	-- Ninja Costume
	[SpellName(24712)] = true,	-- Leper Gnome Costume
	[SpellName(24723)] = true,	-- Skeleton Costume
	[SpellName(24732)] = true,	-- Bat Costume
	[SpellName(24735)] = true,	-- Ghost Costume
	[SpellName(24740)] = true,	-- Wisp Costume
	[SpellName(279509)] = true,	-- A Witch!
	[SpellName(44212)] = true,	-- Jack-o'-Lanterned!
	[SpellName(58493)] = true,	-- Mohawked!
	[SpellName(61716)] = true,	-- Rabbit Costume
	[SpellName(61734)] = true,	-- Noblegarden Bunny
	[SpellName(61781)] = true,	-- Turkey Feathers
	[SpellName(261477)] = true,	-- Dervish
}