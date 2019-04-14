local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if (not oUF) then
	K.Print("Could not find a vaild instance of oUF. Stopping Player.lua code!")
	return
end

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

function Module:CreatePlayer()
	local UnitframeFont = K.GetFont(C["Unitframe"].Font)
	local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", function(self)
		UnitFrame_OnEnter(self)

		if (self.Highlight and not self.Highlight:IsShown()) then
			self.Highlight:Show()
		end
	end)

	self:SetScript("OnLeave", function(self)
		UnitFrame_OnLeave(self)

		if (self.Highlight and self.Highlight:IsShown()) then
			self.Highlight:Hide()
		end
	end)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetSize(140, 26)
	self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.PostUpdate = C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" and Module.UpdateHealth
	self.Health.Smooth = C["Unitframe"].Smooth
	self.Health.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetSize(140, 14)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.Smooth = C["Unitframe"].Smooth
	self.Power.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")

	if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
		self.Portrait = CreateFrame("PlayerModel", nil, self)
		self.Portrait:SetSize(46, 46)
		self.Portrait:SetPoint("LEFT", self, 4, 0)
		self.Portrait:SetAlpha(0.9)

		self.Portrait.Borders = CreateFrame("Frame", nil, self)
		self.Portrait.Borders:SetPoint("LEFT", self, 4, 0)
		self.Portrait.Borders:SetSize(46, 46)
		self.Portrait.Borders:CreateBorder()
		self.Portrait.Borders:CreateInnerShadow()
	elseif (C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits") then
		self.Portrait = self.Health:CreateTexture("$parentPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(46, 46)
		self.Portrait:SetPoint("LEFT", self, 4, 0)

		self.Portrait.Borders = CreateFrame("Frame", nil, self)
		self.Portrait.Borders:SetPoint("LEFT", self, 4, 0)
		self.Portrait.Borders:SetSize(46, 46)
		self.Portrait.Borders:CreateBorder()

		if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "PlayerCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()
		self.Castbar:ClearAllPoints()

		if C["Raid"].RaidLayout.Value == "Healer" then
			self.Castbar:SetPoint("BOTTOM", "ActionBarAnchor", "TOP", 0, 230)
		else
			self.Castbar:SetPoint("BOTTOM", "ActionBarAnchor", "TOP", 0, 200)
		end

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")
		-- self.Castbar.Spark:SetPoint("CENTER", self.Castbar:GetStatusBarTexture(), "RIGHT", 0, 0)

		if C["Unitframe"].CastbarLatency then
			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "ARTWORK")
			self.Castbar.SafeZone:SetTexture(UnitframeTexture)
			self.Castbar.SafeZone:SetPoint("RIGHT")
			self.Castbar.SafeZone:SetPoint("TOP")
			self.Castbar.SafeZone:SetPoint("BOTTOM")
			self.Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
			self.Castbar.SafeZone:SetWidth(0.0001)

			self.Castbar.Latency = self.Castbar:CreateFontString(nil, "OVERLAY")
			self.Castbar.Latency:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", -3.5, -3)
			self.Castbar.Latency:SetFontObject(UnitframeFont)
			self.Castbar.Latency:SetFont(select(1, self.Castbar.Latency:GetFont()), 11, select(3, self.Castbar.Latency:GetFont()))
			self.Castbar.Latency:SetTextColor(0.84, 0.75, 0.65)
			self.Castbar.Latency:SetJustifyH("RIGHT")
		end

		self.Castbar.timeToHold = 0.4
		self.Castbar.CustomDelayText = Module.CustomCastDelayText
		self.Castbar.CustomTimeText = Module.CustomTimeText
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostCastInterruptible = Module.PostCastInterruptible
		self.Castbar.PostCastFail = Module.PostCastFailedOrInterrupted

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
		self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Text:SetJustifyH("LEFT")
		self.Castbar.Text:SetWordWrap(false)

		if (C["Unitframe"].CastbarIcon) then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:SetSize(20, 20)
			self.Castbar.Button:CreateBorder()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
			self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			self.Castbar.Icon:SetPoint("RIGHT", self.Castbar, "LEFT", -6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end

		-- Adjust tick heights
		self.Castbar.tickHeight = self.Castbar:GetHeight()

		if C["Unitframe"].CastbarTicks then -- Only player unitframe has this
			-- Set tick width and color
			self.Castbar.tickWidth = C["Unitframe"].CastbarTicksWidth
			self.Castbar.tickColor = C["Unitframe"].CastbarTicksColor

			for i = 1, #Module.ticks do
				Module.ticks[i]:SetVertexColor(self.Castbar.tickColor[1], self.Castbar.tickColor[2], self.Castbar.tickColor[3], self.Castbar.tickColor[4])
				Module.ticks[i]:SetWidth(self.Castbar.tickWidth)
			end
		end

		K.Movers:RegisterFrame(self.Castbar)
	end

	self.AdditionalPower = CreateFrame("StatusBar", nil, self.Health)
	self.AdditionalPower:SetFrameStrata(self:GetFrameStrata())
	self.AdditionalPower:SetHeight(12)
	self.AdditionalPower:SetPoint("LEFT", self.Portrait)
	self.AdditionalPower:SetPoint("RIGHT")
	self.AdditionalPower:SetPoint("BOTTOM", self, "TOP", 0, 3)
	self.AdditionalPower:SetStatusBarTexture(UnitframeTexture)
	self.AdditionalPower:SetStatusBarColor(unpack(K.Colors.power["MANA"]))
	self.AdditionalPower:CreateBorder()

	self.AdditionalPower.Smooth = C["Unitframe"].Smooth
	self.AdditionalPower.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.AdditionalPower.frequentUpdates = true

	self.LeaderIndicatorOverlay = CreateFrame("Frame", nil, self.Portrait.Borders)
	self.LeaderIndicatorOverlay:SetAllPoints()
	self.LeaderIndicatorOverlay:SetFrameLevel(4) -- self.Portrait.Borders = 3 so we put it 1 higher. Watch this.

	self.LeaderIndicator = self.LeaderIndicatorOverlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(14, 14)
	self.LeaderIndicator:SetPoint("TOPLEFT", 2, 9)

	-- Class Power (Combo Points, etc...)
	if C["Unitframe"].ClassResource then
		Module.CreateClassPower(self)
		if (K.Class == "MONK") then
			Module.CreateStaggerBar(self)
		elseif (K.Class == "DEATHKNIGHT") then
			Module.CreateRuneBar(self)
		end
	end

	self.HealthPrediction = Module.CreateHealthPrediction(self, 140)

	if (C["Unitframe"].PowerPredictionBar) then
		self.PowerPrediction = Module.CreatePowerPrediction(self)
	end

	if C["Unitframe"].PlayerBuffs then
		Module.CreateAuras(self, "player")
	end

	Module.CreateCombatIndicator(self)
	Module.CreateRaidTargetIndicator(self)
	Module.CreateReadyCheckIndicator(self)
	Module.CreateResurrectIndicator(self)
	Module.CreateRestingIndicator(self)
	Module.CreateThreatIndicator(self)
	Module.CreatePvPIndicator(self, "player")

	if C["Unitframe"].DebuffHighlight then
		Module.CreateDebuffHighlight(self)
	end

	if C["Unitframe"].PortraitTimers then
		Module.CreatePortraitTimers(self)
	end

	if C["Unitframe"].MouseoverHighlight then
		Module.MouseoverHealth(self, "player")
	end

	if (C["Unitframe"].GlobalCooldown) then
		Module.CreateGlobalCooldown(self)
	end

	self.Threat = {
		Hide = K.Noop,
		IsObjectType = K.Noop,
		Override = Module.CreateThreatIndicator
	}

	self.CombatFade = C["Unitframe"].CombatFade
end