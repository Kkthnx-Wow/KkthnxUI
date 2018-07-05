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
	HEALER = [[Interface\AddOns\KkthnxUI\Media\Unitframes\healer.tga]]
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

	if (self.Portrait or self.Portrait.Borders) then
		local Status = UnitThreatSituation(unit)

		if (Status and Status > 0) then
			local r, g, b = GetThreatStatusColor(Status)
			self.Portrait.Borders:SetBackdropBorderColor(r, g, b)
		else
			self.Portrait.Borders:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		end
	end
end

function Module:CreateThreatIndicator()
	local threat = {}
	threat.IsObjectType = function()
	end
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

function Module:CreateSpecIcons()
	self.PVPSpecIcon = CreateFrame("Frame", nil, self)
	self.PVPSpecIcon:SetSize(46, 46)
	self.PVPSpecIcon:SetPoint("LEFT", self, 4, 0)

	self.PVPSpecIcon.Backgrounds = self.PVPSpecIcon:CreateTexture(nil, "BACKGROUND", -1)
	self.PVPSpecIcon.Backgrounds:SetAllPoints()
	self.PVPSpecIcon.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	self.PVPSpecIcon.Borders = CreateFrame("Frame", nil, self.PVPSpecIcon)
	self.PVPSpecIcon.Borders:SetAllPoints()
	K.CreateBorder(self.PVPSpecIcon.Borders)
end

function Module:CreateTrinkets()
	self.Trinket = CreateFrame("Frame", nil, self)
	self.Trinket:SetSize(46, 46)
	self.Trinket:SetPoint("RIGHT", self.PVPSpecIcon, "LEFT", -6, 0)

	if not self.Trinket.isSkinned then
		self.Trinket.Backgrounds = self.Trinket:CreateTexture(nil, "BACKGROUND", -1)
		self.Trinket.Backgrounds:SetAllPoints()
		self.Trinket.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		self.Trinket.Borders = CreateFrame("Frame", nil, self.Trinket)
		self.Trinket.Borders:SetAllPoints()
		K.CreateBorder(self.Trinket.Borders)
		self.Trinket.isSkinned = true
	end
end

function Module:CreateCombatFeedback()
	self.CombatText = self.Portrait.Borders:CreateFontString(nil, "OVERLAY")
	self.CombatText:SetFont(C["Media"].Font, 20, "")
	self.CombatText:SetShadowOffset(1.25, -1.25)
	self.CombatText:SetPoint("CENTER", self.Portrait, "CENTER", 0, -1)
end

function Module:CreateGlobalCooldown()
	self.GlobalCooldown = CreateFrame("Frame", self:GetName() .. "_GlobalCooldown", self.Health)
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

-- function Module:CreateResurrectIndicator()
-- 	self.ResInfo = self.Portrait.Borders:CreateFontString(nil, "OVERLAY")
-- 	self.ResInfo:SetFont(C["Media"].Font, self.Portrait:GetWidth() / 3.5, "")
-- 	self.ResInfo:SetShadowOffset(K.Mult, -K.Mult)
-- 	self.ResInfo:SetPoint("CENTER", self.Portrait, "CENTER", 0, 0)
-- end

function Module:CreatePvPIndicator(unit)
	self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PvPIndicator:SetSize(30, 30)
	self.PvPIndicator:ClearAllPoints()

	if (unit == "player") then
		self.PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT")
	else
		self.PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT")
	end

	self.PvPIndicator.Prestige = self:CreateTexture(nil, "OVERLAY")
	self.PvPIndicator.Prestige:SetSize(50, 52)
	self.PvPIndicator.Prestige:SetPoint("CENTER", self.PvPIndicator, "CENTER")
end

function Module:CreateRestingIndicator()
	self.RestingIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RestingIndicator:SetPoint("RIGHT", 0, 2)
	self.RestingIndicator:SetSize(22, 22)
	self.RestingIndicator:SetAlpha(0.7)
end

function Module:CreateAssistantIndicator()
	self.AssistantIndicator = self.Portrait.Borders:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetSize(14, 14)
	self.AssistantIndicator:SetPoint("BOTTOM", self.Portrait, "TOPLEFT", 4, -5)
end

function Module:CreateCombatIndicator()
	self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.CombatIndicator:SetSize(24, 24)
	self.CombatIndicator:SetPoint("LEFT", 0, 0)
	self.CombatIndicator:SetVertexColor(0.84, 0.75, 0.65)
end

function Module:CreateLeaderIndicator(unit)
	self.LeaderIndicator = self:CreateTexture(nil, "OVERLAY")
	if unit == "party" then
		self.LeaderIndicator:SetSize(13, 13)
	else
		self.LeaderIndicator:SetSize(16, 16)
	end
	self.LeaderIndicator:SetPoint("BOTTOM", self.Portrait, "TOPLEFT", 5, 1)
end

function Module:CreateMasterLooterIndicator()
	self.MasterLooterIndicator = self:CreateTexture(nil, "OVERLAY")
	self.MasterLooterIndicator:SetSize(16, 16)
	self.MasterLooterIndicator:SetPoint("BOTTOM", self.Portrait, "TOPRIGHT", -5, 2)
end

function Module:CreatePhaseIndicator()
	self.PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PhaseIndicator:SetSize(22, 22)
	self.PhaseIndicator:SetPoint("LEFT", self.Health, "RIGHT", 1, 0)
end

function Module:CreateQuestIndicator()
	self.QuestIndicator = self.Portrait.Borders:CreateTexture(nil, "OVERLAY")
	self.QuestIndicator:SetSize(20, 20)
	self.QuestIndicator:SetPoint("BOTTOMRIGHT", self.Health, "TOPLEFT", 11, -11)
end