local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame

function Module:CreateTargetOfTarget()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	local targetOfTargetWidth = C["Unitframe"].TargetTargetHealthWidth
	local targetOfTargetPortraitStyle = C["Unitframe"].PortraitStyle.Value

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetAllPoints()
	Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetHeight(C["Unitframe"].TargetTargetHealthHeight)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(UnitframeTexture)
	Health:CreateBorder()

	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["Unitframe"].HealthbarColor.Value == "Value" then
		Health.colorSmooth = true
		Health.colorClass = false
		Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor.Value == "Dark" then
		Health.colorSmooth = false
		Health.colorClass = false
		Health.colorReaction = false
		Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		Health.colorSmooth = false
		Health.colorClass = true
		Health.colorReaction = true
	end

	Health.Value = Health:CreateFontString(nil, "OVERLAY")
	Health.Value:SetPoint("CENTER", Health, "CENTER", 0, 0)
	Health.Value:SetFontObject(UnitframeFont)
	Health.Value:SetFont(select(1, Health.Value:GetFont()), 10, select(3, Health.Value:GetFont()))
	self:Tag(Health.Value, "[hp]")

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(C["Unitframe"].TargetTargetPowerHeight)
	Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -6)
	Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -6)
	Power:SetStatusBarTexture(UnitframeTexture)
	Power:CreateBorder()

	Power.colorPower = true
	Power.frequentUpdates = false

	local Name = self:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("TOPLEFT", Power, "BOTTOMLEFT", 0, -4)
	Name:SetPoint("TOPRIGHT", Power, "BOTTOMRIGHT", 0, -4)
	Name:SetFontObject(UnitframeFont)
	Name:SetWordWrap(false)

	if targetOfTargetPortraitStyle == "NoPortraits" or targetOfTargetPortraitStyle == "OverlayPortrait" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[name] [fulllevel][afkdnd]")
		else
			self:Tag(Name, "[color][name] [fulllevel][afkdnd]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[name][afkdnd]")
		else
			self:Tag(Name, "[color][name][afkdnd]")
		end
	end
	Name:SetShown(not C["Unitframe"].HideTargetOfTargetName)

	if targetOfTargetPortraitStyle ~= "NoPortraits" then
		if targetOfTargetPortraitStyle == "OverlayPortrait" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_TargetTargetPortrait", self)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetPoint("TOPLEFT", Health, "TOPLEFT", 1, -1)
			Portrait:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -1, 1)
			Portrait:SetAlpha(0.6)

			self.Portrait = Portrait
		elseif targetOfTargetPortraitStyle == "ThreeDPortraits" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_TargetTargetPortrait", Health)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			Portrait:CreateBorder()

			self.Portrait = Portrait
		elseif targetOfTargetPortraitStyle ~= "ThreeDPortraits" and targetOfTargetPortraitStyle ~= "OverlayPortrait" then
			local Portrait = Health:CreateTexture("KKUI_TargetTargetPortrait", "BACKGROUND", nil, 1)
			Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

			Portrait.Border = CreateFrame("Frame", nil, self)
			Portrait.Border:SetAllPoints(Portrait)
			Portrait.Border:CreateBorder()

			self.Portrait = Portrait

			if targetOfTargetPortraitStyle == "ClassPortraits" or targetOfTargetPortraitStyle == "NewClassPortraits" then
				Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	local Level = self:CreateFontString(nil, "OVERLAY")
	Level:SetFontObject(UnitframeFont)
	if targetOfTargetPortraitStyle ~= "NoPortraits" and targetOfTargetPortraitStyle ~= "OverlayPortrait" and not C["Unitframe"].HideTargetOfTargetLevel then
		Level:Show()
	else
		Level:Hide()
	end
	Level:SetPoint("TOPLEFT", self.Portrait, "BOTTOMLEFT", 0, -4)
	Level:SetPoint("TOPRIGHT", self.Portrait, "BOTTOMRIGHT", 0, -4)
	self:Tag(Level, "[fulllevel]")

	local Debuffs = CreateFrame("Frame", nil, self)
	Debuffs.spacing = 6
	Debuffs.initialAnchor = "TOPLEFT"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs["growth-y"] = "DOWN"
	Debuffs:SetPoint("TOPLEFT", C["Unitframe"].HideTargetOfTargetName and Power or Name, "BOTTOMLEFT", 0, -6)
	Debuffs:SetPoint("TOPRIGHT", C["Unitframe"].HideTargetOfTargetName and Power or Name, "BOTTOMRIGHT", 0, -6)
	Debuffs.num = 8
	Debuffs.iconsPerRow = 4

	Module:UpdateAuraContainer(targetOfTargetWidth, Debuffs, Debuffs.num)

	Debuffs.PostCreateIcon = Module.PostCreateAura
	Debuffs.PostUpdateIcon = Module.PostUpdateAura

	local RaidTargetIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if targetOfTargetPortraitStyle ~= "NoPortraits" and targetOfTargetPortraitStyle ~= "OverlayPortrait" then
		RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		RaidTargetIndicator:SetPoint("TOP", Health, "TOP", 0, 8)
	end
	RaidTargetIndicator:SetSize(12, 12)

	local Highlight = Health:CreateTexture(nil, "OVERLAY")
	Highlight:SetAllPoints()
	Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	Highlight:SetTexCoord(0, 1, 0.5, 1)
	Highlight:SetVertexColor(0.6, 0.6, 0.6)
	Highlight:SetBlendMode("ADD")
	Highlight:Hide()

	local ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	local Range = Module.CreateRangeIndicator(self)

	self.Overlay = Overlay
	self.Health = Health
	self.Power = Power
	self.Name = Name
	self.Level = Level
	self.Debuffs = Debuffs
	self.RaidTargetIndicator = RaidTargetIndicator
	self.Highlight = Highlight
	self.ThreatIndicator = ThreatIndicator
	self.Range = Range
end
