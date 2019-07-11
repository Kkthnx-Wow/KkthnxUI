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
local UnitIsUnit = _G.UnitIsUnit
local UnitExists = _G.UnitExists

function Module:IsMouseoverUnit()
	if not self or not self.unit then
		return
	end

	if self:IsVisible() and UnitExists("mouseover") and not UnitIsUnit("target", self.unit) then
		return UnitIsUnit("mouseover", self.unit)
	end

	return false
end

function Module:UpdateMouseoverShown()
	if not self or not self.unit then
		return
	end

	if self:IsShown() and UnitIsUnit("mouseover", self.unit) and not UnitIsUnit("target", self.unit) then
		self.plateGlow:Show()
		self.HighlightIndicator:Show()
	else
		self.HighlightIndicator:Hide()
	end
end

local function AddMouseoverIndicator(self)
	local plateGlow = self.Health:CreateTexture(nil, "OVERLAY")
	plateGlow:SetAllPoints()
	plateGlow:SetTexture(C["Media"].Mouseover)
	plateGlow:SetVertexColor(1, 1, 1, 0.50)
	plateGlow:Hide()

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Module.UpdateMouseoverShown, true)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateMouseoverShown, true)

	local updateFrame = CreateFrame("Frame", nil, self)
	updateFrame:SetScript("OnUpdate", function(_, elapsed)
		updateFrame.elapsed = (updateFrame.elapsed or 0) + elapsed
		if updateFrame.elapsed > 0.1 then
			if not Module.IsMouseoverUnit(self) then
				updateFrame:Hide()
			end
			updateFrame.elapsed = 0
		end
	end)

	updateFrame:HookScript("OnHide", function()
		plateGlow:Hide()
	end)

	self.plateGlow = plateGlow
	self.HighlightIndicator = updateFrame
end

function Module:PostUpdatePower(_, cur)
	if (cur == 0) then
		self:Hide()
	else
		self:Show()
	end
end

function Module:CreateNameplates()
	local NameplateTexture = K.GetTexture(C["UITextures"].NameplateTextures)
	local Font = K.GetFont(C["UIFonts"].NameplateFonts)

	self:SetScale(UIParent:GetEffectiveScale())
	self:SetSize(C["Nameplates"].Width, C["Nameplates"].Height)
	self:SetPoint("CENTER", 0, 0)

	local elevatedFrame = CreateFrame("Frame", nil, self)
	elevatedFrame:SetAllPoints()
	elevatedFrame:SetFrameLevel(self:GetFrameLevel() + 2)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetFrameStrata(self:GetFrameStrata())
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetHeight(C["Nameplates"].Height)
	self.Health:SetWidth(self:GetWidth())
	self.Health:SetStatusBarTexture(NameplateTexture)
	self.Health:CreateShadow(true)

	self.Health.colorTapping = true
	self.Health.colorReaction = true
	self.Health.colorClass = true
	self.Health.colorHealth = true
	self.Health.colorThreat = C["Nameplates"].Threat
	self.Health.frequentUpdates = true

	K:SetSmoothing(self.Health, C["Nameplates"].Smooth)

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetFrameStrata(self:GetFrameStrata())
	self.Power:SetFrameLevel(4)
	self.Power:SetHeight(C["Nameplates"].CastHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)
	self.Power:SetStatusBarTexture(NameplateTexture)
	self.Power:CreateShadow(true)

	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.PostUpdate = Module.PostUpdatePower

	K:SetSmoothing(self.Power, C["Nameplates"].Smooth)

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

	Module.CreateNameplateCastbar(self)

	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(18, 18)
	self.RaidTargetIndicator:SetPoint("RIGHT", self, "LEFT", -10, 0)

	if C["Nameplates"].QuestIcon then
		self.questIcon = self:CreateTexture(nil, "OVERLAY", nil, 2)
		self.questIcon:SetPoint("LEFT", self, "RIGHT", -1, 0)
		self.questIcon:SetSize(20, 20)
		self.questIcon:SetAtlas("adventureguide-microbutton-alert")
		self.questIcon:Hide()

		self.questCount = self:CreateFontString(nil, "OVERLAY")
		self.questCount:SetFontObject(Font)
		self.questCount:SetPoint("LEFT", self.questIcon, "RIGHT", -4, 0)

		self:RegisterEvent("QUEST_LOG_UPDATE", Module.UpdateQuestUnit, true)
	end

	self.creatureIcon = elevatedFrame:CreateTexture(nil, "ARTWORK")
	self.creatureIcon:SetAtlas("VignetteKill")
	self.creatureIcon:SetPoint("BOTTOMLEFT", self, "LEFT", 0, -4)
	self.creatureIcon:SetSize(16, 16)
	self.creatureIcon:SetAlpha(0)

	if C["Nameplates"].ThreatPercent == true then
		self.ThreatPercent = self:CreateFontString(nil, "OVERLAY")
		self.ThreatPercent:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
		self.ThreatPercent:SetFontObject(Font)
		self:Tag(self.ThreatPercent, "[KkthnxUI:ThreatColor][KkthnxUI:ThreatPercent]")
	end

	if C["Nameplates"].ClassResource then
		Module.CreateNamePlateClassPower(self)
		if (K.Class == "DEATHKNIGHT") then
			Module.CreateNamePlateRuneBar(self)
		elseif (K.Class == "MONK") then
			Module.CreateNamePlateStaggerBar(self)
		end
	end

	Module.CreateNameplateAuras(self)
	Module.CreateDebuffHighlight(self)
	Module.CreateHealthPrediction(self, "nameplate")
	Module.AddFollowerXP(self)

	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.HighlightPlate, true)
	self:RegisterEvent("UNIT_HEALTH", Module.HighlightPlate, true)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateNameplateTarget, true)

	AddMouseoverIndicator(self)
end