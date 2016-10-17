local K, C, L = select(2, ...):unpack()
if IsAddOnLoaded("OmniCC") or IsAddOnLoaded("ncCooldown") or IsAddOnLoaded("CooldownCount") or C.Cooldown.Enable ~= true then return end

local format = string.format
local floor = math.floor
local min = math.min

local MIN_SCALE = 0.5
local ICON_SIZE = 36 --the normal size for an icon (don"t change this)
local FONT_SIZE = 20 --the base font size to use at a scale of 1
local MIN_SCALE = 0.5 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
local MIN_DURATION = 1.5 --the minimum duration to show cooldown text for
local threshold = 3

local TimeColors = {
	[0] = "|cfffefefe",
	[1] = "|cfffefefe",
	[2] = "|cfffefefe",
	[3] = "|cfffefefe",
	[4] = "|cfffe0000",
}

K.TimeFormats = {
	[0] = { "%dd", "%dd" },
	[1] = { "%dh", "%dh" },
	[2] = { "%dm", "%dm" },
	[3] = { "%ds", "%d" },
	[4] = { "%.1fs", "%.1f" },
}

local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for calculating aura time text
local DAYISH, HOURISH, MINUTEISH = HOUR * 23.5, MINUTE * 59.5, 59.5 --used for caclculating aura time at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

-- will return the the value to display, the formatter id to use and calculates the next update for the Aura
local function GetTimeInfo(s, threshhold)
	if s < MINUTE then
		if s >= threshhold then
			return floor(s), 3, 0.51
		else
			return s, 4, 0.051
		end
	elseif s < HOUR then
		local minutes = floor((s/MINUTE)+.5)
		return ceil(s / MINUTE), 2, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	elseif s < DAY then
		local hours = floor((s/HOUR)+.5)
		return ceil(s / HOUR), 1, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	else
		local days = floor((s/DAY)+.5)
		return ceil(s / DAY), 0,  days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

local function Cooldown_OnUpdate(cd, elapsed)
	if cd.nextUpdate > 0 then
		cd.nextUpdate = cd.nextUpdate - elapsed
		return
	end

	local remain = cd.duration - (GetTime() - cd.start)

	if remain > 0.05 then
		if (cd.fontScale * cd:GetEffectiveScale() / UIParent:GetScale()) < MIN_SCALE then
			cd.text:SetText("")
			cd.nextUpdate = 500
		else
			local timervalue, formatid
			timervalue, formatid, cd.nextUpdate = GetTimeInfo(remain, threshold)
			cd.text:SetFormattedText(("%s%s|r"):format(TimeColors[formatid], K.TimeFormats[formatid][2]), timervalue)
		end
	else
		K:Cooldown_StopTimer(cd)
	end
end

function K:Cooldown_OnSizeChanged(cd, width, height)
	local fontScale = floor(width +.5) / ICON_SIZE
	local override = cd:GetParent():GetParent().SizeOverride
	if override then
		fontScale = override / FONT_SIZE
	end

	if fontScale == cd.fontScale then
		return
	end

	cd.fontScale = fontScale
	if fontScale < MIN_SCALE and not override then
		cd:Hide()
	else
		cd:Show()
		cd.text:SetFont(C.Media.Font, fontScale * FONT_SIZE, "OUTLINE")
		if cd.enabled then
			self:Cooldown_ForceUpdate(cd)
		end
	end
end

function K:Cooldown_ForceUpdate(cd)
	cd.nextUpdate = 0
	cd:Show()
end

function K:Cooldown_StopTimer(cd)
	cd.enabled = nil
	cd:Hide()
end

function K:CreateCooldownTimer(parent)
	local scaler = CreateFrame("Frame", nil, parent)
	scaler:SetAllPoints()

	local timer = CreateFrame("Frame", nil, scaler); timer:Hide()
	timer:SetAllPoints()
	timer:SetScript("OnUpdate", Cooldown_OnUpdate)

	local text = timer:CreateFontString(nil, "OVERLAY")
	text:SetPoint("CENTER", 1, -1)
	text:SetJustifyH("CENTER")
	timer.text = text

	self:Cooldown_OnSizeChanged(timer, parent:GetSize())
	parent:SetScript("OnSizeChanged", function(_, ...) self:Cooldown_OnSizeChanged(timer, ...) end)

	parent.timer = timer
	return timer
end

function K:OnSetCooldown(start, duration)
	if(self.noOCC) then return end
	local button = self:GetParent()
	local remainingCharges = charges or 0

	if self:GetName() and string.find(self:GetName(), "ChargeCooldown") then return end
	if start > 0 and duration > MIN_DURATION and remainingCharges == 0 and (not self.noOCC) then
		local timer = self.timer or K:CreateCooldownTimer(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= MIN_SCALE then timer:Show() end
	else
		local timer = self.timer
		if timer then
			K:Cooldown_StopTimer(timer)
			return
		end
	end
end

hooksecurefunc(getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", K.OnSetCooldown)

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
		K:OnSetCooldown(start, duration, charges, maxCharges)
	end
end

local EventWatcher = CreateFrame("Frame")
EventWatcher:Hide()
EventWatcher:SetScript("OnEvent", function(self, event)
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
	for i, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
		actionButton_Register(frame)
	end
end

hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", actionButton_Register)