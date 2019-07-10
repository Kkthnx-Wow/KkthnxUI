local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

function Module:CreateBoss()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", UnitFrame_OnEnter)
	self:HookScript("OnLeave", UnitFrame_OnLeave)

	self.Health = CreateFrame("StatusBar", "$parent.Healthbar", self)
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:SetSize(130, 26)
	self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
	self.Health:CreateBorder()

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = false

	K:SetSmoothing(self.Health, C["Boss"].Smooth)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:SetSize(130, 14)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	K:SetSmoothing(self.Power, C["Boss"].Smooth)

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")

	if (C["Boss"].PortraitStyle.Value == "ThreeDPortraits") then
		self.Portrait = CreateFrame("PlayerModel", nil, self)
		self.Portrait:SetSize(46, 46)
		self.Portrait:SetPoint("LEFT", self, 4, 0)
		self.Portrait:SetAlpha(0.9)

		self.Portrait.Borders = CreateFrame("Frame", nil, self)
		self.Portrait.Borders:SetPoint("LEFT", self, 4, 0)
		self.Portrait.Borders:SetSize(46, 46)
		self.Portrait.Borders:CreateBorder()
		self.Portrait.Borders:CreateInnerShadow()
	elseif (C["Boss"].PortraitStyle.Value ~= "ThreeDPortraits") then
		self.Portrait = self.Health:CreateTexture("$parentPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(46, 46)
		self.Portrait:SetPoint("LEFT", self, 4, 0)

		self.Portrait.Borders = CreateFrame("Frame", nil, self)
		self.Portrait.Borders:SetPoint("LEFT", self, 4, 0)
		self.Portrait.Borders:SetSize(46, 46)
		self.Portrait.Borders:CreateBorder()

		if (C["Boss"].PortraitStyle.Value == "ClassPortraits" or C["Boss"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetSize(130, 24)
	self.Name:SetJustifyV("TOP")
	self.Name:SetJustifyH("CENTER")
	self.Name:SetFontObject(UnitframeFont)
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameAbbrev]")

	if (C["Boss"].ThreatPercent == true) then
		Module.CreateThreatPercent(self, "LEFT", "RIGHT", 4, 0)
	end

	Module.CreateBossCastbar(self)
	Module.CreateBossAuras(self)
	Module.CreateDebuffHighlight(self)
	self.Range = Module.CreateRangeIndicator(self)
end