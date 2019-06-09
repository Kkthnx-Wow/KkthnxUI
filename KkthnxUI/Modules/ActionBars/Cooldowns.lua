local K, C, L = unpack(select(2, ...))
local module = K:NewModule("Cooldowns")

local _G = _G
local math_floor = math.floor
local pairs = pairs
local select = select
local string_find = string.find
local string_format = string.format

local CreateFrame = _G.CreateFrame
local GetActionCooldown = _G.GetActionCooldown
local getmetatable = _G.getmetatable
local GetTime = _G.GetTime
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local SetCVar = _G.SetCVar

local day, hour, minute = 86400, 3600, 60
local function TimerFormat(s)
	if s >= day then
		return string_format("%d"..K.ClassColor.."d", s / day), s % day
	elseif s >= hour then
		return string_format("%d"..K.ClassColor.."h", s / hour), s % hour
	elseif s >= minute then
		return string_format("%d"..K.ClassColor.."m", s / minute), s % minute
	elseif s > 10 then
		return string_format("|cffcccc33%d|r", s), s - math_floor(s)
	elseif s > 3 then
		return string_format("|cffffff00%d|r", s), s - math_floor(s)
	else
		if C["ActionBar"].DecimalCD then
			return string_format("|cffff0000%.1f|r", s), s - string_format("%.1f", s)
		else
			return string_format("|cffff0000%d|r", s + .5), s - math_floor(s)
		end
	end
end

function module:OnEnable()
	if K.CheckAddOnState("OmniCC") or K.CheckAddOnState("ncCooldown") or K.CheckAddOnState("CooldownCount") or C["ActionBar"].Cooldowns ~= true then
		return
	end

	OmniCC = true
	local FONT_SIZE = 19
	local MIN_DURATION = 2.5 -- The Minimum Duration To Show Cooldown Text For
	local MIN_SCALE = 0.5 -- The Minimum Scale We Want To Show Cooldown Counts At, Anything Below This Will Be Hidden
	local ICON_SIZE = 36
	local hideNumbers = {}

	-- Stops The Timer
	local function Timer_Stop(self)
		self.enabled = nil
		self:Hide()
	end

	-- Forces The Given Timer To Update On The Next Frame
	local function Timer_ForceUpdate(self)
		self.nextUpdate = 0
		self:Show()
	end

	-- Adjust Font Size Whenever The Timer's Parent Size Changes, Hide If It Gets Too Tiny
	local function Timer_OnSizeChanged(self, width)
		local cooldownFont = K.GetFont(C["ActionBar"].Font)
		local fontScale = math_floor(width + 0.5) / ICON_SIZE
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
				Timer_ForceUpdate(self)
			end
		end
	end

	-- Update Timer Text, If It Needs To Be, Hide The Timer If Done
	local function Timer_OnUpdate(self, elapsed)
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
		else
			local remain = self.duration - (GetTime() - self.start)
			if remain > 0 then
				local getTime, nextUpdate = TimerFormat(remain)
				self.text:SetText(getTime)
				self.nextUpdate = nextUpdate
			else
				Timer_Stop(self)
			end
		end
	end

	-- Returns A New Timer Object
	local function Timer_Create(self)
		local scaler = CreateFrame("Frame", nil, self)
		scaler:SetAllPoints(self)

		local timer = CreateFrame("Frame", nil, scaler)
		timer:Hide()
		timer:SetAllPoints(scaler)
		timer:SetScript("OnUpdate", Timer_OnUpdate)

		local text = timer:CreateFontString(nil, "BACKGROUND")
		text:SetPoint("CENTER", 2, 0)
		text:SetJustifyH("CENTER")
		timer.text = text

		Timer_OnSizeChanged(timer, scaler:GetSize())
		scaler:SetScript("OnSizeChanged", function(_, ...)
			Timer_OnSizeChanged(timer, ...)
		end)

		self.timer = timer
		return timer
	end

	local function Timer_Start(self, start, duration)
		if self:IsForbidden() or self.noOCC or self.noCooldownCount or hideNumbers[self] then
			return
		end

		if C["ActionBar"].OverrideWA and self:GetName() and string_find(self:GetName(), "WeakAuras") then
			self.noOCC = true
			return
		end

		if start > 0 and duration > MIN_DURATION then
			local timer = self.timer or Timer_Create(self)
			timer.start = start
			timer.duration = duration
			timer.enabled = true
			timer.nextUpdate = 0

			-- Wait For Blizz To Fix Itself
			local parent = self:GetParent()
			local charge = parent and parent.chargeCooldown
			local chargeTimer = charge and charge.timer
			if chargeTimer and chargeTimer ~= timer then
				Timer_Stop(chargeTimer)
			end

			if timer.fontScale >= MIN_SCALE then
				timer:Show()
			end
		elseif self.timer then
			Timer_Stop(self.timer)
		end

		-- hide cooldown flash if barFader enabled
		if self:GetParent().__faderParent then
			if self:GetEffectiveAlpha() > 0 then
				self:Show()
			else
				self:Hide()
			end
		end
	end

	local function hideCooldownNumbers(self, hide)
		if hide then
			hideNumbers[self] = true
			if self.timer then Timer_Stop(self.timer) end
		else
			hideNumbers[self] = nil
		end
	end

	local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldownIndex, "SetCooldown", Timer_Start)
	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", function(self)
		hideCooldownNumbers(self, true)
	end)

	-- Action Buttons Hook
	local active, hooked = {}, {}

	local function Cooldown_OnShow(self)
		active[self] = true
	end

	local function Cooldown_OnHide(self)
		active[self] = nil
	end

	local function Cooldown_ShouldUpdateTimer(self, start)
		local timer = self.timer
		if not timer then
			return true
		end

		return timer.start ~= start
	end

	local function Cooldown_Update(self)
		local button = self:GetParent()
		local start, duration = GetActionCooldown(button.action)

		if Cooldown_ShouldUpdateTimer(self, start) then
			Timer_Start(self, start, duration)
		end
	end

	K:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", function()
		for cooldown in pairs(active) do
			Cooldown_Update(cooldown)
		end
	end)

	local function ActionButton_Register(frame)
		local cooldown = frame.cooldown
		if not hooked[cooldown] then
			cooldown:HookScript("OnShow", Cooldown_OnShow)
			cooldown:HookScript("OnHide", Cooldown_OnHide)
			hooked[cooldown] = true
		end
	end

	if _G["ActionBarButtonEventsFrame"].frames then
		for _, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
			ActionButton_Register(frame)
		end
	end
	hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", ActionButton_Register)

	-- Hide Default Cooldown
	if not InCombatLockdown() then
		SetCVar("countdownForCooldowns", 0)
	end
	K.HideInterfaceOption(InterfaceOptionsActionBarsPanelCountdownCooldowns)
end