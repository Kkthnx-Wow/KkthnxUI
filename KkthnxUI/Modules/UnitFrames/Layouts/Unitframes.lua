local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Unitframes.lua code!")
	return
end

local _G = _G
local pairs = pairs
local print = print
local unpack = unpack

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CreateFrame = _G.CreateFrame
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetNumArenaOpponentSpecs = _G.GetNumArenaOpponentSpecs
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local InCombatLockdown = _G.InCombatLockdown
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES or 5
local UnitClass = _G.UnitClass
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave
local UnitIsPlayer = _G.UnitIsPlayer

local UnitframeFont = K.GetFont(C["Unitframe"].Font)
local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

local function UpdateClassPortraits(self, unit)
	local _, unitClass = UnitClass(unit)
	if (unitClass and UnitIsPlayer(unit)) and C["Unitframe"].PortraitStyle.Value == "ClassPortraits" then
		self:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
		self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
	elseif (unitClass and UnitIsPlayer(unit)) and C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
		self:SetTexture(C["Media"].NewClassPortraits)
		self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
	else
		self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	end
end

local function CreateUnitframeLayout(self, unit)
	unit = unit:match("^(%a-)%d+") or unit

	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", UnitFrame_OnEnter)
	self:HookScript("OnLeave", UnitFrame_OnLeave)

	-- Health bar
	self.Health = CreateFrame("StatusBar", "$parent.Healthbar", self)
	self.Health:SetTemplate("Transparent")
	self.Health:SetFrameStrata("LOW")
	self.Health:SetFrameLevel(1)
	self.Health:SetStatusBarTexture(UnitframeTexture)

	self.Health.Cutaway = C["Unitframe"].Cutaway
	self.Health.Smooth = C["Unitframe"].Smooth
	self.Health.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = unit == "player" or unit == "target" or unit == "party"
	self.Health.PostUpdate = K.PostUpdateHealth
	self.CombatFade = C["Unitframe"].CombatFade and unit == "player" or unit == "pet"

	if (unit == "player") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent]")
	elseif (unit == "pet") then
		self.Health:SetSize(74, 12)
		self.Health:SetPoint("CENTER", self, "CENTER", 15, 7)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Health.Value:SetJustifyH("LEFT")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	elseif (unit == "target") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", -26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	elseif (unit == "focus") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	elseif (unit == "targettarget") then
		self.Health:SetSize(74, 12)
		self.Health:SetPoint("CENTER", self, "CENTER", -15, 7)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	elseif (unit == "focustarget") then
		self.Health:SetSize(74, 12)
		self.Health:SetPoint("CENTER", self, "CENTER", 15, 7)
	elseif (unit == "party") then
		self.Health:SetSize(98, 16)
		self.Health:SetPoint("CENTER", self, "CENTER", 18, 8)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	elseif (unit == "partytarget") then
		self.Health:SetSize(74, 12)
		self.Health:SetPoint("CENTER", self, "CENTER", 0, 0)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	elseif (unit == "boss" or unit == "arena") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	end

	-- Power Bar
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetTemplate("Transparent")
	self.Power:SetFrameStrata("LOW")
	self.Power:SetFrameLevel(1)
	self.Power:SetStatusBarTexture(UnitframeTexture)

	self.Power.Cutaway = C["Unitframe"].Cutaway
	self.Power.Smooth = C["Unitframe"].Smooth
	self.Power.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Power.colorPower = true
	self.Power.frequentUpdates = unit == "player" or unit == "target" or unit == "party" -- Less usage this way!

	if C["Unitframe"].PowerClass then
		self.Power.colorClass = true
		self.Power.colorReaction = true
	else
		self.Power.colorPower = true
	end

	-- Power StatusBar
	if unit == "player" then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power Value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Power.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	elseif unit == "pet" then
		self.Power:SetSize(74, 8)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power Value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Power.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	elseif unit == "target" then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Power.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	elseif unit == "focus" then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Power.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	elseif (unit == "targettarget") then
		self.Power:SetSize(74, 8)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	elseif (unit == "focustarget") then
		self.Power:SetSize(74, 8)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	elseif (unit == "party") then
		self.Power:SetSize(98, 10)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	elseif (unit == "boss" or unit == "arena") then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Power.Value:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	end

	-- 3D and such models. We provide 3 choices here.
	if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
		-- Create the portrait globally
		self.Portrait = CreateFrame("PlayerModel", self:GetName().."_3DPortrait", self)
		self.Portrait:SetTemplate("Transparent")
		self.Portrait:SetFrameStrata("BACKGROUND")
		self.Portrait:SetFrameLevel(1)

		if (unit == "player" or unit == "focus" or unit == "boss") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "pet" or unit == "focustarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "target") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "targettarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "party") then
			self.Portrait:SetSize(32, 32)
			self.Portrait:SetPoint("LEFT", self, 2, 0)
		end
	elseif (C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits") then
		self.Portrait = self.Health:CreateTexture("$parentPortrait", "BACKGROUND", nil, 7)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)

		-- We need to create this for non 3D Ports
		self.Portrait.Background = CreateFrame("Frame", self:GetName().."_2DPortrait", self)
		self.Portrait.Background:SetTemplate("Transparent")
		self.Portrait.Background:SetFrameStrata("LOW")
		self.Portrait.Background:SetFrameLevel(1)

		if (unit == "player" or unit == "focus" or unit == "boss") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
			self.Portrait.Background:SetSize(46, 46)
			self.Portrait.Background:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "pet") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
			self.Portrait.Background:SetSize(26, 26)
			self.Portrait.Background:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "target") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
			self.Portrait.Background:SetSize(46, 46)
			self.Portrait.Background:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "targettarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
			self.Portrait.Background:SetSize(26, 26)
			self.Portrait.Background:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "focustarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
			self.Portrait.Background:SetSize(26, 26)
			self.Portrait.Background:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "party") then
			self.Portrait:SetSize(32, 32)
			self.Portrait:SetPoint("LEFT", self, 2, 0)
			self.Portrait.Background:SetSize(32, 32)
			self.Portrait.Background:SetPoint("LEFT", self, 2, 0)
		end

		if C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
			self.Portrait.PostUpdate = UpdateClassPortraits
		end
	end

	-- Name Text
	if (unit == "target") then
		self.Name = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -3, 4)
		self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 3, 4)
		if C["Unitframe"].NameAbbreviate == true then
			self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMediumAbbrev]")
		else
			self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
		end
		-- Level Text
		self.Level = K.SetFontString(self, C["Media"].Font, 14, C["Unitframe"].Outline and "OUTLINE" or "", "LEFT")
		self.Level:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Level:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
		self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

		-- Threat Text
		if C["Unitframe"].ThreatPercent == true then
			self.ThreatPercentText = K.SetFontString(self, C["Media"].Font, 14, C["Unitframe"].Outline and "OUTLINE" or "", "LEFT")
			self.ThreatPercentText:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			self.ThreatPercentText:SetPoint("RIGHT", self.Power, "LEFT", -4, 0)
			self:Tag(self.ThreatPercentText, "[KkthnxUI:NameplateThreatColor][KkthnxUI:NameplateThreat]")
		end
	elseif unit == "focus" then
		self.Name = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 16)
		if C["Unitframe"].NameAbbreviate == true then
			self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMediumAbbrev]")
		else
			self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
		end
		-- Level Text
		self.Level = K.SetFontString(self, C["Media"].Font, 14, C["Unitframe"].Outline and "OUTLINE" or "", "RIGHT")
		self.Level:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Level:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
		self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")
	elseif (unit == "targettarget" or unit == "focustarget") then
		self.Name = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("BOTTOM", self.Power, "BOTTOM", 0, -16)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameShort]")
	elseif (unit == "party") then
		self.Name = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 16)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
		-- Level Text
		self.Level = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "LEFT")
		self.Level:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Level:SetPoint("TOP", self.Portrait, "TOP", 0, 16)
		self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel]")
	elseif (unit == "partytarget") then
		self.Name = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 14)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameShort]")
		-- Level Text
		self.Level = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "LEFT")
		self.Level:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Level:SetPoint("TOP", self.Portrait, "TOP", 0, 16)
		self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel]")
	elseif (unit == "boss" or unit == "arena") then
		self.Name = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 16)
		if C["Unitframe"].NameAbbreviate == true then
			self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMediumAbbrev]")
		else
			self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
		end
	end

	if (unit == "player") then
		if C["Unitframe"].Castbars then
			K.CreateCastBar(self, "player")
		end
		if (C["Unitframe"].CombatText) then
			K.CreateCombatFeedback(self)
		end
		if (C["Unitframe"].GlobalCooldown) then
			K.CreateGlobalCooldown(self)
		end
		K.CreateAdditionalPower(self)
		K.CreateAssistantIndicator(self)
		K.CreateClassModules(self, 194, 12, 6)
		K.CreateClassTotems(self, 194, 12, 6)
		K.CreateCombatIndicator(self)
		K.CreateLeaderIndicator(self)
		K.CreateMasterLooterIndicator(self)
		if C["Unitframe"].PvPText then
			K.CreatePvPText(self, "player")
		end
		K.CreateAFKIndicator(self)
		K.CreateRaidTargetIndicator(self)
		K.CreateReadyCheckIndicator(self)
		K.CreateRestingIndicator(self)
		K.CreateThreatIndicator(self)
		self.HealthPrediction = K.CreateHealthPrediction(self)
		if (C["Unitframe"].PowerPredictionBar) then
			K.CreatePowerPrediction(self)
		end
		if K.Class == "DEATHKNIGHT" then
			K.CreateClassRunes(self, 194, 12, 6)
		elseif (K.Class == "MONK") then
			K.CreateStagger(self)
		end
	end

	if (unit == "target") then
		if C["Unitframe"].Castbars then
			K.CreateCastBar(self, "target")
		end
		if (C["Unitframe"].CombatText) then
			K.CreateCombatFeedback(self)
		end
		K.CreateAuras(self, "target")
		if C["Unitframe"].PvPText then
			K.CreatePvPText(self, "target")
		end
		K.CreateQuestIndicator(self)
		K.CreateRaidTargetIndicator(self)
		K.CreateReadyCheckIndicator(self)
		K.CreateResurrectIndicator(self)
		K.CreateThreatIndicator(self)
		self.HealthPrediction = K.CreateHealthPrediction(self)
	end

	if (unit == "pet" or unit == "targettarget") then
		K.CreateAuras(self, unit)
		K.CreateRaidTargetIndicator(self)
		K.CreateThreatIndicator(self)
	end

	if (unit == "focus") then
		if C["Unitframe"].Castbars then
			K.CreateCastBar(self, "focus")
		end
		K.CreateAuras(self, "focus")
	end

	if (unit == "boss") then
		if C["Unitframe"].Castbars then
			K.CreateCastBar(self, "boss")
		end
		K.CreateAuras(self, "boss")
	end

	if (unit == "arena") then
		if C["Unitframe"].Castbars then
			K.CreateCastBar(self, "arena")
		end
		K.CreateAuras(self, "arena")
		K.CreateSpecIcons(self)
		K.CreateTrinkets(self)
	end

	if (unit == "party") then
		K.CreateAFKIndicator(self)
		K.CreateAssistantIndicator(self)
		K.CreateAuras(self, "party")
		K.CreateGroupRoleIndicator(self)
		K.CreateLeaderIndicator(self)
		K.CreateMasterLooterIndicator(self)
		K.CreatePhaseIndicator(self)
		K.CreateRaidTargetIndicator(self)
		K.CreateReadyCheckIndicator(self)
		K.CreateResurrectIndicator(self)
		K.CreateThreatIndicator(self)
		if (C["Unitframe"].TargetHighlight) then
			K.CreatePartyTargetGlow(self)
		end
		self.HealthPrediction = K.CreateHealthPrediction(self)
	end

	self.Threat = {
		Hide = K.Noop, -- oUF stahp
		IsObjectType = K.Noop,
		Override = K.CreateThreatIndicator,
	}

	if (unit ~= "player") then
		self.Range = K.CreateRange(self)
	end
end

oUF:RegisterStyle("oUF_KkthnxUI_Unitframes", CreateUnitframeLayout)
oUF:SetActiveStyle("oUF_KkthnxUI_Unitframes")

local player = oUF:Spawn("player", "oUF_Player")
player:SetSize(190, 52)
player:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "TOPLEFT", -10, 200)
K.Movers:RegisterFrame(player)

local pet = oUF:Spawn("pet", "oUF_Pet")
pet:SetSize(116, 36)
if (K.Class == "WARLOCK" or K.Class == "DEATHKNIGHT") then
	pet:SetPoint("TOPRIGHT", oUF_Player, "BOTTOMLEFT", 56, -14)
else
	pet:SetPoint("TOPRIGHT", oUF_Player, "BOTTOMLEFT", 56, 2)
end
if C["Unitframe"].CombatFade and oUF_Player and not InCombatLockdown() then
	pet:SetParent(oUF_Player)
end
K.Movers:RegisterFrame(pet)

local target = oUF:Spawn("target", "oUF_Target")
target:SetSize(190, 52)
target:SetPoint("BOTTOMLEFT", ActionBarAnchor, "TOPRIGHT", 10, 200)
K.Movers:RegisterFrame(target)

local targettarget = oUF:Spawn("targettarget", "oUF_TargetTarget")
targettarget:SetSize(116, 36)
targettarget:SetPoint("TOPLEFT", oUF_Target, "BOTTOMRIGHT", -56, 2)
K.Movers:RegisterFrame(targettarget)

local focus = oUF:Spawn("focus", "oUF_Focus")
focus:SetSize(190, 52)
focus:SetPoint("BOTTOMRIGHT", oUF_Player, "TOPLEFT", -60, 30)
K.Movers:RegisterFrame(focus)

local focustarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
focustarget:SetSize(116, 36)
focustarget:SetPoint("TOPRIGHT", oUF_Focus, "BOTTOMLEFT", 56, 2)
K.Movers:RegisterFrame(focustarget)

if C["Unitframe"].Party then
	local party = oUF:SpawnHeader("oUF_Party", nil, C["Unitframe"].PartyAsRaid and "custom [group:party] hide" or "custom [group:party, nogroup:raid] show; hide",
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],
	"initial-width", 140,
	"initial-height", 38,
	"showSolo", false,
	"showParty", true,
	"showPlayer", C["Unitframe"].ShowPlayer,
	"showRaid", false,
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "TANK, HEALER, DAMAGER, NONE",
	"groupBy", "ASSIGNEDROLE",
	"yOffset", -44)

	party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 12, -200)
	K.Movers:RegisterFrame(party)
end

if C["Unitframe"].Party then
	local partytarget = oUF:SpawnHeader("oUF_PartyTarget", nil, C["Unitframe"].PartyAsRaid and "custom [group:party] hide" or "custom [group:party, nogroup:raid] show; hide",
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	self:SetAttribute("unitsuffix", "target")
	]],
	"initial-width", 74,
	"initial-height", 14,
	"showSolo", false,
	"showParty", true,
	"showPlayer", C["Unitframe"].ShowPlayer,
	"showRaid", false,
	"groupBy", "ASSIGNEDROLE",
	"groupingOrder", "TANK, HEALER, DAMAGER, NONE",
	"sortMethod", "NAME",
	"yOffset", -68)

	partytarget:SetPoint("TOPLEFT", oUF_Party, "TOPRIGHT", 4, 16)
end

if (C["Unitframe"].ShowBoss) then
	local Boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		Boss[i] = oUF:Spawn("boss"..i, "oUF_BossFrame"..i)
		Boss[i]:SetParent(K.PetBattleHider)

		Boss[i]:SetSize(190, 52)
		if (i == 1) then
			Boss[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
		else
			Boss[i]:SetPoint("TOPLEFT", Boss[i-1], "BOTTOMLEFT", 0, -48)
		end
		K.Movers:RegisterFrame(Boss[i])
	end
end

if (C["Unitframe"].ShowArena) then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "oUF_ArenaFrame"..i)
		arena[i]:SetSize(190, 52)
		if (i == 1) then
			arena[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
		else
			arena[i]:SetPoint("TOPLEFT", arena[i-1], "BOTTOMLEFT", 0, -48)
		end
		K.Movers:RegisterFrame(arena[i])
	end
end

if (C["Unitframe"].ShowArena) then
	local arenaprep = {}
	for i = 1, 5 do
		arenaprep[i] = CreateFrame("Frame", "oUF_ArenaPrep"..i, UIParent)
		arenaprep[i]:SetAllPoints(_G["oUF_ArenaFrame"..i])
		arenaprep[i]:SetFrameStrata("BACKGROUND")

		arenaprep[i].Health = CreateFrame("StatusBar", nil, arenaprep[i])
		arenaprep[i].Health:SetAllPoints()
		arenaprep[i].Health:SetStatusBarTexture(C["Media"].Texture)
		arenaprep[i].Health:SetTemplate("Transparent", true)

		arenaprep[i].Spec = K.SetFontString(arenaprep[i].Health, C["Media"].Font, 14, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		arenaprep[i].Spec:SetPoint("CENTER")
		arenaprep[i]:Hide()
	end

	local arenaprepupdate = CreateFrame("Frame")
	arenaprepupdate:RegisterEvent("PLAYER_LOGIN")
	arenaprepupdate:RegisterEvent("PLAYER_ENTERING_WORLD")
	arenaprepupdate:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	arenaprepupdate:RegisterEvent("ARENA_OPPONENT_UPDATE")
	arenaprepupdate:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_LOGIN" then
			for i = 1, 5 do
				arenaprep[i]:SetAllPoints(_G["oUF_ArenaFrame"..i])
			end
		elseif event == "ARENA_OPPONENT_UPDATE" then
			for i = 1, 5 do
				arenaprep[i]:Hide()
			end
		else
			local numOpps = GetNumArenaOpponentSpecs()
			if numOpps > 0 then
				for i = 1, 5 do
					local f = arenaprep[i]

					if i <= numOpps then
						local s = GetArenaOpponentSpec(i)
						local _, spec, class = nil, "UNKNOWN", "UNKNOWN"

						if s and s > 0 then
							_, spec, _, _, _, class = GetSpecializationInfoByID(s)
						end

						if class and spec then
							local color = (_G.CUSTOM_CLASS_COLORS or _G.RAID_CLASS_COLORS)[class]
							if color then
								f.Health:SetStatusBarColor(color.r, color.g, color.b)
							else
								f.Health:SetStatusBarColor(0.4, 0.4, 0.4)
							end
							f.Spec:SetText(spec)
							f:Show()
						end
					else
						f:Hide()
					end
				end
			else
				for i = 1, 5 do
					arenaprep[i]:Hide()
				end
			end
		end
	end)
end

-- Test UnitFrames(by community)
local moving = false
function K.TestUnitframes(msg)
	if InCombatLockdown() then print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
	if not moving then
		for _, frames in pairs({"oUF_Target", "oUF_TargetTarget", "oUF_Pet", "oUF_Focus"}) do
			_G[frames].oldunit = _G[frames].unit
			_G[frames]:SetAttribute("unit", "player")
		end

		if C["Unitframe"].ShowArena == true then
			for i = 1, 5 do
				_G["oUF_ArenaFrame"..i].oldunit = _G["oUF_ArenaFrame"..i].unit
				_G["oUF_ArenaFrame"..i]:SetAttribute("unit", "player")
			end
		end

		if C["Unitframe"].ShowBoss == true then
			for i = 1, MAX_BOSS_FRAMES do
				_G["oUF_BossFrame"..i].oldunit = _G["oUF_BossFrame"..i].unit
				_G["oUF_BossFrame"..i]:SetAttribute("unit", "player")
			end
		end
		moving = true
	else
		for _, frames in pairs({"oUF_Target", "oUF_TargetTarget", "oUF_Pet", "oUF_Focus"}) do
			_G[frames]:SetAttribute("unit", _G[frames].oldunit)
		end

		if C["Unitframe"].ShowArena == true then
			for i = 1, 5 do
				_G["oUF_ArenaFrame"..i]:SetAttribute("unit", _G["oUF_ArenaFrame"..i].oldunit)
			end
		end

		if C["Unitframe"].ShowBoss == true then
			for i = 1, MAX_BOSS_FRAMES do
				_G["oUF_BossFrame"..i]:SetAttribute("unit", _G["oUF_BossFrame"..i].oldunit)
			end
		end
		moving = false
	end
end
K:RegisterChatCommand("testui", K.TestUnitframes)