local K, C = unpack(KkthnxUI)
local Module = K:NewModule("Cooldowns")

local _G = _G
local pairs = _G.pairs
local select = _G.select
local string_find = _G.string.find

local CreateFrame = _G.CreateFrame
local GetActionCooldown = _G.GetActionCooldown
local getmetatable = _G.getmetatable
local GetTime = _G.GetTime
local hooksecurefunc = _G.hooksecurefunc
local SetCVar = _G.SetCVar

local FONT_SIZE = 19
local MIN_DURATION = 2 -- the minimum duration to show cooldown text for
local MIN_SCALE = 0.5 -- the minimum scale we want to show cooldown counts at, anything below this will be hidden
local ICON_SIZE = 36

local hideNumbers, active, hooked = {}, {}, {}

local day, hour, minute = 86400, 3600, 60
function Module.FormattedTimer(s, modRate)
	if s >= day then
		return format("%d" .. K.MyClassColor .. "d", s / day + 0.5), s % day
	elseif s > hour then
		return format("%d" .. K.MyClassColor .. "h", s / hour + 0.5), s % hour
	elseif s >= minute then
		if s < C["ActionBar"].MMSSTH then
			return format("%d:%.2d", s / minute, s % minute), s - floor(s)
		else
			return format("%d" .. K.MyClassColor .. "m", s / minute + 0.5), s % minute
		end
	else
		local colorStr = (s < 3 and "|cffff0000") or (s < 10 and "|cffffff00") or "|cffcccc33"
		if s < C["ActionBar"].TenthTH then
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

function Module:OnSizeChanged(width, height)
	local cooldownFont = K.GetFont(C["UIFonts"].ActionBarsFonts)

	local fontScale = K.Round((width + height) / 2) / ICON_SIZE
	if fontScale == self.fontScale then
		return
	end
	self.fontScale = fontScale

	if fontScale < MIN_SCALE then
		self:Hide()
	else
		self.text:SetFontObject(cooldownFont)
		self.text:SetFont(select(1, self.text:GetFont()), fontScale * FONT_SIZE, select(3, self.text:GetFont()))
		self.text:SetShadowColor(0, 0, 0, 0)

		if self.enabled then
			Module.ForceUpdate(self)
		end
	end
end

function Module:TimerOnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		local remain = (self.duration - (GetTime() - self.start)) / self.modRate
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

function Module:OnCreate()
	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints(self)

	local timer = CreateFrame("Frame", nil, scaler)
	timer:Hide()
	timer:SetAllPoints(scaler)
	timer:SetScript("OnUpdate", Module.TimerOnUpdate)
	scaler.timer = timer

	local text = timer:CreateFontString(nil, "BACKGROUND")
	text:SetPoint("CENTER", 2, 0)
	text:SetJustifyH("CENTER")
	timer.text = text

	Module.OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", Module.ScalerOnSizeChanged)

	self.timer = timer
	return timer
end

function Module:StartTimer(start, duration, modRate)
	if self:IsForbidden() then
		return
	end

	if self.noCooldownCount or hideNumbers[self] then
		return
	end

	local frameName = self.GetName and self:GetName()
	if C["ActionBar"].OverrideWA and frameName and string_find(frameName, "WeakAuras") then
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

		-- Wait For Blizz To Fix Itself
		local charge = parent and parent.chargeCooldown
		local chargeTimer = charge and charge.timer
		if chargeTimer and chargeTimer ~= timer then
			Module.StopTimer(chargeTimer)
		end

		if timer.fontScale >= MIN_SCALE then
			timer:Show()
		end
	elseif self.timer then
		Module.StopTimer(self.timer)
	end

	-- Hide Cooldown Flash If Barfader Enabled
	if parent and parent.__faderParent then
		if self:GetEffectiveAlpha() > 0 then
			self:Show()
		else
			self:Hide()
		end
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
	local start, duration = GetActionCooldown(button.action)

	if shouldUpdateTimer(self, start) then
		Module.StartTimer(self, start, duration)
	end
end

function Module:ActionbarUpateCooldown()
	for cooldown in pairs(active) do
		Module.CooldownUpdate(cooldown)
	end
end

function Module:RegisterActionButton()
	local cooldown = self.cooldown
	if not hooked[cooldown] then
		cooldown:HookScript("OnShow", Module.CooldownOnShow)
		cooldown:HookScript("OnHide", Module.CooldownOnHide)

		hooked[cooldown] = true
	end
end

function Module:OnEnable()
	if K.CheckAddOnState("OmniCC") or K.CheckAddOnState("ncCooldown") or K.CheckAddOnState("CooldownCount") then
		return
	end

	if not C["ActionBar"].Cooldowns then
		return
	end

	local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldownIndex, "SetCooldown", Module.StartTimer)
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", Module.HideCooldownNumbers)
	K:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", Module.ActionbarUpateCooldown)

	if _G["ActionBarButtonEventsFrame"].frames then
		for _, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
			Module.RegisterActionButton(frame)
		end
	end
	hooksecurefunc(ActionBarButtonEventsFrameMixin, "RegisterFrame", Module.RegisterActionButton)

	-- Hide Default Cooldown
	if not InCombatLockdown() then
		SetCVar("countdownForCooldowns", 0)
	end
	K.HideInterfaceOption(InterfaceOptionsActionBarsPanelCountdownCooldowns)
end
