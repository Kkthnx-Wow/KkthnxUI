--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Creates and updates the Party unit frame.
-- - Design: Features Health, Power, Portrait, and Aura management for group members.
-- - Events: UNIT_HEALTH, UNIT_POWER, UNIT_AURA, etc. handled by oUF.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- REASON: Localize C-functions (Snake Case)
local select = _G.select

-- REASON: Localize Globals
local CreateFrame = _G.CreateFrame
local UnitIsUnit = _G.UnitIsUnit

function Module:CreateParty()
	self.mystyle = "party"

	local partyWidth = C["Party"].HealthWidth
	local partyHeight = C["Party"].HealthHeight
	local partyPortraitStyle = C["Unitframe"].PortraitStyle

	local UnitframeTexture = K.GetTexture(C["General"].Texture)


	-- REASON: Overlay frame for borders and indicators.
	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetFrameStrata(self:GetFrameStrata())
	self.Overlay:SetFrameLevel(6)
	self.Overlay:SetAllPoints()
	self.Overlay:EnableMouse(false)

	Module.CreateHeader(self)

	-- REASON: Health Bar Setup
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(partyHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Party"].Smooth then
		K:SmoothBar(self.Health)
	end

	if C["Party"].HealthbarColor == 3 then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Party"].HealthbarColor == 2 then
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
	self.Power:SetHeight(C["Party"].PowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	-- REASON: Power spark — shows a glow at the current power edge; hidden at full/zero/dead/offline.
	self.Power.Spark = Module:CreateBarSpark(self.Power)
	self.Power.PostUpdate = Module.PostUpdatePowerSpark

	if C["Party"].Smooth then
		K:SmoothBar(self.Power)
	end

	Module:CreateUnitNameString(self, { layout = "aboveHealth", width = partyWidth })
	Module:TagUnitName(self, partyPortraitStyle, { prefix = "[lfdrole]", levelTag = "[nplevel]", suffix = "" })
	Module:CreateUnitPortrait(self, { side = "left", style = partyPortraitStyle })

	Module:CreatePrivateAuras(self, {
		point = "TOPRIGHT",
		relativeTo = self.Health,
		relativePoint = "TOPRIGHT",
		x = -2,
		y = -2,
		size = 16,
		num = 4,
		initialAnchor = "TOPRIGHT",
		growthX = "LEFT",
		growthY = "DOWN",
	})
	Module:CreatePortraitLevelTag(self, partyPortraitStyle, { tag = "[nplevel]", layout = "above" })

	-- REASON: Buffs
	if C["Party"].ShowBuffs then
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

		Module:UpdateAuraContainer(partyWidth, self.Buffs, self.Buffs.num)

		self.Buffs.PostCreateButton = Module.PostCreateButton
		self.Buffs.PostUpdateButton = Module.PostUpdateButton
	end

	-- REASON: Debuffs
	self.Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = "LEFT"
	self.Debuffs.growthX = "RIGHT"
	self.Debuffs:SetPoint("LEFT", self.Health, "RIGHT", 6, 0)
	self.Debuffs.num = 5
	self.Debuffs.iconsPerRow = 5

	Module:UpdateAuraContainer(partyWidth - 14, self.Debuffs, self.Debuffs.num)

	self.Debuffs.PostCreateButton = Module.PostCreateButton
	self.Debuffs.PostUpdateButton = Module.PostUpdateButton

	-- REASON: Castbar
	if C["Party"].Castbars then
		Module:CreateUnitCastbar(self, {
			width = C["Party"].HealthWidth,
			relativeTo = self.Health,
		})
	end

	-- REASON: Heal Prediction
	if C["Party"].ShowHealPrediction then
		Module:CreateHealPrediction(self)
	end

	self.StatusIndicator = self.Power:CreateFontString(nil, "OVERLAY")
	self.StatusIndicator:SetPoint("CENTER", 0, 0.5)
	self.StatusIndicator:SetFontObject(K.UIFont)
	self.StatusIndicator:SetFont(select(1, self.StatusIndicator:GetFont()), 10, select(3, self.StatusIndicator:GetFont()))
	self:Tag(self.StatusIndicator, "[afkdnd]")

	-- REASON: Target Highlight
	if C["Party"].TargetHighlight then
		local TargetHighlight = CreateFrame("Frame", nil, self.Overlay, "BackdropTemplate")
		TargetHighlight:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12 })
		TargetHighlight:SetFrameLevel(6)

		local relativeTo = Module.GetPortraitAnchor(self, partyPortraitStyle)

		TargetHighlight:SetPoint("TOPLEFT", relativeTo, -5, 5)
		TargetHighlight:SetPoint("BOTTOMRIGHT", relativeTo, 5, -5)
		TargetHighlight:SetBackdropBorderColor(1, 1, 0)
		TargetHighlight:Hide()

		local function UpdatePartyTargetGlow()
			if K.UnitIsUnit("target", self.unit) then
				TargetHighlight:Show()
			else
				TargetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdatePartyTargetGlow, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdatePartyTargetGlow, true)

		self.TargetHighlight = TargetHighlight
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(15, 15)
	self.LeaderIndicator:SetPoint("TOPLEFT", Module.GetPortraitAnchor(self, partyPortraitStyle), 0, 10)
	self.LeaderIndicator.PostUpdate = Module.PostUpdateLeaderIndicator

	self.AssistantIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetSize(15, 15)
	self.AssistantIndicator:SetPoint("TOPLEFT", Module.GetPortraitAnchor(self, partyPortraitStyle), 0, 8)

	self.ReadyCheckIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.ReadyCheckIndicator:SetSize(20, 20)
	self.ReadyCheckIndicator:SetPoint("LEFT", 0, 0)

	self.PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PhaseIndicator:SetSize(20, 20)
	self.PhaseIndicator:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
	self.PhaseIndicator:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\PhaseIcons.tga]])
	self.PhaseIndicator.PostUpdate = Module.UpdatePhaseIcon

	self.SummonIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.SummonIndicator:SetSize(30, 30)
	self.SummonIndicator:SetPoint("LEFT", 2, 0)

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOP", Module.GetPortraitAnchor(self, partyPortraitStyle), "TOP", 0, 8)
	self.RaidTargetIndicator:SetSize(14, 14)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(28, 28)
	self.ResurrectIndicator:SetPoint("CENTER", Module.GetPortraitAnchor(self, partyPortraitStyle))

	-- REASON: Debuff Highlight
	if C["Unitframe"].DebuffHighlight then
		Module:CreateDebuffHighlight(self)
	end

	if C["Party"].DispelIcon then
		Module:CreateRaidDispelIcon(self, "Party")
	end

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, 0.5, 1)
	self.Highlight:SetVertexColor(0.6, 0.6, 0.6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	local altPower = K.CreateFontString(self, 10, "")
	altPower:SetPoint("LEFT", self.Power, "RIGHT", 6, 0)
	self:Tag(altPower, "[altpower]")

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
