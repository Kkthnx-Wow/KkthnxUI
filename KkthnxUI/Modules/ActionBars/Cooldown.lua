--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Style Blizzard's native cooldown countdown numbers on action buttons.
-- - Design: ElvUI-style — engine renders text (secret-safe in Midnight); we only
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

	-- COMPAT: Option to ignore WeakAuras if they handle their own cooldown text.
	local frameName = cooldown.GetName and cooldown:GetName()
	if C["ActionBar"]["OverrideWA"] and frameName and strfind(frameName, "WeakAuras") then
		cooldown.noCooldownCount = true
		return
	end

	if cooldown.SetHideCountdownNumbers then
		cooldown:SetHideCountdownNumbers(false)
	end

	-- NOTE: MmssTH repurposed as abbrev threshold (TenthTH is no longer used).
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

-- ---------------------------------------------------------------------------
-- INITIALIZATION
-- ---------------------------------------------------------------------------

function Module:OnEnable()
	if not C["ActionBar"]["Cooldown"] then
		return
	end

	-- REASON: Hook the metatable of standard ActionButton cooldowns to catch all instances.
	local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldownIndex, "SetCooldown", Module.StyleCooldown)
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", Module.HideCooldownNumbers)

	-- REASON: Let the engine render countdown numbers (secret-safe in Midnight).
	SetCVar("countdownForCooldowns", 1)
end
