local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local select = select

local CreateFrame = CreateFrame
local UnitIsUnit = UnitIsUnit

function Module:CreateParty()
	self.mystyle = "party"

	local partyWidth = C["Party"].HealthWidth
	local partyHeight = C["Party"].HealthHeight
	local partyPortraitStyle = C["Unitframe"].PortraitStyle.Value

	local UnitframeTexture = K.GetTexture(C["General"].Texture)
	local HealPredictionTexture = K.GetTexture(C["General"].Texture)

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetFrameStrata(self:GetFrameStrata())
	Overlay:SetFrameLevel(6)
	Overlay:SetAllPoints()
	Overlay:EnableMouse(false)

	Module.CreateHeader(self)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetHeight(partyHeight)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(UnitframeTexture)
	Health:CreateBorder()

	Health.PostUpdate = Module.UpdateHealth
	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["Party"].Smooth then
		K:SmoothBar(Health)
	end

	if C["Party"].HealthbarColor.Value == "Value" then
		Health.colorSmooth = true
		Health.colorClass = false
		Health.colorReaction = false
	elseif C["Party"].HealthbarColor.Value == "Dark" then
		Health.colorSmooth = false
		Health.colorClass = false
		Health.colorReaction = false
		Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		Health.colorSmooth = false
		Health.colorClass = true
		Health.colorReaction = true
	end

	Health.Value = Health:CreateFontString(nil, "OVERLAY")
	Health.Value:SetPoint("CENTER", Health, "CENTER", 0, 0)
	Health.Value:SetFontObject(K.UIFont)
	Health.Value:SetFont(select(1, Health.Value:GetFont()), 10, select(3, Health.Value:GetFont()))
	self:Tag(Health.Value, "[hp]")

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(C["Party"].PowerHeight)
	Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -6)
	Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -6)
	Power:SetStatusBarTexture(UnitframeTexture)
	Power:CreateBorder()

	Power.colorPower = true
	Power.SetFrequentUpdates = true

	if C["Party"].Smooth then
		K:SmoothBar(Power)
	end

	local Name = self:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 4)
	Name:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", 0, 4)
	Name:SetWidth(partyWidth)
	Name:SetWordWrap(false)
	Name:SetFontObject(K.UIFont)
	if partyPortraitStyle == "NoPortraits" or partyPortraitStyle == "OverlayPortrait" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[lfdrole][name] [nplevel]")
		else
			self:Tag(Name, "[lfdrole][color][name] [nplevel]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[lfdrole][name]")
		else
			self:Tag(Name, "[lfdrole][color][name]")
		end
	end

	if partyPortraitStyle ~= "NoPortraits" then
		local Portrait = CreateFrame("PlayerModel", "KKUI_PartyPortrait", self)
		if partyPortraitStyle == "OverlayPortrait" then
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetPoint("TOPLEFT", Health, "TOPLEFT", 1, -1)
			Portrait:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -1, 1)
			Portrait:SetAlpha(0.6)

			self.Portrait = Portrait
		elseif partyPortraitStyle == "ThreeDPortraits" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_PartyPortrait", Health)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
			Portrait:CreateBorder()

			self.Portrait = Portrait
		elseif partyPortraitStyle ~= "ThreeDPortraits" and partyPortraitStyle ~= "OverlayPortrait" then
			local Portrait = Health:CreateTexture("KKUI_PartyPortrait", "BACKGROUND", nil, 1)
			Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)

			Portrait.Border = CreateFrame("Frame", nil, self)
			Portrait.Border:SetAllPoints(Portrait)
			Portrait.Border:CreateBorder()

			self.Portrait = Portrait

			if partyPortraitStyle == "ClassPortraits" or partyPortraitStyle == "NewClassPortraits" then
				Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	local Level = self:CreateFontString(nil, "OVERLAY")
	if partyPortraitStyle ~= "NoPortraits" and partyPortraitStyle ~= "OverlayPortrait" then
		Level:Show()
		Level:SetPoint("BOTTOMLEFT", self.Portrait, "TOPLEFT", 0, 4)
		Level:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 4)
	else
		Level:Hide()
	end
	Level:SetFontObject(K.UIFont)
	self:Tag(Level, "[nplevel]")

	if C["Party"].ShowBuffs then
		local Buffs = CreateFrame("Frame", "KKUI_PartyBuffs", self)
		Buffs:SetPoint("TOPLEFT", Power, "BOTTOMLEFT", 0, -6)
		Buffs:SetPoint("TOPRIGHT", Power, "BOTTOMRIGHT", 0, -6)
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-x"] = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs.num = 6
		Buffs.spacing = 6
		Buffs.iconsPerRow = 6
		Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(partyWidth, Buffs, Buffs.num)

		Buffs.PostCreateButton = Module.PostCreateButton
		Buffs.PostUpdateButton = Module.PostUpdateButton

		self.Buffs = Buffs
	end

	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs.spacing = 6
	Debuffs.initialAnchor = "LEFT"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs:SetPoint("LEFT", Health, "RIGHT", 6, 0)
	Debuffs.num = 5
	Debuffs.iconsPerRow = 5

	Module:UpdateAuraContainer(partyWidth - 14, Debuffs, Debuffs.num)

	Debuffs.PostCreateButton = Module.PostCreateButton
	Debuffs.PostUpdateButton = Module.PostUpdateButton

	if C["Party"].Castbars then
		local Castbar = CreateFrame("StatusBar", "oUF_CastbarParty", self)
		Castbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		Castbar:SetFrameLevel(10)
		Castbar:SetPoint("BOTTOM", Health, "TOP", 0, 6)
		Castbar:SetSize(C["Party"].HealthWidth, 18)
		Castbar:CreateBorder()
		Castbar.castTicks = {}

		Castbar.Spark = Castbar:CreateTexture(nil, "OVERLAY", nil, 2)
		Castbar.Spark:SetSize(64, Castbar:GetHeight() - 2)
		Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		Castbar.Spark:SetBlendMode("ADD")
		Castbar.Spark:SetAlpha(0.8)

		local timer = K.CreateFontString(Castbar, 11, "", "", false, "RIGHT", -3, 0)
		local name = K.CreateFontString(Castbar, 11, "", "", false, "LEFT", 3, 0)
		name:SetPoint("RIGHT", timer, "LEFT", -5, 0)
		name:SetJustifyH("LEFT")

		Castbar.Icon = Castbar:CreateTexture(nil, "ARTWORK")
		Castbar.Icon:SetSize(Castbar:GetHeight(), Castbar:GetHeight())
		Castbar.Icon:SetPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -6, 0)
		Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		Castbar.Button = CreateFrame("Frame", nil, Castbar)
		Castbar.Button:CreateBorder()
		Castbar.Button:SetAllPoints(Castbar.Icon)
		Castbar.Button:SetFrameLevel(Castbar:GetFrameLevel())

		local stage = K.CreateFontString(Castbar, 16)
		stage:ClearAllPoints()
		stage:SetPoint("TOPLEFT", Castbar.Icon, 1, -1)
		Castbar.stageString = stage

		Castbar.decimal = "%.1f"

		Castbar.Time = timer
		Castbar.Text = name
		Castbar.OnUpdate = Module.OnCastbarUpdate
		Castbar.PostCastStart = Module.PostCastStart
		Castbar.PostCastUpdate = Module.PostCastUpdate
		Castbar.PostCastStop = Module.PostCastStop
		Castbar.PostCastFail = Module.PostCastFailed
		Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
		Castbar.CreatePip = Module.CreatePip
		Castbar.PostUpdatePips = Module.PostUpdatePips

		self.Castbar = Castbar
	end

	if C["Party"].ShowHealPrediction then
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints(Health)
		local frameLevel = frame:GetFrameLevel()

		local normalTexture = K.GetTexture(C["General"].Texture)
		local bdTexture = K.MediaFolder .. "Textures\\bgTex"

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
		absorbBar:SetStatusBarTexture(bdTexture)
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
		overAbsorbBar:SetStatusBarTexture(bdTexture)
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
		healAbsorbBar:SetStatusBarTexture(bdTexture)
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

	local StatusIndicator = Power:CreateFontString(nil, "OVERLAY")
	StatusIndicator:SetPoint("CENTER", 0, 0.5)
	StatusIndicator:SetFontObject(K.UIFont)
	StatusIndicator:SetFont(select(1, StatusIndicator:GetFont()), 10, select(3, StatusIndicator:GetFont()))
	self:Tag(StatusIndicator, "[afkdnd]")

	if C["Party"].TargetHighlight then
		local TargetHighlight = CreateFrame("Frame", nil, Overlay, "BackdropTemplate")
		TargetHighlight:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12 })
		TargetHighlight:SetFrameLevel(6)

		local relativeTo = (partyPortraitStyle == "NoPortraits" or partyPortraitStyle == "OverlayPortrait") and Health or self.Portrait

		TargetHighlight:SetPoint("TOPLEFT", relativeTo, -5, 5)
		TargetHighlight:SetPoint("BOTTOMRIGHT", relativeTo, 5, -5)
		TargetHighlight:SetBackdropBorderColor(1, 1, 0)
		TargetHighlight:Hide()

		local function UpdatePartyTargetGlow()
			if UnitIsUnit("target", self.unit) then
				TargetHighlight:Show()
			else
				TargetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdatePartyTargetGlow, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", UpdatePartyTargetGlow, true)

		self.TargetHighlight = TargetHighlight
	end

	local LeaderIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	LeaderIndicator:SetSize(15, 15)
	if partyPortraitStyle == "NoPortraits" or partyPortraitStyle == "OverlayPortrait" then
		LeaderIndicator:SetPoint("TOPLEFT", Health, 0, 10)
	else
		LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 10)
	end

	local AssistantIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	AssistantIndicator:SetSize(15, 15)
	if partyPortraitStyle == "NoPortraits" or partyPortraitStyle == "OverlayPortrait" then
		AssistantIndicator:SetPoint("TOPLEFT", Health, 0, 8)
	else
		AssistantIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
	end

	local ReadyCheckIndicator = Health:CreateTexture(nil, "OVERLAY")
	ReadyCheckIndicator:SetSize(20, 20)
	ReadyCheckIndicator:SetPoint("LEFT", 0, 0)

	local PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
	PhaseIndicator:SetSize(20, 20)
	PhaseIndicator:SetPoint("LEFT", Health, "RIGHT", 4, 0)
	PhaseIndicator:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\PhaseIcons.tga]])
	PhaseIndicator.PostUpdate = Module.UpdatePhaseIcon

	local SummonIndicator = Health:CreateTexture(nil, "OVERLAY")
	SummonIndicator:SetSize(30, 30)
	SummonIndicator:SetPoint("LEFT", 2, 0)

	local RaidTargetIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if partyPortraitStyle ~= "NoPortraits" and partyPortraitStyle ~= "OverlayPortrait" then
		RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		RaidTargetIndicator:SetPoint("TOP", Health, "TOP", 0, 8)
	end
	RaidTargetIndicator:SetSize(14, 14)

	local ResurrectIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	ResurrectIndicator:SetSize(28, 28)
	if partyPortraitStyle ~= "NoPortraits" and partyPortraitStyle ~= "OverlayPortrait" then
		ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		ResurrectIndicator:SetPoint("CENTER", Health)
	end

	if C["Unitframe"].DebuffHighlight then
		local DebuffHighlight = Health:CreateTexture(nil, "OVERLAY")
		DebuffHighlight:SetAllPoints(Health)
		DebuffHighlight:SetTexture(C["Media"].Textures.White8x8Texture)
		DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		DebuffHighlight:SetBlendMode("ADD")

		self.DebuffHighlight = DebuffHighlight

		self.DebuffHighlightAlpha = 0.45
		self.DebuffHighlightFilter = true
	end

	local Highlight = Health:CreateTexture(nil, "OVERLAY")
	Highlight:SetAllPoints()
	Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	Highlight:SetTexCoord(0, 1, 0.5, 1)
	Highlight:SetVertexColor(0.6, 0.6, 0.6)
	Highlight:SetBlendMode("ADD")
	Highlight:Hide()

	local altPower = K.CreateFontString(self, 10, "")
	altPower:SetPoint("LEFT", Power, "RIGHT", 6, 0)
	self:Tag(altPower, "[altpower]")

	local ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	local Range = {
		Override = Module.UpdateRange,
	}

	self.Overlay = Overlay
	self.Health = Health
	self.Power = Power
	self.LeaderIndicator = LeaderIndicator
	self.Debuffs = Debuffs
	self.StatusIndicator = StatusIndicator
	self.AssistantIndicator = AssistantIndicator
	self.RaidTargetIndicator = RaidTargetIndicator
	self.ReadyCheckIndicator = ReadyCheckIndicator
	self.PhaseIndicator = PhaseIndicator
	self.SummonIndicator = SummonIndicator
	self.ResurrectIndicator = ResurrectIndicator
	self.Highlight = Highlight
	self.ThreatIndicator = ThreatIndicator
	self.Range = Range
end
