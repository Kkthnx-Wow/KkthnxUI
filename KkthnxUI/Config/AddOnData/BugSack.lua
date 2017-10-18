local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = table.wipe

-- GLOBALS: BugSackDB, BugSackLDBIconDB

function K.LoadBugSackProfile()
	if BugSackDB then
		table_wipe(BugSackDB)
	end

	if BugSackLDBIconDB then
		table_wipe(BugSackLDBIconDB)
	end

	BugSackDB = {
		["fontSize"] = "GameFontHighlight",
		["auto"] = false,
		["soundMedia"] = "BugSack: Fatality",
		["mute"] = true,
		["chatframe"] = false,
	}

	BugSackLDBIconDB = {
		["hide"] = false,
	}
end