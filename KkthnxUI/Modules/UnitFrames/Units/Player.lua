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
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

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
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorSmooth = false
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true

	K:SetSmoothing(self.Health, C["Unitframe"].Smooth)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, C["Unitframe"].PlayerHealthFormat.Value)

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetSize(140, 14)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()
	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	K:SetSmoothing(self.Power, C["Unitframe"].Smooth)

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")

	if C["Unitframe"].ShowPortrait then
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
	end

	if C["Raid"].ShowGroupText then
		self.GroupNumber = self:CreateFontString(nil, "OVERLAY")
		self.GroupNumber:SetPoint("TOP", self.Health, 0, 16)
		self.GroupNumber:SetWidth(self.Health:GetWidth())
		self.GroupNumber:SetFontObject(UnitframeFont)
		self:Tag(self.GroupNumber, "[KkthnxUI:GetNameColor][KkthnxUI:GroupNumber]")
	end

	Module.CreatePlayerCastbar(self)

	if C["Unitframe"].AdditionalPower then
		if K.Class == "DRUID" then
			Module.CreateAddPower(self)
		elseif K.Class == "PRIEST" then
			Module.CreateAddPower(self)
		elseif K.Class == "SHAMAN" then
			Module.CreateAddPower(self)
		end
	end

	if C["Unitframe"].ShowPortrait then
		self.LeaderIndicatorOverlay = CreateFrame("Frame", nil, self.Portrait.Borders)
	else
		self.LeaderIndicatorOverlay = CreateFrame("Frame", nil, self.Health)
	end
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

	Module.CreateHealthPrediction(self, "player")

	if (C["Unitframe"].PowerPredictionBar) then
		self.PowerPrediction = Module.CreatePowerPrediction(self)
	end

	if C["Unitframe"].PlayerBuffs then
		Module.CreatePlayerAuras(self)
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