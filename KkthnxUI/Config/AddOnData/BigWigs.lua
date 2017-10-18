local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local print = print
local table_wipe = table.wipe

-- GLOBALS: BigWigs, LibStub, BigWigs3DB

function K.LoadBigWigsProfile()
	if BigWigs3DB then
		table_wipe(BigWigs3DB)
	end

	BigWigs3DB = {
		["namespaces"] = {
			["BigWigs_Plugins_Victory"] = {},
			["BigWigs_Plugins_Colors"] = {},
			["BigWigs_Plugins_Alt Power"] = {
				["profiles"] = {
					["KkthnxUI"] = {
						["posx"] = 339.84443097218,
						["fontSize"] = 11,
						["fontOutline"] = "",
						["font"] = "KkthnxUI_Normal",
						["lock"] = true,
						["posy"] = 61.8444405166224,
					},
				},
			},
			["BigWigs_Plugins_BossBlock"] = {},
			["BigWigs_Plugins_Bars"] = {
				["profiles"] = {
					["KkthnxUI"] = {
						["BigWigsEmphasizeAnchor_y"] = 274.777784431353,
						["fontSize"] = 11,
						["BigWigsAnchor_width"] = 239.999954223633,
						["BigWigsAnchor_y"] = 265.177697393337,
						["BigWigsEmphasizeAnchor_x"] = 251.977762177876,
						["barStyle"] = "KkthnxUI",
						["emphasizeGrowup"] = true,
						["BigWigsAnchor_x"] = 1018.51096216262,
						["outline"] = "OUTLINE",
						["BigWigsEmphasizeAnchor_width"] = 244.999984741211,
						["font"] = "KkthnxUI_Normal",
						["emphasizeScale"] = 1.1,
						["texture"] = "KkthnxUI_StatusBar",
					},
				},
			},
			["BigWigs_Plugins_Super Emphasize"] = {
				["profiles"] = {
					["KkthnxUI"] = {
						["font"] = "KkthnxUI_Normal",
					},
				},
			},
			["BigWigs_Plugins_Sounds"] = {},
			["BigWigs_Plugins_Messages"] = {
				["profiles"] = {
					["KkthnxUI"] = {
						["outline"] = "OUTLINE",
						["fontSize"] = 20,
						["BWEmphasizeCountdownMessageAnchor_x"] = 664,
						["BWMessageAnchor_x"] = 608,
						["growUpwards"] = false,
						["BWEmphasizeCountdownMessageAnchor_y"] = 523,
						["font"] = "KkthnxUI_Normal",
						["BWEmphasizeMessageAnchor_y"] = 614,
						["BWMessageAnchor_y"] = 676,
						["BWEmphasizeMessageAnchor_x"] = 610,
					},
				},
			},
			["BigWigs_Plugins_Statistics"] = {},
			["BigWigs_Plugins_Respawn"] = {},
			["BigWigs_Plugins_Proximity"] = {
				["profiles"] = {
					["KkthnxUI"] = {
						["posx"] = 900.11113290675,
						["font"] = "KkthnxUI_Normal",
						["lock"] = true,
						["height"] = 99.0000381469727,
						["posy"] = 70.4000288314296,
					},
				},
			},
			["BigWigs_Plugins_Raid Icons"] = {},
			["LibDualSpec-1.0"] = {},
		},
		["profiles"] = {
			["KkthnxUI"] = {
				["fakeDBMVersion"] = true,
			},
		},
	}

	-- Profile creation
	local db = LibStub("AceDB-3.0"):New(BigWigs3DB, nil, true)
	db:SetProfile("KkthnxUI")
end