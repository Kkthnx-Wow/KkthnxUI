local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Installer")

local _G = _G
local table_wipe = _G.table.wipe

local function ForceHekiliOptions()
	if not IsAddOnLoaded("Hekili") then
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
						["primaryWidth"] = 40,
						["rel"] = "CENTER",
						["delays"] = {
							["font"] = "Friz Quadrata TT",
						},
						["captions"] = {
							["font"] = "Friz Quadrata TT",
						},
						["targets"] = {
							["font"] = "Friz Quadrata TT",
						},
						["y"] = 91.49479675292969,
						["x"] = -246.2991485595703,
						["keybindings"] = {
							["font"] = "Friz Quadrata TT",
						},
						["primaryHeight"] = 40,
					},
					["Cooldowns"] = {
						["primaryWidth"] = 40,
						["rel"] = "CENTER",
						["delays"] = {
							["font"] = "Friz Quadrata TT",
						},
						["captions"] = {
							["font"] = "Friz Quadrata TT",
						},
						["targets"] = {
							["font"] = "Friz Quadrata TT",
						},
						["y"] = 91.58060455322266,
						["x"] = -201.3146667480469,
						["keybindings"] = {
							["font"] = "Friz Quadrata TT",
						},
						["primaryHeight"] = 40,
					},
					["Primary"] = {
						["primaryWidth"] = 40,
						["rel"] = "CENTER",
						["targets"] = {
							["font"] = "Friz Quadrata TT",
						},
						["captions"] = {
							["font"] = "Friz Quadrata TT",
						},
						["keybindings"] = {
							["font"] = "Friz Quadrata TT",
						},
						["queue"] = {
							["width"] = 40,
							["height"] = 40,
						},
						["y"] = 45,
						["x"] = -291.454833984375,
						["primaryHeight"] = 40,
						["delays"] = {
							["font"] = "Friz Quadrata TT",
						},
					},
					["AOE"] = {
						["primaryWidth"] = 40,
						["rel"] = "CENTER",
						["keybindings"] = {
							["font"] = "Friz Quadrata TT",
						},
						["captions"] = {
							["font"] = "Friz Quadrata TT",
						},
						["queue"] = {
							["width"] = 40,
							["height"] = 40,
						},
						["y"] = -0.7357177734375,
						["x"] = -291.455810546875,
						["primaryHeight"] = 40,
						["targets"] = {
							["font"] = "Friz Quadrata TT",
						},
						["delays"] = {
							["font"] = "Friz Quadrata TT",
						},
					},
					["Defensives"] = {
						["primaryWidth"] = 40,
						["rel"] = "CENTER",
						["delays"] = {
							["font"] = "Friz Quadrata TT",
						},
						["captions"] = {
							["font"] = "Friz Quadrata TT",
						},
						["targets"] = {
							["font"] = "Friz Quadrata TT",
						},
						["y"] = 91.4949722290039,
						["x"] = -291.2839965820313,
						["keybindings"] = {
							["font"] = "Friz Quadrata TT",
						},
						["primaryHeight"] = 40,
					},
				},
			},
		},
	}

	KkthnxUIDB.Variables["HekiliRequest"] = false
end

local function ForceMaxDPSOptions()
	if not IsAddOnLoaded("MaxDps") then
		return
	end

	if MaxDpsOptions then
		table_wipe(MaxDpsOptions)
	end

	MaxDpsOptions = {
		["global"] = {
			["customRotations"] = {},
			["customTexture"] = "Interface\\BUTTONS\\CheckButtonHilight-Blue",
			["debugMode"] = false,
			["disableButtonGlow"] = true,
			["disabledInfo"] = true,
			["sizeMult"] = 1.8,
			["texture"] = "Interface\\Cooldown\\star4",
		},
	}

	KkthnxUIDB.Variables["MaxDpsRequest"] = false
end

local function ForceDBMOptions()
	if not IsAddOnLoaded("DBM-Core") then
		return
	end

	if DBT_AllPersistentOptions then
		table_wipe(DBT_AllPersistentOptions)
	end

	DBT_AllPersistentOptions = {
		["Default"] = {
			["DBM"] = {
				["Scale"] = 1,
				["HugeScale"] = 1,
				["ExpandUpwards"] = true,
				["ExpandUpwardsLarge"] = true,
				["BarXOffset"] = 0,
				["BarYOffset"] = 100,
				["TimerPoint"] = "LEFT",
				["TimerX"] = 122,
				["TimerY"] = -300,
				["Width"] = 174,
				["Height"] = 20,
				["HugeWidth"] = 194,
				["HugeBarXOffset"] = 0,
				["HugeBarYOffset"] = 10,
				["HugeTimerPoint"] = "CENTER",
				["HugeTimerX"] = 290,
				["HugeTimerY"] = 20,
				["FontSize"] = 10,
				["StartColorR"] = 1,
				["StartColorG"] = 0.7,
				["StartColorB"] = 0,
				["EndColorR"] = 1,
				["EndColorG"] = 0,
				["EndColorB"] = 0,
				["Texture"] = C["Media"].Statusbars.KkthnxUIStatusbar,
			},
		},
	}

	if not _G.DBM_AllSavedOptions["Default"] then
		_G.DBM_AllSavedOptions["Default"] = {}
	end
	_G.DBM_AllSavedOptions["Default"]["WarningY"] = -170
	_G.DBM_AllSavedOptions["Default"]["WarningX"] = 0
	_G.DBM_AllSavedOptions["Default"]["WarningFontStyle"] = "OUTLINE"
	_G.DBM_AllSavedOptions["Default"]["SpecialWarningX"] = 0
	_G.DBM_AllSavedOptions["Default"]["SpecialWarningY"] = -260
	_G.DBM_AllSavedOptions["Default"]["SpecialWarningFontStyle"] = "OUTLINE"
	_G.DBM_AllSavedOptions["Default"]["HideObjectivesFrame"] = false
	_G.DBM_AllSavedOptions["Default"]["WarningFontSize"] = 18
	_G.DBM_AllSavedOptions["Default"]["SpecialWarningFontSize2"] = 24

	KkthnxUIDB.Variables["DBMRequest"] = false
end

local function ForceSkadaOptions()
	if not IsAddOnLoaded("Skada") then
		return
	end

	if SkadaDB then
		table_wipe(SkadaDB)
	end

	SkadaDB = {
		["hasUpgraded"] = true,
		["profiles"] = {
			["Default"] = {
				["windows"] = {
					{
						["barheight"] = 18,
						["classicons"] = false,
						["barslocked"] = true,
						["y"] = 28,
						["x"] = -3,
						["title"] = {
							["color"] = {
								["a"] = 0.3,
								["b"] = 0,
								["g"] = 0,
								["r"] = 0,
							},
							["font"] = "",
							["borderthickness"] = 0,
							["fontflags"] = "OUTLINE",
							["fontsize"] = 14,
							["texture"] = "normTex",
						},
						["barfontflags"] = "OUTLINE",
						["point"] = "BOTTOMRIGHT",
						["mode"] = "",
						["barwidth"] = 300,
						["barbgcolor"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["barfontsize"] = 14,
						["background"] = {
							["height"] = 180,
							["texture"] = "None",
							["bordercolor"] = {
								["a"] = 0,
							},
						},
						["bartexture"] = "KKUI_Statusbar",
					},
				},
				["tooltiprows"] = 10,
				["setstokeep"] = 30,
				["tooltippos"] = "topleft",
				["reset"] = {
					["instance"] = 3,
					["join"] = 1,
				},
			},
		},
	}

	KkthnxUIDB.Variables["SkadaRequest"] = false
end

local function ForceCursorTrail()
	if not IsAddOnLoaded("CursorTrail") then
		return
	end

	if CursorTrail_PlayerConfig then
		table_wipe(CursorTrail_PlayerConfig)
	end

	CursorTrail_PlayerConfig = {
		["FadeOut"] = false,
		["UserOfsY"] = 0,
		["UserShowMouseLook"] = false,
		["ModelID"] = 166492,
		["UserAlpha"] = 0.9,
		["UserOfsX"] = 0.1,
		["UserScale"] = 0.4,
		["UserShadowAlpha"] = 0,
		["UserShowOnlyInCombat"] = false,
		["Strata"] = "HIGH",
	}

	KkthnxUIDB.Variables["CursorTrailRequest"] = false
end

local function ForceBigwigs()
	if not IsAddOnLoaded("BigWigs") then
		return
	end

	if BigWigs3DB then
		table_wipe(BigWigs3DB)
	end

	BigWigs3DB = {
		["namespaces"] = {
			["BigWigs_Plugins_Bars"] = {
				["profiles"] = {
					["Default"] = {
						["outline"] = "OUTLINE",
						["fontSize"] = 12,
						["BigWigsAnchor_y"] = 336,
						["BigWigsAnchor_x"] = 16,
						["BigWigsAnchor_width"] = 175,
						["growup"] = true,
						["interceptMouse"] = false,
						["barStyle"] = "KKUI_Statusbar",
						["LeftButton"] = {
							["emphasize"] = false,
						},
						["font"] = K.UIFont,
						["onlyInterceptOnKeypress"] = true,
						["emphasizeMultiplier"] = 1,
						["BigWigsEmphasizeAnchor_x"] = 810,
						["BigWigsEmphasizeAnchor_y"] = 350,
						["BigWigsEmphasizeAnchor_width"] = 220,
						["emphasizeGrowup"] = true,
					},
				},
			},
			["BigWigs_Plugins_Super Emphasize"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 28,
						["font"] = K.UIFont,
					},
				},
			},
			["BigWigs_Plugins_Messages"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 18,
						["font"] = K.UIFont,
						["BWEmphasizeCountdownMessageAnchor_x"] = 665,
						["BWMessageAnchor_x"] = 616,
						["BWEmphasizeCountdownMessageAnchor_y"] = 530,
						["BWMessageAnchor_y"] = 305,
					},
				},
			},
			["BigWigs_Plugins_Proximity"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 18,
						["font"] = K.UIFont,
						["posy"] = 346,
						["width"] = 140,
						["posx"] = 1024,
						["height"] = 120,
					},
				},
			},
			["BigWigs_Plugins_Alt Power"] = {
				["profiles"] = {
					["Default"] = {
						["posx"] = 1002,
						["fontSize"] = 14,
						["font"] = K.UIFont,
						["fontOutline"] = "OUTLINE",
						["posy"] = 490,
					},
				},
			},
		},
		["profiles"] = {
			["Default"] = {
				["fakeDBMVersion"] = true,
			},
		},
	}

	KkthnxUIDB.Variables["BWRequest"] = false
end

function Module:ForceAddonSkins()
	if KkthnxUIDB.Variables["DBMRequest"] then
		ForceDBMOptions()
	end

	if KkthnxUIDB.Variables["SkadaRequest"] then
		ForceSkadaOptions()
	end

	if KkthnxUIDB.Variables["BWRequest"] then
		ForceBigwigs()
	end

	if KkthnxUIDB.Variables["MaxDpsRequest"] then
		ForceMaxDPSOptions()
	end

	if KkthnxUIDB.Variables["CursorTrailRequest"] then
		ForceCursorTrail()
	end

	if KkthnxUIDB.Variables["HekiliRequest"] then
		ForceHekiliOptions()
	end
end
