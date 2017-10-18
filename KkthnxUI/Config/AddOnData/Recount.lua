local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = table.wipe

-- Wow API
local RecountDB = _G.RecountDB

-- GLOBALS: Recount

function K.LoadRecountProfile()
	if RecountDB then
		table_wipe(RecountDB)
	end
	
	RecountDB["profiles"]["KkthnxUI"] = {
		["Colors"] = {
			["Other Windows"] = {
				["Title Text"] = {
					["g"] = 0.5,
					["b"] = 0,
				},
			},
			["Window"] = {
				["Title Text"] = {
					["g"] = 0.5,
					["b"] = 0,
				},
			},
			["Bar"] = {
				["Bar Text"] = {
					["a"] = 1,
				},
				["Total Bar"] = {
					["a"] = 1,
				},
			},
		},
		["DetailWindowY"] = 0,
		["DetailWindowX"] = 0,
		["GraphWindowX"] = 0,
		["Locked"] = true,
		["FrameStrata"] = "2-LOW",
		["BarTextColorSwap"] = true,
		["BarTexture"] = "KkthnxUI_StatusBar",
		["CurDataSet"] = "OverallData",
		["ClampToScreen"] = true,
		["Font"] = "KkthnxUI_Normal",
	}
	Recount.db:SetProfile("KkthnxUI")
end