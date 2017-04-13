local K, C, L = unpack(select(2, ...))
if K.CheckAddOn("OmniCC") or K.CheckAddOn("ncCooldown") or K.CheckAddOn("CooldownCount") or C.Cooldown.Enable ~= true then return end

-- Lua API
local _G = _G
local math_ceil = math.ceil
local math_floor = math.floor
local string_find = string.find

-- Wow API
local GetTime = _G.GetTime

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: UIParent, CreateFrame, GetActionCooldown, GetActionCharges

local ICON_SIZE = 36 -- the normal size for an icon (don't change this)
local FONT_SIZE = C.Cooldown.FontSize -- the base font size to use at a scale of 1
local MIN_SCALE = 0.5 -- the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 1.5 -- the minimum duration to show cooldown text for
local threshold = C.Cooldown.Threshold

local TimeColors = {
	[0] = K.RGBToHex(0.4, 0.4, 1),
	[1] = K.RGBToHex(0.4, 1, 1),
	[2] = K.RGBToHex(1, 1, 1),
	[3] = K.RGBToHex(1, 1, 0),
	[4] = K.RGBToHex(1, 0, 0),
}

local TimeFormats = {
	[0] = {"%dd", "%dd"},
	[1] = {"%dh", "%dh"},
	[2] = {"%dm", "%dm"},
	[3] = {"%ds", "%d"},
	[4] = {"%.1fs", "%.1f"},
}

local DAY, HOUR, MINUTE = 86400, 3600, 60 -- used for calculating aura time text
local DAYISH, HOURISH, MINUTEISH = HOUR * 23.5, MINUTE * 59.5, 59.5 -- used for caclculating aura time at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY / 2 + 0.5, HOUR / 2 + 0.5, MINUTE / 2 + 0.5 -- used for calculating next update times

-- will return the the value to display, the formatter id to use and calculates the next update for the Aura
local function GetTimeInfo(s, threshhold)
	if s < MINUTE then
		if s >= threshhold then
			return math_floor(s), 3, 0.51
		else
			return s, 4, 0.051
		end
	elseif s < HOUR then
		local minutes = math_floor((s / MINUTE) + 0.5)
		return math_ceil(s / MINUTE), 2, minutes > 1 and (s - (minutes * MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	elseif s < DAY then
		local hours = math_floor((s / HOUR) + 0.5)
		return math_ceil(s / HOUR), 1, hours > 1 and (s - (hours * HOUR - HALFHOURISH)) or (s - HOURISH)
	else
		local days = math_floor((s / DAY) + 0.5)
		return math_ceil(s / DAY), 0, days > 1 and (s - (days * DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

local function Cooldown_Stop(self)
	self.enabled = nil
	self:Hide()
end

local function Cooldown_ForceUpdate(self)
	self.nextUpdate = 0
	self:Show()
end

local function Cooldown_OnSizeChanged(self, width, height)
	local fontScale = math_floor(width + 0.5) / ICON_SIZE
	local override = self:GetParent():GetParent().SizeOverride
	if override then
		fontScale = override / FONT_SIZE
	end

	if fontScale == self.fontScale then
		return
	end

	self.fontScale = fontScale
	if fontScale < MIN_SCALE and not override then
		self:Hide()
	else
		self:Show()
		self.text:SetFont(C.Media.Font, fontScale * FONT_SIZE, "OUTLINE")
		if self.enabled then
			Cooldown_ForceUpdate(self)
		end
	end
end

local function Cooldown_OnUpdate(self, elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	local remain = self.duration - (GetTime() - self.start)

	if remain > 0.05 then
		if (self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < MIN_SCALE then
			self.text:SetText("")
			self.nextUpdate = 500
		else
			local timervalue, formatid
			timervalue, formatid, self.nextUpdate = GetTimeInfo(remain, threshold)
			self.text:SetFormattedText(("%s%s|r"):format(TimeColors[formatid], TimeFormats[formatid][2]), timervalue)
		end
	else
		Cooldown_Stop(self)
	end
end

local function Cooldown_Create(self)
	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints()

	local timer = CreateFrame("Frame", nil, scaler) timer:Hide()
	timer:SetAllPoints()
	timer:SetScript("OnUpdate", Cooldown_OnUpdate)

	local text = timer:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER", 1, 1)
	text:SetJustifyH("CENTER")
	timer.text = text

	Cooldown_OnSizeChanged(timer, self:GetSize())
	self:SetScript("OnSizeChanged", function(_, ...) Cooldown_OnSizeChanged(timer, ...) end)

	self.timer = timer
	return timer
end

local function Cooldown_Start(self, start, duration, charges, maxCharges)
	local remainingCharges = charges or 0

	if self:GetName() and string_find(self:GetName(), "ChargeCooldown") then return end
	if start > 0 and duration > MIN_DURATION and remainingCharges < 2 and (not self.noOCC) then
		local timer = self.timer or Cooldown_Create(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= MIN_SCALE then timer:Show() end
	else
		local timer = self.timer
		if timer then
			Cooldown_Stop(timer)
			return
		end
	end
end

hooksecurefunc(getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", Cooldown_Start)

if not _G["ActionBarButtonEventsFrame"] then return end

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
	return not(timer and timer.start == start and timer.duration == duration and timer.charges == charges and timer.maxCharges == maxCharges)
end

local function cooldown_Update(self)
	local button = self:GetParent()
	local action = button.action
	local start, duration, enable = GetActionCooldown(action)
	local charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(action)

	if cooldown_ShouldUpdateTimer(self, start, duration, charges, maxCharges) then
		Cooldown_Start(self, start, duration, charges, maxCharges)
	end
end

local EventWatcher = CreateFrame("Frame")
EventWatcher:SetParent(UIFrameHider)
EventWatcher:SetScript("OnEvent", function(self, event)
	for cooldown in pairs(active) do
		cooldown_Update(cooldown)
	end
end)
EventWatcher:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
EventWatcher:RegisterEvent("SPELL_UPDATE_COOLDOWN")
EventWatcher:RegisterEvent("LOSS_OF_CONTROL_ADDED")
EventWatcher:RegisterEvent("LOSS_OF_CONTROL_UPDATE")

local function actionButton_Register(frame)
	local cooldown = frame.cooldown
	if (not C.Cooldown.Enable or cooldown.isHooked) then return end
	cooldown:HookScript("OnShow", cooldown_OnShow)
	cooldown:HookScript("OnHide", cooldown_OnHide)
	cooldown.isHooked = true
	cooldown:SetHideCountdownNumbers(true)
end

if _G["ActionBarButtonEventsFrame"].frames then
	for i, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
		actionButton_Register(frame)
	end
end

hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", actionButton_Register)