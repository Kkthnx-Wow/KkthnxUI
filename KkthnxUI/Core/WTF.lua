local K, C, L, _ = select(2, ...):unpack()

local print = print
local IsAddOnLoaded = IsAddOnLoaded
local ReloadUI = ReloadUI
local wipe = table.wipe

if (K.Name == "Swiverr" or K.Name == "Swiver") and (K.Realm == "Stormreaver") then
	local UploadAzCastBar = function()
		if AzCastBar_Profiles then wipe(AzCastBar_Profiles) end
		AzCastBar_Profiles = {
			["Swiver"] = {
				["Player"] = {
					["mergeTrade"] = false,
					["bottom"] = 87.5330123901367,
					["showSpellTarget"] = false,
					["showRank"] = false,
					["width"] = 216,
					["colSafezone"] = {
						0.3, -- [1]
						0.8, -- [2]
						0.3, -- [3]
						0.6, -- [4]
					},
					["colInterrupt"] = {
						1, -- [1]
						0.75, -- [2]
						0.5, -- [3]
					},
					["colFailed"] = {
						1, -- [1]
						0.5, -- [2]
						0.5, -- [3]
					},
					["safeZone"] = false,
					["colNonInterruptable"] = {
						0.78, -- [1]
						0.82, -- [2]
						0.86, -- [3]
					},
					["colNormal"] = {
						0.4, -- [1]
						0.6, -- [2]
						0.8, -- [3]
					},
					["left"] = 773.400451660156,
				},
				["optionsLeft"] = 267.999603271484,
				["Focus"] = {
					["bottom"] = 281.000061035156,
					["showRank"] = false,
					["width"] = 100,
					["colInterrupt"] = {
						1, -- [1]
						0.75, -- [2]
						0.5, -- [3]
					},
					["colNormal"] = {
						0.4, -- [1]
						0.6, -- [2]
						0.8, -- [3]
					},
					["iconAnchor"] = "NONE",
					["colNonInterruptable"] = {
						0.78, -- [1]
						0.82, -- [2]
						0.86, -- [3]
					},
					["left"] = 1199.93371582031,
					["colFailed"] = {
						1, -- [1]
						0.5, -- [2]
						0.5, -- [3]
					},
				},
				["Target"] = {
					["colNormal"] = {
						0.4, -- [1]
						0.6, -- [2]
						0.8, -- [3]
					},
					["colInterrupt"] = {
						1, -- [1]
						0.75, -- [2]
						0.5, -- [3]
					},
					["colFailed"] = {
						1, -- [1]
						0.5, -- [2]
						0.5, -- [3]
					},
					["bottom"] = 115.666374206543,
					["left"] = 773.400329589844,
					["colNonInterruptable"] = {
						0.78, -- [1]
						0.82, -- [2]
						0.86, -- [3]
					},
					["showRank"] = false,
					["width"] = 216,
				},
				["optionsBottom"] = 321.19970703125,
				["Pet"] = {
					["colNormal"] = {
						0.4, -- [1]
						0.6, -- [2]
						0.8, -- [3]
					},
					["colInterrupt"] = {
						1, -- [1]
						0.75, -- [2]
						0.5, -- [3]
					},
					["colFailed"] = {
						1, -- [1]
						0.5, -- [2]
						0.5, -- [3]
					},
					["bottom"] = 30.0660934448242,
					["left"] = 1255.93383789063,
					["colNonInterruptable"] = {
						0.78, -- [1]
						0.82, -- [2]
						0.86, -- [3]
					},
					["showRank"] = false,
					["width"] = 180,
				},
				["Mirror"] = {
					["enabled"] = false,
					["colNormal"] = {
						0.4, -- [1]
						0.6, -- [2]
						0.8, -- [3]
					},
					["left"] = 751.000122070313,
					["bottom"] = 851.133239746094,
				},
			},
		}
	end
	
	local UploadSUF = function()
		if ShadowedUFDB then wipe(ShadowedUFDB) end
		ShadowedUFDB = {
			["namespaces"] = {
				["LibDualSpec-1.0"] = {
				},
			},
			["global"] = {
				["infoID"] = 3,
			},
			["profileKeys"] = {
				["Swiverr - Stormreaver"] = "Default",
				["Swiver - Stormreaver"] = "Default",
			},
			["profiles"] = {
				["Default"] = {
					["wowBuild"] = 70000,
					["auras"] = {
						["borderType"] = "dark",
					},
					["healthColors"] = {
						["aggro"] = {
							["r"] = 0.9,
							["g"] = 0,
							["b"] = 0,
						},
						["healAbsorb"] = {
							["r"] = 0.68,
							["g"] = 0.47,
							["b"] = 1,
						},
						["neutral"] = {
							["r"] = 0.93,
							["g"] = 0.93,
							["b"] = 0,
						},
						["static"] = {
							["r"] = 0.7,
							["g"] = 0.2,
							["b"] = 0.9,
						},
						["friendly"] = {
							["r"] = 0.2,
							["g"] = 0.9,
							["b"] = 0.2,
						},
						["yellow"] = {
							["r"] = 0.93,
							["g"] = 0.93,
							["b"] = 0,
						},
						["incAbsorb"] = {
							["r"] = 0.93,
							["g"] = 0.75,
							["b"] = 0.09,
						},
						["tapped"] = {
							["r"] = 0.5,
							["g"] = 0.5,
							["b"] = 0.5,
						},
						["hostile"] = {
							["r"] = 0.9,
							["g"] = 0,
							["b"] = 0,
						},
						["green"] = {
							["r"] = 0.2,
							["g"] = 0.9,
							["b"] = 0.2,
						},
						["enemyUnattack"] = {
							["r"] = 0.6,
							["g"] = 0.2,
							["b"] = 0.2,
						},
						["offline"] = {
							["r"] = 0.5,
							["g"] = 0.5,
							["b"] = 0.5,
						},
						["inc"] = {
							["r"] = 0,
							["g"] = 0.35,
							["b"] = 0.23,
						},
						["red"] = {
							["r"] = 0.9,
							["g"] = 0,
							["b"] = 0,
						},
					},
					["xpColors"] = {
						["normal"] = {
							["r"] = 0.58,
							["g"] = 0,
							["b"] = 0.55,
						},
						["rested"] = {
							["r"] = 0,
							["g"] = 0.39,
							["b"] = 0.88,
						},
					},
					["locked"] = true,
					["auraIndicators"] = {
						["indicators"] = {
							["bl"] = {
								["x"] = -4,
								["showStack"] = false,
							},
						},
						["filters"] = {
							["bl"] = {
								["boss"] = {
									["enabled"] = false,
								},
							},
						},
					},
					["positions"] = {
						["arenatarget"] = {
							["anchorPoint"] = "RT",
							["anchorTo"] = "$parent",
						},
						["mainassisttarget"] = {
							["anchorPoint"] = "RT",
							["anchorTo"] = "$parent",
						},
						["targettargettarget"] = {
							["anchorPoint"] = "RC",
							["anchorTo"] = "#SUFUnittargettarget",
						},
						["arenatargettarget"] = {
							["anchorPoint"] = "RT",
							["anchorTo"] = "$parent",
						},
						["pettarget"] = {
							["anchorPoint"] = "C",
						},
						["arenapet"] = {
							["anchorPoint"] = "RB",
							["anchorTo"] = "$parent",
						},
						["mainassisttargettarget"] = {
							["anchorPoint"] = "RT",
							["x"] = 150,
							["anchorTo"] = "$parent",
						},
						["party"] = {
							["y"] = 725.730110243967,
							["x"] = 2.93333149878748,
							["point"] = "TOPLEFT",
							["bottom"] = 536.015727990023,
							["top"] = 725.730110243967,
							["relativePoint"] = "BOTTOMLEFT",
						},
						["maintanktarget"] = {
							["anchorPoint"] = "RT",
							["anchorTo"] = "$parent",
						},
						["focus"] = {
							["anchorPoint"] = "TC",
							["anchorTo"] = "#SUFUnittargettarget",
						},
						["target"] = {
							["y"] = 149.070187393464,
							["x"] = 155.772080189427,
							["point"] = "BOTTOM",
							["relativePoint"] = "BOTTOM",
						},
						["raid"] = {
							["anchorPoint"] = "C",
						},
						["partytargettarget"] = {
							["anchorPoint"] = "RT",
							["anchorTo"] = "$parent",
						},
						["boss"] = {
							["point"] = "TOPLEFT",
							["bottom"] = 266.666694885209,
							["y"] = 501.333342671394,
							["x"] = 1125.89259909638,
							["relativePoint"] = "BOTTOMLEFT",
							["top"] = 501.333342671394,
						},
						["maintank"] = {
							["anchorPoint"] = "C",
						},
						["battlegroundtargettarget"] = {
							["anchorPoint"] = "RT",
							["anchorTo"] = "$parent",
						},
						["bosstargettarget"] = {
							["anchorPoint"] = "RB",
							["anchorTo"] = "$parent",
						},
						["raidpet"] = {
							["anchorPoint"] = "C",
						},
						["bosstarget"] = {
							["anchorPoint"] = "RB",
							["anchorTo"] = "$parent",
						},
						["battlegroundpet"] = {
							["anchorPoint"] = "RB",
							["anchorTo"] = "$parent",
						},
						["pet"] = {
							["y"] = -1.5337299450951,
							["x"] = -267.592778421804,
							["point"] = "BOTTOMRIGHT",
							["relativePoint"] = "BOTTOMRIGHT",
						},
						["maintanktargettarget"] = {
							["anchorPoint"] = "RT",
							["x"] = 150,
							["anchorTo"] = "$parent",
						},
						["player"] = {
							["y"] = 149.069803743903,
							["x"] = -155.085242844045,
							["point"] = "BOTTOM",
							["relativePoint"] = "BOTTOM",
						},
						["mainassist"] = {
							["anchorPoint"] = "C",
						},
						["targettarget"] = {
							["anchorPoint"] = "RB",
							["anchorTo"] = "#SUFUnittarget",
						},
						["focustarget"] = {
							["anchorPoint"] = "TL",
							["anchorTo"] = "#SUFUnitfocus",
						},
						["arena"] = {
							["anchorPoint"] = "C",
						},
						["battlegroundtarget"] = {
							["anchorPoint"] = "RT",
							["anchorTo"] = "$parent",
						},
						["battleground"] = {
							["anchorPoint"] = "C",
						},
					},
					["revision"] = 58,
					["powerColors"] = {
						["FUEL"] = {
							["r"] = 0.85,
							["g"] = 0.47,
							["b"] = 0.36,
						},
						["ALTERNATE"] = {
							["r"] = 0.815,
							["g"] = 0.941,
							["b"] = 1,
						},
						["FOCUS"] = {
							["r"] = 1,
							["g"] = 0.5,
							["b"] = 0.25,
						},
						["STAGGER_GREEN"] = {
							["r"] = 0.52,
							["g"] = 1,
							["b"] = 0.52,
						},
						["STAGGER_RED"] = {
							["r"] = 1,
							["g"] = 0.42,
							["b"] = 0.42,
						},
						["ARCANECHARGES"] = {
							["r"] = 0.1,
							["g"] = 0.1,
							["b"] = 0.98,
						},
						["COMBOPOINTS"] = {
							["r"] = 1,
							["g"] = 0.8,
							["b"] = 0,
						},
						["RUNES"] = {
							["r"] = 0.5,
							["g"] = 0.5,
							["b"] = 0.5,
						},
						["RUNEOFPOWER"] = {
							["r"] = 0.35,
							["g"] = 0.45,
							["b"] = 0.6,
						},
						["ENERGY"] = {
							["r"] = 1,
							["g"] = 0.85,
							["b"] = 0.1,
						},
						["MANA"] = {
							["r"] = 0.3,
							["g"] = 0.5,
							["b"] = 0.85,
						},
						["CHI"] = {
							["r"] = 0.71,
							["g"] = 1,
							["b"] = 0.92,
						},
						["AURAPOINTS"] = {
							["r"] = 1,
							["g"] = 0.8,
							["b"] = 0,
						},
						["MUSHROOMS"] = {
							["r"] = 0.2,
							["g"] = 0.9,
							["b"] = 0.2,
						},
						["MAELSTROM"] = {
							["r"] = 0,
							["g"] = 0.5,
							["b"] = 1,
						},
						["PAIN"] = {
							["r"] = 1,
							["g"] = 0,
							["b"] = 0,
						},
						["SOULSHARDS"] = {
							["r"] = 0.58,
							["g"] = 0.51,
							["b"] = 0.79,
						},
						["FURY"] = {
							["r"] = 0.788,
							["g"] = 0.259,
							["b"] = 0.992,
						},
						["LUNAR_POWER"] = {
							["r"] = 0.3,
							["g"] = 0.52,
							["b"] = 0.9,
						},
						["AMMOSLOT"] = {
							["r"] = 0.85,
							["g"] = 0.6,
							["b"] = 0.55,
						},
						["RUNIC_POWER"] = {
							["b"] = 0.6,
							["g"] = 0.45,
							["r"] = 0.35,
						},
						["STATUE"] = {
							["r"] = 0.35,
							["g"] = 0.45,
							["b"] = 0.6,
						},
						["INSANITY"] = {
							["r"] = 0.4,
							["g"] = 0,
							["b"] = 0.8,
						},
						["HOLYPOWER"] = {
							["r"] = 0.95,
							["g"] = 0.9,
							["b"] = 0.6,
						},
						["STAGGER_YELLOW"] = {
							["r"] = 1,
							["g"] = 0.98,
							["b"] = 0.72,
						},
						["RAGE"] = {
							["r"] = 0.9,
							["g"] = 0.2,
							["b"] = 0.3,
						},
					},
					["castColors"] = {
						["cast"] = {
							["r"] = 1,
							["g"] = 0.7,
							["b"] = 0.3,
						},
						["finished"] = {
							["r"] = 0.1,
							["g"] = 1,
							["b"] = 0.1,
						},
						["channel"] = {
							["r"] = 0.25,
							["g"] = 0.25,
							["b"] = 1,
						},
						["uninterruptible"] = {
							["r"] = 0.71,
							["g"] = 0,
							["b"] = 1,
						},
						["interrupted"] = {
							["r"] = 1,
							["g"] = 0,
							["b"] = 0,
						},
					},
					["loadedLayout"] = true,
					["backdrop"] = {
						["inset"] = 3,
						["edgeSize"] = 5,
						["tileSize"] = 1,
						["borderColor"] = {
							["a"] = 1,
							["r"] = 0.3,
							["g"] = 0.3,
							["b"] = 0.5,
						},
						["clip"] = 1,
						["backgroundTexture"] = "Chat Frame",
						["backgroundColor"] = {
							["a"] = 0.8,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
						["borderTexture"] = "None",
					},
					["units"] = {
						["arenatarget"] = {
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 90,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 25,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["mainassisttarget"] = {
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[level( )][classification( )][perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 150,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 40,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 1,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["targettargettarget"] = {
							["enabled"] = false,
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "RIGHT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["height"] = 0.5,
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["range"] = {
								["height"] = 0.5,
							},
							["width"] = 80,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["text"] = {
								{
									["width"] = 1,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["width"] = 0.5,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["height"] = 0.5,
							},
							["height"] = 30,
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["partytarget"] = {
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["width"] = 90,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["height"] = 25,
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
						},
						["arenatargettarget"] = {
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 90,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 25,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["battlegroundtarget"] = {
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 90,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 25,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["arenapet"] = {
							["highlight"] = {
								["size"] = 10,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 90,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["height"] = 25,
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
						},
						["mainassisttargettarget"] = {
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[level( )][classification( )][perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 150,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 40,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 1,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["party"] = {
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["lfdRole"] = {
									["y"] = 14,
									["x"] = 3,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BR",
									["size"] = 14,
								},
								["phase"] = {
									["anchorPoint"] = "RC",
									["x"] = -11,
									["anchorTo"] = "$parent",
									["size"] = 14,
								},
								["masterLoot"] = {
									["y"] = -10,
									["x"] = 16,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 12,
								},
								["leader"] = {
									["y"] = -12,
									["x"] = 2,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["role"] = {
									["y"] = -11,
									["x"] = 30,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["ready"] = {
									["y"] = 0,
									["x"] = 35,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 24,
								},
								["resurrect"] = {
									["y"] = -1,
									["x"] = 37,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 28,
								},
								["height"] = 0.5,
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["status"] = {
									["y"] = -2,
									["x"] = 12,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LB",
									["size"] = 16,
								},
								["pvp"] = {
									["y"] = -21,
									["x"] = 11,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TR",
									["size"] = 22,
								},
							},
							["range"] = {
								["height"] = 0.5,
							},
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["enabled"] = true,
									["y"] = 0,
									["x"] = 0,
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["buffs"] = {
									["enabled"] = true,
									["anchorPoint"] = "BL",
									["x"] = 0,
									["y"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 60,
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 50,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["incAbsorb"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 1,
								["background"] = true,
								["order"] = 20,
							},
							["enabled"] = false,
							["offset"] = 23,
							["incHeal"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["unitsPerColumn"] = 5,
							["fader"] = {
								["height"] = 0.5,
							},
							["attribAnchorPoint"] = "LEFT",
							["height"] = 45,
							["width"] = 190,
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[level( )][perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["combatText"] = {
								["height"] = 0.5,
							},
							["columnSpacing"] = 30,
							["healAbsorb"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["highlight"] = {
								["height"] = 0.5,
								["size"] = 10,
							},
							["attribPoint"] = "TOP",
						},
						["maintanktargettarget"] = {
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[classification( )][perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 150,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 40,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 1,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["focus"] = {
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["lfdRole"] = {
									["y"] = 14,
									["x"] = 3,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BR",
									["size"] = 14,
								},
								["resurrect"] = {
									["y"] = -1,
									["x"] = 37,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 28,
								},
								["masterLoot"] = {
									["y"] = -10,
									["x"] = 16,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 12,
								},
								["leader"] = {
									["y"] = -12,
									["x"] = 2,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["questBoss"] = {
									["y"] = 14,
									["x"] = 7,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BR",
									["enabled"] = false,
									["size"] = 22,
								},
								["status"] = {
									["y"] = -2,
									["x"] = 12,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LB",
									["size"] = 16,
								},
								["height"] = 0.5,
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["role"] = {
									["y"] = -11,
									["x"] = 30,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["pvp"] = {
									["y"] = -21,
									["x"] = 11,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TR",
									["size"] = 22,
								},
							},
							["range"] = {
								["height"] = 0.5,
							},
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 60,
							},
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["incAbsorb"] = {
								["height"] = 0.5,
							},
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "[curpp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 50,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["width"] = 110,
							["fader"] = {
								["height"] = 0.5,
							},
							["incHeal"] = {
								["height"] = 0.5,
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["combatText"] = {
								["height"] = 0.5,
							},
							["height"] = 30,
							["healAbsorb"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["highlight"] = {
								["height"] = 0.5,
								["size"] = 10,
							},
						},
						["target"] = {
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["lfdRole"] = {
									["y"] = 14,
									["x"] = 3,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BR",
									["size"] = 14,
								},
								["resurrect"] = {
									["y"] = -1,
									["x"] = -39,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "RC",
									["size"] = 28,
								},
								["masterLoot"] = {
									["y"] = -10,
									["x"] = 16,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 12,
								},
								["leader"] = {
									["y"] = -12,
									["x"] = 2,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["questBoss"] = {
									["y"] = 24,
									["x"] = 9,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BR",
									["size"] = 22,
								},
								["status"] = {
									["y"] = -2,
									["x"] = 12,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LB",
									["size"] = 16,
								},
								["height"] = 0.5,
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["role"] = {
									["y"] = -11,
									["x"] = 30,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["pvp"] = {
									["y"] = -21,
									["x"] = 11,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TR",
									["size"] = 22,
								},
							},
							["range"] = {
								["height"] = 0.5,
							},
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["enabled"] = true,
									["anchorOn"] = false,
									["enlarge"] = {
										["BOSS"] = true,
										["REMOVABLE"] = true,
									},
									["anchorPoint"] = "TL",
									["maxRows"] = 1,
									["perRow"] = 6,
									["y"] = 0,
									["show"] = {
										["relevant"] = false,
										["misc"] = false,
									},
									["x"] = 0,
									["size"] = 22,
								},
								["buffs"] = {
									["enabled"] = true,
									["anchorOn"] = false,
									["enlarge"] = {
										["SELF"] = true,
										["REMOVABLE"] = true,
									},
									["anchorPoint"] = "BL",
									["maxRows"] = 1,
									["y"] = 0,
									["perRow"] = 6,
									["show"] = {
										["relevant"] = false,
										["misc"] = false,
									},
									["x"] = 0,
									["size"] = 18,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 60,
							},
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 1,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["comboPoints"] = {
								["anchorTo"] = "$parent",
								["order"] = 60,
								["growth"] = "LEFT",
								["anchorPoint"] = "BR",
								["x"] = -3,
								["spacing"] = -4,
								["height"] = 0.4,
								["y"] = 8,
								["size"] = 14,
							},
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[level( )][classification( )][perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["incAbsorb"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["width"] = 190,
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "RIGHT",
								["fullAfter"] = 50,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["incHeal"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["combatText"] = {
								["height"] = 0.5,
							},
							["height"] = 45,
							["healAbsorb"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["highlight"] = {
								["height"] = 0.5,
								["eliteMob"] = false,
								["size"] = 10,
							},
						},
						["raid"] = {
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["groupSpacing"] = 0,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.3,
								["background"] = true,
								["order"] = 20,
							},
							["groupsPerRow"] = 8,
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "none",
							},
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[missinghp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["maxColumns"] = 8,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["height"] = 30,
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["lfdRole"] = {
									["y"] = 14,
									["x"] = 3,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BR",
									["size"] = 14,
								},
								["resurrect"] = {
									["y"] = -1,
									["x"] = 37,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 28,
								},
								["masterLoot"] = {
									["anchorPoint"] = "TR",
									["x"] = -2,
									["anchorTo"] = "$parent",
									["y"] = -10,
									["size"] = 12,
								},
								["leader"] = {
									["y"] = -12,
									["x"] = 2,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["role"] = {
									["enabled"] = false,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BR",
									["y"] = 14,
									["size"] = 14,
								},
								["ready"] = {
									["anchorPoint"] = "LC",
									["x"] = 25,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["size"] = 24,
								},
								["height"] = 0.5,
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["status"] = {
									["y"] = -2,
									["x"] = 12,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LB",
									["size"] = 16,
								},
								["pvp"] = {
									["anchorPoint"] = "BL",
									["x"] = 0,
									["anchorTo"] = "$parent",
									["y"] = 11,
									["size"] = 22,
								},
							},
							["scale"] = 0.85,
							["range"] = {
								["height"] = 0.5,
							},
							["incAbsorb"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["attribAnchorPoint"] = "LEFT",
							["unitsPerColumn"] = 8,
							["width"] = 100,
							["highlight"] = {
								["height"] = 0.5,
								["size"] = 10,
							},
							["fader"] = {
								["height"] = 0.5,
							},
							["combatText"] = {
								["height"] = 0.5,
							},
							["columnSpacing"] = 5,
							["healAbsorb"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["incHeal"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
						},
						["partytargettarget"] = {
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 90,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 25,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["arena"] = {
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["lfdRole"] = {
									["y"] = 14,
									["x"] = 3,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BR",
									["size"] = 14,
								},
								["arenaSpec"] = {
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 28,
								},
							},
							["auras"] = {
								["debuffs"] = {
									["perRow"] = 9,
									["y"] = 0,
									["enabled"] = true,
									["x"] = 0,
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["buffs"] = {
									["perRow"] = 9,
									["y"] = 0,
									["enabled"] = true,
									["x"] = 0,
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 60,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 1,
								["background"] = true,
								["order"] = 20,
							},
							["offset"] = 25,
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["width"] = 170,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["height"] = 45,
							["highlight"] = {
								["size"] = 10,
							},
							["portrait"] = {
								["enabled"] = true,
								["type"] = "class",
								["alignment"] = "LEFT",
								["fullAfter"] = 50,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
						},
						["focustarget"] = {
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["height"] = 0.5,
							},
							["range"] = {
								["height"] = 0.5,
							},
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["width"] = 110,
							["fader"] = {
								["height"] = 0.5,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["height"] = 25,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["highlight"] = {
								["height"] = 0.5,
								["size"] = 10,
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "RIGHT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
						},
						["battlegroundtargettarget"] = {
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 90,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 25,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["bosstargettarget"] = {
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 90,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 25,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["pettarget"] = {
							["width"] = 190,
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["height"] = 0.5,
								["size"] = 10,
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["range"] = {
								["height"] = 0.5,
							},
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["height"] = 0.5,
							},
							["height"] = 30,
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.7,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["bosstarget"] = {
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 90,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 25,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["battlegroundpet"] = {
							["highlight"] = {
								["size"] = 10,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 90,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["height"] = 25,
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
						},
						["pet"] = {
							["xpBar"] = {
								["height"] = 0.25,
								["background"] = true,
								["order"] = 55,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["height"] = 0.5,
							},
							["range"] = {
								["height"] = 0.5,
							},
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 60,
							},
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.7,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "none",
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 50,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["incAbsorb"] = {
								["height"] = 0.5,
							},
							["width"] = 190,
							["fader"] = {
								["height"] = 0.5,
							},
							["incHeal"] = {
								["height"] = 0.5,
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["combatText"] = {
								["height"] = 0.5,
							},
							["height"] = 30,
							["healAbsorb"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["highlight"] = {
								["height"] = 0.5,
								["size"] = 10,
							},
						},
						["partypet"] = {
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 90,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["height"] = 25,
							["healAbsorb"] = {
								["cap"] = 1,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
						},
						["mainassist"] = {
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[level( )][perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["highlight"] = {
								["size"] = 10,
							},
							["attribAnchorPoint"] = "LEFT",
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 60,
							},
							["incHeal"] = {
								["cap"] = 1,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["resurrect"] = {
									["y"] = -1,
									["x"] = 37,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 28,
								},
								["masterLoot"] = {
									["y"] = -10,
									["x"] = 16,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 12,
								},
								["leader"] = {
									["y"] = -12,
									["x"] = 2,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["role"] = {
									["y"] = -11,
									["x"] = 30,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["status"] = {
									["y"] = -2,
									["x"] = 12,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LB",
									["size"] = 16,
								},
								["ready"] = {
									["y"] = 0,
									["x"] = 35,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 24,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["pvp"] = {
									["y"] = -21,
									["x"] = 11,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TR",
									["size"] = 22,
								},
							},
							["incAbsorb"] = {
								["cap"] = 1,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 1,
								["background"] = true,
								["order"] = 20,
							},
							["offset"] = 5,
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 50,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["height"] = 40,
							["unitsPerColumn"] = 5,
							["width"] = 150,
							["maxColumns"] = 1,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["columnSpacing"] = 5,
							["healAbsorb"] = {
								["cap"] = 1,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
						},
						["player"] = {
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 50,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["runeBar"] = {
								["enabled"] = true,
								["background"] = false,
								["order"] = 70,
								["height"] = 0.4,
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 60,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["order"] = 20,
								["background"] = true,
								["height"] = 1,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["reactionType"] = "npc",
								["background"] = true,
								["height"] = 1.2,
								["order"] = 10,
							},
							["druidBar"] = {
								["enabled"] = true,
								["background"] = true,
								["order"] = 70,
								["height"] = 0.4,
							},
							["text"] = {
								{
									["text"] = "[(()afk() )][name][( ()group())]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name][( ()group())]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["anchorTo"] = "$totemBar",
									["text"] = "[totem:timer]",
									["width"] = 1,
									["default"] = true,
									["name"] = "Timer Text",
									["block"] = true,
								}, -- [6]
								{
									["anchorTo"] = "$runeBar",
									["text"] = "[rune:timer]",
									["width"] = 1,
									["name"] = "Timer Text",
									["block"] = true,
								}, -- [7]
								{
									["anchorTo"] = "$staggerBar",
									["text"] = "[monk:abs:stagger]",
									["width"] = 1,
									["name"] = "Text",
								}, -- [8]
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["height"] = 45,
							["auraPoints"] = {
								["anchorTo"] = "$parent",
								["order"] = 60,
								["showAlways"] = true,
								["growth"] = "LEFT",
								["anchorPoint"] = "BR",
								["x"] = -3,
								["spacing"] = -4,
								["height"] = 0.4,
								["y"] = 8,
								["size"] = 14,
							},
							["xpBar"] = {
								["height"] = 0.25,
								["background"] = true,
								["order"] = 55,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["lfdRole"] = {
									["y"] = 14,
									["x"] = 3,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BR",
									["size"] = 14,
								},
								["resurrect"] = {
									["y"] = -1,
									["x"] = 37,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 28,
								},
								["masterLoot"] = {
									["y"] = -10,
									["x"] = 16,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 12,
								},
								["leader"] = {
									["y"] = -12,
									["x"] = 2,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["role"] = {
									["y"] = -11,
									["x"] = 30,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["status"] = {
									["y"] = -2,
									["x"] = 12,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LB",
									["size"] = 16,
								},
								["ready"] = {
									["y"] = 0,
									["x"] = 35,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 24,
								},
								["height"] = 0.5,
								["pvp"] = {
									["y"] = -21,
									["x"] = 11,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TR",
									["size"] = 22,
								},
							},
							["totemBar"] = {
								["enabled"] = true,
								["background"] = false,
								["order"] = 70,
								["height"] = 0.4,
							},
							["incAbsorb"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["comboPoints"] = {
								["anchorTo"] = "$parent",
								["order"] = 60,
								["growth"] = "LEFT",
								["anchorPoint"] = "BR",
								["x"] = -3,
								["spacing"] = -4,
								["height"] = 0.4,
								["y"] = 8,
								["size"] = 14,
							},
							["width"] = 190,
							["staggerBar"] = {
								["height"] = 0.3,
								["background"] = true,
								["order"] = 70,
							},
							["highlight"] = {
								["height"] = 0.5,
								["size"] = 10,
							},
							["shamanBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 70,
							},
							["holyPower"] = {
								["anchorTo"] = "$parent",
								["order"] = 60,
								["showAlways"] = true,
								["growth"] = "LEFT",
								["anchorPoint"] = "BR",
								["x"] = -3,
								["spacing"] = -4,
								["height"] = 0.4,
								["y"] = 6,
								["size"] = 14,
							},
							["soulShards"] = {
								["anchorTo"] = "$parent",
								["order"] = 60,
								["showAlways"] = true,
								["growth"] = "LEFT",
								["anchorPoint"] = "BR",
								["x"] = -8,
								["spacing"] = -2,
								["height"] = 0.4,
								["y"] = 6,
								["size"] = 12,
							},
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["enabled"] = true,
									["anchorOn"] = false,
									["enlarge"] = {
										["SELF"] = false,
										["BOSS"] = false,
										["REMOVABLE"] = false,
									},
									["anchorPoint"] = "LT",
									["maxRows"] = 5,
									["perRow"] = 1,
									["x"] = 0,
									["y"] = 0,
									["size"] = 38,
								},
								["buffs"] = {
									["temporary"] = false,
									["anchorOn"] = true,
									["anchorPoint"] = "LT",
									["x"] = 0,
									["y"] = 0,
									["maxRows"] = 1,
									["size"] = 16,
								},
							},
							["chi"] = {
								["anchorTo"] = "$parent",
								["order"] = 60,
								["showAlways"] = true,
								["growth"] = "LEFT",
								["anchorPoint"] = "BR",
								["x"] = -3,
								["spacing"] = -4,
								["height"] = 0.4,
								["y"] = 6,
								["size"] = 14,
							},
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["fader"] = {
								["inactiveAlpha"] = 0.6,
								["combatAlpha"] = 1,
								["height"] = 0.5,
							},
							["combatText"] = {
								["height"] = 0.5,
							},
							["incHeal"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["healAbsorb"] = {
								["height"] = 0.5,
								["cap"] = 1,
							},
							["arcaneCharges"] = {
								["anchorTo"] = "$parent",
								["order"] = 60,
								["showAlways"] = true,
								["growth"] = "LEFT",
								["anchorPoint"] = "BR",
								["x"] = -8,
								["spacing"] = -2,
								["height"] = 0.4,
								["y"] = 6,
								["size"] = 12,
							},
							["priestBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 70,
							},
						},
						["maintanktarget"] = {
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[classification( )][perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 150,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
							},
							["height"] = 40,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 1,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["targettarget"] = {
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "RIGHT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["highlight"] = {
								["height"] = 0.5,
								["size"] = 10,
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["range"] = {
								["height"] = 0.5,
							},
							["width"] = 110,
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[curhp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "[curpp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["width"] = 0.5,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["height"] = 0.5,
							},
							["height"] = 30,
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.6,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
						},
						["raidpet"] = {
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["groupSpacing"] = 0,
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.3,
								["background"] = true,
								["order"] = 20,
							},
							["groupsPerRow"] = 8,
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "none",
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["maxColumns"] = 8,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["height"] = 30,
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
							},
							["scale"] = 0.85,
							["incAbsorb"] = {
								["cap"] = 1,
							},
							["incHeal"] = {
								["cap"] = 1,
							},
							["attribAnchorPoint"] = "LEFT",
							["unitsPerColumn"] = 8,
							["width"] = 90,
							["columnSpacing"] = 5,
							["healAbsorb"] = {
								["cap"] = 1,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["text"] = "[missinghp]",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
						},
						["maintank"] = {
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["highlight"] = {
								["size"] = 10,
							},
							["text"] = {
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[(()afk() )][name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["auras"] = {
								["debuffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["y"] = 0,
									["x"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 60,
							},
							["height"] = 40,
							["incAbsorb"] = {
								["cap"] = 1,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 1,
								["background"] = true,
								["order"] = 20,
							},
							["attribAnchorPoint"] = "LEFT",
							["offset"] = 5,
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["resurrect"] = {
									["y"] = -1,
									["x"] = 37,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 28,
								},
								["masterLoot"] = {
									["y"] = -10,
									["x"] = 16,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 12,
								},
								["leader"] = {
									["y"] = -12,
									["x"] = 2,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["role"] = {
									["y"] = -11,
									["x"] = 30,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TL",
									["size"] = 14,
								},
								["status"] = {
									["y"] = -2,
									["x"] = 12,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LB",
									["size"] = 16,
								},
								["ready"] = {
									["y"] = 0,
									["x"] = 35,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "LC",
									["size"] = 24,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["pvp"] = {
									["y"] = -21,
									["x"] = 11,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "TR",
									["size"] = 22,
								},
							},
							["incHeal"] = {
								["cap"] = 1,
							},
							["unitsPerColumn"] = 5,
							["width"] = 150,
							["maxColumns"] = 1,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["columnSpacing"] = 5,
							["healAbsorb"] = {
								["cap"] = 1,
							},
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 50,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
						},
						["boss"] = {
							["highlight"] = {
								["height"] = 0.5,
								["size"] = 10,
							},
							["range"] = {
								["height"] = 0.5,
							},
							["auras"] = {
								["height"] = 0.5,
								["debuffs"] = {
									["perRow"] = 1,
									["enlarge"] = {
										["SELF"] = false,
										["BOSS"] = false,
										["REMOVABLE"] = false,
									},
									["y"] = 0,
									["maxRows"] = 5,
									["show"] = {
										["misc"] = false,
									},
									["enabled"] = true,
									["x"] = 0,
									["anchorPoint"] = "LT",
									["size"] = 35,
								},
								["buffs"] = {
									["perRow"] = 6,
									["y"] = 0,
									["enabled"] = true,
									["x"] = 0,
									["anchorPoint"] = "TL",
									["size"] = 24,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 40,
							},
							["auraIndicators"] = {
								["height"] = 0.5,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 1,
								["background"] = true,
								["order"] = 20,
							},
							["offset"] = 27,
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "[perpp]",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["width"] = 160,
							["portrait"] = {
								["type"] = "3D",
								["alignment"] = "LEFT",
								["fullAfter"] = 100,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["combatText"] = {
								["height"] = 0.5,
							},
							["height"] = 40,
							["enabled"] = true,
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["height"] = 0.5,
							},
						},
						["battleground"] = {
							["indicators"] = {
								["raidTarget"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "C",
									["size"] = 20,
								},
								["class"] = {
									["y"] = 0,
									["x"] = 0,
									["anchorTo"] = "$parent",
									["anchorPoint"] = "BL",
									["size"] = 16,
								},
								["pvp"] = {
									["anchorPoint"] = "LC",
									["x"] = 16,
									["anchorTo"] = "$parent",
									["y"] = -8,
									["size"] = 40,
								},
							},
							["auras"] = {
								["debuffs"] = {
									["perRow"] = 9,
									["y"] = 0,
									["anchorPoint"] = "BL",
									["x"] = 0,
									["size"] = 16,
								},
								["buffs"] = {
									["anchorPoint"] = "BL",
									["perRow"] = 9,
									["x"] = 0,
									["y"] = 0,
									["size"] = 16,
								},
							},
							["castBar"] = {
								["time"] = {
									["enabled"] = true,
									["x"] = -1,
									["anchorTo"] = "$parent",
									["y"] = 0,
									["anchorPoint"] = "CRI",
									["size"] = 0,
								},
								["name"] = {
									["y"] = 0,
									["x"] = 1,
									["anchorTo"] = "$parent",
									["size"] = 0,
									["enabled"] = true,
									["anchorPoint"] = "CLI",
									["rank"] = true,
								},
								["height"] = 0.6,
								["background"] = true,
								["icon"] = "HIDE",
								["order"] = 60,
							},
							["powerBar"] = {
								["colorType"] = "type",
								["height"] = 0.5,
								["background"] = true,
								["order"] = 20,
							},
							["healthBar"] = {
								["colorType"] = "class",
								["order"] = 10,
								["background"] = true,
								["height"] = 1.2,
								["reactionType"] = "npc",
							},
							["emptyBar"] = {
								["order"] = 0,
								["background"] = true,
								["reactionType"] = "none",
								["height"] = 1,
							},
							["text"] = {
								{
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [1]
								{
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [2]
								{
									["text"] = "",
									["width"] = 0.5,
									["y"] = 0,
									["x"] = 3,
									["default"] = true,
									["anchorPoint"] = "CLI",
								}, -- [3]
								{
									["text"] = "",
									["width"] = 0.6,
									["y"] = 0,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [4]
								{
									["text"] = "[name]",
									["width"] = 0.5,
									["anchorPoint"] = "CLI",
									["x"] = 3,
									["default"] = true,
								}, -- [5]
								{
									["width"] = 0.6,
									["x"] = -3,
									["default"] = true,
									["anchorPoint"] = "CRI",
								}, -- [6]
							},
							["width"] = 140,
							["altPowerBar"] = {
								["height"] = 0.4,
								["background"] = true,
								["order"] = 100,
							},
							["height"] = 35,
							["highlight"] = {
								["size"] = 10,
							},
							["portrait"] = {
								["type"] = "class",
								["alignment"] = "LEFT",
								["fullAfter"] = 50,
								["height"] = 0.5,
								["fullBefore"] = 0,
								["order"] = 15,
								["width"] = 0.22,
							},
						},
					},
					["font"] = {
						["shadowX"] = 0.8,
						["name"] = "Myriad Condensed Web",
						["shadowColor"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
						["color"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
						["shadowY"] = -0.8,
						["extra"] = "",
						["size"] = 11,
					},
					["classColors"] = {
						["HUNTER"] = {
							["r"] = 0.67,
							["g"] = 0.83,
							["b"] = 0.45,
						},
						["WARRIOR"] = {
							["r"] = 0.78,
							["g"] = 0.61,
							["b"] = 0.43,
						},
						["PALADIN"] = {
							["r"] = 0.96,
							["g"] = 0.55,
							["b"] = 0.73,
						},
						["MAGE"] = {
							["r"] = 0.41,
							["g"] = 0.8,
							["b"] = 0.94,
						},
						["VEHICLE"] = {
							["r"] = 0.23,
							["g"] = 0.41,
							["b"] = 0.23,
						},
						["PRIEST"] = {
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
						["ROGUE"] = {
							["r"] = 1,
							["g"] = 0.96,
							["b"] = 0.41,
						},
						["SHAMAN"] = {
							["r"] = 0.14,
							["g"] = 0.35,
							["b"] = 1,
						},
						["WARLOCK"] = {
							["r"] = 0.58,
							["g"] = 0.51,
							["b"] = 0.79,
						},
						["DEMONHUNTER"] = {
							["r"] = 0.64,
							["g"] = 0.19,
							["b"] = 0.79,
						},
						["PET"] = {
							["r"] = 0.2,
							["g"] = 0.9,
							["b"] = 0.2,
						},
						["DRUID"] = {
							["r"] = 1,
							["g"] = 0.49,
							["b"] = 0.04,
						},
						["MONK"] = {
							["r"] = 0,
							["g"] = 1,
							["b"] = 0.59,
						},
						["DEATHKNIGHT"] = {
							["r"] = 0.77,
							["g"] = 0.12,
							["b"] = 0.23,
						},
					},
					["bars"] = {
						["texture"] = "Minimalist",
						["backgroundAlpha"] = 0.2,
						["alpha"] = 1,
						["spacing"] = -1.25,
					},
					["auraColors"] = {
						["removable"] = {
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
					},
				},
			},
		}
	end
end

if (K.Name == "Swiverr" or K.Name == "Swiver") and (K.Realm == "Stormreaver") then return end

local UploadGrid = function()
	if GridDB then wipe(GridDB) end
	GridDB = {
		["namespaces"] = {
			["GridFrame"] = {
				["profiles"] = {
					["Default"] = {
						["texture"] = "KkUI StatusBar",
						["frameHeight"] = 40,
						["invertBarColor"] = true,
						["frameWidth"] = 40,
						["font"] = "KkUI Normal",
					},
				},
			},
			["GridStatusRange"] = {
				["profiles"] = {
					["Default"] = {
						["alert_range_10"] = {
							["enable"] = false,
							["text"] = "10 yards",
							["color"] = {
								["a"] = 0.8181818181818181,
								["r"] = 0.1,
								["g"] = 0.2,
								["b"] = 0.3,
							},
							["priority"] = 81,
							["range"] = false,
							["desc"] = "More than 10 yards away",
						},
						["alert_range_30"] = {
							["enable"] = true,
							["text"] = "30 yards",
							["color"] = {
								["a"] = 0.4545454545454546,
								["r"] = 0.3,
								["g"] = 0.6,
								["b"] = 0.9,
							},
							["priority"] = 83,
							["range"] = false,
							["desc"] = "More than 30 yards away",
						},
						["alert_range_28"] = {
							["enable"] = true,
							["text"] = "28 yards",
							["color"] = {
								["a"] = 0.490909090909091,
								["r"] = 0.28,
								["g"] = 0.5600000000000001,
								["b"] = 0.84,
							},
							["priority"] = 83,
							["range"] = false,
							["desc"] = "More than 28 yards away",
						},
						["alert_range_38"] = {
							["enable"] = true,
							["text"] = "38 yards",
							["color"] = {
								["a"] = 0.3090909090909091,
								["r"] = 0.38,
								["g"] = 0.76,
								["b"] = 0.14,
							},
							["priority"] = 84,
							["range"] = false,
							["desc"] = "More than 38 yards away",
						},
						["alert_range_25"] = {
							["enable"] = true,
							["text"] = "25 yards",
							["color"] = {
								["a"] = 0.5454545454545454,
								["r"] = 0.25,
								["g"] = 0.5,
								["b"] = 0.75,
							},
							["priority"] = 82,
							["range"] = false,
							["desc"] = "More than 25 yards away",
						},
						["alert_range_100"] = {
							["enable"] = false,
							["text"] = "100 yards",
							["color"] = {
								["a"] = 0.1090909090909091,
								["r"] = 0,
								["g"] = 0,
								["b"] = 0,
							},
							["priority"] = 90,
							["range"] = false,
							["desc"] = "More than 100 yards away",
						},
					},
				},
			},
			["GridStatus"] = {
				["profiles"] = {
					["Default"] = {
						["colors"] = {
							["HUNTER"] = {
								["r"] = 0.67,
								["g"] = 0.83,
								["b"] = 0.45,
							},
							["SHAMAN"] = {
								["r"] = 0,
								["g"] = 0.44,
								["b"] = 0.87,
							},
							["MAGE"] = {
								["r"] = 0.41,
								["g"] = 0.8,
								["b"] = 0.94,
							},
							["DRUID"] = {
								["r"] = 1,
								["g"] = 0.49,
								["b"] = 0.04,
							},
							["DEATHKNIGHT"] = {
								["r"] = 0.77,
								["g"] = 0.12,
								["b"] = 0.23,
							},
							["PRIEST"] = {
								["r"] = 1,
								["g"] = 1,
								["b"] = 1,
							},
							["WARLOCK"] = {
								["r"] = 0.58,
								["g"] = 0.51,
								["b"] = 0.79,
							},
							["WARRIOR"] = {
								["r"] = 0.78,
								["g"] = 0.61,
								["b"] = 0.43,
							},
							["PALADIN"] = {
								["r"] = 0.96,
								["g"] = 0.55,
								["b"] = 0.73,
							},
							["ROGUE"] = {
								["r"] = 1,
								["g"] = 0.96,
								["b"] = 0.41,
							},
						},
					},
				},
			},
			["GridStatusName"] = {
				["profiles"] = {
					["Default"] = {
						["unit_name"] = {
							["color"] = {
								["b"] = 0.09019607843137255,
								["g"] = 0.8745098039215686,
								["r"] = 0.8627450980392157,
							},
							["class"] = false,
						},
					},
				},
			},
			["GridLayout"] = {
				["profiles"] = {
					["Default"] = {
						["hideTab"] = true,
						["anchorRel"] = "TOPLEFT",
						["BorderB"] = 0.6078431372549019,
						["layouts"] = {
							["party"] = "None",
							["solo"] = "None",
							["arena"] = "None",
						},
						["BackgroundR"] = 0.02,
						["FrameLock"] = true,
						["BorderR"] = 0.6078431372549019,
						["Spacing"] = 6,
						["BackgroundG"] = 0.02,
						["PosY"] = -311.1103383733839,
						["layout"] = "None",
						["BackgroundA"] = 0.9,
						["BorderG"] = 0.6078431372549019,
						["PosX"] = 229.7776683887274,
						["Padding"] = 0,
						["BackgroundB"] = 0.02,
						["borderTexture"] = "None",
					},
				},
			},
			["GridStatusMana"] = {
				["profiles"] = {
					["Default"] = {
						["alert_lowMana"] = {
							["color"] = {
								["r"] = 0.31,
								["g"] = 0.45,
								["b"] = 0.63,
							},
						},
					},
				},
			},
			["GridStatusHealth"] = {
				["profiles"] = {
					["Default"] = {
						["unit_health"] = {
							["deadAsFullHealth"] = false,
						},
					},
				},
			},
		},
	}
end

-- ButtonFacade Settings
local UploadBFacade = function()
	if ButtonFacadeDB then wipe(ButtonFacadeDB) end
	ButtonFacadeDB = {
		["profileKeys"] = {
			["Kkthnx - Lordaeron"] = "Default",
		},
		["profiles"] = {
			["Default"] = {
				["Gloss"] = 0,
				["Backdrop"] = true,
				["SkinID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
			},
		},
	}
end

-- ChatFilter Settings
local UploadChatFilter = function()
	if ChatConsolidateDB then wipe(ChatConsolidateDB) end

end

-- ThreatPlates
local UploadThreatPlates = function()
	if ThreatPlates3BetaDB then wipe(ThreatPlates3BetaDB) end
	ThreatPlates3BetaDB = {
		["char"] = {
			["Kkthnx - Lordaeron"] = {
				["specInfo"] = {
					{
						nil, -- [1]
						51, -- [2]
					}, -- [1]
				},
				["specName"] = {
					"Beast Mastery", -- [1]
					"Marksmanship", -- [2]
					"Survival", -- [3]
				},
				["welcome"] = true,
			},
		},
		["profileKeys"] = {
			["Kkthnx - Lordaeron"] = "Default",
		},
		["profiles"] = {
			["Default"] = {
				["OldSetting"] = false,
				["friendlyClass"] = {
					["toggle"] = false,
				},
				["threat"] = {
					["nonCombat"] = false,
					["useAlpha"] = false,
					["useScale"] = false,
					["useType"] = false,
					["toggle"] = {
						["Elite"] = false,
						["Boss"] = false,
						["Neutral"] = false,
						["Normal"] = false,
					},
					["useHPColor"] = false,
					["ON"] = false,
				},
				["nHPbarColor"] = {
					["r"] = 0.6509803921568628,
					["g"] = 0.6313725490196078,
					["b"] = 0.3490196078431372,
				},
				["eliteWidget"] = {
					["ON"] = false,
				},
				["cache"] = {
				},
				["customColor"] = {
					["toggle"] = true,
				},
				["settings"] = {
					["specialText"] = {
						["typeface"] = "KkUI Unitframe",
						["y"] = 0,
						["size"] = 10,
					},
					["level"] = {
						["y"] = 1,
						["x"] = 47,
						["typeface"] = "KkUI Unitframe",
						["vertical"] = "CENTER",
						["size"] = 11,
					},
					["normal"] = {
						["threatcolor"] = {
							["MEDIUM"] = {
								["a"] = 0,
							},
							["LOW"] = {
								["a"] = 0,
							},
							["HIGH"] = {
								["a"] = 0,
							},
						},
					},
					["dangerskull"] = {
						["anchor"] = "RIGHT",
						["x"] = -3,
						["scale"] = 12,
					},
					["specialText2"] = {
						["typeface"] = "KkUI Unitframe",
						["y"] = -40,
						["size"] = 11,
					},
					["name"] = {
						["y"] = 14,
						["typeface"] = "KkUI Unitframe",
						["size"] = 11,
					},
					["castbar"] = {
						["texture"] = "KkUI StatusBar",
					},
					["healthbar"] = {
						["texture"] = "KkUI StatusBar",
					},
				},
				["theme"] = "none",
				["targetWidget"] = {
					["level"] = 20,
				},
				["nameplate"] = {
					["scale"] = {
						["Elite"] = 1,
						["Boss"] = 1.2,
						["Neutral"] = 1,
					},
					["toggle"] = {
						["Totem"] = true,
					},
				},
				["blizzFade"] = {
					["toggle"] = false,
					["amount"] = -0.5,
				},
				["HPbarColor"] = {
					["r"] = 0.78,
					["g"] = 0.25,
					["b"] = 0.25,
				},
				["classWidget"] = {
					["y"] = 0,
					["x"] = -22,
					["scale"] = 20,
					["anchor"] = "LEFT",
				},
				["fHPbarColor"] = {
					["r"] = 0.3098039215686275,
					["g"] = 0.4509803921568628,
					["b"] = 0.6313725490196078,
				},
				["debuffWidget"] = {
					["mode"] = "all",
				},
				["uniqueWidget"] = {
					["y"] = -27,
					["x"] = 9,
					["scale"] = 14,
					["anchor"] = "LEFT",
				},
			},
		},
	}
end

-- Bartender 4
local UploadBartender4 = function()
	if Bartender4DB then wipe(Bartender4DB) end
	Bartender4DB = {
		["namespaces"] = {
			["ActionBars"] = {
				["profiles"] = {
					["Default"] = {
						["actionbars"] = {
							{
								["showgrid"] = true,
								["rows"] = 2,
								["skin"] = {
									["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
								},
								["version"] = 3,
								["position"] = {
									["y"] = -214,
									["x"] = -124.299991607666,
									["point"] = "CENTER",
									["scale"] = 1.1,
								},
								["padding"] = 0,
							}, -- [1]
							{
								["skin"] = {
									["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
								},
								["enabled"] = false,
								["version"] = 3,
								["position"] = {
									["y"] = -227.499923706055,
									["x"] = -231.500183105469,
									["point"] = "CENTER",
								},
							}, -- [2]
							{
								["showgrid"] = true,
								["rows"] = 12,
								["skin"] = {
									["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
								},
								["enabled"] = false,
								["version"] = 3,
								["position"] = {
									["y"] = -67.9999237060547,
									["x"] = -82,
									["point"] = "RIGHT",
								},
								["padding"] = 3,
							}, -- [3]
							{
								["showgrid"] = true,
								["rows"] = 12,
								["fadeout"] = true,
								["skin"] = {
									["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
								},
								["version"] = 3,
								["position"] = {
									["y"] = 242.5499692236002,
									["x"] = -47,
									["point"] = "RIGHT",
									["scale"] = 1.100000023841858,
								},
								["padding"] = 0,
							}, -- [4]
							{
								["showgrid"] = true,
								["skin"] = {
									["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
								},
								["version"] = 3,
								["position"] = {
									["y"] = 44,
									["x"] = -243.1,
									["point"] = "BOTTOM",
									["scale"] = 1.1,
								},
								["padding"] = 0,
							}, -- [5]
							{
								["showgrid"] = true,
								["skin"] = {
									["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
								},
								["buttons"] = 6,
								["version"] = 3,
								["position"] = {
									["y"] = 246.6,
									["x"] = -124.299991607666,
									["point"] = "BOTTOM",
									["scale"] = 1.1,
								},
								["padding"] = 0,
							}, -- [6]
							{
							}, -- [7]
							nil, -- [8]
							{
							}, -- [9]
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
					["Default"] = {
						["version"] = 3,
						["position"] = {
							["y"] = 152.401489257813,
							["x"] = -31.4999389648438,
							["point"] = "BOTTOM",
						},
					},
				},
			},
			["MicroMenu"] = {
				["profiles"] = {
					["Default"] = {
						["enabled"] = false,
						["position"] = {
							["y"] = 41.75,
							["x"] = 37.5,
							["point"] = "BOTTOM",
							["scale"] = 1,
						},
						["skin"] = {
							["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
						},
						["version"] = 3,
						["padding"] = -2,
					},
				},
			},
			["XPBar"] = {
				["profiles"] = {
					["Default"] = {
						["position"] = {
							["y"] = 4.0001220703125,
							["x"] = -519,
							["point"] = "TOP",
						},
						["version"] = 3,
					},
				},
			},
			["BlizzardArt"] = {
				["profiles"] = {
					["Default"] = {
						["position"] = {
							["y"] = 47,
							["x"] = -512,
							["point"] = "BOTTOM",
						},
						["version"] = 3,
					},
				},
			},
			["BagBar"] = {
				["profiles"] = {
					["Default"] = {
						["enabled"] = false,
						["position"] = {
							["y"] = 178.288848876953,
							["x"] = 352.98876953125,
							["point"] = "BOTTOM",
						},
						["skin"] = {
							["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
						},
						["version"] = 3,
					},
				},
			},
			["StanceBar"] = {
				["profiles"] = {
					["Default"] = {
						["fadeout"] = true,
						["version"] = 3,
						["position"] = {
							["y"] = 207.951248168945,
							["x"] = -19.5,
							["point"] = "BOTTOM",
							["scale"] = 1,
						},
						["skin"] = {
							["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
						},
					},
				},
			},
			["Vehicle"] = {
				["profiles"] = {
					["Default"] = {
						["version"] = 3,
						["skin"] = {
							["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
						},
						["position"] = {
							["y"] = 77.9999847412109,
							["x"] = 195.562377929688,
							["point"] = "BOTTOM",
						},
					},
				},
			},
			["PetBar"] = {
				["profiles"] = {
					["Default"] = {
						["version"] = 3,
						["skin"] = {
							["ID"] = "|cff2eb6ffKkthnx's|r |cFFFFB200Normal|r",
						},
						["padding"] = 0,
						["position"] = {
							["y"] = 78,
							["x"] = -170.499983215332,
							["point"] = "BOTTOM",
							["scale"] = 1.1,
						},
					},
				},
			},
			["RepBar"] = {
				["profiles"] = {
					["Default"] = {
						["position"] = {
							["y"] = 4.0001220703125,
							["x"] = -516.500061035156,
							["point"] = "TOP",
						},
						["version"] = 3,
					},
				},
			},
		},
		["profileKeys"] = {
			["Kkthnx - Lordaeron"] = "Default",
		},
		["profiles"] = {
			["Default"] = {
				["blizzardVehicle"] = true,
				["focuscastmodifier"] = false,
				["onkeydown"] = false,
				["outofrange"] = "hotkey",
			},
		},
	}
end

-- Nameplate settings
local UploadPlates = function()
	if NameplatesDB then wipe(NameplatesDB) end
	NameplatesDB = {
		["profileKeys"] = {
			["Kkthnx - Lordaeron"] = "Default",
		},
		["profiles"] = {
			["Default"] = {
				["hideUninterruptible"] = true,
				["bindings"] = true,
				["text"] = {
					["name"] = "KkUI Normal",
					["shadowEnabled"] = true,
					["size"] = 10,
				},
				["textureName"] = "KkUI StatusBar",
				["name"] = {
					["name"] = "KkUI Normal",
					["size"] = 11,
					["border"] = "OUTLINE",
					["shadowEnabled"] = true,
				},
				["level"] = {
					["name"] = "KkUI Normal",
					["border"] = "OUTLINE",
					["shadowEnabled"] = true,
				},
			},
			["Kkthnx - Lordaeron"] = {
			},
		},
	}

end

-- ClassTimer settings
local UploadClassTimer = function()
	if ClassTimerDB then wipe(ClassTimerDB) end
	ClassTimerDB = {
		["profileKeys"] = {
			["Kkthnx - Lordaeron"] = "Kkthnx - Lordaeron",
		},
		["profiles"] = {
			["Kkthnx - Lordaeron"] = {
				["Units"] = {
					["player"] = {
						["growup"] = true,
						["y"] = 347.0005207688285,
						["font"] = "KkUI Normal",
						["fontsize"] = 11,
						["differentColors"] = true,
						["x"] = 431.9998238344712,
					},
					["general"] = {
						["differentColors"] = true,
						["growup"] = true,
						["font"] = "KkUI Normal",
						["fontsize"] = 11,
					},
					["focus"] = {
						["debuffs"] = false,
						["growup"] = true,
						["icons"] = false,
						["y"] = 106.9988017871774,
						["x"] = 1234.99982212479,
						["height"] = 4,
						["buffs"] = false,
						["enable"] = false,
						["fontsize"] = 11,
						["click"] = false,
						["differentColors"] = true,
						["alpha"] = 0,
						["width"] = 50,
						["scale"] = 0.1,
						["spacing"] = -5,
						["font"] = "KkUI Normal",
					},
					["target"] = {
						["Poisoncolor"] = {
							0.2901960784313725, -- [1]
							0.7803921568627451, -- [2]
							0.2627450980392157, -- [3]
						},
						["reversed"] = false,
						["Diseasecolor"] = {
							0.7803921568627451, -- [1]
							0.2509803921568627, -- [2]
							0.2509803921568627, -- [3]
						},
						["growup"] = true,
						["y"] = 347.0003106832289,
						["font"] = "KkUI Normal",
						["Cursecolor"] = {
							0.7803921568627451, -- [1]
							0.3372549019607843, -- [2]
							0.7254901960784314, -- [3]
						},
						["fontsize"] = 11,
						["iconSide"] = "RIGHT",
						["Magiccolor"] = {
							0.3098039215686275, -- [1]
							0.4509803921568628, -- [2]
							0.6313725490196078, -- [3]
						},
						["differentColors"] = true,
						["reverseSort"] = false,
						["buffcolor"] = {
							0.1372549019607843, -- [1]
							0.4705882352941176, -- [2]
							0.6509803921568628, -- [3]
						},
						["alwaysshowndebuffcolor"] = {
							0.7725490196078432, -- [1]
							0.6745098039215687, -- [2]
							0.4235294117647059, -- [3]
						},
						["debuffcolor"] = {
							0.6509803921568628, -- [1]
							0.6313725490196078, -- [2]
							0.3490196078431372, -- [3]
						},
						["x"] = 1337.000722511185,
					},
					["sticky"] = {
						["differentColors"] = true,
						["growup"] = true,
						["font"] = "KkUI Normal",
						["fontsize"] = 11,
					},
					["pet"] = {
						["debuffs"] = false,
						["growup"] = true,
						["y"] = 96.99882353431956,
						["font"] = "KkUI Normal",
						["height"] = 4,
						["buffs"] = false,
						["enable"] = false,
						["fontsize"] = 11,
						["differentColors"] = true,
						["alpha"] = 0,
						["width"] = 50,
						["scale"] = 0.1,
						["spacing"] = -5,
						["x"] = 555.0000054025919,
					},
				},
			},
		},
	}
end

-- !ClassColor settings
local UploadColor = function()
	if ClassColorsDB then wipe(ClassColorsDB) end
	ClassColorsDB = {
		["DEATHKNIGHT"] = {
			["b"] = 0.23,
			["g"] = 0.12,
			["r"] = 0.77,
		},
		["WARRIOR"] = {
			["b"] = 0.43,
			["g"] = 0.61,
			["r"] = 0.78,
		},
		["PALADIN"] = {
			["b"] = 0.73,
			["g"] = 0.55,
			["r"] = 0.96,
		},
		["MAGE"] = {
			["b"] = 0.94,
			["g"] = 0.8,
			["r"] = 0.41,
		},
		["PRIEST"] = {
			["b"] = 0.9803921568627451,
			["g"] = 0.9215686274509803,
			["r"] = 0.8627450980392157,
		},
		["WARLOCK"] = {
			["b"] = 0.79,
			["g"] = 0.51,
			["r"] = 0.58,
		},
		["HUNTER"] = {
			["b"] = 0.45,
			["g"] = 0.83,
			["r"] = 0.67,
		},
		["DRUID"] = {
			["b"] = 0.04,
			["g"] = 0.49,
			["r"] = 1,
		},
		["SHAMAN"] = {
			["b"] = 0.87,
			["g"] = 0.44,
			["r"] = 0,
		},
		["ROGUE"] = {
			["b"] = 0.41,
			["g"] = 0.96,
			["r"] = 1,
		},
	}

end

-- XLoot settings
local UploadXLoot = function()
	if XLootADB then wipe(XLootADB) end
	XLootADB = {
		["namespaces"] = {
			["Group"] = {
				["profiles"] = {
					["Default"] = {
						["hook_alert"] = false,
						["roll_width"] = 300,
						["alert_anchor"] = {
							["visible"] = false,
							["y"] = 807.999694824219,
							["x"] = 645.667053222656,
						},
						["roll_anchor"] = {
							["visible"] = false,
							["x"] = 370.444221494004,
							["scale"] = 1.2,
							["y"] = 454.000302361127,
						},
					},
				},
			},
			["Frame"] = {
				["profiles"] = {
					["Default"] = {
						["frame_color_backdrop"] = {
							0.0941176470588235, -- [1]
							0.0941176470588235, -- [2]
							0.0941176470588235, -- [3]
							0.897589601576328, -- [4]
						},
						["quality_color_frame"] = true,
						["loot_row_height"] = 36,
						["loot_color_backdrop"] = {
							0.0705882352941177, -- [1]
							0.0705882352941177, -- [2]
							0.0705882352941177, -- [3]
							0.900000005960465, -- [4]
						},
						["loot_color_gradient"] = {
							1, -- [1]
							1, -- [2]
							1, -- [3]
							0.0903606414794922, -- [4]
						},
						["loot_collapse"] = true,
						["loot_color_info"] = {
							0.772549019607843, -- [1]
							0.772549019607843, -- [2]
							0.772549019607843, -- [3]
							1, -- [4]
						},
						["frame_color_gradient"] = {
							0.501960784313726, -- [1]
							0.501960784313726, -- [2]
							0.501960784313726, -- [3]
							0, -- [4]
						},
						["loot_icon_size"] = 40,
						["font"] = "Interface\\AddOns\\KkthnxUI\\Media\\Fonts\\Normal.ttf",
					},
				},
			},
			["Master"] = {
			},
		},
		["profiles"] = {
			["Default"] = {
				["skin_anchors"] = true,
				["skin"] = "|cff2eb6ffKkthnxUI|r",
			},
		},
	}
end

-- Mapster settings
local UploadMapster = function()
	if MapsterDB then wipe(MapsterDB) end
	MapsterDB = {
		["namespaces"] = {
			["GroupIcons"] = {
			},
			["Coords"] = {
			},
			["FogClear"] = {
				["profiles"] = {
					["Default"] = {
						["version"] = 2,
					},
				},
			},
			["BattleMap"] = {
			},
		},
		["profiles"] = {
			["Default"] = {
				["scale"] = 1.2,
				["mini"] = {
					["scale"] = 1,
					["hideBorder"] = false,
					["disableMouse"] = false,
				},
			},
		},
	}
end

-- Skada settings
local UploadSkada = function()
	if SkadaDB then wipe(SkadaDB) end
	SkadaDB = {
		["profileKeys"] = {
			["Kkthnx - Lordaeron"] = "Default",
			["Pervie - Stormreaver"] = "Default",
		},
		["profiles"] = {
			["Default"] = {
				["windows"] = {
					{
						["barheight"] = 14,
						["barmax"] = 5,
						["barslocked"] = true,
						["background"] = {
							["color"] = {
								["a"] = 0,
							},
							["height"] = 132,
						},
						["y"] = 0,
						["mode"] = "DPS",
						["point"] = "BOTTOMRIGHT",
						["barwidth"] = 217,
						["barspacing"] = 7,
						["x"] = -340,
						["title"] = {
							["bordercolor"] = {
								["a"] = 0,
							},
							["fontsize"] = 12,
							["fontflags"] = "OUTLINE",
							["height"] = 13,
						},
					}, -- [1]
				},
				["showranks"] = false,
			},
		},
	}
end

local UploadMSBT = function()
	if MSBTProfiles_SavedVars then wipe(MSBTProfiles_SavedVars) end
	if MSBT_SavedMedia then wipe(MSBT_SavedMedia) end
	MSBTProfiles_SavedVars = {
		["profiles"] = {
			["Default"] = {
				["powerThrottleDuration"] = 5,
				["normalOutlineIndex"] = 2,
				["partialColoringDisabled"] = true,
				["alwaysShowQuestItems"] = false,
				["hideFullOverheals"] = true,
				["normalFontSize"] = 16,
				["scrollAreas"] = {
					["Incoming"] = {
						["scrollHeight"] = 250,
						["offsetX"] = -215,
						["animationStyle"] = "Straight",
						["behavior"] = "MSBT_NORMAL",
						["offsetY"] = 151,
						["skillIconsDisabled"] = true,
						["direction"] = "Up",
					},
					["Outgoing"] = {
						["scrollHeight"] = 250,
						["offsetX"] = 174,
						["animationStyle"] = "Straight",
						["behavior"] = "MSBT_NORMAL",
						["offsetY"] = 151,
						["skillIconsDisabled"] = true,
						["direction"] = "Up",
					},
					["Notification"] = {
						["offsetX"] = -176,
						["offsetY"] = 201,
					},
					["Static"] = {
						["offsetX"] = -7,
						["offsetY"] = -33,
					},
				},
				["soundsDisabled"] = true,
				["hideMergeTrailer"] = true,
				["triggers"] = {
					["MSBT_TRIGGER_RIPOSTE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_KILL_SHOT"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_DECIMATION"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_BACKLASH"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_OVERPOWER"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_SWORD_AND_BOARD"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_RAMPAGE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_RIME"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_THE_ART_OF_WAR"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_RUNE_STRIKE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_PREDATORS_SWIFTNESS"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_ECLIPSE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_TASTE_FOR_BLOOD"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_LOW_HEALTH"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_LOCK_AND_LOAD"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_TIDAL_WAVES"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_VIPER_STING"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_NIGHTFALL"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_HOT_STREAK"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_LOW_MANA"] = {
						["disabled"] = false,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_SUDDEN_DEATH"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_IMPACT"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_OWLKIN_FRENZY"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_BRAIN_FREEZE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_ERADICATION"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_LOW_PET_HEALTH"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_KILLING_MACHINE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_PVP_TRINKET"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_MISSILE_BARRAGE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_VICTORY_RUSH"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_BLOODSURGE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_CLEARCASTING"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_MOLTEN_CORE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_FINGERS_OF_FROST"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_COUNTER_ATTACK"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_HAMMER_OF_WRATH"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_REVENGE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_EXECUTE"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["MSBT_TRIGGER_FROSTBITE"] = {
						["disabled"] = true,
					},
					["MSBT_TRIGGER_MAELSTROM_WEAPON"] = {
						["disabled"] = true,
					},
				},
				["regenAbilitiesDisabled"] = true,
				["critFontName"] = "KkthnxUI",
				["hotThrottleDuration"] = 5,
				["critOutlineIndex"] = 2,
				["animationSpeed"] = 140,
				["skillIconsDisabled"] = true,
				["dotThrottleDuration"] = 5,
				["creationVersion"] = "5.4.78",
				["critFontSize"] = 22,
				["hideSkills"] = true,
				["events"] = {
					["NOTIFICATION_COMBAT_ENTER"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_PC_KILLING_BLOW"] = {
						["disabled"] = true,
						["fontSize"] = false,
					},
					["NOTIFICATION_MONEY"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_DEBUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_REP_LOSS"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_LOOT"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_SOUL_SHARD_CREATED"] = {
						["disabled"] = true,
						["fontSize"] = false,
					},
					["OUTGOING_EVADE"] = {
						["fontSize"] = 16,
					},
					["NOTIFICATION_SKILL_GAIN"] = {
						["disabled"] = true,
					},
					["INCOMING_HEAL_CRIT"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_POWER_LOSS"] = {
						["disabled"] = true,
					},
					["OUTGOING_HEAL_CRIT"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_DEBUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_ITEM_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_EXPERIENCE_GAIN"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_BUFF_FADE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_MONSTER_EMOTE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_COMBAT_LEAVE"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_POWER_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_FULL"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["NOTIFICATION_ENEMY_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_BUFF_STACK"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_EXTRA_ATTACK"] = {
						["disabled"] = true,
						["fontSize"] = false,
					},
					["NOTIFICATION_COOLDOWN"] = {
						["disabled"] = true,
						["fontSize"] = 16,
					},
					["NOTIFICATION_ITEM_BUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_CP_GAIN"] = {
						["disabled"] = true,
					},
					["PET_OUTGOING_EVADE"] = {
						["fontSize"] = false,
					},
					["NOTIFICATION_HONOR_GAIN"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_DEBUFF"] = {
						["disabled"] = true,
					},
					["NOTIFICATION_NPC_KILLING_BLOW"] = {
						["fontSize"] = false,
					},
				},
				["cooldownThreshold"] = 60,
				["hideNames"] = true,
				["normalFontName"] = "KkthnxUI",
				["healThreshold"] = 1000,
				["qualityExclusions"] = {
					true, -- [1]
				},
			},
		},
	}
	MSBT_SavedMedia = {
		["fonts"] = {
			["KkthnxUI"] = "Interface\\AddOns\\KkthnxUI\\Media\\Fonts\\Damage.ttf",
		},
		["sounds"] = {
		},
	}
end

StaticPopupDialogs.SETTINGS_ALL = {
	text = L_POPUP_SETTINGS_ALL,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		if (select(4, GetAddOnInfo("!ClassColors"))) then UploadColor() end
		if (select(4, GetAddOnInfo("Bartender4"))) then UploadBartender4() end
		if (select(4, GetAddOnInfo("ButtonFacade"))) then UploadBFacade() end
		if (select(4, GetAddOnInfo("ChatConsolidate"))) then UploadChatFilter() end
		if (select(4, GetAddOnInfo("ClassTimer"))) then UploadClassTimer() end
		if (select(4, GetAddOnInfo("DBM-Core"))) and C.Skins.DBM then K.UploadDBM() end
		if (select(4, GetAddOnInfo("Grid"))) then UploadGrid() end
		if (select(4, GetAddOnInfo("Mapster"))) then UploadMapster() end
		if (select(4, GetAddOnInfo("MikScrollingBattleText"))) then UploadMSBT() end
		if (select(4, GetAddOnInfo("Nameplates"))) then UploadPlates() end
		if (select(4, GetAddOnInfo("Skada"))) then UploadSkada() end
		if (select(4, GetAddOnInfo("TidyPlates_ThreatPlates"))) then UploadThreatPlates() end
		if (select(4, GetAddOnInfo("XLoot"))) then UploadXLoot() end
		ReloadUI()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	showAlert = true,
	preferredIndex = 3,
}

SlashCmdList.SETTINGS = function(msg)
	if msg == "nameplates" then
		if (select(4, GetAddOnInfo("Nameplates"))) then
			UploadPlates()
			ReloadUI()
		else
			K.Print("Nameplates".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "suf" then
		if (select(4, GetAddOnInfo("ShadowedUnitFrames"))) then
			UploadSUF()
			ReloadUI()
		else
			K.Print("ShadowedUnitFrames".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "azcb" then
		if (select(4, GetAddOnInfo("AzCastBar"))) then
			UploadAzCastBar()
			ReloadUI()
		else
			K.Print("ShadowedUnitFrames".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "threatplates" then
		if (select(4, GetAddOnInfo("TidyPlates_ThreatPlates"))) then
			UploadThreatPlates()
			ReloadUI()
		else
			K.Print("TidyPlates_ThreatPlates".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "classtimer" then
		if (select(4, GetAddOnInfo("ClassTimer"))) then
			UploadClassTimer()
			ReloadUI()
		else
			K.Print("ClassTimer".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "bfacade" then
		if (select(4, GetAddOnInfo("ButtonFacade"))) then
			UploadBFacade()
			ReloadUI()
		else
			K.Print("ButtonFacade".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "color" then
		if (select(4, GetAddOnInfo("!ClassColors"))) then
			UploadColor()
			ReloadUI()
		else
			K.Print("!ClassColors".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "mapster" then
		if (select(4, GetAddOnInfo("Mapster"))) then
			UploadMapster()
			ReloadUI()
		else
			K.Print("Mapster".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "chatfilter" then
		if (select(4, GetAddOnInfo("ChatConsolidate"))) then
			UploadChatFilter()
			ReloadUI()
		else
			K.Print("ChatConsolidate".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "bartender4" then
		if (select(4, GetAddOnInfo("Bartender4"))) then
			UploadBartender4()
			ReloadUI()
		else
			K.Print("Bartender4".."|cffffe02e"..L_INFO_NOT_INSTALLED.."|r")
		end
	elseif msg == "grid" then
		if (select(4, GetAddOnInfo("Grid"))) then
			UploadGrid()
			ReloadUI()
		else
			K.Print("Grid".."|cffffe02e"..L_INFO_NOT_INSTALLED.."|r")
		end
	elseif msg == "xloot" then
		if (select(4, GetAddOnInfo("XLoot"))) then
			UploadXLoot()
			ReloadUI()
		else
			K.Print("XLoot".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "skada" then
		if (select(4, GetAddOnInfo("Skada"))) then
			UploadSkada()
			ReloadUI()
		else
			K.Print("Skada".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "msbt" then
		if (select(4, GetAddOnInfo("MikScrollingBattleText"))) then
			UploadMSBT()
			ReloadUI()
		else
			K.Print("MikScrollingBattleText".."|cffffe02e"..L_INFO_NOT_INSTALLED)
		end
	elseif msg == "all" then
		StaticPopup_Show("SETTINGS_ALL")
	else
		print("|cffffe02e"..L_INFO_SETTINGS_ALL.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_SUF.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_AZCB.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_BT4.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_BUTTONFACADE.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_CHATCONSOLIDATE.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_CLASSCOLOR.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_CLASSTIMER.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_GRID.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_MAPSTER.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_MSBT.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_PLATES.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_SKADA.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_THREATPLATES.."|r")
		print("|cffffe02e"..L_INFO_SETTINGS_XLOOT.."|r")
	end
end
SLASH_SETTINGS1 = "/settings"
SLASH_SETTINGS2 = "/profiles"