local K, C = unpack(select(2, ...))
if K.CheckAddOnState("OmniCC") or K.CheckAddOnState("ncCooldown") or K.CheckAddOnState("CooldownCount") or C["ActionBar"].Cooldowns ~= true then
	return
end

local _G = _G
local floor = math.floor
local select = select
local tonumber = tonumber

local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime
local hooksecurefunc = _G.hooksecurefunc

OmniCC = true
local ICON_SIZE = 36
local DAY, HOUR, MINUTE = 86400, 3600, 60
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY / 2 + 0.5, HOUR / 2 + 0.5, MINUTE / 2 + 0.5

local CooldownFont = K.GetFont(C["ActionBar"].Font)
local CooldownFontSize = 20
local CooldownMinScale = 0.5
local CooldownMinDuration = 1.5

local EXPIRING_DURATION = 8
local EXPIRING_FORMAT = K.RGBToHex(1, 0, 0) .. "%.1f|r"
local SECONDS_FORMAT = K.RGBToHex(1, 1, 0) .. "%d|r"
local MINUTES_FORMAT = K.RGBToHex(1, 1, 1) .. "%dm|r"
local HOURS_FORMAT = K.RGBToHex(0.4, 1, 1) .. "%dh|r"
local DAYS_FORMAT = K.RGBToHex(0.4, 0.4, 1) .. "%dh|r"

local function GetFormattedTime(s)
	if not s then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 36 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. s .. " doesn't exsit|r")
		end
		return
	end

	if s < MINUTEISH then
		local seconds = tonumber(K.Round(s))
		if seconds > EXPIRING_DURATION then
			return SECONDS_FORMAT, seconds, s - (seconds - .51)
		else
			return EXPIRING_FORMAT, s, .051
		end
	elseif s < HOURISH then
		local minutes = tonumber(K.Round(s / MINUTE))
		return MINUTES_FORMAT, minutes, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	elseif s < DAYISH then
		local hours = tonumber(K.Round(s / HOUR))
		return HOURS_FORMAT, hours, hours > 1 and (s - (hours * HOUR - HALFHOURISH)) or (s - HOURISH)
	else
		local days = tonumber(K.Round(s / DAY))
		return DAYS_FORMAT, days, days > 1 and (s - (days * DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

local function Timer_Stop(self)
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 63 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	self.enabled = nil
	self:Hide()
end

local function Timer_ForceUpdate(self)
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 75 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	self.nextUpdate = 0
	self:Show()
end

local function Timer_OnSizeChanged(self, width)
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 87 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	local fontScale = width and (floor(width + .5) / ICON_SIZE)

	if fontScale and (fontScale == self.fontScale) then
		return
	end

	self.fontScale = fontScale

	if fontScale and (fontScale < CooldownMinScale) then
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
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 114 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	local remain = self.duration - (GetTime() - self.start)
	if remain > 0.05 then
		if self.fontScale and ((self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < CooldownMinScale) then
			self.text:SetText("")
			self.nextUpdate = 500
		else
			local formatString, time, nextUpdate = GetFormattedTime(remain)
			self.text:SetFormattedText(formatString, time)
			self.nextUpdate = nextUpdate
		end
	else
		Timer_Stop(self)
	end
end

local function Timer_Create(self)
	if self:IsForbidden() then
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 143 - KkthnxUI|Modules|ActionBars|Cooldowns -|r |cFFFFFF00" .. self .. " is forbidden|r")
		end
		return
	end

	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints()

	local timer = CreateFrame("Frame", nil, scaler)
	timer:Hide()
	timer:SetAllPoints()

	local text = timer:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER", 1, 0)
	text:SetJustifyH("CENTER")
	timer.text = text

	Timer_OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", function(_, ...)
		Timer_OnSizeChanged(timer, ...)
	end)

	-- keep this after Timer_OnSizeChanged
	timer:SetScript("OnUpdate", Timer_OnUpdate)

	self.timer = timer
	return timer
end

local Cooldown_MT = getmetatable(_G.ActionButton1Cooldown).__index
local hideNumbers = {}

local function deactivateDisplay(cooldown)
	local timer = cooldown.timer
	if timer then
		Timer_Stop(timer)
	end
end

local function setHideCooldownNumbers(cooldown, hide)
	if hide then
		hideNumbers[cooldown] = true
		deactivateDisplay(cooldown)
	else
		hideNumbers[cooldown] = nil
	end
end

hooksecurefunc(Cooldown_MT, "SetCooldown", function(cooldown, start, duration, modRate)
	if cooldown.noCooldownCount or cooldown:IsForbidden() or hideNumbers[cooldown] then
		return
	end

	local show = (start and start > 0) and (duration and duration > CooldownMinDuration) and (modRate == nil or modRate > 0)

	if show then
		local timer = cooldown.timer or Timer_Create(cooldown)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0

		if timer.fontScale and (timer.fontScale >= CooldownMinScale) then
			timer:Show()
		end
	elseif cooldown.timer then
		deactivateDisplay(cooldown)
	end
end)

hooksecurefunc(Cooldown_MT, "Clear", deactivateDisplay)
hooksecurefunc(Cooldown_MT, "SetHideCountdownNumbers", setHideCooldownNumbers)
hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", function(cooldown)
	setHideCooldownNumbers(cooldown, true)
end)