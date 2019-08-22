local K = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = _G.table.wipe

-- GLOBALS: CursorTrail_PlayerConfig

local CursorTrail_PlayerConfig = _G.CursorTrail_PlayerConfig

function K.LoadSkinnerProfile()
	if CursorTrail_PlayerConfig then
		table_wipe(CursorTrail_PlayerConfig)
	end

	_G.CursorTrail_PlayerConfig = {
		["UserOfsY"] = -1.6,
		["BaseOfsX"] = -0.3,
		["BaseOfsY"] = 4.3,
		["BaseStepY"] = 471,
		["ModelID"] = "spells\\lightningboltivus_missile.mdx",
		["UserScale"] = 0.4,
		["UserAlpha"] = 0.5,
		["UserOfsX"] = 1.8,
		["UserShowOnlyInCombat"] = false,
		["BaseStepX"] = 471,
		["BaseScale"] = 0.05,
	}
end