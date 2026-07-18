--[[-----------------------------------------------------------------------------
-- Live GUI refresh for action bar visibility, layout, fader, and pet/stance bars.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

local BAR_CONFIG_KEYS = {
	EquipColor = true,
	Grid = true,
	Hotkeys = true,
	Macro = true,
	KeyDown = true,
	ButtonLock = true,
}

local FADER_KEYS = {
	BarFadeGlobal = true,
	BarFadeCombat = true,
	BarFadeTarget = true,
	BarFadeCasting = true,
	BarFadeHealth = true,
	BarFadeVehicle = true,
	BarFadeDelay = true,
	BarPetFade = true,
	BarStanceFade = true,
}

local function ApplyFaderState()
	Module:UpdateFaderState()
	if Module.fadeParent then
		Module.fadeParent:SetAlpha(C["ActionBar"].BarFadeAlpha)
	end
end

local function OnActionBarSetting(configPath)
	local key = configPath:match("^ActionBar%.(.+)$")
	if not key then
		return
	end

	if key:match("^Bar%d+$") then
		Module:UpdateBarVisibility()
	-- BUGFIX: Lua patterns have no `|` alternation (that's regex syntax) — the previous
	-- pattern "^Bar%d+(Size|PerRow|Num|Font)$" could only match a key literally containing
	-- the string "Size|PerRow|Num|Font", so it never matched anything and every Bar1-8
	-- Size/PerRow/Num/Font slider silently failed to apply live. Match each suffix separately.
	elseif key:match("^Bar%d+Size$") or key:match("^Bar%d+PerRow$") or key:match("^Bar%d+Num$") or key:match("^Bar%d+Font$") or key:match("^Bar%d+Flyout$") then
		if key:match("Flyout$") then
			Module:UpdateBarConfig()
		else
			local barName = key:match("^(Bar%d+)")
			Module:UpdateActionSize(barName)
		end
	elseif key:match("^Bar%d+Fade$") then
		ApplyFaderState()
	elseif key == "BarPetSize" or key == "BarPetPerRow" or key == "BarPetFont" then
		Module:UpdateActionSize("BarPet")
	elseif key == "BarStanceSize" or key == "BarStancePerRow" or key == "BarStanceFont" or key == "ShowStance" then
		Module:UpdateStanceBar()
	elseif key == "VehButtonSize" then
		Module:UpdateVehicleButton()
	elseif BAR_CONFIG_KEYS[key] then
		Module:UpdateBarConfig()
	elseif key == "BarFadeAlpha" then
		if Module.fadeParent then
			Module.fadeParent:SetAlpha(C["ActionBar"].BarFadeAlpha)
		end
	elseif FADER_KEYS[key] then
		ApplyFaderState()
	elseif key == "Cooldown" or key == "MmssTH" then
		local cooldown = K:GetModule("Cooldown")
		if cooldown and cooldown.ApplyCooldownSettings then
			cooldown:ApplyCooldownSettings()
		end
		if key == "MmssTH" and cooldown and cooldown.RefreshCooldownThresholds then
			cooldown:RefreshCooldownThresholds()
		end
	elseif key == "DesaturateOnCooldown" or key == "CooldownAlpha" then
		local cooldown = K:GetModule("Cooldown")
		if cooldown and cooldown.ApplyCooldownDesatSetting then
			cooldown:ApplyCooldownDesatSetting()
		end
	elseif key == "Enable" then
		Module:SetActionBarEnabled(C["ActionBar"].Enable)
	elseif key == "MicroMenu" or key == "FadeMicroMenu" then
		Module:CreateMicroMenu()
	elseif key == "CursorRing" then
		Module:CreateCursorRing()
	elseif key == "CursorRingShowCast" or key == "CursorRingCombatOnly" or key == "CursorRingSize" then
		Module:UpdateCursorRing()
	end
end

K:RegisterSettingPrefixCallback("ActionBar.", OnActionBarSetting)
