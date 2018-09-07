local K, C = unpack(select(2, ...))
if K.CheckAddOnState("OmniCC") or K.CheckAddOnState("ncCooldown") or K.CheckAddOnState("CooldownCount") or C["ActionBar"].Cooldowns ~= true then
	return
end

local _G = _G
local format = string.format
local floor = math.floor

local tonumber = tonumber
local GetTime = _G.GetTime

OmniCC = true
local ICON_SIZE = 36
local DAY, HOUR, MINUTE = 86400, 3600, 60
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY / 2 + 0.5, HOUR / 2 + 0.5, MINUTE / 2 + 0.5

local CooldownFont = K.GetFont(C["ActionBar"].Font)
local CooldownFontSize = 20
local CooldownMinScale = 0.5
local CooldownMinDuration = 2

local EXPIRING_DURATION = 8
local EXPIRING_FORMAT = K.RGBToHex(1, 0, 0) .. "%.1f|r"
local SECONDS_FORMAT = K.RGBToHex(1, 1, 0) .. "%d|r"
local MINUTES_FORMAT = K.RGBToHex(1, 1, 1) .. "%dm|r"
local HOURS_FORMAT = K.RGBToHex(0.4, 1, 1) .. "%dh|r"
local DAYS_FORMAT = K.RGBToHex(0.4, 0.4, 1) .. "%dh|r"

local function GetFormattedTime(s)
	if s < MINUTEISH then
		local seconds = tonumber(K.Round(s))
		if seconds > EXPIRING_DURATION then
			return SECONDS_FORMAT, seconds, s - (seconds - .51)
		else
			return EXPIRING_FORMAT, s, .051
		end
	elseif s < HOURISH then
		local minutes = tonumber(K.Round(s/MINUTE))
		return MINUTES_FORMAT, minutes, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	elseif s < DAYISH then
		local hours = tonumber(K.Round(s/HOUR))
		return HOURS_FORMAT, hours, hours > 1 and (s - (hours * HOUR - HALFHOURISH)) or (s - HOURISH)
	else
		local days = tonumber(K.Round(s/DAY))
		return DAYS_FORMAT, days, days > 1 and (s - (days * DAY - HALFDAYISH)) or (s - DAYISH)
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

local function Timer_OnSizeChanged(self, width)
	local fontScale = K.Round(width) / ICON_SIZE
	if fontScale == self.fontScale then
		return
	end

	self.fontScale = fontScale
	if fontScale < CooldownMinScale then
		self:Hide()
	else
		self.text:SetFontObject(CooldownFont)
		self.text:SetFont(select(1, self.text:GetFont()), fontScale * CooldownFontSize, select(3, self.text:GetFont()))
		if self.enabled then
			Timer_ForceUpdate(self)
		end
	end
end

local function Timer_OnUpdate(self, elapsed)
	if self.text:IsShown() then
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
		else
			if (self:GetEffectiveScale() / UIParent:GetEffectiveScale()) < CooldownMinScale then
				self.text:SetText("")
				self.nextUpdate = 1
			else
				local remain = self.duration - (GetTime() - self.start)
				if floor(remain + CooldownMinScale) > 0 then
					local formatString, time, nextUpdate = GetFormattedTime(remain)
					self.text:SetFormattedText(formatString, time)
					self.nextUpdate = nextUpdate
				else
					Timer_Stop(self)
				end
			end
		end
	end
end

local function Timer_Create(self)
	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints(self)

	local timer = CreateFrame("Frame", nil, scaler)
	timer:Hide()
	timer:SetAllPoints(scaler)
	timer:SetScript("OnUpdate", Timer_OnUpdate)

	local text = timer:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER", 1, 0)
	text:SetJustifyH("CENTER")
	timer.text = text

	Timer_OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", function(_, ...)
		Timer_OnSizeChanged(timer, ...)
	end)

	self.timer = timer
	return timer
end

local function Timer_Start(self, start, duration, charges)
	if self:IsForbidden() then
		-- print(self, " is forbidden")
		return
	end

	local remainingCharges = charges or 0

	if self:GetName() and string.find(self:GetName(), "ChargeCooldown") then
		return
	end

	if start > 0 and duration > CooldownMinDuration and remainingCharges < CooldownMinDuration and (not self.noOCC) then
		local timer = self.timer or Timer_Create(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= CooldownMinScale then
			timer:Show()
		end
	else
		local timer = self.timer
		if timer then
			Timer_Stop(timer)
		end
	end
end

hooksecurefunc(getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", Timer_Start)

if not _G["ActionBarButtonEventsFrame"] then
	return
end

local active = {}
local hooked = {}

local function cooldown_OnShow(self)
	active[self] = true
end

local function cooldown_OnHide(self)
	active[self] = nil
end

local function cooldown_ShouldUpdateTimer(self, start, duration, charges, maxCharges)
	local timer = self.timer
	return not (timer and timer.start == start and timer.duration == duration and timer.charges == charges and timer.maxCharges == maxCharges)
end

local function cooldown_Update(self)
	local button = self:GetParent()
	local action = button.action
	local start, duration = GetActionCooldown(action)
	local charges, maxCharges = GetActionCharges(action)

	if cooldown_ShouldUpdateTimer(self, start, duration, charges, maxCharges) then
		Timer_Start(self, start, duration, charges, maxCharges)
	end
end

local EventWatcher = CreateFrame("Frame")
EventWatcher:Hide()
EventWatcher:SetScript("OnEvent", function()
	for cooldown in pairs(active) do
		cooldown_Update(cooldown)
	end
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
	for _, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
		actionButton_Register(frame)
	end
end

hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", actionButton_Register)
