local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreateTargetOfTarget()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	local targetOfTargetWidth = C["Unitframe"].TargetTargetHealthWidth

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(C["Unitframe"].TargetTargetHealthHeight)
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
	self.Power:SetHeight(C["Unitframe"].TargetTargetPowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -4)
	self.Name:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -4)
	self.Name:SetFontObject(UnitframeFont)

	if C["Unitframe"].PortraitStyle.Value == "NoPortraits" or C["Unitframe"].PortraitStyle.Value == "OverlayPortrait" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name] [fulllevel][afkdnd]")
		else
			self:Tag(self.Name, "[color][name] [fulllevel][afkdnd]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name][afkdnd]")
		else
			self:Tag(self.Name, "[color][name][afkdnd]")
		end
	end
	self.Name:SetShown(not C["Unitframe"].HideTargetOfTargetName)

	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if C["Unitframe"].PortraitStyle.Value == "OverlayPortrait" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_TargetTargetPortrait", self)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 1, -1)
			self.Portrait:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -1, 1)
			self.Portrait:SetAlpha(0.6)
		elseif C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_TargetTargetPortrait", self.Health)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			self.Portrait:CreateBorder()
		elseif C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" and C["Unitframe"].PortraitStyle.Value ~= "OverlayPortrait" then
			self.Portrait = self.Health:CreateTexture("KKUI_TargetTargetPortrait", "BACKGROUND", nil, 1)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

			self.Portrait.Border = CreateFrame("Frame", nil, self)
			self.Portrait.Border:SetAllPoints(self.Portrait)
			self.Portrait.Border:CreateBorder()

			if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
				self.Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	self.Level = self:CreateFontString(nil, "OVERLAY")
	self.Level:SetFontObject(UnitframeFont)
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" and C["Unitframe"].PortraitStyle.Value ~= "OverlayPortrait" then
		self.Level:Show()
		self.Level:SetPoint("TOPLEFT", self.Portrait, "BOTTOMLEFT", 0, -4)
		self.Level:SetPoint("TOPRIGHT", self.Portrait, "BOTTOMRIGHT", 0, -4)
	else
		self.Level:Hide()
	end
	self:Tag(self.Level, "[fulllevel]")

	self.Debuffs = CreateFrame("Frame", nil, self)
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs["growth-x"] = "RIGHT"
	self.Debuffs["growth-y"] = "DOWN"
	self.Debuffs:SetPoint("TOPLEFT", self.Name, "BOTTOMLEFT", 0, -6)
	self.Debuffs:SetPoint("TOPRIGHT", self.Name, "BOTTOMRIGHT", 0, -6)
	self.Debuffs.num = 8
	self.Debuffs.iconsPerRow = 4

	self.Debuffs.size = Module.auraIconSize(targetOfTargetWidth, self.Debuffs.iconsPerRow, self.Debuffs.spacing)
	self.Debuffs:SetWidth(targetOfTargetWidth)
	self.Debuffs:SetHeight((self.Debuffs.size + self.Debuffs.spacing) * math.floor(self.Debuffs.num / self.Debuffs.iconsPerRow + .5))

	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" and C["Unitframe"].PortraitStyle.Value ~= "OverlayPortrait" then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(12, 12)

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)
end