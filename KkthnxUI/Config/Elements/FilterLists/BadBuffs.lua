local K, C = unpack(KkthnxUI)

local GetSpellInfo = _G.GetSpellInfo

local function SpellName(id)
	local name = GetSpellInfo(id)
	if name then
		return name
	else
		K.Print("|cffff0000WARNING: [BadBuffsFilter] - spell ID [" .. tostring(id) .. "] no longer exists! Report this to Kkthnx.|r")
		return "Empty"
	end
end

C.CheckBadBuffs = {
	[SpellName(172003)] = true,
	[SpellName(172008)] = true,
	[SpellName(172010)] = true,
	[SpellName(172015)] = true,
	[SpellName(172020)] = true,
	[SpellName(24709)] = true,
	[SpellName(24710)] = true,
	[SpellName(24712)] = true,
	[SpellName(24723)] = true,
	[SpellName(24732)] = true,
	[SpellName(24735)] = true,
	[SpellName(24740)] = true,
	[SpellName(279509)] = true,
	[SpellName(44212)] = true,
	[SpellName(58493)] = true,
	[SpellName(61716)] = true,
	[SpellName(61734)] = true,
	[SpellName(61781)] = true,
	[SpellName(261477)] = true,
	[SpellName(354550)] = true,
	[SpellName(354481)] = true,
}
