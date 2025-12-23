local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("AddOns")

local table_wipe = table.wipe

local function ImportDeadlyBossModsProfile()
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

function Module:CreateDeadlyBossModsProfile()
	if not K.isDeveloper then
		return
	end

	if KkthnxUIDB.Variables[K.Realm][K.Name].DBMRequest then
		ImportDeadlyBossModsProfile()
	end
end
