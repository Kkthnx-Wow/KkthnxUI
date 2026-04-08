--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: High-performance cooldown timer replacement.
-- - Design: Provides custom font, scaling, and color coding for action button cooldowns.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Cooldown")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache globals and frequently used table functions.
local _G = _G
local pairs, format, floor, strfind = pairs, string.format, math.floor, string.find
local GetTime, GetActionCooldown, tonumber = _G.GetTime, _G.GetActionCooldown, tonumber

-- NOTE: Constants for visual consistency and logic thresholds.
local FONT_SIZE = 19
local MIN_DURATION = 2.5 -- REASON: Ignore short GCD-like durations to reduce visual clutter.
local MIN_SCALE = 0.5 -- REASON: Hide numbers on buttons too small to read.
local ICON_SIZE = 36

local day, hour, minute = 86400, 3600, 60

local hideNumbers = {}
local active = {}
local hooked = {}

-- ---------------------------------------------------------------------------
-- HELPER FUNCTIONS
-- ---------------------------------------------------------------------------

-- REASON: Converts seconds into a formatted string (Days, Hours, Minutes, Seconds).
-- Includes color coding for urgency (Red for < 3s, Yellow for < 10s).
function Module.FormattedTimer(s, modRate)
	if s >= day then
		return format("%d" .. K.MyClassColor .. "d", s / day + 0.5), s % day
	elseif s > hour then
		return format("%d" .. K.MyClassColor .. "h", s / hour + 0.5), s % hour
	elseif s >= minute then
		if s < C["ActionBar"]["MmssTH"] then
			return format("%d:%.2d", s / minute, s % minute), s - floor(s)
		else
			return format("%d" .. K.MyClassColor .. "m", s / minute + 0.5), s % minute
		end
	else
		local colorStr = (s < 3 and "|cffff0000") or (s < 10 and "|cffffff00") or "|cffcccc33"
		if s < C["ActionBar"]["TenthTH"] then
			return format(colorStr .. "%.1f|r", s), (s - format("%.1f", s)) / modRate
		else
			return format(colorStr .. "%d|r", s + 0.5), (s - floor(s)) / modRate
		end
	end
end

function Module:StopTimer()
	self.enabled = nil
	self:Hide()
end

function Module:ForceUpdate()
	self.nextUpdate = 0
	self:Show()
end

-- REASON: Dynamically adjust font size when the button is resized (e.g. during UI scaling).
function Module:OnSizeChanged(width, height)
	local fontScale = K.Round((width + height) / 2) / ICON_SIZE
	if fontScale == self.fontScale then
		return
	end
	self.fontScale = fontScale

	if fontScale < MIN_SCALE then
		self:Hide()
	else
		self.text:SetFontObject(K.UIFontOutline)
		self.text:SetFont(select(1, self.text:GetFont()), fontScale * FONT_SIZE, select(3, self.text:GetFont()))
		self.text:SetShadowColor(0, 0, 0, 0)

		if self.enabled then
			Module.ForceUpdate(self)
		end
	end
end

-- ---------------------------------------------------------------------------
-- CORE TIMER LOGIC
-- ---------------------------------------------------------------------------

-- REASON: Main update loop for active cooldowns. Calculates remaining time and
-- updates the text based on modRate (haste/slow effects).
function Module:TimerOnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		-- NOTE: Safety check for modRate to avoid arithmetic errors.
		if self.modRate == 0 then
			self.modRate = 1
		end
		local passTime = GetTime() - self.start
		local remain = passTime >= 0 and ((self.duration - passTime) / self.modRate) or self.duration
		if remain > 0 then
			local getTime, nextUpdate = Module.FormattedTimer(remain, self.modRate)
			self.text:SetText(getTime)
			self.nextUpdate = nextUpdate
		else
			Module.StopTimer(self)
		end
	end
end

function Module:ScalerOnSizeChanged(...)
	Module.OnSizeChanged(self.timer, ...)
end

-- REASON: Creates the internal timer frame and font string when a cooldown is first tracked.
function Module:OnCreate()
	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints(self)

	local timer = CreateFrame("Frame", nil, scaler)
	timer:Hide()
	timer:SetAllPoints(scaler)
	timer:SetScript("OnUpdate", Module.TimerOnUpdate)
	scaler.timer = timer

	local text = timer:CreateFontString(nil, "BACKGROUND")
	text:SetPoint("CENTER", 1, 0)
	text:SetJustifyH("CENTER")
	timer.text = text

	Module.OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", Module.ScalerOnSizeChanged)

	self.timer = timer
	return timer
end

-- REASON: Main entry point for starting a cooldown timer. Hooks into Blizzard's SetCooldown.
function Module:StartTimer(start, duration, modRate)
	-- NOTE: Avoid forbidden frames (e.g. secure frames in combat that haven't been styled).
	if self:IsForbidden() then
		return
	end
	if self.noCooldownCount or hideNumbers[self] then
		return
	end

	-- COMPAT: Option to ignore WeakAuras if they handle their own cooldown text.
	local frameName = self.GetName and self:GetName()
	if C["ActionBar"]["OverrideWA"] and frameName and strfind(frameName, "WeakAuras") then
		self.noCooldownCount = true
		return
	end

	local parent = self:GetParent()
	start = tonumber(start) or 0
	duration = tonumber(duration) or 0
	modRate = tonumber(modRate) or 1

	if start > 0 and duration > MIN_DURATION then
		local timer = self.timer or Module.OnCreate(self)
		timer.start = start
		timer.duration = duration
		timer.modRate = modRate
		timer.enabled = true
		timer.nextUpdate = 0

		-- NOTE: Cleanup logic for charge-based cooldowns to prevent overlapping timers.
		local charge = parent and parent.chargeCooldown
		local chargeTimer = charge and charge.timer
		if chargeTimer and chargeTimer ~= timer then
			Module.StopTimer(chargeTimer)
		end

		if timer.fontScale and timer.fontScale >= MIN_SCALE then
			timer:Show()
		end
	elseif self.timer then
		Module.StopTimer(self.timer)
	end

	-- NOTE: Sync visibility with Action Bar Fader if it's currently hiding the bar.
	if parent and parent.__faderParent then
		if self:GetEffectiveAlpha() > 0 then
			self:Show()
		else
			self:Hide()
		end
	end

	-- REASON: Suppress Blizzard's default numbers to avoid double-display.
	if self.SetHideCountdownNumbers then
		self:SetHideCountdownNumbers(true)
	end
end

function Module:HideCooldownNumbers()
	hideNumbers[self] = true
	if self.timer then
		Module.StopTimer(self.timer)
	end
end

function Module:CooldownOnShow()
	active[self] = true
end

function Module:CooldownOnHide()
	active[self] = nil
end

local function shouldUpdateTimer(self, start)
	local timer = self.timer
	if not timer then
		return true
	end
	return timer.start ~= start
end

function Module:CooldownUpdate()
	local button = self:GetParent()
	local start, duration, modRate = GetActionCooldown(button.action)

	if shouldUpdateTimer(self, start) then
		Module.StartTimer(self, start, duration, modRate)
	end
end

function Module:ActionbarUpateCooldown()
	for cooldown in pairs(active) do
		Module.CooldownUpdate(cooldown)
	end
end

-- ---------------------------------------------------------------------------
-- INITIALIZATION
-- ---------------------------------------------------------------------------

function Module:OnSetHideCountdownNumbers(hide)
	local disable = not (hide or self.noCooldownCount or self:IsForbidden())
	if disable then
		self:SetHideCountdownNumbers(true)
	end
end

function Module:OnEnable()
	if not C["ActionBar"]["Cooldown"] then
		return
	end

	-- REASON: Hook the metatable of standard ActionButton cooldowns to catch all instances.
	local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldownIndex, "SetCooldown", Module.StartTimer)
	hooksecurefunc(cooldownIndex, "SetHideCountdownNumbers", Module.OnSetHideCountdownNumbers)
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", Module.HideCooldownNumbers)

	K:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", Module.ActionbarUpateCooldown)

	-- WARNING: Ensure the Blizzard CVar is disabled to prevent native number rendering.
	SetCVar("countdownForCooldowns", 0)
end
