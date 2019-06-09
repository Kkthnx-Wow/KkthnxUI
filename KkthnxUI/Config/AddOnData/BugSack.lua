local K = unpack(select(2, ...))

local table_wipe = table.wipe

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