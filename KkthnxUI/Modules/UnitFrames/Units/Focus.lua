--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Creates and updates the Focus unit frame.
-- - Design: Features Health, Power, Portrait, Auras, and optional Castbar.
-- - Events: UNIT_HEALTH, UNIT_POWER, UNIT_AURA, etc. handled by oUF.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- REASON: Localize C-functions (Snake Case)
local select = _G.select

-- REASON: Localize Globals
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

function Module:CreateFocus()
	self.mystyle = "focus"

	local focusWidth = C["Unitframe"].FocusHealthWidth
	local focusPortraitStyle = C["Unitframe"].PortraitStyle

	local UnitframeTexture = K.GetTexture(C["General"].Texture)


	Module.CreateHeader(self)

	-- REASON: Health Bar Setup
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(C["Unitframe"].FocusHealthHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	-- REASON: Overlay frame for borders and indicators.
	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(5)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Health)
	end

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

	Module:CreateBarValueTag(self, self.Health, "[hp]")

	-- REASON: Health spark — shows a glow at the current HP edge; hidden at full/zero/dead/offline.
	self.Health.Spark = Module:CreateBarSpark(self.Health)
	self.Health.PostUpdate = Module.PostUpdateHealthSpark

	-- REASON: Power Bar Setup
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(C["Unitframe"].FocusPowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	-- REASON: Power spark — shows a glow at the current power edge; hidden at full/zero/dead/offline.
	self.Power.Spark = Module:CreateBarSpark(self.Power)
	self.Power.PostUpdate = Module.PostUpdatePowerSpark

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Power)
	end

	Module:CreateBarValueTag(self, self.Power, "[power]", { size = 11 })

	Module:CreateUnitNameString(self, { layout = "aboveHealth" })
	Module:TagUnitName(self, focusPortraitStyle)
	Module:CreateUnitPortrait(self, { side = "right" })

	Module:CreatePrivateAuras(self, {
		point = "TOPLEFT",
		relativeTo = self.Health,
		relativePoint = "TOPLEFT",
		x = 2,
		y = -2,
		initialAnchor = "TOPLEFT",
		growthX = "RIGHT",
		growthY = "DOWN",
	})

	-- REASON: Aura Debuffs
	if C["Unitframe"].FocusDebuffs then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.spacing = 6
		self.Debuffs.initialAnchor = "BOTTOMLEFT"
		self.Debuffs.growthX = "RIGHT"
		self.Debuffs.growthY = "UP"
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Name, "TOPLEFT", 0, 6)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self.Name, "TOPRIGHT", 0, 6)
		self.Debuffs.num = 15
		self.Debuffs.iconsPerRow = C["Unitframe"].TargetDebuffsPerRow

		Module:UpdateAuraContainer(focusWidth, self.Debuffs, self.Debuffs.num)

		self.Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		self.Debuffs.showDebuffType = true
		self.Debuffs.FilterAura = Module.CustomFilter
		self.Debuffs.PostCreateButton = Module.PostCreateButton
		self.Debuffs.PostUpdateButton = Module.PostUpdateButton
	end

	-- REASON: Aura Buffs
	if C["Unitframe"].FocusBuffs then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Buffs:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -6)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs.growthX = "RIGHT"
		self.Buffs.growthY = "DOWN"
		self.Buffs.num = 20
		self.Buffs.spacing = 6
		self.Buffs.iconsPerRow = C["Unitframe"].TargetBuffsPerRow
		self.Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(focusWidth, self.Buffs, self.Buffs.num)

		self.Buffs.showStealableBuffs = true
		self.Buffs.FilterAura = Module.CustomFilter
		self.Buffs.PostCreateButton = Module.PostCreateButton
		self.Buffs.PostUpdateButton = Module.PostUpdateButton
	end

	-- REASON: Castbar
	if C["Unitframe"].FocusCastbar then
		local cbW = C["Unitframe"].FocusCastbarWidth
		local cbH = C["Unitframe"].FocusCastbarHeight
		Module:CreateUnitCastbar(self, {
			width = cbW,
			height = cbH,
			textSize = 12,
			stageSize = 20,
			decimal = "%.2f",
			kickTick = true,
			mover = {
				label = "Focus Castbar",
				key = "FocusCB",
				anchor = { "BOTTOM", UIParent, "BOTTOM", -474, 750 },
				width = cbH + cbW + 3,
				height = cbH + 3,
			},
		})
	end

	-- REASON: Heal Prediction
	if C["Unitframe"].ShowHealPrediction then
		Module:CreateHealPrediction(self)
	end

	-- Level
	-- REASON: Level Tag
	self.Level = self:CreateFontString(nil, "OVERLAY")
	if Module.IsDetachedPortrait(focusPortraitStyle) then
		self.Level:Show()
		self.Level:SetPoint("BOTTOMLEFT", self.Portrait, "TOPLEFT", 0, 4)
		self.Level:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 4)
	else
		self.Level:Hide()
	end
	self.Level:SetFontObject(K.UIFont)
	self:Tag(self.Level, "[fulllevel]")

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		if Module.IsDetachedPortrait(focusPortraitStyle) then
			self.PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", 2, 0)
		else
			self.PvPIndicator:SetPoint("LEFT", self.Health, "RIGHT", 2, 0)
		end
		self.PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(16, 16)
	if focusPortraitStyle == 0 then
		self.LeaderIndicator:SetPoint("TOPRIGHT", self.Health, 0, 10)
	else
		self.LeaderIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 10)
	end
	self.LeaderIndicator.PostUpdate = Module.PostUpdateLeaderIndicator

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if Module.IsDetachedPortrait(focusPortraitStyle) then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if Module.IsDetachedPortrait(focusPortraitStyle) then
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Health)
	end
	self.ReadyCheckIndicator:SetSize(C["Unitframe"].FocusHealthHeight - 4, C["Unitframe"].FocusHealthHeight - 4)

	-- REASON: Resurrection Indicator
	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	if Module.IsDetachedPortrait(focusPortraitStyle) then
		self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ResurrectIndicator:SetPoint("CENTER", self.Health)
	end

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
