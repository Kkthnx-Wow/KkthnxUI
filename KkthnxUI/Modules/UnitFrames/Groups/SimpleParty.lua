--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Creates and updates the Simple Party unit frames.
-- - Design: Features Health, Power, Aura tracking, and basic indicators.
-- - Events: UNIT_HEALTH, UNIT_POWER, UNIT_AURA, etc. handled by oUF.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- REASON: Localize C-functions (Snake Case)
local select = _G.select
local string_format = _G.string.format
local table_insert = _G.table.insert

-- REASON: Localize Globals
local CreateFrame = _G.CreateFrame
local GetThreatStatusColor = _G.GetThreatStatusColor
local UnitIsUnit = _G.UnitIsUnit
local UnitPowerType = _G.UnitPowerType
local UnitThreatSituation = _G.UnitThreatSituation

local function UpdateSimplePartyThreat(self, _, unit)
	if unit ~= self.unit then
		return
	end

	if not self.KKUI_Border then
		return
	end

	local situation = UnitThreatSituation(unit)
	if situation and situation > 0 then
		local r, g, b = GetThreatStatusColor(situation)
		self.KKUI_Border:SetVertexColor(r, g, b)
	else
		K.SetBorderColor(self.KKUI_Border)
	end
end

local function UpdateSimplePartyPower(self, _, unit)
	if self.unit ~= unit or not self.Health then
		return
	end

	-- Check power type (MANA or others)
	local _, powerToken = UnitPowerType(unit)
	local shouldShowPower = false

	-- Determine if power bar should be shown
	if C["SimpleParty"].PowerBarShow then
		-- Show all power bars when PowerBarShow is enabled
		shouldShowPower = true
	elseif C["SimpleParty"].ManabarShow and powerToken == "MANA" then
		-- Show only mana bars when ManabarShow is enabled
		shouldShowPower = true
	end

	-- Calculate health bar offset based on power bar height + spacing
	local powerBarOffset = C["SimpleParty"].PowerBarHeight + 2

	if shouldShowPower then
		if not self.Power:IsVisible() then
			self.Health:ClearAllPoints()
			self.Health:SetPoint("BOTTOMLEFT", self, 0, powerBarOffset)
			self.Health:SetPoint("TOPRIGHT", self)
			self.Power:Show()
		else
			-- Update health position if power bar height changed
			self.Health:ClearAllPoints()
			self.Health:SetPoint("BOTTOMLEFT", self, 0, powerBarOffset)
			self.Health:SetPoint("TOPRIGHT", self)
		end
	else
		if self.Power:IsVisible() then
			self.Health:ClearAllPoints()
			self.Health:SetAllPoints(self)
			self.Power:Hide()
		end
	end
end

function Module:CreateSimpleParty()
	local SimplePartyframeTexture = K.GetTexture(C["General"].Texture)
	local HealPredictionTexture = K.GetTexture(C["General"].Texture)

	Module.CreateHeader(self)

	self:CreateBorder()

	-- REASON: Health Bar Setup
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetFrameLevel(self:GetFrameLevel())
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture(SimplePartyframeTexture)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, 0, -9)
	self.Health.Value:SetFontObject(K.UIFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 11, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[raidhp]")

	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["SimpleParty"].HealthbarColor == 3 then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["SimpleParty"].HealthbarColor == 2 then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	if C["SimpleParty"].Smooth then
		-- K:SmoothBar(self.Health)
	end

	-- REASON: Power Bar Setup
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetFrameStrata("LOW")
	self.Power:SetFrameLevel(self:GetFrameLevel())
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
	self.Power:SetHeight(C["SimpleParty"].PowerBarHeight)
	self.Power:SetStatusBarTexture(SimplePartyframeTexture)

	self.Power.colorPower = true
	self.Power.frequentUpdates = false

	if C["SimpleParty"].Smooth then
		-- K:SmoothBar(self.Power)
	end

	self.UpdateSimplePartyPower = UpdateSimplePartyPower -- Store reference for external access

	table_insert(self.__elements, UpdateSimplePartyPower)
	self:RegisterEvent("UNIT_DISPLAYPOWER", UpdateSimplePartyPower)
	UpdateSimplePartyPower(self, _, self.unit)

	-- REASON: Heal Prediction
	if C["SimpleParty"].ShowHealPrediction then
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints(self.Health)
		local frameLevel = frame:GetFrameLevel()

		local normalTexture = K.GetTexture(C["General"].Texture)

		-- Position and size
		local myBar = CreateFrame("StatusBar", nil, frame)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarTexture(normalTexture)
		myBar:SetStatusBarColor(0, 1, 0.5, 0.5)
		myBar:SetFrameLevel(frameLevel)
		myBar:Hide()

		local otherBar = CreateFrame("StatusBar", nil, frame)
		otherBar:SetPoint("TOP")
		otherBar:SetPoint("BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetStatusBarTexture(normalTexture)
		otherBar:SetStatusBarColor(0, 1, 0, 0.5)
		otherBar:SetFrameLevel(frameLevel)
		otherBar:Hide()

		local absorbBar = CreateFrame("StatusBar", nil, frame)
		absorbBar:SetPoint("TOP")
		absorbBar:SetPoint("BOTTOM")
		absorbBar:SetPoint("LEFT", otherBar:GetStatusBarTexture(), "RIGHT")
		absorbBar:SetStatusBarTexture(normalTexture)
		absorbBar:SetStatusBarColor(0.66, 1, 1)
		absorbBar:SetFrameLevel(frameLevel)
		absorbBar:SetAlpha(0.5)
		absorbBar:Hide()
		local tex = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex:SetAllPoints(absorbBar:GetStatusBarTexture())
		tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)

		local overAbsorbBar = CreateFrame("StatusBar", nil, frame)
		overAbsorbBar:SetAllPoints()
		overAbsorbBar:SetStatusBarTexture(normalTexture)
		overAbsorbBar:SetStatusBarColor(0.66, 1, 1)
		overAbsorbBar:SetFrameLevel(frameLevel)
		overAbsorbBar:SetAlpha(0.35)
		overAbsorbBar:Hide()
		local tex2 = overAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex2:SetAllPoints(overAbsorbBar:GetStatusBarTexture())
		tex2:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex2:SetHorizTile(true)
		tex2:SetVertTile(true)

		local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
		healAbsorbBar:SetPoint("TOP")
		healAbsorbBar:SetPoint("BOTTOM")
		healAbsorbBar:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetStatusBarTexture(normalTexture)
		healAbsorbBar:SetStatusBarColor(1, 0, 0.5)
		healAbsorbBar:SetFrameLevel(frameLevel)
		healAbsorbBar:SetAlpha(0.35)
		healAbsorbBar:Hide()
		local tex3 = healAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex3:SetAllPoints(healAbsorbBar:GetStatusBarTexture())
		tex3:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex3:SetHorizTile(true)
		tex3:SetVertTile(true)

		local overAbsorb = self.Health:CreateTexture(nil, "OVERLAY", nil, 2)
		overAbsorb:SetWidth(8)
		overAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		overAbsorb:SetBlendMode("ADD")
		overAbsorb:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 0)
		overAbsorb:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -0)
		overAbsorb:Hide()

		local overHealAbsorb = frame:CreateTexture(nil, "OVERLAY")
		overHealAbsorb:SetWidth(15)
		overHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		overHealAbsorb:SetBlendMode("ADD")
		overHealAbsorb:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
		overHealAbsorb:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)
		overHealAbsorb:Hide()

		self.HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			absorbBar = absorbBar,
			healAbsorbBar = healAbsorbBar,
			overAbsorbBar = overAbsorbBar,
			overAbsorb = overAbsorb,
			overHealAbsorb = overHealAbsorb,
			maxOverflow = 1,
			PostUpdate = Module.PostUpdatePrediction,
		}
		self.predicFrame = frame
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -15)
	self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -15)
	self.Name:SetFontObject(K.UIFont)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[lfdrole][name]")

	-- REASON: Overlay frame for borders and indicators.
	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetFrameStrata(self:GetFrameStrata())
	self.Overlay:SetFrameLevel(self:GetFrameLevel() + 4)
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:EnableMouse(false)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY", nil, 2)
	self.ReadyCheckIndicator:SetSize(22, 22)
	self.ReadyCheckIndicator:SetPoint("CENTER")

	self.PhaseIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.PhaseIndicator:SetSize(20, 20)
	self.PhaseIndicator:SetPoint("CENTER")
	self.PhaseIndicator:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\PhaseIcons.tga]])
	self.PhaseIndicator.PostUpdate = Module.UpdatePhaseIcon

	self.SummonIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.SummonIndicator:SetSize(20, 20)
	self.SummonIndicator:SetPoint("CENTER", self.Overlay)

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(16, 16)
	self.RaidTargetIndicator:SetPoint("TOP", self, 0, 8)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(30, 30)
	self.ResurrectIndicator:SetPoint("CENTER", 0, -3)

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetTexCoord(0, 1, 0, 1) -- NEW?
	self.LeaderIndicator:SetPoint("TOPLEFT", self.Health, 0, 8)
	self.LeaderIndicator:SetSize(14, 14)
	self.LeaderIndicator.PostUpdate = Module.PostUpdateLeaderIndicator

	self.AssistantIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetPoint("TOPLEFT", self.Health, 0, 8)
	self.AssistantIndicator:SetSize(14, 14)

	-- REASON: Raid Buffs
	if C["SimpleParty"].RaidBuffsStyle == 2 then
		local AuraTrack = CreateFrame("Frame", nil, self.Health)
		AuraTrack.Texture = SimplePartyframeTexture
		AuraTrack.Icons = C["SimpleParty"].AuraTrackIcons
		AuraTrack.SpellTextures = C["SimpleParty"].AuraTrackSpellTextures
		AuraTrack.Thickness = C["SimpleParty"].AuraTrackThickness
		AuraTrack.Font = select(1, _G.KkthnxUIFontOutline:GetFont())

		AuraTrack:ClearAllPoints()
		if AuraTrack.Icons ~= true then
			AuraTrack:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 2, -2)
			AuraTrack:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -2, 2)
		else
			AuraTrack:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -4, -6)
			AuraTrack:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 4, 6)
		end

		self.AuraTrack = AuraTrack
	elseif C["SimpleParty"].RaidBuffsStyle == 1 then
		local filter = C["SimpleParty"].RaidBuffs == 3 and "HELPFUL" or "HELPFUL|RAID"
		local onlyShowPlayer = C["SimpleParty"].RaidBuffs == 2

		local frameName = self:GetName()
		self.Buffs = CreateFrame("Frame", frameName and string_format("%sBuffs", frameName) or nil, self.Health)
		self.Buffs:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 2, -2)
		self.Buffs:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -2, 2)
		self.Buffs:SetHeight(16)
		self.Buffs:SetWidth(79)
		self.Buffs.size = 16
		self.Buffs.num = 5
		self.Buffs.numRow = 1
		self.Buffs.spacing = 6
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs.disableCooldown = true
		self.Buffs.disableMouse = true
		self.Buffs.onlyShowPlayer = onlyShowPlayer
		self.Buffs.filter = filter
		self.Buffs.IsRaid = true
		self.Buffs.PostCreateButton = Module.PostCreateButton
		self.Buffs.PostUpdateButton = Module.PostUpdateButton
	end

	-- REASON: Raid Debuffs
	if C["SimpleParty"].DebuffWatch then
		local Height = C["SimpleParty"].HealthHeight
		local DebuffSize = Height >= 32 and Height - 20 or Height

		self.RaidDebuffs = CreateFrame("Frame", nil, self.Health)
		self.RaidDebuffs:SetHeight(DebuffSize)
		self.RaidDebuffs:SetWidth(DebuffSize)
		self.RaidDebuffs:SetPoint("CENTER", self.Health)
		self.RaidDebuffs:SetFrameLevel(self.Health:GetFrameLevel() + 10)
		self.RaidDebuffs:CreateBorder()
		self.RaidDebuffs:Hide()

		self.RaidDebuffs.icon = self.RaidDebuffs:CreateTexture(nil, "ARTWORK")
		self.RaidDebuffs.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		self.RaidDebuffs.icon:SetAllPoints(self.RaidDebuffs)

		self.RaidDebuffs.cd = CreateFrame("Cooldown", nil, self.RaidDebuffs, "CooldownFrameTemplate")
		self.RaidDebuffs.cd:SetAllPoints(self.RaidDebuffs)
		self.RaidDebuffs.cd:SetReverse(true)
		self.RaidDebuffs.cd.noOCC = true
		self.RaidDebuffs.cd.noCooldownCount = true
		self.RaidDebuffs.cd:SetHideCountdownNumbers(true)
		self.RaidDebuffs.cd:SetAlpha(0.7)

		local parentFrame = CreateFrame("Frame", nil, self.RaidDebuffs)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(self.RaidDebuffs:GetFrameLevel() + 6)

		self.RaidDebuffs.timer = parentFrame:CreateFontString(nil, "OVERLAY")
		self.RaidDebuffs.timer:SetFont(select(1, _G.KkthnxUIFont:GetFont()), 12, "OUTLINE")
		self.RaidDebuffs.timer:SetPoint("CENTER", self.RaidDebuffs, 1, 0)

		self.RaidDebuffs.count = parentFrame:CreateFontString(nil, "OVERLAY")
		self.RaidDebuffs.count:SetFont(select(1, _G.KkthnxUIFontOutline:GetFont()), 11, "OUTLINE")
		self.RaidDebuffs.count:SetPoint("BOTTOMRIGHT", self.RaidDebuffs, "BOTTOMRIGHT", 2, 0)
		self.RaidDebuffs.count:SetTextColor(1, 0.9, 0)
	end

	-- REASON: Target Highlight
	if C["SimpleParty"].TargetHighlight then
		local TargetHighlight = CreateFrame("Frame", nil, self.Overlay, "BackdropTemplate")
		TargetHighlight:SetFrameLevel(6)
		TargetHighlight:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12 })
		TargetHighlight:SetPoint("TOPLEFT", self, -5, 5)
		TargetHighlight:SetPoint("BOTTOMRIGHT", self, 5, -5)
		TargetHighlight:SetBackdropBorderColor(1, 1, 0)
		TargetHighlight:Hide()

		local function UpdateSimplePartyTargetGlow()
			if self.unit and UnitIsUnit("target", self.unit) then
				TargetHighlight:Show()
			else
				TargetHighlight:Hide()
			end
		end

		self.TargetHighlight = TargetHighlight

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateSimplePartyTargetGlow, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateSimplePartyTargetGlow, true)
	end

	self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.DebuffHighlight:SetAllPoints(self.Health)
	self.DebuffHighlight:SetTexture(C["Media"].Textures.White8x8Texture)
	self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	self.DebuffHighlight:SetBlendMode("ADD")

	self.DebuffHighlightAlpha = 0.45
	self.DebuffHighlightFilter = true

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, 0.5, 1)
	self.Highlight:SetVertexColor(0.6, 0.6, 0.6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = UpdateSimplePartyThreat,
	}

	self.RangeFader = {
		insideAlpha = 1,
		outsideAlpha = 0.55,
		MaxAlpha = 1,
		MinAlpha = 0.3,
	}
end
