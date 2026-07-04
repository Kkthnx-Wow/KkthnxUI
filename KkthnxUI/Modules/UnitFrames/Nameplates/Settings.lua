--[[-----------------------------------------------------------------------------
-- Live GUI refresh for nameplate settings (replaces GUIConfig hook functions).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local CVAR_SETTINGS = {
	["Nameplate.InsideView"] = true,
	["Nameplate.MinScale"] = true,
	["Nameplate.MaxScale"] = true,
	["Nameplate.MinAlpha"] = true,
	["Nameplate.MaxAlpha"] = true,
	["Nameplate.VerticalSpacing"] = true,
	["Nameplate.SelectedScale"] = true,
	["Nameplate.CVarOnlyNames"] = true,
	["Nameplate.CVarShowNPCs"] = true,
}

local function OnNameplateSetting(configPath)
	if CVAR_SETTINGS[configPath] then
		Module:UpdatePlateCVars()
	end

	if configPath == "Nameplate.ShowPlayerPlate" then
		Module:TogglePlayerPlate()
		return
	elseif configPath == "Nameplate.PPPowerText" then
		Module:TogglePlatePower()
		return
	elseif configPath == "Nameplate.PPHideOOC" then
		Module:TogglePlateVisibility()
		return
	elseif configPath == "Nameplate.NameplateClassPower" then
		Module:ToggleTargetClassPower()
	elseif configPath == "Nameplate.QuestIndicator" or configPath == "Nameplate.QuestProgressMode" or configPath == "Nameplate.QuestShowPartyQuest" or configPath == "Nameplate.QuestProgressFormat" or configPath == "Nameplate.QuestProgressModifier" then
		Module:RefreshAllQuestIndicators()
		return
	elseif configPath == "Nameplate.CustomUnitColor" then
		Module:CreateUnitTable()
	elseif configPath == "Nameplate.Smooth" then
		Module:UpdateNameplateSmooth()
		return
	elseif configPath == "Nameplate.Enable" then
		Module:SetNameplatesEnabled(C["Nameplate"].Enable)
		return
	end

	Module:RefreshNameplates()
end

K:RegisterSettingPrefixCallback("Nameplate.", OnNameplateSetting)
