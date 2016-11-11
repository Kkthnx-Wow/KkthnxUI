local K, C, L = select(2, ...):unpack()

--[[
if C.Nameplates.Enable ~= false then return end

local function SpellName(id)
	local name = GetSpellInfo(id)
	if name then
		return name
	else
		print("|cffff0000WARNING: spell ID ["..tostring(id).."] no longer exists! Report this to Kkthnx.|r")
		return "Empty"
	end
end

K.NameplatesWhitelist = {
	-- Death Knight
	-- Harmful
	[SpellName(47476)] = true, -- Strangulate
	[SpellName(43265)] = true, -- death and decay
	[SpellName(55095)] = true, -- frost fever
	[SpellName(55078)] = true, -- blood plague
	[SpellName(194310)] = true, -- festering wound
	[SpellName(196782)] = true, -- outbreak
	[SpellName(130736)] = true, -- soul reaper
	[SpellName(191587)] = true, -- virulent plague
	-- Control
	[SpellName(56222)] = true, -- dark command
	[SpellName(45524)] = true, -- chains of ice
	[SpellName(108194)] = true, -- Kkthnxte stun

	-- Demon Hunter
	-- Self
	[SpellName(218256)] = true, -- empower wards
	[SpellName(203819)] = true, -- demon spikes
	[SpellName(187827)] = true, -- metamorphosis (vengeance)
	[SpellName(212800)] = true, -- blur
	[SpellName(196555)] = true, -- netherwalk
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
	[SpellName(217932)] = true, -- imprison
	-- self
	[SpellName(218256)] = true, -- empower wards
	[SpellName(203819)] = true, -- demon spikes
	[SpellName(187827)] = true, -- metamorphosis (vengeance)
	[SpellName(212800)] = true, -- blur
	[SpellName(196555)] = true, -- net
	-- Helpful
	[SpellName(209426)] = true, -- darkness
	[SpellName(208628)] = true, -- darkness

	-- Druid
	-- Harmful
	[SpellName(164812)] = true,	-- Moonfire
	[SpellName(164815)] = true,	-- Sunfire
	[SpellName(58180)] = true,	-- Infected Wounds
	[SpellName(155722)] = true,	-- Rake
	[SpellName(1079)] = true,	-- Rip
	[SpellName(1822)] = true, -- rake
	[SpellName(8921)] = true, -- moonfire
	[SpellName(77758)] = true, -- bear thrash
	[SpellName(192090)] = true, -- bear thrash 7.0
	[SpellName(106830)] = true, -- cat thrash
	[SpellName(93402)] = true, -- sunfire
	[SpellName(202347)] = true, -- stellar flare
	-- Control
	[SpellName(339)] = true, -- entangling roots
	[SpellName(6795)] = true, -- growl
	[SpellName(22570)] = true, -- maim
	[SpellName(33786)] = true, -- cyclone
	[SpellName(78675)] = true, -- solar beam silence
	[SpellName(102359)] = true, -- mass entanglement
	[SpellName(99)] = true, -- disorienting roar
	[SpellName(5211)] = true, -- mighty bash
	[SpellName(61391)] = true, -- typhoon daze

	-- Hunter
	-- Harmful
	[SpellName(3355)] = true, -- Freezing Trap
	[SpellName(1130)] = true, -- hunter"s arrow
	[SpellName(118253)] = true, -- serpent sting
	[SpellName(131894)] = true, -- murder by way of crow
	[SpellName(13812)] = true, -- explosive trap
	[SpellName(117405)] = true, -- binding shot
	[SpellName(187131)] = true, -- Vulnerable
	[SpellName(185855)] = true, -- lacerate
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
	[SpellName(31661)] = true, -- dragon"s breath
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
	-- Harmful
	[SpellName(26573)] = true, -- consecration
	[SpellName(197277)] = true, -- judgement
	[SpellName(183218)] = true, -- hand of hindrance
	-- Control
	[SpellName(853)] = true, -- hammer of justice
	[SpellName(20066)] = true, -- repentance
	[SpellName(31935)] = true, -- avenger"s shield silence
	[SpellName(62124)] = true, -- reckoning taunt
	[SpellName(105421)] = true, -- blinding light

	-- Priest
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
	[SpellName(15487)] = true,	-- Silence
	[SpellName(605)] = true, -- dominate mind
	[SpellName(8122)] = true, -- psychic scream
	[SpellName(64044)] = true, -- psychic horror
	[SpellName(88625)] = true, -- holy word: chastise
	[SpellName(200200)] = true, -- holy word: chastise
	[SpellName(9484)] = true, -- shackle undead
	[SpellName(114404)] = true, -- void tendril root
	[SpellName(204263)] = true, -- shining force

	-- Rogue
	-- Harmful
	[SpellName(703)] = true, -- garrote
	[SpellName(1943)] = true, -- rupture
	[SpellName(16511)] = true, -- hemorrhage
	[SpellName(79140)] = true, -- vendetta
	[SpellName(2818)] = true, -- deadly poison
	[SpellName(8680)] = true, -- wound poison
	[SpellName(137619)] = true, -- marked for death
	[SpellName(195452)] = true, -- nightblade
	[SpellName(192759)] = true, -- kingsbane
	[SpellName(196937)] = true, -- ghostly strike
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
	-- Harmful
	[SpellName(196840)] = true,	-- Frost Shock
	[SpellName(188389)] = true,	-- Flame Shock
	[SpellName(17364)] = true, -- stormstrike
	[SpellName(61882)] = true, -- earthquake
	-- Control
	[SpellName(3600)] = true, -- earthbind totem slow
	[SpellName(116947)] = true, -- earthbind totem slow again
	[SpellName(64695)] = true, -- earthgrab totem root
	[SpellName(51514)] = true, -- hex
	[SpellName(77505)] = true, -- earthquake stun
	[SpellName(51490)] = true, -- thunderstorm slow

	-- Warlock
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
}

K.NameplateSelfWhitelist = {
	-- Druid
	-- Self
	[SpellName(22842)] = true, -- frenzied regeneration
	[SpellName(192081)] = true, -- ironfur
	[SpellName(61336)] = true, -- survival instincts
	[SpellName(22812)] = true, -- barkskin
	[SpellName(192083)] = true, -- mark of ursol
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

	-- Hunter
	-- Self
	[SpellName(190931)] = true, -- mongoose fury
	[SpellName(186257)] = true, -- aspect of the cheetah 90%
	[SpellName(186258)] = true, -- aspect of the cheetah 30%
	[SpellName(186289)] = true, -- aspect of the eagle
	[SpellName(186265)] = true, -- aspect of the turtle
	-- Helpful
	[SpellName(34477)] = true, -- misdirection

	-- Mage
	-- Self
	[SpellName(108839)] = true, -- ice floes
	[SpellName(108843)] = true, -- blazing speed
	[SpellName(116014)] = true, -- rune of power
	[SpellName(116267)] = true, -- incanter"s flow
	[SpellName(198924)] = true, -- quickening
	[SpellName(205766)] = true, -- bone chilling
	-- Helpful
	[SpellName(130)] = true, -- slow fall

	-- Deathknight
	-- Helpful
	[SpellName(3714)] = true, -- path of frost
	[SpellName(57330)] = true, -- horn of winter

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

	-- Paladin
	-- Helpful
	[SpellName(184662)] = true, -- shield of vengeance
	[SpellName(114163)] = true, -- eternal flame
	[SpellName(53563)] = true, -- beacon of light
	[SpellName(156910)] = true, -- beacon of faith

	[SpellName(203528)] = true, -- greater blessing of might
	[SpellName(203538)] = true, -- greater blessing of kings
	[SpellName(203539)] = true, -- greater blessing of wisdom

	-- hand of...
	[SpellName(6940)] = true, -- sacrifice
	[SpellName(1044)] = true, -- freedom
	[SpellName(1022)] = true, -- protection

	-- Warlock
	-- Helpful
	[SpellName(5697)] = true, -- unending breath
	[SpellName(20707)] = true, -- soulstone

	-- Shaman
	-- Helpful
	[SpellName(546)] = true, -- water walking
	[SpellName(61295)] = true, -- riptide

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
	[SpellName(116841)] = true, -- tiger"s lust
	[SpellName(116844)] = true, -- ring of peace
	[SpellName(116849)] = true, -- life cocoon
	[SpellName(119611)] = true, -- renewing mist
	[SpellName(124081)] = true, -- zen sphere
	[SpellName(124682)] = true, -- enveloping mist
	[SpellName(191840)] = true, -- essence font

	-- Demonhunter
	-- Self
	[SpellName(218256)] = true, -- empower wards
	[SpellName(203819)] = true, -- demon spikes
	[SpellName(187827)] = true, -- metamorphosis (vengeance)
	[SpellName(212800)] = true, -- blur
	[SpellName(196555)] = true, -- netherwalk
	-- Helpful
	[SpellName(209426)] = true, -- darkness
}

K.NameplateBlacklist = {
	-- [SpellName(spellID)] = true,	-- Spell Name
}

local _, ns = ...
local oUF = ns.oUF or oUF

SetCVar("nameplateShowAll", 1)
SetCVar("nameplateMaxAlpha", 0.5)
SetCVar("nameplateMaxDistance", 50)
SetCVar("nameplateShowEnemies", 1)
SetCVar("nameplateMinScale", 1)
SetCVar("nameplateLargerScale", 1)
SetCVar("nameplateOtherTopInset", -1) -- Default 0.08
SetCVar("nameplateOtherBottomInset", -1) -- Default 0.1

local function getcolor(unit)
	local reaction = UnitReaction(unit, "player") or 5

	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		local color = RAID_CLASS_COLORS[class]
		return color.r, color.g, color.b
	elseif UnitCanAttack("player", unit) then
		if UnitIsDead(unit) then
			return 136/255, 136/255, 136/255
		else
			if reaction < 4 then
				return unpack(K.Colors.reaction[1])
			elseif reaction == 4 then
				return unpack(K.Colors.reaction[4])
			end
		end
	else
		if reaction < 4 then
			return unpack(K.Colors.reaction[5])
		else
			return 255/255, 255/255, 255/255
		end
	end
end

local function threatColor(self, forced)
	if (UnitIsPlayer(self.unit)) then return end
	local healthbar = self.Health
	local combat = UnitAffectingCombat("player")
	local threat = select(2, UnitDetailedThreatSituation("player", self.unit))
	local targeted = select(1, UnitDetailedThreatSituation("player", self.unit))

	if (UnitIsTapDenied(self.unit)) then
		healthbar:SetStatusBarColor(.5, .5, .5)
	elseif (combat) then

		if (threat and threat >= 1) then
			if (threat == 3) then
				healthbar:SetStatusBarColor(unpack(K.Colors.reaction[1]))
			elseif (threat == 2 or threat == 1 or targeted) then
				healthbar:SetStatusBarColor(unpack(K.Colors.reaction[5]))
			end
		else
			healthbar:SetStatusBarColor(112/255, 51/255, 112/255)
		end
	elseif (not forced) then
		self.Health:ForceUpdate()
	end
end

local function callback(event,nameplate,unit)
	local unit = unit or "target"
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local self = nameplate.ouf

	if (UnitIsUnit(unit, "player")) then
		self.Name:Hide()
		self.Power:Show()
		self.Castbar:Hide()
		self.Level:Hide()
	else
		self.Name:Show()
		self.Power:Hide()
		self.Castbar:Show()
	end
end

local function style(self,unit)
	local Nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local main = self
	Nameplate.ouf = self
	self.unit = unit
	self:SetScript("OnEnter", function()
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetUnit(self.unit)
		GameTooltip:Show()
	end)
	self:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	self:SetPoint("CENTER", Nameplate, "CENTER")
	self:SetScale(K.NoScaleMult)
	self:SetSize(C.Nameplates.Width, C.Nameplates.Height)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(C.Media.Texture)
	self.Health:SetAllPoints(self)
	self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.colorHealth = true
	K.CreateShadowFrame(self.Health)

	self.Name = self:CreateFontString(nil)
	self.Name:SetFont(C.Media.Font, 14)
	self.Name:SetShadowOffset(K.Mult, -K.Mult) -- Temp
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -3, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 3, 4)
	self:Tag(self.Name, "[KkthnxUI:Name]")

	self.Level = self:CreateFontString(nil)
	self.Level:SetFont(C.Media.Font, 14)
	self.Level:SetShadowOffset(K.Mult, -K.Mult) -- Temp
	self.Level:SetPoint("LEFT", self.Health, "RIGHT", 6, 0)
	self:Tag(self.Level, "[KkthnxUI:Level]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(C.Media.Texture)
	self.Power:ClearAllPoints()
	self.Power:SetFrameLevel(5)
	self.Power:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Power:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 12)
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	K.CreateShadowFrame(self.Power)

	self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")

	self.Health:SetScript("OnEvent",function()
		threatColor(main)
	end)
	function self.Health:PostUpdate()
		threatColor(main,true)
	end

	-- Absorb
	-- self.TotalAbsorb = CreateFrame("StatusBar", nil, self.Health)
	-- self.TotalAbsorb:SetAllPoints(self.Health)
	-- self.TotalAbsorb:SetStatusBarTexture(C.Media.Texture)
	-- self.TotalAbsorb:SetStatusBarColor(.1, .1, .1, .6)

	-- Raid Icon
	self.RaidIcon = self:CreateTexture(nil,nil,7)
	self.RaidIcon:SetSize(14, 14)
	self.RaidIcon:SetPoint("LEFT", self, "RIGHT", 6, 0)

	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 28)
	self.Auras:SetSize(C.Nameplates.Width, C.Nameplates.AurasSize)
	self.Auras:EnableMouse(false)
	self.Auras.size = C.Nameplates.AurasSize
	self.Auras.initialAnchor = "BOTTOMLEFT"
	self.Auras.spacing = 2
	self.Auras.num = 20
	self.Auras["growth-y = "UP"
	self.Auras["growth-x = "RIGHT"

	self.Auras.CustomFilter = function(icons, unit, name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, _, nameplateShowAll)
		local allow = false

		if (nameplateShowAll or (nameplateShowPersonal and caster == "player")) then
			allow = true
		end
		if (K.NameplateWhitelist and K.NameplateWhitelist[name]) then
			allow = true
		end
		if (K.NameplateSelfWhitelist and K.NameplateSelfWhitelist[name]) then
			allow = true
		end
		if (K.NameplateBlacklist and K.NameplateBlacklist[name]) then
			allow = false
		end

		return allow
	end

	self.Auras.PostUpdateIcon = function(Auras, unit, button)
		K.CreateShadowFrame(button)
		button.cd:GetRegions():SetAlpha(0)
		button:EnableMouse(false)
		button.icon:SetTexCoord(0.08, 0.9, 0.08, 0.9)
		button:SetHeight(C.Nameplates.AurasSize * .6)
	end

	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(C.Media.Texture)
	self.Castbar:SetStatusBarColor(.1, .4, .7, 1)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -12)
	K.CreateShadowFrame(self.Castbar)

	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFont(C.Media.Font, 11, "OUTLINE")
	self.Castbar.Text:SetJustifyH("RIGHT")
	self.Castbar.Text:SetPoint("CENTER", self.Castbar, "CENTER")

	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	self.Castbar.Icon:SetDrawLayer("ARTWORK")
	self.Castbar.Icon:SetSize(C.Nameplates.Height + 12, C.Nameplates.Height + 12)
	self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -4, 0)

	self.Castbar.bg = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.bg:SetSize(self.Castbar.Icon:GetSize())
	self.Castbar.bg:SetPoint("TOPLEFT", self.Castbar.Icon)
	self.Castbar.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon)
	K.CreateShadowFrame(self.Castbar.bg)

	self.Castbar.PostCastStart = function(self,unit, name, castid)
		local interrupt = select(9, UnitCastingInfo(unit))
		if (interrupt) then
			self.Icon:SetDesaturated(1)
			self:SetStatusBarColor(.7, .7, .7, 1)
		else
			self.Icon:SetDesaturated(false)
			self:SetStatusBarColor(.1, .4, .7, 1)
		end
	end

end

oUF:RegisterStyle("oUF_KkthnxPlates", style)
oUF:SpawnNamePlates("oUF_KkthnxPlates", "oUF_KkthnxPlates", callback)

--------------------------
-- NEW INSTALLER BELOW WIP
--------------------------
L_INSTALLATION_SKIPBUTTON = "Skip Process"

L_INSTALLATION_TITLE = "Welcome to %s version %s"
L_INSTALLATION_DESC1 = "This install process will help you learn some of the features in KkthnxUI has to offer and also prepare your user interface for usage."
L_INSTALLATION_DESC2 = "The in-game configuration menu can be accesses by typing the /acp command or by clicking the Control Panel button. Press the button below if you wish to skip the installation process."
L_INSTALLATION_DESC3 = "Please press the continue button to go onto the next step."

L_INSTALLATION_CVARS_TITLE = "CVars"
L_INSTALLATION_CVARS_DESC1 = "This part of the installation process sets up your World of Warcraft default options it is recommended you should do this step for everything to behave properly."
L_INSTALLATION_CVARS_DESC2 = "Please click the button below to setup your CVars."
L_INSTALLATION_CVARS_DESC3 = "Importance: |cff07d400High|r"
L_INSTALLATION_CVARS_BUTTON = "Setup CVars"

L_INSTALLATION_CHAT_TITLE = "Chat"
L_INSTALLATION_CHAT_DESC1 = "This part of the installation process sets up your chat windows names, positions and colors."
L_INSTALLATION_CHAT_DESC2 = "The chat windows function the same as Blizzard standard chat windows, you can right click the tabs and drag them around, rename, etc. Please click the button below to setup your chat windows."
L_INSTALLATION_CHAT_DESC3 = "Importance: |cffd3cf00Medium|r"
L_INSTALLATION_CHAT_BUTTON = "Setup Chat"

L_INSTALLATION_LAYOUT_TITLE = "Layout"
L_INSTALLATION_LAYOUT_DESC1 = "You can now choose what layout you wish to use based on your combat role."
L_INSTALLATION_LAYOUT_DESC2 = "This will change the layout of your unitframes and raidframes."
L_INSTALLATION_LAYOUT_DESC3 = "Importance: |cffd3cf00Medium|r"
L_INSTALLATION_LAYOUT_BUTTON = "Setup Layout"

L_INSTALLATION_COMPLETE_TITLE = "Installation complete"
L_INSTALLATION_COMPLETE_DESC1 = "You are now finished with the installation process. If you are in need of technical support please visit us at INSERT WEB"
L_INSTALLATION_COMPLETE_DESC2 = "Please click the button below so you can setup variables and ReloadUI."
L_INSTALLATION_COMPLETE_DESC3 = ""
L_INSTALLATION_COMPLETE_BUTTON = "Finished"

local format = string.format
local CreateFrame = CreateFrame
local SetCVar = SetCVar

local Installation_CurrentPage = 0
local Installation_MaxPage = 5

local Installation_FullStep, Installation_CurrentStep = 0, 0
local Installation_Index = 0
local Installation_Instructions = {}

K.Installation_ChatFrames = function()
	InstallationMessageFrame.Message = "Locales: Installation ChatFrames"
	InstallationMessageFrame:Show()

	-- Setting chat frames if using KkthnxUI chats.
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_OpenNewWindow(GENERAL)
	FCF_SetLocked(ChatFrame3, 1)
	FCF_DockFrame(ChatFrame3)
	FCF_OpenNewWindow(LOOT)
	FCF_SetLocked(ChatFrame4, 1)
	FCF_DockFrame(ChatFrame4)

	-- Setting chat frames
	if C.Chat.Enable == true and not IsAddOnLoaded("Prat-3.0") or IsAddOnLoaded("Chatter") then
		for i = 1, NUM_CHAT_WINDOWS do
			local Frame = _G["ChatFrame"..i]
			local ID = Frame:GetID()

			Frame:SetSize(C.Chat.Width, C.Chat.Height)

			-- Default width and height of chats
			SetChatWindowSavedDimensions(ID, K.Scale(C.Chat.Width), K.Scale(C.Chat.Height))

			-- Move general chat to bottom left
			if (ID == 1) then
				Frame:ClearAllPoints()
				Frame:SetPoint(unpack(C.Position.Chat))
			end

			-- Save new default position and dimension
			FCF_SavePositionAndDimensions(Frame)

			-- Set default font size
			FCF_SetChatWindowFontSize(nil, Frame, 12)

			if (ID == 1) then
				FCF_SetWindowName(Frame, "G, S & W")
			end

			if (ID == 2) then
				FCF_SetWindowName(Frame, "Log")
			end

			if (not Frame.isLocked) then
				FCF_SetLocked(Frame, 1)
			end
		end

		-- Set more chat groups
		ChatFrame_RemoveAllMessageGroups(ChatFrame1)
		ChatFrame_RemoveChannel(ChatFrame1, TRADE)
		ChatFrame_RemoveChannel(ChatFrame1, GENERAL)
		ChatFrame_RemoveChannel(ChatFrame1, L_CHAT_LOCALDEFENSE)
		ChatFrame_RemoveChannel(ChatFrame1, L_CHAT_GUILDRECRUITMENT)
		ChatFrame_RemoveChannel(ChatFrame1, L_CHAT_LOOKINGFORGROUP)
		ChatFrame_AddMessageGroup(ChatFrame1, "SAY")
		ChatFrame_AddMessageGroup(ChatFrame1, "EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
		ChatFrame_AddMessageGroup(ChatFrame1, "GUILD")
		ChatFrame_AddMessageGroup(ChatFrame1, "OFFICER")
		ChatFrame_AddMessageGroup(ChatFrame1, "GUILD_ACHIEVEMENT")
		ChatFrame_AddMessageGroup(ChatFrame1, "WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_SAY")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_YELL")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_EMOTE")
		ChatFrame_AddMessageGroup(ChatFrame1, "MONSTER_BOSS_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY")
		ChatFrame_AddMessageGroup(ChatFrame1, "PARTY_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "RAID_WARNING")
		ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT")
		ChatFrame_AddMessageGroup(ChatFrame1, "INSTANCE_CHAT_LEADER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_HORDE")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_ALLIANCE")
		ChatFrame_AddMessageGroup(ChatFrame1, "BG_NEUTRAL")
		ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
		ChatFrame_AddMessageGroup(ChatFrame1, "ERRORS")
		ChatFrame_AddMessageGroup(ChatFrame1, "AFK")
		ChatFrame_AddMessageGroup(ChatFrame1, "DND")
		ChatFrame_AddMessageGroup(ChatFrame1, "IGNORED")
		ChatFrame_AddMessageGroup(ChatFrame1, "ACHIEVEMENT")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_WHISPER")
		ChatFrame_AddMessageGroup(ChatFrame1, "BN_CONVERSATION")

		-- Setup the spam chat frame
		ChatFrame_RemoveAllMessageGroups(ChatFrame3)
		ChatFrame_AddChannel(ChatFrame3, TRADE)
		ChatFrame_AddChannel(ChatFrame3, GENERAL)
		ChatFrame_AddChannel(ChatFrame3, L_CHAT_LOCALDEFENSE)
		ChatFrame_AddChannel(ChatFrame3, L_CHAT_GUILDRECRUITMENT)
		ChatFrame_AddChannel(ChatFrame3, L_CHAT_LOOKINGFORGROUP)

		-- Setup the loot chat
		ChatFrame_RemoveAllMessageGroups(ChatFrame4)
		ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_XP_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_HONOR_GAIN")
		ChatFrame_AddMessageGroup(ChatFrame4, "COMBAT_FACTION_CHANGE")
		ChatFrame_AddMessageGroup(ChatFrame4, "LOOT")
		ChatFrame_AddMessageGroup(ChatFrame4, "MONEY")

		if (K.Name == "Pervie" or K.Name == "Aceer" or K.Name == "Kkthnxx" or K.Name == "Tatterdots") and (K.Realm == "Stormreaver") then
			SetCVar("scriptErrors", 1)
		end

		-- Enable class color automatically on login and each character without doing /configure each time.
		ToggleChatColorNamesByClassGroup(true, "SAY")
		ToggleChatColorNamesByClassGroup(true, "EMOTE")
		ToggleChatColorNamesByClassGroup(true, "YELL")
		ToggleChatColorNamesByClassGroup(true, "GUILD")
		ToggleChatColorNamesByClassGroup(true, "OFFICER")
		ToggleChatColorNamesByClassGroup(true, "GUILD_ACHIEVEMENT")
		ToggleChatColorNamesByClassGroup(true, "ACHIEVEMENT")
		ToggleChatColorNamesByClassGroup(true, "WHISPER")
		ToggleChatColorNamesByClassGroup(true, "PARTY")
		ToggleChatColorNamesByClassGroup(true, "PARTY_LEADER")
		ToggleChatColorNamesByClassGroup(true, "RAID")
		ToggleChatColorNamesByClassGroup(true, "RAID_LEADER")
		ToggleChatColorNamesByClassGroup(true, "RAID_WARNING")
		ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND")
		ToggleChatColorNamesByClassGroup(true, "BATTLEGROUND_LEADER")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL1")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL2")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL3")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL4")
		ToggleChatColorNamesByClassGroup(true, "CHANNEL5")
		ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT")
		ToggleChatColorNamesByClassGroup(true, "INSTANCE_CHAT_LEADER")

		DEFAULT_CHAT_FRAME:SetUserPlaced(true)
	end
end

K.Installation_RaidFrames = function()
	InstallationMessageFrame.Message = "Locales: Installation RaidFrames"
	InstallationMessageFrame:Show()

	-- DisableAddOn("Blizzard_CUFProfiles")
	-- DisableAddOn("Blizzard_CompactRaidFrames")
end

K.Installation_CVARs = function()
	InstallationMessageFrame.Message = "Locales: Installation CVARs"
	InstallationMessageFrame:Show()

	SetCVar("NamePlateHorizontalScale", 1)
	SetCVar("NamePlateVerticalScale", 1)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("WhisperMode", "inline")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("autoOpenLootHistory", 0)
	SetCVar("autoQuestProgress", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("buffDurations", 1)
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "im")
	SetCVar("countdownForCooldowns", 0)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("removeChatDelay", 1)
	SetCVar("screenshotQuality", 8)
	SetCVar("scriptErrors", 1)
	SetCVar("showArenaEnemyFrames", 0)
	SetCVar("showTutorials", 0)
	SetCVar("showVKeyCastbar", 1)
	SetCVar("spamFilter", 0)
	SetCVar("violenceLevel", 5)
end

K.Installation_Complete = function()
	K.DataTexts:Reset()

	-- aCoreCDB.General.IsInstalled = true

	if (GetCVarBool("Sound_EnableMusic")) then
		StopMusic()
	end

	ReloadUI()
end

K.Installation_ResetAll = function()
	InstallationFrame.NextButton:Disable()
	InstallationFrame.PreviousButton:Disable()
	InstallationFrame.RaidDPS:Hide()
	InstallationFrame.RaidHealing:Hide()
	InstallationFrame.Option1:Hide()
	InstallationFrame.Option1:SetScript("OnClick", nil)
	InstallationFrame.Option1:SetText("")
	InstallationFrame.SubTitle:SetText("")
	InstallationFrame.Desc1:SetText("")
	InstallationFrame.Desc2:SetText("")
	InstallationFrame.Desc3:SetText("")
end

K.Installation_SetPage = function(PageNumber)
	local R, G, B = K.ColorGradient(PageNumber, Installation_MaxPage, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)

	Installation_CurrentPage = PageNumber
	K.Installation_ResetAll()

	if (PageNumber == Installation_MaxPage) then
		InstallationFrame.NextButton:Disable()
	else
		InstallationFrame.NextButton:Enable()
	end

	if (PageNumber == 1) then
		InstallationFrame.PreviousButton:Disable()
	else
		InstallationFrame.PreviousButton:Enable()
	end

	if (PageNumber == 1) then
		InstallationFrame.SubTitle:SetText(format(L_INSTALLATION_TITLE, "KkthnxUI", K.Version))
		InstallationFrame.Desc1:SetText(L_INSTALLATION_DESC1)
		InstallationFrame.Desc2:SetText(L_INSTALLATION_DESC2)
		InstallationFrame.Desc3:SetText(L_INSTALLATION_DESC3)
		InstallationFrame.Option1:Show()
		InstallationFrame.Option1:SetScript("OnClick", K.Installation_Complete)
		InstallationFrame.Option1.Text:SetText(L_INSTALLATION_SKIPBUTTON)
	elseif (PageNumber == 2) then
		InstallationFrame.SubTitle:SetText(L_INSTALLATION_CVARS_TITLE)
		InstallationFrame.Desc1:SetText(L_INSTALLATION_CVARS_DESC1)
		InstallationFrame.Desc2:SetText(L_INSTALLATION_CVARS_DESC2)
		InstallationFrame.Desc3:SetText(L_INSTALLATION_CVARS_DESC3)
		InstallationFrame.Option1:Show()
		InstallationFrame.Option1:SetScript("OnClick", K.Installation_CVARs)
		InstallationFrame.Option1.Text:SetText(L_INSTALLATION_CVARS_BUTTON)
	elseif (PageNumber == 3) then
		InstallationFrame.SubTitle:SetText(L_INSTALLATION_CHAT_TITLE)
		InstallationFrame.Desc1:SetText(L_INSTALLATION_CHAT_DESC1)
		InstallationFrame.Desc2:SetText(L_INSTALLATION_CHAT_DESC2)
		InstallationFrame.Desc3:SetText(L_INSTALLATION_CHAT_DESC3)
		InstallationFrame.Option1:Show()
		InstallationFrame.Option1:SetScript("OnClick", K.Installation_ChatFrames)
		InstallationFrame.Option1.Text:SetText(L_INSTALLATION_CHAT_BUTTON)
	elseif (PageNumber == 4) then
		InstallationFrame.SubTitle:SetText(L_INSTALLATION_LAYOUT_TITLE)
		InstallationFrame.Desc1:SetText(L_INSTALLATION_LAYOUT_DESC1)
		InstallationFrame.Desc2:SetText(L_INSTALLATION_LAYOUT_DESC2)
		InstallationFrame.Desc3:SetText(L_INSTALLATION_LAYOUT_DESC3)
		InstallationFrame.RaidDPS:Show()
		InstallationFrame.RaidHealing:Show()
		InstallationFrame.Option1:Show()
		InstallationFrame.Option1:SetScript("OnClick", K.Installation_RaidFrames)
		InstallationFrame.Option1.Text:SetText(L_INSTALLATION_LAYOUT_BUTTON)
	elseif (PageNumber == 5) then
		InstallationFrame.SubTitle:SetText(L_INSTALLATION_COMPLETE_TITLE)
		InstallationFrame.Desc1:SetText(L_INSTALLATION_COMPLETE_DESC1)
		InstallationFrame.Desc2:SetText(L_INSTALLATION_COMPLETE_DESC2)
		InstallationFrame.Desc3:SetText(L_INSTALLATION_COMPLETE_DESC3)
		InstallationFrame.Option1:Show()
		InstallationFrame.Option1:SetScript("OnClick", K.Installation_Complete)
		InstallationFrame.Option1.Text:SetText(L_INSTALLATION_COMPLETE_BUTTON)
	end

	InstallationFrame.StatusBar.Anim:SetChange(PageNumber)
	InstallationFrame.StatusBar.Anim:Play()

	InstallationFrame.StatusBar.Anim2:SetChange(R, G, B)
	InstallationFrame.StatusBar.Anim2:Play()
end

K.Installation_NextPage = function()
	if (Installation_CurrentPage ~= Installation_MaxPage) then
		Installation_CurrentPage = Installation_CurrentPage + 1
		K.Installation_SetPage(Installation_CurrentPage)
	end
end

K.Installation_PreviousPage = function()
	if (Installation_CurrentPage ~= 1) then
		Installation_CurrentPage = Installation_CurrentPage - 1
		K.Installation_SetPage(Installation_CurrentPage)
	end
end

K.Installation_Run = function()
	if (not InstallationMessageFrame) then
		local InstallationMessageFrame = CreateFrame("Frame", "InstallationMessageFrame", UIParent)
		InstallationMessageFrame:SetPoint("TOP", 0, -100)
		InstallationMessageFrame:SetSize(418, 72)
		InstallationMessageFrame:Hide()

		InstallationMessageFrame:SetScript("OnShow", function(self)
			if (self.Message) then
				PlaySoundFile("Sound\\Interface\\LevelUp.wav")
				self.Text:SetText(self.Message)
				UIFrameFadeOut(self, 3.5, 1, 0)

				K.Delay(5, function()
					self:Hide()
				end)

				self.Message = nil

				if (InstallationMessageFrame.FirstShow == false) then
					if (GetCVarBool("Sound_EnableMusic")) then
						PlayMusic("Sound\\Music\\ZoneMusic\\DMF_L70ETC01.mp3")
					end

					InstallationMessageFrame.FirstShow = true
				end
			else
				self:Hide()
			end
		end)

		InstallationMessageFrame.FirstShow = false

		InstallationMessageFrame.Texture = InstallationMessageFrame:CreateTexture(nil, "BACKGROUND")
		InstallationMessageFrame.Texture:SetPoint("BOTTOM")
		InstallationMessageFrame.Texture:SetSize(326, 103)
		InstallationMessageFrame.Texture:SetTexture("Interface\\LevelUp\\LevelUpTex")
		InstallationMessageFrame.Texture:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
		InstallationMessageFrame.Texture:SetVertexColor(1, 1, 1, 0.6)

		InstallationMessageFrame.LineTop = InstallationMessageFrame:CreateTexture(nil, "BACKGROUND")
		InstallationMessageFrame.LineTop:SetPoint("TOP")
		InstallationMessageFrame.LineTop:SetSize(418, 7)
		InstallationMessageFrame.LineTop:SetDrawLayer("BACKGROUND", 2)
		InstallationMessageFrame.LineTop:SetTexture("Interface\\LevelUp\\LevelUpTex")
		InstallationMessageFrame.LineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

		InstallationMessageFrame.LineBottom = InstallationMessageFrame:CreateTexture(nil, "BACKGROUND")
		InstallationMessageFrame.LineBottom:SetPoint("BOTTOM")
		InstallationMessageFrame.LineBottom:SetSize(418, 7)
		InstallationMessageFrame.LineBottom:SetDrawLayer("BACKGROUND", 2)
		InstallationMessageFrame.LineBottom:SetTexture("Interface\\LevelUp\\LevelUpTex")
		InstallationMessageFrame.LineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

		InstallationMessageFrame.Text = InstallationMessageFrame:CreateFontString(nil, "ARTWORK", "GameFont_Gigantic")
		InstallationMessageFrame.Text:SetPoint("BOTTOM", 0, 12)
		InstallationMessageFrame.Text:SetTextColor(1, 0.82, 0)
		InstallationMessageFrame.Text:SetJustifyH("CENTER")
	end

	if (not InstallationFrame) then
		local InstallationFrame = CreateFrame("Frame", "InstallationFrame", UIParent)
		InstallationFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		InstallationFrame:SetSize(500, 500)
		InstallationFrame:SetTemplate("Transparent")

		InstallationFrame.Subtitle = CreateFrame("Frame", nil, InstallationFrame)
		InstallationFrame.Subtitle:SetPoint("BOTTOM", InstallationFrame, "TOP", 0, -2)
		InstallationFrame.Subtitle:SetSize(InstallationFrame:GetWidth(), 28)
		InstallationFrame.Subtitle:SetTemplate("Transparent")

		InstallationFrame.Subtitle.Text = InstallationFrame.Subtitle:CreateFontString(nil, "OVERLAY")
		InstallationFrame.Subtitle.Text:SetPoint("CENTER", InstallationFrame.Subtitle, "CENTER", 0, -1)
		InstallationFrame.Subtitle.Text:SetFont(C.Media.Font, 13, "OUTLINE")
		InstallationFrame.Subtitle.Text:SetText("Original author: |cff00AAFFKkthnx|r")

		InstallationFrame.Title = CreateFrame("Frame", nil, InstallationFrame)
		InstallationFrame.Title:SetPoint("BOTTOM", InstallationFrame.Subtitle, "TOP", 0, 0)
		InstallationFrame.Title:SetSize(InstallationFrame:GetWidth() - 4, 28)
		InstallationFrame.Title:CreateBackdrop("Transparent")

		InstallationFrame.Title.Text = InstallationFrame.Title:CreateFontString(nil, "OVERLAY")
		InstallationFrame.Title.Text:SetPoint("CENTER", InstallationFrame.Title, "CENTER", 0, -1)
		InstallationFrame.Title.Text:SetFont(C.Media.Font, 16, "OUTLINE")
		InstallationFrame.Title.Text:SetText("|cff00AAFFKkthnxUI|r " .. K.Version .. " - |cffFF6347Installation|r")

		InstallationFrame.StatusBar = CreateFrame("StatusBar", nil, InstallationFrame)
		InstallationFrame.StatusBar:SetStatusBarTexture(C.Media.Texture)
		InstallationFrame.StatusBar:SetPoint("BOTTOM", InstallationFrame, "BOTTOM", 0, 65)
		InstallationFrame.StatusBar:SetSize(456, 25)
		InstallationFrame.StatusBar:SetFrameLevel(InstallationFrame.StatusBar:GetFrameLevel() + 2)
		InstallationFrame.StatusBar:CreateBackdrop(size, 4)
		InstallationFrame.StatusBar:SetStatusBarColor(0.26, 1, 0.22)
		InstallationFrame.StatusBar:SetMinMaxValues(0, Installation_MaxPage)
		InstallationFrame.StatusBar:SetValue(0)

		InstallationFrame.StatusBar.Anim = CreateAnimationGroup(InstallationFrame.StatusBar):CreateAnimation("Progress")
		InstallationFrame.StatusBar.Anim:SetDuration(0.3)
		InstallationFrame.StatusBar.Anim:SetSmoothing("InOut")

		InstallationFrame.StatusBar.Anim2 = CreateAnimationGroup(InstallationFrame.StatusBar):CreateAnimation("Color")
		InstallationFrame.StatusBar.Anim2:SetDuration(0.3)
		InstallationFrame.StatusBar.Anim2:SetSmoothing("InOut")
		InstallationFrame.StatusBar.Anim2:SetColorType("StatusBar")

		InstallationFrame.PreviousButton = CreateFrame("Button", "InstallationFramePreviousButton", InstallationFrame)
		InstallationFrame.PreviousButton:SetPoint("BOTTOMLEFT", InstallationFrame, "BOTTOMLEFT", 20, 20)
		InstallationFrame.PreviousButton:SetSize(128, 23)
		InstallationFrame.PreviousButton:SkinButton("Button")
		InstallationFrame.PreviousButton:Disable()
		InstallationFrame.PreviousButton:SetScript("OnClick", K.Installation_PreviousPage)

		InstallationFrame.PreviousButton.Text = K.SetFontString(InstallationFrame.PreviousButton, C.Media.Font, 13, "OUTLINE", "CENTER")
		InstallationFrame.PreviousButton.Text:SetPoint("CENTER", InstallationFrame.PreviousButton, "CENTER", 0, 0)
		InstallationFrame.PreviousButton.Text:SetText(PREVIOUS)

		InstallationFrame.NextButton = CreateFrame("Button", "InstallationFrameNextButton", InstallationFrame)
		InstallationFrame.NextButton:SetPoint("BOTTOMRIGHT", InstallationFrame, "BOTTOMRIGHT", -20, 20)
		InstallationFrame.NextButton:SetSize(128, 23)
		InstallationFrame.NextButton:SkinButton("Button")
		InstallationFrame.NextButton:Disable()
		InstallationFrame.NextButton:SetScript("OnClick", K.Installation_NextPage)

		InstallationFrame.NextButton.Text = K.SetFontString(InstallationFrame.NextButton, C.Media.Font, 13, "OUTLINE", "CENTER")
		InstallationFrame.NextButton.Text:SetPoint("CENTER", InstallationFrame.NextButton, "CENTER", 0, 0)
		InstallationFrame.NextButton.Text:SetText(CONTINUE)

		InstallationFrame.Option1 = CreateFrame("Button", "InstallationFrameOption1Button", InstallationFrame)
		InstallationFrame.Option1:SetPoint("BOTTOM", InstallationFrame, "BOTTOM", 0, 20)
		InstallationFrame.Option1:SetSize(160, 23)
		InstallationFrame.Option1:SkinButton("Button")

		InstallationFrame.Option1.Text = K.SetFontString(InstallationFrame.Option1, C.Media.Font, 13, "OUTLINE", "CENTER")
		InstallationFrame.Option1.Text:SetPoint("CENTER", InstallationFrame.Option1, "CENTER", 0, 0)
		InstallationFrame.Option1.Text:SetText("")
		InstallationFrame.Option1:Hide()

		InstallationFrame.RaidDPS = CreateFrame("Button", nil, InstallationFrame)
		InstallationFrame.RaidDPS:SetPoint("BOTTOMLEFT", InstallationFrame, "BOTTOMLEFT", 20, 110)
		InstallationFrame.RaidDPS:SetSize(140, 23)
		InstallationFrame.RaidDPS:SkinButton("Button")
		InstallationFrame.RaidDPS:SetScript("OnClick", function()
			-- aCoreCDB["RaidFrames"]["RaidFrames_Layout = "DPS"
			K.Print("Blue", "RaidFrames set to DPS Layout")
		end)

		InstallationFrame.RaidDPS.Text = K.SetFontString(InstallationFrame.RaidDPS, C.Media.Font, 13, "OUTLINE", "CENTER")
		InstallationFrame.RaidDPS.Text:SetPoint("CENTER", InstallationFrame.RaidDPS, "CENTER", 0, 0)
		InstallationFrame.RaidDPS.Text:SetText("Tank/DPS")
		InstallationFrame.RaidDPS:Hide()

		InstallationFrame.RaidHealing = CreateFrame("Button", nil, InstallationFrame)
		InstallationFrame.RaidHealing:SetPoint("BOTTOMRIGHT", InstallationFrame, "BOTTOMRIGHT", -20, 110)
		InstallationFrame.RaidHealing:SetSize(140, 23)
		InstallationFrame.RaidHealing:SkinButton("Button")
		InstallationFrame.RaidHealing:SetScript("OnClick", function()
			-- aCoreCDB["RaidFrames"]["RaidFrames_Layout = "Healer"
			K.Print("Blue", "RaidFrames set to Healing Layout")
		end)

		InstallationFrame.RaidHealing.Text = K.SetFontString(InstallationFrame.RaidHealing, C.Media.Font, 13, "OUTLINE", "CENTER")
		InstallationFrame.RaidHealing.Text:SetPoint("CENTER", InstallationFrame.RaidHealing, "CENTER", 0, 0)
		InstallationFrame.RaidHealing.Text:SetText("Healing")
		InstallationFrame.RaidHealing:Hide()

		InstallationFrame.SubTitle = K.SetFontString(InstallationFrame, C.Media.Font, 15, "OUTLINE", "CENTER")
		InstallationFrame.SubTitle:SetPoint("TOP", InstallationFrame, "TOP", 0, -40)
		InstallationFrame.SubTitle:SetText("")

		InstallationFrame.Desc1 = K.SetFontString(InstallationFrame, C.Media.Font, 13, "OUTLINE", "LEFT")
		InstallationFrame.Desc1:SetPoint("TOPLEFT", InstallationFrame, "TOPLEFT", 20, -100)
		InstallationFrame.Desc1:SetWidth(InstallationFrame:GetWidth() - 40)
		InstallationFrame.Desc1:SetText("")

		InstallationFrame.Desc2 = K.SetFontString(InstallationFrame, C.Media.Font, 13, "OUTLINE", "LEFT")
		InstallationFrame.Desc2:SetPoint("TOPLEFT", InstallationFrame.Desc1, "BOTTOMLEFT", 0, -20)
		InstallationFrame.Desc2:SetWidth(InstallationFrame:GetWidth() - 40)
		InstallationFrame.Desc2:SetText("")

		InstallationFrame.Desc3 = K.SetFontString(InstallationFrame, C.Media.Font, 13, "OUTLINE", "LEFT")
		InstallationFrame.Desc3:SetPoint("TOPLEFT", InstallationFrame.Desc2, "BOTTOMLEFT", 0, -20)
		InstallationFrame.Desc3:SetWidth(InstallationFrame:GetWidth() - 40)
		InstallationFrame.Desc3:SetText("")

		InstallationFrame.CloseButton = CreateFrame("Button", "InstallCloseButton", InstallationFrame, "UIPanelCloseButton")
		InstallationFrame.CloseButton:SetPoint("TOPRIGHT", InstallationFrame, "TOPRIGHT", 0 ,0)
		InstallationFrame.CloseButton:SetScript("OnClick", function()
			InstallationFrame:Hide()
		end)
	end

	InstallationFrame:Show()
	K.Installation_NextPage()
end

K.Installation_Finish = function(Text, Subtext)
	local TextCoords = {
		TextLine = {0.00195313, 0.81835938, 0.00195313, 0.01562500},
		SubtextLine = {1, 0.996, 0.745},
		LineDelay = 0,
	}

	local ScriptFrame = LevelUpDisplay:GetScript("OnShow")
	LevelUpDisplay.type = LEVEL_UP_TYPE_SCENARIO
	LevelUpDisplay:SetScript("OnShow", nil)
	LevelUpDisplay:Show()

	LevelUpDisplay.scenarioFrame.level:SetText(Text)
	LevelUpDisplay.scenarioFrame.name:SetText(Subtext)
	LevelUpDisplay.scenarioFrame.description:SetText("")
	LevelUpDisplay:SetPoint("TOP", UIParent, "TOP", 0, -250)

	LevelUpDisplay.gLine:SetTexCoord(unpack(TextCoords.TextLine))
	LevelUpDisplay.gLine2:SetTexCoord(unpack(TextCoords.TextLine))
	LevelUpDisplay.gLine:SetVertexColor(unpack(TextCoords.SubtextLine))
	LevelUpDisplay.gLine2:SetVertexColor(unpack(TextCoords.SubtextLine))
	LevelUpDisplay.levelFrame.levelText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
	LevelUpDisplay.gLine.grow.anim1:SetStartDelay(TextCoords.LineDelay)
	LevelUpDisplay.gLine2.grow.anim1:SetStartDelay(TextCoords.LineDelay)
	LevelUpDisplay.blackBg.grow.anim1:SetStartDelay(TextCoords.LineDelay)

	LevelUpDisplay.scenarioFrame.newStage:Play()
	PlaySoundKitID(31749)

	LevelUpDisplay:SetScript("OnShow", ScriptFrame)
end

K.Installation_CreateInstruction = function(Parent, Button, Title, Text, Anchor)
	Installation_Index = Installation_Index + 1

	local Mark = CreateFrame("Button", nil, Parent)
	if (not Button) then
		Mark:SetPoint("CENTER", Parent, "CENTER", 0, 0)
	else
		Mark:SetPoint("CENTER", Button, "CENTER", 0, 0)
	end
	Mark:SetSize(40, 40)
	if (Title == "ActionBars") then
		Mark:SetParent(UIParent)
	end
	Mark:SetFrameStrata("FULLSCREEN")
	Mark:SetFrameLevel(2)

	local Frame = CreateFrame("Button", nil, Mark, "GlowBorderTemplate")
	Frame:SetAllPoints(Parent)
	Frame:SetFrameLevel(1)

	Mark:SetNormalTexture("Interface\\common\\help-i")
	Mark:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

	Mark:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, Anchor)
		GameTooltip:AddLine(Title)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(Text)

		GameTooltip:Show()
	end)

	Mark:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)

	Mark:SetScript("OnMouseDown", function(self)
		self:Hide()

		Installation_CurrentStep = Installation_CurrentStep + 1
		if (Installation_CurrentStep ~= Installation_FullStep) then
			ActionStatus_DisplayMessage(format("Tutorial: %s/%s completed", Installation_CurrentStep, Installation_FullStep), true)
		else
			K.Installation_Finish("Congratulations", "All the tutorials are completed")
			--	aCoreDB["General"]["IsGuided = true
		end
	end)

	Mark:Hide()

	table.insert(Installation_Instructions, Mark)
end

K.Installation_Instructions = function()
	K.Installation_CreateInstruction(ChatFrame1, nil, "ChatFrames", "Description", "ANCHOR_TOPLEFT")
	K.Installation_CreateInstruction(Minimap, nil, "Minimap", "Description", "ANCHOR_BOTTOM")

	Installation_FullStep = Installation_Index
	Installation_CurrentStep = 0

	for index = 1, #Installation_Instructions do
		if (index == 1) then
			Installation_Instructions[index]:Show()
		end

		if (index ~= #Installation_Instructions) then
			Installation_Instructions[index]:SetScript("OnHide", function()
				Installation_Instructions[index + 1]:Show()
			end)
		end
	end
end

K.Installation_Reset = function()

end

local Frame = CreateFrame("Frame")
Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

function Frame:PLAYER_ENTERING_WORLD()

	if (KkthnxUIDataPerChar.Install ~= true) then
		K.Installation_Run()

		--KkthnxUIDataPerChar.Install = true
	end

	SLASH_CONFIGURE1 = "/installui"
	SlashCmdList.CONFIGURE = K.Installation_Run

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
--]]
