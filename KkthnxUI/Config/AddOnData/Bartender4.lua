local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local table_wipe = table.wipe

-- GLOBALS: Bartender4DB

function K.LoadBartenderProfile()
  if Bartender4DB then
		table_wipe(Bartender4DB)
	end

	Bartender4DB = {
		["namespaces"] = {
			["ActionBars"] = {
				["profiles"] = {
					["KkhnxUI"] = {
						["actionbars"] = {
							{
								["showgrid"] = true,
								["rows"] = 2,
								["version"] = 3,
								["position"] = {
									["y"] = -253,
									["x"] = -127.050016784668,
									["point"] = "CENTER",
									["scale"] = 1.1,
								},
								["padding"] = 1,
							}, -- [1]
							{
								["enabled"] = false,
								["version"] = 3,
								["position"] = {
									["y"] = -227.499923706055,
									["x"] = -231.500183105469,
									["point"] = "CENTER",
								},
							}, -- [2]
							{
								["rows"] = 12,
								["enabled"] = false,
								["version"] = 3,
								["position"] = {
									["y"] = 248.000061035156,
									["x"] = -260.332885742188,
									["point"] = "RIGHT",
								},
								["padding"] = 5,
							}, -- [3]
							{
								["showgrid"] = true,
								["rows"] = 12,
								["fadeout"] = true,
								["version"] = 3,
								["position"] = {
									["y"] = 249.150022184849,
									["x"] = -45.6497762690851,
									["point"] = "RIGHT",
									["scale"] = 1.10000002384186,
								},
								["padding"] = 1,
							}, -- [4]
							{
								["showgrid"] = true,
								["fadeout"] = true,
								["version"] = 3,
								["position"] = {
									["y"] = 41.5,
									["x"] = -226.500015258789,
									["point"] = "BOTTOM",
								},
								["padding"] = 1,
							}, -- [5]
							{
								["showgrid"] = true,
								["rows"] = 2,
								["version"] = 3,
								["position"] = {
									["y"] = 206,
									["x"] = -127.050016784668,
									["point"] = "BOTTOM",
									["scale"] = 1.1,
								},
								["padding"] = 1,
							}, -- [6]
							{
							}, -- [7]
							{
							}, -- [8]
							nil, -- [9]
							{
							}, -- [10]
						},
					},
				},
			},
			["LibDualSpec-1.0"] = {
			},
			["ExtraActionBar"] = {
				["profiles"] = {
					["KkhnxUI"] = {
						["position"] = {
							["y"] = 176,
							["x"] = 180,
							["point"] = "BOTTOM",
						},
						["version"] = 3,
					},
				},
			},
			["ZoneAbilityBar"] = {
				["profiles"] = {
					["KkhnxUI"] = {
						["position"] = {
							["y"] = 176,
							["x"] = 180,
							["point"] = "BOTTOM",
						},
						["version"] = 3,
					},
				},
			},
			["MicroMenu"] = {
				["profiles"] = {
					["KkhnxUI"] = {
						["enabled"] = false,
						["position"] = {
							["y"] = 220.144470214844,
							["x"] = 355.600036621094,
							["point"] = "BOTTOMLEFT",
							["scale"] = 1,
						},
						["version"] = 3,
						["padding"] = -2,
					},
				},
			},
			["XPBar"] = {
			},
			["APBar"] = {
			},
			["BlizzardArt"] = {
				["profiles"] = {
					["KkhnxUI"] = {
						["position"] = {
							["y"] = 47,
							["x"] = -512,
							["point"] = "BOTTOM",
						},
						["version"] = 3,
					},
				},
			},
			["Vehicle"] = {
				["profiles"] = {
					["KkhnxUI"] = {
						["version"] = 3,
						["position"] = {
							["y"] = 42,
							["x"] = 226,
							["point"] = "BOTTOM",
						},
					},
				},
			},
			["BagBar"] = {
				["profiles"] = {
					["KkhnxUI"] = {
						["enabled"] = false,
						["version"] = 3,
						["position"] = {
							["y"] = 99.6888732910156,
							["x"] = 220.922241210938,
							["point"] = "BOTTOM",
						},
					},
				},
			},
			["StanceBar"] = {
				["profiles"] = {
					["KkhnxUI"] = {
						["position"] = {
							["y"] = 224.500094370051,
							["x"] = -372.698542336566,
							["point"] = "BOTTOM",
							["scale"] = 1.20000004768372,
						},
						["padding"] = 1,
						["version"] = 3,
					},
				},
			},
			["PetBar"] = {
				["profiles"] = {
					["KkhnxUI"] = {
						["version"] = 3,
						["position"] = {
							["y"] = 72,
							["x"] = -159.5,
							["point"] = "BOTTOM",
						},
						["padding"] = 1,
					},
				},
			},
			["RepBar"] = {
			},
		},
		["profileKeys"] = {
			["KkhnxUI"] = "KkhnxUI",
		},
		["profiles"] = {
			["KkhnxUI"] = {
				["focuscastmodifier"] = false,
				["blizzardVehicle"] = true,
				["outofrange"] = "hotkey",
			},
		},
	}
end