local K, C, L, _ = select(2, ...):unpack()
if IsAddOnLoaded("OmniCC") or IsAddOnLoaded("ncCooldown") or C.Cooldown.Enable ~= true then return end

-- Cooldown count(tullaCC by Tuller)
local _G = _G
local format = string.format
local floor = math.floor
local min = math.min
local find = string.find
local pairs = pairs
local getmetatable = getmetatable
local CreateFrame = CreateFrame
local GetTime = GetTime
local GetActionCooldown = GetActionCooldown
local GetActionCharges = GetActionCharges

local ICON_SIZE = 36
local FONT_SIZE = C.Cooldown.FontSize
local MIN_SCALE = 0.5
local MIN_DURATION = 1.5

local function Timer_Stop(self)
	self.enabled = nil
	self:Hide()
end

local function Timer_ForceUpdate(self)
	self.nextUpdate = 0
	self:Show()
end

local function Timer_OnSizeChanged(self, width, height)
	local fontScale = floor(width +.5) / ICON_SIZE
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
		self.text:SetFont(C.Media.Font, fontScale * FONT_SIZE, C.Media.Font_Style)
		if self.enabled then
			Timer_ForceUpdate(self)
		end
	end
end

local function Timer_OnUpdate(self, elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	local remain = self.duration - (GetTime() - self.start)

	if remain > 0.05 then
		if (self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < MIN_SCALE then
			self.text:SetText('')
			self.nextUpdate = 500
		else
			local timervalue, formatid
			timervalue, formatid, self.nextUpdate = K.GetTimeInfo(remain, C.Cooldown.Threshold)
			self.text:SetFormattedText(("%s%s|r"):format(K.TimeColors[formatid], K.TimeFormats[formatid][2]), timervalue)
		end
	else
		Timer_Stop(self)
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
	scaler:SetScript("OnSizeChanged", function(self, ...) Timer_OnSizeChanged(timer, ...) end)

	self.timer = timer
	return timer
end

local function Timer_Start(self, start, duration, charges, maxCharges)
	local remainingCharges = charges or 0

	if self:GetName() and find(self:GetName(), "ChargeCooldown") then return end
	if start > 0 and duration > MIN_DURATION and remainingCharges == 0 and (not self.noOCC) then
		local timer = self.timer or Timer_Create(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= MIN_SCALE then timer:Show() end
	else
		local timer = self.timer
		if timer then
			Timer_Stop(timer)
		end
	end
end
hooksecurefunc(getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", Timer_Start)