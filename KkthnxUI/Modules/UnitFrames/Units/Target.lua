local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame

function Module:CreateTarget()
	self.mystyle = "target"

	local targetWidth = C["Unitframe"].TargetHealthWidth
	local targetHeight = C["Unitframe"].TargetHealthHeight
	local targetPortraitStyle = C["Unitframe"].PortraitStyle.Value

	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	Module.CreateHeader(self)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetHeight(targetHeight)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(UnitframeTexture)
	Health:CreateBorder()

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetAllPoints(Health)
	Overlay:SetFrameLevel(5)

	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(Health)
	end

	if C["Unitframe"].HealthbarColor.Value == "Value" then
		Health.colorSmooth = true
		Health.colorClass = false
		Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor.Value == "Dark" then
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
	self:Tag(Health.Value, "[hp]")

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(C["Unitframe"].TargetPowerHeight)
	Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -6)
	Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -6)
	Power:SetStatusBarTexture(UnitframeTexture)
	Power:CreateBorder()

	Power.colorPower = true
	Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(Power)
	end

	Power.Value = Power:CreateFontString(nil, "OVERLAY")
	Power.Value:SetPoint("CENTER", Power, "CENTER", 0, 0)
	Power.Value:SetFontObject(UnitframeFont)
	Power.Value:SetFont(select(1, Power.Value:GetFont()), 11, select(3, Power.Value:GetFont()))
	self:Tag(Power.Value, "[power]")

	local Name = self:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 4)
	Name:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", 0, 4)
	Name:SetFontObject(UnitframeFont)
	Name:SetWordWrap(false)

	if targetPortraitStyle == "NoPortraits" or targetPortraitStyle == "OverlayPortrait" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[name] [fulllevel][afkdnd]")
		else
			self:Tag(Name, "[color][name] [fulllevel][afkdnd]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(Name, "[name][afkdnd]")
		else
			self:Tag(Name, "[color][name][afkdnd]")
		end
	end

	if targetPortraitStyle ~= "NoPortraits" then
		if targetPortraitStyle == "OverlayPortrait" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_TargetPortrait", self)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetPoint("TOPLEFT", Health, "TOPLEFT", 1, -1)
			Portrait:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -1, 1)
			Portrait:SetAlpha(0.6)

			self.Portrait = Portrait
		elseif targetPortraitStyle == "ThreeDPortraits" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_TargetPortrait", Health)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			Portrait:CreateBorder()

			self.Portrait = Portrait
		elseif targetPortraitStyle ~= "ThreeDPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
			local Portrait = Health:CreateTexture("KKUI_TargetPortrait", "BACKGROUND", nil, 1)
			Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

			Portrait.Border = CreateFrame("Frame", nil, self)
			Portrait.Border:SetAllPoints(Portrait)
			Portrait.Border:CreateBorder()

			self.Portrait = Portrait

			if (targetPortraitStyle == "ClassPortraits" or targetPortraitStyle == "NewClassPortraits") then
				Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	if C["Unitframe"].TargetDebuffs then
		local Debuffs = CreateFrame("Frame", nil, self)
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "BOTTOMLEFT"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOMLEFT", Name, "TOPLEFT", 0, 6)
		Debuffs:SetPoint("BOTTOMRIGHT", Name, "TOPRIGHT", 0, 6)
		Debuffs.num = 14
		Debuffs.iconsPerRow = C["Unitframe"].TargetDebuffsPerRow

		Module:UpdateAuraContainer(targetWidth, Debuffs, Debuffs.num)

		Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

		self.Debuffs = Debuffs
	end

	if C["Unitframe"].TargetBuffs then
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetPoint("TOPLEFT", Power, "BOTTOMLEFT", 0, -6)
		Buffs:SetPoint("TOPRIGHT", Power, "BOTTOMRIGHT", 0, -6)
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-x"] = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs.num = 20
		Buffs.spacing = 6
		Buffs.iconsPerRow = C["Unitframe"].TargetBuffsPerRow
		Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(targetWidth, Buffs, Buffs.num)

		Buffs.showStealableBuffs = true
		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura
		Buffs.PreUpdate = Module.bolsterPreUpdate
		Buffs.PostUpdate = Module.bolsterPostUpdate

		self.Buffs = Buffs
	end

	if C["Unitframe"].TargetCastbar then
		local Castbar = CreateFrame("StatusBar", "TargetCastbar", self)
		Castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", C["Unitframe"].TargetCastbarIcon and 18 or 0, 342)
		Castbar:SetStatusBarTexture(UnitframeTexture)
		Castbar:SetSize(C["Unitframe"].TargetCastbarWidth, C["Unitframe"].TargetCastbarHeight)
		Castbar:SetClampedToScreen(true)
		Castbar:CreateBorder()

		Castbar.Spark = Castbar:CreateTexture(nil, "OVERLAY")
		Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		Castbar.Spark:SetSize(64, Castbar:GetHeight())
		Castbar.Spark:SetBlendMode("ADD")

		self.ShieldOverlay = CreateFrame("Frame", nil, Castbar) -- We will use this to overlay onto our special borders.
		self.ShieldOverlay:SetAllPoints()
		self.ShieldOverlay:SetFrameLevel(5)

		Castbar.Shield = self.ShieldOverlay:CreateTexture(nil, "OVERLAY")
		Castbar.Shield:SetAtlas("Soulbinds_Portrait_Lock")
		Castbar.Shield:SetSize(C["Unitframe"].TargetCastbarHeight + 10, C["Unitframe"].TargetCastbarHeight + 10)
		Castbar.Shield:SetPoint("CENTER", 0, -14)

		Castbar.Time = Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
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
		Castbar.Text:SetPoint("LEFT", 3.5, 0)
		Castbar.Text:SetPoint("RIGHT", Castbar.Time, "LEFT", -3.5, 0)
		Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		Castbar.Text:SetJustifyH("LEFT")
		Castbar.Text:SetWordWrap(false)

		if C["Unitframe"].TargetCastbarIcon then
			Castbar.Button = CreateFrame("Frame", nil, Castbar)
			Castbar.Button:SetSize(20, 20)
			Castbar.Button:CreateBorder()

			Castbar.Icon = Castbar.Button:CreateTexture(nil, "ARTWORK")
			Castbar.Icon:SetSize(C["Unitframe"].TargetCastbarHeight, C["Unitframe"].TargetCastbarHeight)
			Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			Castbar.Icon:SetPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -6, 0)

			Castbar.Button:SetAllPoints(Castbar.Icon)
		end

		self.Castbar = Castbar

		K.Mover(Castbar, "TargetCastBar", "TargetCastBar", {"BOTTOM", UIParent, "BOTTOM", C["Unitframe"].TargetCastbarIcon and 18 or 0, 342})
	end

	if C["Unitframe"].ShowHealPrediction then
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
		hab:SetWidth(targetWidth)
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

	-- Level
	local Level = self:CreateFontString(nil, "OVERLAY")
	if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
		Level:Show()
		Level:SetPoint("BOTTOMLEFT", self.Portrait, "TOPLEFT", 0, 4)
		Level:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 4)
	else
		Level:Hide()
	end
	Level:SetFontObject(UnitframeFont)
	self:Tag(Level, "[fulllevel]")

	if C["Unitframe"].CombatText then
		local parentFrame = CreateFrame("Frame", nil, UIParent)
		local FloatingCombatFeedback = CreateFrame("Frame", "oUF_Target_CombatTextFrame", parentFrame)
		FloatingCombatFeedback:SetSize(32, 32)
		K.Mover(FloatingCombatFeedback, "CombatText", "TargetCombatText", {"BOTTOM", self, "TOPRIGHT", 0, 120})

		for i = 1, 36 do
			FloatingCombatFeedback[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
		end

		FloatingCombatFeedback.font = C["Media"].Fonts.DamageFont
		FloatingCombatFeedback.fontFlags = "OUTLINE"
		FloatingCombatFeedback.abbreviateNumbers = true

		self.FloatingCombatFeedback = FloatingCombatFeedback

		-- Default CombatText
		SetCVar("enableFloatingCombatText", 0)
		K.HideInterfaceOption(_G.InterfaceOptionsCombatPanelEnableFloatingCombatText)
	end

	if C["Unitframe"].PvPIndicator then
		local PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		PvPIndicator:SetSize(30, 33)
		if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
			PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", 2, 0)
		else
			PvPIndicator:SetPoint("LEFT", Health, "RIGHT", 2, 0)
		end
		PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator

		self.PvPIndicator = PvPIndicator
	end

	local LeaderIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	LeaderIndicator:SetSize(12, 12)
	if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
		LeaderIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 8)
	else
		LeaderIndicator:SetPoint("TOPRIGHT", Health, 0, 8)
	end

	local RaidTargetIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
		RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		RaidTargetIndicator:SetPoint("TOP", Health, "TOP", 0, 8)
	end
	RaidTargetIndicator:SetSize(16, 16)

	local ReadyCheckIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
		ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		ReadyCheckIndicator:SetPoint("CENTER", Health)
	end
	ReadyCheckIndicator:SetSize(targetHeight - 4, targetHeight - 4)

	local ResurrectIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	ResurrectIndicator:SetSize(44, 44)
	if targetPortraitStyle ~= "NoPortraits" and targetPortraitStyle ~= "OverlayPortrait" then
		ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		ResurrectIndicator:SetPoint("CENTER", Health)
	end

	local QuestIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	QuestIndicator:SetSize(20, 20)
	QuestIndicator:SetPoint("TOPLEFT", Health, "TOPRIGHT", -6, 6)

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
	Highlight:SetTexCoord(0, 1, .5, 1)
	Highlight:SetVertexColor(.6, .6, .6)
	Highlight:SetBlendMode("ADD")
	Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)

	self.Overlay = Overlay
	self.Health = Health
	self.Power = Power
	self.Name = Name
	self.Level = Level
	self.LeaderIndicator = LeaderIndicator
	self.RaidTargetIndicator = RaidTargetIndicator
	self.ReadyCheckIndicator = ReadyCheckIndicator
	self.ResurrectIndicator = ResurrectIndicator
	self.QuestIndicator = QuestIndicator
	self.Highlight = Highlight
end