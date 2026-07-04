--[[-----------------------------------------------------------------------------
-- Live GUI refresh for General category settings (UI scale).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local function OnUIScaleSetting()
	if K.SetupUIScale then
		K:SetupUIScale(true)
		K:SetupUIScale()
	end
end

local function OnSmoothAmountSetting()
	if K.SetSmoothingAmount then
		K:SetSmoothingAmount(C["General"].SmoothAmount)
	end
end

local function RefreshBorderAppearance()
	if K.RefreshBorderColors then
		K:RefreshBorderColors()
	end

	local bags = K:GetModule("Bags")
	if bags and bags.UpdateBagStatus then
		bags:UpdateBagStatus()
	end

	if _G.ChatEdit_UpdateHeader and _G.ChatEdit_ChooseBoxForSend then
		_G.ChatEdit_UpdateHeader(_G.ChatEdit_ChooseBoxForSend())
	end

	local actionBar = K:GetModule("ActionBar")
	if actionBar and actionBar.RefreshActionBarBorders then
		actionBar:RefreshActionBarBorders()
	end
end

local function RefreshTextureAppearance()
	local unitframes = K:GetModule("Unitframes")
	if unitframes and unitframes.UpdateStatusBarTextures then
		unitframes:UpdateStatusBarTextures()
	end

	local tooltip = K:GetModule("Tooltip")
	if tooltip and tooltip.UpdateStatusBarTextures then
		tooltip:UpdateStatusBarTextures()
	end

	if _G.MainMenuMicroButton and _G.MainMenuMicroButton.MainMenuBarPerformanceBar then
		_G.MainMenuMicroButton.MainMenuBarPerformanceBar:SetTexture(K.GetTexture(C["General"].Texture))
	end

	local actionBar = K:GetModule("ActionBar")
	if actionBar and actionBar.RefreshActionBarBorders then
		actionBar:RefreshActionBarBorders()
	end
end

local function OnVersionCheckSetting()
	local versionCheck = K:GetModule("VersionCheck")
	if versionCheck and versionCheck.ApplyVersionCheckSetting then
		versionCheck:ApplyVersionCheckSetting()
	end
end

K:RegisterSettingCallback("General.AutoScale", OnUIScaleSetting)
K:RegisterSettingCallback("General.UIScale", OnUIScaleSetting)
K:RegisterSettingCallback("General.SmoothAmount", OnSmoothAmountSetting)
K:RegisterSettingCallback("General.ColorTextures", RefreshBorderAppearance)
K:RegisterSettingCallback("General.TexturesColor", RefreshBorderAppearance)
K:RegisterSettingCallback("General.Texture", RefreshTextureAppearance)
K:RegisterSettingCallback("General.VersionCheck", OnVersionCheckSetting)

local function OnGeneralSetting(configPath)
	if configPath == "General.MinimapIcon" then
		local misc = K:GetModule("Miscellaneous")
		if misc and misc.ToggleMinimapIcon then
			misc:ToggleMinimapIcon()
		end
	elseif configPath == "General.NoErrorFrame" then
		local misc = K:GetModule("Miscellaneous")
		if misc and misc.CreateErrorFrameToggle then
			misc:CreateErrorFrameToggle()
		end
	elseif configPath == "General.MoveBlizzardFrames" then
		local misc = K:GetModule("Miscellaneous")
		if misc and misc.UpdateMoveBlizzardFrames then
			misc:UpdateMoveBlizzardFrames()
		end
	elseif configPath == "General.BorderStyle" then
		if K.RefreshBorderStyle then
			K:RefreshBorderStyle()
		end
	elseif configPath == "General.NoTutorialButtons" then
		local blizzard = K:GetModule("Blizzard")
		if blizzard and blizzard.UpdateNoTutorialButtons then
			blizzard:UpdateNoTutorialButtons()
		end
	end
end

K:RegisterSettingPrefixCallback("General.", OnGeneralSetting)
