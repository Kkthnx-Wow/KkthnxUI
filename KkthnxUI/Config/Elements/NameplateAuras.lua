local _, C = unpack(KkthnxUI)

local _G = _G

C.NameplateWhiteList = {
	--Buffs
	[642] = true, -- Divine Shield
	[1022] = true, -- Hand of Protection
	[23920] = true, -- Spell Reflection
	[45438] = true, -- Ice Barrier
	[186265] = true, -- Guardian of the tortoise
	--Debuffs
	[2094] = true, -- blind
	[10326] = true, -- over evil
	[20549] = true, -- war trample
	[107079] = true, -- Shaking Mountain Palm
	[117405] = true, -- restraint shot
	[127797] = true, -- Ursol Whirlwind
	[272295] = true, -- bounty
	-- Mythic+
	[228318] = true, -- enrage
	[226510] = true, -- blood pool
	[343553] = true, -- The Grudge
	[343502] = true, -- Aura of Inspiration
	-- Dungeons
	[320293] = true, -- Sadness Theater, merge into death
	[331510] = true, -- The Theater of Sadness, Death Wish
	[333241] = true, -- Sad Theater, Grumpy
	[336449] = true, -- Death of the Wither, Tomb of Maldraxxus
	[336451] = true, -- Wither's Wrath, Wall of Maldraxxus
	[333737] = true, -- Death of the Wither, Sickness of Congealing
	[328175] = true, -- Death of the Wither, Sickness of Congealing
	[340357] = true, -- Death of the Wither, rapid infection
	[228626] = true, -- the other world, the urn of resentful spirits
	[344739] = true, -- the other world, the ghost
	[333227] = true, -- the other world, the wrath of the undead
	[326450] = true, -- Hall of Atonement, Faithful Beast
	[343558] = true, -- psychic wave, morbid gaze
	[343470] = true, -- Psychic Tide, Bone Shattering Shield
	[328351] = true, -- psychic war tide, blood-stained spear
	[322433] = true, -- Crimson Abyss, Stoneskin
	[321402] = true, -- red abyss, full meal
	[327416] = true, -- Promote the tower, recharge the heart
	[317936] = true, -- Promoted to the Tower, Abandoned Creed
	[327812] = true, -- Promote the tower and boost the heroic spirit
	[339917] = true, -- Promote the Tower, the Spear of Destiny
	[323149] = true, -- Immortal Forest, Embrace of Darkness
	[322569] = true, -- Fairy Forest, Hand of Zlos
	[355147] = true, -- market, fish encouragement
	[355057] = true, -- Bazaar, Murloc Battle Cry
	[351088] = true, -- Bazaar, Relic Link
	[355640] = true, -- fair, reload square
	[355783] = true, -- bazaar, power boost
	[347840] = true, -- fair, wild
	[347015] = true, -- market, fortified defense
	[355934] = true, -- fair, glare barrier
	[349933] = true, -- bazaar, fanatical flogging protocol
	[350931] = true, -- tower ooze immunity
	[164504] = true, -- Steel Dock, Intimidate
	[163689] = true, -- Iron Dock, Blood Red Orb
	[227548] = true, -- on card, ablative shield
	--S3, Encrypted
	[368078] = true, -- Drift Field
	[368103] = true, -- acceleration field
	[368243] = true, -- energy barrage
	--S4
	[373724] = true, -- blood barrier
	[373011] = true, -- disguise
	[373785] = true, -- Great Demon King disguise
	-- Raids
	[334695] = true, -- turbulent energy, hunter
	[345902] = true, -- Broken Link, Hunter
	[346792] = true, -- Sintouched Blade, Crimson Council
}

C.NameplateBlackList = {
	[15407] = true, -- Mind Flay
	[51714] = true, -- Frost of Sharpness
	[199721] = true, -- Rot Aura
	[214968] = true, -- Necronomicon Aura
	[214975] = true, -- Heart Suppression Aura
	[273977] = true, -- Grip of the Dead
	[276919] = true, -- under pressure
	[206930] = true, -- Heart Strike
}

C.NameplateCustomUnits = {
	[179823] = true, -- Relic Collector, Keshia
	[179565] = true, -- Relic glutton, Keshia
	[180501] = true, -- Innocent Soul, Fragment of Whispering Power
	-- Nzoth vision
	[153401] = true, -- K'thir Dominator
	[157610] = true, -- K'thir Dominator
	[156795] = true, -- MI7 informant
	-- Dungeons
	[120651] = true, -- rice, explosives
	[174773] = true, -- Rice, Maleficent Shadowfiend
	[184908] = true, -- rice, dimension dismantler
	[184910] = true, -- rice, wo-type dismantler
	[184911] = true, -- rice, the special type dismantler
	[190128] = true, -- Rice, Zulgamas
	[169498] = true, -- Wither's Death, Potion Bomb
	[170851] = true, -- Wither's Mourning, Explosive Potion Bomb
	[165556] = true, -- red abyss, instant representation
	[170234] = true, -- Theater of Sadness, suppressing the battle flag
	[164464] = true, -- Theater of Sadness, Despicable Sheila
	[165251] = true, -- Fairy Forest, Phantom Fairy Fox
	[171341] = true, -- other world, young crane
	[175576] = true, -- fair, jail
	[179733] = true, -- market, fish skewers
	[180433] = true, -- Bazaar, Wandering Pulsar
	[104251] = true, -- Court of the Stars, Sentinel
	[101008] = true, -- Black Rook Fortress, Needle Swarm
	-- Raids
	[175992] = true, -- Crimson Council, loyal servant
	[165762] = true, -- Kaizi, Psionic Infuser
	-- Condemned Demon
	[169430] = true,
	[169428] = true,
	[168932] = true,
	[169425] = true,
	[169429] = true,
	[169421] = true,
	[169426] = true,
}

C.NameplateShowPowerList = {
	[171557] = true, -- Hunter Aldymore, Shadow of Bagastre
	[165556] = true, -- red abyss, instant representation
	[163746] = true, -- Junkyard, Walking Shocker X1
	[114247] = true, -- on card, curator
}

-- Display the target of the name board unit
C.NameplateTargetNPCs = {
	[165251] = true, -- fairy forest fox
	[174773] = true, -- Malice
}

-- invalid target
C.NameplateTrashUnits = {
	[166589] = true, -- Living Weapon, Crimson
	[169753] = true, -- Hungry lice, red
	[175677] = true, -- smuggled creature, fair
	[190174] = true, -- Hypnotic Bat, S4
}

-- Important readings highlighted
C.MajorSpells = {
	[373513] = true, -- S4, Shadow Burst
	[294324] = true, -- workshop, super drill
	[297128] = true, -- workshop, short circuit
	[291613] = true, -- workshop, launch into space
	[300129] = true, -- junkyard, self-destruct protocol
	[300424] = true, -- junkyard, shockwave
	[300436] = true, -- Junkyard, Entanglement
	[301667] = true, -- junkyard, rapid fire
	[358967] = true, -- S2, Hellfire
	[373429] = true, -- S4, Carrion Swarm
	[334664] = true, -- the other world, howling in terror
	[332612] = true, -- Otherworld, Healing Wave
	[332706] = true, -- the other world, healing
	[334051] = true, -- the other world, spewing darkness
	[332084] = true, -- the other world, self-cleaning cycle
	[321828] = true, -- Xianlin, meatloaf cake
	[326046] = true, -- fairy forest, simulate resistance
	[326450] = true, -- Hall of Atonement, Faithful Beast
	[325700] = true, -- Hall of Atonement, collect sins
	[323552] = true, -- Hall of Atonement, Rain of Energy Arrows
	[341969] = true, -- Injury Theater, Wither Release
	[330586] = true, -- Injury Theater, Devouring Flesh
	[333294] = true, -- Theater of Injury, Wind of Death
	[330868] = true, -- wounded theater, psychic arrow rain
	[327413] = true, -- Promote the tower, the fist of resistance
	[317936] = true, -- Promoted to the Tower, Abandoned Creed
	[324293] = true, -- psychic war tide, ear-piercing scream
	[334748] = true, -- psychic war tide, draining body fluids
	[334749] = true, -- psychic war tide, draining body fluids
	[338357] = true, -- psychic war tide, violent beating
	[320596] = true, -- psychic war tide, heavy vomiting
	[326827] = true, -- Crimson Abyss, Binding of Fear
	[326831] = true, -- Crimson Abyss, Binding of Fear
	[327233] = true, -- wither, spray potion
	[324667] = true, -- wither, ooze tide
	[328400] = true, -- wither, stealth spiderling
}
