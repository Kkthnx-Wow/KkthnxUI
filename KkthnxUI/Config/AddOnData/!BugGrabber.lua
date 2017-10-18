local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = table.wipe

-- GLOBALS: BugGrabberDB

function K.LoadBugGrabberProfile()
	if BugGrabberDB then
		table_wipe(BugGrabberDB)
	end

	BugGrabberDB = {
		["stopnag"] = 50001,
		["throttle"] = true,
		["limit"] = 50,
		["errors"] = {},
		["save"] = false,
		["session"] = 1,
	}
end