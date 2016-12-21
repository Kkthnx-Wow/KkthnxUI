local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true or C.Unitframe.CastbarTicks ~= true then return end

----------------------------------------------------------------------------------------
--	The best way to add or delete spell is to go at www.wowhead.com, search for a spell.
--	Example: Drain Life -> http://www.wowhead.com/spell=689
--	Take the number ID at the end of the URL, and add it to the list
----------------------------------------------------------------------------------------
local function SpellName(id)
	local name = GetSpellInfo(id)
	if name then
		return name
	else
		print("|cffff0000WARNING: spell ID ["..tostring(id).."] no longer exists! Report this to Kkthnx.|r")
		return "Empty"
	end
end

K.CastBarTicks = {
	-- Druid
	[SpellName(740)] = 4,		-- Tranquility
	-- Mage
	[SpellName(12051)] = 4,		-- Evocation
	[SpellName(5143)] = 5,		-- Arcane Missiles
	-- Monk
	[SpellName(113656)] = 4,	-- Fists of Fury
	[SpellName(115175)] = 9,	-- Soothing Mist
	[SpellName(117952)] = 6,	-- Crackling Jade Lightning
	-- Priest
	[SpellName(15407)] = 4,		-- Mind Flay
	[SpellName(179338)] = 5,	-- Searing Insanity
	[SpellName(47540)] = 3,		-- Penance
	[SpellName(48045)] = 5,		-- Mind Sear
	[SpellName(64843)] = 4,		-- Divine Hymn
	-- Warlock
	[SpellName(198590)] = 6,	-- Drain Soul
	[SpellName(689)] = 6,		-- Drain Life
	[SpellName(755)] = 6,		-- Health Funnel
}