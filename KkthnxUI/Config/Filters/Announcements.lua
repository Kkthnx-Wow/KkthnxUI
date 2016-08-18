local K, C, L, _ = select(2, ...):unpack()

--[[
	THE BEST WAY TO ADD OR DELETE SPELL IS TO GO AT WWW.WOWHEAD.COM, SEARCH FOR A SPELL.
	EXAMPLE: MISDIRECTION -> http://www.wowhead.com/spell=34477
	TAKE THE NUMBER ID AT THE END OF THE URL, AND ADD IT TO THE LIST
]]--

if C.Announcements.Spells == true then
	K.AnnounceSpells = {
		61999, -- RAISE ALLY
		20484, -- REBIRTH
		20707, -- SOULSTONE
		31821, -- AURA MASTERY
		633, -- LAY ON HANDS
		34477, -- MISDIRECTION
		57934, -- TRICKS OF THE TRADE
		19801, -- TRANQUILIZING SHOT
		2908, -- SOOTHE
		7328, -- REDEMPTION
	}
end

if C.Announcements.BadGear == true then
	K.AnnounceBadGear = {
		-- HEAD
		[1] = {
			88710,	-- NAT'S HAT
			33820,	-- WEATHER-BEATEN FISHING HAT
			19972,	-- LUCKY FISHING HAT
			46349,	-- CHEF'S HAT
		},
		-- NECK
		[2] = {
			32757,	-- BLESSED MEDALLION OF KARABOR
		},
		-- FEET
		[8] = {
			50287,	-- BOOTS OF THE BAY
			19969,	-- NAT PAGLE'S EXTREME ANGLIN' BOOTS
		},
		-- BACK
		[15] = {
			65360,	-- CLOAK OF COORDINATION (ALLIANCE)
			65274,	-- CLOAK OF COORDINATION (HORDE)
		},
		-- MAIN-HAND
		[16] = {
			44050,	-- MASTERCRAFT KALU'AK FISHING POLE
			19970,	-- ARCANITE FISHING POLE
			84660,	-- PANDAREN FISHING POLE
			84661,	-- DRAGON FISHING POLE
			45992,	-- JEWELED FISHING POLE
			45991,	-- BONE FISHING POLE
			116826,	-- DRAENIC FISHING POLE
			116825,	-- SAVAGE FISHING POLE
			86559,	-- FRYING PAN
		},
		-- OFF-HAND
		[17] = {
			86558,	-- ROLLING PIN
		},
	}
end

if C.Announcements.Toys == true then
	K.AnnounceToys = {
		[61031] = true, -- toy train set
		[49844] = true, -- DIREBREW'S REMOTE
	}
end

if C.Announcements.Feasts == true then
	K.AnnounceBots = {
		[22700] = true,	-- FIELD REPAIR BOT 74A
		[44389] = true,	-- FIELD REPAIR BOT 110G
		[54711] = true,	-- SCRAPBOT
		[67826] = true,	-- JEEVES
		[126459] = true, -- BLINGTRON 4000
		[161414] = true, -- BLINGTRON 5000
	}
end

if C.Announcements.Portals == true then
	K.AnnouncePortals = {
		-- ALLIANCE
		[10059] = true,	-- STORMWIND
		[11416] = true,	-- IRONFORGE
		[11419] = true,	-- DARNASSUS
		[32266] = true,	-- EXODAR
		[49360] = true,	-- THERAMORE
		[33691] = true,	-- SHATTRATH
		[88345] = true,	-- TOL BARAD
		[132620] = true, -- VALE OF ETERNAL Blossoms
		[176246] = true, -- STORMSHIELD
		-- HORDE
		[11417] = true,	-- ORGRIMMAR
		[11420] = true,	-- THUNDER BLUFF
		[11418] = true,	-- UNDERCITY
		[32267] = true,	-- SILVERMOON
		[49361] = true,	-- STONARD
		[35717] = true,	-- SHATTRATH
		[88346] = true,	-- TOL BARAD
		[132626] = true, -- VALE OF ETERNAL BLOSSOMS
		[176244] = true, -- WARSPEAR
		-- ALLIANCE/HORDE
		[53142] = true, -- DALARAN
		[120146] = true, -- ANCIENT DALARAN
	}
end