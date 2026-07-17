--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Creates and updates the Boss unit frames.
-- - Design: Features Health, Power, Portrait, Castbar, and Aura tracking specifically for Boss encounters.
-- - Events: UNIT_HEALTH, UNIT_POWER, UNIT_AURA, etc. handled by oUF.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- REASON: Localize C-functions (Snake Case)
local select = _G.select

-- REASON: Localize Globals
local CreateFrame = _G.CreateFrame
local UnitIsUnit = _G.UnitIsUnit

function Module:CreateBoss()
	self.mystyle = "boss"

	local bossWidth = C["Boss"].HealthWidth
	local bossHeight = C["Boss"].HealthHeight
	local bossPortraitStyle = C["Unitframe"].PortraitStyle

	local UnitframeTexture = K.GetTexture(C["General"].Texture)

	-- REASON: Overlay frame for borders and indicators.
	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(6)

	Module.CreateHeader(self)

	-- REASON: Health Bar Setup
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(bossHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Boss"].Smooth then
		K:SmoothBar(self.Health)
	end

	if C["Boss"].HealthbarColor == 3 then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Boss"].HealthbarColor == 2 then
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
	self.Power:SetHeight(C["Boss"].PowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	-- REASON: Power spark — shows a glow at the current power edge; hidden at full/zero/dead/offline.
	self.Power.Spark = Module:CreateBarSpark(self.Power)
	self.Power.PostUpdate = Module.PostUpdatePowerSpark

	if C["Boss"].Smooth then
		K:SmoothBar(self.Power)
	end

	Module:CreateUnitNameString(self, { layout = "aboveHealth", width = bossWidth })
	Module:TagUnitName(self, bossPortraitStyle, { levelTag = "[nplevel]" })
	Module:CreateUnitPortrait(self, { side = "right", style = bossPortraitStyle })
	Module:CreatePortraitLevelTag(self, bossPortraitStyle, { tag = "[nplevel]", layout = "above" })

	--if C["Boss"].ShowBuffs then
	-- REASON: Aura Buffs
	self.Buffs = CreateFrame("Frame", nil, self)
	self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
	self.Buffs:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -6)
	self.Buffs.initialAnchor = "TOPLEFT"
	self.Buffs.growthX = "RIGHT"
	self.Buffs.growthY = "DOWN"
	self.Buffs.num = 6
	self.Buffs.spacing = 6
	self.Buffs.iconsPerRow = 6
	self.Buffs.onlyShowPlayer = false

	Module:UpdateAuraContainer(bossWidth, self.Buffs, self.Buffs.num)

	self.Buffs.showStealableBuffs = true
	self.Buffs.FilterAura = Module.CustomFilter
	self.Buffs.PostCreateButton = Module.PostCreateButton
	self.Buffs.PostUpdateButton = Module.PostUpdateButton

	-- REASON: Aura Debuffs
	self.Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = "RIGHT"
	self.Debuffs.growthX = "LEFT"
	self.Debuffs:SetPoint("RIGHT", self.Health, "LEFT", -6, 0)
	self.Debuffs.num = 5
	self.Debuffs.iconsPerRow = 5

	Module:UpdateAuraContainer(bossWidth - 12, self.Debuffs, self.Debuffs.num)

	self.Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
	self.Debuffs.FilterAura = Module.CustomFilter
	self.Debuffs.PostCreateButton = Module.PostCreateButton
	self.Debuffs.PostUpdateButton = Module.PostUpdateButton

	-- REASON: Castbar configuration
	if C["Boss"].Castbars then
		local iconOffset = 24
		Module:CreateUnitCastbar(self, {
			width = C["Boss"].HealthWidth,
			shield = true,
			kickTick = true,
			textSize = 11,
			decimal = "%.1f",
			timeX = -3,
			textX = 3,
			textGap = 4,
			timerJustify = "RIGHT",
			-- Keep bar width = health width; icon hangs left so the timer isn't clipped.
			onSize = function(castbar, unitFrame)
				castbar:ClearAllPoints()
				castbar:SetPoint("BOTTOMLEFT", unitFrame.Health, "TOPLEFT", iconOffset, 6)
				castbar:SetPoint("BOTTOMRIGHT", unitFrame.Health, "TOPRIGHT", 0, 6)
				castbar:SetHeight(18)
			end,
		})
	end
	if C["Boss"].TargetHighlight then
		self.TargetHighlight = CreateFrame("Frame", nil, self.Overlay, "BackdropTemplate")
		self.TargetHighlight:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12 })

		local relativeTo = Module.GetPortraitAnchor(self, bossPortraitStyle)

		self.TargetHighlight:SetPoint("TOPLEFT", relativeTo, -5, 5)
		self.TargetHighlight:SetPoint("BOTTOMRIGHT", relativeTo, 5, -5)
		self.TargetHighlight:SetBackdropBorderColor(1, 1, 0)
		self.TargetHighlight:Hide()

		local function UpdateBossTargetGlow()
			if K.UnitIsUnit("target", self.unit) then
				self.TargetHighlight:Show()
			else
				self.TargetHighlight:Hide()
			end
		end

		-- Unsure as to what is needed here currently, needs testing.
		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateBossTargetGlow, true)
	end

	-- REASON: Raid Target Indicator
	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOP", Module.GetPortraitAnchor(self, bossPortraitStyle), "TOP", 0, 8)
	self.RaidTargetIndicator:SetSize(14, 14)

	-- REASON: Resurrection Indicator
	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(28, 28)
	self.ResurrectIndicator:SetPoint("CENTER", Module.GetPortraitAnchor(self, bossPortraitStyle))

	-- REASON: Debuff Highlight
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

	local altPower = K.CreateFontString(self, 10, "")
	altPower:SetPoint("RIGHT", self.Power, "LEFT", -6, 0)
	self:Tag(altPower, "[altpower]")

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	-- REASON: Range Fader Settings
	self.RangeFader = {
		insideAlpha = 1,
		outsideAlpha = 0.55,
		MaxAlpha = 1,
		MinAlpha = 0.3,
	}
end
