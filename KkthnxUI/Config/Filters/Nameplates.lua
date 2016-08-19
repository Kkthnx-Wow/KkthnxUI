local K, C, L, _ = select(2, ...):unpack()
if C.Nameplate.Enable ~= true then return end

-- LUA API
local tostring = tostring
local print = print

-- WOW API
local GetSpellInfo = GetSpellInfo

--[[
	THE BEST WAY TO ADD OR DELETE SPELL IS TO GO AT WWW.WOWHEAD.COM, SEARCH FOR A SPELL.
	EXAMPLE: POLYMORPH -> http://www.wowhead.com/spell=118
	TAKE THE NUMBER ID AT THE END OF THE URL, AND ADD IT TO THE LIST
]]--

local function SpellName(id)
	local name = GetSpellInfo(id)
	if name then
		return name
	else
		print("|cffff0000WARNING: spell ID ["..tostring(id).."] no longer exists! Report this to Kkthnx.|r")
		return "Empty"
	end
end

K.DebuffWhiteList = {
	-- DEATH KNIGHT
	[SpellName(108194)] = true,	-- ASPHYXIATE
	[SpellName(47476)] = true,	-- STRANGULATE
	[SpellName(55078)] = true,	-- BLOOD PLAGUE
	[SpellName(55095)] = true,	-- FROST FEVER
	-- DRUID
	[SpellName(33786)] = true,	-- CYCLONE
	[SpellName(339)] = true,	-- ENTANGLING ROOTS
	[SpellName(164812)] = true,	-- MOONFIRE
	[SpellName(164815)] = true,	-- SUNFIRE
	[SpellName(58180)] = true,	-- INFECTED WOUNDS
	[SpellName(155722)] = true,	-- RAKE
	[SpellName(1079)] = true,	-- RIP
	-- HUNTER
	[SpellName(3355)] = true,	-- FREEZING TRAP
	-- MAGE
	[SpellName(118)] = true,	-- POLYMORPH
	[SpellName(31661)] = true,	-- DRAGON'S BREATH
	[SpellName(122)] = true,	-- FROST NOVA
	[SpellName(44457)] = true,	-- LIVING BOMB
	[SpellName(114923)] = true,	-- NETHER TEMPEST
	[SpellName(112948)] = true,	-- FROST BOMB
	[SpellName(120)] = true,	-- CONE OF COLD
	-- MONK
	[SpellName(115078)] = true,	-- PARALYSIS
	-- PALADIN
	[SpellName(20066)] = true,	-- REPENTANCE
	[SpellName(853)] = true,	-- HAMMER OF JUSTICE
	-- PRIEST
	[SpellName(9484)] = true,	-- SHACKLE UNDEAD
	[SpellName(8122)] = true,	-- PSYCHIC SCREAM
	[SpellName(64044)] = true,	-- PSYCHIC HORROR
	[SpellName(15487)] = true,	-- SILENCE
	[SpellName(589)] = true,	-- SHADOW WORD: PAIN
	[SpellName(34914)] = true,	-- VAMPIRIC TOUCH
	-- ROGUE
	[SpellName(6770)] = true,	-- SAP
	[SpellName(2094)] = true,	-- BLIND
	[SpellName(1776)] = true,	-- GOUGE
	-- SHAMAN
	[SpellName(51514)] = true,	-- HEX
	[SpellName(3600)] = true,	-- EARTHBIND
	-- WARLOCK
	[SpellName(710)] = true,	-- BANISH
	[SpellName(6789)] = true,	-- MORTAL COIL
	[SpellName(5782)] = true,	-- FEAR
	[SpellName(5484)] = true,	-- HOWL OF TERROR
	[SpellName(6358)] = true,	-- SEDUCTION
	[SpellName(30283)] = true,	-- SHADOWFURY
	[SpellName(603)] = true,	-- DOOM
	[SpellName(980)] = true,	-- AGONY
	[SpellName(146739)] = true,	-- CORRUPTION
	[SpellName(48181)] = true,	-- HAUNT
	[SpellName(348)] = true,	-- IMMOLATE
	[SpellName(30108)] = true,	-- UNSTABLE AFFLICTION
	-- WARRIOR
	[SpellName(5246)] = true,	-- INTIMIDATING SHOUT
	[SpellName(132168)] = true,	-- SHOCKWAVE
	[SpellName(115767)] = true,	-- DEEP WOUNDS
	-- RACIAL
	[SpellName(25046)] = true,	-- ARCANE TORRENT
	[SpellName(20549)] = true,	-- WAR STOMP
	[SpellName(107079)] = true,	-- QUAKING PALM
}

K.PlateBlacklist = {
	-- ARMY OF THE DEAD
	["Army of the Dead"] = true,
	-- WILD IMP
	["Wild Imp"] = true,
	-- HUNTER TRAP
	["Venomous Snake"] = true,
	["Viper"] = true,
	-- RAID
	["Liquid Obsidian"] = true,
	["Lava Parasites"] = true,
	-- GUNDRAK
	["Fanged Pit Viper"] = true,
}