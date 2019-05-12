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
	self.ThreatPercent:SetFontObject(K.GetFont(C["Unitframe"].Font))
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

function Module:CreateOfflineIndicator(size, position)
	if C["Unitframe"].ShowPortrait then
		size = size or self.Portrait:GetSize()
		position = position or "CENTER"
		self.OfflineIcon = self.Portrait.Borders:CreateTexture(nil, "OVERLAY", 7)
		self.OfflineIcon:SetSize(size, size)
		self.OfflineIcon:SetPoint("CENTER", self.Portrait.Borders)
	else
		size = size or 18
		position = position or "CENTER"
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
	self.DebuffHighlightFilterTable = Module.DebuffHighlightColors
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

-- Nameplate Indicators
function Module:CreatePlateThreatIndicator()
	if C["Nameplates"].Threat ~= true then
		return
	end

	self.ThreatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.ThreatIndicator:SetSize(16, 16)
	self.ThreatIndicator:SetPoint("CENTER", self.Health, "TOPRIGHT")
	self.ThreatIndicator:SetColorTexture(0, 0, 0, 0)

	function self.ThreatIndicator:PreUpdate(unit)
		Module:PreUpdateThreat(self, unit)
	end

	function self.ThreatIndicator:PostUpdate(unit, status)
		Module:PostUpdateThreat(self, unit, status)
	end
end

function Module:CreatePlateQuestIcons()
	if C["Nameplates"].QuestIcon ~= true then
		return
	end

	local size = C["Nameplates"].QuestIconSize

	self.QuestIcons = CreateFrame("Frame", self:GetDebugName() .. "QuestIcons", self)
	self.QuestIcons:Hide()
	self.QuestIcons:SetSize(size + 4, size + 4)

	for _, object in pairs({"Item", "Loot", "Skull", "Chat"}) do
		self.QuestIcons[object] = self.QuestIcons:CreateTexture(nil, "BORDER", nil, 1)
		self.QuestIcons[object]:SetPoint("CENTER")
		self.QuestIcons[object]:SetSize(size, size)
		self.QuestIcons[object]:Hide()
	end

	self.QuestIcons.Item:SetTexCoord(unpack(K.TexCoords))

	self.QuestIcons.Skull:SetSize(size + 4, size + 4)

	self.QuestIcons.Chat:SetSize(size + 4, size + 4)
	self.QuestIcons.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
	self.QuestIcons.Chat:SetTexCoord(0, 0.5, 0.5, 1)

	self.QuestIcons.Text = self.QuestIcons:CreateFontString(nil, "OVERLAY")
	self.QuestIcons.Text:SetPoint("BOTTOMLEFT", self.QuestIcons, "BOTTOMLEFT", -2, -0.8)
	self.QuestIcons.Text:SetFont(C["Media"].Font, 11, "")
	self.QuestIcons.Text:SetShadowOffset(1.2, -1.2)
end

function Module:CreatePlateHealerIcons()
	if C["Nameplates"].MarkHealers ~= true then
		return
	end

	self.HealerSpecs = self:CreateTexture(nil, "OVERLAY")
	self.HealerSpecs:SetSize(40, 40)
	self.HealerSpecs:SetTexture([[Interface\AddOns\KkthnxUI\Media\Nameplates\UI-Plate-Healer.tga]])
	self.HealerSpecs:Hide()
end

function Module:CreatePlateClassIcons()
	if C["Nameplates"].ClassIcons ~= true then
		return
	end

	self.Class = CreateFrame("Frame", nil, self)
	self.Class:SetSize(self:GetHeight() - 1, self:GetHeight() - 1)
	self.Class:SetPoint("TOPRIGHT", self, "TOPLEFT", -4, 0)
	self.Class:Hide()

	self.Class.Icon = self.Class:CreateTexture(nil, "ARTWORK")
	self.Class.Icon:SetAllPoints()
	self.Class.Icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Nameplates\\ICONS-CLASSES")
	self.Class.Icon:SetTexCoord(0, 0, 0, 0)
end

function Module:CreatePlateTotemIcons()
	if C["Nameplates"].Totems ~= true then
		return
	end

	self.Totem = CreateFrame("Frame", nil, self)
	self.Totem:SetSize((C["Nameplates"].Height * 2 * K.NoScaleMult) + 8, (C["Nameplates"].Height * 2 * K.NoScaleMult) + 8)
	self.Totem:CreateShadow(true)
	self.Totem:SetPoint("BOTTOM", self.Health, "TOP", 0, 38)
	self.Totem:Hide()

	self.Totem.Icon = self.Totem:CreateTexture(nil, "ARTWORK")
	self.Totem.Icon:SetAllPoints()
end

function Module:CreatePlateClassificationIcons()
	if C["Nameplates"].EliteIcon ~= true then
		return
	end

	self.ClassificationIndicator = self:CreateTexture(nil, "OVERLAY")
end

function Module:CreatePlateTargetArrow()
	if C["Nameplates"].TargetArrow ~= true then
		return
	end

	self.TopArrow = self:CreateTexture(nil, "OVERLAY")
	self.TopArrow:SetPoint("BOTTOM", self.Debuffs, "TOP", 0, 30)
	self.TopArrow:SetSize(50, 50)
	self.TopArrow:SetTexture([[Interface\AddOns\KkthnxUI\Media\Nameplates\UI-Plate-Arrow-Top.tga]])
	self.TopArrow:Hide()
end

function Module:CreatePlateClassPowerText()
	self.ClassPowerText = self:CreateFontString(nil, "OVERLAY")
	self.ClassPowerText:SetFontObject(K.GetFont(C["Nameplates"].Font))
	self.ClassPowerText:SetFont(select(1, self.ClassPowerText:GetFont()), 26, select(3, self.ClassPowerText:GetFont()))
	self.ClassPowerText:SetPoint("TOP", self.Health, "BOTTOM", 0, -10)
	self.ClassPowerText:SetWidth(C["Nameplates"].Width)
	if K.Class == "DEATHKNIGHT" then
		self:Tag(self.ClassPowerText, "[runes]", "player")
	else
		self:Tag(self.ClassPowerText, "[KkthnxUI:ClassPower]", "player")
	end

	self.ClassPowerText:Hide()
end

-- Nameplate and Unitframe Indicators
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

function Module.CreateCombatFeedback(self)
	local cf = CreateFrame("Frame", nil, self)
	cf:SetSize(32, 32)
	cf:SetPoint("CENTER", self.Portrait, "CENTER", 0, -1)
	cf:SetFrameStrata("TOOLTIP")

	self.CombatText = cf:CreateFontString(nil, "OVERLAY")
	self.CombatText:SetFont(C["Media"].Font, C["FloatingCombatFeedback"].FontSize, "")
	self.CombatText:SetShadowOffset(1.25, -1.25)
	self.CombatText:SetPoint("CENTER", cf, "CENTER", 0, -1)
end

function Module.CreateNameplateCombatFeedback(self)
	local fcf = CreateFrame("Frame", nil, self)
	fcf:SetSize(32, 32)
	fcf:SetPoint("CENTER")
	fcf:SetFrameStrata("TOOLTIP")

	for i = 1, 12 do
		fcf[i] = fcf:CreateFontString("$parentFCFText" .. i, "OVERLAY")
		fcf[i]:SetShadowOffset(1.25, -1.25)
	end
		
	fcf.font = C["Media"].Font
	fcf.fontHeight = C["FloatingCombatFeedback"].FontSize
	fcf.fontFlags = "NONE"
	fcf.useCLEU = true
	fcf.abbreviateNumbers = C["FloatingCombatFeedback"].AbbreviateNumbers
	fcf.scrollTime = C["FloatingCombatFeedback"].ScrollTime
	fcf.format = "%1$s |T%2$s:0:0:0:0:64:64:4:60:4:60|t"
	self.FloatingCombatFeedback = fcf

	-- Hide blizzard combat text
	SetCVar("floatingCombatTextCombatHealing", 0)
	SetCVar("floatingCombatTextCombatDamage", 0)
		
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("PLAYER_LOGOUT")
	frame:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_LOGOUT" then
			SetCVar("floatingCombatTextCombatHealing", 1)
			SetCVar("floatingCombatTextCombatDamage", 1)
		end
	end)
end