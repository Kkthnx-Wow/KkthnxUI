local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Unitframes.lua code!")
	return
end

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreateTargetOfTarget()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(14)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.PostUpdate = C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" and Module.UpdateHealth
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Unitframe"].HealthbarColor.Value == "Value" then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor.Value == "Dark" then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 10, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(8)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	if C["Unitframe"].TargetOfTargetName then
		self.Name = self:CreateFontString(nil, "OVERLAY")
		self.Name:SetPoint("BOTTOM", self.Power, 0, -16)
		self.Name:SetWidth(81 * 0.96)
		self.Name:SetFontObject(UnitframeFont)
		self.Name:SetWordWrap(false)
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name]")
		else
			self:Tag(self.Name, "[color][name]")
		end
	end

	if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
		self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
		self.Portrait:SetFrameStrata(self:GetFrameStrata())
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.Portrait:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	elseif C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" then
		self.Portrait = self.Health:CreateTexture("TargetPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)

		self.Portrait.Border = CreateFrame("Frame", nil, self)
		self.Portrait.Border:SetAllPoints(self.Portrait)
		self.Portrait.Border:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

		if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT", -self.Portrait:GetWidth() - 6, 0)

	if C["Unitframe"].TargetOfTargetLevel then
		self.Level = self:CreateFontString(nil, "OVERLAY")
		self.Level:SetPoint("BOTTOM", self.Portrait, 0, -16)
		self.Level:SetFontObject(UnitframeFont)
		self:Tag(self.Level, "[fulllevel]")
	end

	self.Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
	self.Debuffs:SetWidth(82)
	if C["Unitframe"].TargetOfTargetName and C["Unitframe"].TargetOfTargetLevel then
		self.Debuffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -20)
	else
		self.Debuffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
	end
	self.Debuffs.num = 4 * 4
	self.Debuffs.spacing = 6
	self.Debuffs.size = ((((self.Debuffs:GetWidth() - (self.Debuffs.spacing * (self.Debuffs.num / 4 - 1))) / self.Debuffs.num)) * 4)
	self.Debuffs:SetHeight(self.Debuffs.size * 4)
	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs["growth-y"] = "DOWN"
	self.Debuffs["growth-x"] = "RIGHT"
	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	self.RaidTargetIndicator:SetSize(12, 12)

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = function() end,
		Override = Module.UpdateThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)
end