local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame

function Module:CreateFocus()
	self.mystyle = "focus"

	local focusWidth = C["Unitframe"].FocusHealthWidth
	local focusPortraitStyle = C["Unitframe"].PortraitStyle.Value

	local UnitframeFont = "KkthnxUIFont"
	local UnitframeTexture = K.GetTexture(C["General"].Texture)
	local HealPredictionTexture = K.GetTexture(C["General"].Texture)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(C["Unitframe"].FocusHealthHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(5)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Health)
	end

	if C["Unitframe"].HealthbarColor.Value == "Value" then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor.Value == "Dark" then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(C["Unitframe"].FocusPowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Power)
	end

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[power]")

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetWordWrap(false)

	if focusPortraitStyle == "NoPortraits" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name] [fulllevel][afkdnd]")
		else
			self:Tag(self.Name, "[color][name] [fulllevel][afkdnd]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name][afkdnd]")
		else
			self:Tag(self.Name, "[color][name][afkdnd]")
		end
	end

	if focusPortraitStyle ~= "NoPortraits" then
		if focusPortraitStyle == "OverlayPortrait" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_FocusPortrait", self)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 1, -1)
			self.Portrait:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -1, 1)
			self.Portrait:SetAlpha(0.6)
		elseif focusPortraitStyle == "ThreeDPortraits" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_FocusPortrait", self.Health)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			self.Portrait:CreateBorder()
		elseif focusPortraitStyle ~= "ThreeDPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
			self.Portrait = self.Health:CreateTexture("KKUI_FocusPortrait", "BACKGROUND", nil, 1)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

			self.Portrait.Border = CreateFrame("Frame", nil, self)
			self.Portrait.Border:SetAllPoints(self.Portrait)
			self.Portrait.Border:CreateBorder()

			if focusPortraitStyle == "ClassPortraits" or focusPortraitStyle == "NewClassPortraits" then
				self.Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	if C["Unitframe"].FocusDebuffs then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.spacing = 6
		self.Debuffs.initialAnchor = "BOTTOMLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Name, "TOPLEFT", 0, 6)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self.Name, "TOPRIGHT", 0, 6)
		self.Debuffs.num = 15
		self.Debuffs.iconsPerRow = C["Unitframe"].TargetDebuffsPerRow

		Module:UpdateAuraContainer(focusWidth, self.Debuffs, self.Debuffs.num)

		self.Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		self.Debuffs.PostCreateIcon = Module.PostCreateAura
		self.Debuffs.PostUpdateIcon = Module.PostUpdateAura
	end

	if C["Unitframe"].FocusBuffs then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Buffs:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -6)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs.num = 20
		self.Buffs.spacing = 6
		self.Buffs.iconsPerRow = C["Unitframe"].TargetBuffsPerRow
		self.Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(focusWidth, self.Buffs, self.Buffs.num)

		self.Buffs.showStealableBuffs = true
		self.Buffs.PostCreateIcon = Module.PostCreateAura
		self.Buffs.PostUpdateIcon = Module.PostUpdateAura
	end

	if C["Unitframe"].FocusCastbar then
		self.Castbar = CreateFrame("StatusBar", "FocusCastbar", self)
		self.Castbar:SetPoint("TOP", self.Buffs, "BOTTOM", 0, -6)
		self.Castbar:SetPoint("CENTER", self.Buffs)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(focusWidth, C["Unitframe"].FocusCastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.ShieldOverlay = CreateFrame("Frame", nil, self.Castbar) -- We will use this to overlay onto our special borders.
		self.ShieldOverlay:SetAllPoints()
		self.ShieldOverlay:SetFrameLevel(5)

		self.Castbar.Shield = self.ShieldOverlay:CreateTexture(nil, "OVERLAY")
		self.Castbar.Shield:SetAtlas("Soulbinds_Portrait_Lock")
		self.Castbar.Shield:SetSize(C["Unitframe"].FocusCastbarHeight + 10, C["Unitframe"].FocusCastbarHeight + 10)
		self.Castbar.Shield:SetPoint("CENTER", 0, -14)

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Time:SetFontObject("KkthnxUIFont")
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.decimal = "%.2f"

		self.Castbar.OnUpdate = Module.OnCastbarUpdate
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostCastFail = Module.PostCastFailed
		self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible

		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Text:SetFontObject("KkthnxUIFont")
		self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
		self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Text:SetJustifyH("LEFT")
		self.Castbar.Text:SetWordWrap(false)

		if C["Unitframe"].FocusCastbarIcon then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:SetSize(20, 20)
			self.Castbar.Button:CreateBorder()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(C["Unitframe"].FocusCastbarHeight, C["Unitframe"].FocusCastbarHeight)
			self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end

		local FocusCastbarPoint
		if C["Unitframe"].FocusBuffs then
			FocusCastbarPoint = self.Buffs
		else
			FocusCastbarPoint = self.Power
		end

		K.Mover(self.Castbar, "FocusCastbar", "FocusCastbar", { "TOP", FocusCastbarPoint, "BOTTOM", 0, -6 }, focusWidth, C["Unitframe"].FocusCastbarHeight)
	end

	if C["Unitframe"].ShowHealPrediction then
		local mhpb = self.Health:CreateTexture(nil, "BORDER", nil, 5)
		mhpb:SetWidth(1)
		mhpb:SetTexture(HealPredictionTexture)
		mhpb:SetVertexColor(0, 1, 0.5, 0.25)

		local ohpb = self.Health:CreateTexture(nil, "BORDER", nil, 5)
		ohpb:SetWidth(1)
		ohpb:SetTexture(HealPredictionTexture)
		ohpb:SetVertexColor(0, 1, 0, 0.25)

		local abb = self.Health:CreateTexture(nil, "BORDER", nil, 5)
		abb:SetWidth(1)
		abb:SetTexture(HealPredictionTexture)
		abb:SetVertexColor(1, 1, 0, 0.25)

		local abbo = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
		abbo:SetAllPoints(abb)
		abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		abbo.tileSize = 32

		local oag = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
		oag:SetWidth(15)
		oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		oag:SetBlendMode("ADD")
		oag:SetAlpha(0.25)
		oag:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 2)
		oag:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -2)

		local hab = CreateFrame("StatusBar", nil, self.Health)
		hab:SetPoint("TOP")
		hab:SetPoint("BOTTOM")
		hab:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
		hab:SetWidth(focusWidth)
		hab:SetReverseFill(true)
		hab:SetStatusBarTexture(HealPredictionTexture)
		hab:SetStatusBarColor(1, 0, 0, 0.25)

		local ohg = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
		ohg:SetWidth(15)
		ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		ohg:SetBlendMode("ADD")
		ohg:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
		ohg:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)

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
	self.Level = self:CreateFontString(nil, "OVERLAY")
	if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
		self.Level:Show()
		self.Level:SetPoint("BOTTOMLEFT", self.Portrait, "TOPLEFT", 0, 4)
		self.Level:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 4)
	else
		self.Level:Hide()
	end
	self.Level:SetFontObject(UnitframeFont)
	self:Tag(self.Level, "[fulllevel]")

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
			self.PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", 2, 0)
		else
			self.PvPIndicator:SetPoint("LEFT", self.Health, "RIGHT", 2, 0)
		end
		self.PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(12, 12)
	if focusPortraitStyle == "NoPortraits" then
		self.LeaderIndicator:SetPoint("TOPRIGHT", self.Health, 0, 8)
	else
		self.LeaderIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 8)
	end

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Health)
	end
	self.ReadyCheckIndicator:SetSize(C["Unitframe"].FocusHealthHeight - 4, C["Unitframe"].FocusHealthHeight - 4)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
		self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ResurrectIndicator:SetPoint("CENTER", self.Health)
	end

	if C["Unitframe"].DebuffHighlight then
		self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
		self.DebuffHighlight:SetAllPoints(self.Health)
		self.DebuffHighlight:SetTexture(C["Media"].Textures.BlankTexture)
		self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		self.DebuffHighlight:SetBlendMode("ADD")

		self.DebuffHighlightAlpha = 0.45
		self.DebuffHighlightFilter = true
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

	self.Range = Module.CreateRangeIndicator(self)
end
