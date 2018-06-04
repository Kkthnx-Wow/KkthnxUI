local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GetThreatStatusColor = _G.GetThreatStatusColor
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitReaction = _G.UnitReaction
local UnitThreatSituation = _G.UnitThreatSituation

local roleIconTextures = {
	TANK = [[Interface\AddOns\KkthnxUI\Media\Unitframes\tank.tga]],
	HEALER = [[Interface\AddOns\KkthnxUI\Media\Unitframes\healer.tga]],
}

local function UpdateGroupRole(self)
	local lfdrole = self.GroupRoleIndicator
	if (lfdrole.PreUpdate) then
		lfdrole:PreUpdate()
	end

	local role = _G.UnitGroupRolesAssigned(self.unit)
	if (_G.UnitIsConnected(self.unit)) and (role == "HEALER") or (role == "TANK") then
		lfdrole:SetTexture(roleIconTextures[role])
		lfdrole:Show()
	else
		lfdrole:Hide()
	end

	if (lfdrole.PostUpdate) then
		return lfdrole:PostUpdate(role)
	end
end

local function UpdateThreat(self, _, unit)
	if (unit ~= self.unit) then
		return
	end

	if (self.Portrait or self.Portrait.Background) then
		local Status = UnitThreatSituation(unit)

		if (Status and Status > 0) then
			local r, g, b = GetThreatStatusColor(Status)
			if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
				self.Portrait:SetBackdropBorderColor(r, g, b)
			elseif (C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits") then
				self.Portrait.Background:SetBackdropBorderColor(r, g, b)
			end
		elseif (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
			self.Portrait:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], 1)
		elseif (C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits") then
			self.Portrait.Background:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], 1)
		end
	end
end

function Module:CreateThreatIndicator()
	local threat = {}
	threat.IsObjectType = function() end
	threat.Override = UpdateThreat

	self.ThreatIndicator = threat
end

function Module:CreateGroupRoleIndicator()
		local GroupRoleIndicator = self:CreateTexture(nil, "OVERLAY")
		GroupRoleIndicator:SetPoint("BOTTOM", self.Portrait, "TOPRIGHT", 0, -6)
		GroupRoleIndicator:SetSize(16, 16)
		GroupRoleIndicator.Override = UpdateGroupRole
		self.GroupRoleIndicator = GroupRoleIndicator
end

function Module:CreatePartyTargetGlow()
	if (C["Unitframe"].TargetHighlight) then
		self.TargetHighlight = CreateFrame("Frame", nil, self)
		self.TargetHighlight:SetBackdrop({edgeFile = [[Interface\AddOns\KkthnxUI\Media\Border\BorderTickGlow.tga]], edgeSize = 10})
		self.TargetHighlight:SetPoint("TOPLEFT", self.Portrait, -7, 7)
		self.TargetHighlight:SetPoint("BOTTOMRIGHT", self.Portrait, 7, -7)
		self.TargetHighlight:SetFrameStrata("BACKGROUND")
		self.TargetHighlight:SetFrameLevel(0)
		self.TargetHighlight:Hide()

		local function UpdateTargetGlow()
			if not self.unit then
				return
			end
			local unit = self.unit

			if (UnitIsUnit("target", self.unit)) then
				self.TargetHighlight:Show()
				local reaction = UnitReaction(unit, "player")
				if UnitIsPlayer(unit) then
					local _, class = UnitClass(unit)
					if class then
						local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
						self.TargetHighlight:SetBackdropBorderColor(color.r, color.g, color.b)
					else
						self.TargetHighlight:SetBackdropBorderColor(1, 1, 1)
					end
				elseif reaction then
					local color = FACTION_BAR_COLORS[reaction]
					self.TargetHighlight:SetBackdropBorderColor(color.r, color.g, color.b)
				else
					self.TargetHighlight:SetBackdropBorderColor(1, 1, 1)
				end
			else
				self.TargetHighlight:Hide()
			end
		end

		table_insert(self.__elements, UpdateTargetGlow)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTargetGlow)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateTargetGlow)
	end
end

function Module:CreateSpecIcons()
	self.PVPSpecIcon = CreateFrame("Frame", nil, self)
	self.PVPSpecIcon:SetSize(46, 46)
	self.PVPSpecIcon:SetPoint("LEFT", self, 4, 0)
	self.PVPSpecIcon:SetTemplate("Transparent", true)
end

function Module:CreateTrinkets()
	self.Trinket = CreateFrame("Frame", nil, self)
	self.Trinket:SetSize(46, 46)
	self.Trinket:SetPoint("RIGHT", self.PVPSpecIcon, "LEFT", -6, 0)
	self.Trinket:SetTemplate("Transparent", true)
end

function Module:CreateCombatFeedback()
	self.CombatText = self:CreateFontString(nil, "OVERLAY")
	self.CombatText:SetFont(C["Media"].Font, 20, "")
	self.CombatText:SetShadowOffset(1.25, -1.25)
	self.CombatText:SetPoint("CENTER", self.Portrait, "CENTER", 0, -1)
end

function Module:CreateGlobalCooldown()
	self.GlobalCooldown = CreateFrame("Frame", self:GetName().."_GlobalCooldown", self.Health)
	self.GlobalCooldown:SetWidth(self.Health:GetWidth())
	self.GlobalCooldown:SetHeight(self.Health:GetHeight() * 1.4)
	self.GlobalCooldown:SetFrameStrata("HIGH")
	self.GlobalCooldown:SetPoint("LEFT", self.Health, "LEFT", 0, 0)
	self.GlobalCooldown.Color = {1, 1, 1}
	self.GlobalCooldown.Height = (self.Health:GetHeight() * 1.4)
	self.GlobalCooldown.Width = (10)
end

function Module:CreateReadyCheckIndicator()
	self.ReadyCheckIndicator = self:CreateTexture(nil, "OVERLAY")
	self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	self.ReadyCheckIndicator:SetSize(self.Portrait:GetWidth() - 4, self.Portrait:GetHeight() - 4)
	self.ReadyCheckIndicator.finishedTime = 5
	self.ReadyCheckIndicator.fadeTime = 3
end

function Module:CreateRaidTargetIndicator()
	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOPRIGHT", self.Portrait, "TOPLEFT", 4, 5)
	self.RaidTargetIndicator:SetSize(16, 16)
end

function Module:CreateResurrectIndicator()
	self.ResInfo = self:CreateFontString(nil, "OVERLAY")
	self.ResInfo:SetFont(C["Media"].Font, self.Portrait:GetWidth() / 3.5, "")
	self.ResInfo:SetShadowOffset(K.Mult, -K.Mult)
	self.ResInfo:SetPoint("CENTER", self.Portrait, "CENTER", 0, 0)
end

function Module:CreateAFKIndicator()
	self.AFK = self:CreateFontString(nil, "OVERLAY")
	self.AFK:SetFont(C["Media"].Font, 10, "")
	self.AFK:SetPoint("BOTTOM", self.Health, 0, -8)
	self.AFK:SetShadowOffset(K.Mult, -K.Mult)
	self.AFK.fontFormat = "AFK %s:%s"
end

function Module:CreatePvPIndicator(unit)
    self.PvPIndicator = self:CreateTexture(nil, "ARTWORK")
    self.PvPIndicator:SetSize(30, 30)
    self.PvPIndicator:ClearAllPoints()
    if (unit == "player") then
		self.PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT")
	else
		self.PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT")
	end

    self.PvPIndicator.Prestige = self:CreateTexture(nil, "ARTWORK")
    self.PvPIndicator.Prestige:SetSize(50, 52)
    self.PvPIndicator.Prestige:SetPoint("CENTER", self.PvPIndicator, "CENTER")
end

function Module:CreateRestingIndicator()
	self.RestingIndicator = self:CreateTexture(nil, "OVERLAY")
	self.RestingIndicator:SetPoint("TOPRIGHT", self.Health, 10, 8)
	self.RestingIndicator:SetSize(22, 22)
end

function Module:CreateAssistantIndicator()
	self.AssistantIndicator = self:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetSize(14, 14)
	self.AssistantIndicator:SetPoint("BOTTOM", self.Portrait, "TOPLEFT", 4, -5)
end

function Module:CreateCombatIndicator()
	self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.CombatIndicator:SetSize(24, 24)
	self.CombatIndicator:SetPoint("LEFT", 0, 0)
	self.CombatIndicator:SetVertexColor(0.84, 0.75, 0.65)
end

function Module:CreateLeaderIndicator()
	self.LeaderIndicator = self:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(14, 14)
	self.LeaderIndicator:SetPoint("BOTTOM", self.Portrait, "TOPLEFT", 4, -5)
end

function Module:CreateMasterLooterIndicator()
	self.MasterLooterIndicator = self.Power:CreateTexture(nil, "OVERLAY")
	self.MasterLooterIndicator:SetSize(14, 14)
	self.MasterLooterIndicator:SetPoint("BOTTOM", self.Portrait, "TOPLEFT", 14, -5)
end

function Module:CreatePhaseIndicator()
	self.PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PhaseIndicator:SetSize(18, 18)
	self.PhaseIndicator:SetPoint("BOTTOM", self.Portrait, "TOPRIGHT", 3, -9)
end

function Module:CreateQuestIndicator()
	self.QuestIndicator = self:CreateTexture(nil, "OVERLAY")
	self.QuestIndicator:SetSize(20, 20)
	self.QuestIndicator:SetPoint("BOTTOMRIGHT", self.Health, "TOPLEFT" , 11, -11)
end