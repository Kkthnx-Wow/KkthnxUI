local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _G = _G

local UnitThreatSituation = _G.UnitThreatSituation
local GetThreatStatusColor = _G.GetThreatStatusColor
local CreateFrame = _G.CreateFrame

function K.CreateCombatText(self)
	self.CombatFeedbackText = self:CreateFontString(nil, "OVERLAY", 7)
	self.CombatFeedbackText:SetFont(C["Media"].Font, 14, "OUTLINE")
	self.CombatFeedbackText:SetShadowOffset(0, -0)
	self.CombatFeedbackText:SetPoint("CENTER", self.Portrait)
	self.CombatFeedbackText.colors = {
		DAMAGE = {0.69, 0.31, 0.31},
		CRUSHING = {0.69, 0.31, 0.31},
		CRITICAL = {0.69, 0.31, 0.31},
		GLANCING = {0.69, 0.31, 0.31},
		STANDARD = {0.84, 0.75, 0.65},
		IMMUNE = {0.84, 0.75, 0.65},
		ABSORB = {0.84, 0.75, 0.65},
		BLOCK = {0.84, 0.75, 0.65},
		RESIST = {0.84, 0.75, 0.65},
		MISS = {0.84, 0.75, 0.65},
		HEAL = {0.33, 0.59, 0.33},
		CRITHEAL = {0.33, 0.59, 0.33},
		ENERGIZE = {0.31, 0.45, 0.63},
		CRITENERGIZE = {0.31, 0.45, 0.63},
	}
end

function K.CreateGlobalCooldown(self)
	self.GCD = CreateFrame("Frame", self:GetName().."_GCD", self.Health)
	self.GCD:SetWidth(self.Health:GetWidth())
	self.GCD:SetHeight(self.Health:GetHeight() * 1.4)
	self.GCD:SetFrameStrata("HIGH")
	self.GCD:SetPoint("LEFT", self.Health, "LEFT", 0, 0)
	self.GCD.Smooth = C["Unitframe"].Smooth
	self.GCD.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.GCD.Color = {1, 1, 1}
	self.GCD.Height = (self.Health:GetHeight() * 1.4)
	self.GCD.Width = (10)
end

-- Portrait Timer
function K.CreatePortraitTimer(self)
	self.PortraitTimer = CreateFrame("Frame", nil, self)
	self.PortraitTimer.Icon = self.PortraitTimer:CreateTexture(nil, "BACKGROUND")
	self.PortraitTimer.Icon:SetAllPoints(self.Portrait)
	self.PortraitTimer.Remaining = K.SetFontString(self.PortraitTimer, C["Media"].Font, self.Portrait:GetSize() / 2, C["Media"].FontStyle, "CENTER")
	self.PortraitTimer.Remaining:SetShadowOffset(0, 0)
	self.PortraitTimer.Remaining:SetPoint("CENTER", self.PortraitTimer.Icon)
end

function K.CreateGroupRoleIndicator(self)
	self.GroupTextRoleIndicator = self:CreateFontString(nil, "OVERLAY")
	self.GroupTextRoleIndicator:SetFont(C["Media"].Font, 10, "")
	self.GroupTextRoleIndicator:SetPoint("BOTTOM", self.Portrait, "BOTTOM", 0, -14)
	self.GroupTextRoleIndicator:SetShadowOffset(K.Mult, -K.Mult)
	self:Tag(self.GroupTextRoleIndicator, "[KkthnxUI:GroupRole]")
end

function K.CreateReadyCheckIndicator(self)
	self.ReadyCheckIndicator = self:CreateTexture(nil, "OVERLAY")
	self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	self.ReadyCheckIndicator:SetSize(self.Portrait:GetWidth() - 2, self.Portrait:GetHeight() - 2)
	self.ReadyCheckIndicator.finishedTime = 5
	self.ReadyCheckIndicator.fadeTime = 3
end

function K.CreateRaidTargetIndicator(self)
	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("CENTER", self.Portrait)
	self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 14)
	self.RaidTargetIndicator:SetSize(16, 16)
end

function K.CreateResurrectIndicator(self)
	self.ResurrectIndicator = self:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	self.ResurrectIndicator:SetSize(self.Portrait:GetWidth() - 2, self.Portrait:GetHeight() - 2)
end

function K.CreateRestingIndicator(self)
	self.RestingIndicator = self:CreateTexture(nil, "OVERLAY")
	self.RestingIndicator:SetPoint("TOPRIGHT", self.Health, 10, 8)
	self.RestingIndicator:SetSize(22, 22)
end

function K.CreateAssistantIndicator(self)
	self.AssistantIndicator = self:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetSize(14, 14)
	self.AssistantIndicator:SetPoint("BOTTOM", self.Portrait, "TOPLEFT", 4, -5)
end

function K.CreateCombatIndicator(self)
	self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.CombatIndicator:SetSize(24, 24)
	self.CombatIndicator:SetPoint("LEFT", 0, 0)
	self.CombatIndicator:SetVertexColor(0.84, 0.75, 0.65)
end

function K.CreateLeaderIndicator(self)
	self.LeaderIndicator = self:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(14, 14)
	self.LeaderIndicator:SetPoint("BOTTOM", self.Portrait, "TOPLEFT", 4, -5)
end

function K.CreateMasterLooterIndicator(self)
	self.MasterLooterIndicator = self.Power:CreateTexture(nil, "OVERLAY")
	self.MasterLooterIndicator:SetSize(14, 14)
	self.MasterLooterIndicator:SetPoint("BOTTOM", self.Portrait, "TOPLEFT", 14, -5)
end

function K.CreatePhaseIndicator(self)
	self.PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PhaseIndicator:SetSize(18, 18)
	self.PhaseIndicator:SetPoint("BOTTOM", self.Portrait, "TOPRIGHT", 3, -9)
end

function K.CreateQuestIndicator(self)
	self.QuestIndicator = self:CreateTexture(nil, "OVERLAY")
	self.QuestIndicator:SetSize(22, 22)
	self.QuestIndicator:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPLEFT" , 9, -12)
end

local function UpdateThreat(self, event, unit)
	if (self.unit ~= unit) then return end

	local situation = UnitThreatSituation(unit)
	if (situation and situation > 0) then
		local r, g, b = GetThreatStatusColor(situation)
		if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			self.Portrait:SetBackdropBorderColor(r, g, b, 1)
		else
			self.Portrait.Background:SetBackdropBorderColor(r, g, b, 1)
		end
	else
		if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			self.Portrait:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], 1)
		else
			self.Portrait.Background:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], 1)
		end
	end
end

function K.CreateThreatIndicator(self)
	self.ThreatIndicator = {}
	self.ThreatIndicator.IsObjectType = function() end
	self.ThreatIndicator.Override = UpdateThreat
end