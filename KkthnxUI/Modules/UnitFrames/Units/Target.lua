--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Creates and updates the Target unit frame.
-- - Design: Features Health, Power, Portrait, Castbar, Auras.
-- - Events: UNIT_HEALTH, UNIT_POWER, UNIT_AURA, etc. handled by oUF.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- PERF: Localize C-functions (Snake Case)
local select = _G.select

-- PERF: Localize Globals
local CreateFrame = _G.CreateFrame
local SetCVar = _G.SetCVar
local UIParent = _G.UIParent

function Module:CreateTarget()
	self.mystyle = "target"

	local targetWidth = C["Unitframe"].TargetHealthWidth
	local targetHeight = C["Unitframe"].TargetHealthHeight
	local targetPortraitStyle = C["Unitframe"].PortraitStyle

	local UnitframeTexture = K.GetTexture(C["General"].Texture)


	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(targetHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	-- REASON: Provides an independent strata layer to prevent border/indicator overlap issues.
	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetFrameStrata(self:GetFrameStrata())
	self.Overlay:SetFrameLevel(6)
	self.Overlay:SetAllPoints()
	self.Overlay:EnableMouse(false)

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

	-- REASON: Health spark — tracks the visual HP edge; hidden when full/zero/dead/offline.
	self.Health.Spark = Module:CreateBarSpark(self.Health)
	self.Health.PostUpdate = Module.PostUpdateHealthSpark

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(C["Unitframe"].TargetPowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Power)
	end

	Module:CreateBarValueTag(self, self.Power, "[power]", { size = 11 })

	-- REASON: Power spark — tracks the visual power edge; hidden when full/zero/dead/offline.
	self.Power.Spark = Module:CreateBarSpark(self.Power)
	self.Power.PostUpdate = Module.PostUpdatePowerSpark

	Module:CreateUnitNameString(self, { layout = "aboveHealth" })
	Module:TagUnitName(self, targetPortraitStyle)
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

	if C["Unitframe"].TargetDebuffs then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.spacing = 6
		self.Debuffs.initialAnchor = "BOTTOMLEFT"
		self.Debuffs.growthX = "RIGHT"
		self.Debuffs.growthY = "UP"
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Name, "TOPLEFT", 0, 6)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self.Name, "TOPRIGHT", 0, 6)
		self.Debuffs.num = 14
		self.Debuffs.iconsPerRow = C["Unitframe"].TargetDebuffsPerRow

		Module:UpdateAuraContainer(targetWidth, self.Debuffs, self.Debuffs.num)

		self.Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		self.Debuffs.showDebuffType = true
		self.Debuffs.FilterAura = Module.CustomFilter
		self.Debuffs.PostCreateButton = Module.PostCreateButton
		self.Debuffs.PostUpdateButton = Module.PostUpdateButton
	end

	if C["Unitframe"].TargetBuffs then
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

		Module:UpdateAuraContainer(targetWidth, self.Buffs, self.Buffs.num)

		self.Buffs.showStealableBuffs = true
		self.Buffs.FilterAura = Module.CustomFilter
		self.Buffs.PostCreateButton = Module.PostCreateButton
		self.Buffs.PostUpdateButton = Module.PostUpdateButton
	end

	if C["Unitframe"].TargetCastbar then
		local cbW = C["Unitframe"].TargetCastbarWidth
		local cbH = C["Unitframe"].TargetCastbarHeight
		Module:CreateUnitCastbar(self, {
			name = "oUF_CastbarTarget",
			width = cbW,
			height = cbH,
			textSize = 12,
			stageSize = 20,
			decimal = "%.2f",
			timeToHold = 0.5,
			sparkSubLevel = 7,
			shield = { size = cbH + 10 },
			kickTick = true,
			mover = {
				label = "Target Castbar",
				key = "TargetCB",
				anchor = { "BOTTOM", UIParent, "BOTTOM", 0, 342 },
				width = cbH + cbW + 6,
				height = cbH,
			},
		})
	end

	if C["Unitframe"].ShowHealPrediction then
		Module:CreateHealPrediction(self)
	end

	Module:CreateLevelTagString(self, self.Portrait, {
		tag = "[fulllevel]",
		layout = "above",
		show = Module.IsDetachedPortrait(targetPortraitStyle),
	})

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		if Module.IsDetachedPortrait(targetPortraitStyle) then
			self.PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", 2, 0)
		else
			self.PvPIndicator:SetPoint("LEFT", self.Health, "RIGHT", 2, 0)
		end
		self.PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(16, 16)
	if Module.IsDetachedPortrait(targetPortraitStyle) then
		self.LeaderIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 10)
	else
		self.LeaderIndicator:SetPoint("TOPRIGHT", self.Health, 0, 10)
	end
	self.LeaderIndicator.PostUpdate = Module.PostUpdateLeaderIndicator

	self.AssistantIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetSize(16, 16)
	if Module.IsDetachedPortrait(targetPortraitStyle) then
		self.AssistantIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 10)
	else
		self.AssistantIndicator:SetPoint("TOPRIGHT", self.Health, 0, 10)
	end

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if Module.IsDetachedPortrait(targetPortraitStyle) then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if Module.IsDetachedPortrait(targetPortraitStyle) then
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Health)
	end
	self.ReadyCheckIndicator:SetSize(targetHeight - 4, targetHeight - 4)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	if Module.IsDetachedPortrait(targetPortraitStyle) then
		self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ResurrectIndicator:SetPoint("CENTER", self.Health)
	end

	self.QuestIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.QuestIndicator:SetSize(20, 20)
	self.QuestIndicator:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -6, 6)

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
