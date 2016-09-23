local K, C, L, _ = select(2, ...):unpack()
if K.IsAddOnEnabled("OmniCC") or K.IsAddOnEnabled("ncCooldown") or K.IsAddOnEnabled("CooldownCount") or C.Cooldown.Enable ~= true then return end

local floor = math.floor
local min = math.min
local tonumber = tonumber

local GetTime = GetTime

if K.IsAddOnEnabled("BigDebuffs") then
	OmniCC = false
else
	OmniCC = true
end

local IconSize = 36
local Day, Hour, Minute = 86400, 3600, 60
local Dayish, Hourish, Minuteish = 3600 * 23.5, 60 * 59.5, 59.5
local HalfDayish, HalfHourish, HalfMinuteish = Day / 2 + 0.5, Hour / 2 + 0.5, Minute / 2 + 0.5

Font = C.Media.Font
FontSize = C.Cooldown.FontSize
MinScale = 0.5
MinDuration = 2.5

local ExpiringDuration = C.Cooldown.Threshold
local ExpiringFormat = K.RGBToHex(1, 0, 0) .. "%.1f|r"
local SecondsFormat = K.RGBToHex(1, 1, 0) .. "%d|r"
local MinutesFormat = K.RGBToHex(1, 1, 1) .. "%dm|r"
local HoursFormat = K.RGBToHex(0.4, 1, 1) .. "%dh|r"
local DaysFormat = K.RGBToHex(0.4, 0.4, 1) .. "%dh|r"

local function getTimeText(s)
	if s < Minuteish then
		local Seconds = tonumber(K.Round(s))
		if Seconds > ExpiringDuration then return SecondsFormat, Seconds, s - (Seconds - .51) else return ExpiringFormat, s, .051 end
	elseif s < Hourish then
		local Minutes = tonumber(K.Round(s/Minute))
		return MinutesFormat, Minutes, Minutes > 1 and (s - (Minutes*Minute - HalfMinuteish)) or (s - Minuteish)
	elseif s < Dayish then
		local Hours = tonumber(K.Round(s/Hour))
		return HoursFormat, Hours, Hours > 1 and (s - (Hours*Hour - HalfHourish)) or (s - Hourish)
	else
		local Days = tonumber(K.Round(s/Day))
		return DaysFormat, Days,  Days > 1 and (s - (Days*Day - HalfDayish)) or (s - Dayish)
	end
end

local function Timer_Stop(self)
	self.enabled = nil
	self:Hide()
end

local function Timer_ForceUpdate(self)
	self.nextUpdate = 0
	self:Show()
end

local function Timer_OnSizeChanged(self, width, height)
	local FontScale = K.Round(width) / IconSize
	if FontScale == self.FontScale then return end

	self.FontScale = FontScale
	if FontScale < MinScale then
		self:Hide()
	else
		self.text:SetFont(Font, FontScale * FontSize, "OUTLINE")
		self.text:SetShadowColor(0, 0, 0, .5)
		self.text:SetShadowOffset(2, -2)
		if self.enabled then Timer_ForceUpdate(self) end
	end
end

local function Timer_OnUpdate(self, elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		local remain = self.duration - (GetTime() - self.start)
		if tonumber(K.Round(remain)) > 0 then
			if (self.FontScale * self:GetEffectiveScale() / UIParent:GetScale()) < MinScale then
				self.text:SetText("")
				self.nextUpdate  = 1
			else
				local formatStr, time, nextUpdate = getTimeText(remain)
				self.text:SetFormattedText(formatStr, time)
				self.nextUpdate = nextUpdate
			end
		else
			Timer_Stop(self)
		end
	end
end

local function Timer_Create(self)
	-- A FRAME TO WATCH FOR ONSIZECHANGED EVENTS
	-- NEEDED SINCE ONSIZECHANGED HAS FUNNY TRIGGERING IF THE FRAME WITH THE HANDLER IS NOT SHOWN
	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints(self)

	local Timer = CreateFrame("Frame", nil, scaler); Timer:Hide()
	Timer:SetAllPoints(scaler)
	Timer:SetScript("OnUpdate", Timer_OnUpdate)

	local Text = Timer:CreateFontString(nil, "OVERLAY")
	Text:SetPoint("CENTER", 2, 0)
	Text:SetJustifyH("CENTER")
	Timer.text = Text

	Timer_OnSizeChanged(Timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", function(self, ...) Timer_OnSizeChanged(Timer, ...) end)

	self.Timer = Timer
	return Timer
end

local function Timer_Start(self, start, duration, charges, maxCharges)
	if self.noOCC then return end

	if start > 0 and duration > MinDuration then
		local Timer = self.Timer or Timer_Create(self)
		local Num = charges or 0
		Timer.start = start
		Timer.duration = duration
		Timer.charges = Num
		Timer.maxCharges = maxCharges
		Timer.enabled = true
		Timer.nextUpdate = 0
		if Timer.FontScale >= MinScale and Timer.charges < 1 then Timer:Show() end
	else
		local Timer = self.Timer
		if Timer then Timer_Stop(Timer) end
	end
end

hooksecurefunc(getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", Timer_Start)

local active = {}
local hooked = {}

local function cooldown_OnShow(self) active[self] = true end
local function cooldown_OnHide(self) active[self] = nil end

K.UpdateActionButtonCooldown = function(self)
	local button = self:GetParent()
	local start, duration, enable = GetActionCooldown(button.action)
	local charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(button.action)

	Timer_Start(self, start, duration, charges, maxCharges)
end

local EventWatcher = CreateFrame("Frame")
EventWatcher:Hide()
EventWatcher:SetScript("OnEvent", function(self, event)
	for cooldown in pairs(active) do K.UpdateActionButtonCooldown(cooldown) end
end)
EventWatcher:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")

local function actionButton_Register(frame)
	local cooldown = frame.cooldown
	if not hooked[cooldown] then
		cooldown:HookScript("OnShow", cooldown_OnShow)
		cooldown:HookScript("OnHide", cooldown_OnHide)
		hooked[cooldown] = true
	end
end

if _G["ActionBarButtonEventsFrame"].frames then
	for i, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do actionButton_Register(frame) end
end
hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", actionButton_Register)