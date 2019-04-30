
local _, ns = ...
local oUF = ns.oUF or oUF

ns.PortraitTimerDB = {
	-- Interrupts
	--[1766] = { type = "interrupts", duration = 5 }, -- Kick (Rogue)
	--[2139] = { type = "interrupts", duration = 6 }, -- Counterspell (Mage)
	--[6552] = { type = "interrupts", duration = 4 }, -- Pummel (Warrior)
	--[19647] = { type = "interrupts", duration = 6 }, -- Spell Lock (Warlock)
	--[47528] = { type = "interrupts", duration = 3 }, -- Mind Freeze (Death Knight)
	--[57994] = { type = "interrupts", duration = 3 }, -- Wind Shear (Shaman)
	--[91802] = { type = "interrupts", duration = 2 }, -- Shambling Rush (Death Knight)
	--[96231] = { type = "interrupts", duration = 4 }, -- Rebuke (Paladin)
	--[106839] = { type = "interrupts", duration = 4 }, -- Skull Bash (Feral)
	--[115781] = { type = "interrupts", duration = 6 }, -- Optical Blast (Warlock)
	--[116705] = { type = "interrupts", duration = 4 }, -- Spear Hand Strike (Monk)
	--[132409] = { type = "interrupts", duration = 6 }, -- Spell Lock (Warlock)
	--[147362] = { type = "interrupts", duration = 3 }, -- Countershot (Hunter)
	--[171138] = { type = "interrupts", duration = 6 }, -- Shadow Lock (Warlock)
	--[183752] = { type = "interrupts", duration = 3 }, -- Consume Magic (Demon Hunter)
	--[187707] = { type = "interrupts", duration = 3 }, -- Muzzle (Hunter)
	--[212619] = { type = "interrupts", duration = 6 }, -- Call Felhunter (Warlock)
	--[231665] = { type = "interrupts", duration = 3 }, -- Avengers Shield (Paladin)

	-- Death Knight
	[47476] = true, -- Strangulate
	[48707] = true, -- Anti-Magic Shell
	[48265] = true, -- Death's Advance
	[48792] = true, -- Icebound Fortitude
	[81256] = true, -- Dancing Rune Weapon
	[51271] = true, -- Pillar of Frost
	[55233] = true, -- Vampiric Blood
	[77606] = true, -- Dark Simulacrum
	[91797] =  true, -- Monstrous Blow
	[91800] =  true, -- Gnaw
	[108194] =  true, -- Asphyxiate
	[221562] =  true, -- Asphyxiate (Blood)
	[152279] =  true, -- Breath of Sindragosa
	[194679] =  true, -- Rune Tap
	[194844] =  true, -- Bonestorm
	[204080] =  true, -- Frostbite
	[206977] =  true, -- Blood Mirror
	[207127] =  true, -- Hungering Rune Weapon
	[207167] =  true, -- Blinding Sleet
	[207171] =  true, -- Winter is Coming
	[207256] =  true, -- Obliteration
	[207289] =  true, -- Unholy Frenzy
	[207319] =  true, -- Corpse Shield
	[212332] =  true, -- Smash
	[212337] = true, -- Powerful Smash
	[212552] =  true, -- Wraith Walk
	[219809] =  true, -- Tombstone
	[223929] = true, -- Necrotic Wound

	-- Demon Hunter
	[179057] =  true, -- Chaos Nova
	[187827] =  true, -- Metamorphosis
	[188499] =  true, -- Blade Dance
	[188501] =  true, -- Spectral Sight
	[204490] =  true, -- Sigil of Silence
	[205629] =  true, -- Demonic Trample
	[205630] =  true, -- Illidan's Grasp
	[206649] = true, -- Eye of Leotheras
	[207685] =  true, -- Sigil of Misery
	[207810] =  true, -- Nether Bond
	[211048] =  true, -- Chaos Blades
	[211881] =  true, -- Fel Eruption
	[212800] =  true, -- Blur		[196555] =  true, -- Netherwalk
	[218256] =  true, -- Empower Wards
	[221527] =  true, -- Imprison (Detainment Honor Talent)
	[217832] = true, -- Imprison (Baseline Undispellable)
	[227225] =  true, -- Soul Barrier

	-- Druid
	[99] =  true, -- Incapacitating Roar
	[339] =  true, -- Entangling Roots
	[740] =  true, -- Tranquility
	[1850] = true, -- Dash
	[252216] = true, -- Tiger Dash
	[2637] =  true, -- Hibernate
	[5211] =  true, -- Mighty Bash
	[5217] =  true, -- Tiger's Fury
	[22812] =  true, -- Barkskin
	[22842] =  true, -- Frenzied Regeneration
	[29166] =  true, -- Innervate
	[33891] =  true, -- Incarnation: Tree of Life
	[45334] =  true, -- Wild Charge
	[61336] =  true, -- Survival Instincts
	[81261] =  true, -- Solar Beam
	[102342] =  true, -- Ironbark
	[102359] =  true, -- Mass Entanglement
	[279642] =  true, -- Lively Spirit
	[102543] =  true, -- Incarnation: King of the Jungle
	[102558] =  true, -- Incarnation: Guardian of Ursoc
	[102560] =  true, -- Incarnation: Chosen of Elune
	[106951] =  true, -- Berserk
	[155835] =  true, -- Bristling Fur
	[192081] =  true, -- Ironfur
	[163505] =  true, -- Rake
	[194223] =  true, -- Celestial Alignment
	[200851] =  true, -- Rage of the Sleeper
	[202425] =  true, -- Warrior of Elune
	[204399] =  true, -- Earthfury
	[204437] =  true, -- Lightning Lasso

	[209749] =  true, -- Faerie Swarm (Slow/Disarm)
	[209753] = true, -- Cyclone
	[33786] = true, -- Cyclone
	[22570] =  true, -- Maim
	[203123] = true, -- Maim
	[236025] = true, -- Enraged Maim (Feral Honor Talent)
	[236696] =  true, -- Thorns (PvP Talent)

	-- Hunter
	[136] =  true, -- Mend Pet
	[3355] =  true, -- Freezing Trap
	[203340] =  true, -- Diamond Ice (Survival Honor Talent)
	[5384] =  true, -- Feign Death
	[19386] =  true, -- Wyvern Sting
	[19574] =  true, -- Bestial Wrath
	[19577] =  true, -- Intimidation
	[24394] = true, -- Intimidation
	[53480] =  true, -- Roar of Sacrifice (Hunter Pet Skill)
	[117526] =  true, -- Binding Shot
	[131894] =  true, -- A Murder of Crows (Beast Mastery, Marksmanship)
	[206505] = true, -- A Murder of Crows (Survival)
	[186265] =  true, -- Aspect of the Turtle
	[186289] =  true, -- Aspect of the Eagle
	[238559] =  true, -- Bursting Shot
	[186387] = true, -- Bursting Shot
	[193526] =  true, -- Trueshot
	[193530] =  true, -- Aspect of the Wild
	[199483] =  true, -- Camouflage
	[202914] =  true, -- Spider Sting (Armed)
	[202933] =  true, -- Spider Sting (Silenced)
	[233022] =  true, -- Spider Sting (Silenced)
	[209790] =  true, -- Freezing Arrow
	[209997] =  true, -- Play Dead
	[213691] =  true, -- Scatter Shot
	[272682] =  true, -- Master's Call

	-- Mage
	[66] =  true, -- Invisibility
	[110959] = true, -- Greater Invisibility
	[118] =  true, -- Polymorph
	[28271] =  true, -- Polymorph Turtle
	[28272] =  true, -- Polymorph Pig
	[61025] =  true, -- Polymorph Serpent
	[61305] =  true, -- Polymorph Black Cat
	[61721] =  true, -- Polymorph Rabbit
	[61780] =  true, -- Polymorph Turkey
	[126819] =  true, -- Polymorph Porcupine
	[161353] =  true, -- Polymorph Polar Bear Cub
	[161354] =  true, -- Polymorph Monkey
	[161355] =  true, -- Polymorph Penguin
	[161372] =  true, -- Polymorph Peacock
	[277787] =  true, -- Polymorph Direhorn
	[277792] =  true, -- Polymorph Bumblebee
	[122] =  true, -- Frost Nova
	[33395] = true, -- Freeze
	[11426] =  true, -- Ice Barrier
	[12042] =  true, -- Arcane Power
	[12051] =  true, -- Evocation
	[12472] =  true, -- Icy Veins
	[198144] = true, -- Ice Form
	[31661] =  true, -- Dragon's Breath
	[45438] =  true, -- Ice Block
	[41425] = true, -- Hypothermia
	[80353] =  true, -- Time Warp
	[82691] =  true, -- Ring of Frost
	[108839] =  true, -- Ice Floes
	[157997] =  true, -- Ice Nova
	[190319] =  true, -- Combustion
	[198111] =  true, -- Temporal Shield
	[198158] =  true, -- Mass Invisibility
	[198064] =  true, -- Prismatic Cloak
	[198065] = true, -- Prismatic Cloak
	[205025] =  true, -- Presence of Mind
	[228600] =  true, -- Glacial Spike Root

	-- Monk
	[115078] =  true, -- Paralysis
	[115080] =  true, -- Touch of Death
	[115203] =  true, -- Fortifying Brew (Brewmaster)
	[201318] = true, -- Fortifying Brew (Windwalker Honor Talent)
	[243435] = true, -- Fortifying Brew (Mistweaver)
	[116706] =  true, -- Disable
	[116849] =  true, -- Life Cocoon
	[119381] =  true, -- Leg Sweep
	[122278] =  true, -- Dampen Harm
	[122470] =  true, -- Touch of Karma
	[122783] =  true, -- Diffuse Magic
	[137639] =  true, -- Storm, Earth, and Fire
	[198909] =  true, -- Song of Chi-Ji
	[201325] =  true, -- Zen Meditation
	[115176] = true, -- Zen Meditation
	[202162] =  true, -- Guard
	[202274] =  true, -- Incendiary Brew
	[216113] =  true, -- Way of the Crane
	[232055] =  true, -- Fists of Fury
	[120086] = true, -- Fists of Fury
	[233759] =  true, -- Grapple Weapon

	-- Paladin
	[498] =  true, -- Divine Protection
	[642] =  true, -- Divine Shield
	[853] =  true, -- Hammer of Justice
	[1022] =  true, -- Blessing of Protection
	[204018] =  true, -- Blessing of Spellwarding
	[1044] =  true, -- Blessing of Freedom
	[6940] =  true, -- Blessing of Sacrifice
	[199448] = true, -- Blessing of Sacrifice (Ultimate Sacrifice Honor Talent)
	[20066] =  true, -- Repentance
	[31821] =  true, -- Aura Mastery
	[31850] =  true, -- Ardent Defender
	[31884] =  true, -- Avenging Wrath (Protection/Retribution)
	[31842] =  true, -- Avenging Wrath (Holy)
	[216331] =  true, -- Avenging Crusader (Holy Honor Talent)
	[231895] =  true, -- Crusade (Retribution Talent)
	[31935] =  true, -- Avenger's Shield
	[86659] =  true, -- Guardian of Ancient Kings
	[212641] =  true, -- Guardian of Ancient Kings (Glyphed)
	[228049] =  true, -- Guardian of the Forgotten Queen
	[105809] =  true, -- Holy Avenger
	[115750] =  true, -- Blinding Light
	[105421] =  true, -- Blinding Light
	[152262] =  true, -- Seraphim
	[184662] =  true, -- Shield of Vengeance
	[204150] =  true, -- Aegis of Light
	[205191] =  true, -- Eye for an Eye
	[210256] =  true, -- Blessing of Sanctuary
	[210294] =  true, -- Divine Favor
	[215652] =  true, -- Shield of Virtue

	-- Priest
	[586] =  true, -- Fade
	[213602] =  true, -- Greater Fade
	[605] = true, -- Mind Control
	[8122] =  true, -- Psychic Scream
	[9484] =  true, -- Shackle Undead
	[10060] =  true, -- Power Infusion
	[15487] =  true, -- Silence
	[199683] = true, -- Last Word
	[33206] =  true, -- Pain Suppression
	[47536] =  true, -- Rapture
	[47585] =  true, -- Dispersion
	[47788] =  true, -- Guardian Spirit
	[64044] =  true, -- Psychic Horror
	[64843] =  true, -- Divine Hymn
	[81782] =  true, -- Power Word: Barrier
	[271466] = true, -- Luminous Barrier (Disc Talent)
	[87204] =  true, -- Sin and Punishment
	[193223] =  true, -- Surrender to Madness
	[194249] =  true, -- Voidform
	[196762] =  true, -- Inner Focus
	[197268] =  true, -- Ray of Hope
	[197862] =  true, -- Archangel
	[197871] =  true, -- Dark Archangel
	[200183] =  true, -- Apotheosis
	[200196] =  true, -- Holy Word: Chastise
	[200200] = true, -- Holy Word: Chastise (Stun)
	[205369] =  true, -- Mind Bomb
	[226943] = true, -- Mind Bomb (Disorient)
	[213610] =  true, -- Holy Ward
	[215769] =  true, -- Spirit of Redemption
	[221660] =  true, -- Holy Concentration

	-- Rogue
	[408] =  true, -- Kidney Shot
	[1330] =  true, -- Garrote - Silence
	[1776] =  true, -- Gouge
	[1833] =  true, -- Cheap Shot
	[1966] =  true, -- Feint
	[2094] =  true, -- Blind
	[199743] = true, -- Parley
	[5277] =  true, -- Evasion
	[6770] =  true, -- Sap
	[13750] =  true, -- Adrenaline Rush
	[31224] =  true, -- Cloak of Shadows
	[51690] =  true, -- Killing Spree
	[79140] =  true, -- Vendetta
	[121471] =  true, -- Shadow Blades
	[199754] =  true, -- Riposte
	[199804] =  true, -- Between the Eyes
	[207736] =  true, -- Shadowy Duel
	[212183] =  true, -- Smoke Bomb

	-- Shaman
	[2825] =  true, -- Bloodlust
	[32182] = true, -- Heroism
	[51514] =  true, -- Hex
	[196932] =  true, -- Voodoo Totem
	[210873] =  true, -- Hex (Compy)
	[211004] =  true, -- Hex (Spider)
	[211010] =  true, -- Hex (Snake)
	[211015] =  true, -- Hex (Cockroach)
	[269352] =  true, -- Hex (Skeletal Hatchling)
	[277778] =  true, -- Hex (Zandalari Tendonripper)
	[277784] =  true, -- Hex (Wicker Mongrel)
	[79206] =  true, -- Spiritwalker's Grace 60 * OTHER
	[108281] =  true, -- Ancestral Guidance
	[16166] =  true, -- Elemental Mastery
	[64695] =  true, -- Earthgrab Totem
	[77505] =  true, -- Earthquake (Stun)
	[98008] =  true, -- Spirit Link Totem
	[108271] =  true, -- Astral Shift
	[210918] = true, -- Ethereal Form
	[114050] =  true, -- Ascendance (Elemental)
	[114051] =  true, -- Ascendance (Enhancement)
	[114052] =  true, -- Ascendance (Restoration)
	[118345] =  true, -- Pulverize
	[118905] =  true, -- Static Charge
	[197214] =  true, -- Sundering
	[204293] =  true, -- Spirit Link
	[204366] =  true, -- Thundercharge
	[204945] =  true, -- Doom Winds
	[260878] =  true, -- Spirit Wolf
	[8178] =  true, -- Grounding
	[255016] =  true, -- Grounding
	[204336] =  true, -- Grounding
	[34079] =  true, -- Grounding

	-- Warlock
	[710] =  true, -- Banish
	[5484] =  true, -- Howl of Terror
	[6358] =  true, -- Seduction
	[115268] = true, -- Mesmerize
	[6789] =  true, -- Mortal Coil
	[20707] =  true, -- Soulstone
	[22703] =  true, -- Infernal Awakening
	[30283] =  true, -- Shadowfury
	[89751] =  true, -- Felstorm
	[115831] = true, -- Wrathstorm
	[89766] =  true, -- Axe Toss
	[104773] =  true, -- Unending Resolve
	[108416] =  true, -- Dark Pact
	[113860] =  true, -- Dark Soul: Misery (Affliction)
	[113858] =  true, -- Dark Soul: Instability (Demonology)
	[118699] =  true, -- Fear
	[130616] = true, -- Fear (Glyph of Fear)
	[171017] =  true, -- Meteor Strike
	[196098] =  true, -- Soul Harvest
	[196364] =  true, -- Unstable Affliction (Silence)
	[212284] =  true, -- Firestone
	[212295] =  true, -- Nether Ward

	-- Warrior
	[871] =  true, -- Shield Wall
	[1719] =  true, -- Recklessness
	[5246] =  true, -- Intimidating Shout
	[12975] =  true, -- Last Stand
	[18499] = true, -- Berserker Rage
	[23920] =  true, -- Spell Reflection
	[213915] = true, -- Mass Spell Reflection
	[216890] = true, -- Spell Reflection (Arms, Fury)
	[46968] =  true, -- Shockwave
	[97462] =  true, -- Rallying Cry
	[105771] =  true, -- Charge (Warrior)
	[107574] =  true, -- Avatar
	[118038] =  true, -- Die by the Sword
	[132169] =  true, -- Storm Bolt
	[184364] =  true, -- Enraged Regeneration
	[197690] =  true, -- Defensive Stance
	[213871] =  true, -- Bodyguard
	[227847] =  true, -- Bladestorm (Arms)
	[46924] =  true, -- Bladestorm (Fury)
	[152277] =  true, -- Ravager
	[228920] =  true, -- Ravager
	[236077] =  true, -- Disarm
	[236236] = true, -- Disarm

	-- Other
	[20549] =  true, -- War Stomp
	[107079] =  true, -- Quaking Palm
	[129597] =  true, -- Arcane Torrent
	[25046] =  true, -- Arcane Torrent
	[28730] =  true, -- Arcane Torrent
	[50613] =  true, -- Arcane Torrent
	[69179] =  true, -- Arcane Torrent
	[80483] =  true, -- Arcane Torrent
	[155145] =  true, -- Arcane Torrent
	[202719] =  true, -- Arcane Torrent
	[202719] =  true, -- Arcane Torrent
	[232633] =  true, -- Arcane Torrent
	[192001] = true, -- Drink
	[167152] = true, -- Refreshment
	[256948] = true, -- Spatial Rift
	[255654] =  true, --Bull Rush
	[294127] =  true, -- Gladiator's Maledict

	-- [278736] = true, -- Debug DO NOT UNCOMMENT THIS
}

local Update = function(self, event, unit)
	if self.unit ~= unit or self.IsTargetFrame then
		return
	end

	local element = self.PortraitTimer
	local name, texture, _, _, duration, expirationTime, _, _, _, spellId
	local results

	for i = 1, 40 do
		name, texture, _, _, duration, expirationTime, _, _, _, spellId = UnitBuff(unit, i)

		if name then
			results = ns.PortraitTimerDB[spellId]

			if results then
				element.Icon:SetTexture(texture)
				CooldownFrame_Set(element.cooldownFrame, expirationTime - duration, duration, duration > 0)
				element:Show()

				if self.CombatFeedbackText then
					self.CombatFeedbackText.maxAlpha = 0
				end
				return
			end
		end
	end

	for i = 1, 40 do
		name, texture, _, _, duration, expirationTime, _, _, _, spellId = UnitDebuff(unit, i)

		if name then
			results = ns.PortraitTimerDB[spellId]

			if results then
				element.Icon:SetTexture(texture)
				CooldownFrame_Set(element.cooldownFrame, expirationTime - duration, duration, duration > 0)
				element:Show()

				if self.CombatFeedbackText then
					self.CombatFeedbackText.maxAlpha = 0
				end
				return
			end
		end
	end

	element:Hide()
	if self.CombatFeedbackText then
		self.CombatFeedbackText.maxAlpha = 1
	end

	if event == "PLAYER_ENTERING_WORLD" then
		CooldownFrame_Set(element.cooldownFrame, 1, 1, 1)
	end
end

local Enable = function(self)
	local element = self.PortraitTimer

	if element then
		self:RegisterEvent("UNIT_AURA", Update, false)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Update, true)

		if not element.Icon then
			local mask = element:CreateMaskTexture()
			mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
			mask:SetAllPoints(element)

			element.Icon = element:CreateTexture(nil, "BACKGROUND")
			element.Icon:SetAllPoints(element)
			element.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			--element.Icon:AddMaskTexture(mask)
		end

		if not element.cooldownFrame then
			element.cooldownFrame = CreateFrame("Cooldown", nil, element, "CooldownFrameTemplate")
			element.cooldownFrame:SetAllPoints(element)
			element.cooldownFrame:SetHideCountdownNumbers(false)
			element.cooldownFrame:SetDrawSwipe(false)
		end

		element:Hide()

		return true
	end
end

local Disable = function(self)
	local element = self.PortraitTimer
	if element then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("PortraitTimer", Update, Enable, Disable)
