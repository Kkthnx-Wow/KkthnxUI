local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame
local GetThreatStatusColor = _G.GetThreatStatusColor
local UnitFactionGroup = _G.UnitFactionGroup
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UnitThreatSituation = _G.UnitThreatSituation

-- Unitframe Indicators
local function UpdateThreat(self, _, unit)
	if (unit ~= self.unit) then
		return
	end

	if C["Unitframe"].ShowPortrait then
		if (self.Portrait.Borders) then
			local Status = UnitThreatSituation(unit)

			if (Status and Status > 0) then
				local r, g, b = GetThreatStatusColor(Status)
				self.Portrait.Borders:SetBackdropBorderColor(r, g, b)
			else
				self.Portrait.Borders:SetBackdropBorderColor()
			end
		end
	else
		if (self.Health) then
			local Status = UnitThreatSituation(unit)

			if (Status and Status > 0) then
				local r, g, b = GetThreatStatusColor(Status)
				self.Health:SetBackdropBorderColor(r, g, b)
			else
				self.Health:SetBackdropBorderColor()
			end
		end
	end
end

function Module:CreateThreatIndicator()
	self.ThreatIndicator = {
		IsObjectType = function() end,
		Override = UpdateThreat,
	}
end

function Module:CreateThreatPercent(tPoint, tRelativePoint, tOfsx, tOfsy, tSize)
	tPoint = tPoint or "RIGHT"
	tRelativePoint = tRelativePoint or "LEFT"
	tOfsx = tOfsx or -4
	tOfsy = tOfsy or 0
	tSize = tSize or 14

	self.ThreatPercent = self:CreateFontString(nil, "OVERLAY")
	self.ThreatPercent:SetPoint(tPoint, self.Health, tRelativePoint, tOfsx, tOfsy)
	self.ThreatPercent:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
	self.ThreatPercent:SetFont(select(1, self.ThreatPercent:GetFont()), tSize, select(3, self.ThreatPercent:GetFont()))
	self:Tag(self.ThreatPercent, "[KkthnxUI:ThreatColor][KkthnxUI:ThreatPercent]")
end

function Module:CreatePortraitTimers()
	if not C["Unitframe"].ShowPortrait then return end

	self.PortraitTimer = CreateFrame("Frame", nil, self.Health)
	self.PortraitTimer:SetInside(self.Portrait, 1, 1)
	self.PortraitTimer:CreateInnerShadow()
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
	if C["Unitframe"].ShowPortrait then
		size = size or self.Portrait:GetSize()
		self.ResurrectIndicator = self.Portrait.Borders:CreateTexture(nil, "OVERLAY", 7)
		self.ResurrectIndicator:SetSize(size, size)
		self.ResurrectIndicator:SetPoint("CENTER", self.Portrait.Borders)
	else
		size = size or 18
		self.ResurrectIndicator = self.Health:CreateTexture(nil, "OVERLAY", 7)
		self.ResurrectIndicator:SetSize(size, size)
		self.ResurrectIndicator:SetPoint("CENTER", self.Health)
	end
end

function Module:CreateOfflineIndicator(size)
	if C["Unitframe"].ShowPortrait then
		size = size or self.Portrait:GetSize()
		self.OfflineIcon = self.Portrait.Borders:CreateTexture(nil, "OVERLAY", 7)
		self.OfflineIcon:SetSize(size, size)
		self.OfflineIcon:SetPoint("CENTER", self.Portrait.Borders)
	else
		size = size or 18
		self.OfflineIcon = self.Health:CreateTexture(nil, "OVERLAY", 7)
		self.OfflineIcon:SetSize(size, size)
		self.OfflineIcon:SetPoint("CENTER", self.Health)
	end
end

function Module:CreateSummonIndicator(size)
	if C["Unitframe"].ShowPortrait then
		size = size or self.Portrait:GetSize()
		self.SummonIndicator = self.Portrait.Borders:CreateTexture(nil, "OVERLAY", 7)
		self.SummonIndicator:SetSize(size, size)
		self.SummonIndicator:SetPoint("CENTER", self.Portrait.Borders)
	else
		size = size or 18
		self.SummonIndicator = self.Health:CreateTexture(nil, "OVERLAY", 7)
		self.SummonIndicator:SetSize(size, size)
		self.SummonIndicator:SetPoint("CENTER", self.Health)
	end
end

function Module:CreateDebuffHighlight()
	self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.DebuffHighlight:SetAllPoints(self.Health)
	self.DebuffHighlight:SetTexture(C["Media"].Blank)
	self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	self.DebuffHighlight:SetBlendMode("ADD")

	self.DebuffHighlightAlpha = 0.45
	self.DebuffHighlightFilter = true
	self.DebuffHighlightFilterTable = K.DebuffHighlightColors
end

function Module:CreateGlobalCooldown()
	self.GlobalCooldown = CreateFrame("Frame", nil, self.Health)
	self.GlobalCooldown:SetWidth(130)
	self.GlobalCooldown:SetHeight(26 * 1.4)
	self.GlobalCooldown:SetFrameStrata("HIGH")
	self.GlobalCooldown:SetPoint("LEFT", self.Health, "LEFT", 0, 0)
	self.GlobalCooldown.Height = (26 * 1.4)
	self.GlobalCooldown.Width = (10)
end

function Module:CreateReadyCheckIndicator()
	self.ReadyCheckIndicator = self:CreateTexture(nil, "OVERLAY")

	if C["Unitframe"].ShowPortrait then
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait.Borders)
		self.ReadyCheckIndicator:SetSize(self.Portrait.Borders:GetWidth() - 4, self.Portrait.Borders:GetHeight() - 4)
	else
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Health)
		self.ReadyCheckIndicator:SetSize(self.Health:GetWidth() - 4, self.Health:GetHeight() - 4)
	end

	self.ReadyCheckIndicator.finishedTime = 5
	self.ReadyCheckIndicator.fadeTime = 3
end

function Module:CreateRaidTargetIndicator(size)
	size = size or 16

	if C["Unitframe"].ShowPortrait then
		self.RaidTargetOverlay = CreateFrame("Frame", nil, self.Portrait.Borders)
		self.RaidTargetOverlay:SetAllPoints()
		self.RaidTargetOverlay:SetFrameLevel(self.Portrait.Borders:GetFrameLevel() + 4)
	else
		self.RaidTargetOverlay = CreateFrame("Frame", nil, self.Health)
		self.RaidTargetOverlay:SetAllPoints()
		self.RaidTargetOverlay:SetFrameLevel(self.Health:GetFrameLevel() + 4)
	end

	self.RaidTargetIndicator = self.RaidTargetOverlay:CreateTexture(nil, "OVERLAY", 7)
	self.RaidTargetIndicator:SetPoint("TOP", self.RaidTargetOverlay, 0, 10)
	self.RaidTargetIndicator:SetSize(size, size)
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

local function PostUpdatePvPIndicator(self, unit, status)
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) and status == "ffa" then
		self:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self:SetTexCoord(0, 0.65625, 0, 0.65625)
	elseif factionGroup and UnitIsPVP(unit) and status ~= nil then
		self:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\ObjectiveWidget")

		if factionGroup == "Alliance" then
			self:SetTexCoord(0.00390625, 0.136719, 0.511719, 0.671875)
		else
			self:SetTexCoord(0.00390625, 0.136719, 0.679688, 0.839844)
		end
	end
end

function Module:CreatePvPIndicator(unit, parent, width, height)
	if C["Unitframe"].ShowPortrait then
		parent = parent or self.Portrait.Borders
	else
		parent = parent or self.Health
	end
	width = width or 30
	height = height or 33

	self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PvPIndicator:SetSize(width, height)
	self.PvPIndicator:ClearAllPoints()

	if (unit == "player") then
		self.PvPIndicator:SetPoint("RIGHT", parent, "LEFT", -2, 0)
	else
		self.PvPIndicator:SetPoint("LEFT", parent, "RIGHT", 2, 0)
	end

	self.PvPIndicator.PostUpdate = PostUpdatePvPIndicator
end

function Module.PostUpdateAddPower(element, _, cur, max)
	if element.Text and max > 0 then
		local perc = cur / max * 100
		if perc == 100 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = format("%d%%", perc)
			element:SetAlpha(1)
		end
		element.Text:SetText(perc)
	end
end

function Module:CreateAddPower()
	self.AdditionalPower = CreateFrame("StatusBar", nil, self)
	self.AdditionalPower:SetHeight(12)
	self.AdditionalPower:SetWidth(self.Portrait:GetWidth() + self.Health:GetWidth() + 6)
	self.AdditionalPower:SetPoint("BOTTOM", self, "TOP", 0, 3)
	self.AdditionalPower:SetStatusBarTexture(K.GetTexture(C["UITextures"].UnitframeTextures))
	self.AdditionalPower:SetStatusBarColor(unpack(K.Colors.power["MANA"]))
	self.AdditionalPower:CreateBorder()
	self.AdditionalPower.frequentUpdates = true

	K:SetSmoothing(self.AdditionalPower, C["Unitframe"].Smooth)

	self.AdditionalPower.Text = self.AdditionalPower:CreateFontString(nil, "OVERLAY")
	self.AdditionalPower.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
	self.AdditionalPower.Text:SetPoint("CENTER", self.AdditionalPower, "CENTER", 0, 0)

	self.AdditionalPower.PostUpdate = Module.PostUpdateAddPower
end