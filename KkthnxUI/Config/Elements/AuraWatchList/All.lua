local K, _, L = unpack(KkthnxUI)
local Module = K:GetModule("AurasTable")

-- All occupational related monitoring
local list = {
	["Enchant Aura"] = { -- enchantment and trinket set
		{ AuraID = 341260, UnitID = "player", Flash = true }, -- Knowledge Burst, Heirloom Set
		{ AuraID = 354808, UnitID = "player" }, -- Prismatic Light, a 10,000 coin pet
		-- racial talent
		{ AuraID = 26297, UnitID = "player" }, -- Rampage Troll
		{ AuraID = 20572, UnitID = "player" }, -- Blood Rage Orc
		{ AuraID = 33697, UnitID = "player" }, -- Blood Fury Orc
		{ AuraID = 292463, UnitID = "player" }, -- Zandalar, Pa'ku's Embrace
		-- 9.0 Potion
		{ AuraID = 307159, UnitID = "player" }, -- Ghostly Agility Potion
		{ AuraID = 307162, UnitID = "player" }, -- Ghostly Intelligence Potion
		{ AuraID = 307163, UnitID = "player" }, -- Ghost Stamina Potion
		{ AuraID = 307164, UnitID = "player" }, -- Potion of Ghostly Power
		{ AuraID = 307494, UnitID = "player" }, -- Enhanced Exorcism Potion
		{ AuraID = 307495, UnitID = "player" }, -- Phantom Fire Potion
		{ AuraID = 307496, UnitID = "player" }, -- Holy Awakening Potion
		{ AuraID = 307497, UnitID = "player" }, -- Death Paranoid Potion
		{ AuraID = 344314, UnitID = "player" }, -- Potion of Speed ​​of Heart
		{ AuraID = 307195, UnitID = "player" }, -- Stealth Spirit Potion
		{ AuraID = 342890, UnitID = "player" }, -- Potion of Unrestrained Movement
		{ AuraID = 322302, UnitID = "player" }, -- Sacrifice Anima Potion
		{ AuraID = 307160, UnitID = "player" }, -- Hardened Shadow Potion
		-- 9.0 accessories
		{ AuraID = 344231, UnitID = "player" }, -- red wine
		{ AuraID = 345228, UnitID = "player" }, -- Gladiator badge
		{ AuraID = 344662, UnitID = "player" }, -- Shattered Mind
		{ AuraID = 345439, UnitID = "player" }, -- Crimson Waltz
		{ AuraID = 345019, UnitID = "player" }, -- lurking predator
		{ AuraID = 345530, UnitID = "player" }, -- overloaded anima battery
		{ AuraID = 345541, UnitID = "player" }, -- Sky Surge
		{ AuraID = 336588, UnitID = "player" }, -- Awakener's compound leaves
		{ AuraID = 348139, UnitID = "player" }, -- Master's Bell
		{ AuraID = 311444, UnitID = "player", Value = true }, -- Unyielding deck
		{ AuraID = 336465, UnitID = "player", Value = true }, -- Pulse Radiance Shield
		{ AuraID = 330366, UnitID = "player", Text = L["Crit"] }, -- incredible quantum device, critical strike
		{ AuraID = 330367, UnitID = "player", Text = L["Versa"] }, -- incredible quantum device, omnipotent
		{ AuraID = 330368, UnitID = "player", Text = L["Haste"] }, -- incredible quantum device, haste
		{ AuraID = 330380, UnitID = "player", Text = L["Mastery"] }, -- incredible quantum device, mastery
		{ AuraID = 351872, UnitID = "player" }, -- Iron Spike
		{ AuraID = 355316, UnitID = "player" }, -- Shield of Anhilde
		{ AuraID = 356326, UnitID = "player" }, -- Torment Insight
		{ AuraID = 355333, UnitID = "player" }, -- The recovered fusion amplifier
		{ AuraID = 357185, UnitID = "player" }, -- Loyal Power, Fragment of Whispering Power
		{ AuraID = 357773, UnitID = "player" }, -- Divine Mission, the handle of the Nine Valkyries
		{ AuraID = 165485, UnitID = "player" }, -- Kira's syringe
		{ AuraID = 165534, UnitID = "player" }, -- Executor's stun grenade
		{ AuraID = 230152, UnitID = "player" }, -- Command Eye

		{ AuraID = 367241, UnitID = "player" }, -- Primordial Sigil
		{ AuraID = 363522, UnitID = "player" }, -- Gladiator's Eternal Ward
		{ AuraID = 362699, UnitID = "player" }, -- Gladiator's Resolve
		{ AuraID = 345231, UnitID = "player" }, -- The gladiator's coat of arms
		{ AuraID = 368641, UnitID = "player" }, -- final rune
		-- Covenant
		{ AuraID = 331937, UnitID = "player", Flash = true }, -- intoxicated
		{ AuraID = 354053, UnitID = "player", Flash = true, Text = L["Crit"] }, -- fatal flaw, critical strike
		{ AuraID = 354054, UnitID = "player", Flash = true, Text = L["Versa"] }, -- fatal flaw, omnipotent
		{ AuraID = 323546, UnitID = "player" }, -- gluttonous frenzy
		{ AuraID = 326860, UnitID = "player" }, -- fallen monk
		{ AuraID = 310143, UnitID = "player", Combat = true }, -- soul shaper
		{ AuraID = 327104, UnitID = "player" }, -- Ghost Step
		{ AuraID = 327710, UnitID = "player" }, -- Good Deeds Dharma Night
		{ AuraID = 328933, UnitID = "player" }, -- Faye Suffering
		{ AuraID = 328281, UnitID = "player" }, -- Winter Blessing
		{ AuraID = 328282, UnitID = "player" }, -- Spring Blessing
		{ AuraID = 328620, UnitID = "player" }, -- Midsummer Blessing
		{ AuraID = 328622, UnitID = "player" }, -- Late Autumn Blessing
		{ AuraID = 324867, UnitID = "player", Value = true }, -- Flesh Forge
		{ AuraID = 328204, UnitID = "player" }, -- Hammer of the Conqueror
		{ AuraID = 325748, UnitID = "player" }, -- Cataclysm Swarm
		{ AuraID = 315443, UnitID = "player" }, -- Abomination Appendage
		{ AuraID = 325299, UnitID = "player" }, -- Slaughter Arrow
		{ AuraID = 327164, UnitID = "player" }, -- Tides of Origin
		{ AuraID = 325216, UnitID = "player" }, -- Bonedust Brew
		{ AuraID = 343672, UnitID = "player" }, -- Conqueror's Madness
		{ AuraID = 324220, UnitID = "player" }, -- body of death
		{ AuraID = 311648, UnitID = "player" }, -- Clouded Mist
		{ AuraID = 323558, UnitID = "player" }, -- reprimand echo 2
		{ AuraID = 323559, UnitID = "player" }, -- reprimand echo 3
		{ AuraID = 323560, UnitID = "player" }, -- reprimand echo 4
		{ AuraID = 338142, UnitID = "player" }, -- self-audit enhancement
		{ AuraID = 310454, UnitID = "player" }, -- orderly pawns
		{ AuraID = 325013, UnitID = "player" }, -- Gift of the Ascended
		{ AuraID = 308495, UnitID = "player" }, -- Resonating Arrow
		{ AuraID = 328908, UnitID = "player" }, -- combat meditation
		{ AuraID = 345499, UnitID = "player" }, -- Archon's Blessing
		{ AuraID = 339461, UnitID = "player" }, -- Hunter Toughness
		{ AuraID = 325381, UnitID = "player", Flash = true }, -- first strike
		{ AuraID = 351414, UnitID = "player", Flash = true }, -- Eye of the Meat Slicer
		{ AuraID = 342774, UnitID = "player" }, -- Bustling Wilderness
		{ AuraID = 333218, UnitID = "player" }, -- wasteland etiquette
		{ AuraID = 336885, UnitID = "player" }, -- soothe the shadow
		{ AuraID = 324156, UnitID = "player", Flash = true }, -- Plunder Shot
		--{AuraID = 328900, UnitID = "player"}, -- let go
		{ AuraID = 333961, UnitID = "player" }, -- Call to Action: Braum
		{ AuraID = 333943, UnitID = "player" }, -- Primal Hammer
		{ AuraID = 339928, UnitID = "player", Flash = true }, -- brutal projection
		{ AuraID = 358404, UnitID = "player", Flash = true }, -- Trial of Doubt
		{ AuraID = 352917, UnitID = "player" }, -- new determination
		{ AuraID = 356263, UnitID = "player" }, -- Pact of Soul Tracker
		{ AuraID = 352875, UnitID = "player", Flash = true }, -- Path of the Devout
		-- S2, Anima/Dominance Fragment
		{ AuraID = 357852, UnitID = "player" }, -- incentive
		{ AuraID = 356364, UnitID = "player" }, -- icy heart
		{ AuraID = 356043, UnitID = "player" }, -- all things
		-- Alchemy Stone
		{ AuraID = 60233, UnitID = "player" }, -- Agility
		{ AuraID = 60229, UnitID = "player" }, -- strength
		{ AuraID = 60234, UnitID = "player" }, -- intelligence
		-- WoD Orange Ring
		{ AuraID = 187616, UnitID = "player" }, -- Nisamus, intelligence
		{ AuraID = 187617, UnitID = "player" }, -- Sarktus, tank
		{ AuraID = 187618, UnitID = "player" }, -- Ysera Ruth, healer
		{ AuraID = 187619, UnitID = "player" }, -- Thorasus, power
		{ AuraID = 187620, UnitID = "player" }, -- Marus, Dexterity
		-- Heirloom jewelry
		{ AuraID = 201405, UnitID = "player" }, -- power
		{ AuraID = 201408, UnitID = "player" }, -- Agility
		{ AuraID = 201410, UnitID = "player" }, -- intelligence
		{ AuraID = 202052, UnitID = "player", Value = true }, -- tank
	},
	["Raid Buff"] = { -- Raid Buff Group
		{ AuraID = 54861, UnitID = "player" }, -- rocket boots, engineering
		-- bloodthirsty
		{ AuraID = 2825, UnitID = "player" }, -- bloodthirsty
		{ AuraID = 32182, UnitID = "player" }, -- heroic
		{ AuraID = 80353, UnitID = "player" }, -- time warp
		{ AuraID = 264667, UnitID = "player" }, -- Primal Fury
		{ AuraID = 178207, UnitID = "player" }, -- Drums of Fury
		{ AuraID = 230935, UnitID = "player" }, -- Alpine War Drum
		{ AuraID = 256740, UnitID = "player" }, -- Vortex Drum
		{ AuraID = 309658, UnitID = "player" }, -- Death Brutal War Drum
		{ AuraID = 102364, UnitID = "player" }, -- Bronze Dragon's Blessing
		{ AuraID = 292686, UnitID = "player" }, -- leather drum
		-- Team buffs or damage reductions
		{ AuraID = 1022, UnitID = "player" }, -- Blessing of Protection
		{ AuraID = 6940, UnitID = "player" }, -- Blessing of sacrifice
		{ AuraID = 1044, UnitID = "player" }, -- Blessing of Freedom
		{ AuraID = 10060, UnitID = "player" }, -- Power Infusion
		{ AuraID = 77761, UnitID = "player" }, -- Stampeding Roar
		{ AuraID = 77764, UnitID = "player" }, -- Stampeding Roar
		{ AuraID = 31821, UnitID = "player" }, -- Aura Mastery
		{ AuraID = 97463, UnitID = "player" }, -- command roar
		{ AuraID = 64843, UnitID = "player" }, -- Holy Hymn
		{ AuraID = 64901, UnitID = "player" }, -- symbol of hope
		{ AuraID = 81782, UnitID = "player" }, -- Power Word: Barrier
		{ AuraID = 29166, UnitID = "player" }, -- activate
		{ AuraID = 47788, UnitID = "player" }, -- Guardian Spirit
		{ AuraID = 33206, UnitID = "player" }, -- Pain Suppression
		{ AuraID = 53563, UnitID = "player" }, -- Beacon of Light
		{ AuraID = 98007, UnitID = "player" }, -- Soul Link Totem
		{ AuraID = 223658, UnitID = "player" }, -- defend
		{ AuraID = 115310, UnitID = "player" }, -- Five Qi return
		{ AuraID = 116849, UnitID = "player" }, -- cocoon life
		{ AuraID = 204018, UnitID = "player" }, -- curse-breaking blessing
		{ AuraID = 102342, UnitID = "player" }, -- Ironwood Bark
		{ AuraID = 145629, UnitID = "player" }, -- anti-magic realm
		{ AuraID = 156910, UnitID = "player" }, -- Beacon of Faith
		{ AuraID = 192082, UnitID = "player" }, -- Wind Totem
		{ AuraID = 201633, UnitID = "player" }, -- large totem
		{ AuraID = 207498, UnitID = "player" }, -- Ancestral Blessing
		{ AuraID = 238698, UnitID = "player" }, -- Vampire Aura
		{ AuraID = 209426, UnitID = "player" }, -- Phantom Strike
		{ AuraID = 114018, UnitID = "player", Flash = true }, -- Curtain
		{ AuraID = 115834, UnitID = "player", Flash = true },
	},
	["Raid Debuff"] = { -- raid debuff group
		-- Big Illusion
		{ AuraID = 311390, UnitID = "player" }, -- madness: insect phobia, vision
		{ AuraID = 306583, UnitID = "player" }, -- lead footsteps
		{ AuraID = 313698, UnitID = "player", Flash = true }, -- Gift of the Titan
		-- resident affixes
		{ AuraID = 366288, UnitID = "player" }, -- destructuring
		{ AuraID = 368239, UnitID = "player", Flash = true, Text = "CD" }, -- minus CD ciphertext
		{ AuraID = 368240, UnitID = "player", Flash = true, Text = L["Haste"] }, -- haste ciphertext
		{ AuraID = 368241, UnitID = "player", Flash = true, Text = L["Speed"] }, -- Speed ​​ciphertext
		{ AuraID = 358777, UnitID = "player" }, -- Chain of Pain
		{ AuraID = 355732, UnitID = "player" }, -- melt soul
		{ AuraID = 356667, UnitID = "player" }, -- Biting Chill
		{ AuraID = 356925, UnitID = "player" }, -- slaughter
		{ AuraID = 342466, UnitID = "player" }, -- brag, S1
		{ AuraID = 209858, UnitID = "player" }, -- gangrene fester
		{ AuraID = 240559, UnitID = "player" }, -- serious injury
		{ AuraID = 340880, UnitID = "player" }, -- arrogance
		{ AuraID = 226512, UnitID = "player", Flash = true }, -- blood pool
		{ AuraID = 240447, UnitID = "player", Flash = true }, -- trample
		{ AuraID = 240443, UnitID = "player", Flash = true }, -- burst
		-- 5 people
		{ AuraID = 327107, UnitID = "player" }, -- Crimson, shining bright
		{ AuraID = 340433, UnitID = "player" }, -- Crimson, Gift of Sin
		{ AuraID = 324092, UnitID = "player", Flash = true }, -- Crimson, shining bright
		{ AuraID = 328737, UnitID = "player", Flash = true }, -- Crimson, Shard of Light
		{ AuraID = 326891, UnitID = "player", Flash = true }, -- Hall of Atonement, Pain
		{ AuraID = 319603, UnitID = "player", Flash = true }, -- Hall of Atonement, Curse of Stone
		{ AuraID = 333299, UnitID = "player" }, -- Theater of the Dead, Curse of Desolation
		{ AuraID = 319637, UnitID = "player" }, -- The theater of the dead, the soul returns to the body
		{ AuraID = 330725, UnitID = "player", Flash = true }, -- Theater of the Dead, Shadow Vulnerable
		{ AuraID = 336258, UnitID = "player", Flash = true }, -- Death of the Wither, hunt alone
		{ AuraID = 331399, UnitID = "player" }, -- Wither, infected with poison rain
		{ AuraID = 333353, UnitID = "player" }, -- Wither's Wrath, Shadow Ambush
		{ AuraID = 327401, UnitID = "player", Flash = true }, -- psychic warfare, suffering together
		{ AuraID = 323471, UnitID = "player", Flash = true }, -- psychic war tide, meat cutting knife
		{ AuraID = 328181, UnitID = "player" }, -- The psychic war tide, the cold
		{ AuraID = 327397, UnitID = "player" }, -- Psychic Tide, Harsh Fate
		{ AuraID = 322681, UnitID = "player" }, -- Psychic Tide, Meat Hook
		{ AuraID = 335161, UnitID = "player" }, -- psychic war tide, remaining anima
		{ AuraID = 345323, UnitID = "player", Flash = true }, -- Psychic Tide, Gift of the Warrior
		{ AuraID = 320366, UnitID = "player", Flash = true }, -- Psychic Tide, Antiseptic
		{ AuraID = 322746, UnitID = "player" }, -- Otherworld, Blood of the Fallen
		{ AuraID = 323692, UnitID = "player" }, -- Otherworld, Arcane Vulnerability
		{ AuraID = 331379, UnitID = "player" }, -- otherworld, lubricant
		{ AuraID = 320786, UnitID = "player" }, -- The other world, unstoppable
		{ AuraID = 323687, UnitID = "player", Flash = true }, -- The Otherworld, Arcane Lightning
		{ AuraID = 327893, UnitID = "player", Flash = true }, -- Otherworld, Bwonsamdi's passion
		{ AuraID = 339978, UnitID = "player", Flash = true }, -- the other world, soothe the fog
		{ AuraID = 323569, UnitID = "player", Flash = true }, -- The other world, splashing soul
		{ AuraID = 334496, UnitID = "player", Stack = 7, Flash = true }, -- Otherworld, Hypnotic Powder
		{ AuraID = 328453, UnitID = "player" }, -- Promote the tower, oppress
		{ AuraID = 335805, UnitID = "player", Flash = true }, -- Promote the Tower, the Archon's Bulwark
		{ AuraID = 325027, UnitID = "player", Flash = true }, -- fairy forest, thorns burst
		{ AuraID = 356011, UnitID = "player" }, -- bazaar, ray slicer
		{ AuraID = 353421, UnitID = "player" }, -- bazaar, energy
		{ AuraID = 347949, UnitID = "player", Flash = true }, -- bazaar, interrogation
		{ AuraID = 355915, UnitID = "player" }, -- Bazaar, Glyph of Binding
		{ AuraID = 347771, UnitID = "player" }, -- bazaar, rush
		{ AuraID = 346962, UnitID = "player", Flash = true }, -- bazaar, cash remittance
		{ AuraID = 348567, UnitID = "player" }, -- fair, jazz
		{ AuraID = 349627, UnitID = "player" }, -- bazaar, gluttony
		{ AuraID = 350010, UnitID = "player", Flash = true }, -- Bazaar, Devoured Anima
		{ AuraID = 346828, UnitID = "player", Flash = true }, -- bazaar, disinfection area
		{ AuraID = 355581, UnitID = "player", Flash = true }, -- bazaar, burst
		{ AuraID = 346961, UnitID = "player", Flash = true }, -- Bazaar, place of purification
		{ AuraID = 347481, UnitID = "player" }, -- Bazaar, Aura Ripple
		{ AuraID = 350013, UnitID = "player" }, -- market, feast of gluttony
		{ AuraID = 350885, UnitID = "player" }, -- Market, shocks faster than light
		{ AuraID = 350804, UnitID = "player" }, -- bazaar, collapse energy
		{ AuraID = 349999, UnitID = "player" }, -- market, anima detonates
		{ AuraID = 359019, UnitID = "player", Flash = true }, -- Market, speed up stories
		{ AuraID = 173324, UnitID = "player", Flash = true }, -- pier, sawtooth bristle
		{ AuraID = 160681, UnitID = "player", Flash = true }, -- station, suppressing fire
		{ AuraID = 166676, UnitID = "player", Flash = true }, -- station, grenade blast
		{ AuraID = 291937, UnitID = "player", Flash = true }, -- Workshop, Junk Bunker
		{ AuraID = 230087, UnitID = "player", Flash = true }, -- Card on, cheer up
		-- group book
		{ AuraID = 342077, UnitID = "player" }, -- echolocation, growl
		{ AuraID = 329725, UnitID = "player" }, -- eradicate, destroyer
		{ AuraID = 329298, UnitID = "player" }, -- gluttony, destroyer
		{ AuraID = 325936, UnitID = "player" }, -- shared awareness, lord
		{ AuraID = 346035, UnitID = "player" }, -- Dazzling Footwork, Crimson Council
		{ AuraID = 331636, UnitID = "player", Flash = true }, -- Dark Dancer, Scarlet Council
		{ AuraID = 335293, UnitID = "player" }, -- Chain Link, Mud Fist
		{ AuraID = 333913, UnitID = "player" }, -- Chain Link, Mud Fist
		{ AuraID = 327039, UnitID = "player" }, -- Evil tear, go-getter
		{ AuraID = 344655, UnitID = "player" }, -- Concussion vulnerable, go-getter
		{ AuraID = 327089, UnitID = "player" }, -- feeding time, Denathius
		{ AuraID = 327796, UnitID = "player" }, -- Midnight Hunter, Denathius
		{ AuraID = 347283, UnitID = "player" }, -- Howl of the Predator, Tarraglu
		{ AuraID = 347286, UnitID = "player" }, -- Fear of the Undying, Tarraglu
		{ AuraID = 360403, UnitID = "player" }, -- force field, vigilant guard
		{ AuraID = 361751, UnitID = "player", Flash = true }, -- Decay Aura, Dawsy Garni
	},
	["Warning"] = { -- target important aura group
		{ AuraID = 355596, UnitID = "target", Flash = true }, -- orange bow, mourning arrow
		-- Big Illusion
		{ AuraID = 304975, UnitID = "target", Value = true }, -- Void Wailing, Absorb Shield
		{ AuraID = 319643, UnitID = "target", Value = true }, -- Void Wailing, Absorb Shield
		-- rice
		{ AuraID = 226510, UnitID = "target" }, -- blood pool recovery
		{ AuraID = 343502, UnitID = "target" }, -- Aura of Inspiration
		{ AuraID = 373724, UnitID = "target", Value = true }, -- S4, Blood Barrier
		-- 5 people
		{ AuraID = 321754, UnitID = "target", Value = true }, -- Psychic Tide, Icebound Shield
		{ AuraID = 343470, UnitID = "target", Value = true }, -- Psychic Tide, Bone Shattering Shield
		{ AuraID = 328351, UnitID = "target", Flash = true }, -- Psychic Tide, Bloody Spear
		{ AuraID = 322773, UnitID = "target", Value = true }, -- Otherworld, Blood Barrier
		{ AuraID = 333227, UnitID = "target", Flash = true }, -- The Other Realm, Undead Fury
		{ AuraID = 228626, UnitID = "target" }, -- Otherworld, the urn of the Wraith
		{ AuraID = 324010, UnitID = "target" }, -- otherworld, launch
		{ AuraID = 320132, UnitID = "target" }, -- Otherworld, Shadow Fury
		{ AuraID = 320293, UnitID = "target", Value = true }, -- The Theater of Sadness, blending into death
		{ AuraID = 331275, UnitID = "target", Flash = true }, -- Theater of Death, Guardian of the Undying
		{ AuraID = 336449, UnitID = "target" }, -- Wither, Tomb of Maldraxxus
		{ AuraID = 336451, UnitID = "target" }, -- Wither, Wall of Maldraxxus
		{ AuraID = 333737, UnitID = "target" }, -- wither, congealed disease
		{ AuraID = 328175, UnitID = "target" }, -- wither, congealed disease
		{ AuraID = 321368, UnitID = "target", Value = true }, -- Wither, Icebound Shield
		{ AuraID = 327416, UnitID = "target", Value = true }, -- promotion, anima recharge
		{ AuraID = 345561, UnitID = "target", Value = true }, -- promotion, life link
		{ AuraID = 339917, UnitID = "target", Value = true }, -- Promotion, Spear of Destiny
		{ AuraID = 323878, UnitID = "target", Flash = true }, -- promoted, exhausted
		{ AuraID = 317936, UnitID = "target" }, -- promotion, renunciation
		{ AuraID = 327812, UnitID = "target" }, -- promotion, boost heroism
		{ AuraID = 323149, UnitID = "target" }, -- Fairy Forest, Embrace of Darkness
		{ AuraID = 340191, UnitID = "target", Value = true }, -- Fairy Forest, Regenerating Radiance
		{ AuraID = 323059, UnitID = "target", Flash = true }, -- Xianlin, the wrath of the suzerain
		{ AuraID = 336499, UnitID = "target" }, -- Xianlin, guessing game
		{ AuraID = 322569, UnitID = "target" }, -- Fairy Forest, Hand of Zlos
		{ AuraID = 326771, UnitID = "target" }, -- Hall of Atonement, Rock Watcher
		{ AuraID = 326450, UnitID = "target" }, -- Hall of Atonement, Faithful Beast
		{ AuraID = 322433, UnitID = "target" }, -- Crimson Abyss, Stoneskin
		{ AuraID = 321402, UnitID = "target" }, -- Crimson abyss, full meal
		{ AuraID = 355640, UnitID = "target" }, -- bazaar, reload square
		{ AuraID = 355782, UnitID = "target" }, -- Bazaar, Power Amplifier
		{ AuraID = 351086, UnitID = "target" }, -- bazaar, unstoppable
		{ AuraID = 347840, UnitID = "target" }, -- bazaar, wild
		{ AuraID = 347992, UnitID = "target" }, -- bazaar, roundabout body armor
		{ AuraID = 347840, UnitID = "target" }, -- bazaar, wild
		{ AuraID = 347015, UnitID = "target", Flash = true }, -- market, fortified defense
		{ AuraID = 355934, UnitID = "target", Value = true }, -- bazaar, light barrier
		{ AuraID = 349933, UnitID = "target", Flash = true, Value = true }, -- Bazaar, Falcon Flogging Protocol
		{ AuraID = 229495, UnitID = "target" }, -- on the card, the king is vulnerable
		{ AuraID = 227548, UnitID = "target", Value = true }, -- on card, ablative shield
		{ AuraID = 227817, UnitID = "target", Value = true }, -- under the card, the shield
		{ AuraID = 163689, UnitID = "target", Value = true, Flash = true }, -- Iron Dock, Blood Red Orb
		-- group book
		{ AuraID = 345902, UnitID = "target" }, -- Broken Link, Hunter
		{ AuraID = 334695, UnitID = "target" }, -- Unstable energy, hunter
		{ AuraID = 346792, UnitID = "target" }, -- Sintouched Blade, Crimson Council
		{ AuraID = 331314, UnitID = "target" }, -- Destruction Blast, Mud Fist
		{ AuraID = 341250, UnitID = "target" }, -- Terror Rage, Mud Fist
		{ AuraID = 329636, UnitID = "target", Flash = true }, -- rock form, go-getter
		{ AuraID = 329808, UnitID = "target", Flash = true }, -- rock form, go-getter
		{ AuraID = 350857, UnitID = "target", Flash = true }, -- Banshee Cloak, Queen
		{ AuraID = 367573, UnitID = "target", Flash = true }, -- Primal Bulwark, Artifact
		{ AuraID = 368684, UnitID = "target", Value = true }, -- Recycle, Herrondos
		{ AuraID = 361651, UnitID = "target", Value = true }, -- Siphon Barrier, Dawsy Gonny
		{ AuraID = 362505, UnitID = "target", Flash = true }, -- Grip of Dominance, Anduin
		-- PvP
		{ AuraID = 498, UnitID = "target" }, -- Divine Protection
		{ AuraID = 642, UnitID = "target" }, -- Divine Shield
		{ AuraID = 871, UnitID = "target" }, -- shield wall
		{ AuraID = 5277, UnitID = "target" }, -- dodge
		{ AuraID = 1044, UnitID = "target" }, -- Blessing of Freedom
		{ AuraID = 6940, UnitID = "target" }, -- Blessing of sacrifice
		{ AuraID = 1022, UnitID = "target" }, -- Blessing of Protection
		{ AuraID = 19574, UnitID = "target" }, -- wild rage
		{ AuraID = 23920, UnitID = "target" }, -- Spell Reflection
		{ AuraID = 31884, UnitID = "target" }, -- Wrath of Vengeance
		{ AuraID = 33206, UnitID = "target" }, -- Pain Suppression
		{ AuraID = 45438, UnitID = "target" }, -- Ice Barrier
		{ AuraID = 47585, UnitID = "target" }, -- dissipate
		{ AuraID = 47788, UnitID = "target" }, -- Guardian Spirit
		{ AuraID = 48792, UnitID = "target" }, -- Frozen Fortitude
		{ AuraID = 48707, UnitID = "target" }, -- anti-magic shield
		{ AuraID = 61336, UnitID = "target" }, -- survival instinct
		{ AuraID = 197690, UnitID = "target" }, -- defensive stance
		{ AuraID = 147833, UnitID = "target" }, -- Aid
		{ AuraID = 186265, UnitID = "target" }, -- Guardian of the Turtle
		{ AuraID = 113862, UnitID = "target" }, -- enhanced invisibility
		{ AuraID = 118038, UnitID = "target" }, -- the sword is in the person
		{ AuraID = 114050, UnitID = "target" }, -- Ascension element
		{ AuraID = 114051, UnitID = "target" }, -- Ascension Enhancement
		{ AuraID = 114052, UnitID = "target" }, -- Ascension recovery
		{ AuraID = 204018, UnitID = "target" }, -- curse-breaking blessing
		{ AuraID = 205191, UnitID = "target" }, -- eye for eye punishment
		{ AuraID = 104773, UnitID = "target" }, -- Undying Resolve
		{ AuraID = 199754, UnitID = "target" }, -- fight back
		{ AuraID = 120954, UnitID = "target" }, -- Fortifying Brew
		{ AuraID = 122278, UnitID = "target" }, -- body is not bad
		{ AuraID = 122783, UnitID = "target" }, -- Dispel magic
		{ AuraID = 188499, UnitID = "target" }, -- Blade Dance
		{ AuraID = 210152, UnitID = "target" }, -- Blade Dance
		{ AuraID = 247938, UnitID = "target" }, -- Chaos Blade
		{ AuraID = 212800, UnitID = "target" }, -- Swift Shadow
		{ AuraID = 162264, UnitID = "target" }, -- Metamorphosis
		{ AuraID = 187827, UnitID = "target" }, -- Metamorphosis
		{ AuraID = 125174, UnitID = "target" }, -- Touch of Karma
		{ AuraID = 171607, UnitID = "target" }, -- Love Ray
		{ AuraID = 228323, UnitID = "target", Value = true }, -- Crota's shield
	},
	["InternalCD"] = { -- custom built-in cooldown group
		{ IntID = 240447, Duration = 20 }, -- rice, trample
		{ IntID = 352875, Duration = 30 }, -- Glenn, Path of the Devout
		{ IntID = 114018, Duration = 15, OnSuccess = true, UnitID = "all" }, -- Curtain
		{ IntID = 316958, Duration = 30, OnSuccess = true, UnitID = "all" }, -- red clay
		{ IntID = 327811, Duration = 19, OnSuccess = true, UnitID = "all" }, -- red corridor flash step
		{ IntID = 353635, Duration = 27.5, OnSuccess = true, UnitID = "all" }, -- Collapse star self-detonation time
	},
}

Module:AddNewAuraWatch("ALL", list)
