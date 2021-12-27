local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Installer")

local _G = _G
local table_wipe = _G.table.wipe

-- local function ForceZygorOptions()
-- 	if not IsAddOnLoaded("Zygor") then
-- 		return
-- 	end

-- 	if Zygor then
-- 		table_wipe(Zygor)
-- 	end
-- end

local function ForceHekiliOptions()
	if not IsAddOnLoaded("Hekili") then
		return
	end

	if HekiliDB then
		table_wipe(HekiliDB)
	end

	HekiliDB = {
		["profiles"] = {
			["KkthnxUI"] = {
				["toggles"] = {
					["potions"] = {
						["value"] = true,
					},
					["interrupts"] = {
						["value"] = true,
						["separate"] = true,
					},
					["cooldowns"] = {
						["value"] = true,
						["override"] = true,
					},
					["mode"] = {
						["aoe"] = true,
					},
					["defensives"] = {
						["value"] = true,
						["separate"] = true,
					},
				},
				["displays"] = {
					["AOE"] = {
						["rel"] = "CENTER",
						["delays"] = {
							["font"] = "KkthnxUIFont",
							["fontSize"] = 16,
						},
						["captions"] = {
							["fontSize"] = 16,
							["font"] = "KkthnxUIFont",
						},
						["y"] = -231,
						["targets"] = {
							["font"] = "KkthnxUIFont",
							["fontSize"] = 16,
						},
						["keybindings"] = {
							["fontSize"] = 16,
							["font"] = "KkthnxUIFont",
						},
					},
					["Primary"] = {
						["rel"] = "CENTER",
						["delays"] = {
							["font"] = "KkthnxUIFont",
							["fontSize"] = 16,
						},
						["captions"] = {
							["fontSize"] = 16,
							["font"] = "KkthnxUIFont",
						},
						["y"] = -286,
						["targets"] = {
							["font"] = "KkthnxUIFont",
							["fontSize"] = 16,
						},
						["keybindings"] = {
							["fontSize"] = 16,
							["font"] = "KkthnxUIFont",
						},
					},
					["Defensives"] = {
						["rel"] = "CENTER",
						["delays"] = {
							["font"] = "KkthnxUIFont",
							["fontSize"] = 16,
						},
						["captions"] = {
							["fontSize"] = 16,
							["font"] = "KkthnxUIFont",
						},
						["y"] = -48,
						["x"] = -244,
						["targets"] = {
							["font"] = "KkthnxUIFont",
							["fontSize"] = 16,
						},
						["keybindings"] = {
							["fontSize"] = 16,
							["font"] = "KkthnxUIFont",
						},
					},
					["Interrupts"] = {
						["rel"] = "CENTER",
						["delays"] = {
							["font"] = "KkthnxUIFont",
							["fontSize"] = 16,
						},
						["captions"] = {
							["fontSize"] = 16,
							["font"] = "KkthnxUIFont",
						},
						["y"] = -48,
						["x"] = 244,
						["targets"] = {
							["font"] = "KkthnxUIFont",
							["fontSize"] = 16,
						},
						["keybindings"] = {
							["fontSize"] = 16,
							["font"] = "KkthnxUIFont",
						},
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
			["customRotations"] = {
			},
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

-- DBM bars
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
				["BarYOffset"] = 15,
				["TimerPoint"] = "LEFT",
				["TimerX"] = 122,
				["TimerY"] = -300,
				["Width"] = 174,
				["Height"] = 20,
				["HugeWidth"] = 210,
				["HugeBarXOffset"] = 0,
				["HugeBarYOffset"] = 15,
				["HugeTimerPoint"] = "CENTER",
				["HugeTimerX"] = 330,
				["HugeTimerY"] = -42,
				["FontSize"] = 10,
				["StartColorR"] = 1,
				["StartColorG"] = .7,
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

-- Skada
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
					{	["barheight"] = 18,
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
					}, -- [1]
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

-- BigWigs
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
						["font"] = "KKUI_Normal",
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
						["font"] = "KKUI_Normal",
					},
				},
			},
			["BigWigs_Plugins_Messages"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 18,
						["font"] = "KKUI_Normal",
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
						["font"] = "KKUI_Normal",
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
						["font"] = "KKUI_Normal",
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