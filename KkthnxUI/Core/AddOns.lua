local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Installer")

local table_wipe = table.wipe

local function ForceHekiliOptions()
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
						["keybindings"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["x"] = -246.2991485595703,
						["primaryHeight"] = 40,
						["empowerment"] = {
							["fontSize"] = 14,
						},
						["delays"] = {
							["font"] = "Friz Quadrata TT",
							["fontSize"] = 14,
						},
						["y"] = 91.49479675292969,
					},
					["Cooldowns"] = {
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
						["keybindings"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["x"] = -201.3146667480469,
						["primaryHeight"] = 40,
						["empowerment"] = {
							["fontSize"] = 14,
						},
						["delays"] = {
							["font"] = "Friz Quadrata TT",
							["fontSize"] = 14,
						},
						["y"] = 91.58060455322266,
					},
					["Primary"] = {
						["empowerment"] = {
							["fontSize"] = 14,
						},
						["border"] = {
							["enabled"] = false,
						},
						["flash"] = {
							["enabled"] = true,
						},
						["rel"] = "CENTER",
						["numIcons"] = 4,
						["captions"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["delays"] = {
							["font"] = "Friz Quadrata TT",
							["fontSize"] = 14,
						},
						["queue"] = {
							["width"] = 44,
							["spacing"] = 2,
							["height"] = 44,
							["offsetX"] = 2,
						},
						["y"] = 44,
						["x"] = -330,
						["primaryHeight"] = 44,
						["primaryWidth"] = 44,
						["targets"] = {
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
						["primaryWidth"] = 40,
						["rel"] = "CENTER",
						["delays"] = {
							["font"] = "Friz Quadrata TT",
							["fontSize"] = 14,
						},
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
						["targets"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["y"] = -0.7357177734375,
					},
					["Defensives"] = {
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
						["keybindings"] = {
							["fontSize"] = 14,
							["font"] = "Friz Quadrata TT",
						},
						["x"] = -291.2839965820313,
						["primaryHeight"] = 40,
						["empowerment"] = {
							["fontSize"] = 14,
						},
						["delays"] = {
							["font"] = "Friz Quadrata TT",
							["fontSize"] = 14,
						},
						["y"] = 91.4949722290039,
					},
				},
			},
		},
	}

	KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest = false
end

local function ForceMaxDPSOptions()
	if not C_AddOns.IsAddOnLoaded("MaxDps") then
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

	KkthnxUIDB.Variables[K.Realm][K.Name].MaxDpsRequest = false
end

local function ForceDBMOptions()
	if not C_AddOns.IsAddOnLoaded("DBM-Core") then
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
				["FontSize"] = 12,
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

	local DBM_ASO = DBM_AllSavedOptions
	if not DBM_ASO["Default"] then
		DBM_ASO["Default"] = {}
	end
	DBM_ASO["Default"]["WarningY"] = -170
	DBM_ASO["Default"]["WarningX"] = 0
	DBM_ASO["Default"]["WarningFontStyle"] = "OUTLINE"
	DBM_ASO["Default"]["SpecialWarningX"] = 0
	DBM_ASO["Default"]["SpecialWarningY"] = -260
	DBM_ASO["Default"]["SpecialWarningFontStyle"] = "OUTLINE"
	DBM_ASO["Default"]["HideObjectivesFrame"] = false
	DBM_ASO["Default"]["WarningFontSize"] = 18
	DBM_ASO["Default"]["SpecialWarningFontSize2"] = 24

	KkthnxUIDB.Variables[K.Realm][K.Name].DBMRequest = false
end

local function ForceCursorTrail()
	if not C_AddOns.IsAddOnLoaded("CursorTrail") then
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

	KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest = false
end

function Module:ForceAddonSkins()
	if not K.isDeveloper then -- This is personal for now.
		return
	end

	if KkthnxUIDB.Variables[K.Realm][K.Name].DBMRequest then
		ForceDBMOptions()
	end

	if KkthnxUIDB.Variables[K.Realm][K.Name].MaxDpsRequest then
		ForceMaxDPSOptions()
	end

	if KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest then
		ForceCursorTrail()
	end

	if KkthnxUIDB.Variables[K.Realm][K.Name].HekiliRequest then
		ForceHekiliOptions()
	end
end
