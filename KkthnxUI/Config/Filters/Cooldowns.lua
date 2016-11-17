local K, C, L = select(2, ...):unpack()

--[[
	The best way to add or delete spell is to go at www.wowhead.com, search for a spell.
	Example: Rebirth -> http://www.wowhead.com/spell=20484
	Take the number ID at the end of the URL, and add it to the list
]]

if C.RaidCD.Enable == true then
	K.RaidSpells = {
		-- Battle resurrection
		[20484] = 600,	-- Rebirth
		[61999] = 600,	-- Raise Ally
		[20707] = 600,	-- Soulstone
		[126393] = 600,	-- Eternal Guardian (Quilen)
		[159956] = 600,	-- Dust of Life (Moth)
		[159931] = 600,	-- Gift of Chi-Ji (Crane)
		-- Heroism
		[32182] = 300,	-- Heroism
		[2825] = 300,	-- Bloodlust
		[80353] = 300,	-- Time Warp
		[90355] = 300,	-- Ancient Hysteria (Core Hound)
		[160452] = 300,	-- Netherwinds (Nether Ray)
		-- Healing
		[633] = 600,	-- Lay on Hands
		[740] = 180,	-- Tranquility
		[115310] = 180,	-- Revival
		[64843] = 180,	-- Divine Hymn
		[108280] = 180,	-- Healing Tide Totem
		[15286] = 180,	-- Vampiric Embrace
		[108281] = 120,	-- Ancestral Guidance
		-- Defense
		[62618] = 180,	-- Power Word: Barrier
		[33206] = 180,	-- Pain Suppression
		[47788] = 180,	-- Guardian Spirit
		[31821] = 180,	-- Aura Mastery
		[98008] = 180,	-- Spirit Link Totem
		[97462] = 180,	-- Rallying Cry
		[88611] = 180,	-- Smoke Bomb
		[51052] = 120,	-- Anti-Magic Zone
		[116849] = 120,	-- Life Cocoon
		[6940] = 120,	-- Blessing of Sacrifice
		[114030] = 120,	-- Vigilance
		[102342] = 60,	-- Ironbark
		-- Other
		[106898] = 120,	-- Stampeding Roar
	}
end

if C.PulseCD.Enable == true then
	K.PulseIgnoredSpells = {
		--GetSpellInfo(6807),	-- Maul
		--GetSpellInfo(35395),	-- Crusader Strike
	}
end
