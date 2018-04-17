local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local _, ns = ...
local oUF = ns.oUF or oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Player.lua code!")
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

function K.CreatePlayer(self, unit)
	unit = unit:match("^(%a-)%d+") or unit

	if (unit == "player") then
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
		self.Health.colorClass = true
		self.Health.colorReaction = true
		self.Health.frequentUpdates = true
		self.Health.PostUpdate = K.PostUpdateHealth

		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent]")

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

		if C["Unitframe"].PowerClass then
			self.Power.colorClass = true
			self.Power.colorReaction = true
		else
			self.Power.colorPower = true
		end

		-- Power StatusBar
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power Value
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

			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
		elseif (C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits") then
			self.Portrait = self.Health:CreateTexture("$parentPortrait", "BACKGROUND", nil, 7)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)

			-- We need to create this for non 3D Ports
			self.Portrait.Background = CreateFrame("Frame", self:GetName().."_2DPortrait", self)
			self.Portrait.Background:SetTemplate("Transparent")
			self.Portrait.Background:SetFrameStrata("LOW")
			self.Portrait.Background:SetFrameLevel(1)

			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
			self.Portrait.Background:SetSize(46, 46)
			self.Portrait.Background:SetPoint("LEFT", self, 4, 0)

			if C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
				self.Portrait.PostUpdate = K.UpdateClassPortraits
			end
		end

		if C["Unitframe"].Castbars then
			K.CreateCastBar(self, "player")
		end
		if (C["Unitframe"].CombatText) then
			K.CreateCombatFeedback(self)
		end
		if (C["Unitframe"].GlobalCooldown) then
			K.CreateGlobalCooldown(self)
		end
		K.CreateAdditionalPower(self)
		K.CreateAssistantIndicator(self)
		K.CreateClassModules(self, 194, 12, 6)
		K.CreateClassTotems(self, 194, 12, 6)
		K.CreateCombatIndicator(self)
		K.CreateLeaderIndicator(self)
		K.CreateMasterLooterIndicator(self)
		if C["Unitframe"].PvPText then
			K.CreatePvPText(self, "player")
		end
		K.CreateAFKIndicator(self)
		K.CreateRaidTargetIndicator(self)
		K.CreateReadyCheckIndicator(self)
		K.CreateRestingIndicator(self)
		K.CreateThreatIndicator(self)
		self.HealthPrediction = K.CreateHealthPrediction(self)
		self.CombatFade = C["Unitframe"].CombatFade
		if (C["Unitframe"].PowerPredictionBar) then
			K.CreatePowerPrediction(self)
		end
		if K.Class == "DEATHKNIGHT" then
			K.CreateClassRunes(self, 194, 12, 6)
		elseif (K.Class == "MONK") then
			K.CreateStagger(self)
		end

		self.Threat = {
			Hide = K.Noop, -- oUF stahp
			IsObjectType = K.Noop,
			Override = K.CreateThreatIndicator,
		}
	end
end