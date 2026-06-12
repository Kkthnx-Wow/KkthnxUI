local K = KkthnxUI[1]
local Module = K:GetModule("AddOns")

local table_wipe = table.wipe

local function ImportCursorTrailProfile()
	if not C_AddOns.IsAddOnLoaded("CursorTrail") then
		return
	end

	if CursorTrail_PlayerConfig then
		table_wipe(CursorTrail_PlayerConfig)
	end

	CursorTrail_PlayerConfig = {
		["Layers"] = {
			{
				["Strata"] = "HIGH",
				["ShapeColorA"] = 1,
				["IsLayerEnabled"] = true,
				["UserShowMouseLook"] = false,
				["ModelID"] = 166492,
				["UserRotX"] = 0,
				["ShapeColorB"] = 1,
				["UserOfsX"] = 0,
				["UserScale"] = 0.6,
				["UserShadowAlpha"] = 0,
				["UserRotY"] = 0,
				["UserOfsY"] = 0,
				["ShapeSparkle"] = false,
				["ShapeColorG"] = 1,
				["ShapeFileName"] = "",
				["UserAlpha"] = 0.9,
				["UserOfsZ"] = 0,
				["UserShowOnlyInCombat"] = false,
				["FadeOut"] = true,
				["ShapeColorR"] = 1,
				["UserRotZ"] = 0,
			},
			{
				["Strata"] = "HIGH",
				["ShapeColorA"] = 1,
				["IsLayerEnabled"] = false,
				["UserShowMouseLook"] = false,
				["ModelID"] = 0,
				["UserRotX"] = 0,
				["ShapeColorB"] = 1,
				["ShapeFileName"] = "Interface\\Addons\\CursorTrail\\Media\\Ring 1.tga",
				["UserScale"] = 1,
				["UserShadowAlpha"] = 0,
				["UserRotY"] = 0,
				["UserOfsY"] = 0,
				["ShapeSparkle"] = false,
				["ShapeColorG"] = 1,
				["UserOfsX"] = 0,
				["UserAlpha"] = 1,
				["UserOfsZ"] = 0,
				["UserShowOnlyInCombat"] = false,
				["FadeOut"] = false,
				["ShapeColorR"] = 1,
				["UserRotZ"] = 0,
			},
			{
				["Strata"] = "HIGH",
				["ShapeColorA"] = 1,
				["IsLayerEnabled"] = false,
				["UserShowMouseLook"] = false,
				["ModelID"] = 0,
				["UserRotX"] = 0,
				["ShapeColorB"] = 1,
				["ShapeFileName"] = "Interface\\Addons\\CursorTrail\\Media\\Ring 1.tga",
				["UserScale"] = 1,
				["UserShadowAlpha"] = 0,
				["UserRotY"] = 0,
				["UserOfsY"] = 0,
				["ShapeSparkle"] = false,
				["ShapeColorG"] = 1,
				["UserOfsX"] = 0,
				["UserAlpha"] = 1,
				["UserOfsZ"] = 0,
				["UserShowOnlyInCombat"] = false,
				["FadeOut"] = false,
				["ShapeColorR"] = 1,
				["UserRotZ"] = 0,
			},
		},
		["ConfigVersion"] = 2,
		["MasterScale"] = 0.6,
	}

	KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest = false
end

function Module:CreateDCursorTrailProfile()
	if not K.isDeveloper then
		return
	end

	if KkthnxUIDB.Variables[K.Realm][K.Name].CursorTrailRequest then
		ImportCursorTrailProfile()
	end
end
