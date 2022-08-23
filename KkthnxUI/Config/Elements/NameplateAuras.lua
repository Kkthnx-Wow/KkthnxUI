local _, C = unpack(KkthnxUI)

local _G = _G

C.NameplateWhiteList = {
	--Buffs
	[1022] = true, -- Hand of Protection
	[186265] = true, -- Guardian of the tortoise
	[23920] = true, -- Spell Reflection
	[45438] = true, -- Ice Barrier
	[642] = true, -- Divine Shield
	--Debuffs
	[10326] = true, -- over evil
	[107079] = true, -- Shaking Mountain Palm
	[117405] = true, -- restraint shot
	[127797] = true, -- Ursol Whirlwind
	[20549] = true, -- war trample
	[2094] = true, -- blind
	[272295] = true, -- bounty
	-- Mythic+
	[226510] = true, -- blood pool
	[228318] = true, -- enrage
	[343502] = true, -- Aura of Inspiration
	[343553] = true, -- The Grudge
	-- Dungeons
	[163689] = true, -- Iron Dock, Blood Red Orb
	[164504] = true, -- Steel Dock, Intimidate
	[227548] = true, -- on card, ablative shield
	[228626] = true, -- the other world, the urn of resentful spirits
	[293724] = true, -- Workshop, Shield Generator
	[317936] = true, -- Promoted to the Tower, Abandoned Creed
	[320293] = true, -- Sadness Theater, merge into death
	[321402] = true, -- red abyss, full meal
	[322433] = true, -- Crimson Abyss, Stoneskin
	[322569] = true, -- Fairy Forest, Hand of Zlos
	[323149] = true, -- Immortal Forest, Embrace of Darkness
	[326450] = true, -- Hall of Atonement, Faithful Beast
	[327416] = true, -- Promote the tower, recharge the heart
	[327812] = true, -- Promote the tower and boost the heroic spirit
	[328175] = true, -- Death of the Wither, Sickness of Congealing
	[328351] = true, -- psychic war tide, blood-stained spear
	[331510] = true, -- The Theater of Sadness, Death Wish
	[333227] = true, -- the other world, the wrath of the undead
	[333241] = true, -- Sad Theater, Grumpy
	[333737] = true, -- Death of the Wither, Sickness of Congealing
	[336449] = true, -- Death of the Wither, Tomb of Maldraxxus
	[336451] = true, -- Wither's Wrath, Wall of Maldraxxus
	[339917] = true, -- Promote the Tower, the Spear of Destiny
	[340357] = true, -- Death of the Wither, rapid infection
	[343470] = true, -- Psychic Tide, Bone Shattering Shield
	[343558] = true, -- psychic wave, morbid gaze
	[344739] = true, -- the other world, the ghost
	[347015] = true, -- market, fortified defense
	[347840] = true, -- fair, wild
	[349933] = true, -- bazaar, fanatical flogging protocol
	[350931] = true, -- tower ooze immunity
	[351088] = true, -- Bazaar, Relic Link
	[355057] = true, -- Bazaar, Murloc Battle Cry
	[355147] = true, -- market, fish encouragement
	[355640] = true, -- fair, reload square
	[355783] = true, -- bazaar, power boost
	[355934] = true, -- fair, glare barrier
	--S3, Encrypted
	[368078] = true, -- Drift Field
	[368103] = true, -- acceleration field
	[368243] = true, -- energy barrage
	--S4
	[373011] = true, -- disguise
	[373724] = true, -- blood barrier
	[373785] = true, -- Great Demon King disguise
	-- Raids
	[334695] = true, -- turbulent energy, hunter
	[345902] = true, -- Broken Link, Hunter
	[346792] = true, -- Sintouched Blade, Crimson Council
}

C.NameplateBlackList = {
	[15407] = true, -- Mind Flay
	[199721] = true, -- Rot Aura
	[206930] = true, -- Heart Strike
	[214968] = true, -- Necronomicon Aura
	[214975] = true, -- Heart Suppression Aura
	[273977] = true, -- Grip of the Dead
	[276919] = true, -- under pressure
	[51714] = true, -- Frost of Sharpness
}

C.NameplateCustomUnits = {
	[179565] = true, -- Relic glutton, Keshia
	[179823] = true, -- Relic Collector, Keshia
	[180501] = true, -- Innocent Soul, Fragment of Whispering Power
	-- Nzoth vision
	[153401] = true, -- K'thir Dominator
	[156795] = true, -- MI7 informant
	[157610] = true, -- K'thir Dominator
	-- Dungeons
	[101008] = true, -- Black Rook Fortress, Needle Swarm
	[104251] = true, -- Court of the Stars, Sentinel
	[120651] = true, -- rice, explosives
	[164464] = true, -- Theater of Sadness, Despicable Sheila
	[165251] = true, -- Fairy Forest, Phantom Fairy Fox
	[165556] = true, -- red abyss, instant representation
	[169498] = true, -- Wither's Death, Potion Bomb
	[170234] = true, -- Theater of Sadness, suppressing the battle flag
	[170851] = true, -- Wither's Mourning, Explosive Potion Bomb
	[171341] = true, -- other world, young crane
	[174773] = true, -- Rice, Maleficent Shadowfiend
	[175576] = true, -- fair, jail
	[179733] = true, -- market, fish skewers
	[180433] = true, -- Bazaar, Wandering Pulsar
	[184908] = true, -- rice, dimension dismantler
	[184910] = true, -- rice, wo-type dismantler
	[184911] = true, -- rice, the special type dismantler
	[190128] = true, -- Rice, Zulgamas
	-- Raids
	[165762] = true, -- Kaizi, Psionic Infuser
	[175992] = true, -- Crimson Council, loyal servant
	-- Condemned Demon
	[168932] = true,
	[169421] = true,
	[169425] = true,
	[169426] = true,
	[169428] = true,
	[169429] = true,
	[169430] = true,
}

C.NameplateShowPowerList = {
	[114247] = true, -- on card, curator
	[163746] = true, -- Junkyard, Walking Shocker X1
	[165556] = true, -- red abyss, instant representation
	[171557] = true, -- Hunter Aldymore, Shadow of Bagastre
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
	[162058] = true, -- Station, Bone Spear
	[291613] = true, -- workshop, launch into space
	[293861] = true, -- Workshop, Anti-Infantry Squirrel
	[294324] = true, -- workshop, super drill
	[297128] = true, -- workshop, short circuit
	[298940] = true, -- Junkyard, Bolt Blasting
	[300129] = true, -- junkyard, self-destruct protocol
	[300424] = true, -- junkyard, shockwave
	[300436] = true, -- Junkyard, Entanglement
	[301667] = true, -- junkyard, rapid fire
	[317936] = true, -- Promoted to the Tower, Abandoned Creed
	[320596] = true, -- psychic war tide, heavy vomiting
	[321828] = true, -- Xianlin, meatloaf cake
	[323552] = true, -- Hall of Atonement, Rain of Energy Arrows
	[324293] = true, -- psychic war tide, ear-piercing scream
	[324667] = true, -- wither, ooze tide
	[325700] = true, -- Hall of Atonement, collect sins
	[326046] = true, -- fairy forest, simulate resistance
	[326450] = true, -- Hall of Atonement, Faithful Beast
	[326827] = true, -- Crimson Abyss, Binding of Fear
	[326831] = true, -- Crimson Abyss, Binding of Fear
	[327233] = true, -- wither, spray potion
	[327413] = true, -- Promote the tower, the fist of resistance
	[328400] = true, -- wither, stealth spiderling
	[330586] = true, -- Injury Theater, Devouring Flesh
	[330868] = true, -- wounded theater, psychic arrow rain
	[332084] = true, -- the other world, self-cleaning cycle
	[332612] = true, -- Otherworld, Healing Wave
	[332706] = true, -- the other world, healing
	[333294] = true, -- Theater of Injury, Wind of Death
	[334051] = true, -- the other world, spewing darkness
	[334664] = true, -- the other world, howling in terror
	[334748] = true, -- psychic war tide, draining body fluids
	[334749] = true, -- psychic war tide, draining body fluids
	[338357] = true, -- psychic war tide, violent beating
	[341969] = true, -- Injury Theater, Wither Release
	[358967] = true, -- S2, Hellfire
	[373429] = true, -- S4, Carrion Swarm
	[373513] = true, -- S4, Shadow Burst
}
