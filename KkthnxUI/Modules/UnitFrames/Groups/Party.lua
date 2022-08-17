local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local select = _G.select

local CreateFrame = _G.CreateFrame
local UnitIsUnit = _G.UnitIsUnit

function Module:CreateParty()
	self.mystyle = "party"

	local partyWidth = C["Party"].HealthWidth
	local partyHeight = C["Party"].HealthHeight
	local partyPortraitStyle = C["Unitframe"].PortraitStyle.Value

	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetAllPoints()
	Overlay:SetFrameLevel(6)

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
	Health.Value:SetFontObject(UnitframeFont)
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
	Name:SetFontObject(UnitframeFont)
	if partyPortraitStyle == "NoPortraits" or partyPortraitStyle == "OverlayPortrait" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[lfdrole][name] [nplevel][afkdnd]")
		else
			self:Tag(Name, "[lfdrole][color][name] [nplevel][afkdnd]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[lfdrole][name][afkdnd]")
		else
			self:Tag(Name, "[lfdrole][color][name][afkdnd]")
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
	Level:SetFontObject(UnitframeFont)
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

		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura

		self.Buffs = Buffs
	end

	local Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	Debuffs.spacing = 6
	Debuffs.initialAnchor = "LEFT"
	Debuffs["growth-x"] = "RIGHT"
	Debuffs:SetPoint("LEFT", Health, "RIGHT", 6, 0)
	Debuffs.num = 5
	Debuffs.iconsPerRow = 5

	Module:UpdateAuraContainer(partyWidth - 10, Debuffs, Debuffs.num)

	Debuffs.PostCreateIcon = Module.PostCreateAura
	Debuffs.PostUpdateIcon = Module.PostUpdateAura

	if C["Party"].Castbars then
		local Castbar = CreateFrame("StatusBar", "PartyCastbar", self)
		Castbar:SetStatusBarTexture(UnitframeTexture)
		Castbar:SetClampedToScreen(true)
		Castbar:CreateBorder()

		Castbar:ClearAllPoints()
		if partyPortraitStyle == "NoPortraits" or partyPortraitStyle == "OverlayPortrait" then
			Castbar:SetPoint("TOPLEFT", C["Party"].CastbarIcon and 22 or 0, 22)
			Castbar:SetPoint("TOPRIGHT", 0, 22)
		else
			Castbar:SetPoint("TOPLEFT", self.Portrait, C["Party"].CastbarIcon and 22 or 0, 22)
			Castbar:SetPoint("TOPRIGHT", 0, 22)
		end
		Castbar:SetHeight(16)

		Castbar.Spark = Castbar:CreateTexture(nil, "OVERLAY")
		Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		Castbar.Spark:SetSize(128, Castbar:GetHeight())
		Castbar.Spark:SetBlendMode("ADD")

		Castbar.Time = Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		Castbar.Time:SetFont(select(1, Castbar.Time:GetFont()), 11, select(3, Castbar.Time:GetFont()))
		Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		Castbar.Time:SetJustifyH("RIGHT")

		Castbar.decimal = "%.2f"

		Castbar.OnUpdate = Module.OnCastbarUpdate
		Castbar.PostCastStart = Module.PostCastStart
		Castbar.PostCastStop = Module.PostCastStop
		Castbar.PostCastFail = Module.PostCastFailed
		Castbar.PostCastInterruptible = Module.PostUpdateInterruptible

		Castbar.Text = Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		Castbar.Text:SetFont(select(1, Castbar.Text:GetFont()), 11, select(3, Castbar.Text:GetFont()))
		Castbar.Text:SetPoint("LEFT", 3.5, 0)
		Castbar.Text:SetPoint("RIGHT", Castbar.Time, "LEFT", -3.5, 0)
		Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		Castbar.Text:SetJustifyH("LEFT")
		Castbar.Text:SetWordWrap(false)

		if C["Party"].CastbarIcon then
			Castbar.Button = CreateFrame("Frame", nil, Castbar)
			Castbar.Button:SetSize(16, 16)
			Castbar.Button:CreateBorder()

			Castbar.Icon = Castbar.Button:CreateTexture(nil, "ARTWORK")
			Castbar.Icon:SetSize(Castbar:GetHeight(), Castbar:GetHeight())
			Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			Castbar.Icon:SetPoint("RIGHT", Castbar, "LEFT", -6, 0)

			Castbar.Button:SetAllPoints(Castbar.Icon)
		end

		self.Castbar = Castbar
	end

	if C["Party"].ShowHealPrediction then
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
		hab:SetWidth(124)
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

	local StatusIndicator = Power:CreateFontString(nil, "OVERLAY")
	StatusIndicator:SetPoint("CENTER", 0, 0.5)
	StatusIndicator:SetFontObject(UnitframeFont)
	StatusIndicator:SetFont(select(1, StatusIndicator:GetFont()), 10, select(3, StatusIndicator:GetFont()))
	self:Tag(StatusIndicator, "[afkdnd]")

	if C["Party"].TargetHighlight then
		local TargetHighlight = CreateFrame("Frame", nil, Overlay, "BackdropTemplate")
		TargetHighlight:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12 })
		TargetHighlight:SetFrameLevel(6)

		local relativeTo
		if partyPortraitStyle == "NoPortraits" or partyPortraitStyle == "OverlayPortrait" then
			relativeTo = Health
		else
			relativeTo = self.Portrait
		end

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
	LeaderIndicator:SetSize(12, 12)
	if partyPortraitStyle == "NoPortraits" or partyPortraitStyle == "OverlayPortrait" then
		LeaderIndicator:SetPoint("TOPLEFT", Health, 0, 8)
	else
		LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
	end

	local AssistantIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	AssistantIndicator:SetSize(12, 12)
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
	SummonIndicator:SetSize(20, 20)
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
		DebuffHighlight:SetTexture(C["Media"].Textures.BlankTexture)
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

	local Range = Module.CreateRangeIndicator(self)

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
