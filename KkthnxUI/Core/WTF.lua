local K, C, L, _ = select(2, ...):unpack()

local print = print
local IsAddOnLoaded = IsAddOnLoaded
local ReloadUI = ReloadUI
local wipe = table.wipe

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
		},
		["profiles"] = {
			["Default"] = {
				["windows"] = {
					{
						["barheight"] = 14,
						["barmax"] = 5,
						["scale"] = 1,
						["barslocked"] = true,
						["background"] = {
							["height"] = 132,
							["color"] = {
								["a"] = 0,
							},
						},
						["barwidth"] = 217,
						["barspacing"] = 7,
						["y"] = 119.0008345294831,
						["x"] = -387.0000836375939,
						["title"] = {
							["height"] = 13,
						},
						["point"] = "BOTTOMRIGHT",
						["enabletitle"] = false,
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
	elseif msg == "gird" then
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