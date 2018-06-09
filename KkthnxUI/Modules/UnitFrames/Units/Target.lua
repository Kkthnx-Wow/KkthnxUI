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
	self:HookScript("OnEnter", UnitFrame_OnEnter)
	self:HookScript("OnLeave", UnitFrame_OnLeave)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetTemplate("Transparent")
	self.Health:SetFrameStrata("LOW")
	self.Health:SetFrameLevel(1)
	self.Health:SetSize(130, 26)
	self.Health:SetPoint("CENTER", self, "CENTER", -26, 10)
	self.Health:SetStatusBarTexture(UnitframeTexture)

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
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 12, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetTemplate("Transparent")
	self.Power:SetFrameStrata("LOW")
	self.Power:SetFrameLevel(1)
	self.Power:SetSize(130, 14)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)

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
		self.Portrait:SetTemplate("Transparent")
		self.Portrait:SetFrameStrata("BACKGROUND")
		self.Portrait:SetFrameLevel(1)
		self.Portrait:SetSize(46, 46)
		self.Portrait:SetPoint("RIGHT", self, -4, 0)
	elseif (C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits") then
		self.Portrait = self.Health:CreateTexture(nil, "BACKGROUND", nil, 7)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(46, 46)
		self.Portrait:SetPoint("RIGHT", self, -4, 0)

		self.Portrait.Background = CreateFrame("Frame", nil, self)
		self.Portrait.Background:SetTemplate("Transparent")
		self.Portrait.Background:SetFrameStrata("LOW")
		self.Portrait.Background:SetFrameLevel(1)
		self.Portrait.Background:SetSize(46, 46)
		self.Portrait.Background:SetPoint("RIGHT", self, -4, 0)
		if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetSize(130, 24)
	self.Name:SetJustifyV("TOP")
	self.Name:SetJustifyH("CENTER")
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetFont(select(1, self.Name:GetFont()), 12, select(3, self.Name:GetFont()))
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	self.Level = self:CreateFontString(nil, "OVERLAY")
	self.Level:SetPoint("BOTTOM", self.Portrait, "TOP", 0, 4)
	self.Level:SetFontObject(UnitframeFont)
	self.Level:SetFont(select(1, self.Level:GetFont()), 12, select(3, self.Level:GetFont()))
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

	if (C["Unitframe"].ThreatPercent == true) then
		self.ThreatPercent = self:CreateFontString(nil, "OVERLAY")
		self.ThreatPercent:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
		self.ThreatPercent:SetFontObject(UnitframeFont)
		self.ThreatPercent:SetFont(select(1, self.Name:GetFont()), 14, select(3, self.Name:GetFont()))
		self:Tag(self.ThreatPercent, "[KkthnxUI:ThreatColor][KkthnxUI:ThreatPercent]")
	end

	Module.CreateAuras(self, "target")

	if (C["Unitframe"].Castbars) then
		Module.CreateCastBar(self, "target")
	end

	self.Range = Module.CreateRange(self)

	self.HealthPrediction = Module.CreateHealthPrediction(self)

	if (C["Unitframe"].CombatText) then
		Module.CreateCombatFeedback(self)
	end

	Module.CreateQuestIndicator(self)
	Module.CreateRaidTargetIndicator(self)
	Module.CreateReadyCheckIndicator(self)
	Module.CreateResurrectIndicator(self)
	Module.CreateThreatIndicator(self)
	Module.CreatePvPIndicator(self, "target")

	self.Threat = {
		Hide = K.Noop,
		IsObjectType = K.Noop,
		Override = Module.CreateThreatIndicator,
	}
end