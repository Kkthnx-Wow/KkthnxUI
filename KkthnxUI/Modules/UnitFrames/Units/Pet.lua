--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Creates and updates the Pet unit frame.
-- - Design: Features Health, Power, Portrait, and Debuffs.
-- - Events: UNIT_HEALTH, UNIT_POWER, UNIT_AURA, etc. handled by oUF.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- REASON: Localize C-functions (Snake Case)
local select = _G.select

-- REASON: Localize Globals
local CreateFrame = _G.CreateFrame

function Module:CreatePet()
	self.mystyle = "pet"

	local petHeight = C["Unitframe"].PetHealthHeight
	local petPortraitStyle = C["Unitframe"].PortraitStyle

	local UnitframeTexture = K.GetTexture(C["General"].Texture)

	-- REASON: Overlay frame for borders and indicators.
	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetFrameStrata(self:GetFrameStrata())
	self.Overlay:SetFrameLevel(5)
	self.Overlay:SetAllPoints()
	self.Overlay:EnableMouse(false)

	Module.CreateHeader(self)

	-- REASON: Health Bar Setup
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(petHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Unitframe"].HealthbarColor == 3 then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor == 2 then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	Module:CreateBarValueTag(self, self.Health, "[hp]", { size = 10 })

	-- REASON: Health spark — shows a glow at the current HP edge; hidden at full/zero/dead/offline.
	self.Health.Spark = Module:CreateBarSpark(self.Health)
	self.Health.PostUpdate = Module.PostUpdateHealthSpark

	-- REASON: Power Bar Setup
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(C["Unitframe"].PetPowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	-- REASON: Power spark — shows a glow at the current power edge; hidden at full/zero/dead/offline.
	self.Power.Spark = Module:CreateBarSpark(self.Power)
	self.Power.PostUpdate = Module.PostUpdatePowerSpark

	Module:CreateUnitNameString(self, { layout = "belowPower" })
	Module:TagUnitName(self, petPortraitStyle, { levelTag = "[fulllevel]", suffix = "" })
	self.Name:SetShown(not C["Unitframe"].HidePetName)
	Module:CreateUnitPortrait(self, { side = "left", style = petPortraitStyle })
	Module:CreatePortraitLevelTag(self, petPortraitStyle, {
		tag = "[fulllevel]",
		layout = "below",
		show = Module.IsDetachedPortrait(petPortraitStyle) and not C["Unitframe"].HidePetLevel,
	})

	-- REASON: Aura Debuffs
	self.Debuffs = CreateFrame("Frame", nil, self)
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs.growthX = "RIGHT"
	self.Debuffs.growthY = "DOWN"
	self.Debuffs:SetPoint("TOPLEFT", C["Unitframe"].HidePetName and self.Power or self.Name, "BOTTOMLEFT", 0, -6)
	self.Debuffs:SetPoint("TOPRIGHT", C["Unitframe"].HidePetName and self.Power or self.Name, "BOTTOMRIGHT", 0, -6)
	self.Debuffs.num = 8
	self.Debuffs.iconsPerRow = 4

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOP", Module.GetPortraitAnchor(self, petPortraitStyle), "TOP", 0, 8)
	self.RaidTargetIndicator:SetSize(12, 12)

	-- REASON: Debuff Highlight (Magic, Poison, etc.)
	if C["Unitframe"].DebuffHighlight then
		Module:CreateDebuffHighlight(self)
	end

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, 0.5, 1)
	self.Highlight:SetVertexColor(0.6, 0.6, 0.6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.RangeFader = {
		insideAlpha = 1,
		outsideAlpha = 0.55,
		MaxAlpha = 1,
		MinAlpha = 0.3,
	}
end
