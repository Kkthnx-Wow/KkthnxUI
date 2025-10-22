local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- Cache frequently used Lua functions
local select = select
local string_format = string.format

-- Cache WoW API functions
local CreateFrame = CreateFrame
local GetThreatStatusColor = GetThreatStatusColor
local UnitIsUnit = UnitIsUnit
local UnitPowerType = UnitPowerType
local UnitThreatSituation = UnitThreatSituation

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

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetFrameLevel(self:GetFrameLevel())
	Health:SetAllPoints(self)
	Health:SetStatusBarTexture(SimplePartyframeTexture)

	Health.Value = Health:CreateFontString(nil, "OVERLAY")
	Health.Value:SetPoint("CENTER", Health, 0, -9)
	Health.Value:SetFontObject(K.UIFont)
	Health.Value:SetFont(select(1, Health.Value:GetFont()), 11, select(3, Health.Value:GetFont()))
	self:Tag(Health.Value, "[raidhp]")

	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["SimpleParty"].HealthbarColor == 3 then
		Health.colorSmooth = true
		Health.colorClass = false
		Health.colorReaction = false
	elseif C["SimpleParty"].HealthbarColor == 2 then
		Health.colorSmooth = false
		Health.colorClass = false
		Health.colorReaction = false
		Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		Health.colorSmooth = false
		Health.colorClass = true
		Health.colorReaction = true
	end

	if C["SimpleParty"].Smooth then
		K:SmoothBar(Health)
	end

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetFrameStrata("LOW")
	Power:SetFrameLevel(self:GetFrameLevel())
	Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -1)
	Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -1)
	Power:SetHeight(C["SimpleParty"].PowerBarHeight)
	Power:SetStatusBarTexture(SimplePartyframeTexture)

	Power.colorPower = true
	Power.frequentUpdates = false

	if C["SimpleParty"].Smooth then
		K:SmoothBar(Power)
	end

	self.Power = Power
	self.UpdateSimplePartyPower = UpdateSimplePartyPower -- Store reference for external access

	table.insert(self.__elements, UpdateSimplePartyPower)
	self:RegisterEvent("UNIT_DISPLAYPOWER", UpdateSimplePartyPower)
	UpdateSimplePartyPower(self, _, self.unit)

	if C["SimpleParty"].ShowHealPrediction then
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints(Health)
		local frameLevel = frame:GetFrameLevel()

		local normalTexture = K.GetTexture(C["General"].Texture)

		-- Position and size
		local myBar = CreateFrame("StatusBar", nil, frame)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT")
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
		local tex = overAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex:SetAllPoints(overAbsorbBar:GetStatusBarTexture())
		tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)

		local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
		healAbsorbBar:SetPoint("TOP")
		healAbsorbBar:SetPoint("BOTTOM")
		healAbsorbBar:SetPoint("RIGHT", Health:GetStatusBarTexture())
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetStatusBarTexture(normalTexture)
		healAbsorbBar:SetStatusBarColor(1, 0, 0.5)
		healAbsorbBar:SetFrameLevel(frameLevel)
		healAbsorbBar:SetAlpha(0.35)
		healAbsorbBar:Hide()
		local tex = healAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex:SetAllPoints(healAbsorbBar:GetStatusBarTexture())
		tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)

		local overAbsorb = Health:CreateTexture(nil, "OVERLAY", nil, 2)
		overAbsorb:SetWidth(8)
		overAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		overAbsorb:SetBlendMode("ADD")
		overAbsorb:SetPoint("TOPLEFT", Health, "TOPRIGHT", -5, 0)
		overAbsorb:SetPoint("BOTTOMLEFT", Health, "BOTTOMRIGHT", -5, -0)
		overAbsorb:Hide()

		local overHealAbsorb = frame:CreateTexture(nil, "OVERLAY")
		overHealAbsorb:SetWidth(15)
		overHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		overHealAbsorb:SetBlendMode("ADD")
		overHealAbsorb:SetPoint("TOPRIGHT", Health, "TOPLEFT", 5, 2)
		overHealAbsorb:SetPoint("BOTTOMRIGHT", Health, "BOTTOMLEFT", 5, -2)
		overHealAbsorb:Hide()

		-- Register with oUF
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

	local Name = self:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -15)
	Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -15)
	Name:SetFontObject(K.UIFont)
	Name:SetWordWrap(false)
	self:Tag(Name, "[lfdrole][name]")

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetFrameStrata(self:GetFrameStrata())
	Overlay:SetFrameLevel(self:GetFrameLevel() + 4)
	Overlay:SetAllPoints(Health)
	Overlay:EnableMouse(false)

	local ReadyCheckIndicator = Overlay:CreateTexture(nil, "OVERLAY", nil, 2)
	ReadyCheckIndicator:SetSize(22, 22)
	ReadyCheckIndicator:SetPoint("CENTER")

	local PhaseIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	PhaseIndicator:SetSize(20, 20)
	PhaseIndicator:SetPoint("CENTER")
	PhaseIndicator:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\PhaseIcons.tga]])
	PhaseIndicator.PostUpdate = Module.UpdatePhaseIcon

	local SummonIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	SummonIndicator:SetSize(20, 20)
	SummonIndicator:SetPoint("CENTER", Overlay)

	local RaidTargetIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	RaidTargetIndicator:SetSize(16, 16)
	RaidTargetIndicator:SetPoint("TOP", self, 0, 8)

	local ResurrectIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	ResurrectIndicator:SetSize(30, 30)
	ResurrectIndicator:SetPoint("CENTER", 0, -3)

	local LeaderIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	LeaderIndicator:SetTexCoord(0, 1, 0, 1) -- NEW?
	LeaderIndicator:SetPoint("TOPLEFT", Health, 0, 8)
	LeaderIndicator:SetSize(14, 14)

	local AssistantIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	AssistantIndicator:SetPoint("TOPLEFT", Health, 0, 8)
	AssistantIndicator:SetSize(14, 14)

	-- if C["Raid"].ShowNotHereTimer then
	-- 	local StatusIndicator = self:CreateFontString(nil, "OVERLAY")
	-- 	StatusIndicator:SetPoint("CENTER", Overlay, "BOTTOM", 0, 6)
	-- 	StatusIndicator:SetFontObject(K.UIFont)
	-- 	StatusIndicator:SetFont(select(1, StatusIndicator:GetFont()), 10, select(3, StatusIndicator:GetFont()))
	-- 	StatusIndicator:SetTextColor(1, 0, 0)
	-- 	self:Tag(StatusIndicator, "[status]")

	-- 	self.StatusIndicator = StatusIndicator
	-- end

	if C["SimpleParty"].RaidBuffsStyle == 2 then
		local AuraTrack = CreateFrame("Frame", nil, Health)
		AuraTrack.Texture = SimplePartyframeTexture
		AuraTrack.Icons = C["SimpleParty"].AuraTrackIcons
		AuraTrack.SpellTextures = C["SimpleParty"].AuraTrackSpellTextures
		AuraTrack.Thickness = C["SimpleParty"].AuraTrackThickness
		AuraTrack.Font = select(1, _G.KkthnxUIFontOutline:GetFont())

		AuraTrack:ClearAllPoints()
		if AuraTrack.Icons ~= true then
			AuraTrack:SetPoint("TOPLEFT", Health, "TOPLEFT", 2, -2)
			AuraTrack:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -2, 2)
		else
			AuraTrack:SetPoint("TOPLEFT", Health, "TOPLEFT", -4, -6)
			AuraTrack:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", 4, 6)
		end

		self.AuraTrack = AuraTrack
	elseif C["SimpleParty"].RaidBuffsStyle == 1 then
		local filter = C["SimpleParty"].RaidBuffs == 3 and "HELPFUL" or "HELPFUL|RAID"
		local onlyShowPlayer = C["SimpleParty"].RaidBuffs == 2

		local frameName = self:GetName()
		local Buffs = CreateFrame("Frame", frameName and string_format("%sBuffs", frameName) or nil, Health)
		Buffs:SetPoint("TOPLEFT", Health, "TOPLEFT", 2, -2)
		Buffs:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -2, 2)
		Buffs:SetHeight(16)
		Buffs:SetWidth(79)
		Buffs.size = 16
		Buffs.num = 5
		Buffs.numRow = 1
		Buffs.spacing = 6
		Buffs.initialAnchor = "TOPLEFT"
		Buffs.disableCooldown = true
		Buffs.disableMouse = true
		Buffs.onlyShowPlayer = onlyShowPlayer
		Buffs.filter = filter
		Buffs.IsRaid = true
		Buffs.PostCreateButton = Module.PostCreateButton
		Buffs.PostUpdateButton = Module.PostUpdateButton

		self.Buffs = Buffs
	end

	if C["SimpleParty"].DebuffWatch then
		local Height = C["SimpleParty"].HealthHeight
		local DebuffSize = Height >= 32 and Height - 20 or Height

		local RaidDebuffs = CreateFrame("Frame", nil, Health)
		RaidDebuffs:SetHeight(DebuffSize)
		RaidDebuffs:SetWidth(DebuffSize)
		RaidDebuffs:SetPoint("CENTER", Health)
		RaidDebuffs:SetFrameLevel(Health:GetFrameLevel() + 10)
		RaidDebuffs:CreateBorder()
		RaidDebuffs:Hide()

		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, "ARTWORK")
		RaidDebuffs.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		RaidDebuffs.icon:SetAllPoints(RaidDebuffs)

		RaidDebuffs.cd = CreateFrame("Cooldown", nil, RaidDebuffs, "CooldownFrameTemplate")
		RaidDebuffs.cd:SetAllPoints(RaidDebuffs)
		RaidDebuffs.cd:SetReverse(true)
		RaidDebuffs.cd.noOCC = true
		RaidDebuffs.cd.noCooldownCount = true
		RaidDebuffs.cd:SetHideCountdownNumbers(true)
		RaidDebuffs.cd:SetAlpha(0.7)

		local parentFrame = CreateFrame("Frame", nil, RaidDebuffs)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(RaidDebuffs:GetFrameLevel() + 6)

		RaidDebuffs.timer = parentFrame:CreateFontString(nil, "OVERLAY")
		RaidDebuffs.timer:SetFont(select(1, _G.KkthnxUIFont:GetFont()), 12, "OUTLINE")
		RaidDebuffs.timer:SetPoint("CENTER", RaidDebuffs, 1, 0)

		RaidDebuffs.count = parentFrame:CreateFontString(nil, "OVERLAY")
		RaidDebuffs.count:SetFont(select(1, _G.KkthnxUIFontOutline:GetFont()), 11, "OUTLINE")
		RaidDebuffs.count:SetPoint("BOTTOMRIGHT", RaidDebuffs, "BOTTOMRIGHT", 2, 0)
		RaidDebuffs.count:SetTextColor(1, 0.9, 0)

		self.RaidDebuffs = RaidDebuffs
	end

	if C["SimpleParty"].TargetHighlight then
		local TargetHighlight = CreateFrame("Frame", nil, Overlay, "BackdropTemplate")
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

	local DebuffHighlight = Health:CreateTexture(nil, "OVERLAY")
	DebuffHighlight:SetAllPoints(Health)
	DebuffHighlight:SetTexture(C["Media"].Textures.White8x8Texture)
	DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	DebuffHighlight:SetBlendMode("ADD")

	self.DebuffHighlightAlpha = 0.45
	self.DebuffHighlightFilter = true

	local Highlight = Health:CreateTexture(nil, "OVERLAY")
	Highlight:SetAllPoints()
	Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	Highlight:SetTexCoord(0, 1, 0.5, 1)
	Highlight:SetVertexColor(0.6, 0.6, 0.6)
	Highlight:SetBlendMode("ADD")
	Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = function() end,
		Override = UpdateSimplePartyThreat,
	}

	self.RangeFader = {
		insideAlpha = 1,
		outsideAlpha = 0.55,
		MaxAlpha = 1,
		MinAlpha = 0.3,
	}

	self.Health = Health
	self.Name = Name
	self.Overlay = Overlay
	-- self.ReadyCheckIndicator = ReadyCheckIndicator
	self.PhaseIndicator = PhaseIndicator
	self.SummonIndicator = SummonIndicator
	self.RaidTargetIndicator = RaidTargetIndicator
	self.ResurrectIndicator = ResurrectIndicator
	self.LeaderIndicator = LeaderIndicator
	self.AssistantIndicator = AssistantIndicator
	self.DebuffHighlight = DebuffHighlight
	self.Highlight = Highlight
end
