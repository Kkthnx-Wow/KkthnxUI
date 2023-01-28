local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local select = _G.select

local CreateFrame = _G.CreateFrame
local GetThreatStatusColor = _G.GetThreatStatusColor
local UnitIsUnit = _G.UnitIsUnit
local UnitThreatSituation = _G.UnitThreatSituation

local function UpdateRaidThreat(self, _, unit)
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

local function UpdateRaidPower(self, _, unit)
	-- Check if the unit passed as an argument is the same as the frame's unit
	if self.unit ~= unit then
		return
	end

	-- Check if the unit is assigned as a healer role and not assigned as none
	if UnitGroupRolesAssigned(unit) == "HEALER" and UnitGroupRolesAssigned(unit) ~= "NONE" then
		-- If the power frame is not visible, adjust the health frame and show power frame
		if not self.Power:IsVisible() then
			self.Health:ClearAllPoints()
			self.Health:SetPoint("BOTTOMLEFT", self, 0, 6)
			self.Health:SetPoint("TOPRIGHT", self)

			self.Power:Show()
		end
	else
		-- If the power frame is visible, reset the health frame and hide the power frame
		if self.Power:IsVisible() then
			self.Health:ClearAllPoints()
			self.Health:SetAllPoints(self)

			self.Power:Hide()
		end
	end
end

function Module:CreateRaid()
	local RaidframeTexture = K.GetTexture(C["General"].Texture)
	local HealPredictionTexture = K.GetTexture(C["General"].Texture)

	Module.CreateHeader(self)

	self:CreateBorder()

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetFrameLevel(self:GetFrameLevel())
	Health:SetAllPoints(self)
	Health:SetStatusBarTexture(RaidframeTexture)

	Health.Value = Health:CreateFontString(nil, "OVERLAY")
	Health.Value:SetPoint("CENTER", Health, 0, -9)
	Health.Value:SetFontObject(K.UIFont)
	Health.Value:SetFont(select(1, Health.Value:GetFont()), 11, select(3, Health.Value:GetFont()))
	self:Tag(Health.Value, "[raidhp]")

	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["Raid"].HealthbarColor.Value == "Value" then
		Health.colorSmooth = true
		Health.colorClass = false
		Health.colorReaction = false
	elseif C["Raid"].HealthbarColor.Value == "Dark" then
		Health.colorSmooth = false
		Health.colorClass = false
		Health.colorReaction = false
		Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		Health.colorSmooth = false
		Health.colorClass = true
		Health.colorReaction = true
	end

	if C["Raid"].Smooth then
		K:SmoothBar(Health)
	end

	if C["Raid"].ManabarShow then
		local Power = CreateFrame("StatusBar", nil, self)
		Power:SetFrameStrata("LOW")
		Power:SetFrameLevel(self:GetFrameLevel())
		Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -1)
		Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -1)
		Power:SetHeight(4)
		Power:SetStatusBarTexture(RaidframeTexture)

		Power.colorPower = true
		Power.frequentUpdates = false

		if C["Raid"].Smooth then
			K:SmoothBar(Power)
		end

		self.Power = Power

		table.insert(self.__elements, UpdateRaidPower)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateRaidPower)
		self:RegisterEvent("UNIT_MAXPOWER", UpdateRaidPower)
		self:RegisterEvent("UNIT_DISPLAYPOWER", UpdateRaidPower)
	end

	if C["Raid"].ShowHealPrediction then
		local mhpb = Health:CreateTexture(nil, "BORDER", nil, 5)
		mhpb:SetWidth(1)
		mhpb:SetTexture(HealPredictionTexture)
		mhpb:SetVertexColor(0, 1, 0.5, 0.25)

		local ohpb = Health:CreateTexture(nil, "BORDER", nil, 5)
		ohpb:SetWidth(1)
		ohpb:SetTexture(HealPredictionTexture)
		ohpb:SetVertexColor(0, 1, 0, 0.25)

		local abb = Health:CreateTexture(nil, "BORDER", nil, 5)
		abb:SetWidth(1)
		abb:SetTexture(HealPredictionTexture)
		abb:SetVertexColor(1, 1, 0, 0.25)

		local abbo = Health:CreateTexture(nil, "ARTWORK", nil, 1)
		abbo:SetAllPoints(abb)
		abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		abbo.tileSize = 32

		local oag = Health:CreateTexture(nil, "ARTWORK", nil, 1)
		oag:SetWidth(15)
		oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		oag:SetBlendMode("ADD")
		oag:SetAlpha(0.25)
		oag:SetPoint("TOPLEFT", Health, "TOPRIGHT", -5, 2)
		oag:SetPoint("BOTTOMLEFT", Health, "BOTTOMRIGHT", -5, -2)

		local hab = CreateFrame("StatusBar", nil, Health)
		hab:SetPoint("TOP")
		hab:SetPoint("BOTTOM")
		hab:SetPoint("RIGHT", Health:GetStatusBarTexture())
		hab:SetWidth(C["Raid"].Width)
		hab:SetReverseFill(true)
		hab:SetStatusBarTexture(HealPredictionTexture)
		hab:SetStatusBarColor(1, 0, 0, 0.25)

		local ohg = Health:CreateTexture(nil, "ARTWORK", nil, 1)
		ohg:SetWidth(15)
		ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		ohg:SetBlendMode("ADD")
		ohg:SetPoint("TOPRIGHT", Health, "TOPLEFT", 5, 2)
		ohg:SetPoint("BOTTOMRIGHT", Health, "BOTTOMLEFT", 5, -2)

		self.HealPredictionAndAbsorb = {
			myBar = mhpb,
			otherBar = ohpb,
			absorbBar = abb,
			absorbBarOverlay = abbo,
			overAbsorbGlow = oag,
			healAbsorbBar = hab,
			overHealAbsorbGlow = ohg,
			maxOverflow = 1,
		}
	end

	local Name = self:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -15)
	Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -15)
	Name:SetFontObject(K.UIFont)
	Name:SetWordWrap(false)
	self:Tag(Name, "[lfdrole][name]")

	local Overlay = CreateFrame("Frame", nil, self)
	Overlay:SetAllPoints(Health)
	Overlay:SetFrameLevel(self:GetFrameLevel() + 4)

	-- local ReadyCheckIndicator = Overlay:CreateTexture(nil, "OVERLAY", 2)
	-- ReadyCheckIndicator:SetSize(22, 22)
	-- ReadyCheckIndicator:SetPoint("CENTER")

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
	LeaderIndicator:SetPoint("TOPLEFT", Health, 0, 8)
	LeaderIndicator:SetSize(12, 12)

	local AssistantIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	AssistantIndicator:SetPoint("TOPLEFT", Health, 0, 8)
	AssistantIndicator:SetSize(12, 12)

	if C["Raid"].ShowNotHereTimer then
		local StatusIndicator = self:CreateFontString(nil, "OVERLAY")
		StatusIndicator:SetPoint("CENTER", Overlay, "BOTTOM", 0, 6)
		StatusIndicator:SetFontObject(K.UIFont)
		StatusIndicator:SetFont(select(1, StatusIndicator:GetFont()), 10, select(3, StatusIndicator:GetFont()))
		StatusIndicator:SetTextColor(1, 0, 0)
		self:Tag(StatusIndicator, "[afkdnd]")

		self.StatusIndicator = StatusIndicator
	end

	if C["Raid"].RaidBuffsStyle.Value == "Aura Track" then
		local AuraTrack = CreateFrame("Frame", nil, Health)
		AuraTrack.Texture = RaidframeTexture
		AuraTrack.Icons = C["Raid"].AuraTrackIcons
		AuraTrack.SpellTextures = C["Raid"].AuraTrackSpellTextures
		AuraTrack.Thickness = C["Raid"].AuraTrackThickness
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
	elseif C["Raid"].RaidBuffsStyle.Value == "Standard" then
		local filter = C["Raid"].RaidBuffs.Value == "All" and "HELPFUL" or "HELPFUL|RAID"
		local onlyShowPlayer = C["Raid"].RaidBuffs.Value == "Self"

		local Buffs = CreateFrame("Frame", self:GetName() .. "Buffs", Health)
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

	if C["Raid"].DebuffWatch then
		local Height = C["Raid"].Height
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

		RaidDebuffs.onlyMatchSpellID = true
		RaidDebuffs.showDispellableDebuff = true

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

		RaidDebuffs.forceShow = false
		RaidDebuffs.ShowDispellableDebuff = true

		self.RaidDebuffs = RaidDebuffs
	end

	if C["Raid"].TargetHighlight then
		local TargetHighlight = CreateFrame("Frame", nil, Overlay, "BackdropTemplate")
		TargetHighlight:SetFrameLevel(6)
		TargetHighlight:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12 })
		TargetHighlight:SetPoint("TOPLEFT", self, -5, 5)
		TargetHighlight:SetPoint("BOTTOMRIGHT", self, 5, -5)
		TargetHighlight:SetBackdropBorderColor(1, 1, 0)
		TargetHighlight:Hide()

		local function UpdateRaidTargetGlow()
			if UnitIsUnit("target", self.unit) then
				TargetHighlight:Show()
			else
				TargetHighlight:Hide()
			end
		end

		self.TargetHighlight = TargetHighlight

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateRaidTargetGlow, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateRaidTargetGlow, true)
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
		Override = UpdateRaidThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)

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
