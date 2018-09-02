local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame
local GetThreatStatusColor = _G.GetThreatStatusColor
local UnitThreatSituation = _G.UnitThreatSituation

local function UpdateThreat(self, _, unit)
	if (unit ~= self.unit) then
		return
	end

	if (self.Portrait.Borders) then
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

function Module:CreatePortraitTimers()
   	self.PortraitTimer = CreateFrame("Frame", nil, self.Health)
	self.PortraitTimer:SetAllPoints(self.Portrait)

	self.PortraitTimer.Borders = CreateFrame("Frame", nil, self.PortraitTimer)
	self.PortraitTimer.Borders:SetAllPoints()
	--self.PortraitTimer.Borders:CreateBorder()
	K.CreateBorder(self.PortraitTimer.Borders)
	self.PortraitTimer.Borders:CreateInnerShadow()
end

function Module:CreateSpecIcons()
	self.PVPSpecIcon = CreateFrame("Frame", nil, self)
	self.PVPSpecIcon:SetSize(46, 46)
	self.PVPSpecIcon:SetPoint("LEFT", self, 4, 0)
	self.PVPSpecIcon:CreateBorder()
end

function Module:CreateTrinkets()
	self.Trinket = CreateFrame("Frame", nil, self)
	self.Trinket:SetSize(46, 46)
	self.Trinket:SetPoint("RIGHT", self.PVPSpecIcon, "LEFT", -6, 0)
	self.Trinket:CreateBorder()
end

function Module:CreateResurrectIndicator(size)
	size = size or self.Portrait:GetSize()

	self.ResurrectIndicator = self.Portrait.Borders:CreateTexture(nil, "OVERLAY", 7)
	self.ResurrectIndicator:SetSize(size, size)
	self.ResurrectIndicator:SetPoint("CENTER", self.Portrait.Borders)
end

function Module:CreateDebuffHighlight()
	self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.DebuffHighlight:SetAllPoints(self.Health)
	self.DebuffHighlight:SetTexture(C["Media"].Blank)
	self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	self.DebuffHighlight:SetBlendMode("ADD")
	self.DebuffHighlightAlpha = 0.45
	self.DebuffHighlightFilter = true
	self.DebuffHighlightFilterTable = Module.DebuffHighlightColors
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
	self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait.Borders)
	self.ReadyCheckIndicator:SetSize(self.Portrait.Borders:GetWidth() - 4, self.Portrait.Borders:GetHeight() - 4)
	self.ReadyCheckIndicator.finishedTime = 5
	self.ReadyCheckIndicator.fadeTime = 3
end

function Module:CreateRaidTargetIndicator(size)
	size = size or 16

	self.RaidTargetOverlay = CreateFrame("Frame", nil, self.Portrait.Borders)
	self.RaidTargetOverlay:SetAllPoints()
	self.RaidTargetOverlay:SetFrameLevel(self.Portrait.Borders:GetFrameLevel() + 4)

	self.RaidTargetIndicator = self.RaidTargetOverlay:CreateTexture(nil, "OVERLAY", 7)
	self.RaidTargetIndicator:SetPoint("TOP", self.RaidTargetOverlay, 0, 10)
	self.RaidTargetIndicator:SetSize(size, size)
end

local function PostUpdatePvPIndicator(self, unit, status)
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) and status == "ffa" then
		self:SetTexture("Intewrface\\TargetingFrame\\UI-PVP-FFA")
		self:SetTexCoord(0, 0.65625, 0, 0.65625)
	elseif factionGroup and UnitIsPVP(unit) and status ~= nil then
		self:SetTexture("Interface\\QuestFrame\\objectivewidget")

		if factionGroup == "Alliance" then
			self:SetTexCoord(0.00390625, 0.136719, 0.511719, 0.671875)
		else
			self:SetTexCoord(0.00390625, 0.136719, 0.679688, 0.839844)
		end
	end
end

function Module:CreatePvPIndicator(unit, parent, width, height)
	parent = parent or self.Portrait.Borders
	width = width or 30
	height = height or 33

	self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PvPIndicator:SetSize(width, height)
	self.PvPIndicator:ClearAllPoints()

	if (unit == "player") then
		self.PvPIndicator:SetPoint("RIGHT", parent, "LEFT")
	else
		self.PvPIndicator:SetPoint("LEFT", parent, "RIGHT")
	end

	self.PvPIndicator.PostUpdate = PostUpdatePvPIndicator

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

function Module:CreateCombatIndicator()
	self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.CombatIndicator:SetSize(20, 20)
	self.CombatIndicator:SetPoint("LEFT", 0, 0)
	self.CombatIndicator:SetVertexColor(1, 0.2, 0.2, 1)
end

function Module:CreatePhaseIndicator()
	self.PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PhaseIndicator:SetSize(22, 22)
	self.PhaseIndicator:SetPoint("LEFT", self.Health, "RIGHT", 1, 0)
end

function Module:CreateQuestIndicator(size)
	size = size or 20

	self.QuestOverlay = CreateFrame("Frame", nil, self.Health)
	self.QuestOverlay:SetAllPoints()
	self.QuestOverlay:SetFrameLevel(self.Health:GetFrameLevel() + 4)

	self.QuestIndicator = self.QuestOverlay:CreateTexture(nil, "OVERLAY", 7)
	self.QuestIndicator:SetTexture("Interface\\MINIMAP\\ObjectIcons")
	self.QuestIndicator:SetTexCoord(0.125, 0.250, 0.125, 0.250)
	self.QuestIndicator:SetSize(size, size)
	self.QuestIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", -4, 0)
end