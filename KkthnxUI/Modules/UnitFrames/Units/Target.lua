local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Target.lua code!")
	return
end

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

function Module:CreateTarget()
	local UnitframeFont = K.GetFont(C["Unitframe"].Font)
	local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", function(self)
		UnitFrame_OnEnter(self)

		if (self.Highlight) then
			self.Highlight:Show()
		end
	end)

	self:SetScript("OnLeave", function(self)
		UnitFrame_OnLeave(self)

		if (self.Highlight) then
			self.Highlight:Hide()
		end
	end)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetSize(140, 26)
	self.Health:SetPoint("CENTER", self, "CENTER", -26, 10)
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
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")

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
		self.Portrait:SetPoint("RIGHT", self, -4, 0)
		self.Portrait:SetAlpha(0.9)

		self.Portrait.Borders = CreateFrame("Frame", nil, self)
		self.Portrait.Borders:SetPoint("RIGHT", self, -4, 0)
		self.Portrait.Borders:SetSize(46, 46)
		self.Portrait.Borders:CreateBorder()
		self.Portrait.Borders:CreateInnerShadow()
	elseif (C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits") then
		self.Portrait = self.Health:CreateTexture("$parentPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(46, 46)
		self.Portrait:SetPoint("RIGHT", self, -4, 0)

		self.Portrait.Borders = CreateFrame("Frame", nil, self)
		self.Portrait.Borders:SetPoint("RIGHT", self, -4, 0)
		self.Portrait.Borders:SetSize(46, 46)
		self.Portrait.Borders:CreateBorder()
		if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetWidth(self.Health:GetWidth())
	self.Name:SetFontObject(UnitframeFont)
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	self.Level = self:CreateFontString(nil, "OVERLAY")
	self.Level:SetPoint("TOP", self.Portrait, 0, 15)
	self.Level:SetFontObject(UnitframeFont)
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

	if (C["Unitframe"].ThreatPercent == true) then
		Module.CreateThreatPercent(self)
	end

	if C["Unitframe"].MouseoverHighlight then
		Module.MouseoverHealth(self, "target")
	end

	Module.CreateAuras(self, "target")

	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "TargetCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight + 6)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()
		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("BOTTOM", "PlayerCastbar", "TOP", 0, 6)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")
		-- self.Castbar.Spark:SetPoint("CENTER", self.Castbar:GetStatusBarTexture(), "RIGHT", 0, 0)

		self.Castbar.Shield = self.Castbar:CreateTexture(nil, "ARTWORK")
		self.Castbar.Shield:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CastBorderShield")
		self.Castbar.Shield:SetPoint("RIGHT", self.Castbar, "LEFT", 34, 12)

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.timeToHold = 0.4
		self.Castbar.CustomDelayText = Module.CustomCastDelayText
		self.Castbar.CustomTimeText = Module.CustomTimeText
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostCastInterruptible = Module.PostCastInterruptible
		self.Castbar.PostCastFail = Module.PostCastFailedOrInterrupted

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
			self.Castbar.Icon:SetPoint("LEFT", self.Castbar, "RIGHT", 6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end

		K.Movers:RegisterFrame(self.Castbar)
	end

	self.HealthPrediction = Module.CreateHealthPrediction(self, 140)

	if C["Unitframe"].PortraitTimers then
		Module.CreatePortraitTimers(self)
	end

	-- Module.CreateRaidTargetIndicator(self) has an issue where it is falling behind the border we use.
	-- This is created in `KkthnxUI\KkthnxUI\Modules\UnitFrames\Elements\Indicators.lua - Line 128`
	Module.CreateRaidTargetIndicator(self)
	Module.CreateReadyCheckIndicator(self)
	Module.CreateResurrectIndicator(self)
	Module.CreateThreatIndicator(self)
	Module.CreatePvPIndicator(self, "target")
	Module.CreateDebuffHighlight(self)

	if C["FloatingCombatFeedback"].Enable and C["FloatingCombatFeedback"].Style.Value == "Portraits" then
		Module.CreateCombatFeedback(self)
	end

	self.Threat = {
		Hide = K.Noop,
		IsObjectType = K.Noop,
		Override = Module.CreateThreatIndicator,
	}

	self.Range = Module.CreateRangeIndicator(self)
end
