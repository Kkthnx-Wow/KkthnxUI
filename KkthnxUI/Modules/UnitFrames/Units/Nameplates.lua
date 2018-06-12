local K, C = unpack(select(2, ...))
if C["Nameplates"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Nameplates.lua code!")
	return
end

local _G = _G
local select = select

local UIParent = _G.UIParent
local CreateFrame = _G.CreateFrame

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
	self.Health:CreateShadow()

	self.Health.Background = self.Health:CreateTexture(nil, "BORDER")
	self.Health.Background:SetAllPoints()
	self.Health.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	self.Health.frequentUpdates = true
	self.Health.colorReaction = true
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.Smooth = C["Nameplates"].Smooth
	self.Health.SmoothSpeed = C["Nameplates"].SmoothSpeed * 10

	if C["Nameplates"].HealthValue == true then
		self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self.Health.Value:SetFontObject(Font)
		self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), self.Health:GetHeight() - 2, select(3, self.Health.Value:GetFont()))
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	end

	self.Level = self.Health:CreateFontString(nil, "OVERLAY")
	self.Level:SetJustifyH("RIGHT")
	self.Level:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Level:SetFontObject(Font)
	self.Level:SetFont(select(1, self.Level:GetFont()), 12, select(3, self.Level:GetFont()))
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetJustifyH("LEFT")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Level, "BOTTOMLEFT")
	self.Name:SetFontObject(Font)
	self.Name:SetFont(select(1, self.Name:GetFont()), 12, select(3, self.Name:GetFont()))
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetFrameStrata(self:GetFrameStrata())
	self.Power:SetHeight(C["Nameplates"].CastHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)
	self.Power:SetStatusBarTexture(NameplateTexture)
	self.Power:CreateShadow()

	self.Power.Background = self.Power:CreateTexture(nil, "BORDER")
	self.Power.Background:SetAllPoints()
	self.Power.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.Smooth = C["Nameplates"].Smooth
	self.Power.SmoothSpeed = C["Nameplates"].SmoothSpeed * 10

	self.Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
	self.Debuffs:SetHeight(C["Nameplates"].Height)
	self.Debuffs:SetWidth(self:GetWidth())
	self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 18)
	self.Debuffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 18)
	self.Debuffs.size = C["Nameplates"].Height
	self.Debuffs.num = 36
	self.Debuffs.numRow = 9

	self.Debuffs.spacing = 2
	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs["growth-y"] = "UP"
	self.Debuffs["growth-x"] = "RIGHT"
	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura
	self.Debuffs.onlyShowPlayer = true
	self.Debuffs.filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY"

	self.Castbar = CreateFrame("StatusBar", "TargetCastbar", self)
	self.Castbar:SetFrameStrata(self:GetFrameStrata())
	self.Castbar:SetStatusBarTexture(NameplateTexture)
	self.Castbar:SetFrameLevel(6)
	self.Castbar:SetHeight(C["Nameplates"].CastHeight)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)

	self.Castbar.Background = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.Background:SetAllPoints(self.Castbar)
	self.Castbar.Background:SetTexture(NameplateTexture)
	self.Castbar.Background:SetVertexColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetSize(32, self:GetHeight())
	self.Castbar.Spark:SetTexture(C["Media"].Spark_64)
	self.Castbar.Spark:SetBlendMode("ADD")

	self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
	self.Castbar.Time:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", 0, -2)
	self.Castbar.Time:SetJustifyH("RIGHT")
	self.Castbar.Time:SetJustifyV("TOP")
	self.Castbar.Time:SetFontObject(Font)
	self.Castbar.Time:SetFont(select(1, self.Castbar.Time:GetFont()), 12, select(3, self.Castbar.Time:GetFont()))

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:SetSize(self:GetHeight() + 2, self:GetHeight() + 3)
	self.Castbar.Button:CreateShadow()
	self.Castbar.Button:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)

	self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetAllPoints()
	self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Shield:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]])
	self.Castbar.Shield:SetSize(self:GetHeight(), self:GetHeight())
	self.Castbar.Shield:SetPoint("LEFT", self.Castbar, "RIGHT", 0, 10)

	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetPoint("TOPLEFT", self.Castbar, "BOTTOMLEFT", 0, -2)
	self.Castbar.Text:SetPoint("TOPRIGHT", self.Castbar.Time, "TOPLEFT")
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetJustifyV("TOP")
	self.Castbar.Text:SetFontObject(Font)
	self.Castbar.Text:SetFont(select(1, self.Castbar.Text:GetFont()), 12, select(3, self.Castbar.Text:GetFont()))

	self.Castbar.PostCastStart = Module.CheckInterrupt
	self.Castbar.PostCastInterruptible = Module.CheckInterrupt
	self.Castbar.PostCastNotInterruptible = Module.CheckInterrupt
	self.Castbar.PostChannelStart = Module.CheckInterrupt

	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(self:GetHeight(), self:GetHeight())
	self.RaidTargetIndicator:SetPoint("BOTTOM", self.Health, "TOP", 0, 38)

	self.QuestIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.QuestIndicator:SetSize(14, 14)
	self.QuestIndicator:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -7, 7)

	Module.CreateClassModules(self, 194, 12, 6)

	self.HealthPrediction = Module.CreateHealthPrediction(self)

	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.HighlightPlate)
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.HighlightPlate)
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", Module.HighlightPlate)

	self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", Module.ThreatPlate)
	self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE", Module.ThreatPlate)

	self.Health:SetScript("OnEvent", function()
		Module.ThreatPlate(self)
	end)

	self.Health.PostUpdate = function()
		Module.ThreatPlate(self, true)
	end
end