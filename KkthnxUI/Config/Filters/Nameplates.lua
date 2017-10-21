local K, C, L = unpack(select(2, ...))
if C["Nameplates"].Enable ~= true then return end

local _G = _G

local print = print
local GetSpellInfo = _G.GetSpellInfo

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: C_NamePlate, ShowUIPanel, GameTooltip, UnitAura, DebuffTypeColor

local function SpellName(id)
	local name, _, _, _, _, _, _, _, _ = GetSpellInfo(id)
	if not name then
		print("|cff3c9bedKkthnxUI:|r SpellID is not valid: "..id..". Please check for an updated version, if none exists report to KkthnxUI author.")
		return "Impale"
	else
		return name
	end
end

K.DebuffWhiteList = {
	-- Death Knight
	-- Helpful
	[SpellName(3714)] = true, -- path of frost
	[SpellName(57330)] = true, -- horn of winter
	-- Harmful
	[SpellName(130736)] = true, -- soul reaper
	[SpellName(191587)] = true, -- virulent plague
	[SpellName(194310)] = true, -- festering wound
	[SpellName(196782)] = true, -- outbreak
	[SpellName(43265)] = true, -- death and decay
	[SpellName(47476)] = true, -- Strangulate
	[SpellName(55078)] = true, -- blood plague
	[SpellName(55095)] = true, -- frost fever
	-- Control
	[SpellName(108194)] = true, -- asphyxiate stun
	[SpellName(207171)] = true, -- winter is coming
	[SpellName(221562)] = true, -- asphyxiate
	[SpellName(45524)] = true, -- chains of ice
	[SpellName(56222)] = true, -- dark command

	-- DemonHunter
	-- Self
	[SpellName(218256)] = true, -- empower wards
	[SpellName(203819)] = true, -- demon spikes
	[SpellName(187827)] = true, -- metamorphosis (vengeance)
	[SpellName(212800)] = true, -- blur
	[SpellName(196555)] = true, -- netherwalk
	-- Helpful
	[SpellName(209426)] = true, -- darkness
	-- Harmful
	[SpellName(207744)] = true, -- fiery brand
	[SpellName(207771)] = true, -- fiery brand 2
	[SpellName(204598)] = true, -- sigil of flame
	[SpellName(204490)] = true, -- sigil of silence
	[SpellName(207407)] = true, -- soul carver
	[SpellName(224509)] = true, -- frail
	[SpellName(206491)] = true, -- nemesis
	[SpellName(207690)] = true, -- bloodlet
	[SpellName(213405)] = true, -- master of the glaive snare
	-- Control
	[SpellName(185245)] = true, -- torment taunt
	[SpellName(204843)] = true, -- sigil of chains
	[SpellName(207685)] = true, -- sigil of misery
	[SpellName(179057)] = true, -- chaos nova
	[SpellName(211881)] = true, -- fel eruption
	[SpellName(200166)] = true, -- metamorphosis stun
	[SpellName(198813)] = true, -- vengeful retreat
	[SpellName(217832)] = true, -- imprison

	-- Druid
	-- Self
	[SpellName(22842)] = true, -- frenzied regeneration
	[SpellName(192081)] = true, -- ironfur
	[SpellName(61336)] = true, -- survival instincts
	[SpellName(22812)] = true, -- barkskin
	-- [SpellName(192083)] = true, -- mark of ursol
	[SpellName(213680)] = true, -- guardian of elune
	-- Helpful
	[SpellName(774)] = true, -- rejuvenation
	[SpellName(8936)] = true, -- regrowth
	[SpellName(33763)] = true, -- lifebloom
	[SpellName(188550)] = true, -- lifebloom (HFC 4-set bonus)
	[SpellName(48438)] = true, -- wild growth
	[SpellName(102342)] = true, -- ironbark
	[SpellName(155777)] = true, -- rejuvenation (germination)
	[SpellName(102351)] = true, -- cenarion ward
	[SpellName(102352)] = true, -- cenarion ward proc
	[SpellName(77761)] = true, -- stampeding roar
	-- Harmful
	[SpellName(164812)] = true,	-- Moonfire
	[SpellName(164815)] = true,	-- Sunfire
	[SpellName(58180)] = true,	-- Infected Wounds
	[SpellName(155722)] = true,	-- Rake
	[SpellName(1079)] = true,	-- Rip
	[SpellName(1822)] = true, -- rake
	[SpellName(8921)] = true, -- moonfire
	[SpellName(155625)] = true, -- moonfire cat
	[SpellName(77758)] = true, -- bear thrash
	[SpellName(192090)] = true, -- bear thrash 7.0
	[SpellName(106830)] = true, -- cat thrash
	[SpellName(93402)] = true, -- sunfire
	[SpellName(202347)] = true, -- stellar flare
	[SpellName(197637)] = true, -- stellar empowerment
	-- Control
	[SpellName(102359)] = true, -- mass entanglement
	[SpellName(127797)] = true, -- ursols vortex
	[SpellName(22570)] = true, -- maim
	[SpellName(33786)] = true, -- cyclone
	[SpellName(339)] = true, -- entangling roots
	[SpellName(5211)] = true, -- mighty bash
	[SpellName(61391)] = true, -- typhoon daze
	[SpellName(6795)] = true, -- growl
	[SpellName(78675)] = true, -- solar beam silence
	[SpellName(81261)] = true, -- solar beam
	[SpellName(99)] = true, -- disorienting roar

	-- Hunter
	-- Self
	[SpellName(190931)] = true, -- mongoose fury
	[SpellName(186257)] = true, -- aspect of the cheetah 90%
	[SpellName(186258)] = true, -- aspect of the cheetah 30%
	[SpellName(186289)] = true, -- aspect of the eagle
	[SpellName(186265)] = true, -- aspect of the turtle
	-- Helpful
	[SpellName(34477)] = true, -- misdirection
	-- Harmful
	[SpellName(1130)] = true, -- hunter's arrow
	[SpellName(118253)] = true, -- serpent sting
	[SpellName(131894)] = true, -- murder by way of crow
	[SpellName(13812)] = true, -- explosive trap
	[SpellName(117405)] = true, -- binding shot
	[SpellName(187131)] = true, -- Vulnerable
	[SpellName(185855)] = true, -- lacerate
	[SpellName(194279)] = true,	-- Caltrops
	-- Control
	[SpellName(5116)] = true, -- concussive shot
	[SpellName(20736)] = true, -- distracting shot
	[SpellName(24394)] = true, -- intimidation
	[SpellName(64803)] = true, -- entrapment
	[SpellName(3355)] = true, -- freezing trap
	[SpellName(135299)] = true, -- ice trap
	[SpellName(136634)] = true, -- narrow escape
	[SpellName(19386)] = true, -- wyvern sting
	[SpellName(117526)] = true, -- binding shot stun
	[SpellName(120761)] = true, -- glaive toss slow
	[SpellName(121414)] = true, -- glaive toss slow 2
	[SpellName(190927)] = true, -- harpoon root
	[SpellName(195645)] = true, -- wing clip

	-- Mage
	-- Self
	[SpellName(108839)] = true, -- ice floes
	[SpellName(108843)] = true, -- blazing speed
	[SpellName(116014)] = true, -- rune of power
	[SpellName(116267)] = true, -- incanter's flow
	[SpellName(198924)] = true, -- quickening
	[SpellName(205766)] = true, -- bone chilling
	-- Helpful
	[SpellName(130)] = true, -- slow fall
	-- Harmful
	[SpellName(2120)] = true, -- flamestrike
	[SpellName(11366)] = true, -- pyroblast
	[SpellName(12654)] = true, -- ignite
	[SpellName(44457)] = true, -- living bomb
	[SpellName(112948)] = true, -- frost bomb
	[SpellName(114923)] = true, -- nether tempest
	[SpellName(157981)] = true, -- blast wave
	[SpellName(155158)] = true, -- meteor burn
	[SpellName(210134)] = true, -- erosion
	[SpellName(217694)] = true, -- living bomb
	[SpellName(226757)] = true, -- conflagration
	-- Control
	[SpellName(116)] = true, -- frostbolt debuff
	[SpellName(120)] = true, -- cone of cold
	[SpellName(122)] = true, -- frost nova
	[SpellName(31589)] = true, -- slow
	[SpellName(31661)] = true, -- dragon's breath
	[SpellName(82691)] = true, -- ring of frost
	[SpellName(157997)] = true, -- ice nova
	[SpellName(205708)] = true, -- chilled
	[SpellName(228354)] = true, -- flurry slow
	[SpellName(228600)] = true, -- glacial spike freeze
	-- Morphs
	[SpellName(118)] = true, -- polymorph
	[SpellName(28271)] = true, -- polymorph: turtle
	[SpellName(28272)] = true, -- polymorph: pig
	[SpellName(61305)] = true, -- polymorph: cat
	[SpellName(61721)] = true, -- polymorph: rabbit
	[SpellName(61780)] = true, -- polymorph: turkey
	[SpellName(126819)] = true, -- polymorph: pig
	[SpellName(161353)] = true, -- polymorph: bear cub
	[SpellName(161354)] = true, -- polymorph: monkey
	[SpellName(161355)] = true, -- polymorph: penguin
	[SpellName(161372)] = true, -- polymorph: turtle

	-- Monk
	-- Self
	[SpellName(116680)] = true, -- thunder focus tea
	[SpellName(116847)] = true, -- rushing jade wind
	[SpellName(119085)] = true, -- chi torpedo
	[SpellName(120954)] = true, -- fortifying brew
	[SpellName(122278)] = true, -- dampen harm
	[SpellName(122783)] = true, -- diffuse magic
	[SpellName(196725)] = true, -- refreshing jade wind
	[SpellName(215479)] = true, -- ironskin brew
	-- Helpful
	[SpellName(116841)] = true, -- tiger's lust
	[SpellName(116844)] = true, -- ring of peace
	[SpellName(116849)] = true, -- life cocoon
	[SpellName(119611)] = true, -- renewing mist
	[SpellName(124081)] = true, -- zen sphere
	[SpellName(124682)] = true, -- enveloping mist
	[SpellName(191840)] = true, -- essence font
	-- Harmful
	[SpellName(123725)] = true, -- breath of fire dot
	[SpellName(138130)] = true, -- storm, earth and fire 1
	[SpellName(196608)] = true, -- eye of the tiger
	[SpellName(115804)] = true, -- mortal wounds
	[SpellName(115080)] = true, -- touch of death
	-- Control
	[SpellName(116095)] = true, -- disable
	[SpellName(115078)] = true, -- paralysis
	[SpellName(116189)] = true, -- provoke taunt
	[SpellName(119381)] = true, -- leg sweep
	[SpellName(120086)] = true, -- fists of fury stun
	[SpellName(121253)] = true, -- keg smash slow
	[SpellName(122470)] = true, -- touch of karma
	[SpellName(198909)] = true, -- song of chi-ji

	-- Paladin
	-- Helpful
	[SpellName(184662)] = true, -- shield of vengeance
	[SpellName(114163)] = true, -- eternal flame
	[SpellName(53563)] = true, -- beacon of light
	[SpellName(156910)] = true, -- beacon of faith
	[SpellName(203538)] = true, -- greater blessing of kings
	[SpellName(203539)] = true, -- greater blessing of wisdom
	-- hand of...
	[SpellName(6940)] = true, -- sacrifice
	[SpellName(1044)] = true, -- freedom
	[SpellName(1022)] = true, -- protection
	-- Harmful
	[SpellName(26573)] = true, -- consecration
	[SpellName(197277)] = true, -- judgement
	[SpellName(183218)] = true, -- hand of hindrance
	-- Control
	[SpellName(853)] = true, -- hammer of justice
	[SpellName(20066)] = true, -- repentance
	[SpellName(31935)] = true, -- avenger's shield silence
	[SpellName(62124)] = true, -- reckoning taunt
	[SpellName(105421)] = true, -- blinding light

	-- Priest
	-- Helpful
	[SpellName(17)] = true, -- power word: shield
	[SpellName(81782)] = true, -- power word: barrier
	[SpellName(139)] = true, -- renew
	[SpellName(33206)] = true, -- pain suppression
	[SpellName(41635)] = true, -- prayer of mending buff
	[SpellName(47788)] = true, -- guardian spirit
	[SpellName(114908)] = true, -- spirit shell shield
	[SpellName(152118)] = true, -- clarity of will
	[SpellName(111759)] = true, -- levitate
	[SpellName(121557)] = true, -- angelic feather
	[SpellName(65081)] = true, -- body and soul
	[SpellName(214121)] = true, -- body and mind
	[SpellName(77489)] = true, -- echo of light
	[SpellName(64901)] = true, -- symbol of hope
	[SpellName(194384)] = true, -- attonement
	-- Harmful
	[SpellName(2096)] = true, -- mind vision
	[SpellName(589)] = true, -- shadow word: pain
	[SpellName(14914)] = true, -- holy fire
	[SpellName(34914)] = true, -- vampiric touch
	[SpellName(129250)] = true, -- power word: solace
	[SpellName(155361)] = true, -- void entropy
	[SpellName(204213)] = true, -- purge the wicked
	[SpellName(214621)] = true, -- schism
	[SpellName(217673)] = true, -- mind spike
	-- Control
	[SpellName(114404)] = true, -- void tendril root
	[SpellName(15487)] = true,	-- Silence
	[SpellName(200200)] = true, -- holy word: chastise
	[SpellName(204263)] = true, -- shining force
	[SpellName(205369)] = true, -- mind bomb
	[SpellName(605)] = true, -- dominate mind
	[SpellName(64044)] = true, -- psychic horror
	[SpellName(8122)] = true, -- psychic scream
	[SpellName(88625)] = true, -- holy word: chastise
	[SpellName(9484)] = true, -- shackle undead

	-- Rogue
	-- Self
	[SpellName(5171)] = true, -- slice and dice
	[SpellName(185311)] = true, -- crimson vial
	[SpellName(193538)] = true, -- alacrity
	[SpellName(193356)] = true, -- rtb: broadsides
	[SpellName(199600)] = true, -- rtb: buried treasure
	[SpellName(193358)] = true, -- rtb: grand melee
	[SpellName(199603)] = true, -- rtb: jolly roger
	[SpellName(193357)] = true, -- rtb: shark infested waters
	[SpellName(193359)] = true, -- rtb: true bearing
	-- Helpful
	[SpellName(57934)] = true, -- tricks of the trade
	-- Harmful
	[SpellName(137619)] = true, -- marked for death
	[SpellName(16511)] = true, -- hemorrhage
	[SpellName(192759)] = true, -- kingsbane
	[SpellName(1943)] = true, -- rupture
	[SpellName(195452)] = true, -- nightblade
	[SpellName(196937)] = true, -- ghostly strike
	[SpellName(200803)] = true, -- agonizing poison
	[SpellName(2818)] = true, -- deadly poison
	[SpellName(703)] = true, -- garrote
	[SpellName(79140)] = true, -- vendetta
	[SpellName(8680)] = true, -- wound poison
	-- Control
	[SpellName(408)] = true, -- kidney shot
	[SpellName(1330)] = true, -- garrote silence
	[SpellName(1776)] = true, -- gouge
	[SpellName(1833)] = true, -- cheap shot
	[SpellName(2094)] = true, -- blind
	[SpellName(6770)] = true, -- sap
	[SpellName(26679)] = true, -- deadly throw
	[SpellName(88611)] = true, -- smoke bomb
	[SpellName(3409)] = true, -- crippling poison
	[SpellName(115196)] = true, -- debilitating poison
	[SpellName(197395)] = true, -- finality: nightblade (snare)
	[SpellName(185763)] = true, -- pistol shot snare
	[SpellName(185778)] = true, -- cannonball barrage snare
	[SpellName(199804)] = true, -- between the eyes stun
	[SpellName(199740)] = true, -- bribe
	[SpellName(199743)] = true, -- parley

	-- Shaman
	-- Helpful
	[SpellName(546)] = true, -- water walking
	[SpellName(61295)] = true, -- riptide
	-- Harmful
	[SpellName(17364)] = true, -- stormstrike
	[SpellName(188389)] = true,	-- Flame Shock
	[SpellName(196840)] = true,	-- Frost Shock
	[SpellName(197209)] = true, -- lightning rod
	[SpellName(61882)] = true, -- earthquake
	-- Control
	[SpellName(116947)] = true, -- earthbind totem slow again
	[SpellName(118905)] = true, -- static charge
	[SpellName(3600)] = true, -- earthbind totem slow
	[SpellName(51490)] = true, -- thunderstorm slow
	[SpellName(51514)] = true, -- hex
	[SpellName(64695)] = true, -- earthgrab totem root
	[SpellName(77505)] = true, -- earthquake stun

	-- Warlock
	[SpellName(5697)] = true, -- unending breath
	[SpellName(20707)] = true, -- soulstone
	-- Harmful
	[SpellName(6789)] = true,	-- Mortal Coil
	[SpellName(6358)] = true,	-- Seduction
	[SpellName(980)] = true, -- agony
	[SpellName(603)] = true, -- doom
	[SpellName(172)] = true, -- corruption (demo version)
	[SpellName(146739)] = true, -- corruption
	[SpellName(348)] = true, -- immolate
	[SpellName(157736)] = true, -- immolate (green?)
	[SpellName(27243)] = true, -- immolate (green?)
	[SpellName(27243)] = true, -- seed of corruption
	[SpellName(30108)] = true, -- unstable affliction
	[SpellName(48181)] = true, -- haunt
	[SpellName(80240)] = true, -- havoc
	[SpellName(63106)] = true, -- siphon life
	-- Control
	[SpellName(710)] = true, -- banish
	[SpellName(1098)] = true, -- enslave demon
	[SpellName(5484)] = true, -- howl of terror
	[SpellName(5782)] = true, -- fear
	[SpellName(30283)] = true, -- shadowfury
	[SpellName(118699)] = true, -- fear (again)
	[SpellName(171018)] = true, -- meteor strike (abyssal stun)

	-- Warrior
	-- Self
	[SpellName(871)] = true, -- shield wall
	[SpellName(1719)] = true, -- battle cry
	[SpellName(12975)] = true, -- last stand
	[SpellName(18499)] = true, -- berserker rage
	[SpellName(23920)] = true, -- spell reflection
	[SpellName(107574)] = true, -- avatar
	[SpellName(114030)] = true, -- vigilance
	[SpellName(132404)] = true, -- shield block
	[SpellName(184362)] = true, -- enrage
	[SpellName(184364)] = true, -- enraged regeneration
	[SpellName(190456)] = true, -- ignore pain
	[SpellName(202539)] = true, -- frenzy
	[SpellName(202602)] = true, -- into the fray
	[SpellName(206333)] = true, -- taste for blood
	[SpellName(227744)] = true, -- ravager
	-- Helpful
	[SpellName(3411)] = true, -- intervene
	[SpellName(97463)] = true, -- commanding shout
	[SpellName(223658)] = true, -- safeguard
	-- Harmful
	[SpellName(167105)] = true, -- colossus smash again
	[SpellName(1160)] = true, -- demoralizing shout
	[SpellName(772)] = true, -- rend
	[SpellName(115767)] = true, -- deep wounds
	[SpellName(113344)] = true, -- bloodbath debuff
	-- Control
	[SpellName(355)] = true, -- taunt
	[SpellName(1715)] = true, -- hamstring
	[SpellName(5246)] = true, -- intimidating shout
	[SpellName(7922)] = true, -- charge stun
	[SpellName(12323)] = true, -- piercing howl
	[SpellName(107566)] = true, -- staggering shout
	[SpellName(132168)] = true, -- shockwave stun
	[SpellName(132169)] = true, -- storm bolt stun

	-- Global
	-- Control
	[SpellName(28730)] = true, -- arcane torrent/s
	[SpellName(25046)] = true,
	[SpellName(50613)] = true,
	[SpellName(69179)] = true,
	[SpellName(80483)] = true,
	[SpellName(129597)] = true,
	[SpellName(155145)] = true,
	[SpellName(20549)] = true, -- war stomp
	[SpellName(107079)] = true, -- quaking palm

	-- Buffs
	[SpellName(209859)] = true, -- Bolster
}

K.DebuffBlackList = {
	[SpellName(15407)] = true, -- Mind Flay
	[SpellName(146198)] = true, -- Essence of Yu'lon
}

K.PlateBlacklist = {
	-- Army of the Dead
	["Army of the Dead"] = true,
	-- Wild Imp
	["Wild Imp"] = true,
	-- Hunter Trap
	["Venomous Snake"] = true,
	["Viper"] = true,
	-- Raid
	["Liquid Obsidian"] = true,
	["Lava Parasites"] = true,
	-- Gundrak
	["Fanged Pit Viper"] = true,
}