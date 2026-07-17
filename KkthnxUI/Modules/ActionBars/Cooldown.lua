--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Style Blizzard's native cooldown countdown numbers on action buttons.
-- - Design: Engine renders cooldown text (secret-safe in Midnight); we only
--   set font, color, scale, and thresholds. No Lua arithmetic on cooldown values.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Cooldown")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

local _G = _G
local select, strfind = select, string.find
local hooksecurefunc = hooksecurefunc
local GetCVar = _G.GetCVar
local SetCVar = _G.SetCVar
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS

-- NOTE: Visual constants carried over from the old custom renderer.
local FONT_SIZE = 19
local MIN_DURATION = 2.5 -- Ignore short GCD-like durations to reduce visual clutter.
local MIN_SCALE = 0.5 -- Hide numbers on buttons too small to read.
local ICON_SIZE = 36

-- ---------------------------------------------------------------------------
-- NATIVE TEXT REGION
-- ---------------------------------------------------------------------------

-- REASON: Blizzard cooldown frames expose a single FontString via GetRegions().
function Module:GetCooldownText(cooldown)
	if not cooldown.Text then
		cooldown.Text = cooldown:GetRegions()
	end
	return cooldown.Text
end

-- REASON: The Cooldown widget metatable is shared by non-actionbar cooldowns
-- such as nameplate auras. Avoid styling those from this actionbar module,
-- because their size/start/duration values can be protected secrets.
function Module:IsActionCooldown(cooldown)
	local parent = cooldown and cooldown:GetParent()
	local parentCooldown = parent and (parent.cooldown or parent.Cooldown)
	if not parent or parent:IsForbidden() or parentCooldown ~= cooldown then
		return false
	end

	local parentName = parent.GetName and parent:GetName()
	return parentName
		and (
			parentName == "KKUI_LeaveVehicleButton"
			or parentName == "KKUI_ExtraQuestButton"
			or strfind(parentName, "^KKUI_ActionBar%d+Button%d+$")
			or strfind(parentName, "^PetActionButton%d+$")
			or strfind(parentName, "^StanceButton%d+$")
			or strfind(parentName, "^ExtraActionButton%d+$")
			or strfind(parentName, "^SpellFlyoutPopupButton%d+$")
		)
end

-- REASON: Scale the native countdown font to match button size.
function Module:UpdateCooldownFont(cooldown, width, height)
	if not Module:IsActionCooldown(cooldown) then
		return
	end

	local text = Module:GetCooldownText(cooldown)
	if not text then
		return
	end

	if not width or not height then
		width, height = cooldown:GetSize()
	end

	local fontScale = K.Round((width + height) / 2) / ICON_SIZE
	if fontScale == cooldown.fontScale then
		return
	end
	cooldown.fontScale = fontScale

	if fontScale < MIN_SCALE then
		if cooldown.SetHideCountdownNumbers then
			cooldown:SetHideCountdownNumbers(true)
		end
	else
		if cooldown.SetHideCountdownNumbers and not cooldown.noCooldownCount then
			cooldown:SetHideCountdownNumbers(false)
		end

		text:SetFontObject(K.UIFontOutline)
		text:SetFont(select(1, text:GetFont()), fontScale * FONT_SIZE, select(3, text:GetFont()))
		text:SetShadowColor(0, 0, 0, 0)
	end
end

function Module:OnCooldownSizeChanged(cooldown, width, height)
	Module:UpdateCooldownFont(cooldown, width, height)
end

-- ---------------------------------------------------------------------------
-- COOLDOWN STYLING
-- ---------------------------------------------------------------------------

-- REASON: Apply native countdown settings and font styling. Hooked from SetCooldown
-- so every action-button cooldown is configured before the engine draws numbers.
function Module:StyleCooldown()
	local cooldown = self
	if cooldown.__styled or cooldown:IsForbidden() or cooldown.noCooldownCount or not Module:IsActionCooldown(cooldown) then
		return
	end

	if not C["ActionBar"]["Cooldown"] then
		return
	end

	-- COMPAT: Option to ignore WeakAuras if they handle their own cooldown text.
	local frameName = cooldown.GetName and cooldown:GetName()
	if C["ActionBar"]["OverrideWA"] and frameName and strfind(frameName, "WeakAuras") then
		cooldown.noCooldownCount = true
		return
	end

	if cooldown.SetHideCountdownNumbers then
		cooldown:SetHideCountdownNumbers(false)
	end

	-- NOTE: MmssTH is the abbrev threshold for native countdown text.
	if cooldown.SetCountdownAbbrevThreshold then
		cooldown:SetCountdownAbbrevThreshold(C["ActionBar"]["MmssTH"])
	end
	if cooldown.SetMinimumCountdownDuration then
		cooldown:SetMinimumCountdownDuration(MIN_DURATION)
	end

	local text = Module:GetCooldownText(cooldown)
	if text then
		text:ClearAllPoints()
		text:SetPoint("CENTER", cooldown, "CENTER", 1, 0)
		text:SetJustifyH("CENTER")
		text:SetTextColor(K.r, K.g, K.b)
	end

	cooldown.__styled = true
	Module:UpdateCooldownFont(cooldown)

	if not cooldown.__sizeHooked then
		cooldown.__sizeHooked = true
		cooldown:HookScript("OnSizeChanged", function(self, width, height)
			Module:OnCooldownSizeChanged(self, width, height)
		end)
	end
end

function Module:HideCooldownNumbers()
	self.noCooldownCount = true
	if self.SetHideCountdownNumbers then
		self:SetHideCountdownNumbers(true)
	end
end

local function applyCooldownThreshold(cooldown)
	if cooldown and Module:IsActionCooldown(cooldown) and cooldown.SetCountdownAbbrevThreshold then
		cooldown:SetCountdownAbbrevThreshold(C["ActionBar"]["MmssTH"])
	end
end

function Module:RefreshCooldownThresholds()
	if not C["ActionBar"]["Cooldown"] then
		return
	end

	local actionBar = K:GetModule("ActionBar")
	if actionBar and actionBar.buttons then
		for i = 1, #actionBar.buttons do
			local button = actionBar.buttons[i]
			applyCooldownThreshold(button and (button.cooldown or button.Cooldown))
		end
	end

	if NUM_PET_ACTION_SLOTS then
		for i = 1, NUM_PET_ACTION_SLOTS do
			local button = _G["PetActionButton" .. i]
			applyCooldownThreshold(button and (button.cooldown or button.Cooldown))
		end
	end

	for i = 1, 10 do
		local button = _G["StanceButton" .. i]
		applyCooldownThreshold(button and (button.cooldown or button.Cooldown))
	end
end

local originalCountdownCVar

-- ---------------------------------------------------------------------------
-- COOLDOWN DESATURATION (DurationObject curves)
-- ---------------------------------------------------------------------------

local desatCurveAny, desatCurveReal
local cooldownStateFrame

local function EnsureDesatCurves()
	if desatCurveAny or not (C_CurveUtil and C_CurveUtil.CreateCurve and Enum and Enum.LuaCurveType) then
		return
	end
	desatCurveAny = C_CurveUtil.CreateCurve()
	desatCurveAny:SetType(Enum.LuaCurveType.Step)
	desatCurveAny:AddPoint(0, 0)
	desatCurveAny:AddPoint(0.001, 1)
	desatCurveReal = C_CurveUtil.CreateCurve()
	desatCurveReal:SetType(Enum.LuaCurveType.Step)
	desatCurveReal:AddPoint(0, 0)
	desatCurveReal:AddPoint(1.6, 1)
end

function Module:UpdateButtonCooldownDesat(button, cdInfo, durObj, action)
	if not C["ActionBar"].DesaturateOnCooldown then
		if button and button.icon then
			button.icon:SetDesaturation(0)
		end
		return
	end

	local icon = button and button.icon
	if not icon or not action or not HasAction(action) then
		return
	end

	EnsureDesatCurves()
	if not desatCurveAny then
		return
	end

	local val = 0
	if cdInfo and cdInfo.isActive and durObj and durObj.EvaluateRemainingDuration then
		local chargeInfo = C_ActionBar and C_ActionBar.GetActionCharges and C_ActionBar.GetActionCharges(action)
		local useRealCurve = chargeInfo and chargeInfo.maxCharges and chargeInfo.maxCharges > 1
		if not useRealCurve and GetActionInfo(action) == "item" then
			useRealCurve = true
		end
		if useRealCurve then
			if desatCurveReal then
				val = durObj:EvaluateRemainingDuration(desatCurveReal, 0)
			end
		elseif not cdInfo.isOnGCD then
			val = durObj:EvaluateRemainingDuration(desatCurveAny, 0)
		end
	end
	icon:SetDesaturation(val or 0)
end

function Module:UpdateButtonCooldownAlpha(button, cdInfo, durObj, action)
	local cdAlpha = C["ActionBar"].CooldownAlpha or 100
	local icon = button and button.icon
	if not icon then
		return
	end

	if cdAlpha >= 100 then
		icon:SetAlpha(1)
		return
	end

	if not action or not HasAction(action) then
		icon:SetAlpha(1)
		return
	end

	local alphaOn = cdAlpha / 100
	if icon.SetAlphaFromBoolean and cdInfo and cdInfo.isActive and durObj and durObj.IsZero then
		local chargeInfo = C_ActionBar and C_ActionBar.GetActionCharges and C_ActionBar.GetActionCharges(action)
		local useRealCurve = chargeInfo and chargeInfo.maxCharges and chargeInfo.maxCharges > 1
		if not useRealCurve and GetActionInfo(action) == "item" then
			useRealCurve = true
		end
		local realCd = useRealCurve or (not cdInfo.isOnGCD)
		if realCd then
			icon:SetAlphaFromBoolean(durObj:IsZero(), 1, alphaOn)
		else
			icon:SetAlpha(1)
		end
	else
		icon:SetAlpha(1)
	end
end

local function RefreshActionButtonCooldownState(button)
	if not button or not button.icon then
		return
	end
	local action = button.GetAttribute and button:GetAttribute("action")
	if not action or not HasAction(action) then
		button.icon:SetDesaturation(0)
		button.icon:SetAlpha(1)
		return
	end
	if not (C_ActionBar and C_ActionBar.GetActionCooldown and C_ActionBar.GetActionCooldownDuration) then
		return
	end
	local cdInfo = C_ActionBar.GetActionCooldown(action)
	local durObj
	if cdInfo and cdInfo.isActive then
		durObj = C_ActionBar.GetActionCooldownDuration(action)
	end
	Module:UpdateButtonCooldownDesat(button, cdInfo, durObj, action)
	Module:UpdateButtonCooldownAlpha(button, cdInfo, durObj, action)
end

function Module:OnActionBarUpdateCooldown()
	local desatOn = C["ActionBar"].DesaturateOnCooldown
	local alphaOn = (C["ActionBar"].CooldownAlpha or 100) < 100
	if not desatOn and not alphaOn then
		return
	end

	local actionBar = K:GetModule("ActionBar")
	if actionBar and actionBar.buttons then
		for i = 1, #actionBar.buttons do
			RefreshActionButtonCooldownState(actionBar.buttons[i])
		end
	end

	if NUM_PET_ACTION_SLOTS then
		for i = 1, NUM_PET_ACTION_SLOTS do
			RefreshActionButtonCooldownState(_G["PetActionButton" .. i])
		end
	end

	for i = 1, 10 do
		RefreshActionButtonCooldownState(_G["StanceButton" .. i])
	end
end

function Module:InstallCooldownStateHooks()
	if not cooldownStateFrame then
		cooldownStateFrame = CreateFrame("Frame")
		cooldownStateFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
		cooldownStateFrame:SetScript("OnEvent", function()
			Module:OnActionBarUpdateCooldown()
		end)
	end

	if self._visualHooksInstalled then
		return
	end

	local template = _G.ActionButton1Cooldown
	if not template then
		return
	end

	self._visualHooksInstalled = true
	local cooldownIndex = getmetatable(template).__index
	if cooldownIndex.SetCooldownFromDurationObject then
		hooksecurefunc(cooldownIndex, "SetCooldownFromDurationObject", Module.OnActionCooldownSet)
	end
end

function Module:ApplyCooldownDesatSetting()
	local desatOn = C["ActionBar"].DesaturateOnCooldown
	local alphaOn = (C["ActionBar"].CooldownAlpha or 100) < 100
	Module:InstallCooldownStateHooks()
	if desatOn or alphaOn then
		EnsureDesatCurves()
		Module:OnActionBarUpdateCooldown()
	else
		local actionBar = K:GetModule("ActionBar")
		if actionBar and actionBar.buttons then
			for i = 1, #actionBar.buttons do
				local button = actionBar.buttons[i]
				local icon = button and button.icon
				if icon then
					icon:SetDesaturation(0)
					icon:SetAlpha(1)
				end
			end
		end
	end
end

function Module:InstallCooldownHooks()
	if self._hooksInstalled then
		return
	end

	local template = _G.ActionButton1Cooldown
	if not template then
		return
	end

	self._hooksInstalled = true

	local cooldownIndex = getmetatable(template).__index
	local cooldownMethods = {
		"SetCooldown",
		"SetCooldownFromDurationObject",
		"SetCooldownFromExpirationTime",
		"SetCooldownUNIX",
	}
	for i = 1, #cooldownMethods do
		local method = cooldownMethods[i]
		if cooldownIndex[method] then
			hooksecurefunc(cooldownIndex, method, Module.StyleCooldown)
		end
	end
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", Module.HideCooldownNumbers)
end

function Module:OnActionCooldownSet()
	local cooldown = self
	if not Module:IsActionCooldown(cooldown) then
		return
	end
	local desatOn = C["ActionBar"].DesaturateOnCooldown
	local alphaOn = (C["ActionBar"].CooldownAlpha or 100) < 100
	if not desatOn and not alphaOn then
		return
	end
	local parent = cooldown:GetParent()
	if not parent or not parent.icon then
		return
	end
	local action = parent.GetAttribute and parent:GetAttribute("action")
	if not action or not (C_ActionBar and C_ActionBar.GetActionCooldown) then
		return
	end
	local cdInfo = C_ActionBar.GetActionCooldown(action)
	local durObj = cdInfo and cdInfo.isActive and C_ActionBar.GetActionCooldownDuration and C_ActionBar.GetActionCooldownDuration(action)
	Module:UpdateButtonCooldownDesat(parent, cdInfo, durObj, action)
	Module:UpdateButtonCooldownAlpha(parent, cdInfo, durObj, action)
end

function Module:ApplyCooldownSettings()
	local enabled = C["ActionBar"]["Cooldown"]

	if originalCountdownCVar == nil then
		originalCountdownCVar = GetCVar("countdownForCooldowns") or "0"
	end

	if enabled then
		self:InstallCooldownHooks()
		SetCVar("countdownForCooldowns", "1")
		self:RefreshCooldownThresholds()
	else
		SetCVar("countdownForCooldowns", originalCountdownCVar)
	end
end

-- ---------------------------------------------------------------------------
-- INITIALIZATION
-- ---------------------------------------------------------------------------

function Module:OnEnable()
	Module:InstallCooldownStateHooks()
	Module:ApplyCooldownSettings()
	Module:ApplyCooldownDesatSetting()
end
