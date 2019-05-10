local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Nameplates.lua code!")
	return
end

local _G = _G

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

function Module:CreateNameplates()
	local NameplateTexture = K.GetTexture(C["Nameplates"].Texture)
	local Font = K.GetFont(C["Nameplates"].Font)

	self:SetScale(UIParent:GetEffectiveScale())
	self:SetSize(C["Nameplates"].Width, C["Nameplates"].Height)
	self:SetPoint("CENTER", 0, 0)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetFrameStrata(self:GetFrameStrata())
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetHeight(C["Nameplates"].Height - C["Nameplates"].CastHeight - 1)
	self.Health:SetWidth(self:GetWidth())
	self.Health:SetStatusBarTexture(NameplateTexture)
	self.Health:CreateShadow(true)

	self.Health.UpdateColor = Module.UpdateColor
	self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorReaction = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.Smooth = C["Nameplates"].Smooth
	self.Health.SmoothSpeed = C["Nameplates"].SmoothSpeed * 10

	if C["Nameplates"].HealthValue == true then
		self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self.Health.Value:SetFontObject(Font)
		self:Tag(self.Health.Value, C["Nameplates"].HealthFormat.Value)
	end

	self.Level = self.Health:CreateFontString(nil, "OVERLAY")
	self.Level:SetJustifyH("RIGHT")
	self.Level:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Level:SetFontObject(Font)
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetJustifyH("LEFT")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Level, "BOTTOMLEFT")
	self.Name:SetFontObject(Font)
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameAbbrev]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetFrameStrata(self:GetFrameStrata())
	self.Power:SetHeight(C["Nameplates"].CastHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)
	self.Power:SetStatusBarTexture(NameplateTexture)
	self.Power:CreateShadow(true)

	self.Power.IsHidden = false
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.Smooth = C["Nameplates"].Smooth
	self.Power.SmoothSpeed = C["Nameplates"].SmoothSpeed * 10
	self.Power.PostUpdate = Module.NameplatePowerAndCastBar

	if C["Nameplates"].TrackAuras == true then
		self.Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
		self.Debuffs:SetWidth(C["Nameplates"].Width)
		self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -4)
		self.Debuffs.num = 5 * 2
		self.Debuffs.spacing = 3
		self.Debuffs.size = ((((self.Debuffs:GetWidth() - (self.Debuffs.spacing * (self.Debuffs.num / 2 - 1))) / self.Debuffs.num)) * 2)
		self.Debuffs:SetHeight(self.Debuffs.size * 2)
		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs.onlyShowPlayer = true
		self.Debuffs.filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY"
		self.Debuffs.disableMouse = true
		self.Debuffs.PostCreateIcon = Module.PostCreateAura
		self.Debuffs.PostUpdateIcon = Module.PostUpdateAura
	end

	self.Castbar = CreateFrame("StatusBar", "TargetCastbar", self)
	self.Castbar:SetFrameStrata(self:GetFrameStrata())
	self.Castbar:SetStatusBarTexture(NameplateTexture)
	self.Castbar:SetFrameLevel(6)
	self.Castbar:SetHeight(C["Nameplates"].CastHeight)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetSize(32, self:GetHeight())
	self.Castbar.Spark:SetTexture(C["Media"].Spark_64)
	self.Castbar.Spark:SetBlendMode("ADD")

	self.Castbar.timeToHold = 0.4
	self.Castbar.CustomDelayText = Module.CustomCastDelayText
	self.Castbar.CustomTimeText = Module.CustomTimeText
	self.Castbar.PostCastFailed = Module.PostCastFailed
	self.Castbar.PostCastInterrupted = Module.PostCastFailed
	self.Castbar.PostCastStart = Module.PostCastStart
	self.Castbar.PostCastStop = Module.PostCastStop
	self.Castbar.PostCastInterruptible = Module.PostCastInterruptible

	self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
	self.Castbar.Time:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", 0, -2)
	self.Castbar.Time:SetJustifyH("RIGHT")
	self.Castbar.Time:SetFontObject(Font)
	self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:SetSize(self:GetHeight() + 2, self:GetHeight() + 3)
	self.Castbar.Button:CreateShadow(true)
	self.Castbar.Button:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

	self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetAllPoints()
	self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Shield:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]])
	self.Castbar.Shield:SetSize(50, 50)
	self.Castbar.Shield:SetPoint("RIGHT", self.Castbar, "LEFT", 26, 12)

	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFontObject(Font)
	self.Castbar.Text:SetPoint("TOPLEFT", self.Castbar, "BOTTOMLEFT", 0, -2)
	self.Castbar.Text:SetPoint("TOPRIGHT", self.Castbar.Time, "TOPLEFT")
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
	self.Castbar.Text:SetWordWrap(false)

	self.Castbar:SetScript("OnShow", Module.NameplatePowerAndCastBar)
	self.Castbar:SetScript("OnHide", Module.NameplatePowerAndCastBar)

	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(32, 32)
	self.RaidTargetIndicator:SetPoint("BOTTOM", self.Debuffs or self, "TOP", 0, 10)

	if C["Nameplates"].ClassResource then
		Module.CreateNamePlateClassPower(self)
		if (K.Class == "DEATHKNIGHT") then
			Module.CreateNamePlateRuneBar(self)
		end
	else
		Module.CreatePlateClassPowerText(self)
	end

	Module.CreatePlateQuestIcons(self)
	Module.CreatePlateHealerIcons(self)
	Module.CreatePlateClassificationIcons(self)
	Module.CreatePlateThreatIndicator(self)
	Module.CreatePlateClassIcons(self)
	Module.CreatePlateTotemIcons(self)
	Module.CreatePlateTargetArrow(self)

	if C["FloatingCombatFeedback"].Enable and C["FloatingCombatFeedback"].Style.Value == "Nameplates" then
		Module.CreateNameplateCombatFeedback(self)
	end

	self.HealthPrediction = Module.CreateHealthPrediction(self, C["Nameplates"].Width)
	Module.CreateDebuffHighlight(self)
	Module.CreatePvPIndicator(self, "nameplate", self, self:GetHeight() + 2, self:GetHeight() + 5)

	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.HighlightPlate, true)
	self:RegisterEvent("UNIT_HEALTH", Module.HighlightPlate, true)

	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateNameplateTarget, true)

	if C["Nameplates"].Totems then
		self:RegisterEvent("UNIT_NAME_UPDATE", Module.UpdatePlateTotems, true)
	end
end