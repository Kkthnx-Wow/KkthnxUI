local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Target.lua code!")
	return
end

local _G = _G
local print = print
local unpack = unpack

local CreateFrame = _G.CreateFrame
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave

local UnitframeFont = K.GetFont(C["Unitframe"].Font)
local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

function K.CreateTarget(self, unit)
	unit = unit:match("^(%a-)%d+") or unit

	if (unit == "target") then
		self:RegisterForClicks("AnyUp")
		self:HookScript("OnEnter", UnitFrame_OnEnter)
		self:HookScript("OnLeave", UnitFrame_OnLeave)

		-- Health bar
		self.Health = CreateFrame("StatusBar", "$parent.Healthbar", self)
		self.Health:SetTemplate("Transparent")
		self.Health:SetFrameStrata("LOW")
		self.Health:SetFrameLevel(1)
		self.Health:SetStatusBarTexture(UnitframeTexture)

		self.Health.Cutaway = C["Unitframe"].Cutaway
		self.Health.Smooth = C["Unitframe"].Smooth
		self.Health.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
		self.Health.colorTapping = true
		self.Health.colorDisconnected = true
		if C["Unitframe"].ColorHealthByValue then
			self.Health.colorSmooth = true
			self.Health.colorClass = false
			self.Health.colorReaction = false
		else
			self.Health.colorSmooth = false
			self.Health.colorClass = true
			self.Health.colorReaction = true
		end
		self.Health.frequentUpdates = true
		self.Health.PostUpdate = K.PostUpdateHealth

		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", -26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")

		-- Power Bar
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetTemplate("Transparent")
		self.Power:SetFrameStrata("LOW")
		self.Power:SetFrameLevel(1)
		self.Power:SetStatusBarTexture(UnitframeTexture)

		self.Power.Cutaway = C["Unitframe"].Cutaway
		self.Power.Smooth = C["Unitframe"].Smooth
		self.Power.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
		self.Power.colorPower = true
		self.Power.frequentUpdates = true

		if (C["Unitframe"].PowerClass) then
			self.Power.colorClass = true
			self.Power.colorReaction = true
		else
			self.Power.colorPower = true
		end

		-- Power StatusBar
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Power.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")

		-- 3D and such models. We provide 3 choices here.
		if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			-- Create the portrait globally
			self.Portrait = CreateFrame("PlayerModel", self:GetName().."_3DPortrait", self)
			self.Portrait:SetTemplate("Transparent")
			self.Portrait:SetFrameStrata("BACKGROUND")
			self.Portrait:SetFrameLevel(1)

			if (unit == "target") then
				self.Portrait:SetSize(46, 46)
				self.Portrait:SetPoint("RIGHT", self, -4, 0)
			end
		elseif (C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits") then
			self.Portrait = self.Health:CreateTexture("$parentPortrait", "BACKGROUND", nil, 7)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)

			-- We need to create this for non 3D Ports
			self.Portrait.Background = CreateFrame("Frame", self:GetName().."_2DPortrait", self)
			self.Portrait.Background:SetTemplate("Transparent")
			self.Portrait.Background:SetFrameStrata("LOW")
			self.Portrait.Background:SetFrameLevel(1)

			if (unit == "target") then
				self.Portrait:SetSize(46, 46)
				self.Portrait:SetPoint("RIGHT", self, -4, 0)
				self.Portrait.Background:SetSize(46, 46)
				self.Portrait.Background:SetPoint("RIGHT", self, -4, 0)
			end

			if C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
				self.Portrait.PostUpdate = K.UpdateClassPortraits
			end
		end

		-- Name Text + Threat Percent
		self.Name = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -3, 4)
		self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 3, 4)
		if C["Unitframe"].NameAbbreviate == true then
			self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMediumAbbrev]")
		else
			self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
		end
		-- Level Text
		self.Level = K.SetFontString(self, C["Media"].Font, 14, C["Unitframe"].Outline and "OUTLINE" or "", "LEFT")
		self.Level:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Level:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
		self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

		-- Threat Text
		if C["Unitframe"].ThreatPercent == true then
			self.ThreatPercentText = K.SetFontString(self, C["Media"].Font, 14, C["Unitframe"].Outline and "OUTLINE" or "", "LEFT")
			self.ThreatPercentText:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			self.ThreatPercentText:SetPoint("RIGHT", self.Power, "LEFT", -4, 0)
			self:Tag(self.ThreatPercentText, "[KkthnxUI:NameplateThreatColor][KkthnxUI:NameplateThreat]")
		end

		if C["Unitframe"].Castbars then
			K.CreateCastBar(self, "target")
		end
		if (C["Unitframe"].CombatText) then
			K.CreateCombatFeedback(self)
		end
		K.CreateAuras(self, "target")
		if C["Unitframe"].PvPText then
			K.CreatePvPText(self, "target")
		end
		K.CreateQuestIndicator(self)
		K.CreateRaidTargetIndicator(self)
		K.CreateReadyCheckIndicator(self)
		K.CreateResurrectIndicator(self)
		K.CreateThreatIndicator(self)
		self.HealthPrediction = K.CreateHealthPrediction(self)

		self.Threat = {
			Hide = K.Noop, -- oUF stahp
			IsObjectType = K.Noop,
			Override = K.CreateThreatIndicator,
		}

		self.Range = K.CreateRange(self)
	end
end
