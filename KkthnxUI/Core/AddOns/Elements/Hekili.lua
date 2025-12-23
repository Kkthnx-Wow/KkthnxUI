local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("AddOns")

local table_wipe = table.wipe

local function ImportHekiliProfile()
	if not C_AddOns.IsAddOnLoaded("Hekili") then
		return
	end

	if HekiliDB then
		table_wipe(HekiliDB)
	end

	HekiliDB = {
		["profiles"] = {
			["Default"] = {
				["displays"] = {
					["Interrupts"] = {
						["delays"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["rel"] = "CENTER",
						["targets"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["captions"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["keybindings"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["x"] = -246.2991485595703,
						["primaryHeight"] = 40,
						["empowerment"] = {
							["fontSize"] = 14,
						},
						["primaryWidth"] = 40,
						["y"] = 91.49479675292969,
					},
					["Cooldowns"] = {
						["delays"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["rel"] = "CENTER",
						["targets"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["captions"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["keybindings"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["x"] = -201.3146667480469,
						["primaryHeight"] = 40,
						["empowerment"] = {
							["fontSize"] = 14,
						},
						["primaryWidth"] = 40,
						["y"] = 91.58060455322266,
					},
					["Primary"] = {
						["empowerment"] = {
							["fontSize"] = 14,
						},
						["primaryWidth"] = 44,
						["flash"] = {
							["enabled"] = true,
						},
						["rel"] = "CENTER",
						["numIcons"] = 4,
						["captions"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["targets"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["queue"] = {
							["width"] = 44,
							["spacing"] = 6,
							["height"] = 44,
							["offsetX"] = 6,
						},
						["y"] = 44,
						["x"] = -330,
						["primaryHeight"] = 44,
						["border"] = {
							["enabled"] = false,
						},
						["delays"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["visibility"] = {
							["pve"] = {
								["alpha"] = 0.8,
							},
							["pvp"] = {
								["alpha"] = 0.8,
							},
						},
						["keybindings"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
					},
					["AOE"] = {
						["targets"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["rel"] = "CENTER",
						["primaryWidth"] = 40,
						["captions"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["queue"] = {
							["width"] = 40,
							["height"] = 40,
						},
						["keybindings"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["x"] = -291.455810546875,
						["primaryHeight"] = 40,
						["empowerment"] = {
							["fontSize"] = 14,
						},
						["delays"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["y"] = -0.7357177734375,
					},
					["Defensives"] = {
						["delays"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["rel"] = "CENTER",
						["targets"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["captions"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["keybindings"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["x"] = -291.2839965820313,
						["primaryHeight"] = 40,
						["empowerment"] = {
							["fontSize"] = 14,
						},
						["primaryWidth"] = 40,
						["y"] = 91.4949722290039,
					},
				},
			},
		},
	}

	KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest = false
end

function Module:CreateHekiliProfile()
	if not K.isDeveloper then
		return
	end

	if KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest then
		ImportHekiliProfile()
	end
end
