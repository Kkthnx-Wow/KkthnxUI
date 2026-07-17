--[[-----------------------------------------------------------------------------
-- Live GUI refresh for tooltip anchor, cursor mode, and status bar display.
-- Most other Tooltip.* toggles read C at runtime on the next tooltip show.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Tooltip")

local GameTooltip = _G.GameTooltip
local InCombatLockdown = _G.InCombatLockdown

local STATUS_BAR_KEYS = {
	HealthBarText = true,
	StatusBarHeight = true,
}

local LIVE_APPEARANCE_KEYS = {
	ClassColor = true,
}

local function RefreshTooltipStatusBar()
	if Module.RefreshStatusBarLayout then
		Module:RefreshStatusBarLayout()
	elseif GameTooltip and not GameTooltip:IsForbidden() then
		Module:UpdateStatusBarColor(GameTooltip)
	end
end

local function RefreshTooltipAppearance()
	if GameTooltip and GameTooltip:IsShown() and not GameTooltip:IsForbidden() and Module.ReskinTooltip then
		Module:ReskinTooltip(GameTooltip)
	end
end

local function OnTooltipSetting(configPath)
	local key = configPath:match("^Tooltip%.(.+)$")
	if not key then
		return
	end

	if key == "Enable" then
		if not C["Tooltip"].Enable and GameTooltip and GameTooltip:IsShown() and not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
		return
	elseif key == "TipAnchor" then
		Module:UpdateAnchor()
	elseif key == "CursorMode" then
		Module:UpdateCursorMode()
	elseif key == "CombatHide" then
		if C["Tooltip"].CombatHide and InCombatLockdown() and GameTooltip and GameTooltip:IsShown() then
			GameTooltip:Hide()
		end
	elseif STATUS_BAR_KEYS[key] then
		RefreshTooltipStatusBar()
	elseif LIVE_APPEARANCE_KEYS[key] or key == "Icons" or key == "ShowIDs" then
		RefreshTooltipAppearance()
		if key == "Icons" or key == "ClassColor" then
			if Module.RefreshPawnIntegration then
				Module:RefreshPawnIntegration()
			end
		end
		if GameTooltip and GameTooltip:IsShown() and not GameTooltip:IsForbidden() then
			GameTooltip:Hide()
		end
	end
end

K:RegisterSettingPrefixCallback("Tooltip.", OnTooltipSetting)
